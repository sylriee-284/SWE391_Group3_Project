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
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class MessageService {
    private final MessageRepository messageRepository;
    private final UserRepository userRepository;

    // Save new message with idempotency check
    @Transactional
    public Message saveMessage(Long senderUserId, Long receiverUserId, String content, String clientMsgId) {
        // Validate message content
        if (content == null || content.trim().isEmpty()) {
            throw new IllegalArgumentException("Nội dung tin nhắn không được để trống");
        }

        // Check if message already exists (idempotency check)
        if (clientMsgId != null && !clientMsgId.isEmpty()) {
            Optional<Message> existing = messageRepository.findBySenderUser_IdAndClientMsgId(senderUserId, clientMsgId);
            if (existing.isPresent()) {
                return existing.get(); // Return existing message to prevent duplicate
            }
        }

        // Get sender user
        User senderUser = userRepository.findById(senderUserId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy người gửi"));

        // Get receiver user
        User receiverUser = userRepository.findById(receiverUserId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy người nhận"));

        // Determine conversation pair (user + sellerUser)
        User user = senderUser;
        User sellerUser = receiverUser;

        // Build and save message
        Message message = Message.builder()
                .user(user)
                .sellerUser(sellerUser)
                .senderUser(senderUser)
                .receiverUser(receiverUser)
                .content(content.trim())
                .clientMsgId(clientMsgId)
                .build();

        return messageRepository.save(message);
    }

    // Load latest messages (initial load)
    public List<Message> getLatestMessages(Long userId1, Long userId2, int limit) {
        Pageable pageable = PageRequest.of(0, limit);
        return messageRepository.findLatestMessages(userId1, userId2, pageable);
    }

    // Load older messages (scroll up - cursor pagination)
    public List<Message> getOlderMessages(Long userId1, Long userId2, Long cursorId, int limit) {
        Pageable pageable = PageRequest.of(0, limit);
        return messageRepository.findOlderMessages(userId1, userId2, cursorId, pageable);
    }

    // Get list of conversations (last message of each conversation)
    public List<Message> getConversations(Long userId) {
        return messageRepository.findConversationsForUser(userId);
    }

    // Count unread messages from a specific user
    public Long countUnreadMessages(Long userId, Long otherUserId) {
        return messageRepository.countUnreadMessages(userId, otherUserId);
    }

    // Count total unread messages (all conversations)
    public Long countTotalUnreadMessages(Long userId) {
        return messageRepository.countTotalUnreadMessages(userId);
    }

    // Mark messages as read
    @Transactional
    public int markAsRead(Long userId, Long otherUserId) {
        LocalDateTime readAt = LocalDateTime.now();
        return messageRepository.markAsRead(userId, otherUserId, readAt);
    }

    // Get message by ID
    public Optional<Message> getMessageById(Long messageId) {
        return messageRepository.findById(messageId);
    }
}
