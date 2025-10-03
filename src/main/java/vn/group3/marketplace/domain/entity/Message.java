package vn.group3.marketplace.domain.entity;

import jakarta.persistence.*;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "messages")
@Access(AccessType.FIELD)
public class Message extends BaseEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // Cặp hội thoại (đều FK tới users.id)
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "seller_user_id", nullable = false)
    private User sellerUser;

    // Người gửi (phải là 1 trong 2 bên ở trên; validate ở backend)
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "sender_user_id", nullable = false)
    private User senderUser;

    // Nội dung & idempotency
    @Column(nullable = false, columnDefinition = "TEXT")
    private String content;

    @Column(name = "client_msg_id", length = 100)
    private String clientMsgId;

}
