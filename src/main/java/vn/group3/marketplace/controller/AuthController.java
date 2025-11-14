package vn.group3.marketplace.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import jakarta.servlet.http.*;
import vn.group3.marketplace.security.CustomUserDetailsService;
import vn.group3.marketplace.service.*;
import vn.group3.marketplace.util.ValidationUtils;

import java.io.IOException;

@Controller
public class AuthController {

    private final EmailService emailService;
    @Autowired
    private UserService userService;

    @Autowired
    private CaptchaService captchaService;

    @Autowired
    private CustomUserDetailsService userDetailsService;

    @Autowired
    private PasswordEncoder passwordEncoder;

    private static final String CAPTCHA_SESSION_KEY = "CAPTCHA_TEXT";

    AuthController(EmailService emailService) {
        this.emailService = emailService;
    }

    @GetMapping("/login")
    public String loginPage(
            @RequestParam(value = "error", required = false) String error,
            @RequestParam(value = "errorMessage", required = false) String errorMessage,
            Model model) {

        if (error != null) {
            model.addAttribute("errorMessage", error);
        }

        if (errorMessage != null) {
            model.addAttribute("errorMessage", errorMessage);
        }

        return "login";
    }

    @GetMapping("/login/captcha")
    public void getCaptcha(HttpSession session, HttpServletResponse response) throws IOException {
        // 1. Generate captcha text (4 digits)
        String captchaText = captchaService.generateCaptchaText();
        session.setAttribute(CAPTCHA_SESSION_KEY, captchaText);
        // 2. Generate captcha image from captcha text
        byte[] image = captchaService.generateCaptchaImage(captchaText);
        // 3. Set response headers
        response.setContentType("image/png");
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);
        // 4. Write image to response output stream
        response.getOutputStream().write(image); // Send data (byte array) from server to client via HTTP
        response.getOutputStream().flush();
    }

    @GetMapping("/register")
    public String registerPage() {
        return "register";
    }

    @PostMapping("/register")
    public String handleRegister(
            @RequestParam("username") String username,
            @RequestParam("email") String email,
            @RequestParam("password") String password,
            @RequestParam("repeatPassword") String repeatPassword,
            RedirectAttributes redirectAttributes,
            Model model,
            HttpSession session) {

        // Validate username
        if (!ValidationUtils.isValidUsername(username)) {
            model.addAttribute("errorMessage", ValidationUtils.getUsernameErrorMessage());
            model.addAttribute("username", username);
            model.addAttribute("email", email);
            return "register";
        }

        // Validate email
        if (!ValidationUtils.isValidEmail(email)) {
            model.addAttribute("errorMessage", ValidationUtils.getEmailErrorMessage());
            model.addAttribute("username", username);
            model.addAttribute("email", email);
            return "register";
        }

        // Validate password
        if (!ValidationUtils.isValidPassword(password)) {
            model.addAttribute("errorMessage", ValidationUtils.getPasswordErrorMessage());
            model.addAttribute("username", username);
            model.addAttribute("email", email);
            return "register";
        }

        // Check password match
        if (!password.equals(repeatPassword)) {
            model.addAttribute("errorMessage", "Passwords do not match!");
            model.addAttribute("username", username);
            model.addAttribute("email", email);
            return "register";
        }

        // Check if username or email already exists
        try {
            var existingUser = userService.findByUsernameOrEmail(username, email);
            if (existingUser.isPresent()) {
                var user = existingUser.get();
                // Check which field matches to show correct error message
                if (user.getUsername().equals(username)) {
                    model.addAttribute("errorMessage", "Username already exists!");
                } else {
                    model.addAttribute("errorMessage", "Email already exists!");
                }
                model.addAttribute("username", username);
                model.addAttribute("email", email);
                return "register";
            }

            // Generate OTP and store registration data in session
            String otp = captchaService.generateCaptchaText();
            session.setAttribute("registration_otp", otp);
            session.setAttribute("registration_otp_time", System.currentTimeMillis());
            session.setAttribute("registration_username", username);
            session.setAttribute("registration_email", email);
            session.setAttribute("registration_password", password);
            session.setAttribute("registration_time", 5);

            // Send OTP email
            emailService.sendEmailWithRegistrationOTPAsync(email, otp);

            redirectAttributes.addFlashAttribute("successMessage",
                    "An OTP has been sent to your email. Please check your inbox and verify your email to complete registration.");
            return "redirect:/verify-otp";

        } catch (IllegalArgumentException ex) {
            model.addAttribute("errorMessage", ex.getMessage());
            return "register";
        } catch (Exception ex) {
            model.addAttribute("errorMessage", "An error occurred. Please try again.");
            return "register";
        }
    }

    @PostMapping("/login")
    public String handleLogin(@RequestParam("username") String username,
            @RequestParam("password") String password,
            @RequestParam("captcha") String captcha,
            HttpSession session,
            Model model) {

        // Validate username
        if (!ValidationUtils.isValidUsername(username)) {
            model.addAttribute("errorMessage", ValidationUtils.getUsernameErrorMessage());
            return "login";
        }

        // Validate password
        if (!ValidationUtils.isValidPassword(password)) {
            model.addAttribute("errorMessage", ValidationUtils.getPasswordErrorMessage());
            return "login";
        }

        // Validate captcha first
        String sessionCaptcha = (String) session.getAttribute(CAPTCHA_SESSION_KEY);
        if (sessionCaptcha == null || !sessionCaptcha.equals(captcha)) {
            model.addAttribute("errorMessage", "Invalid captcha code!");
            return "login";
        }

        try {
            session.removeAttribute(CAPTCHA_SESSION_KEY);
            UserDetails userDetails = userDetailsService.loadUserByUsername(username);

            if (!passwordEncoder.matches(password, userDetails.getPassword())) {
                model.addAttribute("errorMessage", "Invalid username or password!");
                return "login";
            }

            // Tạo authentication token chứa thông tin user (username, roles)
            // - Principal: UserDetails (thông tin user)
            // - Credentials: null (không lưu password)
            // - Authorities: Danh sách roles [ROLE_USER, ROLE_SELLER, ...]
            UsernamePasswordAuthenticationToken authToken = new UsernamePasswordAuthenticationToken(userDetails, null,
                    userDetails.getAuthorities());

            // Lưu authentication vào SecurityContext (để Spring Security biết user
            // đã đăng nhập)
            // SecurityContext cho phép BẤT KỲ ĐÂU trong app cũng có thể lấy user hiện tại
            SecurityContextHolder.getContext().setAuthentication(authToken);
            session.setAttribute("SPRING_SECURITY_CONTEXT", SecurityContextHolder.getContext());

            return "redirect:/homepage";

        } catch (Exception e) {
            model.addAttribute("errorMessage", "Invalid username or password!");
            return "login";
        }
    }

    @GetMapping("/forgot-password")
    public String forgotPasswordPage() {
        return "forgot-password";
    }

    @PostMapping("/forgot-password")
    public String handleForgotPassword(@RequestParam String email, HttpSession session,
            RedirectAttributes redirectAttributes, Model model) {

        // Validate email
        if (!ValidationUtils.isValidEmail(email)) {
            model.addAttribute("errorMessage", ValidationUtils.getEmailErrorMessage());
            return "forgot-password";
        }

        try {
            String otp = captchaService.generateCaptchaText();
            session.setAttribute("otp", otp);
            session.setAttribute("otp_time", System.currentTimeMillis());
            session.setAttribute("reset_email", email);
            session.setAttribute("reset_time", 5); // Initialize with 5 attempts

            // Send reset password OTP email
            emailService.sendEmailWithResetPasswordOTPAsync(email, otp);
            redirectAttributes.addFlashAttribute("successMessage",
                    "Một email chứa mã OTP đã được gửi. Vui lòng kiểm tra hộp thư của bạn.");
            return "redirect:/reset-password";

        } catch (Exception e) {
            model.addAttribute("errorMessage", "Đã xảy ra lỗi không mong muốn. Vui lòng thử lại.");
            return "forgot-password";
        }
    }

    @GetMapping("/reset-password")
    public String showResetPasswordPage(HttpSession session, Model model) {
        // Initialize reset_time if not exists (first time visit)
        if (session.getAttribute("reset_time") == null) {
            session.setAttribute("reset_time", 5);
        }

        // Pass reset_time to view
        model.addAttribute("reset_time", session.getAttribute("reset_time"));
        return "reset-password";
    }

    @PostMapping("/reset-password")
    public String handleResetPassword(@RequestParam String otp, @RequestParam String newPassword,
            @RequestParam String email, HttpSession session, Model model, RedirectAttributes redirectAttributes) {

        // Validate password
        if (!ValidationUtils.isValidPassword(newPassword)) {
            model.addAttribute("errorMessage", ValidationUtils.getPasswordErrorMessage());
            model.addAttribute("reset_time", session.getAttribute("reset_time"));
            return "reset-password";
        }

        // Get OTP and time from session
        String sessionOtp = (String) session.getAttribute("otp");
        Long otpTime = (Long) session.getAttribute("otp_time");
        Integer resetTime = (Integer) session.getAttribute("reset_time");

        // Check if reset_time exists
        if (resetTime == null) {
            resetTime = 5;
            session.setAttribute("reset_time", resetTime);
        }

        // Check if reset time is 0 or less
        if (resetTime <= 0) {
            session.removeAttribute("otp");
            session.removeAttribute("otp_time");
            session.removeAttribute("reset_email");
            session.removeAttribute("reset_time");
            redirectAttributes.addFlashAttribute("errorMessage",
                    "Bạn đã hết lượt thử. Vui lòng yêu cầu đặt lại mật khẩu lại.");
            return "redirect:/forgot-password";
        }

        // Check if OTP session exists
        if (sessionOtp == null || otpTime == null) {
            redirectAttributes.addFlashAttribute("errorMessage",
                    "Không tìm thấy OTP. Vui lòng yêu cầu đặt lại mật khẩu lại.");
            return "redirect:/forgot-password";
        }

        // Check if OTP is valid and not expired (10 minutes)
        if (sessionOtp.equals(otp) && (System.currentTimeMillis() - otpTime < 600000)) {
            // If OTP is valid, update user's password
            userService.resetPassword(newPassword, email);

            // Clear all session data after successful reset
            session.removeAttribute("otp");
            session.removeAttribute("otp_time");
            session.removeAttribute("reset_email");
            session.removeAttribute("reset_time");

            // Set success message and redirect to login page
            redirectAttributes.addFlashAttribute("successMessage",
                    "Đặt lại mật khẩu thành công. Bạn có thể đăng nhập ngay bây giờ.");
            return "redirect:/login";
        } else {
            // If OTP is invalid or expired, decrement reset_time
            resetTime--;
            session.setAttribute("reset_time", resetTime);

            // Check if this was the last attempt
            if (resetTime <= 0) {
                session.removeAttribute("otp");
                session.removeAttribute("otp_time");
                session.removeAttribute("reset_email");
                session.removeAttribute("reset_time");
                redirectAttributes.addFlashAttribute("errorMessage",
                        "Bạn đã hết lượt thử. Vui lòng yêu cầu đặt lại mật khẩu lại.");
                return "redirect:/forgot-password";
            }

            // Check if OTP expired
            if (System.currentTimeMillis() - otpTime >= 600000) {
                model.addAttribute("errorMessage", "OTP đã hết hạn. Vui lòng yêu cầu đặt lại mật khẩu lại.");
            } else {
                model.addAttribute("errorMessage",
                        "OTP không hợp lệ. Bạn còn " + resetTime + " lần thử.");
            }

            model.addAttribute("reset_time", resetTime);
            return "reset-password";
        }
    }

    @GetMapping("/verify-otp")
    public String verifyOtpPage(HttpSession session, Model model) {
        // Initialize registration_time if not exists (first time visit)
        if (session.getAttribute("registration_time") == null) {
            session.setAttribute("registration_time", 5);
        }

        // Pass registration_time to view
        model.addAttribute("registration_time", session.getAttribute("registration_time"));
        return "verify-otp";
    }

    @PostMapping("/verify-otp")
    public String handleVerifyOtp(@RequestParam String otp, HttpSession session,
            RedirectAttributes redirectAttributes, Model model) {

        // Get OTP and time from session
        String sessionOtp = (String) session.getAttribute("registration_otp");
        Long otpTime = (Long) session.getAttribute("registration_otp_time");
        Integer registrationTime = (Integer) session.getAttribute("registration_time");

        // Check if registration_time exists
        if (registrationTime == null) {
            registrationTime = 5;
            session.setAttribute("registration_time", registrationTime);
        }

        // Check if registration time is 0 or less
        if (registrationTime <= 0) {
            session.removeAttribute("registration_otp");
            session.removeAttribute("registration_otp_time");
            session.removeAttribute("registration_username");
            session.removeAttribute("registration_email");
            session.removeAttribute("registration_password");
            session.removeAttribute("registration_time");
            redirectAttributes.addFlashAttribute("errorMessage",
                    "Bạn đã hết lượt thử. Vui lòng đăng ký lại.");
            return "redirect:/register";
        }

        // Check if OTP session exists
        if (sessionOtp == null || otpTime == null) {
            redirectAttributes.addFlashAttribute("errorMessage",
                    "Không tìm thấy OTP. Vui lòng đăng ký lại.");
            return "redirect:/register";
        }

        // Check if OTP is valid and not expired (10 minutes)
        if (sessionOtp.equals(otp) && (System.currentTimeMillis() - otpTime < 600000)) {
            try {
                // Get registration data from session
                String username = (String) session.getAttribute("registration_username");
                String email = (String) session.getAttribute("registration_email");
                String password = (String) session.getAttribute("registration_password");

                // Register user
                userService.registerUser(username, email, password);

                // Clear session data
                session.removeAttribute("registration_otp");
                session.removeAttribute("registration_otp_time");
                session.removeAttribute("registration_username");
                session.removeAttribute("registration_email");
                session.removeAttribute("registration_password");
                session.removeAttribute("registration_time");

                // Success message
                redirectAttributes.addFlashAttribute("successMessage",
                        "Đăng ký thành công! Vui lòng đăng nhập.");
                return "redirect:/login";

            } catch (Exception ex) {
                model.addAttribute("errorMessage", "Đăng ký thất bại. Vui lòng thử lại.");
                model.addAttribute("registration_time", registrationTime);
                return "verify-otp";
            }
        } else {
            // If OTP is invalid or expired, decrement registration_time
            registrationTime--;
            session.setAttribute("registration_time", registrationTime);

            // Check if this was the last attempt
            if (registrationTime <= 0) {
                session.removeAttribute("registration_otp");
                session.removeAttribute("registration_otp_time");
                session.removeAttribute("registration_username");
                session.removeAttribute("registration_email");
                session.removeAttribute("registration_password");
                session.removeAttribute("registration_time");
                redirectAttributes.addFlashAttribute("errorMessage",
                        "Bạn đã hết lượt thử. Vui lòng đăng ký lại.");
                return "redirect:/register";
            }

            // Check if OTP expired
            if (System.currentTimeMillis() - otpTime >= 600000) {
                model.addAttribute("errorMessage", "OTP đã hết hạn. Vui lòng đăng ký lại.");
            } else {
                model.addAttribute("errorMessage",
                        "OTP không hợp lệ. Bạn còn " + registrationTime + " lần thử.");
            }

            model.addAttribute("registration_time", registrationTime);
            return "verify-otp";
        }
    }

    @PostMapping("/resend-otp")
    public String resendOtp(HttpSession session, RedirectAttributes redirectAttributes, Model model) {
        try {
            // Get registration data from session
            String email = (String) session.getAttribute("registration_email");

            if (email == null) {
                model.addAttribute("errorMessage", "Không tìm thấy phiên đăng ký. Vui lòng đăng ký lại.");
                model.addAttribute("registration_time", session.getAttribute("registration_time"));
                return "verify-otp";
            }

            // Generate new OTP
            String otp = captchaService.generateCaptchaText();
            session.setAttribute("registration_otp", otp);
            session.setAttribute("registration_otp_time", System.currentTimeMillis());

            // Send new OTP email
            emailService.sendEmailWithRegistrationOTPAsync(email, otp);

            model.addAttribute("successMessage", "Một mã OTP mới đã được gửi đến email của bạn.");
            model.addAttribute("registration_time", session.getAttribute("registration_time"));
            return "verify-otp";

        } catch (Exception ex) {
            model.addAttribute("errorMessage", "Gửi lại OTP thất bại. Vui lòng thử lại.");
            model.addAttribute("registration_time", session.getAttribute("registration_time"));
            return "verify-otp";
        }
    }

    @GetMapping("/user/change-password")
    public String changePasswordPage() {
        return "user/change-password";
    }

    @PostMapping("/user/change-password")
    public String handleChangePassword(
            @RequestParam String oldPassword,
            @RequestParam String newPassword,
            @RequestParam String confirmPassword,
            RedirectAttributes redirectAttributes,
            Model model) {

        try {
            // Get current authenticated user from SecurityContext
            Authentication authentication = SecurityContextHolder.getContext()
                    .getAuthentication();

            if (authentication == null || !authentication.isAuthenticated()) {
                redirectAttributes.addFlashAttribute("errorMessage", "Bạn cần đăng nhập để đổi mật khẩu.");
                return "redirect:/login";
            }

            String username = authentication.getName();

            // Get user information from database
            var userOptional = userService.findByUsername(username);
            if (userOptional.isEmpty()) {
                redirectAttributes.addFlashAttribute("errorMessage", "Không tìm thấy thông tin người dùng.");
                return "redirect:/login";
            }

            var user = userOptional.get();

            // IMPORTANT: Check if old password is correct FIRST (fail fast)
            if (!passwordEncoder.matches(oldPassword, user.getPasswordHash())) {
                model.addAttribute("errorMessage", "Mật khẩu cũ không chính xác.");
                return "user/change-password";
            }

            // Check if old password and new password are the same
            if (oldPassword.equals(newPassword)) {
                model.addAttribute("errorMessage", "Mật khẩu mới phải khác mật khẩu cũ.");
                return "user/change-password";
            }

            // Validate new password
            if (!ValidationUtils.isValidPassword(newPassword)) {
                model.addAttribute("errorMessage", ValidationUtils.getPasswordErrorMessage());
                return "user/change-password";
            }

            // Check if new password and confirm password match
            if (!newPassword.equals(confirmPassword)) {
                model.addAttribute("errorMessage", "Mật khẩu mới và xác nhận mật khẩu không khớp.");
                return "user/change-password";
            }

            // Update new password
            userService.changePassword(username, newPassword);

            // Success message
            redirectAttributes.addFlashAttribute("successMessage", "Đổi mật khẩu thành công!");
            return "redirect:/homepage";

        } catch (Exception ex) {
            model.addAttribute("errorMessage", "Đã xảy ra lỗi khi đổi mật khẩu. Vui lòng thử lại.");
            return "user/change-password";
        }
    }
}
