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
}
