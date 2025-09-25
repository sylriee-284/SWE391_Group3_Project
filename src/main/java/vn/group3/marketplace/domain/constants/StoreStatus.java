package vn.group3.marketplace.domain.constants;

/**
 * Constants for seller store status values
 * Provides type-safe status management
 */
public final class StoreStatus {
    
    // Store status values
    public static final String ACTIVE = "active";
    public static final String INACTIVE = "inactive";
    public static final String SUSPENDED = "suspended";
    public static final String PENDING_VERIFICATION = "pending_verification";
    public static final String REJECTED = "rejected";
    public static final String CLOSED = "closed";
    
    // Display names for status
    public static final String DISPLAY_ACTIVE = "Hoạt động";
    public static final String DISPLAY_INACTIVE = "Không hoạt động";
    public static final String DISPLAY_SUSPENDED = "Tạm ngưng";
    public static final String DISPLAY_PENDING = "Chờ xác minh";
    public static final String DISPLAY_REJECTED = "Bị từ chối";
    public static final String DISPLAY_CLOSED = "Đã đóng";
    
    // Private constructor to prevent instantiation
    private StoreStatus() {
        throw new UnsupportedOperationException("This is a utility class and cannot be instantiated");
    }
    
    /**
     * Check if status is valid
     * @param status Status to validate
     * @return true if valid, false otherwise
     */
    public static boolean isValidStatus(String status) {
        return ACTIVE.equals(status) || 
               INACTIVE.equals(status) || 
               SUSPENDED.equals(status) || 
               PENDING_VERIFICATION.equals(status) || 
               REJECTED.equals(status) || 
               CLOSED.equals(status);
    }
    
    /**
     * Get display name for status
     * @param status Status value
     * @return Display name
     */
    public static String getDisplayName(String status) {
        if (status == null) return "Không xác định";
        
        return switch (status) {
            case ACTIVE -> DISPLAY_ACTIVE;
            case INACTIVE -> DISPLAY_INACTIVE;
            case SUSPENDED -> DISPLAY_SUSPENDED;
            case PENDING_VERIFICATION -> DISPLAY_PENDING;
            case REJECTED -> DISPLAY_REJECTED;
            case CLOSED -> DISPLAY_CLOSED;
            default -> "Không xác định";
        };
    }
    
    /**
     * Check if store is operational (can accept orders)
     * @param status Store status
     * @param isActive Store active flag
     * @param isVerified Store verified flag
     * @return true if operational
     */
    public static boolean isOperational(String status, Boolean isActive, Boolean isVerified) {
        return ACTIVE.equals(status) && 
               Boolean.TRUE.equals(isActive) && 
               Boolean.TRUE.equals(isVerified);
    }
}
