package vn.group3.marketplace.service;

import java.sql.Timestamp;
import java.util.List;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Optional;
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
        // Tạo mới user (admin thêm user)
        user.setId(null); // đảm bảo là insert mới
        // user.setCreatedAt(Timestamp.valueOf(LocalDateTime.now()));
        user.setIsDeleted(false);
        user.setStatus(UserStatus.ACTIVE);
        return userRepository.save(user);
    }

    public User updateUser(Long id, User updatedUser) {
        // Cập nhật thông tin user
        return userRepository.findById(id).map(existing -> {
            existing.setFullName(updatedUser.getFullName());
            existing.setEmail(updatedUser.getEmail());
            existing.setPhone(updatedUser.getPhone());
            existing.setGender(updatedUser.getGender());
            existing.setStatus(updatedUser.getStatus());
            // existing.setUpdatedAt(Timestamp.valueOf(LocalDateTime.now()));
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
    // --- CRUD: End of Admin Account Management ---
}
