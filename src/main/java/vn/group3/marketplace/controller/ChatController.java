package vn.group3.marketplace.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.http.ResponseEntity;
import java.util.Map;

import vn.group3.marketplace.dto.ConversationDTO;
import vn.group3.marketplace.dto.MessageDTO;
import vn.group3.marketplace.service.FirebaseChatService;
import vn.group3.marketplace.security.CustomUserDetails;

import java.util.List;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import com.google.cloud.firestore.DocumentSnapshot;

@Controller
@RequestMapping("/chat")
public class ChatController {
    private final FirebaseChatService firebaseChatService;

    public ChatController(FirebaseChatService firebaseChatService) {
        this.firebaseChatService = firebaseChatService;
    }

    // Show chat page
    @GetMapping
    public String chatPage(
            @AuthenticationPrincipal CustomUserDetails currentUser,
            @RequestParam(name = "chat-to", required = false) String conversationPartnerName,
            Model model) {
        if (currentUser == null) {
            return "redirect:/login?error=not_authenticated";
        }

        try {
            // Get all conversations
            List<ConversationDTO> conversations = firebaseChatService.getUserConversations(currentUser.getId());

            // Determine which conversation to display
            ConversationDTO selectedConversation = null;
            List<MessageDTO> messages = null;

            if (conversationPartnerName != null && !conversationPartnerName.isEmpty()) {
                // User selected a specific conversation
                String conversationId = firebaseChatService.getOrCreateConversationByPartnerName(currentUser.getId(),
                        conversationPartnerName);
                selectedConversation = conversations.stream()
                        .filter(c -> conversationId.equals(c.getId()))
                        .findFirst()
                        .orElse(null);
            }

            // If no conversation selected or not found, use last conversation
            if (selectedConversation == null) {
                selectedConversation = firebaseChatService.getLastConversation(currentUser.getId());
            }

            // Load messages if conversation exists
            if (selectedConversation != null && selectedConversation.getId() != null) {
                messages = firebaseChatService.getMessages(selectedConversation.getId(), 20);
            }

            model.addAttribute("currentUser", currentUser);
            model.addAttribute("conversations", conversations);
            model.addAttribute("lastConversation", selectedConversation);
            model.addAttribute("lastConversationChat", messages);

            return "chat/chatbox";
        } catch (Exception e) {
            e.printStackTrace();
            model.addAttribute("errorMessage", "Error loading chat: " + e.getMessage());
            return "chat/chatbox";
        }
    }

    // Get conversations list
    @GetMapping("/api/conversations/list")
    @ResponseBody
    public ResponseEntity<?> getUserConversations(@AuthenticationPrincipal CustomUserDetails currentUser) {
        try {
            List<ConversationDTO> conversations = firebaseChatService.getUserConversations(
                    currentUser.getId());
            return ResponseEntity.ok(conversations);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    // Get messages from conversation
    @GetMapping("/api/messages/{conversationId}")
    @ResponseBody
    public ResponseEntity<?> getMessages(
            @PathVariable String conversationId,
            @RequestParam(defaultValue = "20") int limit) {
        try {
            List<MessageDTO> messages = firebaseChatService.getMessages(conversationId, limit);
            return ResponseEntity.ok(messages);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    // Send message
    @PostMapping("/api/message")
    @ResponseBody
    public ResponseEntity<?> sendMessage(
            @AuthenticationPrincipal CustomUserDetails currentUser,
            @RequestBody Map<String, Object> payload) {
        try {
            String conversationId = (String) payload.get("conversationId");
            Long receiverId = Long.valueOf(payload.get("receiverId").toString());
            String content = (String) payload.get("content");

            String messageId = firebaseChatService.sendMessage(
                    conversationId,
                    currentUser.getId(),
                    receiverId,
                    content);

            return ResponseEntity.ok(Map.of("messageId", messageId));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    // Mark messages as read
    @PostMapping("/api/messages/{conversationId}/read")
    @ResponseBody
    public ResponseEntity<?> markAsRead(
            @AuthenticationPrincipal CustomUserDetails currentUser,
            @PathVariable String conversationId) {
        try {
            firebaseChatService.markMessagesAsRead(conversationId, currentUser.getId());
            return ResponseEntity.ok(Map.of("success", true));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    // Get unread message count
    @GetMapping("/api/unread-count")
    @ResponseBody
    public ResponseEntity<?> getUnreadCount(@AuthenticationPrincipal CustomUserDetails currentUser) {
        try {
            long count = firebaseChatService.getUnreadMessageCount(currentUser.getId());
            return ResponseEntity.ok(Map.of("count", count));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    // Get older messages
    @GetMapping("/api/messages/{conversationId}/older")
    @ResponseBody
    public ResponseEntity<?> getOlderMessages(
            @PathVariable String conversationId,
            @RequestParam(defaultValue = "20") int pageSize,
            @RequestParam(defaultValue = "0") DocumentSnapshot lastDoc) {
        try {
            List<MessageDTO> messages = firebaseChatService.getOlderMessages(conversationId, pageSize,
                    lastDoc);
            return ResponseEntity.ok(messages);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
}
