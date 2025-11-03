package vn.group3.marketplace.dto.dashboard;

import lombok.*;
import java.time.LocalDateTime;

/**
 * DTO for Alert/Warning messages
 */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AlertDTO {
    private String type; // "low-stock", "expired-soon", "order-issue", "system-event"
    private String severity; // "high", "medium", "low"
    private String title;
    private String message;
    private Long productId;
    private Long orderId;
    private LocalDateTime timestamp;
}
