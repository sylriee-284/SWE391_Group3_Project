package vn.group3.marketplace.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import vn.group3.marketplace.domain.entity.ProductStorage;
import vn.group3.marketplace.domain.enums.ProductStorageStatus;

public interface ProductStorageRepository extends JpaRepository<ProductStorage, Long> {
    List<ProductStorage> findByProductIdAndStatus(Long productId, ProductStorageStatus status);

    @Query("""
                SELECT COUNT(ps) FROM ProductStorage ps
                WHERE ps.product.id = :productId
                  AND ps.status = :status
                  AND ps.isDeleted = false
            """)
    long countAvailable(@Param("productId") Long productId,
            @Param("status") ProductStorageStatus status);

    List<ProductStorage> findByProductIdAndStatusOrderByCreatedAtAsc(Long productId, ProductStorageStatus status);
}
