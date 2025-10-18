package vn.group3.marketplace.domain.entity;

import jakarta.persistence.*;
import lombok.*;
import vn.group3.marketplace.domain.enums.NotificationType;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "notifications")
@Access(AccessType.FIELD)
public class Notification extends BaseEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(length = 100, nullable = false)
    private NotificationType type;

    private String title;

    @Column(columnDefinition = "TEXT")
    private String content;

    @Column(name = "read_at")
    private java.time.LocalDateTime readAt;
}
