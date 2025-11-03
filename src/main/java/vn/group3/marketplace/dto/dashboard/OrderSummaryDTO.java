package vn.group3.marketplace.dto.dashboard;

import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import vn.group3.marketplace.domain.enums.OrderStatus;

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
    private String buyerName;

    // Escrow info
    private BigDecimal escrowHeld;
    private BigDecimal escrowReleased;
    private LocalDateTime escrowHoldUntil;
}
