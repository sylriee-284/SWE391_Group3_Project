package vn.group3.marketplace.controller;

import vn.group3.marketplace.service.NotificationService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/notifications")
public class NotificationController {
    private final NotificationService notificationService;

    public NotificationController(NotificationService notificationService) {
        this.notificationService = notificationService;
    }

    @GetMapping("/{userId}")
    public String listNotifications(@PathVariable Long userId, Model model) {
        // model.addAttribute("notifications", notificationService.findByUser(userId));
        return "notification/list";
    }
}
