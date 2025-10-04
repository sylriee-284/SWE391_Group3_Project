package vn.group3.marketplace.service;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import vn.group3.marketplace.domain.entity.User;
// Wallet entity removed - balance stored on User directly
import vn.group3.marketplace.domain.entity.WalletTransaction;
import vn.group3.marketplace.domain.enums.WalletTransactionType;
import vn.group3.marketplace.repository.UserRepository;
import vn.group3.marketplace.repository.WalletTransactionRepository;

import java.util.Optional;

@Service
@Transactional
public class WalletService {

    private static final Logger logger = LoggerFactory.getLogger(WalletService.class);

    // walletRepository removed
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
                .paymentStatus("PENDING")
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
            if (!"PENDING".equals(transaction.getPaymentStatus())) {
                logger.warn("Transaction already processed, status: {}", transaction.getPaymentStatus());
                return;
            }

            // Cập nhật số dư trực tiếp trên user (BigDecimal safe arithmetic)
            User txnUser = transaction.getUser();
            java.math.BigDecimal oldBalance = txnUser.getBalance();
            java.math.BigDecimal newBalance = oldBalance.add(transaction.getAmount());
            txnUser.setBalance(newBalance);
            userRepository.save(txnUser);
            logger.info("Updated user balance from {} to {}", oldBalance, newBalance);

            // Cập nhật trạng thái transaction
            transaction.setPaymentStatus("SUCCESS");
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
}
