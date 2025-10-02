package vn.group3.marketplace.service;

import java.math.BigDecimal;
import java.util.Optional;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import lombok.RequiredArgsConstructor;
import vn.group3.marketplace.domain.entity.Role;
import vn.group3.marketplace.domain.entity.User;
import vn.group3.marketplace.domain.enums.UserStatus;
import vn.group3.marketplace.repository.RoleRepository;
import vn.group3.marketplace.repository.UserRepository;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final PasswordEncoder passwordEncoder;

    @Transactional
    public void registerUser(String username, String email, String rawPassword) {
        // Kiểm tra username trùng
        if (userRepository.findByUsername(username).isPresent()) {
            throw new IllegalArgumentException("Username đã tồn tại!");
        }

        // Kiểm tra email trùng
        if (userRepository.findByEmail(email).isPresent()) {
            throw new IllegalArgumentException("Email đã tồn tại!");
        }

        // Tạo user mới với balance mặc định
        User user = User.builder()
                .username(username)
                .email(email)
                .passwordHash(passwordEncoder.encode(rawPassword))
                .status(UserStatus.ACTIVE)
                .balance(BigDecimal.ZERO) // Balance được lưu trực tiếp trong User
                .build();

        // Gán role mặc định
        Role role = roleRepository.findByCode("USER")
                .orElseThrow(() -> new RuntimeException("Role USER không tồn tại"));
        user.getRoles().add(role);

        // Lưu user
        userRepository.save(user);
    }

    public Optional<User> findByUsername(String username) {
        return userRepository.findByUsername(username);
    }
}
