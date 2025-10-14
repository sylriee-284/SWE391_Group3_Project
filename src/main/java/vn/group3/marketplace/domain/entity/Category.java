package vn.group3.marketplace.domain.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "categories", uniqueConstraints = {
        @UniqueConstraint(name = "uq_categories_name_parent", columnNames = { "parent_id", "name" })
})
@Access(AccessType.FIELD)
public class Category extends BaseEntity {

    @Column(name = "is_deleted")
    private Boolean isDeleted = false;

    @Column(name = "deleted_at")
    private LocalDateTime deletedAt;

    // Getter & Setter
    public Boolean getIsDeleted() {
        return isDeleted;
    }

    public void setIsDeleted(Boolean isDeleted) {
        this.isDeleted = isDeleted;
    }

    public LocalDateTime getDeletedAt() {
        return deletedAt;
    }

    public void setDeletedAt(LocalDateTime deletedAt) {
        this.deletedAt = deletedAt;
    }

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true, length = 255)
    private String name;

    @Column(length = 500)
    private String description;

    // ===================== PARENT RELATIONSHIP =====================
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "parent_id", insertable = false, updatable = false) // ✅ fix: tránh lỗi duplicated column
    private Category parent;

    // ===================== CHILDREN RELATIONSHIP =====================
    @OneToMany(mappedBy = "parent", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @Builder.Default
    private List<Category> children = new java.util.ArrayList<>();

    // ===================== CỘT parent_id THỰC TẾ =====================
    @Column(name = "parent_id")
    private Long parentId;

    // ✅ Nếu dùng Lombok thì không cần các getter/setter dưới, nhưng có cũng không
    // sao
    public Long getParentId() {
        return parentId;
    }

    public void setParentId(Long parentId) {
        this.parentId = parentId;
    }
}
