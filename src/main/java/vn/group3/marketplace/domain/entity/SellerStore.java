package vn.group3.marketplace.domain.entity;

import java.math.BigDecimal;
import jakarta.persistence.*;
import lombok.*;
import vn.group3.marketplace.domain.enums.SellerStoresType;
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

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "owner_user_id", nullable = false)
    private User owner;

    @Column(nullable = false, length = 255)
    private String storeName;

    private String description;

    @Enumerated(EnumType.STRING)
    @Column(length = 20)
    @Builder.Default
    private StoreStatus status = StoreStatus.ACTIVE;

    @Enumerated(EnumType.STRING)
    @Column(name = "fee_model", length = 20)
    private SellerStoresType feeModel;

    @Column(name = "fee_percentage_rate", precision = 5, scale = 2)
    private BigDecimal feePercentageRate;

    @Column(name = "escrow_amount", nullable = false, precision = 18, scale = 2)
    @Builder.Default
    private BigDecimal escrowAmount = BigDecimal.ZERO;

    @Column(name = "deposit_amount", nullable = false, precision = 18, scale = 2)
    @Builder.Default
    private BigDecimal depositAmount = BigDecimal.ZERO;

    @Column(name = "max_listing_price", precision = 18, scale = 2, insertable = false, updatable = false)
    private BigDecimal maxListingPrice;

    @Column(name = "deposit_currency", length = 3, nullable = false)
    @Builder.Default
    private String depositCurrency = "VND";

    @Column(nullable = false, precision = 3, scale = 2)
    @Builder.Default
    private BigDecimal rating = BigDecimal.ZERO;
}
