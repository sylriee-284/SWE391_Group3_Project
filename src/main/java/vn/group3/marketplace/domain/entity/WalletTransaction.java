package vn.group3.marketplace.domain.entity;

import java.math.BigDecimal;
import jakarta.persistence.*;
import lombok.*;
import vn.group3.marketplace.domain.enums.WalletTransactionType;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "wallet_transactions")
@Access(AccessType.FIELD)
public class WalletTransaction extends BaseEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Enumerated(EnumType.STRING)
    @Column(length = 20, nullable = false)
    private WalletTransactionType type;

    @Column(nullable = false, precision = 18, scale = 2)
    private BigDecimal amount;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "ref_order_id")
    private Order refOrder;

    @Column(length = 500)
    private String note;

    @Column(name = "payment_ref", length = 100)
    private String paymentRef;

    @Column(name = "payment_status", length = 50)
    private String paymentStatus;

    @Column(name = "payment_method", length = 50)
    private String paymentMethod;
}
