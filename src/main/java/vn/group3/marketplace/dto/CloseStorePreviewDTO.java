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
public class CloseStorePreviewDTO {
    private Long storeId;
    private String storeName;
    private String status;
    private String createdAt;
    private String feeModel;
    private BigDecimal depositAmount;
    private Integer openMonths;
    private Long pendingOrders;
    private Long pendingRefunds; // Always 0 for now (future feature)
    private BigDecimal escrowHeld;
    private BigDecimal walletBalance;
}
