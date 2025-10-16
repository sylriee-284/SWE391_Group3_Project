package vn.group3.marketplace.util;

import java.util.regex.Pattern;

public class ValidationUtils {

    private ValidationUtils() {
        // Private constructor to prevent instantiation
    }

    // Pre-compiled patterns for better performance (avoid recompiling on every
    // call)
    private static final Pattern USERNAME_PATTERN = Pattern.compile("^[A-Za-z0-9_]+$");
    private static final Pattern EMAIL_PATTERN = Pattern.compile("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$");
    private static final Pattern PHONE_PATTERN = Pattern.compile("^[+]?[0-9]{10,15}$");
    private static final Pattern NUMERIC_STRING_PATTERN = Pattern.compile("^\\d+$");

    // Username validation
    public static boolean isValidUsername(String username) {
        if (username == null || username.trim().isEmpty()) {
            return false;
        }

        // Check length 4-20 characters
        if (username.length() < 4 || username.length() > 20) {
            return false;
        }

        // Check only contains letters, numbers and _ (use pre-compiled pattern)
        if (!USERNAME_PATTERN.matcher(username).matches()) {
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

        // Check length 12-128 characters
        if (password.length() < 12 || password.length() > 128) {
            return false;
        }

        // Use simple loops instead of regex for better performance
        boolean hasUppercase = false;
        boolean hasLowercase = false;
        boolean hasDigit = false;

        for (char c : password.toCharArray()) {
            if (Character.isUpperCase(c)) {
                hasUppercase = true;
            } else if (Character.isLowerCase(c)) {
                hasLowercase = true;
            } else if (Character.isDigit(c)) {
                hasDigit = true;
            }

            // Early exit if all conditions met
            if (hasUppercase && hasLowercase && hasDigit) {
                return true;
            }
        }

        return hasUppercase && hasLowercase && hasDigit;
    }

    // Email validation
    public static boolean isValidEmail(String email) {
        if (email == null || email.trim().isEmpty()) {
            return false;
        }

        return EMAIL_PATTERN.matcher(email).matches();
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

    // Validate phone number format
    public static boolean isValidPhone(String phone) {
        if (phone == null || phone.trim().isEmpty()) {
            return false;
        }
        return PHONE_PATTERN.matcher(phone).matches();
    }

    // Validate numeric string (only digits)
    public static boolean isValidNumericString(String value) {
        if (value == null || value.trim().isEmpty()) {
            return false;
        }
        return NUMERIC_STRING_PATTERN.matcher(value).matches();
    }

    // Universal validator for import templates
    // Validates value based on validation_rule
    public static boolean validateByRule(String value, String rule) {
        if (rule == null || rule.isEmpty()) {
            return true;
        }

        if (value == null || value.trim().isEmpty()) {
            return false;
        }

        String trimmedValue = value.trim();

        switch (rule) {
            case "email_format":
                return isValidEmail(trimmedValue);

            case "phone_format":
                return isValidPhone(trimmedValue);

            case "numeric_string":
                return isValidNumericString(trimmedValue);
            case "email_or_phone":
                return isValidEmail(trimmedValue) || isValidPhone(trimmedValue);
        }

        // Parameterized rules
        if (rule.startsWith("min_length:")) {
            int minLength = Integer.parseInt(rule.substring(11));
            return trimmedValue.length() >= minLength;
        }

        // Default: accept all
        return true;
    }

    // Get error message for validation rule
    public static String getValidationErrorMessage(String rule) {
        if (rule == null || rule.isEmpty()) {
            return "Giá trị không hợp lệ";
        }

        switch (rule) {
            case "email_format":
                return "Email không đúng định dạng";
            case "phone_format":
                return "Số điện thoại không đúng định dạng";
            case "numeric_string":
                return "Chỉ chấp nhận số";
            case "email_or_phone":
                return "Phải là email hoặc số điện thoại hợp lệ";
            default:
                if (rule.startsWith("min_length:")) {
                    return "Tối thiểu " + rule.substring(11) + " ký tự";
                }
                return "Giá trị không hợp lệ";
        }
    }
}
