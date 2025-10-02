package vn.group3.marketplace.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;

import vn.group3.marketplace.service.UserService;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import vn.group3.marketplace.service.CaptchaGenerator;
import java.io.IOException;

@Controller
public class AuthController {

    @Autowired
    private UserService userService;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private CaptchaGenerator captchaGenerator;

    private static final String CAPTCHA_SESSION_KEY = "CAPTCHA_TEXT";
    private static final String USER_SESSION_KEY = "USER_SESSION";

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
        String captchaText = captchaGenerator.generateCaptchaText();
        session.setAttribute(CAPTCHA_SESSION_KEY, captchaText);
        byte[] image = captchaGenerator.generateCaptchaImage(captchaText);
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

        // Kiểm tra mật khẩu khớp
        if (!password.equals(repeatPassword)) {
            model.addAttribute("errorMessage", "Mật khẩu không khớp!");
            return "register";
        }

        try {
            // Gọi service để xử lý logic đăng ký
            userService.registerUser(username, email, password);

            // Flash message khi thành công
            redirectAttributes.addFlashAttribute("successMessage",
                    "Đăng ký thành công! Vui lòng đăng nhập.");
            return "redirect:/login";

        } catch (IllegalArgumentException ex) {
            // Lỗi validate (username/email tồn tại...)
            model.addAttribute("errorMessage", ex.getMessage());
            return "register";

        } catch (Exception ex) {
            // Lỗi khác (server/database...)
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
        String sessionCaptcha = (String) session.getAttribute(CAPTCHA_SESSION_KEY);
        if (sessionCaptcha == null || !sessionCaptcha.equals(captcha)) {
            model.addAttribute("errorMessage", "Mã xác thực không đúng!");
            return "login";
        }
        session.removeAttribute(CAPTCHA_SESSION_KEY);
        // Kiểm tra user
        var userOpt = userService.findByUsername(username);
        if (userOpt.isEmpty() || !passwordEncoder.matches(password, userOpt.get().getPasswordHash())) {
            model.addAttribute("errorMessage", "Tên đăng nhập hoặc mật khẩu không đúng!");
            return "login";
        }
        // Lưu user vào session
        session.setAttribute(USER_SESSION_KEY, userOpt.get());
        return "redirect:/homepage";
    }

}
