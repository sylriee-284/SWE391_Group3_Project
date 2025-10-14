package vn.group3.marketplace.domain.entity;

import java.math.BigDecimal;
import java.util.HashSet;
import java.util.Set;

import jakarta.persistence.*;
import lombok.*;
import vn.group3.marketplace.domain.enums.Gender;
import vn.group3.marketplace.domain.enums.UserStatus;

import java.time.LocalDate;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "users")
@Access(AccessType.FIELD)
public class User extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true, length = 50)
    private String username;

    @Column(nullable = false, unique = true, length = 255)
    private String email;

    @Column(name = "password_hash", nullable = false, length = 255)
    private String passwordHash;

    // @Transient
    // private String roleName; // 👈 chỉ dùng hiển thị trên form, không lưu xuống
    // DB

    private String phone;
    private String fullName;
    private LocalDate dateOfBirth;

    @Enumerated(EnumType.STRING)
    @Column(length = 20)
    private Gender gender;

    @Enumerated(EnumType.STRING)
    @Column(length = 20)
    @Builder.Default
    private UserStatus status = UserStatus.ACTIVE;

    @Column(nullable = false, precision = 18, scale = 2)
    @Builder.Default
    private BigDecimal balance = BigDecimal.ZERO;

    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, orphanRemoval = true, // 🔑 BẮT BUỘC
            fetch = FetchType.LAZY)
    @Builder.Default
    private Set<UserRole> userRoles = new HashSet<>();

    // (tuỳ chọn) helper thay roles
    public void replaceRoles(Set<UserRole> newRoles) {
        this.userRoles.clear();
        this.userRoles.addAll(newRoles);
    }

    // One-to-One với SellerStore
    @OneToOne(mappedBy = "owner", cascade = CascadeType.ALL)
    private SellerStore sellerStore;

    // Convenience method to get roles
    public Set<Role> getRoles() {
        return userRoles.stream()
                .map(UserRole::getRole)
                .collect(java.util.stream.Collectors.toSet());
    }

    public boolean hasRole(String roleCode) {
        return this.getRoles().stream()
                .anyMatch(r -> r.getCode().equalsIgnoreCase(roleCode));
    }
}
