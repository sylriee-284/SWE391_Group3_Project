package vn.group3.marketplace.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import vn.group3.marketplace.domain.entity.Message;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * DTO for WebSocket message data
 * Optimized for JSON serialization and WebSocket transmission
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@JsonIgnoreProperties(ignoreUnknown = true)
public class MessageDTO implements Serializable {

    private static final long serialVersionUID = 1L;

    @JsonProperty("id")
    private Long id;

    @JsonProperty("senderUserId")
    @NotNull(message = "Sender user ID cannot be null")
    private Long senderUserId;

    @JsonProperty("receiverUserId")
    @NotNull(message = "Receiver user ID cannot be null")
    private Long receiverUserId;

    @JsonProperty("content")
    @NotBlank(message = "Message content cannot be empty")
    @Size(max = 1000, message = "Message content cannot exceed 1000 characters")
    private String content;

    @JsonProperty("timestamp")
    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", timezone = "UTC")
    private LocalDateTime timestamp;

    @JsonProperty("createdAt")
    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", timezone = "UTC")
    private LocalDateTime createdAt;

    @JsonProperty("readAt")
    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", timezone = "UTC")
    private LocalDateTime readAt;

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
        LocalDateTime now = LocalDateTime.now();
        return MessageDTO.builder()
                .senderUserId(senderUserId)
                .receiverUserId(receiverUserId)
                .content(content)
                .timestamp(now)
                .createdAt(now)
                .build();
    }

    // Factory method from Message entity
    public static MessageDTO fromMessage(Message message) {
        return MessageDTO.builder()
                .id(message.getId())
                .senderUserId(message.getSenderUser().getId())
                .receiverUserId(message.getReceiverUser().getId())
                .content(message.getContent())
                .timestamp(message.getCreatedAt())
                .createdAt(message.getCreatedAt())
                .readAt(message.getReadAt())
                .build();
    }

    // Helper method to get timestamp as milliseconds
    public long getTimestampMillis() {
        if (timestamp != null) {
            return timestamp.atZone(java.time.ZoneId.systemDefault()).toInstant().toEpochMilli();
        }
        return System.currentTimeMillis();
    }

    // Helper method to check if message is read
    public boolean isRead() {
        return readAt != null;
    }

    // Helper method to get formatted timestamp string
    public String getFormattedTimestamp() {
        if (timestamp != null) {
            return timestamp.format(java.time.format.DateTimeFormatter.ofPattern("HH:mm"));
        }
        return "";
    }
}
