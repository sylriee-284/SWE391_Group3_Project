package vn.group3.marketplace.repository;

import java.util.Optional;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import vn.group3.marketplace.domain.entity.Product;
import vn.group3.marketplace.domain.enums.ProductStatus;

import java.time.LocalDateTime;

@Repository
public interface ProductRepository extends JpaRepository<Product, Long> {

    // Search with flexible filters (store, keyword, status, category, parent, date
    // range)
    @Query("""
                            SELECT p FROM Product p
                            WHERE p.sellerStore.id = :storeId
                                    AND p.isDeleted = false
                                    AND (:q IS NULL OR :q = ''
                                                     OR LOWER(p.name) LIKE LOWER(CONCAT('%', :q, '%'))
                                                     OR LOWER(p.slug) LIKE LOWER(CONCAT('%', :q, '%')))
                                    AND (:status IS NULL OR p.status = :status)
                                    AND (:categoryId IS NULL OR p.category.id = :categoryId)
                                    AND (:parentCategoryId IS NULL OR (p.category.parent IS NOT NULL AND p.category.parent.id = :parentCategoryId))
                                    AND (:createdFrom IS NULL OR p.createdAt >= :createdFrom)
                                    AND (:createdTo   IS NULL OR p.createdAt <  :createdTo)
                                    AND (:minPrice IS NULL OR p.price >= :minPrice)
                                    AND (:maxPrice IS NULL OR p.price <= :maxPrice)
                                    AND (:idFrom IS NULL OR p.id >= :idFrom)
                                    AND (:idTo IS NULL OR p.id <= :idTo)
            """)
    Page<Product> search(
            @Param("storeId") Long storeId,
            @Param("q") String q,
            @Param("status") ProductStatus status,
            @Param("categoryId") Long categoryId,
            @Param("parentCategoryId") Long parentCategoryId,
            @Param("createdFrom") LocalDateTime createdFrom,
            @Param("createdTo") LocalDateTime createdTo,
            @Param("minPrice") java.math.BigDecimal minPrice,
            @Param("maxPrice") java.math.BigDecimal maxPrice,
            @Param("idFrom") Long idFrom,
            @Param("idTo") Long idTo,
            Pageable pageable);

    boolean existsBySellerStore_IdAndSlugIgnoreCaseAndIsDeletedFalse(Long storeId, String slug);

    boolean existsBySellerStore_IdAndSlugIgnoreCaseAndIdNotAndIsDeletedFalse(Long storeId, String slug,
            Long excludeId);

    // Find products by parent category (including all child categories)
    @Query("SELECT p FROM Product p WHERE p.category.parent.id = :parentCategoryId AND p.status = :status AND p.isDeleted = false")
    Page<Product> findByParentCategoryId(@Param("parentCategoryId") Long parentCategoryId,
            @Param("status") ProductStatus status,
            Pageable pageable);

    // Find products by parent category with search keyword
    @Query("SELECT p FROM Product p WHERE p.category.parent.id = :parentCategoryId AND p.status = :status AND p.isDeleted = false "
            + "AND (LOWER(p.name) LIKE LOWER(CONCAT('%', :keyword, '%')) OR LOWER(p.description) LIKE LOWER(CONCAT('%', :keyword, '%')))")
    Page<Product> findByParentCategoryIdAndKeyword(@Param("parentCategoryId") Long parentCategoryId,
            @Param("status") ProductStatus status,
            @Param("keyword") String keyword,
            Pageable pageable);

    // Find products by specific child category
    @Query("SELECT p FROM Product p WHERE p.category.id = :categoryId AND p.status = :status AND p.isDeleted = false")
    Page<Product> findByCategoryId(@Param("categoryId") Long categoryId,
            @Param("status") ProductStatus status,
            Pageable pageable);

    // Find products by child category with search keyword
    @Query("SELECT p FROM Product p WHERE p.category.id = :categoryId AND p.status = :status AND p.isDeleted = false "
            + "AND (LOWER(p.name) LIKE LOWER(CONCAT('%', :keyword, '%')) OR LOWER(p.description) LIKE LOWER(CONCAT('%', :keyword, '%'))) ")
    Page<Product> findByCategoryIdAndKeyword(@Param("categoryId") Long categoryId,
            @Param("status") ProductStatus status,
            @Param("keyword") String keyword,
            Pageable pageable);

    // Count products by parent category
    @Query("SELECT COUNT(p) FROM Product p WHERE p.category.parent.id = :parentCategoryId AND p.status = :status AND p.isDeleted = false")
    Long countByParentCategoryId(@Param("parentCategoryId") Long parentCategoryId,
            @Param("status") ProductStatus status);

    // Find product by ID with eager loading of category and seller store
    @Query("SELECT p FROM Product p " +
            "LEFT JOIN FETCH p.category c " +
            "LEFT JOIN FETCH c.parent " +
            "LEFT JOIN FETCH p.sellerStore s " +
            "LEFT JOIN FETCH s.owner " +
            "WHERE p.id = :productId AND p.isDeleted = false")
    Optional<Product> findByIdWithDetails(@Param("productId") Long productId);

    @Query("SELECT p FROM Product p " +
            "LEFT JOIN FETCH p.category c " +
            "LEFT JOIN FETCH c.parent " +
            "LEFT JOIN FETCH p.sellerStore s " +
            "LEFT JOIN FETCH s.owner " +
            "WHERE p.slug = :slug AND p.isDeleted = false")
    Optional<Product> findBySlugWithDetails(@Param("slug") String slug);

    // Distinct categories sold by a store
    @Query("SELECT DISTINCT p.category FROM Product p WHERE p.sellerStore.id = :storeId AND p.status = 'ACTIVE' AND p.isDeleted = false")
    java.util.List<vn.group3.marketplace.domain.entity.Category> findDistinctCategoriesByStore(
            @Param("storeId") Long storeId);

    @Query("SELECT COALESCE(MIN(p.price), 0) FROM Product p WHERE p.sellerStore.id = :storeId AND p.status = 'ACTIVE' AND p.isDeleted = false")
    java.math.BigDecimal findMinPriceByStore(@Param("storeId") Long storeId);

    @Query("SELECT COALESCE(MAX(p.price), 0) FROM Product p WHERE p.sellerStore.id = :storeId AND p.status = 'ACTIVE' AND p.isDeleted = false")
    java.math.BigDecimal findMaxPriceByStore(@Param("storeId") Long storeId);

    // Atomic decrement stock with condition
    @Modifying
    @Transactional
    @Query(value = "UPDATE products SET stock = stock - :quantity WHERE id = :productId AND stock >= :quantity AND status = 'ACTIVE'", nativeQuery = true)
    int decrementStock(@Param("productId") Long productId, @Param("quantity") Integer quantity);

    // Atomic increment stock
    @Modifying
    @Transactional
    @Query(value = "UPDATE products SET stock = stock + :quantity WHERE id = :productId", nativeQuery = true)
    int incrementStock(@Param("productId") Long productId, @Param("quantity") Integer quantity);

    // Check available stock (legacy - from products table)
    @Query("SELECT p.stock FROM Product p WHERE p.id = :productId AND p.status = 'ACTIVE'")
    Optional<Integer> getAvailableStock(@Param("productId") Long productId);

    // Get dynamic stock from ProductStorage table
    @Query("SELECT COUNT(ps) FROM ProductStorage ps WHERE ps.product.id = :productId AND ps.status = 'AVAILABLE' AND ps.order IS NULL")
    long getDynamicStock(@Param("productId") Long productId);

    // Dashboard queries
    @Query("SELECT COUNT(p) FROM Product p WHERE p.sellerStore.id = :storeId AND p.stock <= :threshold AND p.stock > 0")
    Long countLowStockByStore(@Param("storeId") Long storeId, @Param("threshold") Integer threshold);

    @Query("SELECT COUNT(p) FROM Product p WHERE p.sellerStore.id = :storeId AND p.stock = 0")
    Long countOutOfStockByStore(@Param("storeId") Long storeId);

    @Query("SELECT p.id, p.name, p.stock FROM Product p WHERE p.sellerStore.id = :storeId " +
            "AND p.stock <= :threshold AND p.stock > 0 ORDER BY p.stock ASC")
    java.util.List<Object[]> findLowStockProducts(@Param("storeId") Long storeId,
            @Param("threshold") Integer threshold);

    @Query("SELECT p.id, p.name FROM Product p WHERE p.sellerStore.id = :storeId AND p.stock = 0")
    java.util.List<Object[]> findOutOfStockProducts(@Param("storeId") Long storeId);

    // Find all active products
    @Query("SELECT p FROM Product p WHERE p.status = :status AND p.isDeleted = false")
    Page<Product> findByStatus(@Param("status") ProductStatus status, Pageable pageable);

    // Find all active products by keyword
    @Query("SELECT p FROM Product p WHERE p.status = :status AND p.isDeleted = false " +
            "AND (LOWER(p.name) LIKE LOWER(CONCAT('%', :keyword, '%')) OR LOWER(p.description) LIKE LOWER(CONCAT('%', :keyword, '%')))")
    Page<Product> findByStatusAndKeyword(@Param("status") ProductStatus status,
            @Param("keyword") String keyword,
            Pageable pageable);

    // Count products by store and status (for performance)
    @Query("SELECT COUNT(p) FROM Product p WHERE p.sellerStore.id = :storeId AND p.status = :status AND p.isDeleted = false")
    Long countBySellerStoreIdAndStatus(@Param("storeId") Long storeId, @Param("status") ProductStatus status);

    // Find hot products from OTHER stores (exclude specific store)
    @Query("""
            SELECT p FROM Product p
            WHERE p.sellerStore.id != :excludeStoreId
                AND p.status = :status
                AND p.isDeleted = false
                AND (:keyword IS NULL OR :keyword = ''
                    OR LOWER(p.name) LIKE LOWER(CONCAT('%', :keyword, '%'))
                    OR LOWER(p.description) LIKE LOWER(CONCAT('%', :keyword, '%')))
                AND (:categoryId IS NULL OR p.category.id = :categoryId)
                AND (:minPrice IS NULL OR p.price >= :minPrice)
                AND (:maxPrice IS NULL OR p.price <= :maxPrice)
            """)
    Page<Product> findHotProductsExcludingStore(
            @Param("excludeStoreId") Long excludeStoreId,
            @Param("status") ProductStatus status,
            @Param("keyword") String keyword,
            @Param("categoryId") Long categoryId,
            @Param("minPrice") java.math.BigDecimal minPrice,
            @Param("maxPrice") java.math.BigDecimal maxPrice,
            Pageable pageable);

    // Admin dashboard queries
    @Query("SELECT COUNT(p) FROM Product p WHERE p.isDeleted = false")
    long countTotalProducts();

    @Query("SELECT COUNT(p) FROM Product p WHERE p.status = :status AND p.isDeleted = false")
    long countProductsByStatus(@Param("status") ProductStatus status);

    /**
     * Top sản phẩm bán chạy (dựa vào Order.quantity)
     */
    @Query("SELECT p.id, p.name, SUM(o.quantity) as totalSold FROM Product p JOIN Order o ON o.product.id = p.id WHERE o.status = 'COMPLETED' GROUP BY p.id, p.name ORDER BY totalSold DESC")
    java.util.List<Object[]> getTopSellingProducts(org.springframework.data.domain.Pageable pageable);

    /**
     * Phân tích giá sản phẩm theo range
     */
    @Query("SELECT CASE WHEN p.price < 100000 THEN 'Dưới 100k' WHEN p.price < 500000 THEN '100k-500k' WHEN p.price < 1000000 THEN '500k-1M' ELSE 'Trên 1M' END as priceRange, COUNT(p) FROM Product p WHERE p.isDeleted = false GROUP BY CASE WHEN p.price < 100000 THEN 'Dưới 100k' WHEN p.price < 500000 THEN '100k-500k' WHEN p.price < 1000000 THEN '500k-1M' ELSE 'Trên 1M' END")
    java.util.List<Object[]> getProductCountByPriceRange();

    /**
     * Sản phẩm theo trạng thái stock
     */
    @Query("SELECT CASE WHEN p.stock = 0 THEN 'Hết hàng' WHEN p.stock <= 10 THEN 'Sắp hết' ELSE 'Đầy đủ' END as stockStatus, COUNT(p) FROM Product p WHERE p.isDeleted = false GROUP BY CASE WHEN p.stock = 0 THEN 'Hết hàng' WHEN p.stock <= 10 THEN 'Sắp hết' ELSE 'Đầy đủ' END")
    java.util.List<Object[]> getProductCountByStockStatus();
}