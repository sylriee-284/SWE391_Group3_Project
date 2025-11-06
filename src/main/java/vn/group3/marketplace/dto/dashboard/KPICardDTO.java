package vn.group3.marketplace.dto.dashboard;

import lombok.*;
import java.math.BigDecimal;

/**
 * DTO for KPI Card data (Revenue, Orders, AOV, etc.)
 */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class KPICardDTO {
    private String title;
    private BigDecimal value;
    private String unit; // VND, orders, %
    private BigDecimal changePercent; // % change from previous period
    private String changeDirection; // "up", "down", "neutral"
    private String description;
}
