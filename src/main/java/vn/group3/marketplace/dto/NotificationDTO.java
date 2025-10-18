package vn.group3.marketplace.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import vn.group3.marketplace.domain.enums.NotificationType;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class NotificationDTO {
    private Long id;
    private NotificationType type;
    private String title;
    private String content;
    private LocalDateTime createdAt;
    private LocalDateTime readAt;
}
