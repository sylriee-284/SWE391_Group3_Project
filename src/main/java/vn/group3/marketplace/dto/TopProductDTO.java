package vn.group3.marketplace.dto;

import lombok.*;
import java.math.BigDecimal;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TopProductDTO {
    private Long productId;
    private String productName;
    private String categoryName;
    private BigDecimal totalRevenue;
    private Long totalUnits;
    private Integer currentStock;
    private BigDecimal productRating;
}
