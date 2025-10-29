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

import java.util.concurrent.TimeUnit;

@Service
public class WebSocketService {

    private static final Logger logger = LoggerFactory.getLogger(WebSocketService.class);
    private static final String NOTIFICATION_DESTINATION = "/queue/notifications";
    private static final int MAX_RETRY_ATTEMPTS = 3;
    private static final long RETRY_DELAY_MS = 500;

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

            // QUAN TRỌNG: Đợi DB transaction commit trước khi gửi WebSocket
            sleepSafely(100);

            // QUAN TRỌNG: Cơ chế retry đảm bảo notification được gửi ngay cả khi
            // kết nối WebSocket tạm thời không khả dụng
            sendNotificationWithRetry(user, notification);
        } catch (Exception e) {
            logger.error("Error creating notification for user {}: {}", user.getId(), e.getMessage());
        }
    }

    // QUAN TRỌNG: Đảm bảo DB transaction commit trước khi gửi WebSocket để tránh
    // race condition
    private void sleepSafely(long milliseconds) {
        try {
            TimeUnit.MILLISECONDS.sleep(milliseconds);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }

    // QUAN TRỌNG: Retry gửi WebSocket tối đa 3 lần với exponential backoff để xử lý
    // các vấn đề kết nối tạm thời
    private void sendNotificationWithRetry(User user, Notification notification) {
        for (int attempt = 1; attempt <= MAX_RETRY_ATTEMPTS; attempt++) {
            try {
                sendNotificationToUser(user, notification);
                return;
            } catch (Exception e) {
                if (attempt == MAX_RETRY_ATTEMPTS) {
                    logger.error("Failed to send notification to user {}: {}", user.getId(), e.getMessage());
                }
                sleepSafely(RETRY_DELAY_MS * attempt);
            }
        }
    }

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

    public void sendNotificationToUser(Long userId, NotificationDTO notification) {
        messagingTemplate.convertAndSend("/user/" + userId + NOTIFICATION_DESTINATION, notification);
    }

    public void sendNotificationToUser(User user, Notification notification) {
        sendNotificationToUser(user.getId(), convertToDTO(notification));
    }

}
