package vn.group3.marketplace.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import vn.group3.marketplace.domain.entity.ProductStorage;
import vn.group3.marketplace.domain.enums.ProductStorageStatus;

import java.util.List;

@Repository
public interface ProductStorageRepository extends JpaRepository<ProductStorage, Long> {

    List<ProductStorage> findByProductIdAndStatusAndOrderIsNull(Long productId, ProductStorageStatus status);

    @Query("SELECT COUNT(ps) FROM ProductStorage ps WHERE ps.product.id = :productId AND ps.status = :status AND ps.order IS NULL")
    long countAvailableStockByProductId(@Param("productId") Long productId, @Param("status") ProductStorageStatus status);

    @Modifying
    @Query("UPDATE ProductStorage ps SET ps.status = :status WHERE ps.product.id = :productId AND ps.status = :currentStatus")
    void updateStatus(Long productId, ProductStorageStatus currentStatus, ProductStorageStatus newStatus);
}
