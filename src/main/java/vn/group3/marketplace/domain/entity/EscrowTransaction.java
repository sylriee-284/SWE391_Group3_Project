package vn.group3.marketplace.domain.entity;

import jakarta.persistence.*;
import lombok.*;
import vn.group3.marketplace.domain.enums.EscrowStatus;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "escrow_transactions", uniqueConstraints = {
        @UniqueConstraint(name = "uniq_escrow_order", columnNames = { "order_id" })
})
@Access(AccessType.FIELD)
public class EscrowTransaction extends BaseEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "order_id", nullable = false)
    private Order order;

    private Double amount;

    @Enumerated(EnumType.STRING)
    @Column(length = 20)
    @Builder.Default
    private EscrowStatus status = EscrowStatus.HELD;

    private java.time.LocalDateTime holdUntil;
    private java.time.LocalDateTime releasedAt;
}
