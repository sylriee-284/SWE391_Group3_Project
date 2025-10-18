package vn.group3.marketplace.domain.entity;

import jakarta.persistence.*;
import lombok.*;

import java.util.HashSet;
import java.util.Set;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "roles")
@Access(AccessType.FIELD)
public class Role extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true, length = 80)
    private String code;

    @Column(nullable = false, length = 255)
    private String name;

    private String description;

    // ✅ mapping CHÍNH qua bảng trung gian
    @OneToMany(mappedBy = "role", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.LAZY)
    @Builder.Default
    private Set<UserRole> userRoles = new HashSet<>();

    // ✅ GIỮ TÊN CŨ, KHÔNG XÓA: thay ManyToMany -> Transient bridge
    @Transient
    @Builder.Default
    private Set<User> users = new HashSet<>();

    // ✅ bridge: đọc từ userRoles
    public Set<User> getUsers() {
        // luôn build từ userRoles để nhất quán
        return userRoles.stream()
                .map(UserRole::getUser)
                .collect(java.util.stream.Collectors.toSet());
    }

    // ✅ bridge: ghi ngược vào userRoles để vẫn “set users” như cũ
    public void setUsers(Set<User> users) {
        this.userRoles.clear();
        if (users != null) {
            for (User u : users) {
                UserRole ur = new UserRole();
                ur.setUser(u);
                ur.setRole(this);
                this.userRoles.add(ur);
            }
        }
        // giữ field users cho code nào lỡ truy cập trực tiếp
        this.users = users != null ? new HashSet<>(users) : new HashSet<>();
    }
}
