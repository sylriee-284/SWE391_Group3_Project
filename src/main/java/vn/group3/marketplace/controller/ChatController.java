package vn.group3.marketplace.controller;

import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.http.ResponseEntity;
import java.util.Map;
import java.util.HashMap;

import vn.group3.marketplace.service.FirebaseChatService;
import vn.group3.marketplace.service.UserService;
import vn.group3.marketplace.domain.entity.Message;
import vn.group3.marketplace.domain.entity.User;
import vn.group3.marketplace.security.CustomUserDetails;

import java.util.List;
import java.util.Optional;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
@RequestMapping("/chat")
public class ChatController {
    private final FirebaseChatService firebaseChatService;

    public ChatController(FirebaseChatService firebaseChatService) {
        this.firebaseChatService = firebaseChatService;
    }

    // Show chat page
    @GetMapping
    public String chatPage() {
        return "chat/chatbox";
    }

    // Create or show conversation
    @PostMapping("/api/conversation")
    @ResponseBody
    public ResponseEntity<?> getOrCreateConversation(
            @AuthenticationPrincipal CustomUserDetails currentUser,
            @RequestParam Long otherUserId) {
        try {
            String conversationId = firebaseChatService.getOrCreateConversation(
                    currentUser.getId(),
                    otherUserId);
            return ResponseEntity.ok(Map.of("conversationId", conversationId));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
}
