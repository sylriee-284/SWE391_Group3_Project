package vn.group3.marketplace.domain.entity;

import jakarta.persistence.*;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "payment_gateways")
@Access(AccessType.FIELD)
public class PaymentGateway extends BaseEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true, length = 80)
    private String code;

    @Column(nullable = false, length = 255)
    private String name;

    @Column(nullable = false)
    @Builder.Default
    private Boolean enabled = true;

    @Column(columnDefinition = "JSON")
    private String config;
}
