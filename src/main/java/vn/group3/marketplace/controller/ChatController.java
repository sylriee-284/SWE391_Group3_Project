package vn.group3.marketplace.controller;

import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import vn.group3.marketplace.service.MessageService;

@Controller
public class ChatController {

    @GetMapping("/chat")
    public String chatPage(Model model) {
        return "chat/chatbox";
    }

}
