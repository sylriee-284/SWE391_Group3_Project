package vn.group3.marketplace.service;

import org.springframework.stereotype.Service;

import vn.group3.marketplace.domain.entity.Notification;
import vn.group3.marketplace.domain.entity.User;
import vn.group3.marketplace.domain.enums.NotificationType;
import vn.group3.marketplace.repository.NotificationRepository;
import vn.group3.marketplace.dto.NotificationDTO;

import java.util.List;
import java.time.LocalDateTime;

@Service
public class NotificationService {

    private final NotificationRepository notificationRepository;

    public NotificationService(NotificationRepository notificationRepository) {
        this.notificationRepository = notificationRepository;
    }

    // Create notification
    public void createNotification(User user, NotificationType type, String title, String content) {
        Notification notification = Notification.builder()
                .user(user)
                .type(type)
                .title(title)
                .content(content)
                .build();

        // Set createdBy as system (0) for notifications
        notification.setCreatedBy(0L);

        notificationRepository.save(notification);
    }

    // Get notifications by id
    public Notification getNotificationsById(Long id) {
        return notificationRepository.findById(id).orElseThrow(() -> new RuntimeException("Notification not found"));
    }

    // Get latest notification by user
    public Notification getLatestNotificationByUser(User user) {
        return notificationRepository.findTopByUserOrderByCreatedAtDesc(user).orElse(null);
    }

    // Get recent notifications by user (last 10 notifications)
    public List<Notification> getRecentNotificationsByUser(User user) {
        return notificationRepository.findByUserOrderByCreatedAtDesc(user)
                .stream()
                .limit(10)
                .toList();
    }

    // Get latest unread notification by user
    public Notification getLatestUnreadNotificationByUser(User user) {
        return notificationRepository.findTopByUserAndReadAtIsNullOrderByCreatedAtDesc(user).orElse(null);
    }

    // Get latest unread notification DTO by user
    public NotificationDTO getLatestUnreadNotificationDTOByUser(User user) {
        return notificationRepository.findTopByUserAndReadAtIsNullOrderByCreatedAtDesc(user)
                .map(this::convertToDTO).orElse(null);
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

    // Get all unread notifications by user
    public List<Notification> getUnreadNotificationsByUser(User user) {
        return notificationRepository.findByUserAndReadAtIsNullOrderByCreatedAtDesc(user);
    }

    // Mark notification as read
    public void markNotificationAsRead(Long notificationId) {
        Notification notification = notificationRepository.findById(notificationId)
                .orElseThrow(() -> new RuntimeException("Notification not found"));
        notification.setReadAt(LocalDateTime.now());
        notificationRepository.save(notification);
    }

    // Mark notification as read by notification object
    public void markNotificationAsRead(Notification notification) {
        notification.setReadAt(LocalDateTime.now());
        notificationRepository.save(notification);
    }

}
