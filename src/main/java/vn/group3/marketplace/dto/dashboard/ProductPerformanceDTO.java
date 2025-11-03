package vn.group3.marketplace.dto.dashboard;

import lombok.*;
import java.math.BigDecimal;

/**
 * DTO for Product Performance data
 */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ProductPerformanceDTO {
    private Long productId;
    private String productName;
    private String categoryName;
    private BigDecimal price;
    private Integer soldQuantity;
    private BigDecimal revenue;
    private BigDecimal rating;
    private Integer ratingCount;
    private BigDecimal sellThroughRate; // % of sold vs total

    // Inventory (digital)
    private Integer availableCount;
    private Integer reservedCount;
    private Integer deliveredCount;
    private Integer expiredCount;
    private Integer expiringSoonCount; // Next 7 days
}
