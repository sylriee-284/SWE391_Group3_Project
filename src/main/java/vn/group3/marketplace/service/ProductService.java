package vn.group3.marketplace.service;

import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.group3.marketplace.domain.entity.Category;
import vn.group3.marketplace.domain.entity.Product;
import vn.group3.marketplace.domain.entity.SellerStore;
import vn.group3.marketplace.domain.enums.ProductStatus;
import vn.group3.marketplace.repository.ProductRepository;
import vn.group3.marketplace.repository.SellerStoreRepository;

import java.time.LocalDateTime;

/**
 * Unified ProductService class. This replaces the previous interface +
 * implementation by providing a single concrete Spring @Service containing all
 * product-related operations used across the application.
 */
@Service
@RequiredArgsConstructor
public class ProductService {

    private final ProductRepository productRepository;
    private final SellerStoreRepository storeRepository;

    /* --- Search / listing helpers (category-based) --- */
    public Page<Product> getProductsByParentCategory(Category parentCategory, int page, int size,
            String sortBy, String sortDirection) {
        Sort sort = Sort.by(Sort.Direction.fromString(sortDirection), sortBy);
        Pageable pageable = PageRequest.of(page, size, sort);

        return productRepository.findByParentCategoryId(parentCategory.getId(), ProductStatus.ACTIVE, pageable);
    }

    public Page<Product> searchProductsByParentCategory(Category parentCategory, String keyword,
            int page, int size, String sortBy, String sortDirection) {
        Sort sort = Sort.by(Sort.Direction.fromString(sortDirection), sortBy);
        Pageable pageable = PageRequest.of(page, size, sort);

        if (keyword == null || keyword.trim().isEmpty()) {
            return getProductsByParentCategory(parentCategory, page, size, sortBy, sortDirection);
        }

        return productRepository.findByParentCategoryIdAndKeyword(
                parentCategory.getId(), ProductStatus.ACTIVE, keyword.trim(), pageable);
    }

    public Page<Product> getProductsByCategory(Category category, int page, int size, String sortBy,
            String sortDirection) {
        Sort sort = Sort.by(Sort.Direction.fromString(sortDirection), sortBy);
        Pageable pageable = PageRequest.of(page, size, sort);

        return productRepository.findByCategoryId(category.getId(), ProductStatus.ACTIVE, pageable);
    }

    public Page<Product> searchProductsByCategory(Category category, String keyword, int page, int size,
            String sortBy, String sortDirection) {
        Sort sort = Sort.by(Sort.Direction.fromString(sortDirection), sortBy);
        Pageable pageable = PageRequest.of(page, size, sort);

        if (keyword == null || keyword.trim().isEmpty()) {
            return getProductsByCategory(category, page, size, sortBy, sortDirection);
        }

        return productRepository.findByCategoryIdAndKeyword(
                category.getId(), ProductStatus.ACTIVE, keyword.trim(), pageable);
    }

    public Long countProductsByParentCategory(Category parentCategory) {
        return productRepository.countByParentCategoryId(parentCategory.getId(), ProductStatus.ACTIVE);
    }

    /**
     * Get product by slug
     * 
     * @param slug Product slug
     * @return Product or null if not found
     */
    public Product getProductBySlug(String slug) {
        return productRepository.findBySlugWithDetails(slug).orElse(null);
    }

    /**
     * Get product by ID
     * 
     * @param productId Product ID
     * @return Product or null if not found
     * 
     * 
     *         /**
     *         Get active product by ID
     * 
     * @param productId Product ID
     * @return Active product or null if not found or inactive
     */
    public Product getActiveProductById(Long productId) {
        Product product = getProductById(productId);
        if (product != null && product.getStatus() == ProductStatus.ACTIVE
                && !Boolean.TRUE.equals(product.getIsDeleted())) {
            return product;
        }
        return null;
    }

    /* --- Methods from previous interface/impl --- */
    public Page<Product> search(Long storeId, String q, ProductStatus status, Long categoryId, Pageable pageable) {
        return productRepository.search(
                storeId, q, status, categoryId, (Long) null, (java.time.LocalDateTime) null,
                (java.time.LocalDateTime) null, (java.math.BigDecimal) null, (java.math.BigDecimal) null,
                (Long) null, (Long) null, pageable);
    }

    public Page<Product> search(Long storeId, String q, ProductStatus status,
            Long categoryId, Long parentCategoryId,
            LocalDateTime createdFrom, LocalDateTime createdTo,
            java.math.BigDecimal minPrice, java.math.BigDecimal maxPrice,
            Long idFrom, Long idTo,
            Pageable pageable) {
        return productRepository.search(storeId, q, status, categoryId, parentCategoryId, createdFrom, createdTo,
                minPrice, maxPrice, idFrom, idTo, pageable);
    }

    public Product getOwned(Long id, Long storeId) {
        return productRepository.findById(id)
                .filter(p -> !Boolean.TRUE.equals(p.getIsDeleted()))
                .filter(p -> p.getSellerStore() != null && p.getSellerStore().getId().equals(storeId))
                .orElseThrow(() -> new IllegalArgumentException(
                        "Không tìm thấy sản phẩm hoặc không thuộc cửa hàng của bạn."));
    }

    @Transactional
    public Product create(Product p) {
        SellerStore store = storeRepository.findById(p.getSellerStore().getId())
                .orElseThrow(() -> new IllegalArgumentException("Store không tồn tại."));

        // NEW: chặn giá vượt trần nếu DB có max_listing_price
        if (p.getPrice() != null && store.getMaxListingPrice() != null
                && p.getPrice().compareTo(store.getMaxListingPrice()) > 0) {
            throw new IllegalArgumentException("Giá vượt mức tối đa cho phép ("
                    + store.getMaxListingPrice().toPlainString() + ").");
        }

        if (p.getSlug() != null
                && productRepository.existsBySellerStore_IdAndSlugIgnoreCaseAndIsDeletedFalse(
                        store.getId(), p.getSlug())) {
            throw new IllegalArgumentException("Slug đã tồn tại trong cửa hàng.");
        }
        if (p.getStatus() == null)
            p.setStatus(ProductStatus.ACTIVE);
        p.setIsDeleted(false);
        return productRepository.save(p);
    }

    @Transactional
    public Product update(Product p, Long storeId) {
        Product db = getOwned(p.getId(), storeId);

        // NEW: lấy store để đọc max_listing_price
        SellerStore store = storeRepository.findById(storeId)
                .orElseThrow(() -> new IllegalArgumentException("Store không tồn tại."));

        if (p.getSlug() != null
                && productRepository.existsBySellerStore_IdAndSlugIgnoreCaseAndIdNotAndIsDeletedFalse(
                        storeId, p.getSlug(), p.getId())) {
            throw new IllegalArgumentException("Slug đã tồn tại trong cửa hàng.");
        }

        // NEW: xác định giá sẽ áp dụng (giữ cũ nếu không gửi mới)
        java.math.BigDecimal priceToApply = p.getPrice() != null ? p.getPrice() : db.getPrice();
        if (priceToApply != null && store.getMaxListingPrice() != null
                && priceToApply.compareTo(store.getMaxListingPrice()) > 0) {
            throw new IllegalArgumentException("Giá vượt mức tối đa cho phép ("
                    + store.getMaxListingPrice().toPlainString() + ").");
        }

        db.setName(p.getName());
        db.setSlug(p.getSlug());
        db.setProductUrl(p.getProductUrl());
        db.setDescription(p.getDescription());
        db.setPrice(p.getPrice());
        db.setCategory(p.getCategory());

        // If submitted status is non-null, validate it and then update.
        if (p.getStatus() != null) {
            // If attempted to set ACTIVE, ensure stock exists
            if (p.getStatus() == ProductStatus.ACTIVE) {
                Integer stockToCheck = p.getStock() != null ? p.getStock() : db.getStock();
                if (stockToCheck == null || stockToCheck <= 0) {
                    throw new IllegalArgumentException("Vui lòng nhập hàng");
                }
            }
            db.setStatus(p.getStatus());
        }
        if (p.getStock() != null) {
            db.setStock(p.getStock());
        }
        return productRepository.save(db);
    }

    @Transactional
    public void toggle(Long id, Long storeId, ProductStatus toStatus) {
        Product db = getOwned(id, storeId);
        // If trying to activate, ensure there is stock available
        if (toStatus == ProductStatus.ACTIVE) {
            Integer stock = db.getStock();
            if (stock == null || stock <= 0) {
                throw new IllegalArgumentException("Vui lòng nhập hàng");
            }
        }
        db.setStatus(toStatus);
        productRepository.save(db);
    }

    @Transactional
    public void softDelete(Long id, Long storeId, Long userId) {
        Product db = getOwned(id, storeId);
        db.setStatus(ProductStatus.INACTIVE);
        db.setIsDeleted(true);
        db.setDeletedBy(userId);
        productRepository.save(db);
    }

    public boolean isSlugTaken(Long storeId, String slug, Long excludeId) {
        return excludeId == null
                ? productRepository.existsBySellerStore_IdAndSlugIgnoreCaseAndIsDeletedFalse(storeId, slug)
                : productRepository.existsBySellerStore_IdAndSlugIgnoreCaseAndIdNotAndIsDeletedFalse(
                        storeId, slug, excludeId);
    }

}

    /**
     * Get dynamic stock count from ProductStorage table
     * 
     * @param productId Product ID
     * @return Number of available ProductStorage items
     */
    public long getDynamicStock(Long productId) {
        return productRepository.getDynamicStock(productId);
    }
}
