package vn.group3.marketplace.dto.dashboard;

import lombok.*;
import org.springframework.data.domain.Page;

/**
 * DTO for Product Inventory & Performance screen (Screen 3)
 */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ProductInventoryDTO {
    // Product performance table
    private Page<ProductPerformanceDTO> products;

    // Charts
    private ChartDataDTO revenueByProductChart;
    private ChartDataDTO inventoryStatusChart;

    // Filter params
    private String timeFilter;
    private String startDate;
    private String endDate;
    private Long categoryId;
    private String inventoryStatus;
    private String sortBy; // "revenue", "sold", "rating"
}
