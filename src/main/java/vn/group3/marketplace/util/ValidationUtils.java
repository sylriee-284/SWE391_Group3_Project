package vn.group3.marketplace.util;

import java.util.regex.Pattern;

public class ValidationUtils {

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

        // Check minimum length 8 characters
        if (password.length() < 8) {
            return false;
        }

        // Check starts with uppercase
        if (!Pattern.matches("^[A-Z].*", password)) {
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
        return "Password: at least 8 characters, start with uppercase, must have at least 1 uppercase, 1 lowercase, 1 number";
    }

    // Get email validation error message
    public static String getEmailErrorMessage() {
        return "Invalid email format";
    }
}
