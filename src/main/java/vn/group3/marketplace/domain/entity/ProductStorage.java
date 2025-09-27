package vn.group3.marketplace.domain.entity;

import jakarta.persistence.*;
import lombok.*;

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

    @Builder.Default
    private String status = "available";
    @Column(columnDefinition = "TEXT")
    private String payloadJson; // JSON
    private String payloadMask;
    private java.time.LocalDateTime reservedUntil;
    private java.time.LocalDateTime deliveredAt;
    private String note;
}
