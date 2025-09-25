package vn.group3.marketplace.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import vn.group3.marketplace.domain.entity.SellerStore;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Response DTO for SellerStore entity
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SellerStoreResponse {

    private Long id;
    private Long ownerUserId;
    private String ownerUsername;
    private String ownerFullName;
    private String storeName;
    private String storeDescription;
    private String status;
    private BigDecimal depositAmount;
    private BigDecimal maxListingPrice;
    private String depositCurrency;
    private String storeLogoUrl;
    private String contactEmail;
    private String contactPhone;
    private String businessLicense;
    private Boolean isVerified;
    private Boolean isActive;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // Additional computed fields
    private Long totalProducts;
    private Long totalOrders;
    private BigDecimal totalRevenue;
    private Double averageRating;
    private Long totalReviews;

    /**
     * Create SellerStoreResponse from SellerStore entity
     * @param store SellerStore entity
     * @return SellerStoreResponse
     */
    public static SellerStoreResponse fromEntity(SellerStore store) {
        return SellerStoreResponse.builder()
                .id(store.getId())
                .ownerUserId(store.getOwnerUser() != null ? store.getOwnerUser().getId() : null)
                .ownerUsername(store.getOwnerUser() != null ? store.getOwnerUser().getUsername() : null)
                .ownerFullName(store.getOwnerUser() != null ? store.getOwnerUser().getFullName() : null)
                .storeName(store.getStoreName())
                .storeDescription(store.getStoreDescription())
                .status(store.getStatus())
                .depositAmount(store.getDepositAmount())
                .maxListingPrice(store.getMaxListingPrice())
                .depositCurrency("VND")
                .storeLogoUrl(store.getStoreLogoUrl())
                .contactEmail(store.getContactEmail())
                .contactPhone(store.getContactPhone())
                .businessLicense(store.getBusinessLicense())
                .isVerified(store.getIsVerified())
                .isActive(store.getIsActive())
                .createdAt(store.getCreatedAt())
                .updatedAt(store.getUpdatedAt())
                .build();
    }

    /**
     * Get formatted deposit amount
     * @return Formatted deposit string
     */
    public String getFormattedDeposit() {
        if (depositAmount == null) return "0 VND";
        return String.format("%,.0f VND", depositAmount);
    }

    /**
     * Get formatted max listing price
     * @return Formatted max listing price string
     */
    public String getFormattedMaxListingPrice() {
        if (maxListingPrice == null) return "Không giới hạn";
        return String.format("%,.0f VND", maxListingPrice);
    }

    /**
     * Get formatted total revenue
     * @return Formatted revenue string
     */
    public String getFormattedRevenue() {
        if (totalRevenue == null) return "0 VND";
        return String.format("%,.0f VND", totalRevenue);
    }

    /**
     * Get store status badge class for UI
     * @return CSS class for status badge
     */
    public String getStatusBadgeClass() {
        if (status == null) return "badge-secondary";
        
        switch (status.toLowerCase()) {
            case "active":
                return isVerified ? "badge-success" : "badge-warning";
            case "inactive":
                return "badge-secondary";
            case "suspended":
                return "badge-danger";
            case "pending":
                return "badge-info";
            default:
                return "badge-secondary";
        }
    }

    /**
     * Get store status display text
     * @return Display text for status
     */
    public String getStatusDisplayText() {
        if (status == null) return "Unknown";
        
        switch (status.toLowerCase()) {
            case "active":
                return isVerified ? "Hoạt động" : "Chờ xác minh";
            case "inactive":
                return "Không hoạt động";
            case "suspended":
                return "Bị khóa";
            case "pending":
                return "Chờ duyệt";
            default:
                return status;
        }
    }

    /**
     * Check if store is operational
     * @return true if store can operate normally
     */
    public boolean isOperational() {
        return Boolean.TRUE.equals(isActive) && 
               Boolean.TRUE.equals(isVerified) && 
               "active".equalsIgnoreCase(status);
    }

    /**
     * Get verification status display
     * @return Verification status text
     */
    public String getVerificationStatus() {
        if (Boolean.TRUE.equals(isVerified)) {
            return "Đã xác minh";
        } else {
            return "Chưa xác minh";
        }
    }

    /**
     * Get verification badge class
     * @return CSS class for verification badge
     */
    public String getVerificationBadgeClass() {
        return Boolean.TRUE.equals(isVerified) ? "badge-success" : "badge-warning";
    }
}
