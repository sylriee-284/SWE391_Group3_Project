package vn.group3.marketplace.domain.entity;

import jakarta.persistence.*;
import lombok.*;
import vn.group3.marketplace.domain.enums.OrderStatus;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "orders", uniqueConstraints = {
        @UniqueConstraint(name = "uniq_orders_storage", columnNames = { "product_storage_id" })
})
@Access(AccessType.FIELD)
public class Order extends BaseEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "buyer_user_id", nullable = false)
    private User buyer;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "seller_store_id", nullable = false)
    private SellerStore sellerStore;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_storage_id")
    private ProductStorage productStorage;

    private String productName;
    private Double productPrice;
    @Builder.Default
    private Integer quantity = 1;

    @Column(columnDefinition = "TEXT")
    private String productData;

    @Enumerated(EnumType.STRING)
    @Column(length = 20)
    @Builder.Default
    private OrderStatus status = OrderStatus.PENDING;

    private Double totalAmount;
}
