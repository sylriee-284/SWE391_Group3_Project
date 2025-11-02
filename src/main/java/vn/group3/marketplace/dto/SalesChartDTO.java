package vn.group3.marketplace.dto;

import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SalesChartDTO {
    private List<DataPoint> dataPoints;

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class DataPoint {
        private String label; // Date/Week/Month
        private LocalDate date;
        private BigDecimal revenue;
        private Long orderCount;
        private Long refundCount;
        private Long cancelCount;
    }
}
