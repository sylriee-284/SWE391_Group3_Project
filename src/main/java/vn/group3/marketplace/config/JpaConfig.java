package vn.group3.marketplace.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.domain.AuditorAware;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import vn.group3.marketplace.domain.entity.User;

import java.util.Optional;

/**
 * JPA Configuration for audit trail support
 * Enables automatic population of created_by and updated_by fields
 */
@Configuration
@EnableJpaAuditing(auditorAwareRef = "auditorProvider")
public class JpaConfig {

    /**
     * Provides current user ID for audit trail
     * @return AuditorAware implementation
     */
    @Bean
    public AuditorAware<Long> auditorProvider() {
        return new AuditorAwareImpl();
    }

    /**
     * Implementation of AuditorAware to get current user ID
     */
    public static class AuditorAwareImpl implements AuditorAware<Long> {

        @Override
        public Optional<Long> getCurrentAuditor() {
            Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
            
            if (authentication == null || !authentication.isAuthenticated() || 
                "anonymousUser".equals(authentication.getPrincipal())) {
                return Optional.empty();
            }

            // If principal is User object
            if (authentication.getPrincipal() instanceof User) {
                User user = (User) authentication.getPrincipal();
                return Optional.of(user.getId());
            }

            // If principal is username string, we would need to look up the user
            // For now, return empty for simplicity
            return Optional.empty();
        }
    }
}
