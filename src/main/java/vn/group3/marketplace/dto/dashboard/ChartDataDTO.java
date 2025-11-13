package vn.group3.marketplace.dto.dashboard;

import lombok.*;
import java.util.List;

/**
 * DTO for Chart.js data
 */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ChartDataDTO {
    private List<String> labels;
    private List<DatasetDTO> datasets;

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class DatasetDTO {
        private String label;
        private List<Object> data; // Can be Number or String
        private String backgroundColor;
        private String borderColor;
        private Integer borderWidth;
    }
}
