package vn.group3.marketplace.domain.entity;

import jakarta.persistence.*;
import lombok.*;
import vn.group3.marketplace.domain.enums.ProductStatus;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "products", uniqueConstraints = {
        @UniqueConstraint(name = "uniq_store_slug", columnNames = { "seller_store_id", "slug" })
})
@Access(AccessType.FIELD)
public class Product extends BaseEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "seller_store_id", nullable = false)
    private SellerStore sellerStore;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "category_id")
    private Category category;

    @Column(nullable = false)
    private String name;

    private String slug;
    private String description;
    private Double price;
    @Builder.Default
    private Integer stock = 0;

    @Enumerated(EnumType.STRING)
    @Column(length = 20)
    @Builder.Default
    private ProductStatus status = ProductStatus.ACTIVE;
}
