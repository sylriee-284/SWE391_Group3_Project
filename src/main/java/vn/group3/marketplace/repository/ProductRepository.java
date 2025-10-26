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
                                        ORDER BY p.updatedAt DESC
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

        // Find all active products
        @Query("SELECT p FROM Product p WHERE p.status = :status AND p.isDeleted = false")
        Page<Product> findByStatus(@Param("status") ProductStatus status, Pageable pageable);

        // Find all active products by keyword
        @Query("SELECT p FROM Product p WHERE p.status = :status AND p.isDeleted = false " +
                        "AND (LOWER(p.name) LIKE LOWER(CONCAT('%', :keyword, '%')) OR LOWER(p.description) LIKE LOWER(CONCAT('%', :keyword, '%')))")
        Page<Product> findByStatusAndKeyword(@Param("status") ProductStatus status,
                        @Param("keyword") String keyword,
                        Pageable pageable);

        // Additional methods for category-based search
        @Query("SELECT p FROM Product p WHERE p.category = :category AND p.status = :status AND p.isDeleted = false")
        Page<Product> findByCategoryAndStatus(vn.group3.marketplace.domain.entity.Category category,
                        @Param("status") ProductStatus status,
                        Pageable pageable);

        @Query("SELECT p FROM Product p WHERE p.status = :status AND p.isDeleted = false " +
                        "AND (LOWER(p.name) LIKE LOWER(CONCAT('%', :keyword, '%')) OR LOWER(p.description) LIKE LOWER(CONCAT('%', :keyword, '%'))) "
                        +
                        "AND p.category = :category")
        Page<Product> findByStatusAndKeywordAndCategory(@Param("status") ProductStatus status,
                        @Param("keyword") String keyword,
                        vn.group3.marketplace.domain.entity.Category category,
                        Pageable pageable);

}
