package vn.group3.marketplace.service;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import lombok.RequiredArgsConstructor;
import vn.group3.marketplace.domain.entity.*;
import vn.group3.marketplace.domain.enums.UserStatus;
import vn.group3.marketplace.repository.*;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final PasswordEncoder passwordEncoder;
    private static final String DEFAULT_PLAIN_PASSWORD = "123456789";

    public java.util.List<Role> getAllRoles() {
        return roleRepository.findAll();
    }

    public Long getDefaultUserRoleId() {
        return roleRepository.findByCode("USER")
                .orElseThrow(() -> new RuntimeException("Role USER does not exist"))
                .getId();
    }

    private java.util.Set<Role> mapRoleIds(java.util.List<Long> roleIds) {
        java.util.Set<Role> out = new java.util.HashSet<>();
        if (roleIds == null || roleIds.isEmpty()) {
            // mặc định: USER
            Role userRole = roleRepository.findByCode("USER")
                    .orElseThrow(() -> new RuntimeException("Role USER does not exist"));
            out.add(userRole);
            return out;
        }
        for (Long id : roleIds) {
            roleRepository.findById(id).ifPresent(out::add);
        }
        if (out.isEmpty()) {
            Role userRole = roleRepository.findByCode("USER")
                    .orElseThrow(() -> new RuntimeException("Role USER does not exist"));
            out.add(userRole);
        }
        return out;
    }

    @Transactional
    public void registerUser(String username, String email, String rawPassword) {
        // Check username duplicate
        if (userRepository.findByUsername(username).isPresent()) {
            throw new IllegalArgumentException("Username already exists!");
        }

        // Check email duplicate
        if (userRepository.findByEmail(email).isPresent()) {
            throw new IllegalArgumentException("Email already exists!");
        }

        // Create new user with default balance
        User user = User.builder()
                .username(username)
                .email(email)
                .passwordHash(passwordEncoder.encode(rawPassword))
                .status(UserStatus.ACTIVE)
                .balance(BigDecimal.ZERO)
                .build();

        // Assign default role
        Role role = roleRepository.findByCode("USER")
                .orElseThrow(() -> new RuntimeException("Role USER does not exist"));
        // Project uses ManyToMany `roles` on User entity. Add role to user's roles set.
        user.getRoles().add(role);

        // Save user (cascade sẽ tự động lưu userRole)
        userRepository.save(user);
    }

    public Optional<User> findByUsername(String username) {
        return userRepository.findByUsername(username);
    }

    public Optional<User> findByEmail(String email) {
        return userRepository.findByEmail(email);
    }

    // Optimized: Check both username and email in single query
    public Optional<User> findByUsernameOrEmail(String username, String email) {
        return userRepository.findByUsernameOrEmail(username, email);
    }

    // Check if username is available for new registration
    public boolean isUsernameAvailable(String username) {
        return !userRepository.findByUsername(username).isPresent();
    }

    // Check if email is available for new registration
    public boolean isEmailAvailable(String email) {
        return !userRepository.findByEmail(email).isPresent();
    }

    public void resetPassword(String newPassword, String email) {
        String encodedPassword = passwordEncoder.encode(newPassword);
        userRepository.updatePassword(encodedPassword, email);
    }

    @PreAuthorize("isAuthenticated()")
    public void updatePassword(String newPassword, String email) {
        String encodedPassword = passwordEncoder.encode(newPassword);
        userRepository.updatePassword(encodedPassword, email);
    }

    // Change password for authenticated user
    @Transactional
    @PreAuthorize("isAuthenticated()")
    public void changePassword(String username, String newPassword) {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new IllegalArgumentException("User not found: " + username));

        String encodedPassword = passwordEncoder.encode(newPassword);
        user.setPasswordHash(encodedPassword);
        userRepository.save(user);
    }

    // Get user by username
    public User getUserByUsername(String username) {
        return userRepository.findByUsername(username).orElse(null);
    }

    // Get user by ID
    @PreAuthorize("hasRole('ADMIN') or (isAuthenticated() and #id == authentication.principal.id)")
    public User getUserById(Long id) {
        return userRepository.findById(id).orElse(null);
    }

    /**
     * Find all users with simple pagination. Returns Page<User>.
     */
    public Page<User> findAllUsers(int page, int size) {
        Pageable p = PageRequest.of(Math.max(0, page), Math.max(1, size));
        return userRepository.findAll(p);
    }

    /**
     * Delete user by id (permanent delete). Use with caution.
     */
    @Transactional
    public void deleteUserById(Long id) {
        userRepository.deleteById(id);
    }

    /**
     * Update user information
     * 
     * @param user User to update
     * @return Updated user
     */
    // Update user information
    @PreAuthorize("hasRole('ADMIN') or (isAuthenticated() and #user.id == authentication.principal.id)")
    @Transactional
    public User updateUser(User user) {
        System.out.println("💾 UserService.updateUser() called for user ID: " + user.getId());
        System.out.println("💾 Saving: " + user.getFullName() + " | " + user.getEmail());
        User savedUser = userRepository.saveAndFlush(user);
        System.out.println("💾 User saved successfully!");
        return savedUser;
    }

    // Get fresh user data from database (bypass cache)
    @Transactional(readOnly = true)
    public User getFreshUserByUsername(String username) {
        System.out.println("🔍 UserService.getFreshUserByUsername() called for: " + username);
        // Force a fresh query from database
        User user = userRepository.findByUsername(username).orElse(null);
        System.out.println("🔍 Fresh user retrieved: " + (user != null ? user.getFullName() : "NULL"));
        return user;
    }

    // Force flush and clear entity manager to ensure immediate persistence
    @Transactional
    public void flushAndClear() {
        userRepository.flush();
    }

    @Transactional
    public User saveFromAdmin(vn.group3.marketplace.domain.entity.User incoming) {
        if (incoming.getId() == null) {
            // CREATE: nếu chưa có hash thì set mật khẩu mặc định
            if (incoming.getPasswordHash() == null || incoming.getPasswordHash().isBlank()) {
                incoming.setPasswordHash(passwordEncoder.encode(DEFAULT_PLAIN_PASSWORD));
            }
            // mặc định không xoá
            if (incoming.getIsDeleted() == null) {
                incoming.setIsDeleted(false);
            }
            return userRepository.save(incoming);
        } else {
            // UPDATE: không đổi password
            User db = userRepository.findById(incoming.getId())
                    .orElseThrow(() -> new IllegalArgumentException("User không tồn tại: id=" + incoming.getId()));

            // copy các field cho phép
            db.setUsername(incoming.getUsername());
            db.setEmail(incoming.getEmail());
            db.setFullName(incoming.getFullName());
            db.setPhone(incoming.getPhone());
            db.setStatus(incoming.getStatus());
            // ... các field khác nếu team bạn cho phép

            return userRepository.save(db);
        }
    }

    public Page<User> findUsers(int page, int size, vn.group3.marketplace.domain.enums.UserStatus status) {
        Pageable pr = PageRequest.of(Math.max(0, page), Math.max(1, size));
        if (status == null) {
            return userRepository.findAll(pr);
        }
        return userRepository.findByStatus(status, pr);
    }

    @Transactional
    public User saveFromAdminWithRoles(User incoming, List<Long> roleIds) {
        // ----- UNIQUE CHECK -----
        Long id = incoming.getId();

        // username
        userRepository.findByUsername(incoming.getUsername()).ifPresent(ex -> {
            if (id == null || !ex.getId().equals(id)) {
                throw new IllegalArgumentException("USERNAME_DUPLICATED");
            }
        });

        // email
        userRepository.findByEmail(incoming.getEmail()).ifPresent(ex -> {
            if (id == null || !ex.getId().equals(id)) {
                throw new IllegalArgumentException("EMAIL_DUPLICATED");
            }
        });

        // nếu muốn ràng buộc phone là unique:
        if (incoming.getPhone() != null && !incoming.getPhone().isBlank()) {
            Optional.ofNullable(userRepository.findByPhone(incoming.getPhone()).orElse(null)).ifPresent(ex -> {
                if (id == null || !ex.getId().equals(id)) {
                    throw new IllegalArgumentException("PHONE_DUPLICATED");
                }
            });
        }
        // -------------------------

        if (incoming.getId() == null) {
            if (incoming.getPasswordHash() == null || incoming.getPasswordHash().isBlank()) {
                incoming.setPasswordHash(passwordEncoder.encode(DEFAULT_PLAIN_PASSWORD));
            }
            if (incoming.getIsDeleted() == null)
                incoming.setIsDeleted(false);
            incoming.setRoles(mapRoleIds(roleIds));
            return userRepository.save(incoming);
        } else {
            User db = userRepository.findById(incoming.getId())
                    .orElseThrow(() -> new IllegalArgumentException("User không tồn tại: id=" + incoming.getId()));
            db.setUsername(incoming.getUsername());
            db.setEmail(incoming.getEmail());
            db.setFullName(incoming.getFullName());
            db.setPhone(incoming.getPhone());
            db.setStatus(incoming.getStatus());
            db.setRoles(mapRoleIds(roleIds));
            return userRepository.save(db);
        }
    }

    public Page<User> searchUsers(int page, int size,
            Long id, String username, String email, String phone,
            UserStatus status) {
        Pageable pr = PageRequest.of(Math.max(0, page), Math.max(1, size));

        Specification<User> spec = Specification.where(null);

        if (id != null) {
            spec = spec.and((root, q, cb) -> cb.equal(root.get("id"), id));
        }
        if (username != null && !username.trim().isEmpty()) {
            String v = "%" + username.trim().toLowerCase() + "%";
            spec = spec.and((root, q, cb) -> cb.like(cb.lower(root.get("username")), v));
        }
        if (email != null && !email.trim().isEmpty()) {
            String v = "%" + email.trim().toLowerCase() + "%";
            spec = spec.and((root, q, cb) -> cb.like(cb.lower(root.get("email")), v));
        }
        if (phone != null && !phone.trim().isEmpty()) {
            String v = "%" + phone.trim() + "%";
            spec = spec.and((root, q, cb) -> cb.like(root.get("phone"), v));
        }
        if (status != null) {
            spec = spec.and((root, q, cb) -> cb.equal(root.get("status"), status));
        }

        // (Tuỳ chọn) loại user có role ADMIN từ DB để phân trang chuẩn:
        // Join<Object, Object> roles = root.join("roles", JoinType.LEFT);
        // q.distinct(true);
        // return cb.notEqual(roles.get("code"), "ADMIN");

        return userRepository.findAll(spec, pr);
    }

}
