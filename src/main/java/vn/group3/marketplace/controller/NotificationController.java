package vn.group3.marketplace.controller;

import vn.group3.marketplace.service.NotificationService;
import vn.group3.marketplace.domain.entity.Notification;
import vn.group3.marketplace.dto.NotificationDTO;
import vn.group3.marketplace.security.CustomUserDetails;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.http.ResponseEntity;

import java.util.List;

@RestController
@RequestMapping("/api/notifications")
public class NotificationController {

    private final NotificationService notificationService;

    public NotificationController(NotificationService notificationService) {
        this.notificationService = notificationService;
    }

    @GetMapping("/recent")
    public ResponseEntity<List<Notification>> getRecentNotifications(
            @AuthenticationPrincipal CustomUserDetails currentUser) {
        List<Notification> notifications = notificationService.getRecentNotificationsByUser(currentUser.getUser());
        return ResponseEntity.ok(notifications);
    }

    @GetMapping("/latest")
    public ResponseEntity<NotificationDTO> getLatestUnreadNotification(
            @AuthenticationPrincipal CustomUserDetails currentUser) {
        if (currentUser == null) {
            return ResponseEntity.ok(null);
        }

        NotificationDTO notification = notificationService.getLatestUnreadNotificationDTOByUser(currentUser.getUser());
        return ResponseEntity.ok(notification);
    }

    @PostMapping("/mark-read/{notificationId}")
    public ResponseEntity<String> markNotificationAsRead(@PathVariable Long notificationId) {
        try {
            notificationService.markNotificationAsRead(notificationId);
            return ResponseEntity.ok("Notification marked as read");
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Error marking notification as read: " + e.getMessage());
        }
    }

}
