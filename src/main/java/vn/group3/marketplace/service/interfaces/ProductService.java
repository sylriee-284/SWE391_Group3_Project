package vn.group3.marketplace.service.interfaces;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.web.multipart.MultipartFile;
import vn.group3.marketplace.domain.entity.Product;
import vn.group3.marketplace.domain.enums.ProductCategory;
import vn.group3.marketplace.dto.request.ProductCreateRequest;
import vn.group3.marketplace.dto.request.ProductUpdateRequest;
import vn.group3.marketplace.dto.response.ProductResponse;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

/**
 * Service interface for Product management
 */
public interface ProductService {

    /**
     * Create a new product
     * @param sellerId ID of the seller creating the product
     * @param request Product creation request
     * @return Created product
     */
    Product createProduct(Long sellerId, ProductCreateRequest request);

    /**
     * Update an existing product
     * @param productId ID of the product to update
     * @param sellerId ID of the seller (for authorization)
     * @param request Product update request
     * @return Updated product
     */
    Product updateProduct(Long productId, Long sellerId, ProductUpdateRequest request);

    /**
     * Delete a product (soft delete)
     * @param productId ID of the product to delete
     * @param sellerId ID of the seller (for authorization)
     */
    void deleteProduct(Long productId, Long sellerId);

    /**
     * Get product by ID
     * @param productId Product ID
     * @return Optional containing the product if found
     */
    Optional<Product> getProductById(Long productId);

    /**
     * Get product response by ID
     * @param productId Product ID
     * @return Optional containing the product response if found
     */
    Optional<ProductResponse> getProductResponseById(Long productId);

    /**
     * Get all products by store
     * @param storeId Store ID
     * @param pageable Pagination information
     * @return Page of product responses
     */
    Page<ProductResponse> getProductsByStore(Long storeId, Pageable pageable);

    /**
     * Get all products by seller
     * @param sellerId Seller ID
     * @param pageable Pagination information
     * @return Page of product responses
     */
    Page<ProductResponse> getProductsBySeller(Long sellerId, Pageable pageable);

    /**
     * Get all active products (public listing)
     * @param pageable Pagination information
     * @return Page of product responses
     */
    Page<ProductResponse> getActiveProducts(Pageable pageable);

    /**
     * Search products by keyword
     * @param keyword Search keyword
     * @param pageable Pagination information
     * @return Page of product responses
     */
    Page<ProductResponse> searchProducts(String keyword, Pageable pageable);

    /**
     * Search products by keyword and category
     * @param keyword Search keyword
     * @param category Product category
     * @param pageable Pagination information
     * @return Page of product responses
     */
    Page<ProductResponse> searchProducts(String keyword, ProductCategory category, Pageable pageable);

    /**
     * Get products by category
     * @param category Product category
     * @param pageable Pagination information
     * @return Page of product responses
     */
    Page<ProductResponse> getProductsByCategory(ProductCategory category, Pageable pageable);

    /**
     * Toggle product active status
     * @param productId Product ID
     * @param sellerId Seller ID (for authorization)
     * @return Updated product
     */
    Product toggleProductStatus(Long productId, Long sellerId);

    /**
     * Upload product images
     * @param productId Product ID
     * @param sellerId Seller ID (for authorization)
     * @param imageFiles Image files to upload
     * @return Updated product with image URLs
     */
    Product uploadProductImages(Long productId, Long sellerId, List<MultipartFile> imageFiles);

    /**
     * Check if SKU is available
     * @param sku SKU to check
     * @param excludeProductId Product ID to exclude (for updates)
     * @return true if SKU is available
     */
    boolean isSkuAvailable(String sku, Long excludeProductId);

    /**
     * Update product stock
     * @param productId Product ID
     * @param quantity Quantity to add (positive) or remove (negative)
     */
    void updateStock(Long productId, int quantity);

    /**
     * Get low stock products for a seller
     * @param sellerId Seller ID
     * @param threshold Stock threshold
     * @return List of low stock products
     */
    List<Product> getLowStockProducts(Long sellerId, Integer threshold);

    /**
     * Get out of stock products for a seller
     * @param sellerId Seller ID
     * @return List of out of stock products
     */
    List<Product> getOutOfStockProducts(Long sellerId);

    /**
     * Count products by seller
     * @param sellerId Seller ID
     * @return Number of products
     */
    long countProductsBySeller(Long sellerId);

    /**
     * Count active products by seller
     * @param sellerId Seller ID
     * @return Number of active products
     */
    long countActiveProductsBySeller(Long sellerId);

    /**
     * Get products with advanced filters
     *
     * @param search Search keyword (nullable)
     * @param category Product category (nullable)
     * @param minPrice Minimum price (nullable)
     * @param maxPrice Maximum price (nullable)
     * @param storeId Store ID (nullable)
     * @param stockStatus Stock status filter (nullable)
     * @param pageable Pagination and sorting
     * @return Page of ProductResponse DTOs
     */
    Page<ProductResponse> getProductsWithFilters(
        String search,
        ProductCategory category,
        BigDecimal minPrice,
        BigDecimal maxPrice,
        Long storeId,
        String stockStatus,
        Pageable pageable
    );

    /**
     * Create a new product for testing (hard-coded store_id = 2)
     * WARNING: This method is for testing purposes only!
     * @param request Product creation request
     * @param imageFiles Optional list of image files to upload
     * @return Created product
     */
    Product createProductForTesting(ProductCreateRequest request, List<org.springframework.web.multipart.MultipartFile> imageFiles);
}
