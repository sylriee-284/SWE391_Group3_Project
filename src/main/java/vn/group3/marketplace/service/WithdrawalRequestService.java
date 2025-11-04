package vn.group3.marketplace.service;

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

import java.math.BigDecimal;
import java.util.Optional;

@Service
@Transactional
public class WithdrawalRequestService {

    private static final Logger logger = LoggerFactory.getLogger(WithdrawalRequestService.class);

    private final WalletTransactionRepository walletTransactionRepository;
    private final UserRepository userRepository;

    public WithdrawalRequestService(
            WalletTransactionRepository walletTransactionRepository,
            UserRepository userRepository) {
        this.walletTransactionRepository = walletTransactionRepository;
        this.userRepository = userRepository;
    }

    /**
     * Tạo yêu cầu rút tiền mới (trạng thái PENDING)
     */
    public WalletTransaction createWithdrawalRequest(User user, BigDecimal amount, String bankName,
            String bankAccountNumber, String bankAccountName) {
        logger.info("Creating withdrawal request for user: {}, amount: {}", user.getId(), amount);

        // Validate amount
        if (amount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("Số tiền rút phải lớn hơn 0");
        }

        // Check balance
        BigDecimal currentBalance = user.getBalance();
        if (currentBalance.compareTo(amount) < 0) {
            throw new IllegalStateException("Số dư không đủ để rút tiền");
        }

        // Create withdrawal request transaction
        WalletTransaction withdrawal = WalletTransaction.builder()
                .user(user)
                .type(WalletTransactionType.WITHDRAWAL)
                .amount(amount)
                .paymentStatus(WalletTransactionStatus.PENDING)
                .paymentMethod("BANK_TRANSFER")
                .note(String.format("Yêu cầu rút tiền - %s - %s - %s", bankName, bankAccountNumber, bankAccountName))
                .paymentRef("WD-" + System.currentTimeMillis() + "-" + user.getId())
                .build();

        return walletTransactionRepository.save(withdrawal);
    }

    /**
     * Cập nhật yêu cầu rút tiền (chỉ khi còn PENDING)
     */
    public WalletTransaction updateWithdrawalRequest(Long withdrawalId, BigDecimal newAmount,
            String bankName, String bankAccountNumber,
            String bankAccountName, User user) {
        logger.info("Updating withdrawal request: {}", withdrawalId);

        WalletTransaction withdrawal = walletTransactionRepository.findById(withdrawalId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy yêu cầu rút tiền"));

        // Verify ownership
        if (!withdrawal.getUser().getId().equals(user.getId())) {
            throw new SecurityException("Bạn không có quyền sửa yêu cầu này");
        }

        // Only allow update if status is PENDING
        if (withdrawal.getPaymentStatus() != WalletTransactionStatus.PENDING) {
            throw new IllegalStateException("Chỉ có thể sửa yêu cầu đang chờ duyệt");
        }

        // Validate new amount
        if (newAmount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("Số tiền rút phải lớn hơn 0");
        }

        // Check balance
        BigDecimal currentBalance = user.getBalance();
        if (currentBalance.compareTo(newAmount) < 0) {
            throw new IllegalStateException("Số dư không đủ");
        }

        // Update withdrawal details
        withdrawal.setAmount(newAmount);
        withdrawal.setNote(
                String.format("Yêu cầu rút tiền - %s - %s - %s", bankName, bankAccountNumber, bankAccountName));

        // Lưu thay đổi
        walletTransactionRepository.save(withdrawal);

        // Đọc lại từ DB để verify status chưa đổi (tránh race condition)
        WalletTransaction verified = walletTransactionRepository.findById(withdrawalId)
                .orElseThrow(() -> new IllegalStateException("Lỗi khi lưu yêu cầu"));

        if (verified.getPaymentStatus() != WalletTransactionStatus.PENDING) {
            throw new IllegalStateException("Yêu cầu đã được admin xử lý, không thể cập nhật");
        }

        return verified;
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

        // Update status to FAILED NGAY để lock
        withdrawal.setPaymentStatus(WalletTransactionStatus.FAILED);
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

}
