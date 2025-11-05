package vn.group3.marketplace.dto.dashboard;

import lombok.*;
import java.util.List;

/**
 * DTO for Dashboard Overview screen (Screen 1)
 */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DashboardOverviewDTO {
    // KPI Cards
    private KPICardDTO revenue;
    private KPICardDTO orderCount;
    private KPICardDTO averageOrderValue;
    private KPICardDTO escrowHeld;
    private KPICardDTO escrowReleased;
    private KPICardDTO escrowRefunded;
    private KPICardDTO shopRating;
    private KPICardDTO lowStockCount;

    // Charts
    private ChartDataDTO revenueChart;
    private ChartDataDTO topProductsChart;

    // Alerts
    private List<AlertDTO> alerts;

    // Filter params (for maintaining state)
    private String timeFilter; // "today", "7days", "30days", "custom"
    private String startDate;
    private String endDate;
    private Long productId;
    private Long categoryId;
}
