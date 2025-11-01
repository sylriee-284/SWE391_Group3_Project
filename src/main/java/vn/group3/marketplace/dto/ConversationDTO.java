package vn.group3.marketplace.dto;

import lombok.*;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ConversationDTO {

    private String id;
    private List<Long> participants;
    private Object createdAt;
    private Object lastMessageAt;
    private String lastMessage;

    // Additional fields enriched at runtime
    private Long conversationPartnerId;
    private String conversationPartnerName;
    private String partnerUsername;
}
