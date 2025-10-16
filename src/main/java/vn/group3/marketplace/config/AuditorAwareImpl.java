package vn.group3.marketplace.config;

import org.springframework.data.domain.AuditorAware;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import vn.group3.marketplace.security.CustomUserDetails;

import java.util.Optional;

@Component
public class AuditorAwareImpl implements AuditorAware<Long> {

    @Override
    @SuppressWarnings("null")
    public Optional<Long> getCurrentAuditor() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

        // Nếu chưa login hoặc là anonymous user -> trả về empty (created_by = null)
        if (authentication == null ||
                !authentication.isAuthenticated() ||
                "anonymousUser".equals(authentication.getPrincipal())) {
            return Optional.empty();
        }

        // Nếu đã login -> lấy user ID từ CustomUserDetails
        if (authentication.getPrincipal() instanceof CustomUserDetails userDetails) {
            return Optional.of(userDetails.getId());
        }

        // Fallback: trả về empty nếu không xác định được user
        return Optional.empty();
    }
}