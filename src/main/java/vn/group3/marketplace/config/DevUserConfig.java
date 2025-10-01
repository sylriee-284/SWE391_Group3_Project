package vn.group3.marketplace.config;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.security.crypto.password.PasswordEncoder;
import vn.group3.marketplace.domain.entity.Role;
import vn.group3.marketplace.domain.entity.User;
import vn.group3.marketplace.repository.RoleRepository;
import vn.group3.marketplace.repository.UserRepository;
import vn.group3.marketplace.service.interfaces.WalletService;

import java.time.LocalDateTime;
import java.util.Optional;

/**
 * Development configuration for creating mock users
 * Only active when Spring Security is disabled
 */
@Configuration
@Slf4j
public class DevUserConfig {

    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private RoleRepository roleRepository;
    
    @Autowired
    private PasswordEncoder passwordEncoder;
    
    @Autowired
    private WalletService walletService;

    /**
     * Create development users when application starts
     */
    @Bean
    public CommandLineRunner createDevUsers() {
        return args -> {
            try {
                createDevUserIfNotExists();
            } catch (Exception e) {
                log.warn("Failed to create dev user: {}", e.getMessage());
            }
        };
    }

    private void createDevUserIfNotExists() {
        // Check if dev user already exists
        Optional<User> existingUser = userRepository.findByUsername("devuser");
        if (existingUser.isPresent()) {
            User user = existingUser.get();
            log.info("Development user already exists: devuser with ID: {}", user.getId());
            return;
        }

        log.info("Creating development user...");

        // Create development user
        User devUser = User.builder()
                .username("devuser")
                .email("dev@taphoammo.com")
                .passwordHash(passwordEncoder.encode("password123"))
                .fullName("Development User")
                .phone("0123456789")
                .status("active")
                .enabled(true)
                .accountNonLocked(true)
                .accountNonExpired(true)
                .credentialsNonExpired(true)
                .build();

        // Set audit fields manually
        devUser.setCreatedBy(1L);

        try {
            // Save user
            User savedUser = userRepository.save(devUser);
            log.info("Saved development user: {} with ID: {}", savedUser.getUsername(), savedUser.getId());

            // Create wallet for dev user
            walletService.createWallet(savedUser);
            log.info("Created wallet for development user: {}", savedUser.getId());

        } catch (Exception e) {
            log.error("Failed to create development user: {}", e.getMessage(), e);
            throw e; // Re-throw to see the full error
        }
    }

    /**
     * Get development user for controllers
     */
    public static User getDevUser(UserRepository userRepository) {
        return userRepository.findByUsername("devuser")
                .orElseThrow(() -> new IllegalStateException("Development user not found. Please restart the application."));
    }
}
