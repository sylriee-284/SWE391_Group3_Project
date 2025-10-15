package vn.group3.marketplace.service;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import vn.group3.marketplace.domain.entity.User;
// Wallet entity removed - balance stored on User directly
import vn.group3.marketplace.domain.entity.WalletTransaction;
import vn.group3.marketplace.domain.enums.WalletTransactionType;
import vn.group3.marketplace.domain.enums.WalletTransactionStatus;
import vn.group3.marketplace.repository.UserRepository;
import vn.group3.marketplace.repository.WalletTransactionRepository;

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
                logger.warn("incrementBalance affected {} rows for userId={}", rows, userId);
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

    /**
     * Tìm ví theo user ID
     */
    public java.util.Optional<java.math.BigDecimal> findBalanceByUserId(Long userId) {
        return userRepository.findById(userId).map(User::getBalance);
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
}
