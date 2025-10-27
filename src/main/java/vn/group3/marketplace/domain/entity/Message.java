package vn.group3.marketplace.domain.entity;

import java.time.LocalDateTime;

import jakarta.persistence.*;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "messages", indexes = {
        @Index(name = "idx_messages_pair_time", columnList = "user_id, seller_user_id, created_at DESC"),
        @Index(name = "idx_messages_pair_time_rev", columnList = "seller_user_id, user_id, created_at DESC"),
        @Index(name = "uq_sender_client_msg", columnList = "sender_user_id, client_msg_id", unique = true)
})
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

    // Người gửi và người nhận
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "sender_user_id", nullable = false)
    private User senderUser;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "receiver_user_id", nullable = false)
    private User receiverUser;

    // Nội dung & idempotency
    @Column(nullable = false, columnDefinition = "TEXT")
    private String content;

    @Column(name = "client_msg_id", length = 100)
    private String clientMsgId;

    @Column(name = "read_at")
    private LocalDateTime readAt;
}
