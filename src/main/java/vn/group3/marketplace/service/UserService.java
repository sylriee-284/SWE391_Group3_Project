package vn.group3.marketplace.service;

import java.math.BigDecimal;
import java.util.Optional;

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
                .balance(BigDecimal.ZERO)
                .build();

        // Assign default role
        Role role = roleRepository.findByCode("USER")
                .orElseThrow(() -> new RuntimeException("Role USER does not exist"));
        UserRole userRole = UserRole.builder()
                .user(user)
                .role(role)
                .id(new UserRole.UserRoleId(null, null)) // id sẽ được tự động set khi persist
                .build();
        user.getUserRoles().add(userRole);

        // Save user (cascade sẽ tự động lưu userRole)
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

    /**
     * Get user by username
     * 
     * @param username Username
     * @return User or null if not found
     */
    public User getUserByUsername(String username) {
        return userRepository.findByUsername(username).orElse(null);
    }

    /**
     * Get user by ID
     * 
     * @param id User ID
     * @return User or null if not found
     */
    public User getUserById(Long id) {
        return userRepository.findById(id).orElse(null);
    }

    /**
     * Update user information
     * 
     * @param user User to update
     * @return Updated user
     */
    @Transactional
    public User updateUser(User user) {
        System.out.println("💾 UserService.updateUser() called for user ID: " + user.getId());
        System.out.println("💾 Saving: " + user.getFullName() + " | " + user.getEmail());
        User savedUser = userRepository.saveAndFlush(user);
        System.out.println("💾 User saved successfully!");
        return savedUser;
    }

    /**
     * Get fresh user data from database (bypass cache)
     * 
     * @param username Username
     * @return Fresh user data
     */
    @Transactional(readOnly = true)
    public User getFreshUserByUsername(String username) {
        System.out.println("🔍 UserService.getFreshUserByUsername() called for: " + username);
        // Force a fresh query from database
        User user = userRepository.findByUsername(username).orElse(null);
        System.out.println("🔍 Fresh user retrieved: " + (user != null ? user.getFullName() : "NULL"));
        return user;
    }

    /**
     * Force flush and clear entity manager to ensure immediate persistence
     */
    @Transactional
    public void flushAndClear() {
        userRepository.flush();
    }

}
