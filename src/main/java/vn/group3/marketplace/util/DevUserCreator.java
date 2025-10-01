package vn.group3.marketplace.util;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import vn.group3.marketplace.domain.entity.User;
import vn.group3.marketplace.repository.UserRepository;
import vn.group3.marketplace.service.interfaces.WalletService;

import java.util.Optional;

/**
 * Utility to manually create development user
 */
@Component
@Slf4j
public class DevUserCreator {

    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private PasswordEncoder passwordEncoder;
    
    @Autowired
    private WalletService walletService;

    /**
     * Manually create development user if not exists
     * TEMPORARY FIX: Always return user with ID = 4
     */
    public User createOrGetDevUser() {
        // TEMPORARY FIX: Check if user with ID = 4 exists
        Optional<User> existingUser = userRepository.findById(4L);
        if (existingUser.isPresent()) {
            User user = existingUser.get();
            log.info("Found existing user with ID 4: {} ({})", user.getUsername(), user.getEmail());
            return user;
        }

        // Check if devuser exists but with different ID
        Optional<User> devUserByUsername = userRepository.findByUsername("devuser");
        if (devUserByUsername.isPresent()) {
            User user = devUserByUsername.get();
            log.info("Found devuser with ID: {} (will use this)", user.getId());
            return user;
        }

        log.info("Creating development user with temporary fix...");

        try {
            // Create development user
            User devUser = User.builder()
                    .username("devuser")
                    .email("dev@taphoammo.com")
                    .passwordHash(passwordEncoder.encode("password123"))
                    .fullName("Development User (ID=4)")
                    .phone("0123456789")
                    .status("active")
                    .enabled(true)
                    .accountNonLocked(true)
                    .accountNonExpired(true)
                    .credentialsNonExpired(true)
                    .build();

            // Set audit fields manually
            devUser.setCreatedBy(1L);

            // Save user
            User savedUser = userRepository.save(devUser);
            log.info("Saved development user: {} with ID: {}", savedUser.getUsername(), savedUser.getId());

            // Create wallet for dev user
            try {
                walletService.createWallet(savedUser);
                log.info("Created wallet for development user: {}", savedUser.getId());
            } catch (Exception e) {
                log.warn("Failed to create wallet for dev user: {}", e.getMessage());
            }

            return savedUser;

        } catch (Exception e) {
            log.error("Failed to create development user: {}", e.getMessage(), e);
            throw new RuntimeException("Could not create development user", e);
        }
    }
}
