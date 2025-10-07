package vn.group3.marketplace.domain.entity;

import java.time.LocalDateTime;
import jakarta.persistence.*;
import lombok.*;
import vn.group3.marketplace.domain.enums.ProductStorageStatus;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "product_storage")
@Access(AccessType.FIELD)
public class ProductStorage extends BaseEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @Enumerated(EnumType.STRING)
    @Column(length = 20, nullable = false)
    @Builder.Default
    private ProductStorageStatus status = ProductStorageStatus.AVAILABLE;

    @Column(name = "payload_json", columnDefinition = "JSON", nullable = false)
    private String payloadJson;

    @Column(name = "payload_mask")
    private String payloadMask;

    @Column(name = "reserved_until")
    private LocalDateTime reservedUntil;

    @Column(name = "delivered_at")
    private LocalDateTime deliveredAt;

    @Column(length = 255)
    private String note;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "order_id")
    private Order order;
}
