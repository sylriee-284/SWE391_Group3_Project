package vn.group3.marketplace.domain.entity;

import jakarta.persistence.*;
import lombok.*;
import vn.group3.marketplace.domain.enums.StoreStatus;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "seller_stores")
@Access(AccessType.FIELD)
public class SellerStore extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "owner_user_id", nullable = false)
    private User owner;

    @Column(nullable = false, length = 255)
    private String storeName;

    private String description;

    @Enumerated(EnumType.STRING)
    @Column(length = 20)
    @Builder.Default
    private StoreStatus status = StoreStatus.ACTIVE;

    private Double depositAmount;
    private Double maxListingPrice;
    @Builder.Default
    private String depositCurrency = "VND";
}
