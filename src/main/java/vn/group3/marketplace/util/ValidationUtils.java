package vn.group3.marketplace.util;

import java.math.BigDecimal;
import java.util.regex.Pattern;
import vn.group3.marketplace.dto.OrderTask;

public class ValidationUtils {

    private ValidationUtils() {
        // Private constructor to prevent instantiation
    }

    // Username validation
    public static boolean isValidUsername(String username) {
        if (username == null || username.trim().isEmpty()) {
            return false;
        }

        // Check length 4-20 characters
        if (username.length() < 4 || username.length() > 20) {
            return false;
        }

        // Check only contains letters, numbers and _
        if (!Pattern.matches("^[A-Za-z0-9_]+$", username)) {
            return false;
        }

        // Check cannot start or end with _
        if (username.startsWith("_") || username.endsWith("_")) {
            return false;
        }

        return true;
    }

    // Password validation
    public static boolean isValidPassword(String password) {
        if (password == null || password.trim().isEmpty()) {
            return false;
        }

        // Check minimum length 12 characters
        if (password.length() < 12) {
            return false;
        }

        // Check maximum length 128 characters
        if (password.length() > 128) {
            return false;
        }

        // Check has at least 1 uppercase
        if (!Pattern.matches(".*[A-Z].*", password)) {
            return false;
        }

        // Check has at least 1 lowercase
        if (!Pattern.matches(".*[a-z].*", password)) {
            return false;
        }

        // Check has at least 1 number
        if (!Pattern.matches(".*\\d.*", password)) {
            return false;
        }

        return true;
    }

    // Email validation
    public static boolean isValidEmail(String email) {
        if (email == null || email.trim().isEmpty()) {
            return false;
        }

        // Regex pattern for email validation
        String emailPattern = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$";
        return Pattern.matches(emailPattern, email);
    }

    // Get username validation error message
    public static String getUsernameErrorMessage() {
        return "Username: 4-20 characters, only letters, numbers and _, cannot start/end with _";
    }

    // Get password validation error message
    public static String getPasswordErrorMessage() {
        return "Password: ít nhất 12 ký tự, có ít nhất 1 chữ hoa, 1 chữ thường, 1 số và ký tự đặc biệt (đề xuất)";
    }

    // Get email validation error message
    public static String getEmailErrorMessage() {
        return "Invalid email format";
    }

    // Validate order data
    public static boolean validateOrderData(OrderTask orderTask) {
        if (orderTask == null) {
            return false;
        }

        // Validate userId
        if (orderTask.getUserId() == null || orderTask.getUserId() <= 0) {
            return false;
        }

        // Validate productId
        if (orderTask.getProductId() == null || orderTask.getProductId() <= 0) {
            return false;
        }

        // Validate sellerStoreId
        if (orderTask.getSellerStoreId() == null || orderTask.getSellerStoreId() <= 0) {
            return false;
        }

        // Validate quantity
        if (orderTask.getQuantity() == null || orderTask.getQuantity() <= 0) {
            return false;
        }

        // Validate totalAmount
        if (orderTask.getTotalAmount() == null || orderTask.getTotalAmount().compareTo(BigDecimal.ZERO) <= 0) {
            return false;
        }

        // Validate productName
        if (orderTask.getProductName() == null || orderTask.getProductName().trim().isEmpty()) {
            return false;
        }

        // Validate productData (optional but if present should not be empty)
        if (orderTask.getProductData() != null && orderTask.getProductData().trim().isEmpty()) {
            return false;
        }

        return true;
    }

    // Get order validation error message
    public static String getOrderValidationErrorMessage() {
        return "Order validation failed: userId, productId, sellerStoreId must be positive, quantity must be > 0, totalAmount must be > 0, productName cannot be empty";
    }
}
