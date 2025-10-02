package vn.group3.marketplace.repository;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import vn.group3.marketplace.domain.entity.Product;
import vn.group3.marketplace.domain.enums.ProductCategory;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

/**
 * Repository for Product entity
 */
@Repository
public interface ProductRepository extends JpaRepository<Product, Long> {

    /**
     * Find product by ID (not deleted)
     */
    Optional<Product> findByIdAndIsDeletedFalse(Long id);

    /**
     * Find all products by store ID
     */
    Page<Product> findByStoreIdAndIsDeletedFalse(Long storeId, Pageable pageable);

    /**
     * Find all products by seller ID
     */
    Page<Product> findBySellerIdAndIsDeletedFalse(Long sellerId, Pageable pageable);

    /**
     * Find active products by store ID
     */
    Page<Product> findByStoreIdAndIsActiveTrueAndIsDeletedFalse(Long storeId, Pageable pageable);

    /**
     * Find products by category
     */
    Page<Product> findByCategoryAndIsActiveTrueAndIsDeletedFalse(
        ProductCategory category,
        Pageable pageable
    );

    /**
     * Find all active products (public listing)
     */
    Page<Product> findByIsActiveTrueAndIsDeletedFalse(Pageable pageable);

    /**
     * Search products by name
     */
    @Query("SELECT p FROM Product p WHERE " +
           "LOWER(p.productName) LIKE LOWER(CONCAT('%', :keyword, '%')) " +
           "AND p.isActive = true AND p.isDeleted = false")
    Page<Product> searchByProductName(@Param("keyword") String keyword, Pageable pageable);

    /**
     * Search products by name or description
     */
    @Query("SELECT p FROM Product p WHERE " +
           "(LOWER(p.productName) LIKE LOWER(CONCAT('%', :keyword, '%')) " +
           "OR LOWER(p.description) LIKE LOWER(CONCAT('%', :keyword, '%'))) " +
           "AND p.isActive = true AND p.isDeleted = false")
    Page<Product> searchProducts(@Param("keyword") String keyword, Pageable pageable);

    /**
     * Search products with category filter
     */
    @Query("SELECT p FROM Product p WHERE " +
           "(LOWER(p.productName) LIKE LOWER(CONCAT('%', :keyword, '%')) " +
           "OR LOWER(p.description) LIKE LOWER(CONCAT('%', :keyword, '%'))) " +
           "AND p.category = :category " +
           "AND p.isActive = true AND p.isDeleted = false")
    Page<Product> searchProductsByCategory(
        @Param("keyword") String keyword,
        @Param("category") ProductCategory category,
        Pageable pageable
    );

    /**
     * Check if SKU exists (excluding specific product ID)
     */
    boolean existsBySkuAndIdNot(String sku, Long id);

    /**
     * Check if SKU exists
     */
    boolean existsBySku(String sku);

    /**
     * Count products by store ID
     */
    long countByStoreIdAndIsDeletedFalse(Long storeId);

    /**
     * Count active products by store ID
     */
    long countByStoreIdAndIsActiveTrueAndIsDeletedFalse(Long storeId);

    /**
     * Count products by seller ID
     */
    long countBySellerIdAndIsDeletedFalse(Long sellerId);

    /**
     * Find low stock products for a seller
     */
    @Query("SELECT p FROM Product p WHERE " +
           "p.seller.id = :sellerId " +
           "AND p.stockQuantity <= :threshold " +
           "AND p.isDeleted = false " +
           "ORDER BY p.stockQuantity ASC")
    List<Product> findLowStockProducts(
        @Param("sellerId") Long sellerId,
        @Param("threshold") Integer threshold
    );

    /**
     * Find out of stock products for a seller
     */
    @Query("SELECT p FROM Product p WHERE " +
           "p.seller.id = :sellerId " +
           "AND p.stockQuantity = 0 " +
           "AND p.isDeleted = false")
    List<Product> findOutOfStockProducts(@Param("sellerId") Long sellerId);

    /**
     * Find products by store and category
     */
    Page<Product> findByStoreIdAndCategoryAndIsDeletedFalse(
        Long storeId,
        ProductCategory category,
        Pageable pageable
    );

    /**
     * Find products with combined filters
     * All parameters are optional (nullable)
     *
     * @param search Search keyword for name/description (nullable)
     * @param category Product category filter (nullable)
     * @param minPrice Minimum price filter (nullable)
     * @param maxPrice Maximum price filter (nullable)
     * @param storeId Store ID filter (nullable)
     * @param stockStatus Stock status filter: ALL, IN_STOCK, LOW_STOCK, OUT_OF_STOCK (nullable)
     * @param pageable Pagination and sorting parameters
     * @return Page of products matching all filters
     */
    @Query("SELECT p FROM Product p " +
           "LEFT JOIN FETCH p.store " +
           "LEFT JOIN FETCH p.seller " +
           "WHERE p.isActive = true AND p.isDeleted = false " +
           "AND (:search IS NULL OR :search = '' OR " +
           "     LOWER(p.productName) LIKE LOWER(CONCAT('%', :search, '%')) OR " +
           "     LOWER(p.description) LIKE LOWER(CONCAT('%', :search, '%'))) " +
           "AND (:category IS NULL OR p.category = :category) " +
           "AND (:minPrice IS NULL OR p.price >= :minPrice) " +
           "AND (:maxPrice IS NULL OR p.price <= :maxPrice) " +
           "AND (:storeId IS NULL OR p.store.id = :storeId) " +
           "AND (:stockStatus IS NULL OR :stockStatus = 'ALL' OR " +
           "     (:stockStatus = 'IN_STOCK' AND p.stockQuantity > 0) OR " +
           "     (:stockStatus = 'LOW_STOCK' AND p.stockQuantity > 0 AND p.stockQuantity <= 10) OR " +
           "     (:stockStatus = 'OUT_OF_STOCK' AND p.stockQuantity = 0))")
    Page<Product> findProductsWithFilters(
        @Param("search") String search,
        @Param("category") ProductCategory category,
        @Param("minPrice") BigDecimal minPrice,
        @Param("maxPrice") BigDecimal maxPrice,
        @Param("storeId") Long storeId,
        @Param("stockStatus") String stockStatus,
        Pageable pageable
    );
}
