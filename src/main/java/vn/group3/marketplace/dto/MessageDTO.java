package vn.group3.marketplace.dto;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MessageDTO {

    private String id;
    private String conversationId;
    private Long senderId;
    private Long receiverId;
    private String content;
    private Object timestamp;
    private Boolean read;

    // Additional fields for display
    private String senderName;
    private String receiverName;
}
