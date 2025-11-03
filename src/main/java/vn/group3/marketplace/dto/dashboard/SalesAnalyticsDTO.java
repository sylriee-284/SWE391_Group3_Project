package vn.group3.marketplace.dto.dashboard;

import lombok.*;
import org.springframework.data.domain.Page;
import java.util.List;

/**
 * DTO for Sales Analytics screen (Screen 2)
 */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SalesAnalyticsDTO {
    // Order table
    private Page<OrderSummaryDTO> orders;

    // Escrow summary
    private EscrowSummaryDTO escrowSummary;

    // Charts
    private ChartDataDTO revenueByStatusChart;
    private ChartDataDTO escrowTimelineChart;

    // Filter params
    private String timeFilter;
    private String startDate;
    private String endDate;
    private String orderStatus;
    private Long productId;
}
