package vn.group3.marketplace.service.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.group3.marketplace.domain.entity.Product;
import vn.group3.marketplace.domain.entity.SellerStore;
import vn.group3.marketplace.domain.enums.ProductStatus;
import vn.group3.marketplace.repository.ProductRepository;
import vn.group3.marketplace.repository.SellerStoreRepository;
import vn.group3.marketplace.service.ProductService;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class ProductServiceImpl implements ProductService {

    private final ProductRepository productRepo;
    private final SellerStoreRepository storeRepo;

    @Override
    public Page<Product> search(Long storeId, String q, ProductStatus status, Long categoryId, Pageable pageable) {
        return productRepo.search(storeId, q, status, categoryId, null, null, null, pageable);
    }

    @Override
    public Page<Product> search(Long storeId, String q, ProductStatus status,
            Long categoryId, Long parentCategoryId,
            LocalDateTime createdFrom, LocalDateTime createdTo,
            Pageable pageable) {
        return productRepo.search(storeId, q, status, categoryId, parentCategoryId, createdFrom, createdTo, pageable);
    }

    @Override
    public Product getOwned(Long id, Long storeId) {
        return productRepo.findById(id)
                .filter(p -> !Boolean.TRUE.equals(p.getIsDeleted()))
                .filter(p -> p.getSellerStore() != null && p.getSellerStore().getId().equals(storeId))
                .orElseThrow(() -> new IllegalArgumentException(
                        "Không tìm thấy sản phẩm hoặc không thuộc cửa hàng của bạn."));
    }

    @Transactional
    @Override
    public Product create(Product p) {
        SellerStore store = storeRepo.findById(p.getSellerStore().getId())
                .orElseThrow(() -> new IllegalArgumentException("Store không tồn tại."));
        if (p.getSlug() != null
                && productRepo.existsBySellerStore_IdAndSlugIgnoreCaseAndIsDeletedFalse(store.getId(), p.getSlug())) {
            throw new IllegalArgumentException("Slug đã tồn tại trong cửa hàng.");
        }
        if (p.getStatus() == null)
            p.setStatus(ProductStatus.ACTIVE);
        p.setIsDeleted(false);
        return productRepo.save(p);
    }

    @Transactional
    @Override
    public Product update(Product p, Long storeId) {
        Product db = getOwned(p.getId(), storeId);
        if (p.getSlug() != null &&
                productRepo.existsBySellerStore_IdAndSlugIgnoreCaseAndIdNotAndIsDeletedFalse(storeId, p.getSlug(),
                        p.getId())) {
            throw new IllegalArgumentException("Slug đã tồn tại trong cửa hàng.");
        }
        db.setName(p.getName());
        db.setSlug(p.getSlug());
        db.setProductUrl(p.getProductUrl());
        db.setDescription(p.getDescription());
        db.setPrice(p.getPrice());
        db.setCategory(p.getCategory());
        db.setStatus(p.getStatus());
        db.setStock(p.getStock());
        return productRepo.save(db);
    }

    @Transactional
    @Override
    public void toggle(Long id, Long storeId, ProductStatus toStatus) {
        Product db = getOwned(id, storeId);
        db.setStatus(toStatus);
        productRepo.save(db);
    }

    @Transactional
    @Override
    public void softDelete(Long id, Long storeId, Long userId) {
        Product db = getOwned(id, storeId);
        db.setStatus(ProductStatus.INACTIVE);
        db.setIsDeleted(true);
        db.setDeletedBy(userId);
        productRepo.save(db);
    }

    @Override
    public boolean isSlugTaken(Long storeId, String slug, Long excludeId) {
        return excludeId == null
                ? productRepo.existsBySellerStore_IdAndSlugIgnoreCaseAndIsDeletedFalse(storeId, slug)
                : productRepo.existsBySellerStore_IdAndSlugIgnoreCaseAndIdNotAndIsDeletedFalse(storeId, slug,
                        excludeId);
    }
}
