package vn.group3.marketplace.domain.enums;

/**
 * Product categories for marketplace
 */
public enum ProductCategory {
    GAME_ACCOUNT("Tài khoản Game"),
    GAME_CURRENCY("Vàng/Tiền Game"),
    SOCIAL_ACCOUNT("Tài khoản MXH"),
    SOFTWARE_LICENSE("License Phần mềm"),
    GIFT_CARD("Thẻ quà tặng"),
    VPN_PROXY("VPN/Proxy"),
    OTHER("Khác");

    private final String displayName;

    ProductCategory(String displayName) {
        this.displayName = displayName;
    }

    public String getDisplayName() {
        return displayName;
    }

    /**
     * Get category by name (case-insensitive)
     */
    public static ProductCategory fromString(String name) {
        if (name == null) return OTHER;

        try {
            return ProductCategory.valueOf(name.toUpperCase());
        } catch (IllegalArgumentException e) {
            return OTHER;
        }
    }

    /**
     * Check if category name is valid
     */
    public static boolean isValid(String name) {
        if (name == null) return false;

        try {
            ProductCategory.valueOf(name.toUpperCase());
            return true;
        } catch (IllegalArgumentException e) {
            return false;
        }
    }
}
