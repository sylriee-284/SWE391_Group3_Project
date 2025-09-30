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

@Controller
public class AuthController {

    @Autowired
    private UserService userService;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @GetMapping("/login")
    public String loginPage(
            @RequestParam(value = "error", required = false) String error,

            Model model) {

        if (error != null) {
            model.addAttribute("errorMessage", "Tên đăng nhập hoặc mật khẩu không đúng!");
        }

        return "login";
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

}
