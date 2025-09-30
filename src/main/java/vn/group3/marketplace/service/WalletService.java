package vn.group3.marketplace.service;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import vn.group3.marketplace.domain.entity.User;
import vn.group3.marketplace.domain.entity.Wallet;
import vn.group3.marketplace.domain.entity.WalletTransaction;
import vn.group3.marketplace.domain.enums.WalletTransactionType;
import vn.group3.marketplace.repository.UserRepository;
import vn.group3.marketplace.repository.WalletRepository;
import vn.group3.marketplace.repository.WalletTransactionRepository;

import java.util.Optional;

@Service
@Transactional
public class WalletService {

    private final WalletRepository walletRepository;
    private final WalletTransactionRepository walletTransactionRepository;
    private final UserRepository userRepository;

    public WalletService(WalletRepository walletRepository,
            WalletTransactionRepository walletTransactionRepository,
            UserRepository userRepository) {
        this.walletRepository = walletRepository;
        this.walletTransactionRepository = walletTransactionRepository;
        this.userRepository = userRepository;
    }

    /**
     * Tạo pending deposit transaction cho user (chờ thanh toán VNPay)
     */
    public WalletTransaction createPendingDeposit(User user, Double amount, String paymentRef) {
        // Lấy managed User từ DB và tạo/lấy wallet
        Wallet wallet = getOrCreateWallet(user.getId());

        WalletTransaction transaction = WalletTransaction.builder()
                .wallet(wallet)
                .user(wallet.getUser()) // Dùng managed user từ wallet
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
        System.out.println("=== Processing Successful Deposit ===");
        System.out.println("Payment Ref: " + paymentRef);

        Optional<WalletTransaction> transactionOpt = walletTransactionRepository.findByPaymentRef(paymentRef);
        if (transactionOpt.isPresent()) {
            WalletTransaction transaction = transactionOpt.get();

            System.out.println("Found transaction: " + transaction.getId());
            System.out.println("Transaction amount: " + transaction.getAmount());
            System.out.println("Current status: " + transaction.getPaymentStatus());

            // Kiểm tra transaction chưa được xử lý
            if (!"PENDING".equals(transaction.getPaymentStatus())) {
                System.out.println("Transaction already processed, status: " + transaction.getPaymentStatus());
                return;
            }

            // Cập nhật số dư ví
            Wallet wallet = transaction.getWallet();
            Double oldBalance = wallet.getBalance();
            Double newBalance = oldBalance + transaction.getAmount();
            wallet.setBalance(newBalance);
            walletRepository.save(wallet);
            System.out.println("Updated wallet balance from " + oldBalance + " to " + newBalance);

            // Cập nhật trạng thái transaction
            transaction.setPaymentStatus("SUCCESS");
            walletTransactionRepository.save(transaction);
            System.out.println("Updated transaction status to SUCCESS");
        } else {
            System.err.println("Transaction not found with payment ref: " + paymentRef);
        }
        System.out.println("=== Deposit Processing Complete ===");
    }

    /**
     * Lấy hoặc tạo mới ví cho user (bằng userId)
     */
    @Transactional
    public Wallet getOrCreateWallet(Long userId) {
        System.out.println("=== WalletService Debug ===");
        System.out.println("Getting wallet for userId: " + userId);

        // Lấy managed User từ DB với eager loading
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found with id: " + userId));

        System.out.println("Retrieved managed user: " + user.getUsername());

        return walletRepository.findByUser(user)
                .orElseGet(() -> {
                    System.out.println("Creating new wallet for user: " + user.getUsername());
                    Wallet newWallet = Wallet.builder()
                            .user(user) // Quan trọng: set managed user
                            .balance(0.0)
                            .build();
                    System.out.println("New wallet created successfully");
                    return walletRepository.save(newWallet);
                });
    }

    /**
     * Tìm ví theo user ID
     */
    public Optional<Wallet> findByUserId(Long userId) {
        return Optional.of(getOrCreateWallet(userId));
    }
}
