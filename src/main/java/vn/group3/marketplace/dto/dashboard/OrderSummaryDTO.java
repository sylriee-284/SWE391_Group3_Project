package vn.group3.marketplace.dto.dashboard;

import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import vn.group3.marketplace.domain.enums.OrderStatus;
import vn.group3.marketplace.domain.enums.SellerStoresType;

/**
 * DTO for Order summary in Sales screen
 */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class OrderSummaryDTO {
    private Long orderId;
    private String orderCode;
    private LocalDateTime orderDate;
    private String productName;
    private Integer quantity;
    private BigDecimal totalAmount;
    private OrderStatus status;
    private String statusText; // Vietnamese translation of status
    private String buyerName;

    // Escrow info
    private BigDecimal escrowHeld;
    private BigDecimal escrowHeldAfterFee; // Amount seller will receive from held escrow (after commission deduction)
    private BigDecimal sellerAmount; // Seller amount from escrow_transactions (amount after fee deduction)
    private LocalDateTime escrowHoldUntil;
    private Boolean isReleased; // True if escrow status is RELEASED

    // Fee model info
    private SellerStoresType feeModel; // NO_FEE or PERCENTAGE
    private BigDecimal commissionRate; // Commission rate (e.g., 3.00 for 3%)
    private BigDecimal commissionAmount; // Actual commission amount in VND
}