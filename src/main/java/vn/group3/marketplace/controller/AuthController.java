package vn.group3.marketplace.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import jakarta.mail.MessagingException;
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
        String captchaText = captchaService.generateCaptchaText();
        session.setAttribute(CAPTCHA_SESSION_KEY, captchaText);
        byte[] image = captchaService.generateCaptchaImage(captchaText);
        response.setContentType("image/png");
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);
        response.getOutputStream().write(image);
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

            // Send OTP email
            emailService.sendEmailWithRegistrationOTP(email, otp);

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

            UsernamePasswordAuthenticationToken authToken = new UsernamePasswordAuthenticationToken(userDetails, null,
                    userDetails.getAuthorities());
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

            // Send reset password OTP email
            emailService.sendEmailWithResetPasswordOTP(email, otp);
            redirectAttributes.addFlashAttribute("successMessage",
                    "An email with the OTP has been sent. Please check your inbox.");
            session.removeAttribute("successMessage");
            return "redirect:/";

        } catch (MessagingException e) {
            redirectAttributes.addFlashAttribute("errorMessage", "Failed to send email. Please try again later.");
            session.removeAttribute("errorMessage");
            return "forgot-password";
        } catch (Exception e) {
            session.setAttribute("errorMessage", "An unexpected error occurred. Please try again.");
            return "forgot-password";
        }
    }

    @GetMapping("/reset-password")
    public String showResetPasswordPage() {
        return "reset-password";
    }

    @PostMapping("/reset-password")
    public String handleResetPassword(@RequestParam String otp, @RequestParam String newPassword,
            @RequestParam String email, HttpSession session, Model model, RedirectAttributes redirectAttributes) {

        // Validate password
        if (!ValidationUtils.isValidPassword(newPassword)) {
            model.addAttribute("errorMessage", ValidationUtils.getPasswordErrorMessage());
            return "reset-password";
        }

        // Get OTP and time from session
        String sessionOtp = (String) session.getAttribute("otp");
        Long otpTime = (Long) session.getAttribute("otp_time");

        // Check if OTP is valid and not expired (10 minutes)
        if (sessionOtp != null && sessionOtp.equals(otp) && (System.currentTimeMillis() - otpTime < 600000)) {
            // If OTP is valid, update user's password
            userService.resetPassword(newPassword, email);
            session.removeAttribute("otp"); // Remove OTP after use

            // Set success message and redirect to login page
            redirectAttributes.addFlashAttribute("successMessage", "Password reset successful. You can now log in.");
            return "redirect:/login";
        } else {
            // If OTP is invalid or expired
            redirectAttributes.addFlashAttribute("errorMessage", "Invalid or expired OTP. Please try again.");
            return "redirect:/forgot-password";
        }
    }

    @GetMapping("/verify-otp")
    public String verifyOtpPage(Model model) {
        return "verify-otp";
    }

    @PostMapping("/verify-otp")
    public String handleVerifyOtp(@RequestParam String otp, HttpSession session,
            RedirectAttributes redirectAttributes, Model model) {

        // Get OTP and time from session
        String sessionOtp = (String) session.getAttribute("registration_otp");
        Long otpTime = (Long) session.getAttribute("registration_otp_time");

        // Check if OTP is valid and not expired (10 minutes)
        if (sessionOtp != null && sessionOtp.equals(otp) && (System.currentTimeMillis() - otpTime < 600000)) {
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

                // Success message
                redirectAttributes.addFlashAttribute("successMessage",
                        "Registration successful! Please log in.");
                return "redirect:/login";

            } catch (Exception ex) {
                model.addAttribute("errorMessage", "Registration failed. Please try again.");
                return "verify-otp";
            }
        } else {
            // If OTP is invalid or expired, stay on the same page and show error
            if (sessionOtp == null || otpTime == null) {
                model.addAttribute("errorMessage", "No OTP found. Please register again.");
                return "verify-otp";
            } else if (System.currentTimeMillis() - otpTime >= 600000) {
                model.addAttribute("errorMessage", "OTP has expired. Please register again.");
                return "verify-otp";
            } else {
                model.addAttribute("errorMessage", "Invalid OTP. Please try again.");
                return "verify-otp";
            }
        }
    }

    @PostMapping("/resend-otp")
    public String resendOtp(HttpSession session, RedirectAttributes redirectAttributes, Model model) {
        try {
            // Get registration data from session
            String email = (String) session.getAttribute("registration_email");

            if (email == null) {
                model.addAttribute("errorMessage", "No registration session found. Please register again.");
                return "verify-otp";
            }

            // Generate new OTP
            String otp = captchaService.generateCaptchaText();
            session.setAttribute("registration_otp", otp);
            session.setAttribute("registration_otp_time", System.currentTimeMillis());

            // Send new OTP email
            emailService.sendEmailWithRegistrationOTP(email, otp);

            model.addAttribute("successMessage", "A new OTP has been sent to your email.");
            return "verify-otp";

        } catch (Exception ex) {
            model.addAttribute("errorMessage", "Failed to resend OTP. Please try again.");
            return "verify-otp";
        }
    }
}
