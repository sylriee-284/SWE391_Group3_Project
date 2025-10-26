package vn.group3.marketplace.domain.entity;

import jakarta.persistence.*;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "category_import_templates", uniqueConstraints = {
                @UniqueConstraint(name = "uniq_category_field", columnNames = { "category_id", "field_name" })
}, indexes = {
                @Index(name = "idx_template_category_order", columnList = "category_id, field_order")
})
@Access(AccessType.FIELD)
public class CategoryImportTemplate extends BaseEntity {

        @Id
        @GeneratedValue(strategy = GenerationType.IDENTITY)
        private Long id;

        @ManyToOne(fetch = FetchType.LAZY)
        @JoinColumn(name = "category_id", nullable = false, foreignKey = @ForeignKey(name = "fk_template_category"))
        private Category category;

        @Column(name = "field_name", nullable = false, length = 100)
        private String fieldName;

        @Column(name = "field_label", nullable = false, length = 255)
        private String fieldLabel;

        @Column(name = "is_unique", nullable = false)
        @Builder.Default
        private Boolean isUnique = true;

        @Column(name = "validation_rule", length = 500)
        private String validationRule;

        @Column(name = "field_order", nullable = false)
        @Builder.Default
        private Integer fieldOrder = 0;
}
