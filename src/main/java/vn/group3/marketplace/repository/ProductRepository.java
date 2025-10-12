package vn.group3.marketplace.repository;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.*;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import vn.group3.marketplace.domain.entity.Product;
import vn.group3.marketplace.domain.enums.ProductStatus;

import java.time.LocalDateTime;

@Repository
public interface ProductRepository extends JpaRepository<Product, Long> {

    @Query("""
                SELECT p FROM Product p
                WHERE p.sellerStore.id = :storeId
                  AND p.isDeleted = false
                  AND (:q IS NULL OR :q = ''
                       OR LOWER(p.name) LIKE LOWER(CONCAT('%', :q, '%'))
                       OR LOWER(p.slug) LIKE LOWER(CONCAT('%', :q, '%')))
                  AND (:status IS NULL OR p.status = :status)
                  /* lọc theo danh mục con (categoryId) nếu có */
                  AND (:categoryId IS NULL OR p.category.id = :categoryId)
                  /* lọc theo danh mục lớn (parentCategoryId) nếu có */
                  AND (:parentCategoryId IS NULL OR (p.category.parent IS NOT NULL AND p.category.parent.id = :parentCategoryId))
                  /* lọc theo khoảng ngày tạo */
                  AND (:createdFrom IS NULL OR p.createdAt >= :createdFrom)
                  AND (:createdTo   IS NULL OR p.createdAt <  :createdTo)
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
            Pageable pageable);

    boolean existsBySellerStore_IdAndSlugIgnoreCaseAndIsDeletedFalse(Long storeId, String slug);

    boolean existsBySellerStore_IdAndSlugIgnoreCaseAndIdNotAndIsDeletedFalse(Long storeId, String slug, Long excludeId);
}
