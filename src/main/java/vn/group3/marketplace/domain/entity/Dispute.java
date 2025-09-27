package vn.group3.marketplace.domain.entity;

import jakarta.persistence.*;
import lombok.*;
import vn.group3.marketplace.domain.enums.DisputeStatus;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "disputes")
@Access(AccessType.FIELD)
public class Dispute extends BaseEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "order_id", nullable = false)
    private Order order;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "opened_by_user_id", nullable = false)
    private User openedBy;

    @Enumerated(EnumType.STRING)
    @Column(length = 20)
    @Builder.Default
    private DisputeStatus status = DisputeStatus.OPEN;

    private String reason;
    private String resolutionNote;
}
