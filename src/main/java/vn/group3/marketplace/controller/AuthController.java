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

        // Validate password
        if (password == null || password.trim().isEmpty()) {
            model.addAttribute("errorMessage", "Mật khẩu không được để trống hoặc chỉ chứa khoảng trắng!");
            return "register";
        }

        // Check password match
        if (!password.equals(repeatPassword)) {
            model.addAttribute("errorMessage", "Mật khẩu không khớp!");
            return "register";
        }

        try {
            // Register user
            userService.registerUser(username, email, password);

            // Success message
            redirectAttributes.addFlashAttribute("successMessage",
                    "Đăng ký thành công! Vui lòng đăng nhập.");
            return "redirect:/login";

        } catch (IllegalArgumentException ex) {
            model.addAttribute("errorMessage", ex.getMessage());
            return "register";
        } catch (Exception ex) {
            model.addAttribute("errorMessage", "Có lỗi xảy ra. Vui lòng thử lại.");
            return "register";
        }
    }

    @PostMapping("/login")
    public String handleLogin(@RequestParam("username") String username,
            @RequestParam("password") String password,
            @RequestParam("captcha") String captcha,
            HttpSession session,
            Model model) {

        // Validate captcha first
        String sessionCaptcha = (String) session.getAttribute(CAPTCHA_SESSION_KEY);
        if (sessionCaptcha == null || !sessionCaptcha.equals(captcha)) {
            model.addAttribute("errorMessage", "Mã xác thực không đúng!");
            return "login";
        }

        try {
            session.removeAttribute(CAPTCHA_SESSION_KEY);
            UserDetails userDetails = userDetailsService.loadUserByUsername(username);

            if (!passwordEncoder.matches(password, userDetails.getPassword())) {
                model.addAttribute("errorMessage", "Tên đăng nhập hoặc mật khẩu không đúng!");
                return "login";
            }

            UsernamePasswordAuthenticationToken authToken = new UsernamePasswordAuthenticationToken(userDetails, null,
                    userDetails.getAuthorities());
            SecurityContextHolder.getContext().setAuthentication(authToken);
            session.setAttribute("SPRING_SECURITY_CONTEXT", SecurityContextHolder.getContext());

            return "redirect:/homepage";

        } catch (Exception e) {
            model.addAttribute("errorMessage", "Tên đăng nhập hoặc mật khẩu không đúng!");
            return "login";
        }
    }

    @GetMapping("/forgot-password")
    public String forgotPasswordPage() {
        return "forgot-password";
    }

    @PostMapping("/forgot-password")
    public String handleForgotPassword(@RequestParam String email, HttpSession session,
            RedirectAttributes redirectAttributes) {
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

        // Kiểm tra mật khẩu mới không được để trống hoặc chỉ chứa khoảng trắng
        if (newPassword == null || newPassword.trim().isEmpty()) {
            model.addAttribute("errorMessage", "Mật khẩu không được để trống hoặc chỉ chứa khoảng trắng!");
            return "reset-password";
        }

        // Lấy OTP và thời gian từ session
        String sessionOtp = (String) session.getAttribute("otp");
        Long otpTime = (Long) session.getAttribute("otp_time");

        // Kiểm tra OTP hợp lệ và chưa hết hạn
        if (sessionOtp != null && sessionOtp.equals(otp) && (System.currentTimeMillis() - otpTime < 600000)) { // 10
                                                                                                               // phút
            // Nếu OTP hợp lệ, cập nhật mật khẩu mới cho người dùng
            userService.resetPassword(newPassword, email);
            session.removeAttribute("otp"); // Xóa OTP sau khi sử dụng

            // Thiết lập thông báo thành công và chuyển hướng tới trang login
            redirectAttributes.addFlashAttribute("successMessage", "Password reset successful. You can now log in.");
            return "redirect:/login"; // Điều hướng tới trang login
        } else {
            // Nếu OTP không hợp lệ hoặc hết hạn, thiết lập thông báo lỗi và chuyển lại
            // trang quên mật khẩu
            redirectAttributes.addFlashAttribute("errorMessage", "Invalid or expired OTP. Please try again.");
            return "redirect:/forgot-password"; // Điều hướng lại trang quên mật khẩu
        }
    }
}
