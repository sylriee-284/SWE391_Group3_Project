package vn.group3.marketplace.controller;

import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import org.springframework.security.core.Authentication;
import org.springframework.http.ResponseEntity;
import java.util.Map;
import java.util.HashMap;

import vn.group3.marketplace.service.MessageService;
import vn.group3.marketplace.service.UserService;
import vn.group3.marketplace.domain.entity.Message;
import vn.group3.marketplace.domain.entity.User;

import java.util.List;
import java.util.Optional;

@Controller
public class ChatController {

    private final MessageService messageService;
    private final UserService userService;

    public ChatController(MessageService messageService, UserService userService) {
        this.messageService = messageService;
        this.userService = userService;
    }

    @GetMapping("/chat")
    public String chatPage(Model model, Authentication authentication,
            @RequestParam(value = "chat-to", required = false) String chatToUsername) {
        if (authentication == null || !authentication.isAuthenticated()) {
            return "redirect:/login";
        }

        // Get current user
        String username = authentication.getName();
        Optional<User> userOpt = userService.findByUsername(username);
        if (userOpt.isEmpty()) {
            return "redirect:/login";
        }
        User currentUser = userOpt.get();

        // Get all conversations for the current user
        List<Message> conversations = messageService.getConversations(currentUser.getId());

        // Get total unread count
        Long totalUnread = messageService.countTotalUnreadMessages(currentUser.getId());

        // Get messages for selected conversation or latest conversation
        List<Message> messages = null;
        User selectedUser = null;

        if (chatToUsername != null) {
            // Get messages for specific conversation
            Optional<User> selectedUserOpt = userService.findByUsername(chatToUsername);
            if (selectedUserOpt.isPresent()) {
                selectedUser = selectedUserOpt.get();
                messages = messageService.getLatestMessages(currentUser.getId(), selectedUser.getId());
                // Mark messages as read
                messageService.markAsRead(currentUser.getId(), selectedUser.getId());
            }
        } else if (!conversations.isEmpty()) {
            // Get messages for the most recent conversation
            Message latestConversation = conversations.get(0);
            User conversationPartner = messageService.getConversationPartner(latestConversation, currentUser.getId());
            messages = messageService.getLatestMessages(currentUser.getId(), conversationPartner.getId());
            selectedUser = conversationPartner;
            // Mark messages as read
            messageService.markAsRead(currentUser.getId(), conversationPartner.getId());
        }

        // Add data to model
        model.addAttribute("conversations", conversations);
        model.addAttribute("currentUser", currentUser);
        model.addAttribute("totalUnread", totalUnread);
        model.addAttribute("messages", messages);
        model.addAttribute("selectedUser", selectedUser);
        model.addAttribute("pageTitle", "Chat");
        model.addAttribute("messageService", messageService);

        return "chat/chatbox";
    }

    @GetMapping("/chat/admin")
    public String adminChatPage(Model model) {

        return "redirect:/chat?admin=true";
    }

    // REST API để gửi tin nhắn
    @PostMapping("/api/chat/send")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> sendMessage(
            @RequestBody Map<String, Object> request,
            Authentication authentication) {

        Map<String, Object> response = new HashMap<>();

        try {
            if (authentication == null || !authentication.isAuthenticated()) {
                response.put("success", false);
                response.put("message", "Chưa đăng nhập");
                return ResponseEntity.status(401).body(response);
            }

            // Lấy thông tin người gửi
            String username = authentication.getName();
            Optional<User> userOpt = userService.findByUsername(username);
            if (userOpt.isEmpty()) {
                response.put("success", false);
                response.put("message", "Không tìm thấy người dùng");
                return ResponseEntity.status(404).body(response);
            }
            User senderUser = userOpt.get();

            // Lấy thông tin từ request
            Long partnerUserId = Long.valueOf(request.get("partnerUserId").toString());
            String content = request.get("content").toString();

            // Gửi tin nhắn
            Message savedMessage = messageService.sendMessageToPartner(
                    senderUser.getId(),
                    partnerUserId,
                    content);

            response.put("success", true);
            response.put("message", "Tin nhắn đã được gửi");
            response.put("messageId", savedMessage.getId());
            response.put("timestamp", savedMessage.getCreatedAt());

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Lỗi khi gửi tin nhắn: " + e.getMessage());
            return ResponseEntity.status(500).body(response);
        }
    }

}
