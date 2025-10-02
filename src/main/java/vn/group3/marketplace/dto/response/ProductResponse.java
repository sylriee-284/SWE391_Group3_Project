package vn.group3.marketplace.dto.response;

import lombok.*;
import vn.group3.marketplace.domain.entity.Product;
import vn.group3.marketplace.domain.enums.ProductCategory;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * DTO for product response with full details
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ProductResponse {

    private Long id;
    private String productName;
    private String description;
    private BigDecimal price;
    private String formattedPrice;
    private Integer stockQuantity;
    private ProductCategory category;
    private String categoryDisplayName;
    private String productImages;
    private String sku;
    private Boolean isActive;
    private Boolean isAvailable;

    // Store information
    private Long storeId;
    private String storeName;
    private String storeLogoUrl;

    // Seller information
    private Long sellerId;
    private String sellerName;
    private String sellerEmail;

    // Timestamps
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    /**
     * Convert Product entity to ProductResponse DTO
     */
    public static ProductResponse fromEntity(Product product) {
        if (product == null) {
            return null;
        }

        ProductResponseBuilder builder = ProductResponse.builder()
                .id(product.getId())
                .productName(product.getProductName())
                .description(product.getDescription())
                .price(product.getPrice())
                .formattedPrice(product.getFormattedPrice())
                .stockQuantity(product.getStockQuantity())
                .category(product.getCategory())
                .categoryDisplayName(product.getCategoryDisplayName())
                .productImages(product.getProductImages())
                .sku(product.getSku())
                .isActive(product.getIsActive())
                .isAvailable(product.isAvailable())
                .createdAt(product.getCreatedAt())
                .updatedAt(product.getUpdatedAt());

        // Add store information if available
        if (product.getStore() != null) {
            builder.storeId(product.getStore().getId())
                   .storeName(product.getStore().getStoreName())
                   .storeLogoUrl(product.getStore().getStoreLogoUrl());
        }

        // Add seller information if available
        if (product.getSeller() != null) {
            builder.sellerId(product.getSeller().getId())
                   .sellerName(product.getSeller().getFullName())
                   .sellerEmail(product.getSeller().getEmail());
        }

        return builder.build();
    }

    /**
     * Simplified version for list views
     */
    public static ProductResponse toListResponse(Product product) {
        if (product == null) {
            return null;
        }

        return ProductResponse.builder()
                .id(product.getId())
                .productName(product.getProductName())
                .price(product.getPrice())
                .formattedPrice(product.getFormattedPrice())
                .stockQuantity(product.getStockQuantity())
                .category(product.getCategory())
                .categoryDisplayName(product.getCategoryDisplayName())
                .productImages(product.getProductImages())
                .isActive(product.getIsActive())
                .isAvailable(product.isAvailable())
                .storeId(product.getStore() != null ? product.getStore().getId() : null)
                .storeName(product.getStore() != null ? product.getStore().getStoreName() : null)
                .build();
    }
}
