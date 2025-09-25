package vn.group3.marketplace.domain.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import lombok.*;
import vn.group3.marketplace.domain.BaseEntity;
import vn.group3.marketplace.domain.constants.StoreStatus;

import java.math.BigDecimal;
import java.math.RoundingMode;

/**
 * SellerStore entity for marketplace seller stores
 * Represents a seller's store with deposit and business information
 */
@Entity
@Table(name = "seller_stores")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SellerStore extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "owner_user_id", nullable = false)
    private User ownerUser;

    @Column(name = "store_name", nullable = false, length = 100)
    @NotBlank(message = "Store name is required")
    @Size(max = 100, message = "Store name must not exceed 100 characters")
    private String storeName;

    @Column(name = "store_description", columnDefinition = "TEXT")
    private String storeDescription;

    @Column(name = "deposit_amount", nullable = false, precision = 15, scale = 2)
    @NotNull(message = "Deposit amount is required")
    @DecimalMin(value = "5000000", message = "Minimum deposit is 5,000,000 VND")
    private BigDecimal depositAmount;

    @Column(name = "max_listing_price", precision = 15, scale = 2)
    private BigDecimal maxListingPrice;

    @Column(name = "store_logo_url")
    private String storeLogoUrl;

    @Column(name = "contact_email", length = 100)
    @Email(message = "Invalid email format")
    private String contactEmail;

    @Column(name = "contact_phone", length = 20)
    private String contactPhone;

    @Column(name = "business_license")
    private String businessLicense;

    @Column(name = "is_verified", nullable = false)
    @Builder.Default
    private Boolean isVerified = false;

    @Column(name = "is_active", nullable = false)
    @Builder.Default
    private Boolean isActive = true;

    @Column(name = "status", nullable = false, length = 20)
    @Builder.Default
    private String status = StoreStatus.ACTIVE;

    // Business methods
    public boolean canListProduct(BigDecimal productPrice) {
        return isActive && !isDeleted() &&
               (maxListingPrice == null || productPrice.compareTo(maxListingPrice) <= 0);
    }

    public boolean isOperational() {
        return StoreStatus.isOperational(status, isActive, isVerified) && !isDeleted();
    }

    public String getDisplayName() {
        return storeName != null ? storeName : "Store #" + id;
    }

    public String getFormattedDeposit() {
        if (depositAmount == null) return "0 VND";
        return String.format("%,.0f VND", depositAmount);
    }

    public String getFormattedMaxPrice() {
        if (maxListingPrice == null) return "Không giới hạn";
        return String.format("%,.0f VND", maxListingPrice);
    }

    // JPA lifecycle methods
    @PrePersist
    @PreUpdate
    public void calculateMaxListingPrice() {
        if (depositAmount != null && depositAmount.compareTo(BigDecimal.ZERO) > 0) {
            this.maxListingPrice = depositAmount.divide(BigDecimal.TEN, 2, RoundingMode.DOWN);
        }
    }

    public String getStatusDisplay() {
        return StoreStatus.getDisplayName(status);
    }
}
