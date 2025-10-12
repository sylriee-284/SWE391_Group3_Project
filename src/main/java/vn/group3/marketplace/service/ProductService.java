package vn.group3.marketplace.service;

import java.time.LocalDateTime;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import vn.group3.marketplace.domain.entity.Product;
import vn.group3.marketplace.domain.enums.ProductStatus;

public interface ProductService {
    Page<Product> search(Long storeId, String q, ProductStatus status, Long categoryId, Pageable pageable);

    Product getOwned(Long id, Long storeId);

    Product create(Product p);

    Product update(Product p, Long storeId);

    void toggle(Long id, Long storeId, ProductStatus toStatus);

    void softDelete(Long id, Long storeId, Long userId);

    boolean isSlugTaken(Long storeId, String slug, Long excludeId);

    Page<Product> search(Long storeId,
            String q,
            ProductStatus status,
            Long categoryId,
            Long parentCategoryId,
            LocalDateTime createdFrom,
            LocalDateTime createdTo,
            Pageable pageable);

}
