package vn.group3.marketplace.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.group3.marketplace.domain.dto.ConversationDTO;
import vn.group3.marketplace.domain.entity.Message;
import vn.group3.marketplace.domain.entity.User;
import vn.group3.marketplace.repository.MessageRepository;
import vn.group3.marketplace.repository.UserRepository;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ConversationService {

    private final MessageRepository messageRepository;
    private final UserRepository userRepository;

    /**
     * Get all conversations for the current user
     * 
     * @param currentUserId ID of the current logged-in user
     * @return List of conversations with last message and unread count
     */
    public List<ConversationDTO> getConversations(Long currentUserId) {
        // Get all messages where current user is sender or receiver
        List<Message> allMessages = messageRepository.findAll().stream()
                .filter(m -> (m.getSenderUser() != null && m.getSenderUser().getId().equals(currentUserId)) ||
                        (m.getReceiverUser() != null && m.getReceiverUser().getId().equals(currentUserId)))
                .collect(Collectors.toList());

        // Group messages by conversation (other user)
        Map<Long, List<Message>> conversationMap = new HashMap<>();

        for (Message msg : allMessages) {
            Long otherUserId = null;
            if (msg.getSenderUser() != null && msg.getSenderUser().getId().equals(currentUserId)) {
                // Current user is sender, other user is receiver
                otherUserId = msg.getReceiverUser() != null ? msg.getReceiverUser().getId() : null;
            } else if (msg.getReceiverUser() != null && msg.getReceiverUser().getId().equals(currentUserId)) {
                // Current user is receiver, other user is sender
                otherUserId = msg.getSenderUser() != null ? msg.getSenderUser().getId() : null;
            }

            if (otherUserId != null) {
                conversationMap.computeIfAbsent(otherUserId, k -> new ArrayList<>()).add(msg);
            }
        }

        // Build ConversationDTO for each conversation
        List<ConversationDTO> conversations = new ArrayList<>();

        for (Map.Entry<Long, List<Message>> entry : conversationMap.entrySet()) {
            Long otherUserId = entry.getKey();
            List<Message> messages = entry.getValue();

            // Sort messages by createdAt descending to get the latest
            messages.sort((m1, m2) -> {
                if (m1.getCreatedAt() == null && m2.getCreatedAt() == null)
                    return 0;
                if (m1.getCreatedAt() == null)
                    return 1;
                if (m2.getCreatedAt() == null)
                    return -1;
                return m2.getCreatedAt().compareTo(m1.getCreatedAt());
            });

            Message lastMessage = messages.get(0);

            // Get other user details
            User otherUser = userRepository.findById(otherUserId).orElse(null);
            if (otherUser == null)
                continue;

            // Calculate unread count (messages sent by other user that current user hasn't
            // read)
            // For now, we'll set it to 0 since we don't have read status tracking yet
            int unreadCount = 0;

            // Build conversation ID (always smaller ID first for consistency)
            String conversationId = currentUserId < otherUserId
                    ? currentUserId + "_" + otherUserId
                    : otherUserId + "_" + currentUserId;

            // Generate avatar URL using UI Avatars API (initials-based avatar)
            String displayName = otherUser.getFullName() != null ? otherUser.getFullName() : otherUser.getUsername();
            String avatarUrl = "https://ui-avatars.com/api/?name=" + displayName.replace(" ", "+")
                    + "&background=random&color=fff&size=128&rounded=true";

            ConversationDTO conversation = ConversationDTO.builder()
                    .conversationId(conversationId)
                    .otherUser(ConversationDTO.OtherUserDTO.builder()
                            .id(otherUser.getId())
                            .username(otherUser.getUsername())
                            .fullName(otherUser.getFullName())
                            .avatar(avatarUrl)
                            .build())
                    .lastMessage(ConversationDTO.LastMessageDTO.builder()
                            .content(lastMessage.getContent())
                            .createdAt(lastMessage.getCreatedAt())
                            .senderId(lastMessage.getSenderUser() != null ? lastMessage.getSenderUser().getId() : null)
                            .build())
                    .unreadCount(unreadCount)
                    .build();

            conversations.add(conversation);
        }

        // Sort conversations by last message time (most recent first)
        conversations.sort((c1, c2) -> {
            LocalDateTime t1 = c1.getLastMessage() != null ? c1.getLastMessage().getCreatedAt() : null;
            LocalDateTime t2 = c2.getLastMessage() != null ? c2.getLastMessage().getCreatedAt() : null;
            if (t1 == null && t2 == null)
                return 0;
            if (t1 == null)
                return 1;
            if (t2 == null)
                return -1;
            return t2.compareTo(t1);
        });

        return conversations;
    }
}
