package vn.group3.marketplace.service;

import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.group3.marketplace.domain.entity.Message;
import vn.group3.marketplace.domain.entity.User;
import vn.group3.marketplace.repository.MessageRepository;
import vn.group3.marketplace.repository.UserRepository;

import java.time.LocalDateTime;
import java.util.Collections;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class MessageService {
    private static final int DEFAULT_MESSAGE_LIMIT = 20;
    private static final String DEFAULT_WELCOME_MESSAGE = "Xin chào! Chúng tôi rất vui được hỗ trợ bạn. Hãy cho chúng tôi biết bạn cần giúp gì nhé!";

    private final MessageRepository messageRepository;
    private final UserRepository userRepository;
    private final SystemSettingService systemSettingService;
    private final WebSocketService webSocketService;

    // Lưu tin nhắn mới với kiểm tra trùng lặp
    @Transactional
    public Message saveMessage(Long senderUserId, Long receiverUserId, String content, String clientMsgId) {
        // Kiểm tra tin nhắn đã tồn tại (idempotency check)
        if (clientMsgId != null && !clientMsgId.isEmpty()) {
            Optional<Message> existing = messageRepository.findBySenderUser_IdAndClientMsgId(senderUserId, clientMsgId);
            if (existing.isPresent()) {
                return existing.get(); // Trả về tin nhắn đã có để tránh duplicate
            }
        }

        // Sử dụng method chung để tạo và lưu tin nhắn
        return createAndSaveMessage(senderUserId, receiverUserId, content, clientMsgId);
    }

    // Gửi tin nhắn tới conversation partner (method đơn giản)
    @Transactional
    public Message sendMessageToPartner(Long senderUserId, Long partnerUserId, String content) {
        // Sử dụng method chung để tạo và lưu tin nhắn (không có clientMsgId)
        return createAndSaveMessage(senderUserId, partnerUserId, content, null);
    }

    // Method private chung để tạo và lưu tin nhắn
    private Message createAndSaveMessage(Long senderUserId, Long receiverUserId, String content, String clientMsgId) {
        // Kiểm tra nội dung tin nhắn
        if (content == null || content.trim().isEmpty()) {
            throw new IllegalArgumentException("Nội dung tin nhắn không được để trống");
        }

        // Lấy thông tin người gửi
        User senderUser = userRepository.findById(senderUserId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy người gửi"));

        // Lấy thông tin người nhận
        User receiverUser = userRepository.findById(receiverUserId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy người nhận"));

        // Xác định cặp conversation để đảm bảo tính nhất quán
        User user;
        User sellerUser;

        if (senderUser.getSellerStore() != null && receiverUser.getSellerStore() == null) {
            // Người gửi là seller, người nhận là user thường
            user = receiverUser;
            sellerUser = senderUser;
        } else if (senderUser.getSellerStore() == null && receiverUser.getSellerStore() != null) {
            // Người gửi là user thường, người nhận là seller
            user = senderUser;
            sellerUser = receiverUser;
        } else {
            // Cả hai đều là seller - dùng ID để đảm bảo tính nhất quán (user = ID nhỏ hơn,
            // sellerUser = ID lớn hơn)
            // Điều này đảm bảo cùng một conversation luôn có cùng thứ tự cặp
            if (senderUser.getId() < receiverUser.getId()) {
                user = senderUser;
                sellerUser = receiverUser;
            } else {
                user = receiverUser;
                sellerUser = senderUser;
            }
        }

        // Tạo và lưu tin nhắn
        Message message = Message.builder()
                .user(user)
                .sellerUser(sellerUser)
                .senderUser(senderUser)
                .receiverUser(receiverUser)
                .content(content.trim())
                .clientMsgId(clientMsgId)
                .build();

        Message savedMessage = messageRepository.save(message);

        // Gửi tin nhắn qua WebSocket tới conversation partner
        webSocketService.sendMessageToPartner(savedMessage);

        return savedMessage;
    }

    // Lấy tin nhắn mới nhất (load ban đầu) - mặc định 20 tin nhắn
    public List<Message> getLatestMessages(Long userId1, Long userId2) {
        Pageable pageable = PageRequest.of(0, DEFAULT_MESSAGE_LIMIT);
        List<Message> messages = messageRepository.findLatestMessages(userId1, userId2, pageable);
        // Đảo ngược để hiển thị từ cũ đến mới (tin nhắn mới nhất ở cuối)
        Collections.reverse(messages);
        return messages;
    }

    // Lấy tin nhắn cũ hơn (scroll up - cursor pagination) - mặc định 20 tin nhắn
    public List<Message> getOlderMessages(Long userId1, Long userId2, Long cursorId) {
        Pageable pageable = PageRequest.of(0, DEFAULT_MESSAGE_LIMIT);
        List<Message> messages = messageRepository.findOlderMessages(userId1, userId2, cursorId, pageable);
        // Đảo ngược thứ tự để tin nhắn cũ ở trên, tin nhắn mới ở dưới
        Collections.reverse(messages);
        return messages;
    }

    // Lấy danh sách conversations (tin nhắn cuối mỗi conversation)
    public List<Message> getConversations(Long userId) {
        return messageRepository.findConversationsForUser(userId);
    }

    // Đếm tin nhắn chưa đọc từ một user cụ thể
    public Long countUnreadMessages(Long userId, Long otherUserId) {
        return messageRepository.countUnreadMessages(userId, otherUserId);
    }

    // Đếm tổng tin nhắn chưa đọc (tất cả conversations)
    public Long countTotalUnreadMessages(Long userId) {
        return messageRepository.countTotalUnreadMessages(userId);
    }

    // Đánh dấu tin nhắn đã đọc
    @Transactional
    public int markAsRead(Long userId, Long otherUserId) {
        LocalDateTime readAt = LocalDateTime.now();
        return messageRepository.markAsRead(userId, otherUserId, readAt);
    }

    // Lấy tin nhắn theo ID
    public Optional<Message> getMessageById(Long messageId) {
        return messageRepository.findById(messageId);
    }

    // Kiểm tra conversation đã tồn tại giữa hai user
    public boolean checkConversationExists(Long userId1, Long userId2) {
        List<Message> messages = messageRepository.findLatestMessages(userId1, userId2, Pageable.ofSize(1));
        return !messages.isEmpty();
    }

    // Tạo tin nhắn chào mừng từ admin cho user mới (gọi khi đăng ký)
    @Transactional
    public void createWelcomeMessageForNewUser(Long userId) {
        // Lấy admin user ID từ system setting
        String adminIdStr = systemSettingService.getSettingValue("wallet.admin_default_receive_commission", "");
        if (adminIdStr == null || adminIdStr.isEmpty()) {
            return;
        }
        Long adminId = Long.parseLong(adminIdStr);

        // Tạo tin nhắn chào mừng với clientMsgId duy nhất
        String systemMsgId = "WELCOME_" + userId;
        saveMessage(adminId, userId, DEFAULT_WELCOME_MESSAGE, systemMsgId);
    }

    // Lấy thông tin người chat đối diện
    public User getConversationPartner(Message message, Long currentUserId) {
        if (message.getUser().getId().equals(currentUserId)) {
            return message.getSellerUser();
        } else {
            return message.getUser();
        }
    }

    // Lấy preview tin nhắn (cắt ngắn nội dung)
    public String getConversationPreview(Message message, Long currentUserId) {
        String content = message.getContent();
        if (content.length() > 50) {
            return content.substring(0, 47) + "...";
        }
        return content;
    }

    // Format thời gian tin nhắn để hiển thị
    public String formatMessageTime(java.time.LocalDateTime dateTime) {
        if (dateTime == null)
            return "";

        java.time.LocalDate today = java.time.LocalDate.now();
        java.time.LocalDate messageDate = dateTime.toLocalDate();

        if (messageDate.equals(today)) {
            return dateTime.format(java.time.format.DateTimeFormatter.ofPattern("HH:mm"));
        } else if (messageDate.equals(today.minusDays(1))) {
            return "Hôm qua " + dateTime.format(java.time.format.DateTimeFormatter.ofPattern("HH:mm"));
        } else {
            return dateTime.format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));
        }
    }

    // Lấy đường dẫn avatar của user
    public String getUserAvatarPath(User user) {
        // Kiểm tra nếu là admin
        if (isAdminUser(user)) {
            return "/images/chat/mmo-avatar.jpg";
        } else {
            return "/images/chat/mmo-user.jpg";
        }
    }

    // Kiểm tra user có phải admin không
    public boolean isAdminUser(User user) {
        try {
            String adminIdStr = systemSettingService.getSettingValue("wallet.admin_default_receive_commission", "");
            if (adminIdStr == null || adminIdStr.isEmpty()) {
                return false;
            }
            Long adminId = Long.parseLong(adminIdStr);
            return user.getId().equals(adminId);
        } catch (NumberFormatException e) {
            return false;
        }
    }

    // Lấy tên hiển thị của user
    public String getUserDisplayName(User user) {
        if (user.getFullName() != null && !user.getFullName().trim().isEmpty()) {
            return user.getFullName();
        } else {
            return user.getUsername();
        }
    }

}
