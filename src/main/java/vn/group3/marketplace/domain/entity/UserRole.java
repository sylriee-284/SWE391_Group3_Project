package vn.group3.marketplace.domain.entity;

import jakarta.persistence.*;
import lombok.*;
import vn.group3.marketplace.domain.entity.UserRole.UserRoleId;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "user_roles")
@Access(AccessType.FIELD)
public class UserRole extends BaseEntity {

    @EmbeddedId
    private UserRoleId id = new UserRoleId();

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("userId")
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("roleId")
    @JoinColumn(name = "role_id", nullable = false)
    private Role role;

    @Embeddable
    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @EqualsAndHashCode
    @Access(AccessType.FIELD)
    public static class UserRoleId implements java.io.Serializable {
        private static final long serialVersionUID = 1L;

        @Column(name = "user_id") // ✅ map đúng tên cột
        private Long userId;

        @Column(name = "role_id") // ✅ map đúng tên cột
        private Long roleId;
    }
}
