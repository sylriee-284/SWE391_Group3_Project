package vn.group3.marketplace.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CloseStoreResultDTO {
    private boolean ok;
    private String status;
    private BigDecimal depositRefund;
    private BigDecimal walletBalanceAfter;
}
