package vn.group3.marketplace.domain.dto;

import lombok.*;
import java.math.BigDecimal;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DashboardKPIDTO {
    // Revenue
    private BigDecimal netSales;
    private BigDecimal grossSales;

    // Orders
    private Long totalOrders;
    private Long pendingOrders;
    private Long completedOrders;
    private Long cancelledOrders;

    // AOV (Average Order Value)
    private BigDecimal averageOrderValue;

    // Escrow
    private BigDecimal escrowHeld;
    private BigDecimal escrowReleased;
    private BigDecimal escrowRefunded;

    // Shop rating
    private BigDecimal shopRating;

    // Stock alerts
    private Long lowStockProducts;
    private Long outOfStockProducts;

    // Return/Cancel rates
    private Double refundRate;
    private Double cancelRate;

    // Buyers
    private Long uniqueBuyers;
    private Long repeatBuyers;

    // Expiring stock
    private Long expiringStockCount;
}
