package vn.group3.marketplace.dto;

import lombok.*;
import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DashboardAlertDTO {
    private String type; // LOW_STOCK, OUT_OF_STOCK, EXPIRING, PENDING_ORDER, REFUNDED_ORDER, SYSTEM
    private String severity; // HIGH, MEDIUM, LOW
    private String title;
    private String message;
    private String link;
    private LocalDateTime timestamp;
    private Long relatedId; // productId, orderId, etc.
}
