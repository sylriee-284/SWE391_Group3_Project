package vn.group3.marketplace.service.impl;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;
import vn.group3.marketplace.domain.entity.Product;
import vn.group3.marketplace.domain.entity.SellerStore;
import vn.group3.marketplace.domain.entity.User;
import vn.group3.marketplace.domain.enums.ProductCategory;
import vn.group3.marketplace.dto.request.ProductCreateRequest;
import vn.group3.marketplace.dto.request.ProductUpdateRequest;
import vn.group3.marketplace.dto.response.ProductResponse;
import vn.group3.marketplace.repository.ProductRepository;
import vn.group3.marketplace.service.interfaces.FileUploadService;
import vn.group3.marketplace.service.interfaces.ProductService;
import vn.group3.marketplace.service.interfaces.SellerStoreService;
import vn.group3.marketplace.service.interfaces.UserService;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * Implementation of ProductService
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ProductServiceImpl implements ProductService {

    private final ProductRepository productRepository;
    private final SellerStoreService sellerStoreService;
    private final UserService userService;
    private final FileUploadService fileUploadService;

    @Override
    @Transactional
    public Product createProduct(Long sellerId, ProductCreateRequest request) {
        log.info("Creating product for seller ID: {}", sellerId);

        // Verify seller exists
        User seller = userService.findById(sellerId)
                .orElseThrow(() -> new IllegalArgumentException("Seller không tồn tại"));

        // Verify seller has a store
        SellerStore store = sellerStoreService.getStoreByOwnerId(sellerId)
                .orElseThrow(() -> new IllegalStateException("Bạn cần tạo cửa hàng trước khi đăng sản phẩm"));

        // Verify store is operational
        if (!store.isOperational()) {
            throw new IllegalStateException("Cửa hàng của bạn chưa được kích hoạt hoặc đang bị khóa");
        }

        // Validate price against store's max listing price
        if (!store.canListProduct(request.getPrice())) {
            throw new IllegalArgumentException(
                String.format("Giá sản phẩm (%s VND) vượt quá giới hạn của cửa hàng (%s)",
                    formatPrice(request.getPrice()), store.getFormattedMaxPrice())
            );
        }

        // Check SKU uniqueness if provided
        if (request.getSku() != null && !request.getSku().isEmpty()) {
            if (productRepository.existsBySku(request.getSku())) {
                throw new IllegalArgumentException("SKU đã tồn tại: " + request.getSku());
            }
        } else {
            // Generate unique SKU if not provided
            request.setSku(generateUniqueSku());
        }

        // Create product entity
        Product product = Product.builder()
                .productName(request.getProductName())
                .description(request.getDescription())
                .price(request.getPrice())
                .stockQuantity(request.getStockQuantity())
                .category(request.getCategory())
                .sku(request.getSku())
                .productImages(request.getProductImages())
                .isActive(request.getIsActive() != null ? request.getIsActive() : true)
                .store(store)
                .seller(seller)
                .build();

        Product savedProduct = productRepository.save(product);
        log.info("Product created successfully with ID: {}", savedProduct.getId());

        return savedProduct;
    }

    @Override
    @Transactional
    public Product updateProduct(Long productId, Long sellerId, ProductUpdateRequest request) {
        log.info("Updating product ID: {} by seller ID: {}", productId, sellerId);

        Product product = productRepository.findByIdAndIsDeletedFalse(productId)
                .orElseThrow(() -> new IllegalArgumentException("Sản phẩm không tồn tại"));

        // Verify ownership
        if (!product.getSeller().getId().equals(sellerId)) {
            throw new IllegalArgumentException("Bạn không có quyền chỉnh sửa sản phẩm này");
        }

        // Validate price against store's max listing price
        if (!product.getStore().canListProduct(request.getPrice())) {
            throw new IllegalArgumentException(
                String.format("Giá sản phẩm (%s VND) vượt quá giới hạn của cửa hàng (%s)",
                    formatPrice(request.getPrice()), product.getStore().getFormattedMaxPrice())
            );
        }

        // Check SKU uniqueness if changed
        if (request.getSku() != null && !request.getSku().equals(product.getSku())) {
            if (productRepository.existsBySkuAndIdNot(request.getSku(), productId)) {
                throw new IllegalArgumentException("SKU đã tồn tại: " + request.getSku());
            }
        }

        // Update fields
        product.setProductName(request.getProductName());
        product.setDescription(request.getDescription());
        product.setPrice(request.getPrice());
        product.setStockQuantity(request.getStockQuantity());
        product.setCategory(request.getCategory());
        product.setSku(request.getSku());
        product.setProductImages(request.getProductImages());

        if (request.getIsActive() != null) {
            product.setIsActive(request.getIsActive());
        }

        Product updatedProduct = productRepository.save(product);
        log.info("Product updated successfully: {}", productId);

        return updatedProduct;
    }

    @Override
    @Transactional
    public void deleteProduct(Long productId, Long sellerId) {
        log.info("Deleting product ID: {} by seller ID: {}", productId, sellerId);

        Product product = productRepository.findByIdAndIsDeletedFalse(productId)
                .orElseThrow(() -> new IllegalArgumentException("Sản phẩm không tồn tại"));

        // Verify ownership
        if (!product.getSeller().getId().equals(sellerId)) {
            throw new IllegalArgumentException("Bạn không có quyền xóa sản phẩm này");
        }

        // Soft delete
        product.setIsDeleted(true);
        product.setIsActive(false);
        productRepository.save(product);

        log.info("Product soft deleted successfully: {}", productId);
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<Product> getProductById(Long productId) {
        return productRepository.findByIdAndIsDeletedFalse(productId);
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<ProductResponse> getProductResponseById(Long productId) {
        return productRepository.findByIdAndIsDeletedFalse(productId)
                .map(ProductResponse::fromEntity);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<ProductResponse> getProductsByStore(Long storeId, Pageable pageable) {
        return productRepository.findByStoreIdAndIsDeletedFalse(storeId, pageable)
                .map(ProductResponse::toListResponse);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<ProductResponse> getProductsBySeller(Long sellerId, Pageable pageable) {
        return productRepository.findBySellerIdAndIsDeletedFalse(sellerId, pageable)
                .map(ProductResponse::toListResponse);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<ProductResponse> getActiveProducts(Pageable pageable) {
        return productRepository.findByIsActiveTrueAndIsDeletedFalse(pageable)
                .map(ProductResponse::toListResponse);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<ProductResponse> searchProducts(String keyword, Pageable pageable) {
        if (keyword == null || keyword.trim().isEmpty()) {
            return getActiveProducts(pageable);
        }
        return productRepository.searchProducts(keyword.trim(), pageable)
                .map(ProductResponse::toListResponse);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<ProductResponse> searchProducts(String keyword, ProductCategory category, Pageable pageable) {
        if (keyword == null || keyword.trim().isEmpty()) {
            return getProductsByCategory(category, pageable);
        }
        return productRepository.searchProductsByCategory(keyword.trim(), category, pageable)
                .map(ProductResponse::toListResponse);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<ProductResponse> getProductsByCategory(ProductCategory category, Pageable pageable) {
        return productRepository.findByCategoryAndIsActiveTrueAndIsDeletedFalse(category, pageable)
                .map(ProductResponse::toListResponse);
    }

    @Override
    @Transactional
    public Product toggleProductStatus(Long productId, Long sellerId) {
        log.info("Toggling product status for ID: {} by seller ID: {}", productId, sellerId);

        Product product = productRepository.findByIdAndIsDeletedFalse(productId)
                .orElseThrow(() -> new IllegalArgumentException("Sản phẩm không tồn tại"));

        // Verify ownership
        if (!product.getSeller().getId().equals(sellerId)) {
            throw new IllegalArgumentException("Bạn không có quyền thay đổi trạng thái sản phẩm này");
        }

        product.setIsActive(!product.getIsActive());
        Product updatedProduct = productRepository.save(product);

        log.info("Product status toggled to: {}", updatedProduct.getIsActive());
        return updatedProduct;
    }

    @Override
    @Transactional
    public Product uploadProductImages(Long productId, Long sellerId, List<MultipartFile> imageFiles) {
        log.info("Uploading images for product ID: {} by seller ID: {}", productId, sellerId);

        Product product = productRepository.findByIdAndIsDeletedFalse(productId)
                .orElseThrow(() -> new IllegalArgumentException("Sản phẩm không tồn tại"));

        // Verify ownership
        if (!product.getSeller().getId().equals(sellerId)) {
            throw new IllegalArgumentException("Bạn không có quyền upload ảnh cho sản phẩm này");
        }

        if (imageFiles == null || imageFiles.isEmpty()) {
            throw new IllegalArgumentException("Vui lòng chọn ít nhất một ảnh");
        }

        // Upload images and collect URLs
        List<String> imageUrls = new ArrayList<>();
        for (MultipartFile imageFile : imageFiles) {
            if (!imageFile.isEmpty()) {
                try {
                    String imageUrl = fileUploadService.uploadProductImage(productId, imageFile);
                    imageUrls.add(imageUrl);
                } catch (Exception e) {
                    log.error("Failed to upload image: {}", e.getMessage());
                    throw new RuntimeException("Không thể upload ảnh: " + e.getMessage());
                }
            }
        }

        // Store as JSON array (simple comma-separated for now)
        String imagesJson = String.join(",", imageUrls);
        product.setProductImages(imagesJson);

        Product updatedProduct = productRepository.save(product);
        log.info("Product images uploaded successfully: {} images", imageUrls.size());

        return updatedProduct;
    }

    @Override
    @Transactional(readOnly = true)
    public boolean isSkuAvailable(String sku, Long excludeProductId) {
        if (sku == null || sku.trim().isEmpty()) {
            return true;
        }

        if (excludeProductId != null) {
            return !productRepository.existsBySkuAndIdNot(sku, excludeProductId);
        }

        return !productRepository.existsBySku(sku);
    }

    @Override
    @Transactional
    public void updateStock(Long productId, int quantity) {
        log.info("Updating stock for product ID: {} by quantity: {}", productId, quantity);

        Product product = productRepository.findByIdAndIsDeletedFalse(productId)
                .orElseThrow(() -> new IllegalArgumentException("Sản phẩm không tồn tại"));

        if (quantity > 0) {
            product.increaseStock(quantity);
        } else if (quantity < 0) {
            product.decreaseStock(Math.abs(quantity));
        }

        productRepository.save(product);
        log.info("Stock updated. New quantity: {}", product.getStockQuantity());
    }

    @Override
    @Transactional(readOnly = true)
    public List<Product> getLowStockProducts(Long sellerId, Integer threshold) {
        if (threshold == null || threshold < 0) {
            threshold = 10; // Default threshold
        }
        return productRepository.findLowStockProducts(sellerId, threshold);
    }

    @Override
    @Transactional(readOnly = true)
    public List<Product> getOutOfStockProducts(Long sellerId) {
        return productRepository.findOutOfStockProducts(sellerId);
    }

    @Override
    @Transactional(readOnly = true)
    public long countProductsBySeller(Long sellerId) {
        return productRepository.countBySellerIdAndIsDeletedFalse(sellerId);
    }

    @Override
    @Transactional(readOnly = true)
    public long countActiveProductsBySeller(Long sellerId) {
        return productRepository.countBySellerIdAndIsDeletedFalse(sellerId);
    }

    // Helper methods

    private String generateUniqueSku() {
        String sku;
        do {
            sku = "PRD-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
        } while (productRepository.existsBySku(sku));
        return sku;
    }

    private String formatPrice(java.math.BigDecimal price) {
        if (price == null) return "0";
        return String.format("%,.0f", price);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<ProductResponse> getProductsWithFilters(
            String search,
            ProductCategory category,
            BigDecimal minPrice,
            BigDecimal maxPrice,
            Long storeId,
            String stockStatus,
            Pageable pageable) {

        log.debug("Fetching products with filters - search: {}, category: {}, minPrice: {}, " +
                  "maxPrice: {}, storeId: {}, stockStatus: {}, page: {}, size: {}",
                  search, category, minPrice, maxPrice, storeId, stockStatus,
                  pageable.getPageNumber(), pageable.getPageSize());

        // Call repository with all filters
        Page<Product> products = productRepository.findProductsWithFilters(
            search,
            category,
            minPrice,
            maxPrice,
            storeId,
            stockStatus,
            pageable
        );

        log.debug("Found {} products matching filters", products.getTotalElements());

        // Transform to ProductResponse DTOs
        return products.map(ProductResponse::toListResponse);
    }
}
