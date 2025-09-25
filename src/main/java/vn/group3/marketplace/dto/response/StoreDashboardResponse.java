package vn.group3.marketplace.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/**
 * Response DTO for store dashboard data
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class StoreDashboardResponse {

    // Store basic info
    private Long storeId;
    private String storeName;
    private String status;
    private Boolean isVerified;
    private Boolean isActive;
    private LocalDateTime createdAt;

    // Financial summary
    private BigDecimal depositAmount;
    private BigDecimal maxListingPrice;
    private BigDecimal totalRevenue;
    private BigDecimal totalProfit;
    private BigDecimal pendingEscrow;
    private BigDecimal availableBalance;

    // Product statistics
    private Long totalProducts;
    private Long activeProducts;
    private Long inactiveProducts;
    private Long outOfStockProducts;

    // Order statistics
    private Long totalOrders;
    private Long pendingOrders;
    private Long completedOrders;
    private Long cancelledOrders;

    // Customer statistics
    private Long totalCustomers;
    private Long repeatCustomers;
    private Double customerRetentionRate;

    // Review statistics
    private Long totalReviews;
    private Double averageRating;
    private Map<Integer, Long> ratingDistribution; // rating -> count

    // Performance metrics
    private BigDecimal conversionRate;
    private BigDecimal averageOrderValue;
    private Long totalViews;
    private Long uniqueVisitors;

    // Recent activity
    private List<Object> recentOrders; // Will be detailed later
    private List<Object> recentReviews; // Will be detailed later
    private List<Object> topProducts; // Will be detailed later

    // Time-based analytics
    private Map<String, BigDecimal> revenueByDay; // last 7 days
    private Map<String, Long> ordersByDay; // last 7 days
    private Map<String, BigDecimal> revenueByMonth; // last 12 months

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
     * Get formatted total profit
     * @return Formatted profit string
     */
    public String getFormattedProfit() {
        if (totalProfit == null) return "0 VND";
        return String.format("%,.0f VND", totalProfit);
    }

    /**
     * Get formatted pending escrow
     * @return Formatted escrow string
     */
    public String getFormattedPendingEscrow() {
        if (pendingEscrow == null) return "0 VND";
        return String.format("%,.0f VND", pendingEscrow);
    }

    /**
     * Get formatted available balance
     * @return Formatted balance string
     */
    public String getFormattedAvailableBalance() {
        if (availableBalance == null) return "0 VND";
        return String.format("%,.0f VND", availableBalance);
    }

    /**
     * Get formatted average order value
     * @return Formatted AOV string
     */
    public String getFormattedAverageOrderValue() {
        if (averageOrderValue == null) return "0 VND";
        return String.format("%,.0f VND", averageOrderValue);
    }

    /**
     * Get formatted conversion rate
     * @return Formatted conversion rate string
     */
    public String getFormattedConversionRate() {
        if (conversionRate == null) return "0%";
        return String.format("%.2f%%", conversionRate);
    }

    /**
     * Get formatted customer retention rate
     * @return Formatted retention rate string
     */
    public String getFormattedRetentionRate() {
        if (customerRetentionRate == null) return "0%";
        return String.format("%.2f%%", customerRetentionRate);
    }

    /**
     * Get formatted average rating
     * @return Formatted rating string
     */
    public String getFormattedAverageRating() {
        if (averageRating == null) return "0.0";
        return String.format("%.1f", averageRating);
    }

    /**
     * Get store health status
     * @return Health status text
     */
    public String getStoreHealthStatus() {
        if (!Boolean.TRUE.equals(isActive)) {
            return "Không hoạt động";
        }
        if (!Boolean.TRUE.equals(isVerified)) {
            return "Chờ xác minh";
        }
        if (totalProducts == null || totalProducts == 0) {
            return "Chưa có sản phẩm";
        }
        if (activeProducts == null || activeProducts == 0) {
            return "Không có sản phẩm hoạt động";
        }
        return "Hoạt động tốt";
    }

    /**
     * Get store health badge class
     * @return CSS class for health badge
     */
    public String getHealthBadgeClass() {
        String health = getStoreHealthStatus();
        switch (health) {
            case "Hoạt động tốt":
                return "badge-success";
            case "Chờ xác minh":
            case "Chưa có sản phẩm":
                return "badge-warning";
            case "Không hoạt động":
            case "Không có sản phẩm hoạt động":
                return "badge-danger";
            default:
                return "badge-secondary";
        }
    }

    /**
     * Calculate order completion rate
     * @return Completion rate percentage
     */
    public Double getOrderCompletionRate() {
        if (totalOrders == null || totalOrders == 0) {
            return 0.0;
        }
        if (completedOrders == null) {
            return 0.0;
        }
        return (completedOrders.doubleValue() / totalOrders.doubleValue()) * 100;
    }

    /**
     * Get formatted order completion rate
     * @return Formatted completion rate string
     */
    public String getFormattedCompletionRate() {
        return String.format("%.1f%%", getOrderCompletionRate());
    }

    /**
     * Calculate product activity rate
     * @return Activity rate percentage
     */
    public Double getProductActivityRate() {
        if (totalProducts == null || totalProducts == 0) {
            return 0.0;
        }
        if (activeProducts == null) {
            return 0.0;
        }
        return (activeProducts.doubleValue() / totalProducts.doubleValue()) * 100;
    }

    /**
     * Get formatted product activity rate
     * @return Formatted activity rate string
     */
    public String getFormattedActivityRate() {
        return String.format("%.1f%%", getProductActivityRate());
    }
}
