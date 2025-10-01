package vn.group3.marketplace.repository;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import vn.group3.marketplace.domain.entity.SellerStore;

import java.math.BigDecimal;
import java.util.Optional;

/**
 * Repository interface for SellerStore entity
 * Provides data access methods for seller store management
 */
@Repository
public interface SellerStoreRepository extends JpaRepository<SellerStore, Long> {

    /**
     * Find seller store by owner user ID (active stores only)
     * @param userId Owner user ID
     * @return Optional SellerStore
     */
    @Query("SELECT s FROM SellerStore s WHERE s.ownerUser.id = :userId AND s.isDeleted = false")
    Optional<SellerStore> findByOwnerUserIdAndIsDeletedFalse(@Param("userId") Long userId);

    /**
     * Find seller store by owner user ID with owner details loaded
     * @param userId Owner user ID
     * @return Optional SellerStore with owner loaded
     */
    @Query("SELECT s FROM SellerStore s LEFT JOIN FETCH s.ownerUser WHERE s.ownerUser.id = :userId AND s.isDeleted = false")
    Optional<SellerStore> findByOwnerUserIdWithOwner(@Param("userId") Long userId);

    /**
     * Find all active seller stores with owner details
     * @param pageable Pagination information
     * @return Page of active seller stores with owner loaded
     */
    @Query("SELECT s FROM SellerStore s LEFT JOIN FETCH s.ownerUser WHERE s.isActive = true AND s.isDeleted = false")
    Page<SellerStore> findAllActive(Pageable pageable);

    /**
     * Find seller stores by status with owner details
     * @param status Store status
     * @param pageable Pagination information
     * @return Page of seller stores with specified status and owner loaded
     */
    @Query("SELECT s FROM SellerStore s LEFT JOIN FETCH s.ownerUser WHERE s.status = :status AND s.isDeleted = false")
    Page<SellerStore> findByStatus(@Param("status") String status, Pageable pageable);

    /**
     * Find verified seller stores with owner details
     * @param pageable Pagination information
     * @return Page of verified seller stores with owner loaded
     */
    @Query("SELECT s FROM SellerStore s LEFT JOIN FETCH s.ownerUser WHERE s.isVerified = true AND s.isActive = true AND s.isDeleted = false")
    Page<SellerStore> findVerifiedStores(Pageable pageable);

    /**
     * Find seller stores with minimum deposit amount
     * @param minDeposit Minimum deposit amount
     * @param pageable Pagination information
     * @return Page of seller stores with sufficient deposit
     */
    @Query("SELECT s FROM SellerStore s WHERE s.depositAmount >= :minDeposit AND s.isDeleted = false")
    Page<SellerStore> findByMinimumDeposit(@Param("minDeposit") BigDecimal minDeposit, Pageable pageable);

    /**
     * Search seller stores by name or description with owner details
     * @param searchTerm Search term
     * @param pageable Pagination information
     * @return Page of matching seller stores with owner loaded
     */
    @Query("SELECT s FROM SellerStore s LEFT JOIN FETCH s.ownerUser WHERE " +
           "(LOWER(s.storeName) LIKE LOWER(CONCAT('%', :searchTerm, '%')) OR " +
           "LOWER(s.storeDescription) LIKE LOWER(CONCAT('%', :searchTerm, '%'))) AND " +
           "s.isDeleted = false")
    Page<SellerStore> searchStores(@Param("searchTerm") String searchTerm, Pageable pageable);

    /**
     * Find stores that can list products with specified price
     * @param productPrice Product price to check
     * @param pageable Pagination information
     * @return Page of stores that can list the product with owner loaded
     */
    @Query("SELECT s FROM SellerStore s LEFT JOIN FETCH s.ownerUser WHERE " +
           "s.isActive = true AND s.isDeleted = false AND " +
           "s.maxListingPrice >= :productPrice")
    Page<SellerStore> findStoresCanListProduct(@Param("productPrice") BigDecimal productPrice, Pageable pageable);

    /**
     * Count stores by status
     * @param status Store status
     * @return Number of stores with specified status
     */
    @Query("SELECT COUNT(s) FROM SellerStore s WHERE s.status = :status AND s.isDeleted = false")
    Long countByStatus(@Param("status") String status);

    /**
     * Count verified stores
     * @return Number of verified stores
     */
    @Query("SELECT COUNT(s) FROM SellerStore s WHERE s.isVerified = true AND s.isDeleted = false")
    Long countVerifiedStores();

    /**
     * Calculate total deposit amount across all stores
     * @return Sum of all deposit amounts
     */
    @Query("SELECT COALESCE(SUM(s.depositAmount), 0) FROM SellerStore s WHERE s.isDeleted = false")
    BigDecimal calculateTotalDeposits();

    /**
     * Find stores with pending verification with owner details
     * @param pageable Pagination information
     * @return Page of stores pending verification with owner loaded
     */
    @Query("SELECT s FROM SellerStore s LEFT JOIN FETCH s.ownerUser WHERE s.isVerified = false AND s.isActive = true AND s.isDeleted = false")
    Page<SellerStore> findPendingVerification(Pageable pageable);

    /**
     * Find stores by business license (case-insensitive)
     * @param businessLicense Business license number
     * @return Optional SellerStore with matching business license
     */
    @Query("SELECT s FROM SellerStore s WHERE UPPER(s.businessLicense) = UPPER(:businessLicense) AND s.isDeleted = false")
    Optional<SellerStore> findByBusinessLicense(@Param("businessLicense") String businessLicense);

    /**
     * Check if store name exists (for uniqueness validation)
     * @param storeName Store name to check
     * @param excludeId Store ID to exclude from check (for updates)
     * @return true if store name exists
     */
    @Query("SELECT COUNT(s) > 0 FROM SellerStore s WHERE " +
           "LOWER(s.storeName) = LOWER(:storeName) AND " +
           "(:excludeId IS NULL OR s.id != :excludeId) AND " +
           "s.isDeleted = false")
    boolean existsByStoreNameIgnoreCase(@Param("storeName") String storeName, @Param("excludeId") Long excludeId);

    /**
     * Find top performing stores by deposit amount (placeholder for order count when Order entity is implemented)
     * @param pageable Pagination information (use PageRequest.of(0, limit) for limiting)
     * @return Page of top performing stores
     */
    @Query("SELECT s FROM SellerStore s LEFT JOIN FETCH s.ownerUser " +
           "WHERE s.isDeleted = false AND s.isActive = true " +
           "ORDER BY s.depositAmount DESC, s.createdAt DESC")
    Page<SellerStore> findTopPerformingStores(Pageable pageable);

    /**
     * Find stores with low deposit (below average)
     * @param pageable Pagination information
     * @return Page of stores with below-average deposits
     */
    @Query("SELECT s FROM SellerStore s WHERE " +
           "s.depositAmount < (SELECT AVG(s2.depositAmount) FROM SellerStore s2 WHERE s2.isDeleted = false) AND " +
           "s.isDeleted = false")
    Page<SellerStore> findLowDepositStores(Pageable pageable);

    /**
     * Find operational stores (active, verified, not deleted) with owner details
     * @param pageable Pagination information
     * @return Page of operational stores with owner loaded
     */
    @Query("SELECT s FROM SellerStore s LEFT JOIN FETCH s.ownerUser WHERE s.isActive = true AND s.isVerified = true AND s.isDeleted = false")
    Page<SellerStore> findOperationalStores(Pageable pageable);

    /**
     * Check if business license exists (case-insensitive, excluding specific store)
     * @param businessLicense Business license to check
     * @param excludeId Store ID to exclude from check
     * @return true if business license exists
     */
    @Query("SELECT COUNT(s) > 0 FROM SellerStore s WHERE " +
           "UPPER(s.businessLicense) = UPPER(:businessLicense) AND " +
           "(:excludeId IS NULL OR s.id != :excludeId) AND " +
           "s.isDeleted = false")
    boolean existsByBusinessLicenseIgnoreCase(@Param("businessLicense") String businessLicense, @Param("excludeId") Long excludeId);

    /**
     * Find stores by deposit amount range
     * @param minDeposit Minimum deposit amount
     * @param maxDeposit Maximum deposit amount
     * @param pageable Pagination information
     * @return Page of stores within deposit range
     */
    @Query("SELECT s FROM SellerStore s LEFT JOIN FETCH s.ownerUser WHERE " +
           "s.depositAmount BETWEEN :minDeposit AND :maxDeposit AND " +
           "s.isDeleted = false")
    Page<SellerStore> findByDepositRange(@Param("minDeposit") BigDecimal minDeposit,
                                        @Param("maxDeposit") BigDecimal maxDeposit,
                                        Pageable pageable);

    /**
     * Get average deposit amount
     * @return Average deposit amount across all active stores
     */
    @Query("SELECT AVG(s.depositAmount) FROM SellerStore s WHERE s.isDeleted = false AND s.isActive = true")
    BigDecimal getAverageDepositAmount();

    /**
     * Count stores by verification status
     * @param isVerified Verification status
     * @return Number of stores with specified verification status
     */
    @Query("SELECT COUNT(s) FROM SellerStore s WHERE s.isVerified = :isVerified AND s.isDeleted = false")
    Long countByVerificationStatus(@Param("isVerified") boolean isVerified);
}
