package vn.group3.marketplace.service.interfaces;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import vn.group3.marketplace.domain.entity.User;
import vn.group3.marketplace.domain.entity.Wallet;
import vn.group3.marketplace.domain.entity.WalletTransaction;
import vn.group3.marketplace.domain.enums.TransactionType;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

/**
 * Service interface for Wallet management
 * Defines business operations for wallet and transaction functionality
 */
public interface WalletService {

    /**
     * Create wallet for user
     * @param user User to create wallet for
     * @return Created wallet
     */
    Wallet createWallet(User user);

    /**
     * Find wallet by user ID
     * @param userId User ID
     * @return Optional containing wallet if found
     */
    Optional<Wallet> findByUserId(Long userId);

    /**
     * Find wallet by username
     * @param username Username
     * @return Optional containing wallet if found
     */
    Optional<Wallet> findByUsername(String username);

    /**
     * Get wallet balance
     * @param userId User ID
     * @return Current wallet balance
     */
    BigDecimal getBalance(Long userId);

    /**
     * Add funds to wallet
     * @param userId User ID
     * @param amount Amount to add
     * @param description Transaction description
     * @param referenceId Optional reference ID
     * @param referenceType Optional reference type
     * @return Updated wallet
     */
    Wallet addFunds(Long userId, BigDecimal amount, String description, 
                   Long referenceId, String referenceType);

    /**
     * Deduct funds from wallet
     * @param userId User ID
     * @param amount Amount to deduct
     * @param description Transaction description
     * @param referenceId Optional reference ID
     * @param referenceType Optional reference type
     * @return Updated wallet
     */
    Wallet deductFunds(Long userId, BigDecimal amount, String description,
                      Long referenceId, String referenceType);

    /**
     * Transfer funds between wallets
     * @param fromUserId Source user ID
     * @param toUserId Target user ID
     * @param amount Amount to transfer
     * @param description Transaction description
     * @param referenceId Optional reference ID
     * @param referenceType Optional reference type
     * @return true if transfer successful
     */
    boolean transferFunds(Long fromUserId, Long toUserId, BigDecimal amount,
                         String description, Long referenceId, String referenceType);

    /**
     * Check if wallet has sufficient funds
     * @param userId User ID
     * @param amount Amount to check
     * @return true if sufficient funds available
     */
    boolean hasSufficientFunds(Long userId, BigDecimal amount);

    /**
     * Process seller store deposit
     * @param userId User ID
     * @param depositAmount Deposit amount (5M VND)
     * @param storeId Store ID for reference
     * @return Updated wallet
     */
    Wallet processStoreDeposit(Long userId, BigDecimal depositAmount, Long storeId);

    /**
     * Refund seller store deposit
     * @param userId User ID
     * @param depositAmount Deposit amount to refund
     * @param storeId Store ID for reference
     * @return Updated wallet
     */
    Wallet refundStoreDeposit(Long userId, BigDecimal depositAmount, Long storeId);

    /**
     * Process escrow hold
     * @param buyerUserId Buyer user ID
     * @param amount Amount to hold in escrow
     * @param orderId Order ID for reference
     * @return Updated wallet
     */
    Wallet processEscrowHold(Long buyerUserId, BigDecimal amount, Long orderId);

    /**
     * Release escrow funds to seller
     * @param buyerUserId Buyer user ID (source of escrow)
     * @param sellerUserId Seller user ID (recipient)
     * @param amount Amount to release
     * @param orderId Order ID for reference
     * @return true if release successful
     */
    boolean releaseEscrowFunds(Long buyerUserId, Long sellerUserId, BigDecimal amount, Long orderId);

    /**
     * Refund escrow funds to buyer
     * @param buyerUserId Buyer user ID
     * @param amount Amount to refund
     * @param orderId Order ID for reference
     * @return Updated wallet
     */
    Wallet refundEscrowFunds(Long buyerUserId, BigDecimal amount, Long orderId);

    /**
     * Get wallet transaction history
     * @param userId User ID
     * @param pageable Pagination information
     * @return Page of wallet transactions
     */
    Page<WalletTransaction> getTransactionHistory(Long userId, Pageable pageable);

    /**
     * Get wallet transactions by type
     * @param userId User ID
     * @param type Transaction type
     * @param pageable Pagination information
     * @return Page of transactions with specified type
     */
    Page<WalletTransaction> getTransactionsByType(Long userId, TransactionType type, Pageable pageable);

    /**
     * Get all wallets with pagination
     * @param pageable Pagination information
     * @return Page of wallets
     */
    Page<Wallet> getAllWallets(Pageable pageable);

    /**
     * Get wallets with minimum balance
     * @param minBalance Minimum balance threshold
     * @param pageable Pagination information
     * @return Page of wallets with sufficient balance
     */
    Page<Wallet> getWalletsWithMinBalance(BigDecimal minBalance, Pageable pageable);

    /**
     * Get empty wallets
     * @param pageable Pagination information
     * @return Page of empty wallets
     */
    Page<Wallet> getEmptyWallets(Pageable pageable);

    /**
     * Calculate total platform balance
     * @return Sum of all wallet balances
     */
    BigDecimal getTotalPlatformBalance();

    /**
     * Get wallet statistics
     * @return Map containing wallet statistics
     */
    java.util.Map<String, Object> getWalletStatistics();

    /**
     * Validate transaction amount
     * @param amount Amount to validate
     * @return true if amount is valid
     */
    boolean isValidTransactionAmount(BigDecimal amount);

    /**
     * Get minimum store deposit amount
     * @return Minimum deposit amount (5M VND)
     */
    BigDecimal getMinimumStoreDeposit();
}
