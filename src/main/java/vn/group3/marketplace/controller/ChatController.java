package vn.group3.marketplace.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import vn.group3.marketplace.security.CustomUserDetails;

@Controller
@RequestMapping("/chat")
public class ChatController {

    @Value("${firebase.api-key}")
    private String firebaseApiKey;

    @Value("${firebase.auth-domain}")
    private String firebaseAuthDomain;

    @Value("${firebase.project-id}")
    private String firebaseProjectId;

    @GetMapping
    public String chatPage(
            @AuthenticationPrincipal CustomUserDetails currentUser,
            @RequestParam(name = "chat-to", required = false) String chatTo,
            Model model) {
        if (currentUser == null) {
            return "redirect:/login?error=not_authenticated";
        }

        model.addAttribute("currentUser", currentUser);
        model.addAttribute("firebaseApiKey", firebaseApiKey);
        model.addAttribute("firebaseAuthDomain", firebaseAuthDomain);
        model.addAttribute("firebaseProjectId", firebaseProjectId);
        if (chatTo != null && !chatTo.isBlank()) {
            model.addAttribute("chatTo", chatTo);
        }
        return "chat/chatbox";
    }
}
