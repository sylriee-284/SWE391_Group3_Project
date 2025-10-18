package vn.group3.marketplace.config;

import org.springframework.data.domain.AuditorAware;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

import java.util.Optional;

@Component("auditorAwareImpl")
public class AuditorAwareImpl implements AuditorAware<Long> {

    @Override
    @SuppressWarnings("null")
    public Optional<Long> getCurrentAuditor() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

        if (authentication == null || !authentication.isAuthenticated()) {
            return Optional.empty();
        }

        // Nếu user đã đăng nhập, lấy ID của user
        if (authentication.getPrincipal() instanceof vn.group3.marketplace.security.CustomUserDetails userDetails) {
            return Optional.ofNullable(userDetails.getId());
        }
        return Optional.empty();
    }
}