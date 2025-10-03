package vn.group3.marketplace.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/chat")
public class ChatController {

    @GetMapping("")
    public String chatPage(Model model) {
        return "chat/chatbox";
    }

    @PostMapping("/send")
    public String sendMessage(
            @RequestParam("message") String message,
            @RequestParam(value = "image", required = false) MultipartFile image,
            RedirectAttributes redirectAttributes) {

        // Xử lý tin nhắn và ảnh ở đây
        System.out.println("Message: " + message);
        if (image != null && !image.isEmpty()) {
            System.out.println("Image: " + image.getOriginalFilename());
        }

        // Redirect về trang chat
        redirectAttributes.addFlashAttribute("successMessage", "Tin nhắn đã được gửi!");
        return "redirect:/chat";
    }
}
