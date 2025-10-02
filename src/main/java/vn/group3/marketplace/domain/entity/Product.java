package vn.group3.marketplace.domain.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import lombok.*;
import vn.group3.marketplace.domain.BaseEntity;
import vn.group3.marketplace.domain.enums.ProductCategory;

import java.math.BigDecimal;

/**
 * Product entity for marketplace products
 * Represents items sold by sellers in their stores
 */
@Entity
@Table(name = "products", indexes = {
    @Index(name = "idx_category", columnList = "category"),
    @Index(name = "idx_active", columnList = "is_active"),
    @Index(name = "idx_products_store", columnList = "seller_store_id"),
    @Index(name = "idx_products_seller", columnList = "seller_id")
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Product extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "product_name", nullable = false, length = 200)
    @NotBlank(message = "Tên sản phẩm không được để trống")
    @Size(max = 200, message = "Tên sản phẩm không được vượt quá 200 ký tự")
    private String productName;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    @Column(name = "price", nullable = false, precision = 15, scale = 2)
    @NotNull(message = "Giá sản phẩm không được để trống")
    @DecimalMin(value = "0.0", inclusive = false, message = "Giá sản phẩm phải lớn hơn 0")
    private BigDecimal price;

    @Column(name = "stock", nullable = false)
    @Min(value = 0, message = "Số lượng tồn kho không được âm")
    @Builder.Default
    private Integer stockQuantity = 0;

    @Enumerated(EnumType.STRING)
    @Column(name = "category", length = 50)
    private ProductCategory category;

    @Column(name = "product_images", columnDefinition = "TEXT")
    private String productImages; // JSON array or comma-separated URLs

    @Column(name = "sku", unique = true, length = 50)
    @Size(max = 50, message = "SKU không được vượt quá 50 ký tự")
    private String sku;

    @Column(name = "is_active", nullable = false)
    @Builder.Default
    private Boolean isActive = true;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "seller_store_id", nullable = false)
    private SellerStore store;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "seller_id", nullable = false)
    private User seller;

    // Business methods
    public boolean isAvailable() {
        return isActive && !isDeleted() && stockQuantity > 0;
    }

    public boolean canBeListed() {
        return isActive && !isDeleted() && store != null && store.isOperational();
    }

    public String getDisplayName() {
        return productName != null ? productName : "Sản phẩm #" + id;
    }

    public String getFormattedPrice() {
        if (price == null) return "0 VND";
        return String.format("%,.0f VND", price);
    }

    public String getCategoryDisplayName() {
        return category != null ? category.getDisplayName() : "Chưa phân loại";
    }

    public boolean isInStock() {
        return stockQuantity != null && stockQuantity > 0;
    }

    public void decreaseStock(int quantity) {
        if (quantity <= 0) {
            throw new IllegalArgumentException("Số lượng phải lớn hơn 0");
        }
        if (stockQuantity < quantity) {
            throw new IllegalStateException("Không đủ hàng trong kho");
        }
        this.stockQuantity -= quantity;
    }

    public void increaseStock(int quantity) {
        if (quantity <= 0) {
            throw new IllegalArgumentException("Số lượng phải lớn hơn 0");
        }
        this.stockQuantity += quantity;
    }

    // Validation
    @PrePersist
    @PreUpdate
    public void validateProduct() {
        // Ensure price doesn't exceed store's max listing price
        if (store != null && store.getMaxListingPrice() != null) {
            if (price.compareTo(store.getMaxListingPrice()) > 0) {
                throw new IllegalStateException(
                    String.format("Giá sản phẩm (%s VND) vượt quá giới hạn của cửa hàng (%s VND)",
                        getFormattedPrice(), store.getFormattedMaxPrice())
                );
            }
        }
    }
}
