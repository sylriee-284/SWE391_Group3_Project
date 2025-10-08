package vn.group3.marketplace.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import vn.group3.marketplace.domain.entity.ProductStorage;
import vn.group3.marketplace.domain.enums.ProductStorageStatus;

@Repository
public interface ProductStorageRepository extends JpaRepository<ProductStorage, Long> {
    List<ProductStorage> findByProductIdAndStatus(Long productId, ProductStorageStatus status);

    List<ProductStorage> findByProductIdAndStatusOrderByCreatedAtAsc(Long productId, ProductStorageStatus status);
}
