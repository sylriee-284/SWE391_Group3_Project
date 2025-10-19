package vn.group3.marketplace.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import vn.group3.marketplace.domain.entity.User;
import vn.group3.marketplace.repository.UserRepository;
import vn.group3.marketplace.security.CustomUserDetails;

/**
 * Service để refresh authentication context khi user data thay đổi
 * (ví dụ: balance được cập nhật sau khi mua hàng)
 */
@Service
public class AuthenticationRefreshService {

    private static final Logger logger = LoggerFactory.getLogger(AuthenticationRefreshService.class);
    private final UserRepository userRepository;

    public AuthenticationRefreshService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    /**
     * Refresh authentication context với thông tin user mới nhất từ database
     */
    public void refreshAuthenticationContext() {
        try {
            Authentication currentAuth = SecurityContextHolder.getContext().getAuthentication();
            if (currentAuth != null && currentAuth.getPrincipal() instanceof CustomUserDetails) {
                CustomUserDetails currentUserDetails = (CustomUserDetails) currentAuth.getPrincipal();
                String username = currentUserDetails.getUsername();

                logger.debug("Refreshing authentication context for user: {}", username);

                // Fetch lại user mới từ database (với số dư đã cập nhật)
                User refreshedUser = userRepository.findByUsername(username).orElse(null);
                if (refreshedUser != null) {
                    // Tạo CustomUserDetails mới với thông tin đã cập nhật
                    CustomUserDetails newUserDetails = new CustomUserDetails(refreshedUser);

                    // Tạo authentication object mới
                    UsernamePasswordAuthenticationToken newAuth = new UsernamePasswordAuthenticationToken(
                            newUserDetails,
                            currentAuth.getCredentials(),
                            newUserDetails.getAuthorities());

                    // Cập nhật SecurityContext
                    SecurityContextHolder.getContext().setAuthentication(newAuth);

                    logger.info("Authentication context refreshed for user: {} with new balance: {}",
                            username, refreshedUser.getBalance());
                } else {
                    logger.warn("User not found when refreshing authentication context: {}", username);
                }
            } else {
                logger.debug("No valid authentication found to refresh");
            }
        } catch (Exception e) {
            logger.error("Failed to refresh authentication context: {}", e.getMessage(), e);
            throw new RuntimeException("Failed to refresh authentication context", e);
        }
    }

    /**
     * Refresh authentication context cho một user cụ thể
     * 
     * @param userId User ID cần refresh
     */
    public void refreshAuthenticationContextForUser(Long userId) {
        try {
            Authentication currentAuth = SecurityContextHolder.getContext().getAuthentication();
            if (currentAuth != null && currentAuth.getPrincipal() instanceof CustomUserDetails) {
                CustomUserDetails currentUserDetails = (CustomUserDetails) currentAuth.getPrincipal();

                // Chỉ refresh nếu đúng user
                if (currentUserDetails.getId().equals(userId)) {
                    refreshAuthenticationContext();
                } else {
                    logger.debug("Current user {} is not the target user {} for refresh",
                            currentUserDetails.getId(), userId);
                }
            }
        } catch (Exception e) {
            logger.error("Failed to refresh authentication context for user {}: {}", userId, e.getMessage(), e);
        }
    }

    /**
     * Kiểm tra và refresh authentication context nếu cần thiết
     * 
     * @param userId          User ID cần kiểm tra
     * @param expectedBalance Số dư mong đợi
     */
    public void refreshIfBalanceChanged(Long userId, java.math.BigDecimal expectedBalance) {
        try {
            Authentication currentAuth = SecurityContextHolder.getContext().getAuthentication();
            if (currentAuth != null && currentAuth.getPrincipal() instanceof CustomUserDetails) {
                CustomUserDetails currentUserDetails = (CustomUserDetails) currentAuth.getPrincipal();

                if (currentUserDetails.getId().equals(userId)) {
                    // So sánh số dư hiện tại với số dư mong đợi
                    if (currentUserDetails.getBalance().compareTo(expectedBalance) != 0) {
                        logger.info("Balance mismatch detected for user {}. Current: {}, Expected: {}. Refreshing...",
                                userId, currentUserDetails.getBalance(), expectedBalance);
                        refreshAuthenticationContext();
                    }
                }
            }
        } catch (Exception e) {
            logger.error("Failed to refresh authentication context for balance check: {}", e.getMessage(), e);
        }
    }
}
