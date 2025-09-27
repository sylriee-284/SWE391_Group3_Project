package vn.group3.marketplace.domain.entity;

import jakarta.persistence.*;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "system_settings")
@Access(AccessType.FIELD)
public class SystemSetting extends BaseEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "setting_key", nullable = false, unique = true, length = 200)
    private String key;

    @Column(name = "setting_value", columnDefinition = "TEXT")
    private String value;
}
