package vn.group3.marketplace.service;

import java.math.BigDecimal;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import lombok.RequiredArgsConstructor;
import vn.group3.marketplace.domain.entity.Role;
import vn.group3.marketplace.domain.entity.User;
import vn.group3.marketplace.domain.entity.Wallet;
import vn.group3.marketplace.domain.enums.UserStatus;
import vn.group3.marketplace.repository.RoleRepository;
import vn.group3.marketplace.repository.UserRepository;
import vn.group3.marketplace.repository.WalletRepository;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final WalletRepository walletRepository;
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

        // Tạo user mới
        User user = User.builder()
                .username(username)
                .email(email)
                .passwordHash(passwordEncoder.encode(rawPassword))
                .status(UserStatus.ACTIVE)
                .build();

        // Gán role mặc định
        Role role = roleRepository.findByCode("USER")
                .orElseThrow(() -> new RuntimeException("Role USER không tồn tại"));
        user.getRoles().add(role);

        // Lưu user trước
        User savedUser = userRepository.save(user);

        // Tạo ví liên kết sau khi user đã có ID
        Wallet wallet = Wallet.builder()
                .user(savedUser)
                .balance(0.0)
                .build();

        // Lưu wallet
        walletRepository.save(wallet);
    }

}
