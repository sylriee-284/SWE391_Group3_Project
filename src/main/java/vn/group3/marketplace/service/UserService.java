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
        if (userRepository.findByUsername(username).isPresent()) {
            throw new IllegalArgumentException("Username already exists!");
        }
        if (userRepository.findByEmail(email).isPresent()) {
            throw new IllegalArgumentException("Email already exists!");
        }

        User user = User.builder()
                .username(username)
                .email(email)
                .passwordHash(passwordEncoder.encode(rawPassword))
                .status(UserStatus.ACTIVE)
                .balance(BigDecimal.ZERO)
                .build();

        // Lưu trước để có ID
        user = userRepository.save(user);

        // Gán mặc định USER (KHÔNG set EmbeddedId)
        Role role = roleRepository.findByCode("USER")
                .orElseThrow(() -> new RuntimeException("Role USER does not exist"));

        user.getUserRoles().clear();
        UserRole ur = new UserRole();
        ur.setUser(user);
        ur.setRole(role);
        user.getUserRoles().add(ur);

        userRepository.save(user);
    }

    public Optional<User> findByUsername(String username) {
        return userRepository.findByUsername(username);
    }

    public Optional<User> findByEmail(String email) {
        return userRepository.findByEmail(email);
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

    @Transactional
    public User createUser(User user) {
        user.setId(null);
        user.setIsDeleted(false);
        if (user.getStatus() == null)
            user.setStatus(UserStatus.ACTIVE);
        if (user.getBalance() == null)
            user.setBalance(BigDecimal.ZERO);
        if (user.getPasswordHash() == null || user.getPasswordHash().isBlank()) {
            user.setPasswordHash(passwordEncoder.encode("ChangeMe@123"));
        }

        // Lưu trước để có ID
        user = userRepository.save(user);

        // Nếu chưa có role => mặc định USER (KHÔNG set EmbeddedId)
        if (user.getUserRoles() == null || user.getUserRoles().isEmpty()) {
            Role role = roleRepository.findByCode("USER")
                    .orElseThrow(() -> new RuntimeException("Role USER does not exist"));
            UserRole ur = new UserRole();
            ur.setUser(user);
            ur.setRole(role);
            user.getUserRoles().add(ur);
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
    public void saveUserWithRoles(User incoming, List<String> roleCodes) {
        final boolean creating = (incoming.getId() == null);

        // Lấy entity managed khi sửa, hoặc new khi tạo
        User user = creating
                ? new User()
                : userRepository.findById(incoming.getId())
                        .orElseThrow(() -> new IllegalArgumentException("User not found"));

        // copy field
        user.setUsername(incoming.getUsername());
        user.setEmail(incoming.getEmail());
        user.setFullName(incoming.getFullName());
        user.setPhone(incoming.getPhone());
        user.setGender(incoming.getGender());
        user.setStatus(incoming.getStatus() != null ? incoming.getStatus() : UserStatus.ACTIVE);
        user.setBalance(incoming.getBalance() != null ? incoming.getBalance() : BigDecimal.ZERO);

        if (creating) {
            user.setIsDeleted(false);
            if (user.getPasswordHash() == null || user.getPasswordHash().isBlank()) {
                user.setPasswordHash(passwordEncoder.encode("ChangeMe@123"));
            }
            // BẮT BUỘC lưu trước để có ID (vì dùng @MapsId)
            user = userRepository.save(user);
        }

        // XÓA toàn bộ roles cũ rồi FLUSH để tránh "re-saved by cascade"
        user.getUserRoles().clear();
        userRepository.flush();

        // Tập role mới (mặc định USER nếu không chọn)
        List<String> codes = (roleCodes == null || roleCodes.isEmpty()) ? List.of("USER") : roleCodes;

        for (String code : codes) {
            Role role = roleRepository.findByCode(code)
                    .orElseThrow(() -> new RuntimeException("Role không tồn tại: " + code));

            UserRole ur = new UserRole();
            ur.setUser(user);
            ur.setRole(role);
            // 🔑 Điền EmbeddedId để Hibernate không nhầm trạng thái
            ur.getId().setUserId(user.getId());
            ur.getId().setRoleId(role.getId());

            user.getUserRoles().add(ur);
        }

        userRepository.save(user);
    }

    @Transactional
    public void saveUserWithRolesAndPassword(User incoming,
            List<String> roleCodes,
            String passwordPlain) {
        final boolean creating = (incoming.getId() == null);

        User user = creating
                ? new User()
                : userRepository.findById(incoming.getId())
                        .orElseThrow(() -> new IllegalArgumentException("User not found"));

        // copy field
        user.setUsername(incoming.getUsername());
        user.setEmail(incoming.getEmail());
        user.setFullName(incoming.getFullName());
        user.setPhone(incoming.getPhone());
        user.setGender(incoming.getGender());
        user.setStatus(incoming.getStatus() != null ? incoming.getStatus() : UserStatus.ACTIVE);
        user.setBalance(incoming.getBalance() != null ? incoming.getBalance() : BigDecimal.ZERO);

        // password
        if (passwordPlain != null && !passwordPlain.isBlank()) {
            user.setPasswordHash(passwordEncoder.encode(passwordPlain));
        } else if (creating) {
            user.setPasswordHash(passwordEncoder.encode("ChangeMe@123"));
        }

        if (creating) {
            user.setIsDeleted(false);
            // BẮT BUỘC lưu trước để có ID
            user = userRepository.save(user);
        }

        // Clear + FLUSH để xóa hẳn các hàng cũ trước khi add mới
        user.getUserRoles().clear();
        userRepository.flush();

        List<String> codes = (roleCodes == null || roleCodes.isEmpty()) ? List.of("USER") : roleCodes;

        for (String code : codes) {
            Role role = roleRepository.findByCode(code)
                    .orElseThrow(() -> new RuntimeException("Role không tồn tại: " + code));

            UserRole ur = new UserRole();
            ur.setUser(user);
            ur.setRole(role);
            // 🔑 Điền khóa lồng
            ur.getId().setUserId(user.getId());
            ur.getId().setRoleId(role.getId());

            user.getUserRoles().add(ur);
        }

        userRepository.save(user);
    }

    public User getFreshUserByUsername(String username) {
        // TODO Auto-generated method stub
        throw new UnsupportedOperationException("Unimplemented method 'getFreshUserByUsername'");
    }

    // --- CRUD: End of Admin Account Management ---
}
