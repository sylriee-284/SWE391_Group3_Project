package vn.group3.marketplace.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ConversationDTO {
    private String conversationId; // "buyerId_sellerId"
    private OtherUserDTO otherUser;
    private LastMessageDTO lastMessage;
    private Integer unreadCount;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class OtherUserDTO {
        private Long id;
        private String username;
        private String fullName;
        private String avatar;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class LastMessageDTO {
        private String content;
        private LocalDateTime createdAt;
        private Long senderId;
    }
}
