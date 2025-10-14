package vn.group3.marketplace.service;

import java.sql.Timestamp;
import java.util.HashSet;
import java.util.List;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;

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
                .balance(BigDecimal.ZERO) // Balance is stored directly in User
                .build();

        // Assign default role
        Role role = roleRepository.findByCode("USER")
                .orElseThrow(() -> new RuntimeException("Role USER does not exist"));
        user.getRoles().add(role);

        // Save user
        userRepository.save(user);
    }

    public Optional<User> findByUsername(String username) {
        return userRepository.findByUsername(username);
    }

    public Optional<User> findByEmail(String email) {
        return userRepository.findByEmail(email);
    }

    public void resetPassword(String newPassword, String email) {
        String encodedPassword = passwordEncoder.encode(newPassword);
        userRepository.updatePassword(encodedPassword, email);
    }

    public void updatePassword(String newPassword, String email) {
        String encodedPassword = passwordEncoder.encode(newPassword);
        userRepository.updatePassword(encodedPassword, email);
    }

    // --- CRUD: Start of Admin Account Management ---
    public List<User> getAllActiveUsers() {
        // Lấy toàn bộ user chưa bị xóa (isDeleted = false)
        return userRepository.findAll()
                .stream()
                .filter(u -> !Boolean.TRUE.equals(u.getIsDeleted()))
                .collect(Collectors.toList());
    }

    public Optional<User> getUserById(Long id) {
        // Tìm user theo ID, chỉ trả nếu chưa bị xóa
        return userRepository.findById(id)
                .filter(u -> !Boolean.TRUE.equals(u.getIsDeleted()));
    }

    public User createUser(User user) {
        user.setId(null);
        user.setIsDeleted(false);

        // Status: tôn trọng form; nếu trống thì mặc định ACTIVE
        if (user.getStatus() == null) {
            user.setStatus(UserStatus.ACTIVE);
        }

        // Balance: nếu null thì set 0
        if (user.getBalance() == null) {
            user.setBalance(BigDecimal.ZERO);
        }

        // Password: form không có ô password -> đặt password tạm và mã hoá
        if (user.getPasswordHash() == null || user.getPasswordHash().isBlank()) {
            String tempPassword = "ChangeMe@123"; // hoặc sinh ngẫu nhiên
            user.setPasswordHash(passwordEncoder.encode(tempPassword));
            // (tuỳ chọn) bạn có thể log/hiển thị tempPassword ở thông báo flash nếu muốn
        }

        // Role: nếu chưa có role thì gán mặc định USER
        if (user.getRoles() == null || user.getRoles().isEmpty()) {
            Role role = roleRepository.findByCode("USER")
                    .orElseThrow(() -> new RuntimeException("Role USER does not exist"));
            user.getRoles().add(role);
        }

        return userRepository.save(user);
    }

    public User updateUser(Long id, User updatedUser) {
        // Check trùng EMAIL (bỏ qua chính record đang sửa)
        userRepository.findByEmail(updatedUser.getEmail())
                .filter(u -> !u.getId().equals(id))
                .ifPresent(u -> {
                    throw new IllegalArgumentException("Email đã tồn tại");
                });

        // Check trùng USERNAME (bỏ qua chính record đang sửa)
        userRepository.findByUsername(updatedUser.getUsername())
                .filter(u -> !u.getId().equals(id))
                .ifPresent(u -> {
                    throw new IllegalArgumentException("Username đã tồn tại");
                });

        return userRepository.findById(id).map(existing -> {
            // cập nhật các trường cho phép
            existing.setUsername(updatedUser.getUsername()); // <— QUAN TRỌNG
            existing.setEmail(updatedUser.getEmail());
            existing.setFullName(updatedUser.getFullName());
            existing.setPhone(updatedUser.getPhone());
            existing.setGender(updatedUser.getGender());
            existing.setStatus(updatedUser.getStatus());
            // balance: nếu null thì về 0
            existing.setBalance(updatedUser.getBalance() != null
                    ? updatedUser.getBalance()
                    : java.math.BigDecimal.ZERO);
            return userRepository.save(existing);
        }).orElseThrow(() -> new RuntimeException("User not found"));
    }

    public void softDeleteUser(Long id, Long adminId) {
        // Xóa mềm user
        userRepository.findById(id).ifPresent(user -> {
            user.setIsDeleted(true);
            user.setDeletedBy(adminId);
            user.setStatus(UserStatus.INACTIVE);
            userRepository.save(user);
        });
    }

    public List<User> getFilteredUsers(String status) {
        return userRepository.findAll().stream()
                .filter(u -> !Boolean.TRUE.equals(u.getIsDeleted()))
                .filter(u -> {
                    if (status == null || status.isEmpty())
                        return true;
                    return u.getStatus().name().equalsIgnoreCase(status);
                })
                .collect(Collectors.toList());
    }

    @Transactional
    public void toggleUserStatus(Long id) {
        userRepository.findById(id).ifPresent(user -> {
            if (!Boolean.TRUE.equals(user.getIsDeleted())) {
                user.setStatus(user.getStatus() == UserStatus.ACTIVE
                        ? UserStatus.INACTIVE
                        : UserStatus.ACTIVE);
                userRepository.save(user);
            }
        });
    }

    @Transactional
    public void saveUserWithRoles(User user, List<String> roleCodes) {
        userRepository.save(user); // lưu trước để có id

        if (roleCodes != null && !roleCodes.isEmpty()) {
            Set<UserRole> userRoleSet = new HashSet<>();

            for (String code : roleCodes) {
                Role role = roleRepository.findByCode(code)
                        .orElseThrow(() -> new RuntimeException("Role không tồn tại: " + code));

                UserRole ur = new UserRole();
                ur.setId(new UserRole.UserRoleId(user.getId(), role.getId())); // 🔑 Quan trọng
                ur.setUser(user);
                ur.setRole(role);
                userRoleSet.add(ur);
            }

            user.setUserRoles(userRoleSet);
            userRepository.save(user);
        }
    }

    @Transactional
    public void saveUserWithRolesAndPassword(User user, List<String> roleCodes, String passwordPlain) {
        // 1️⃣ Lấy bản ghi cũ nếu đang cập nhật
        User existing = user.getId() != null
                ? userRepository.findById(user.getId()).orElse(new User())
                : new User();

        // 2️⃣ Xử lý mật khẩu
        if (passwordPlain != null && !passwordPlain.isBlank()) {
            user.setPasswordHash(passwordEncoder.encode(passwordPlain));
        } else if (user.getId() == null) {
            // Tạo mới mà không nhập mật khẩu => mật khẩu mặc định
            user.setPasswordHash(passwordEncoder.encode("ChangeMe@123"));
        } else {
            // Sửa mà để trống => giữ mật khẩu cũ
            user.setPasswordHash(existing.getPasswordHash());
        }

        // 3️⃣ Xử lý các field mặc định
        if (user.getStatus() == null)
            user.setStatus(UserStatus.ACTIVE);
        if (user.getBalance() == null)
            user.setBalance(BigDecimal.ZERO);
        if (user.getIsDeleted() == null)
            user.setIsDeleted(false);

        // 4️⃣ Lưu lần đầu để có ID (nếu là user mới)
        user = userRepository.save(user);

        // 5️⃣ Xử lý Roles
        Set<UserRole> userRoleSet = new HashSet<>();

        List<String> effectiveRoles = (roleCodes != null && !roleCodes.isEmpty())
                ? roleCodes
                : List.of("USER"); // fallback nếu không chọn

        for (String code : effectiveRoles) {
            Role role = roleRepository.findByCode(code)
                    .orElseThrow(() -> new RuntimeException("Role không tồn tại: " + code));

            UserRole ur = new UserRole();
            ur.setId(new UserRole.UserRoleId(user.getId(), role.getId()));
            ur.setUser(user);
            ur.setRole(role);
            userRoleSet.add(ur);
        }

        user.setUserRoles(userRoleSet);

        // 6️⃣ Lưu cuối (1 lần thôi)
        userRepository.save(user);
    }

    // --- CRUD: End of Admin Account Management ---
}
