package vn.group3.marketplace.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import vn.group3.marketplace.domain.entity.Message;
import vn.group3.marketplace.domain.entity.User;

import vn.group3.marketplace.repository.MessageRepository;

import vn.group3.marketplace.repository.UserRepository;
import vn.group3.marketplace.security.CustomUserDetails;

import java.util.List;

@Controller
@RequiredArgsConstructor
public class ChatController {

    private final MessageRepository messageRepository;
    private final UserRepository userRepository;

    @GetMapping("/chat")
    public String chatPage(@RequestParam(value = "sellerId", required = false) Long sellerId,
            @RequestParam(value = "productId", required = false) Long productId,
            Model model) {
        model.addAttribute("sellerId", sellerId);
        model.addAttribute("productId", productId);
        return "chat/chatbox";
    }

    @GetMapping("/chat/messages")
    @ResponseBody
    public List<java.util.Map<String, Object>> loadMessages(@AuthenticationPrincipal CustomUserDetails currentUser,
            @RequestParam("sellerId") Long sellerId) {
        if (currentUser == null)
            return List.of();
        Long buyerUserId = currentUser.getId();
        // Load messages between buyer and seller
        List<Message> msgs = messageRepository.findMessagesBetweenUsers(buyerUserId, sellerId);
        java.util.List<java.util.Map<String, Object>> list = new java.util.ArrayList<>();
        for (Message m : msgs) {
            java.util.Map<String, Object> map = new java.util.HashMap<>();
            map.put("id", m.getId());
            map.put("content", m.getContent());
            map.put("createdAt", m.getCreatedAt() != null ? m.getCreatedAt().toString() : null);
            map.put("senderId", m.getSenderUser() != null ? m.getSenderUser().getId() : null);
            map.put("receiverId", m.getReceiverUser() != null ? m.getReceiverUser().getId() : null);
            list.add(map);
        }
        return list;
    }

    @PostMapping("/chat/send")
    @ResponseBody
    public java.util.Map<String, Object> sendMessageAjax(@AuthenticationPrincipal CustomUserDetails currentUser,
            @RequestParam Long sellerId,
            @RequestParam String message,
            @RequestParam(required = false) Long productId) {
        java.util.Map<String, Object> resp = new java.util.HashMap<>();
        if (currentUser == null) {
            resp.put("ok", false);
            resp.put("error", "Bạn cần đăng nhập để gửi tin.");
            return resp;
        }

        User sender = userRepository.findById(currentUser.getId()).orElse(null);
        User sellerUser = userRepository.findById(sellerId).orElse(null);
        if (sender == null || sellerUser == null) {
            resp.put("ok", false);
            resp.put("error", "Người nhận không hợp lệ.");
            return resp;
        }

        Message msg = Message.builder().user(sender).sellerUser(sellerUser).senderUser(sender).receiverUser(sellerUser)
                .content((productId != null ? "[Product:" + productId + "] " : "") + message).build();

        Message saved = messageRepository.save(msg);
        resp.put("ok", true);
        java.util.Map<String, Object> mm = new java.util.HashMap<>();
        mm.put("id", saved.getId());
        mm.put("content", saved.getContent());
        mm.put("createdAt", saved.getCreatedAt() != null ? saved.getCreatedAt().toString() : null);
        mm.put("senderId", saved.getSenderUser() != null ? saved.getSenderUser().getId() : null);
        mm.put("receiverId", saved.getReceiverUser() != null ? saved.getReceiverUser().getId() : null);
        resp.put("message", mm);
        return resp;
    }

}
