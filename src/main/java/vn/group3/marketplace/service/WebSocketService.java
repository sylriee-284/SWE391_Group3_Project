package vn.group3.marketplace.service;

import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import vn.group3.marketplace.dto.NotificationDTO;
import vn.group3.marketplace.domain.entity.Notification;
import vn.group3.marketplace.domain.entity.User;
import vn.group3.marketplace.domain.enums.NotificationType;
import vn.group3.marketplace.repository.NotificationRepository;

@Service
public class WebSocketService {

    private static final Logger logger = LoggerFactory.getLogger(WebSocketService.class);
    private static final String NOTIFICATION_DESTINATION = "/queue/notifications";

    private final SimpMessagingTemplate messagingTemplate;
    private final NotificationRepository notificationRepository;

    public WebSocketService(SimpMessagingTemplate messagingTemplate,
            NotificationRepository notificationRepository) {
        this.messagingTemplate = messagingTemplate;
        this.notificationRepository = notificationRepository;
    }

    // Create notification, save to DB and send via WebSocket (Async)
    @Async("notificationTaskExecutor")
    public void createAndSendNotification(User user, NotificationType type, String title, String content) {
        try {
            Notification notification = Notification.builder()
                    .user(user)
                    .type(type)
                    .title(title)
                    .content(content)
                    .build();

            notification.setCreatedBy(0L);
            notification = notificationRepository.save(notification);

            // Send notification via WebSocket
            sendNotificationToUser(user, notification);
            logger.info("Sent notification to user {} - {}", user.getId(), title);
        } catch (Exception e) {
            logger.error("Error creating notification for user {}: {}", user.getId(), e.getMessage());
        }
    }

    // Convert Notification entity to DTO
    private NotificationDTO convertToDTO(Notification notification) {
        return NotificationDTO.builder()
                .id(notification.getId())
                .type(notification.getType())
                .title(notification.getTitle())
                .content(notification.getContent())
                .createdAt(notification.getCreatedAt())
                .readAt(notification.getReadAt())
                .build();
    }

    // Send notification to a specific user
    public void sendNotificationToUser(Long userId, NotificationDTO notification) {
        try {
            String destination = "/user/" + userId + NOTIFICATION_DESTINATION;
            messagingTemplate.convertAndSend(destination, notification);
            logger.info("Sent notification to user {}: {}", userId, notification.getTitle());
        } catch (Exception e) {
            logger.error("Error sending notification to user {}: {}", userId, e.getMessage());
        }
    }

    // Send notification from Notification entity
    public void sendNotificationToUser(User user, Notification notification) {
        NotificationDTO dto = convertToDTO(notification);
        sendNotificationToUser(user.getId(), dto);
    }
}
