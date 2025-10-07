package vn.group3.marketplace.service;

import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import vn.group3.marketplace.domain.entity.Message;
import vn.group3.marketplace.domain.entity.User;
import vn.group3.marketplace.repository.MessageRepository;
import vn.group3.marketplace.repository.UserRepository;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class MessageService {
    // private final MessageRepository messageRepository;
    // private final UserRepository userRepository;

    // // Save new message
    // public Message save(Message message) {
    // if (message.getContent() == null || message.getContent().trim().isEmpty()) {
    // throw new IllegalArgumentException("Message content cannot be empty");
    // }
    // if (message.getSenderUser() == null) {
    // throw new IllegalArgumentException("Sender user cannot be null");
    // }
    // if (message.getReceiverUser() == null) {
    // throw new IllegalArgumentException("Receiver user cannot be null");
    // }

    // User user = determineUser(message);
    // User sellerUser = determineSellerUser(message);

    // Message msg = Message.builder()
    // .user(user)
    // .sellerUser(sellerUser)
    // .senderUser(message.getSenderUser())
    // .receiverUser(message.getReceiverUser())
    // .content(message.getContent().trim())
    // .clientMsgId(message.getClientMsgId())
    // .createdBy(message.getSenderUser().getId())
    // .build();

    // return messageRepository.save(msg);
    // }

    // // Get all messages between two users
    // public List<Message> getMessagesBetweenUsers(Long userId, Long otherUserId) {
    // return messageRepository.findMessagesBetweenUsers(userId, otherUserId);
    // }

    // // Load older messages (scroll up)
    // public List<Message> getOlderMessages(Long userId, Long otherUserId, Long
    // lastMessageId, int limit) {
    // Pageable pageable = PageRequest.of(0, limit);
    // return messageRepository.findMessagesBetweenUsersWithCursor(userId,
    // otherUserId, lastMessageId, pageable);
    // }

    // // Load newer messages (real-time)
    // public List<Message> getNewerMessages(Long userId, Long otherUserId, Long
    // lastMessageId, int limit) {
    // Pageable pageable = PageRequest.of(0, limit);
    // return messageRepository.findMessagesBetweenUsersWithCursorAsc(userId,
    // otherUserId, lastMessageId, pageable);
    // }

    // // Get conversation list
    // public List<Message> getConversationsForUser(Long userId) {
    // return messageRepository.findRecentConversationsForUser(userId);
    // }

    // // Get message by ID
    // public Optional<Message> getMessageById(Long messageId) {
    // return messageRepository.findById(messageId);
    // }

    // // Determine regular user (not seller)
    // private User determineUser(Message message) {
    // return message.getSenderUser();
    // }

    // // Determine seller
    // private User determineSellerUser(Message message) {
    // return message.getReceiverUser();
    // }
}
