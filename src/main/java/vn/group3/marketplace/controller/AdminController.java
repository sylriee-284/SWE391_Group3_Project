package vn.group3.marketplace.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import vn.group3.marketplace.domain.entity.User;
import vn.group3.marketplace.security.CustomUserDetails;
import vn.group3.marketplace.service.UserService;

@Controller
@RequestMapping("/admin")
public class AdminController {

    private final UserService userService;

    public AdminController(UserService userService) {
        this.userService = userService;
    }

    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping
    public String adminRoot() {
        return "redirect:/admin/users";
    }

    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/dashboard")
    public String dashboard() {
        return "redirect:/admin/users";
    }

    @GetMapping("/categories")
    public String manageCategories() {
        // Parent categories are automatically loaded by GlobalControllerAdvice
        return "admin/categories";
    }

    // --- CRUD: Start of Admin Account Management ---
    // Danh sách tài khoản
    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/users")
    public String getAllUsers(Model model) {
        model.addAttribute("users", userService.getAllActiveUsers());
        return "admin/users"; // JSP: hiển thị danh sách users
    }

    // Form thêm mới tài khoản
    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/users/create")
    public String showCreateUserForm(Model model) {
        model.addAttribute("user", new User());
        model.addAttribute("formTitle", "Tạo tài khoản mới");
        return "admin/user_form"; // JSP form thêm user
    }

    // Form chỉnh sửa tài khoản
    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/users/edit/{id}")
    public String showEditUserForm(@PathVariable Long id, Model model) {
        User existing = userService.getUserById(id)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy user ID: " + id));
        model.addAttribute("user", existing);
        model.addAttribute("formTitle", "Chỉnh sửa tài khoản");
        return "admin/user_form";
    }

    // Xử lý cập nhật
    @PreAuthorize("hasRole('ADMIN')")
    @PostMapping("/users/update/{id}")
    public String updateUser(@PathVariable Long id,
            @ModelAttribute("user") User updatedUser,
            RedirectAttributes redirectAttributes) {
        userService.updateUser(id, updatedUser);
        redirectAttributes.addFlashAttribute("success", "Cập nhật tài khoản thành công!");
        return "redirect:/admin/users";
    }

    // Xóa mềm tài khoản
    @PreAuthorize("hasRole('ADMIN')")
    @PostMapping("/users/delete/{id}")
    public String softDeleteUser(@PathVariable Long id,
            Authentication auth,
            RedirectAttributes redirectAttributes) {
        CustomUserDetails admin = (CustomUserDetails) auth.getPrincipal();
        userService.softDeleteUser(id, admin.getId());
        redirectAttributes.addFlashAttribute("success", "Đã xóa tài khoản thành công (soft delete)");
        return "redirect:/admin/users";
    }
    // --- CRUD: End of Admin Account Management ---

}
