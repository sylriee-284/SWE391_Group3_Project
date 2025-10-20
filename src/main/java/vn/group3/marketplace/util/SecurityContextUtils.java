package vn.group3.marketplace.util;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.core.context.SecurityContextHolder;
import vn.group3.marketplace.security.CustomUserDetails;

/**
 * Utility class for handling SecurityContext operations
 * Provides reusable methods for getting current user information
 */
public class SecurityContextUtils {

    private static final Logger logger = LoggerFactory.getLogger(SecurityContextUtils.class);

    private SecurityContextUtils() {
        // Private constructor to prevent instantiation
    }

    /**
     * Lấy ID của user hiện tại từ SecurityContext
     * 
     * @return ID của user hiện tại, hoặc null nếu không thể lấy được
     */
    public static Long getCurrentUserId() {
        try {
            var authentication = SecurityContextHolder.getContext().getAuthentication();
            
            if (authentication == null || !authentication.isAuthenticated()) {
                return null;
            }
            
            var principal = authentication.getPrincipal();
            
            if (principal instanceof CustomUserDetails userDetails) {
                return userDetails.getId();
            }
            
            return null;
        } catch (Exception e) {
            logger.warn("Could not get current user ID from SecurityContext: {}", e.getMessage());
            return null;
        }
    }

    /**
     * Lấy thông tin User hiện tại từ SecurityContext
     * 
     * @return CustomUserDetails của user hiện tại, hoặc null nếu không thể lấy được
     */
    public static CustomUserDetails getCurrentUserDetails() {
        try {
            return (CustomUserDetails) SecurityContextHolder.getContext()
                    .getAuthentication().getPrincipal();
        } catch (Exception e) {
            logger.warn("Could not get current user details from SecurityContext: {}", e.getMessage());
            return null;
        }
    }

    /**
     * Kiểm tra xem có user nào đang đăng nhập không
     * 
     * @return true nếu có user đang đăng nhập, false nếu không
     */
    public static boolean isUserAuthenticated() {
        try {
            return SecurityContextHolder.getContext().getAuthentication() != null
                    && SecurityContextHolder.getContext().getAuthentication().isAuthenticated()
                    && SecurityContextHolder.getContext().getAuthentication()
                            .getPrincipal() instanceof CustomUserDetails;
        } catch (Exception e) {
            logger.warn("Could not check authentication status: {}", e.getMessage());
            return false;
        }
    }

    /**
     * Lấy username của user hiện tại từ SecurityContext
     * 
     * @return username của user hiện tại, hoặc null nếu không thể lấy được
     */
    public static String getCurrentUsername() {
        try {
            CustomUserDetails userDetails = getCurrentUserDetails();
            return userDetails != null ? userDetails.getUsername() : null;
        } catch (Exception e) {
            logger.warn("Could not get current username from SecurityContext: {}", e.getMessage());
            return null;
        }
    }
}
