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
import vn.group3.marketplace.repository.SellerStoreRepository;
import vn.group3.marketplace.repository.UserRepository;
import vn.group3.marketplace.service.interfaces.FileUploadService;
import vn.group3.marketplace.service.interfaces.ProductService;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * Implementation of ProductService interface
 * Handles all product-related business logic
 */
@Service
@Transactional
@RequiredArgsConstructor
@Slf4j
public class ProductServiceImpl implements ProductService {

    private final ProductRepository productRepository;
    private final SellerStoreRepository sellerStoreRepository;
    private final UserRepository userRepository;
    private final FileUploadService fileUploadService;

    @Override
    public Product createProduct(Long sellerId, ProductCreateRequest request, List<MultipartFile> imageFiles) {
        log.info("Creating product for seller {}: {}", sellerId, request.getProductName());

        // Validate seller exists
        User seller = userRepository.findById(sellerId)
                .orElseThrow(() -> new IllegalArgumentException("Seller not found: " + sellerId));

        // Get seller's store (assuming each seller has one store)
        SellerStore store = sellerStoreRepository.findByOwnerUserIdAndIsDeletedFalse(sellerId)
                .orElseThrow(() -> new IllegalStateException("Seller has no active store"));

        // Validate price against store's max listing price
        if (store.getMaxListingPrice() != null && request.getPrice().compareTo(store.getMaxListingPrice()) > 0) {
            throw new IllegalArgumentException(
                String.format("Giá sản phẩm (%s VND) vượt quá giới hạn của cửa hàng (%s VND)",
                    request.getPrice(), store.getMaxListingPrice())
            );
        }

        // Generate SKU if not provided
        String sku = request.getSku();
        if (sku == null || sku.trim().isEmpty()) {
            sku = generateSku();
        }

        // Validate SKU uniqueness
        if (productRepository.existsBySku(sku)) {
            throw new IllegalArgumentException("SKU already exists: " + sku);
        }

        // Upload images if provided
        String productImages = null;
        if (imageFiles != null && !imageFiles.isEmpty()) {
            try {
                List<String> imageUrls = new ArrayList<>();
                for (MultipartFile file : imageFiles) {
                    if (file != null && !file.isEmpty()) {
                        String imageUrl = fileUploadService.uploadProductImage(null, file);
                        imageUrls.add(imageUrl);
                    }
                }
                if (!imageUrls.isEmpty()) {
                    productImages = String.join(",", imageUrls);
                }
            } catch (Exception e) {
                log.error("Failed to upload product images: {}", e.getMessage());
                throw new IllegalStateException("Failed to upload images: " + e.getMessage());
            }
        }

        // Create product entity
        Product product = Product.builder()
                .productName(request.getProductName())
                .description(request.getDescription())
                .price(request.getPrice())
                .stockQuantity(request.getStockQuantity())
                .category(request.getCategory())
                .sku(sku)
                .productImages(productImages)
                .isActive(request.getIsActive() != null ? request.getIsActive() : true)
                .store(store)
                .seller(seller)
                .build();

        product.setCreatedBy(sellerId);
        product = productRepository.save(product);

        log.info("Successfully created product {} with SKU {}", product.getId(), product.getSku());
        return product;
    }

    @Override
    public Product createProductForTesting(ProductCreateRequest request, List<MultipartFile> imageFiles) {
        log.warn("WARNING: Creating product with hard-coded store_id = 1 (TEST MODE)");

        Long testStoreId = 1L;
        Long testSellerId = 4L;

        // Get the test store
        SellerStore store = sellerStoreRepository.findById(testStoreId)
                .orElseThrow(() -> new IllegalStateException("Test store not found: " + testStoreId));

        // Get the test seller
        User seller = userRepository.findById(testSellerId)
                .orElseThrow(() -> new IllegalStateException("Test seller not found: " + testSellerId));

        // Generate SKU if not provided
        String sku = request.getSku();
        if (sku == null || sku.trim().isEmpty()) {
            sku = generateSku();
        }

        // Validate SKU uniqueness
        if (productRepository.existsBySku(sku)) {
            sku = generateSku(); // Regenerate if exists
        }

        // Upload images if provided
        String productImages = null;
        if (imageFiles != null && !imageFiles.isEmpty()) {
            try {
                List<String> imageUrls = new ArrayList<>();
                for (MultipartFile file : imageFiles) {
                    if (file != null && !file.isEmpty()) {
                        String imageUrl = fileUploadService.uploadProductImage(null, file);
                        imageUrls.add(imageUrl);
                    }
                }
                if (!imageUrls.isEmpty()) {
                    productImages = String.join(",", imageUrls);
                }
            } catch (Exception e) {
                log.error("Failed to upload product images in test mode: {}", e.getMessage());
            }
        }

        // Create product entity
        Product product = Product.builder()
                .productName(request.getProductName())
                .description(request.getDescription())
                .price(request.getPrice())
                .stockQuantity(request.getStockQuantity())
                .category(request.getCategory())
                .sku(sku)
                .productImages(productImages)
                .isActive(request.getIsActive() != null ? request.getIsActive() : true)
                .store(store)
                .seller(seller)
                .build();

        product.setCreatedBy(testSellerId);
        product = productRepository.save(product);

        log.info("Successfully created test product {} with SKU {}, Store ID: {}",
                 product.getId(), product.getSku(), testStoreId);
        return product;
    }

    @Override
    public Product updateProduct(Long productId, Long sellerId, ProductUpdateRequest request) {
        log.info("Updating product {} by seller {}", productId, sellerId);

        Product product = productRepository.findByIdAndIsDeletedFalse(productId)
                .orElseThrow(() -> new IllegalArgumentException("Product not found: " + productId));

        // Verify ownership
        if (!product.getSeller().getId().equals(sellerId)) {
            throw new IllegalArgumentException("Seller does not own this product");
        }

        // Update fields
        if (request.getProductName() != null) {
            product.setProductName(request.getProductName());
        }
        if (request.getDescription() != null) {
            product.setDescription(request.getDescription());
        }
        if (request.getPrice() != null) {
            product.setPrice(request.getPrice());
        }
        if (request.getStockQuantity() != null) {
            product.setStockQuantity(request.getStockQuantity());
        }
        if (request.getCategory() != null) {
            product.setCategory(request.getCategory());
        }
        if (request.getIsActive() != null) {
            product.setIsActive(request.getIsActive());
        }

        product = productRepository.save(product);
        log.info("Successfully updated product {}", productId);
        return product;
    }

    @Override
    public void deleteProduct(Long productId, Long sellerId) {
        log.info("Deleting product {} by seller {}", productId, sellerId);

        Product product = productRepository.findByIdAndIsDeletedFalse(productId)
                .orElseThrow(() -> new IllegalArgumentException("Product not found: " + productId));

        // Verify ownership
        if (!product.getSeller().getId().equals(sellerId)) {
            throw new IllegalArgumentException("Seller does not own this product");
        }

        product.setIsDeleted(true);
        product.setDeletedBy(sellerId);
        productRepository.save(product);

        log.info("Successfully deleted product {}", productId);
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
                .map(ProductResponse::fromEntity);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<ProductResponse> getProductsBySeller(Long sellerId, Pageable pageable) {
        return productRepository.findBySellerIdAndIsDeletedFalse(sellerId, pageable)
                .map(ProductResponse::fromEntity);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<ProductResponse> getActiveProducts(Pageable pageable) {
        return productRepository.findByIsActiveTrueAndIsDeletedFalse(pageable)
                .map(ProductResponse::fromEntity);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<ProductResponse> searchProducts(String keyword, Pageable pageable) {
        return productRepository.searchProducts(keyword, pageable)
                .map(ProductResponse::fromEntity);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<ProductResponse> searchProducts(String keyword, ProductCategory category, Pageable pageable) {
        return productRepository.searchProductsByCategory(keyword, category, pageable)
                .map(ProductResponse::fromEntity);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<ProductResponse> getProductsByCategory(ProductCategory category, Pageable pageable) {
        return productRepository.findByCategoryAndIsActiveTrueAndIsDeletedFalse(category, pageable)
                .map(ProductResponse::fromEntity);
    }

    @Override
    public Product toggleProductStatus(Long productId, Long sellerId) {
        log.info("Toggling product status for {} by seller {}", productId, sellerId);

        Product product = productRepository.findByIdAndIsDeletedFalse(productId)
                .orElseThrow(() -> new IllegalArgumentException("Product not found: " + productId));

        // Verify ownership
        if (!product.getSeller().getId().equals(sellerId)) {
            throw new IllegalArgumentException("Seller does not own this product");
        }

        product.setIsActive(!product.getIsActive());
        product = productRepository.save(product);

        log.info("Product {} status toggled to {}", productId, product.getIsActive());
        return product;
    }

    @Override
    public Product uploadProductImages(Long productId, Long sellerId, List<MultipartFile> imageFiles) {
        log.info("Uploading images for product {} by seller {}", productId, sellerId);

        Product product = productRepository.findByIdAndIsDeletedFalse(productId)
                .orElseThrow(() -> new IllegalArgumentException("Product not found: " + productId));

        // Verify ownership
        if (!product.getSeller().getId().equals(sellerId)) {
            throw new IllegalArgumentException("Seller does not own this product");
        }

        if (imageFiles == null || imageFiles.isEmpty()) {
            throw new IllegalArgumentException("No image files provided");
        }

        try {
            List<String> imageUrls = new ArrayList<>();
            for (MultipartFile file : imageFiles) {
                if (file != null && !file.isEmpty()) {
                    String imageUrl = fileUploadService.uploadProductImage(productId, file);
                    imageUrls.add(imageUrl);
                }
            }

            if (!imageUrls.isEmpty()) {
                String newImages = String.join(",", imageUrls);

                // Append to existing images if any
                if (product.getProductImages() != null && !product.getProductImages().isEmpty()) {
                    product.setProductImages(product.getProductImages() + "," + newImages);
                } else {
                    product.setProductImages(newImages);
                }

                product = productRepository.save(product);
                log.info("Successfully uploaded {} images for product {}", imageUrls.size(), productId);
            }
        } catch (Exception e) {
            log.error("Failed to upload product images: {}", e.getMessage());
            throw new IllegalStateException("Failed to upload images: " + e.getMessage());
        }

        return product;
    }

    @Override
    @Transactional(readOnly = true)
    public boolean isSkuAvailable(String sku, Long excludeProductId) {
        if (excludeProductId != null) {
            return !productRepository.existsBySkuAndIdNot(sku, excludeProductId);
        }
        return !productRepository.existsBySku(sku);
    }

    @Override
    public void updateStock(Long productId, int quantity) {
        log.info("Updating stock for product {}: {}", productId, quantity);

        Product product = productRepository.findByIdAndIsDeletedFalse(productId)
                .orElseThrow(() -> new IllegalArgumentException("Product not found: " + productId));

        if (quantity > 0) {
            product.increaseStock(quantity);
        } else if (quantity < 0) {
            product.decreaseStock(Math.abs(quantity));
        }

        productRepository.save(product);
        log.info("Stock updated for product {}: new stock = {}", productId, product.getStockQuantity());
    }

    @Override
    @Transactional(readOnly = true)
    public List<Product> getLowStockProducts(Long sellerId, Integer threshold) {
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
        // Implementation depends on repository method - using basic count for now
        return productRepository.countBySellerIdAndIsDeletedFalse(sellerId);
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

        log.info("Getting products with filters - search: {}, category: {}, price: {}-{}, store: {}, stock: {}",
                 search, category, minPrice, maxPrice, storeId, stockStatus);

        return productRepository.findProductsWithFilters(
                search, category, minPrice, maxPrice, storeId, stockStatus, pageable
        ).map(ProductResponse::fromEntity);
    }

    /**
     * Generate a unique SKU in format PRD-XXXXXXXX (8 random uppercase letters)
     */
    private String generateSku() {
        String uuid = UUID.randomUUID().toString().replace("-", "").toUpperCase();
        return "PRD-" + uuid.substring(0, 8);
    }
}
