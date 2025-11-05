package vn.group3.marketplace.dto;

import lombok.*;
import java.time.LocalDate;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DashboardFilterDTO {
    private String timeRange; // TODAY, LAST_7_DAYS, LAST_30_DAYS, CUSTOM
    private LocalDate startDate;
    private LocalDate endDate;
    private Long productId;
    private Long categoryId;

    public LocalDate getEffectiveStartDate() {
        if (startDate != null) {
            return startDate;
        }

        LocalDate now = LocalDate.now();
        return switch (timeRange != null ? timeRange : "LAST_7_DAYS") {
            case "TODAY" -> now;
            case "LAST_7_DAYS" -> now.minusDays(7);
            case "LAST_30_DAYS" -> now.minusDays(30);
            default -> now.minusDays(7);
        };
    }

    public LocalDate getEffectiveEndDate() {
        return endDate != null ? endDate : LocalDate.now();
    }
}
