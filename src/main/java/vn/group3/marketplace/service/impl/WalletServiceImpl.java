package vn.group3.marketplace.service.impl;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.group3.marketplace.config.MarketplaceProperties;
import vn.group3.marketplace.domain.entity.User;
import vn.group3.marketplace.domain.entity.Wallet;
import vn.group3.marketplace.domain.entity.WalletTransaction;
import vn.group3.marketplace.domain.enums.TransactionType;
import vn.group3.marketplace.repository.WalletRepository;
import vn.group3.marketplace.service.interfaces.WalletService;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

/**
 * Implementation of WalletService interface
 * Handles all wallet-related business logic
 */
@Service
@Transactional
@RequiredArgsConstructor
@Slf4j
public class WalletServiceImpl implements WalletService {

    private final WalletRepository walletRepository;
    private final MarketplaceProperties marketplaceProperties;

    @Override
    public Wallet createWallet(User user) {
        log.info("Creating wallet for user: {}", user.getId());
        
        // Check if user already has a wallet
        Optional<Wallet> existingWallet = walletRepository.findByUserId(user.getId());
        if (existingWallet.isPresent()) {
            log.warn("User {} already has a wallet", user.getId());
            return existingWallet.get();
        }
        
        Wallet wallet = new Wallet();
        wallet.setUser(user);
        wallet.setBalance(BigDecimal.ZERO);
        
        Wallet savedWallet = walletRepository.save(wallet);
        log.info("Wallet created successfully for user: {}", user.getId());
        
        return savedWallet;
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<Wallet> findByUserId(Long userId) {
        return walletRepository.findByUserId(userId);
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<Wallet> findByUsername(String username) {
        return walletRepository.findByUsername(username);
    }

    @Override
    @Transactional(readOnly = true)
    public BigDecimal getBalance(Long userId) {
        return walletRepository.findByUserId(userId)
            .map(Wallet::getBalance)
            .orElse(BigDecimal.ZERO);
    }

    @Override
    public Wallet addFunds(Long userId, BigDecimal amount, String description, 
                          Long referenceId, String referenceType) {
        log.info("Adding funds {} to user {}: {}", amount, userId, description);
        
        if (!isValidTransactionAmount(amount)) {
            throw new IllegalArgumentException("Invalid transaction amount: " + amount);
        }
        
        Wallet wallet = walletRepository.findByUserId(userId)
            .orElseThrow(() -> new IllegalArgumentException("Wallet not found for user: " + userId));
        
        wallet.addFunds(amount, description);

        // Create transaction record
        WalletTransaction transaction = WalletTransaction.createCredit(
            wallet, "deposit", amount, description, referenceId, referenceType
        );
        wallet.getTransactions().add(transaction);
        
        Wallet savedWallet = walletRepository.save(wallet);
        log.info("Funds added successfully. New balance: {}", savedWallet.getBalance());
        
        return savedWallet;
    }

    @Override
    public Wallet deductFunds(Long userId, BigDecimal amount, String description,
                             Long referenceId, String referenceType) {
        log.info("Deducting funds {} from user {}: {}", amount, userId, description);
        
        if (!isValidTransactionAmount(amount)) {
            throw new IllegalArgumentException("Invalid transaction amount: " + amount);
        }
        
        Wallet wallet = walletRepository.findByUserId(userId)
            .orElseThrow(() -> new IllegalArgumentException("Wallet not found for user: " + userId));
        
        if (!wallet.hasSufficientFunds(amount)) {
            throw new IllegalArgumentException("Insufficient funds. Available: " + wallet.getBalance());
        }
        
        wallet.deductFunds(amount, description);

        // Create transaction record
        WalletTransaction transaction = WalletTransaction.createDebit(
            wallet, "withdrawal", amount, description, referenceId, referenceType
        );
        wallet.getTransactions().add(transaction);
        
        Wallet savedWallet = walletRepository.save(wallet);
        log.info("Funds deducted successfully. New balance: {}", savedWallet.getBalance());
        
        return savedWallet;
    }

    @Override
    public boolean transferFunds(Long fromUserId, Long toUserId, BigDecimal amount,
                                String description, Long referenceId, String referenceType) {
        log.info("Transferring funds {} from user {} to user {}", amount, fromUserId, toUserId);
        
        try {
            // Deduct from source wallet
            deductFunds(fromUserId, amount, "Transfer to user " + toUserId + ": " + description,
                       referenceId, referenceType);
            
            // Add to destination wallet
            addFunds(toUserId, amount, "Transfer from user " + fromUserId + ": " + description,
                     referenceId, referenceType);
            
            log.info("Transfer completed successfully");
            return true;
            
        } catch (Exception e) {
            log.error("Transfer failed: {}", e.getMessage());
            return false;
        }
    }

    @Override
    @Transactional(readOnly = true)
    public boolean hasSufficientFunds(Long userId, BigDecimal amount) {
        return walletRepository.findByUserId(userId)
            .map(wallet -> wallet.hasSufficientFunds(amount))
            .orElse(false);
    }

    @Override
    public Wallet processStoreDeposit(Long userId, BigDecimal depositAmount, Long storeId) {
        log.info("Processing store deposit {} for user {} and store {}", depositAmount, userId, storeId);
        
        BigDecimal minDeposit = getMinimumStoreDeposit();
        if (depositAmount.compareTo(minDeposit) < 0) {
            throw new IllegalArgumentException("Deposit amount must be at least " + minDeposit + " VND");
        }
        
        return deductFunds(userId, depositAmount, "Store deposit for store ID: " + storeId,
                          storeId, "STORE_DEPOSIT");
    }

    @Override
    public Wallet refundStoreDeposit(Long userId, BigDecimal depositAmount, Long storeId) {
        log.info("Refunding store deposit {} for user {} and store {}", depositAmount, userId, storeId);
        
        return addFunds(userId, depositAmount, "Store deposit refund for store ID: " + storeId,
                       storeId, "STORE_DEPOSIT_REFUND");
    }

    @Override
    public Wallet processEscrowHold(Long buyerUserId, BigDecimal amount, Long orderId) {
        log.info("Processing escrow hold {} for buyer {} and order {}", amount, buyerUserId, orderId);
        
        return deductFunds(buyerUserId, amount, "Escrow hold for order ID: " + orderId,
                          orderId, "ESCROW_HOLD");
    }

    @Override
    public boolean releaseEscrowFunds(Long buyerUserId, Long sellerUserId, BigDecimal amount, Long orderId) {
        log.info("Releasing escrow funds {} from buyer {} to seller {} for order {}", 
                amount, buyerUserId, sellerUserId, orderId);
        
        try {
            // Add funds to seller wallet
            addFunds(sellerUserId, amount, "Escrow release for order ID: " + orderId,
                    orderId, "ESCROW_RELEASE");
            
            log.info("Escrow funds released successfully");
            return true;
            
        } catch (Exception e) {
            log.error("Escrow release failed: {}", e.getMessage());
            return false;
        }
    }

    @Override
    public Wallet refundEscrowFunds(Long buyerUserId, BigDecimal amount, Long orderId) {
        log.info("Refunding escrow funds {} to buyer {} for order {}", amount, buyerUserId, orderId);
        
        return addFunds(buyerUserId, amount, "Escrow refund for order ID: " + orderId,
                       orderId, "ESCROW_REFUND");
    }

    @Override
    @Transactional(readOnly = true)
    public Page<WalletTransaction> getTransactionHistory(Long userId, Pageable pageable) {
        return walletRepository.findTransactionsByUserId(userId, pageable);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<WalletTransaction> getTransactionsByType(Long userId, TransactionType type, Pageable pageable) {
        return walletRepository.findTransactionsByUserIdAndType(userId, type, pageable);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<Wallet> getAllWallets(Pageable pageable) {
        return walletRepository.findAllActive(pageable);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<Wallet> getWalletsWithMinBalance(BigDecimal minBalance, Pageable pageable) {
        return walletRepository.findByBalanceGreaterThanEqual(minBalance, pageable);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<Wallet> getEmptyWallets(Pageable pageable) {
        return walletRepository.findByBalance(BigDecimal.ZERO, pageable);
    }

    @Override
    @Transactional(readOnly = true)
    public BigDecimal getTotalPlatformBalance() {
        return walletRepository.calculateTotalBalance();
    }

    @Override
    @Transactional(readOnly = true)
    public Map<String, Object> getWalletStatistics() {
        Map<String, Object> stats = new HashMap<>();
        
        stats.put("totalWallets", walletRepository.count());
        stats.put("totalBalance", getTotalPlatformBalance());
        stats.put("emptyWallets", walletRepository.countByBalance(BigDecimal.ZERO));
        stats.put("activeWallets", walletRepository.countByBalanceGreaterThan(BigDecimal.ZERO));
        
        // Average balance
        Long totalWallets = walletRepository.count();
        if (totalWallets > 0) {
            BigDecimal avgBalance = getTotalPlatformBalance().divide(
                BigDecimal.valueOf(totalWallets), 2, RoundingMode.HALF_UP
            );
            stats.put("averageBalance", avgBalance);
        } else {
            stats.put("averageBalance", BigDecimal.ZERO);
        }
        
        return stats;
    }

    @Override
    public boolean isValidTransactionAmount(BigDecimal amount) {
        return amount != null && 
               amount.compareTo(BigDecimal.ZERO) > 0 && 
               amount.scale() <= 2; // Max 2 decimal places
    }

    @Override
    public BigDecimal getMinimumStoreDeposit() {
        return marketplaceProperties.getMinimumSellerDeposit();
    }
}
