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
import vn.group3.marketplace.config.GlobalConfig;
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
            Model model) {

        if (error != null) {
            model.addAttribute("errorMessage", error);
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
            Model model) {

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

        try {
            // Register user
            userService.registerUser(username, email, password);

            // Success message
            redirectAttributes.addFlashAttribute("successMessage",
                    "Registration successful! Please log in.");
            return "redirect:/login";

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
            String resetLink = GlobalConfig.BASE_URL + "/reset-password";

            // Email content
            String subject = "Reset Your Password - MMO Market System";
            String body = "<html><body>" +
                    "<h2>Password Reset Request</h2>" +
                    "<p>Hello,</p>" +
                    "<p>You have requested to reset your password. Please use the following information:</p>" +
                    "<div style='background-color: #f5f5f5; padding: 15px; border-radius: 5px; margin: 10px 0;'>" +
                    "<p><strong>Your OTP:</strong> <span style='font-size: 18px; color: #007bff; font-weight: bold;'>"
                    + otp + "</span></p>" +
                    "</div>" +
                    "<p>Click the link below to reset your password:</p>" +
                    "<p><a href='" + resetLink
                    + "' style='background-color: #007bff; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px;'>Reset Password</a></p>"
                    +
                    "<p><strong>Note:</strong> This OTP will expire in 10 minutes for security reasons.</p>" +
                    "<p>If you did not request this password reset, please ignore this email.</p>" +
                    "<br>" +
                    "<p>Best regards,<br>MMO Market System Team</p>" +
                    "</body></html>";

            emailService.sendEmail(email, subject, body);
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
}
