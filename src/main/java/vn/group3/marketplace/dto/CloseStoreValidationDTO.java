package vn.group3.marketplace.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CloseStoreValidationDTO {
    private boolean ok;
    private String ruleApplied; // "NO_FEE" | "GE_12M" | "LT_12M"
    private BigDecimal depositRefund;
    private List<ValidationError> errors;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ValidationError {
        private String code;
        private String message;
        private String link;
    }
}
