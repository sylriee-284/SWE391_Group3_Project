package vn.group3.marketplace.controller;

import vn.group3.marketplace.service.ChatService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/chat")
public class ChatController {
    private final ChatService chatService;

    public ChatController(ChatService chatService) {
        this.chatService = chatService;
    }

    @GetMapping("/{conversationId}")
    public String viewConversation(@PathVariable Long conversationId, Model model) {
        // model.addAttribute("messages", chatService.getMessages(conversationId));
        return "chat/conversation";
    }
}
