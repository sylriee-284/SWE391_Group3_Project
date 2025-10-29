package vn.group3.marketplace.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import vn.group3.marketplace.domain.entity.Message;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/**
 * DTO for WebSocket message data
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MessageDTO {

    @NotNull(message = "Sender user ID cannot be null")
    private Long senderUserId;

    @NotNull(message = "Receiver user ID cannot be null")
    private Long receiverUserId;

    @NotBlank(message = "Message content cannot be empty")
    @Size(max = 1000, message = "Message content cannot exceed 1000 characters")
    private String content;

    private Long timestamp;

    // Validation method
    public boolean isValid() {
        return senderUserId != null
                && receiverUserId != null
                && content != null
                && !content.trim().isEmpty()
                && content.length() <= 1000;
    }

    // Factory method for current timestamp
    public static MessageDTO create(Long senderUserId, Long receiverUserId, String content) {
        return MessageDTO.builder()
                .senderUserId(senderUserId)
                .receiverUserId(receiverUserId)
                .content(content)
                .timestamp(System.currentTimeMillis())
                .build();
    }

    // Factory method from Message entity
    public static MessageDTO fromMessage(Message message) {
        return MessageDTO.builder()
                .senderUserId(message.getSenderUser().getId())
                .receiverUserId(message.getReceiverUser().getId())
                .content(message.getContent())
                .timestamp(message.getCreatedAt() != null
                        ? message.getCreatedAt().atZone(java.time.ZoneId.systemDefault()).toInstant().toEpochMilli()
                        : System.currentTimeMillis())
                .build();
    }
}
