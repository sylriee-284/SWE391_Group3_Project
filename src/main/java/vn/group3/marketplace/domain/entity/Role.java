package vn.group3.marketplace.domain.entity;

import java.util.Set;

import jakarta.persistence.*;
import lombok.*;

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

    // === Many-to-Many với Permission thông qua role_permissions ===
    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(name = "role_permissions", joinColumns = @JoinColumn(name = "role_id"), inverseJoinColumns = @JoinColumn(name = "permission_id"))
    private Set<Permission> permissions;
    // Many-to-Many với User
    @ManyToMany(mappedBy = "roles")
    private Set<User> users;
}
