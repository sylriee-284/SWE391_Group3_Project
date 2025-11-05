package vn.group3.marketplace.service;

import org.springframework.context.ApplicationContext;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import vn.group3.marketplace.domain.entity.User;
import vn.group3.marketplace.domain.entity.WalletTransaction;
import vn.group3.marketplace.domain.enums.WalletTransactionStatus;
import vn.group3.marketplace.domain.enums.WalletTransactionType;
import vn.group3.marketplace.repository.WalletTransactionRepository;
import vn.group3.marketplace.repository.UserRepository;
import vn.group3.marketplace.util.PerUserSerialExecutor;

import java.math.BigDecimal;
import java.util.Optional;
import java.util.concurrent.Future;

@Service
public class WithdrawalRequestService {

    private static final Logger logger = LoggerFactory.getLogger(WithdrawalRequestService.class);

    private final WalletTransactionRepository walletTransactionRepository;
    private final UserRepository userRepository;
    private final PerUserSerialExecutor perUserSerialExecutor;
    private final ApplicationContext applicationContext;

    public WithdrawalRequestService(
            WalletTransactionRepository walletTransactionRepository,
            UserRepository userRepository,
            PerUserSerialExecutor perUserSerialExecutor,
            ApplicationContext applicationContext) {
        this.walletTransactionRepository = walletTransactionRepository;
        this.userRepository = userRepository;
        this.perUserSerialExecutor = perUserSerialExecutor;
        this.applicationContext = applicationContext;
    }

    // Lazy getter để tránh circular dependency
    private WithdrawalRequestService getSelf() {
        return applicationContext.getBean(WithdrawalRequestService.class);
    }

    /**
     * Tạo yêu cầu rút tiền mới - Sử dụng PerUserSerialExecutor queue
     * 
     * Quy trình:
     * 1. Đưa yêu cầu vào queue của seller theo userId
     * 2. Trong queue sẽ thực hiện tuần tự:
     * a. Kiểm tra xem đã có yêu cầu PENDING nào chưa
     * b. Nếu có -> throw error "Đang có 1 yêu cầu trước đó, vui lòng đợi"
     * c. Nếu chưa -> Trừ tiền và lưu giao dịch PENDING
     * 
     * @param user              Seller tạo yêu cầu
     * @param amount            Số tiền rút
     * @param bankName          Tên ngân hàng
     * @param bankAccountNumber Số tài khoản
     * @param bankAccountName   Tên chủ tài khoản
     * @return Future chứa WalletTransaction đã tạo
     * @throws RejectedExecutionException nếu queue đầy
     */
    public Future<WalletTransaction> createWithdrawalRequestAsync(
            User user, BigDecimal amount, String bankName,
            String bankAccountNumber, String bankAccountName) {

        logger.info("Enqueueing withdrawal request for user: {}, amount: {}", user.getId(), amount);

        // Submit vào queue - PHẢI gọi qua getSelf() để trigger @Transactional proxy
        return perUserSerialExecutor.submit(user.getId(), () -> {
            return getSelf().doCreateWithdrawalInTransaction(user, amount, bankName, bankAccountNumber,
                    bankAccountName);
        });
    }

    /**
     * Logic thực tế xử lý trong queue - đảm bảo thread-safe
     * PHẢI là public để @Transactional hoạt động (Spring proxy)
     * 
     * Quy trình xử lý:
     * 1. Validate số tiền rút
     * 2. Kiểm tra xem đã có yêu cầu PENDING nào chưa (thread-safe trong queue)
     * 3. Kiểm tra số dư
     * 4. Trừ tiền ngay lập tức (atomic operation)
     * 5. Tạo giao dịch với trạng thái PENDING
     */
    @Transactional
    public WalletTransaction doCreateWithdrawalInTransaction(
            User user, BigDecimal amount, String bankName,
            String bankAccountNumber, String bankAccountName) {

        logger.info("Processing withdrawal request in queue for user: {}, amount: {}", user.getId(), amount);

        try {
            // 1. Validate amount
            if (amount == null || amount.compareTo(BigDecimal.ZERO) <= 0) {
                logger.error("Invalid withdrawal amount: {}", amount);
                throw new IllegalArgumentException("Số tiền rút phải lớn hơn 0");
            }
            
            // Validate minimum amount (100,000 VNĐ)
            BigDecimal MIN_WITHDRAWAL_AMOUNT = new BigDecimal("100000");
            if (amount.compareTo(MIN_WITHDRAWAL_AMOUNT) < 0) {
                logger.error("Withdrawal amount {} is below minimum {}", amount, MIN_WITHDRAWAL_AMOUNT);
                throw new IllegalArgumentException("Số tiền rút tối thiểu là 100,000 VNĐ");
            }

            // 2. Check xem đã có yêu cầu PENDING nào chưa (trong queue đảm bảo thread-safe)
            boolean hasPending = walletTransactionRepository.existsByUserAndTypeAndPaymentStatus(
                    user, WalletTransactionType.WITHDRAWAL, WalletTransactionStatus.PENDING);

            if (hasPending) {
                logger.warn("User {} already has a pending withdrawal request", user.getId());
                throw new IllegalStateException(
                        "Đang có 1 yêu cầu rút tiền trước đó đang chờ xử lý, vui lòng đợi yêu cầu được duyệt hoặc từ chối");
            }

            // 3. Refresh user để có balance mới nhất
            User refreshedUser = userRepository.findById(user.getId())
                    .orElseThrow(() -> new IllegalStateException("User không tồn tại"));

            // 4. Check balance
            BigDecimal currentBalance = refreshedUser.getBalance();
            if (currentBalance.compareTo(amount) < 0) {
                logger.error("Insufficient balance for user {}: balance={}, requested={}",
                        refreshedUser.getId(), currentBalance, amount);
                throw new IllegalStateException(
                        String.format("Số dư không đủ để rút tiền. Số dư hiện tại: %s, số tiền yêu cầu: %s",
                                currentBalance, amount));
            }

            // 5. Trừ tiền ngay (atomic operation) - đảm bảo không race condition
            int updatedRows = userRepository.decrementBalance(refreshedUser.getId(), amount);
            if (updatedRows != 1) {
                logger.error("Failed to decrement balance for user {}: updatedRows={}", refreshedUser.getId(),
                        updatedRows);
                throw new IllegalStateException("Không thể trừ tiền - có thể số dư đã thay đổi. Vui lòng thử lại");
            }

            // 6. Tạo withdrawal transaction với status PENDING
            WalletTransaction withdrawal = WalletTransaction.builder()
                    .user(refreshedUser)
                    .type(WalletTransactionType.WITHDRAWAL)
                    .amount(amount)
                    .paymentStatus(WalletTransactionStatus.PENDING)
                    .paymentMethod("BANK_TRANSFER")
                    .note(String.format("Yêu cầu rút tiền - %s - %s - %s", bankName, bankAccountNumber,
                            bankAccountName))
                    .paymentRef("WD-" + System.currentTimeMillis() + "-" + refreshedUser.getId())
                    .build();

            WalletTransaction savedWithdrawal = walletTransactionRepository.save(withdrawal);

            logger.info("✅ Withdrawal request created successfully: ID={}, User={}, Amount={}, NewBalance={}",
                    savedWithdrawal.getId(), refreshedUser.getId(), amount, currentBalance.subtract(amount));

            return savedWithdrawal;

        } catch (Exception e) {
            logger.error("❌ Error creating withdrawal request for user {}: {}", user.getId(), e.getMessage(), e);
            throw e;
        }
    }

    /**
     * Cập nhật yêu cầu rút tiền - CHỈ cho phép cập nhật thông tin khác, KHÔNG cho
     * sửa số tiền
     * Yêu cầu phải chưa được chấp nhận (PENDING)
     * 
     * Các quy tắc:
     * - CHỈ cho phép sửa thông tin ngân hàng (bankName, bankAccountNumber,
     * bankAccountName)
     * - KHÔNG cho phép sửa trường amount (số tiền)
     * - Yêu cầu phải ở trạng thái PENDING (chưa được chấp nhận)
     */
    @Transactional
    public WalletTransaction updateWithdrawalRequest(Long withdrawalId, String bankName,
            String bankAccountNumber, String bankAccountName, User user) {
        logger.info("Updating withdrawal request: {} by user: {}", withdrawalId, user.getId());

        WalletTransaction withdrawal = walletTransactionRepository.findById(withdrawalId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy yêu cầu rút tiền"));

        // Verify ownership
        if (!withdrawal.getUser().getId().equals(user.getId())) {
            logger.warn("User {} attempted to update withdrawal {} owned by user {}",
                    user.getId(), withdrawalId, withdrawal.getUser().getId());
            throw new SecurityException("Bạn không có quyền sửa yêu cầu này");
        }

        // Chỉ cho phép update khi PENDING (chưa được chấp nhận)
        if (withdrawal.getPaymentStatus() != WalletTransactionStatus.PENDING) {
            logger.warn("Cannot update withdrawal {} - status is {}", withdrawalId, withdrawal.getPaymentStatus());
            throw new IllegalStateException("Chỉ có thể sửa yêu cầu đang chờ duyệt (chưa được chấp nhận)");
        }

        // Cập nhật CHỈ thông tin ngân hàng - KHÔNG cho sửa amount
        // Amount đã được lock khi tạo yêu cầu và đã trừ tiền
        String updatedNote = String.format("Yêu cầu rút tiền - %s - %s - %s", bankName, bankAccountNumber,
                bankAccountName);
        withdrawal.setNote(updatedNote);

        WalletTransaction saved = walletTransactionRepository.save(withdrawal);

        logger.info("Withdrawal request updated successfully: ID={}, NewBankInfo: {} - {} - {}",
                withdrawalId, bankName, bankAccountNumber, bankAccountName);
        return saved;
    }

    /**
     * Lấy danh sách yêu cầu rút tiền của seller
     */
    @Transactional(readOnly = true)
    public Page<WalletTransaction> getWithdrawalRequestsByUser(User user, int page, int size) {
        Pageable pageable = PageRequest.of(page, size);
        return walletTransactionRepository.findByUserAndTypeOrderByIdDesc(user, WalletTransactionType.WITHDRAWAL,
                pageable);
    }

    /**
     * Lấy tất cả yêu cầu rút tiền (cho admin)
     */
    @Transactional(readOnly = true)
    public Page<WalletTransaction> getAllWithdrawalRequests(int page, int size) {
        Pageable pageable = PageRequest.of(page, size);
        return walletTransactionRepository.findByTypeWithUserOrderByIdDesc(WalletTransactionType.WITHDRAWAL, pageable);
    }

    /**
     * Lấy yêu cầu rút tiền theo trạng thái (cho admin)
     */
    @Transactional(readOnly = true)
    public Page<WalletTransaction> getWithdrawalRequestsByStatus(WalletTransactionStatus status, int page, int size) {
        Pageable pageable = PageRequest.of(page, size);
        return walletTransactionRepository.findByTypeAndPaymentStatusWithUserOrderByIdDesc(
                WalletTransactionType.WITHDRAWAL, status, pageable);
    }

    /**
     * Lấy yêu cầu rút tiền với các bộ lọc (cho admin)
     */
    @Transactional(readOnly = true)
    public Page<WalletTransaction> getWithdrawalRequestsWithFilters(
            WalletTransactionStatus status, String fromDate, String toDate, int page, int size) {
        Pageable pageable = PageRequest.of(page, size);
        return walletTransactionRepository.findWithdrawalsByFilters(
                WalletTransactionType.WITHDRAWAL, status, fromDate, toDate, pageable);
    }

    /**
     * Admin duyệt yêu cầu rút tiền
     */
    @Transactional
    public WalletTransaction approveWithdrawal(Long withdrawalId, User admin) {
        logger.info("Admin {} approving withdrawal: {}", admin.getId(), withdrawalId);

        WalletTransaction withdrawal = walletTransactionRepository.findById(withdrawalId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy yêu cầu rút tiền"));

        // Kiểm tra status - nếu không còn PENDING thì có thể seller đang sửa
        if (withdrawal.getPaymentStatus() != WalletTransactionStatus.PENDING) {
            throw new IllegalStateException("Yêu cầu không ở trạng thái chờ duyệt");
        }

        User user = withdrawal.getUser();
        BigDecimal amount = withdrawal.getAmount();

        // Trừ tiền từ tài khoản user
        int rows = userRepository.decrementBalance(user.getId(), amount);
        if (rows != 1) {
            throw new IllegalStateException("Không đủ số dư để thực hiện rút tiền");
        }

        // Update status to SUCCESS NGAY để lock
        withdrawal.setPaymentStatus(WalletTransactionStatus.SUCCESS);
        withdrawal.setNote(withdrawal.getNote() + " - Đã duyệt bởi admin #" + admin.getId());

        WalletTransaction saved = walletTransactionRepository.save(withdrawal);

        // Flush để đảm bảo DB được update ngay
        walletTransactionRepository.flush();

        return saved;
    }

    /**
     * Admin từ chối yêu cầu rút tiền
     */
    @Transactional
    public WalletTransaction rejectWithdrawal(Long withdrawalId, String reason, User admin) {
        logger.info("Admin {} rejecting withdrawal: {}", admin.getId(), withdrawalId);

        WalletTransaction withdrawal = walletTransactionRepository.findById(withdrawalId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy yêu cầu rút tiền"));

        // Kiểm tra status - nếu không còn PENDING thì có thể seller đang sửa
        if (withdrawal.getPaymentStatus() != WalletTransactionStatus.PENDING) {
            throw new IllegalStateException("Yêu cầu không ở trạng thái chờ duyệt");
        }

        // Update status to CANCELLED NGAY để lock
        withdrawal.setPaymentStatus(WalletTransactionStatus.CANCELLED);
        withdrawal.setNote(reason); // Lưu lý do từ chối vào note

        WalletTransaction saved = walletTransactionRepository.save(withdrawal);

        // Flush để đảm bảo DB được update ngay
        walletTransactionRepository.flush();

        return saved;
    }

    /**
     * Seller hủy yêu cầu rút tiền (chỉ khi còn PENDING)
     */
    public void cancelWithdrawalRequest(Long withdrawalId, User user) {
        logger.info("User {} cancelling withdrawal: {}", user.getId(), withdrawalId);

        WalletTransaction withdrawal = walletTransactionRepository.findById(withdrawalId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy yêu cầu rút tiền"));

        // Verify ownership
        if (!withdrawal.getUser().getId().equals(user.getId())) {
            throw new SecurityException("Bạn không có quyền hủy yêu cầu này");
        }

        if (withdrawal.getPaymentStatus() != WalletTransactionStatus.PENDING) {
            throw new IllegalStateException("Chỉ có thể hủy yêu cầu đang chờ duyệt");
        }

        withdrawal.setPaymentStatus(WalletTransactionStatus.CANCELLED);
        withdrawal.setNote(withdrawal.getNote() + " - Đã hủy bởi người dùng");

        walletTransactionRepository.save(withdrawal);
    }

    /**
     * Lấy chi tiết yêu cầu rút tiền
     */
    @Transactional(readOnly = true)
    public Optional<WalletTransaction> getWithdrawalById(Long id) {
        return walletTransactionRepository.findById(id);
    }

    /**
     * Kiểm tra quyền truy cập yêu cầu rút tiền
     */
    @Transactional(readOnly = true)
    public boolean canUserAccessWithdrawal(WalletTransaction withdrawal, User user) {
        if (withdrawal == null || user == null)
            return false;
        return withdrawal.getUser() != null &&
                withdrawal.getUser().getId().equals(user.getId());
    }

    /**
     * Kiểm tra xem user có yêu cầu rút tiền PENDING nào không
     */
    @Transactional(readOnly = true)
    public boolean hasPendingWithdrawal(User user) {
        return walletTransactionRepository.existsByUserAndTypeAndPaymentStatus(
                user, WalletTransactionType.WITHDRAWAL, WalletTransactionStatus.PENDING);
    }

    /**
     * Admin duyệt yêu cầu rút tiền - Async với queue
     * Đưa vào queue của user để xử lý tuần tự
     */
    public Future<WalletTransaction> approveWithdrawalAsync(Long withdrawalId, User admin) {
        logger.info("Enqueueing approve withdrawal request: {} by admin: {}", withdrawalId, admin.getId());

        // Lấy withdrawal để biết userId cho queue
        WalletTransaction withdrawal = walletTransactionRepository.findById(withdrawalId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy yêu cầu rút tiền"));

        Long userId = withdrawal.getUser().getId();

        return perUserSerialExecutor.submit(userId, () -> {
            return getSelf().doApproveWithdrawalInTransaction(withdrawalId, admin);
        });
    }

    /**
     * Admin duyệt yêu cầu rút tiền (tiền đã được trừ) - Xử lý trong queue
     * 
     * Logic:
     * 1. Kiểm tra status - nếu đã SUCCESS thì báo lỗi đã duyệt trước đó
     * 2. Kiểm tra status phải là PENDING mới cho phép duyệt
     * 3. Cập nhật status thành SUCCESS
     * 4. Không hoàn tiền (tiền đã được trừ khi tạo yêu cầu)
     */
    @Transactional
    public WalletTransaction doApproveWithdrawalInTransaction(Long withdrawalId, User admin) {
        logger.info("Processing approve withdrawal in queue: {} by admin: {}", withdrawalId, admin.getId());

        try {
            WalletTransaction withdrawal = walletTransactionRepository.findById(withdrawalId)
                    .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy yêu cầu rút tiền"));

            // Check nếu đã duyệt trước đó
            if (withdrawal.getPaymentStatus() == WalletTransactionStatus.SUCCESS) {
                logger.warn("Cannot approve withdrawal {} - already approved", withdrawalId);
                throw new IllegalStateException("Yêu cầu này đã được duyệt trước đó");
            }

            // Check nếu đã bị từ chối
            if (withdrawal.getPaymentStatus() == WalletTransactionStatus.CANCELLED) {
                logger.warn("Cannot approve withdrawal {} - already rejected", withdrawalId);
                throw new IllegalStateException("Không thể duyệt yêu cầu đã bị từ chối");
            }

            // Check nếu đã hủy
            if (withdrawal.getPaymentStatus() == WalletTransactionStatus.CANCELLED) {
                logger.warn("Cannot approve withdrawal {} - already cancelled", withdrawalId);
                throw new IllegalStateException("Không thể duyệt yêu cầu đã bị hủy");
            }

            // Chỉ cho phép duyệt khi đang PENDING
            if (withdrawal.getPaymentStatus() != WalletTransactionStatus.PENDING) {
                logger.warn("Cannot approve withdrawal {} - invalid status: {}", withdrawalId,
                        withdrawal.getPaymentStatus());
                throw new IllegalStateException("Yêu cầu không ở trạng thái chờ duyệt");
            }

            // Chỉ cần cập nhật trạng thái (tiền đã được trừ khi tạo yêu cầu)
            withdrawal.setPaymentStatus(WalletTransactionStatus.SUCCESS);
            withdrawal.setNote(withdrawal.getNote() + " - Đã duyệt bởi admin #" + admin.getId());

            WalletTransaction saved = walletTransactionRepository.save(withdrawal);
            logger.info("✅ Withdrawal approved: ID={}, Admin={}", withdrawalId, admin.getId());

            return saved;

        } catch (Exception e) {
            logger.error("❌ Error approving withdrawal {}: {}", withdrawalId, e.getMessage(), e);
            throw e;
        }
    }

    /**
     * Admin từ chối yêu cầu rút tiền - Async với queue
     * Đưa vào queue của user để xử lý tuần tự và hoàn tiền
     */
    public Future<WalletTransaction> rejectWithdrawalAsync(Long withdrawalId, String reason, User admin) {
        logger.info("Enqueueing reject withdrawal request: {} by admin: {}", withdrawalId, admin.getId());

        // Lấy withdrawal để biết userId cho queue
        WalletTransaction withdrawal = walletTransactionRepository.findById(withdrawalId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy yêu cầu rút tiền"));

        Long userId = withdrawal.getUser().getId();

        return perUserSerialExecutor.submit(userId, () -> {
            return getSelf().doRejectWithdrawalInTransaction(withdrawalId, reason, admin);
        });
    }

    /**
     * Admin từ chối yêu cầu rút tiền (hoàn tiền) - Xử lý trong queue
     * 
     * Logic:
     * 1. Kiểm tra status - nếu đã FAILED thì báo lỗi đã từ chối trước đó
     * 2. Kiểm tra status phải là PENDING mới cho phép từ chối
     * 3. Hoàn tiền vào tài khoản user
     * 4. Cập nhật status thành FAILED
     */
    @Transactional
    public WalletTransaction doRejectWithdrawalInTransaction(Long withdrawalId, String reason, User admin) {
        logger.info("Processing reject withdrawal in queue: {} by admin: {}", withdrawalId, admin.getId());

        try {
            WalletTransaction withdrawal = walletTransactionRepository.findById(withdrawalId)
                    .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy yêu cầu rút tiền"));

            // Check nếu đã bị từ chối trước đó
            if (withdrawal.getPaymentStatus() == WalletTransactionStatus.CANCELLED) {
                logger.warn("Cannot reject withdrawal {} - already rejected", withdrawalId);
                throw new IllegalStateException("Yêu cầu này đã bị từ chối trước đó");
            }

            // Check nếu đã duyệt
            if (withdrawal.getPaymentStatus() == WalletTransactionStatus.SUCCESS) {
                logger.warn("Cannot reject withdrawal {} - already approved", withdrawalId);
                throw new IllegalStateException("Không thể từ chối yêu cầu đã được duyệt");
            }

            // Check nếu đã hủy
            if (withdrawal.getPaymentStatus() == WalletTransactionStatus.CANCELLED) {
                logger.warn("Cannot reject withdrawal {} - already cancelled", withdrawalId);
                throw new IllegalStateException("Không thể từ chối yêu cầu đã bị hủy");
            }

            // Chỉ cho phép từ chối khi đang PENDING
            if (withdrawal.getPaymentStatus() != WalletTransactionStatus.PENDING) {
                logger.warn("Cannot reject withdrawal {} - invalid status: {}", withdrawalId,
                        withdrawal.getPaymentStatus());
                throw new IllegalStateException("Yêu cầu không ở trạng thái chờ duyệt");
            }

            // Hoàn tiền vào tài khoản user
            BigDecimal amount = withdrawal.getAmount();
            int updatedRows = userRepository.incrementBalance(withdrawal.getUser().getId(), amount);
            if (updatedRows != 1) {
                logger.error("Failed to refund for user {}: updatedRows={}", withdrawal.getUser().getId(), updatedRows);
                throw new IllegalStateException("Không thể hoàn tiền");
            }

            withdrawal.setPaymentStatus(WalletTransactionStatus.CANCELLED);
            withdrawal.setNote(withdrawal.getNote() + " - Từ chối: " + reason + " - Admin #" + admin.getId());

            WalletTransaction saved = walletTransactionRepository.save(withdrawal);
            logger.info("✅ Withdrawal rejected and refunded: ID={}, Amount={}, Admin={}",
                    withdrawalId, amount, admin.getId());

            return saved;

        } catch (Exception e) {
            logger.error("❌ Error rejecting withdrawal {}: {}", withdrawalId, e.getMessage(), e);
            throw e;
        }
    }

    /**
     * User hủy yêu cầu rút tiền - Async với queue
     * Đưa vào queue để xử lý tuần tự, tránh race condition
     */
    public Future<Void> cancelWithdrawalRequestAsync(Long withdrawalId, User user) {
        logger.info("Enqueueing cancel withdrawal request: {} for user: {}", withdrawalId, user.getId());

        return perUserSerialExecutor.submit(user.getId(), () -> {
            getSelf().doCancelWithdrawalInTransaction(withdrawalId, user);
            return null;
        });
    }

    /**
     * User hủy yêu cầu rút tiền (hoàn tiền) - Xử lý trong queue
     * 
     * Logic:
     * 1. Kiểm tra ownership
     * 2. Kiểm tra status (chỉ cho phép PENDING)
     * 3. Kiểm tra xem đã bị hủy trước đó chưa (CANCELLED)
     * 4. Hoàn tiền
     * 5. Cập nhật status thành CANCELLED
     */
    @Transactional
    public void doCancelWithdrawalInTransaction(Long withdrawalId, User user) {
        logger.info("Processing cancel withdrawal in queue: {} for user: {}", withdrawalId, user.getId());

        try {
            WalletTransaction withdrawal = walletTransactionRepository.findById(withdrawalId)
                    .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy yêu cầu rút tiền"));

            // Verify ownership
            if (!withdrawal.getUser().getId().equals(user.getId())) {
                logger.warn("User {} attempted to cancel withdrawal {} owned by user {}",
                        user.getId(), withdrawalId, withdrawal.getUser().getId());
                throw new SecurityException("Bạn không có quyền hủy yêu cầu này");
            }

            // Check nếu đã bị hủy trước đó
            if (withdrawal.getPaymentStatus() == WalletTransactionStatus.CANCELLED) {
                logger.warn("Withdrawal {} already cancelled for user {}", withdrawalId, user.getId());
                throw new IllegalStateException("Yêu cầu rút tiền này đã được hủy và hoàn tiền trước đó");
            }

            // Check nếu đã được chấp nhận (SUCCESS)
            if (withdrawal.getPaymentStatus() == WalletTransactionStatus.SUCCESS) {
                logger.warn("Withdrawal {} already approved - cannot cancel for user {}", withdrawalId, user.getId());
                throw new IllegalStateException("Yêu cầu này đã được chấp nhận, không thể hủy");
            }

            // Chỉ cho phép hủy khi PENDING
            if (withdrawal.getPaymentStatus() != WalletTransactionStatus.PENDING) {
                logger.warn("Cannot cancel withdrawal {} - status is {}", withdrawalId, withdrawal.getPaymentStatus());
                throw new IllegalStateException(
                        String.format("Chỉ có thể hủy yêu cầu đang chờ duyệt. Trạng thái hiện tại: %s",
                                withdrawal.getPaymentStatus()));
            }

            // Hoàn tiền vào tài khoản user
            BigDecimal amount = withdrawal.getAmount();
            int updatedRows = userRepository.incrementBalance(user.getId(), amount);
            if (updatedRows != 1) {
                logger.error("Failed to refund for user {}: updatedRows={}", user.getId(), updatedRows);
                throw new IllegalStateException("Không thể hoàn tiền. Vui lòng thử lại");
            }

            withdrawal.setPaymentStatus(WalletTransactionStatus.CANCELLED);
            withdrawal.setNote(withdrawal.getNote() + " - Đã hủy bởi người dùng");

            walletTransactionRepository.save(withdrawal);
            logger.info("✅ Withdrawal cancelled and refunded: ID={}, User={}, Amount={}",
                    withdrawalId, user.getId(), amount);

        } catch (Exception e) {
            logger.error("❌ Error cancelling withdrawal {}: {}", withdrawalId, e.getMessage(), e);
            throw e;
        }
    }
}