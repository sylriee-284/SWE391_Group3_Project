package vn.group3.marketplace.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import vn.group3.marketplace.domain.entity.ProductStorage;
import vn.group3.marketplace.domain.entity.Product;
import vn.group3.marketplace.domain.enums.ProductStorageStatus;

import java.util.List;

@Repository
public interface ProductStorageRepository extends JpaRepository<ProductStorage, Long> {

    List<ProductStorage> findByProductAndStatusAndOrderIsNull(Product product, ProductStorageStatus status);
}
