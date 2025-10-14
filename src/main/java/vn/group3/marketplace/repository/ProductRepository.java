package vn.group3.marketplace.repository;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import vn.group3.marketplace.domain.entity.Product;
import vn.group3.marketplace.domain.enums.ProductStatus;

@Repository
public interface ProductRepository extends JpaRepository<Product, Long> {

        // Find products by parent category (including all child categories)
        @Query("SELECT p FROM Product p WHERE p.category.parent.id = :parentCategoryId AND p.status = :status AND p.isDeleted = false")
        Page<Product> findByParentCategoryId(@Param("parentCategoryId") Long parentCategoryId,
                        @Param("status") ProductStatus status,
                        Pageable pageable);

        // Find products by parent category with search keyword
        @Query("SELECT p FROM Product p WHERE p.category.parent.id = :parentCategoryId AND p.status = :status AND p.isDeleted = false "
                        +
                        "AND (LOWER(p.name) LIKE LOWER(CONCAT('%', :keyword, '%')) OR LOWER(p.description) LIKE LOWER(CONCAT('%', :keyword, '%')))")
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
                        +
                        "AND (LOWER(p.name) LIKE LOWER(CONCAT('%', :keyword, '%')) OR LOWER(p.description) LIKE LOWER(CONCAT('%', :keyword, '%')))")
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
        java.util.Optional<Product> findByIdWithDetails(@Param("productId") Long productId);

        @Query("SELECT p FROM Product p " +
                        "LEFT JOIN FETCH p.category c " +
                        "LEFT JOIN FETCH c.parent " +
                        "LEFT JOIN FETCH p.sellerStore s " +
                        "LEFT JOIN FETCH s.owner " +
                        "WHERE p.slug = :slug AND p.isDeleted = false")
        java.util.Optional<Product> findBySlugWithDetails(@Param("slug") String slug);

}
