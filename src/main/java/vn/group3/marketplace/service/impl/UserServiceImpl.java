package vn.group3.marketplace.service.impl;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.group3.marketplace.domain.entity.Role;
import vn.group3.marketplace.domain.entity.User;
import vn.group3.marketplace.repository.RoleRepository;
import vn.group3.marketplace.repository.UserRepository;
import vn.group3.marketplace.service.interfaces.UserService;
import vn.group3.marketplace.service.interfaces.WalletService;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * Implementation of UserService interface
 * Handles all user-related business logic
 */
@Service
@Transactional
@RequiredArgsConstructor
@Slf4j
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final WalletService walletService;
    private final PasswordEncoder passwordEncoder;

    @Override
    public User registerUser(User user, String rawPassword) {
        log.info("Registering new user: {}", user.getUsername());
        
        // Validate username and email availability
        if (!isUsernameAvailable(user.getUsername())) {
            throw new IllegalArgumentException("Username already exists: " + user.getUsername());
        }
        
        if (!isEmailAvailable(user.getEmail())) {
            throw new IllegalArgumentException("Email already exists: " + user.getEmail());
        }
        
        // Encrypt password
        user.setPasswordHash(passwordEncoder.encode(rawPassword));
        
        // Set default values
        user.setStatus("active");
        user.setEnabled(true);
        user.setAccountNonLocked(true);
        user.setAccountNonExpired(true);
        user.setCredentialsNonExpired(true);
        
        // Assign default role (BUYER)
        List<Role> defaultRoles = roleRepository.findDefaultRoles();
        user.getRoles().addAll(defaultRoles);
        
        // Save user
        User savedUser = userRepository.save(user);
        
        // Create wallet for user
        walletService.createWallet(savedUser);
        
        log.info("User registered successfully: {}", savedUser.getUsername());
        return savedUser;
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<User> findById(Long id) {
        return userRepository.findByIdWithRoles(id);
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<User> findByUsername(String username) {
        return userRepository.findByUsernameWithRoles(username);
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<User> findByEmail(String email) {
        return userRepository.findByEmail(email);
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<User> findByUsernameOrEmail(String usernameOrEmail) {
        return userRepository.findByUsernameOrEmail(usernameOrEmail, usernameOrEmail);
    }

    @Override
    public User updateUser(User user) {
        log.info("Updating user: {}", user.getId());
        
        User existingUser = userRepository.findById(user.getId())
            .orElseThrow(() -> new IllegalArgumentException("User not found: " + user.getId()));
        
        // Update allowed fields
        existingUser.setFullName(user.getFullName());
        existingUser.setPhone(user.getPhone());
        existingUser.setAvatarUrl(user.getAvatarUrl());
        existingUser.setDateOfBirth(user.getDateOfBirth());
        existingUser.setGender(user.getGender());
        
        return userRepository.save(existingUser);
    }

    @Override
    public boolean changePassword(Long userId, String oldPassword, String newPassword) {
        log.info("Changing password for user: {}", userId);
        
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new IllegalArgumentException("User not found: " + userId));
        
        // Verify old password
        if (!passwordEncoder.matches(oldPassword, user.getPasswordHash())) {
            log.warn("Invalid old password for user: {}", userId);
            return false;
        }
        
        // Update password
        user.setPasswordHash(passwordEncoder.encode(newPassword));
        userRepository.save(user);
        
        log.info("Password changed successfully for user: {}", userId);
        return true;
    }

    @Override
    public User updateUserStatus(Long userId, String status) {
        log.info("Updating status for user {} to {}", userId, status);

        User user = userRepository.findById(userId)
            .orElseThrow(() -> new IllegalArgumentException("User not found: " + userId));

        user.setStatus(status);
        return userRepository.save(user);
    }

    @Override
    public User setUserEnabled(Long userId, boolean enabled) {
        log.info("Setting enabled status for user {} to {}", userId, enabled);
        
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new IllegalArgumentException("User not found: " + userId));
        
        user.setEnabled(enabled);
        return userRepository.save(user);
    }

    @Override
    public User setUserLocked(Long userId, boolean locked) {
        log.info("Setting locked status for user {} to {}", userId, locked);
        
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new IllegalArgumentException("User not found: " + userId));
        
        user.setAccountNonLocked(!locked);
        return userRepository.save(user);
    }

    @Override
    public void deleteUser(Long userId, Long deletedBy) {
        log.info("Soft deleting user {} by user {}", userId, deletedBy);
        
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new IllegalArgumentException("User not found: " + userId));
        
        user.softDelete(deletedBy);
        userRepository.save(user);
    }

    @Override
    public void restoreUser(Long userId) {
        log.info("Restoring user: {}", userId);
        
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new IllegalArgumentException("User not found: " + userId));
        
        user.restore();
        userRepository.save(user);
    }

    @Override
    public User assignRole(Long userId, String roleCode) {
        log.info("Assigning role {} to user {}", roleCode, userId);
        
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new IllegalArgumentException("User not found: " + userId));
        
        Role role = roleRepository.findByCode(roleCode)
            .orElseThrow(() -> new IllegalArgumentException("Role not found: " + roleCode));
        
        user.addRole(role);
        return userRepository.save(user);
    }

    @Override
    public User removeRole(Long userId, String roleCode) {
        log.info("Removing role {} from user {}", roleCode, userId);
        
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new IllegalArgumentException("User not found: " + userId));
        
        Role role = roleRepository.findByCode(roleCode)
            .orElseThrow(() -> new IllegalArgumentException("Role not found: " + roleCode));
        
        user.removeRole(role);
        return userRepository.save(user);
    }

    @Override
    @Transactional(readOnly = true)
    public boolean isUsernameAvailable(String username) {
        return !userRepository.existsByUsername(username);
    }

    @Override
    @Transactional(readOnly = true)
    public boolean isEmailAvailable(String email) {
        return !userRepository.existsByEmail(email);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<User> getAllUsers(Pageable pageable) {
        return userRepository.findAllActive(pageable);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<User> searchUsers(String searchTerm, Pageable pageable) {
        return userRepository.searchUsers(searchTerm, pageable);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<User> getUsersByStatus(String status, Pageable pageable) {
        return userRepository.findByStatus(status, pageable);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<User> getUsersByRole(String roleCode, Pageable pageable) {
        return userRepository.findByRoleCode(roleCode, pageable);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<User> getUsersWithSellerStores(Pageable pageable) {
        return userRepository.findUsersWithSellerStores(pageable);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<User> getUsersWithMinBalance(BigDecimal minBalance, Pageable pageable) {
        return userRepository.findUsersWithMinBalance(minBalance, pageable);
    }

    @Override
    @Transactional(readOnly = true)
    public Map<String, Long> getUserStatistics() {
        Map<String, Long> stats = new HashMap<>();
        stats.put("total", userRepository.count());
        stats.put("active", userRepository.countByStatus("active"));
        stats.put("inactive", userRepository.countByStatus("inactive"));
        stats.put("suspended", userRepository.countByStatus("suspended"));
        stats.put("enabled", userRepository.countByEnabled(true));
        stats.put("disabled", userRepository.countByEnabled(false));
        return stats;
    }

    @Override
    @Transactional(readOnly = true)
    public boolean canCreateSellerStore(Long userId, BigDecimal depositAmount) {
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new IllegalArgumentException("User not found: " + userId));
        
        // Check if user already has a seller store
        if (user.getSellerStore() != null && !user.getSellerStore().isDeleted()) {
            return false;
        }
        
        // Check if user has SELLER role or can be assigned
        if (!user.hasRole("SELLER")) {
            // Auto-assign SELLER role if user doesn't have it
            try {
                assignRole(userId, "SELLER");
            } catch (Exception e) {
                log.warn("Could not assign SELLER role to user {}: {}", userId, e.getMessage());
                return false;
            }
        }
        
        // Check wallet balance
        return user.getWallet() != null && user.getWallet().canCoverDeposit(depositAmount);
    }
}
