package vn.group3.marketplace.domain.entity;

import java.math.BigDecimal;
import jakarta.persistence.*;
import lombok.*;
import vn.group3.marketplace.domain.enums.WalletTransactionType;
import vn.group3.marketplace.domain.enums.WalletTransactionStatus;

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

    @Enumerated(EnumType.STRING)
    @Column(name = "payment_status", length = 50)
    private WalletTransactionStatus paymentStatus;

    @Column(name = "payment_method", length = 50)
    private String paymentMethod;

    public String getPaymentRef() {
        return paymentRef;
    }

    public void setPaymentRef(String paymentRef) {
        this.paymentRef = paymentRef;
    }

    public WalletTransactionStatus getPaymentStatus() {
        return paymentStatus;
    }

    public void setPaymentStatus(WalletTransactionStatus paymentStatus) {
        this.paymentStatus = paymentStatus;
    }

    public String getPaymentMethod() {
        return paymentMethod;
    }

    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }

    public Order getOrder() {
        return this.refOrder;
    }

    /**
     * Convenience property for JSP/EL: exposes the referenced order id.
     * If the relationship is not set, attempt to parse the paymentRef as an order
     * id.
     */
    public Long getOrderId() {
        if (this.refOrder != null) {
            return this.refOrder.getId();
        }
        if (this.paymentRef != null && !this.paymentRef.isEmpty()) {
            try {
                return Long.parseLong(this.paymentRef);
            } catch (NumberFormatException ex) {
                return null;
            }
        }
        return null;
    }
}
