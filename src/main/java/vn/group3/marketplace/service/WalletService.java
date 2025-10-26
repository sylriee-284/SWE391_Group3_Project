package vn.group3.marketplace.service;

import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import vn.group3.marketplace.domain.entity.Order;
import vn.group3.marketplace.domain.entity.User;
// Wallet entity removed - balance stored on User directly
import vn.group3.marketplace.domain.entity.WalletTransaction;
import vn.group3.marketplace.domain.enums.WalletTransactionType;
import vn.group3.marketplace.domain.enums.WalletTransactionStatus;
import vn.group3.marketplace.repository.UserRepository;
import vn.group3.marketplace.repository.WalletTransactionRepository;
import vn.group3.marketplace.service.WalletService;
import vn.group3.marketplace.util.SecurityContextUtils;

import java.util.Optional;

@Service
@Transactional
public class WalletService {

    private static final Logger logger = LoggerFactory.getLogger(WalletService.class);
    private final WalletTransactionRepository walletTransactionRepository;
    private final UserRepository userRepository;

    public WalletService(
            WalletTransactionRepository walletTransactionRepository,
            UserRepository userRepository) {
        this.walletTransactionRepository = walletTransactionRepository;
        this.userRepository = userRepository;
    }

    /**
     * Tạo pending deposit transaction cho user (chờ thanh toán VNPay)
     */
    @PreAuthorize("isAuthenticated() and #user.id == authentication.principal.id")
    public WalletTransaction createPendingDeposit(User user, java.math.BigDecimal amount, String paymentRef) {
        // Lấy managed User từ DB và dùng balance trên user
        User managed = userRepository.findById(user.getId())
                .orElseThrow(() -> new RuntimeException("User not found with id: " + user.getId()));

        WalletTransaction transaction = WalletTransaction.builder()
                .user(managed)
                .type(WalletTransactionType.DEPOSIT)
                .amount(amount)
                .paymentRef(paymentRef)
                .paymentStatus(WalletTransactionStatus.PENDING)
                .paymentMethod("VNPAY")
                .note("Nạp tiền qua VNPay")
                .build();

        // Set createdBy manually since AuditorAware không tham chiếu được trong luồng
        // này
        Long currentUserId = SecurityContextUtils.getCurrentUserId();
        if (currentUserId != null) {
            transaction.setCreatedBy(currentUserId);
        } else {
            // Fallback: sử dụng user.getId() từ parameter nếu SecurityContext không có
            transaction.setCreatedBy(user.getId());
        }

        return walletTransactionRepository.save(transaction);
    }

    /**
     * Xử lý khi VNPay callback thành công
     */
    @Transactional
    public void processSuccessfulDeposit(String paymentRef) {
        logger.info("=== Processing Successful Deposit ===");
        logger.info("Payment Ref: {}", paymentRef);

        Optional<WalletTransaction> transactionOpt = walletTransactionRepository.findByPaymentRef(paymentRef);
        if (transactionOpt.isPresent()) {
            WalletTransaction transaction = transactionOpt.get();

            logger.debug("Found transaction: {}", transaction.getId());
            logger.debug("Transaction amount: {}", transaction.getAmount());
            logger.debug("Current status: {}", transaction.getPaymentStatus());

            // Kiểm tra transaction chưa được xử lý
            if (transaction.getPaymentStatus() != WalletTransactionStatus.PENDING) {
                logger.warn("Transaction already processed, status: {}", transaction.getPaymentStatus());
                return;
            }

            // Cập nhật số dư bằng UPDATE nguyên tử ở DB để an toàn multi-instance
            Long userId = transaction.getUser().getId();
            int rows = userRepository.incrementBalance(userId, transaction.getAmount());
            if (rows != 1) {
                logger.warn("UPDATE failed: {} rows for userId={}", rows, userId);
            } else {
                logger.info("Incremented balance for userId={} by {}", userId, transaction.getAmount());
            }

            // Cập nhật trạng thái transaction
            transaction.setPaymentStatus(WalletTransactionStatus.SUCCESS);
            walletTransactionRepository.save(transaction);
            logger.info("Updated transaction status to SUCCESS");
        } else {
            logger.error("Transaction not found with payment ref: {}", paymentRef);
        }
        logger.info("=== Deposit Processing Complete ===");
    }

    // Tìm ví theo user ID
    @PreAuthorize("hasRole('ADMIN') or (isAuthenticated() and #userId == authentication.principal.id)")
    public java.util.Optional<java.math.BigDecimal> findBalanceByUserId(Long userId) {
        return userRepository.findById(userId).map(User::getBalance);
    }

    /**
     * Cập nhật trạng thái giao dịch thành CANCELLED
     */
    @Transactional
    public void updateTransactionStatusToCancelled(String paymentRef) {
        logger.info("=== Cancelling Transaction ===");
        logger.info("Payment Ref: {}", paymentRef);

        Optional<WalletTransaction> transactionOpt = walletTransactionRepository.findByPaymentRef(paymentRef);
        if (transactionOpt.isPresent()) {
            WalletTransaction transaction = transactionOpt.get();

            logger.debug("Found transaction: {}", transaction.getId());
            logger.debug("Current status: {}", transaction.getPaymentStatus());

            // Chỉ cập nhật nếu transaction đang ở trạng thái PENDING
            if (transaction.getPaymentStatus() == WalletTransactionStatus.PENDING) {
                transaction.setPaymentStatus(WalletTransactionStatus.CANCELLED);
                walletTransactionRepository.save(transaction);
                logger.info("Updated transaction status to CANCELLED");
            } else {
                logger.warn("Transaction not in PENDING state, current status: {}", transaction.getPaymentStatus());
            }
        } else {
            logger.error("Transaction not found with payment ref: {}", paymentRef);
        }
        logger.info("=== Transaction Cancellation Complete ===");
    }

    /**
     * Trả về userId liên kết với paymentRef nếu có.
     */
    public java.util.Optional<Long> findUserIdByPaymentRef(String paymentRef) {
        try {
            java.util.Optional<WalletTransaction> txOpt = walletTransactionRepository.findByPaymentRef(paymentRef);
            if (txOpt.isPresent()) {
                WalletTransaction tx = txOpt.get();
                if (tx.getUser() != null) {
                    return java.util.Optional.ofNullable(tx.getUser().getId());
                }
            }
            return java.util.Optional.empty();
        } catch (Exception ex) {
            logger.error("Error finding userId by paymentRef {}: {}", paymentRef, ex.getMessage());
            return java.util.Optional.empty();
        }
    }

    /**
     * Tìm WalletTransaction theo paymentRef để check status
     */
    public java.util.Optional<WalletTransaction> findTransactionByPaymentRef(String paymentRef) {
        try {
            return walletTransactionRepository.findByPaymentRef(paymentRef);
        } catch (Exception ex) {
            logger.error("Error finding transaction by paymentRef {}: {}", paymentRef, ex.getMessage());
            return java.util.Optional.empty();
        }
    }

    // Xử lý trừ tiền khi mua hàng
    @Transactional
    public boolean processPurchasePayment(Long userId, java.math.BigDecimal amount, Order order) {
        logger.info("=== Processing Purchase Payment ===");
        logger.info("User ID: {}, Amount: {}, Order ID: {}", userId, amount, order.getId());

        // Lấy user từ database
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found with id: " + userId));

        // Tạo transaction trước với trạng thái PENDING
        WalletTransaction transaction = WalletTransaction.builder()
                .user(user)
                .type(WalletTransactionType.PAYMENT)
                .amount(amount)
                .refOrder(order)
                .paymentRef(order.getId().toString())
                .paymentStatus(WalletTransactionStatus.PENDING)
                .paymentMethod("INTERNAL")
                .note("Thanh toán đơn hàng #" + order.getId().toString())
                .build();

        // Set createdBy manually since AuditorAware không tham chiếu được trong luồng
        // này
        Long currentUserId = SecurityContextUtils.getCurrentUserId();
        if (currentUserId != null) {
            transaction.setCreatedBy(currentUserId);
        } else {
            // Fallback: sử dụng userId từ parameter nếu SecurityContext không có
            transaction.setCreatedBy(userId);
        }

        transaction = walletTransactionRepository.save(transaction);

        try {
            // Cập nhật số dư bằng UPDATE nguyên tử
            // Method decrementBalance chỉ trừ khi balance >= amount
            int rows = userRepository.decrementBalance(userId, amount);

            if (rows != 1) {
                logger.error("❌ Payment failed for userId={}. Required: {}", userId, amount);
                logger.error("❌ decrementBalance returned {} rows (expected 1)", rows);

                transaction.setPaymentStatus(WalletTransactionStatus.FAILED);
                walletTransactionRepository.save(transaction);
                logger.info("❌ Payment failed due to insufficient balance for userId={}", userId);
                return false; // Payment failed - KHÔNG throw exception
            }

            // Kiểm tra số dư sau khi trừ tiền
            User updatedUser = userRepository.findById(userId)
                    .orElseThrow(() -> new RuntimeException("User not found with id: " + userId));
            logger.info("Balance updated successfully - User {} balance: {}",
                    userId, updatedUser.getBalance());

            // Cập nhật trạng thái transaction thành công
            transaction.setPaymentStatus(WalletTransactionStatus.SUCCESS);
            walletTransactionRepository.save(transaction);

            logger.info("Payment processed successfully for userId={}", userId);
            return true; // Payment successful

        } catch (Exception e) {
            // Nếu có lỗi SAU KHI đã trừ tiền thành công, cần rollback
            logger.error("Payment processing failed for userId={}: {}", userId, e.getMessage());

            // Rollback: hoàn lại tiền vì đã trừ thành công nhưng có lỗi sau đó
            try {
                int rollbackRows = userRepository.incrementBalance(userId, amount);
                if (rollbackRows == 1) {
                    logger.info("Rollback successful: returned {} to user {}", amount, userId);
                } else {
                    logger.warn("Rollback failed: incrementBalance returned {} rows for user {}", rollbackRows, userId);
                }
            } catch (Exception rollbackException) {
                logger.error("Rollback failed for userId={}: {}", userId, rollbackException.getMessage());
            }

            // Cập nhật transaction thành FAILED
            transaction.setPaymentStatus(WalletTransactionStatus.FAILED);
            walletTransactionRepository.save(transaction);
            return false; // Payment failed
        }

    }

    // xử lí trừ tiền khi đăng kí shop

    @Transactional
    public boolean processPurchasePayment(Long userId, java.math.BigDecimal amount, String paymentRef) {
        logger.info("=== Processing Purchase Payment (Shop Registration) ===");
        logger.info("User ID: {}, Amount: {}, PaymentRef: {}", userId, amount, paymentRef);

        // 0) Validate input
        if (amount == null || amount.signum() <= 0) {
            logger.error("❌ Invalid amount: {}", amount);
            throw new IllegalArgumentException("Amount must be > 0");
        }

        if (paymentRef == null || paymentRef.isEmpty()) {
            logger.error("❌ Invalid paymentRef: {}", paymentRef);
            throw new IllegalArgumentException("PaymentRef cannot be null or empty");
        }

        // 1) Check idempotency TRƯỚC (không save transaction)
        Optional<WalletTransaction> existingTx = walletTransactionRepository.findByPaymentRef(paymentRef);
        if (existingTx.isPresent()) {
            WalletTransaction tx = existingTx.get();
            
            if (tx.getPaymentStatus() == WalletTransactionStatus.SUCCESS) {
                logger.warn("⚠️ Payment already processed successfully - paymentRef={}", paymentRef);
                return true;  // Idempotent: return true (đã xử lý thành công trước đó)
            } else if (tx.getPaymentStatus() == WalletTransactionStatus.PENDING) {
                logger.warn("⚠️ Payment still PENDING - paymentRef={}, reject duplicate", paymentRef);
                throw new IllegalStateException("Payment already submitted and pending: " + paymentRef);
            } else {
                logger.warn("⚠️ Payment failed or cancelled before - paymentRef={}, status={}", 
                    paymentRef, tx.getPaymentStatus());
                throw new IllegalStateException("Cannot reprocess payment with ref: " + paymentRef);
            }
        }

        // 2) Load user (throw nếu không có)
        User user = userRepository.findById(userId)
                .orElseThrow(() -> {
                    logger.error("❌ User not found: {}", userId);
                    return new RuntimeException("User not found with id: " + userId);
                });

        // 3) Tạo transaction record ở PENDING state
        WalletTransaction transaction = walletTransactionRepository.save(
            WalletTransaction.builder()
                .user(user)
                .type(WalletTransactionType.PAYMENT)
                .amount(amount)
                .paymentRef(paymentRef)
                .paymentStatus(WalletTransactionStatus.PENDING)  // ← State = PENDING
                .paymentMethod("INTERNAL")
                .note("Thanh toán phí ký quỹ tạo cửa hàng mới")
                .build()
        );
        logger.info("Created transaction record: txId={}, status=PENDING", transaction.getId());

        // 4) Cố gắng trừ tiền (nguyên tử - atomic)
        int rows = userRepository.decrementBalance(userId, amount);

        if (rows != 1) {
            // Thất bại nghiệp vụ: không đủ tiền hoặc user không tồn tại
            logger.error("❌ Insufficient balance - decrementBalance returned {} rows", rows);
            
            // Update transaction to FAILED (được lưu vào DB)
            transaction.setPaymentStatus(WalletTransactionStatus.FAILED);
            walletTransactionRepository.save(transaction);
            logger.info("Updated transaction to FAILED: txId={}", transaction.getId());
            
            return false;  // ← Return false (không throw - không muốn rollback)
        }

        // 5) Thành công: update transaction to SUCCESS
        logger.info("✅ Balance decremented successfully for user {}", userId);
        
        transaction.setPaymentStatus(WalletTransactionStatus.SUCCESS);
        walletTransactionRepository.save(transaction);
        logger.info("✅ Updated transaction to SUCCESS: txId={}", transaction.getId());

        return true;
    }

    /**
     * Lấy trạng thái transaction theo order ID
     */
       @PreAuthorize("hasRole('ADMIN')")
    public WalletTransactionStatus getTransactionStatusByOrderId(String orderId) {
        Optional<WalletTransaction> transactionOpt = walletTransactionRepository.findByPaymentRef(orderId);
        if (transactionOpt.isPresent()) {
            return transactionOpt.get().getPaymentStatus();
        }
        return WalletTransactionStatus.FAILED; // Default to FAILED if not found
    }

}
