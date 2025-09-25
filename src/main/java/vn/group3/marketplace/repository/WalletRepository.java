package vn.group3.marketplace.repository;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import vn.group3.marketplace.domain.entity.Wallet;
import vn.group3.marketplace.domain.entity.WalletTransaction;
import vn.group3.marketplace.domain.enums.TransactionType;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

/**
 * Repository interface for Wallet entity
 * Provides data access methods for wallet management
 */
@Repository
public interface WalletRepository extends JpaRepository<Wallet, Long> {

    /**
     * Find wallet by user ID
     * @param userId User ID to search for
     * @return Optional containing wallet if found
     */
    Optional<Wallet> findByUserId(Long userId);

    /**
     * Find wallet by username
     * @param username Username to search for
     * @return Optional containing wallet if found
     */
    @Query("SELECT w FROM Wallet w JOIN w.user u WHERE u.username = :username AND w.isDeleted = false")
    Optional<Wallet> findByUsername(@Param("username") String username);

    /**
     * Check if wallet exists for user
     * @param userId User ID to check
     * @return true if wallet exists for user
     */
    boolean existsByUserId(Long userId);

    /**
     * Find wallets with balance greater than or equal to specified amount
     * @param minBalance Minimum balance threshold
     * @param pageable Pagination information
     * @return Page of wallets with sufficient balance
     */
    @Query("SELECT w FROM Wallet w WHERE w.balance >= :minBalance AND w.isDeleted = false")
    Page<Wallet> findByBalanceGreaterThanEqual(@Param("minBalance") BigDecimal minBalance, Pageable pageable);

    /**
     * Find wallets with balance less than specified amount
     * @param maxBalance Maximum balance threshold
     * @param pageable Pagination information
     * @return Page of wallets with low balance
     */
    @Query("SELECT w FROM Wallet w WHERE w.balance < :maxBalance AND w.isDeleted = false")
    Page<Wallet> findByBalanceLessThan(@Param("maxBalance") BigDecimal maxBalance, Pageable pageable);

    /**
     * Find empty wallets (balance = 0)
     * @param pageable Pagination information
     * @return Page of empty wallets
     */
    @Query("SELECT w FROM Wallet w WHERE w.balance = 0 AND w.isDeleted = false")
    Page<Wallet> findEmptyWallets(Pageable pageable);

    /**
     * Find wallets that can cover seller store deposit
     * @param depositAmount Required deposit amount (5M VND)
     * @param pageable Pagination information
     * @return Page of wallets with sufficient funds for store deposit
     */
    @Query("SELECT w FROM Wallet w WHERE w.balance >= :depositAmount AND w.isDeleted = false")
    Page<Wallet> findWalletsForStoreDeposit(@Param("depositAmount") BigDecimal depositAmount, Pageable pageable);

    /**
     * Calculate total balance across all wallets
     * @return Sum of all wallet balances
     */
    @Query("SELECT COALESCE(SUM(w.balance), 0) FROM Wallet w WHERE w.isDeleted = false")
    BigDecimal calculateTotalBalance();

    /**
     * Count wallets with balance above threshold
     * @param threshold Balance threshold
     * @return Number of wallets above threshold
     */
    @Query("SELECT COUNT(w) FROM Wallet w WHERE w.balance > :threshold AND w.isDeleted = false")
    long countWalletsAboveThreshold(@Param("threshold") BigDecimal threshold);

    /**
     * Find wallets by user role
     * @param roleCode Role code to filter by
     * @param pageable Pagination information
     * @return Page of wallets belonging to users with specified role
     */
    @Query("SELECT w FROM Wallet w JOIN w.user u JOIN u.roles r WHERE r.code = :roleCode AND w.isDeleted = false")
    Page<Wallet> findByUserRole(@Param("roleCode") String roleCode, Pageable pageable);

    /**
     * Find all non-deleted wallets
     * @return List of all active wallets
     */
    @Query("SELECT w FROM Wallet w WHERE w.isDeleted = false")
    List<Wallet> findAllActive();

    /**
     * Find wallets with recent transactions
     * @param sinceDate Date to look back from
     * @param pageable Pagination information
     * @return Page of wallets with recent activity
     */
    @Query("SELECT DISTINCT w FROM Wallet w JOIN w.transactions t WHERE t.createdAt >= :sinceDate AND w.isDeleted = false")
    Page<Wallet> findWalletsWithRecentActivity(@Param("sinceDate") LocalDateTime sinceDate, Pageable pageable);

    /**
     * Find transactions by user ID
     * @param userId User ID to search for
     * @param pageable Pagination information
     * @return Page of wallet transactions for the user
     */
    @Query("SELECT t FROM WalletTransaction t JOIN t.wallet w WHERE w.user.id = :userId AND t.isDeleted = false ORDER BY t.createdAt DESC")
    Page<WalletTransaction> findTransactionsByUserId(@Param("userId") Long userId, Pageable pageable);

    /**
     * Find transactions by user ID and type
     * @param userId User ID to search for
     * @param type Transaction type to filter by
     * @param pageable Pagination information
     * @return Page of wallet transactions for the user with specified type
     */
    @Query("SELECT t FROM WalletTransaction t JOIN t.wallet w WHERE w.user.id = :userId AND t.type = :type AND t.isDeleted = false ORDER BY t.createdAt DESC")
    Page<WalletTransaction> findTransactionsByUserIdAndType(@Param("userId") Long userId, @Param("type") TransactionType type, Pageable pageable);

    /**
     * Find wallets by exact balance
     * @param balance Exact balance to search for
     * @param pageable Pagination information
     * @return Page of wallets with exact balance
     */
    @Query("SELECT w FROM Wallet w WHERE w.balance = :balance AND w.isDeleted = false")
    Page<Wallet> findByBalance(@Param("balance") BigDecimal balance, Pageable pageable);

    /**
     * Count wallets by exact balance
     * @param balance Exact balance to count
     * @return Number of wallets with exact balance
     */
    @Query("SELECT COUNT(w) FROM Wallet w WHERE w.balance = :balance AND w.isDeleted = false")
    long countByBalance(@Param("balance") BigDecimal balance);

    /**
     * Count wallets with balance greater than threshold
     * @param threshold Balance threshold
     * @return Number of wallets with balance greater than threshold
     */
    @Query("SELECT COUNT(w) FROM Wallet w WHERE w.balance > :threshold AND w.isDeleted = false")
    long countByBalanceGreaterThan(@Param("threshold") BigDecimal threshold);

    /**
     * Find all active wallets with pagination
     * @param pageable Pagination information
     * @return Page of all active wallets
     */
    @Query("SELECT w FROM Wallet w WHERE w.isDeleted = false")
    Page<Wallet> findAllActive(Pageable pageable);
}
