package vn.group3.marketplace.controller;

import org.springframework.data.domain.Page;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import vn.group3.marketplace.domain.entity.User;
import vn.group3.marketplace.service.UserService;

@Controller
@RequestMapping("/admin")
public class AdminController {

    private final UserService userService;

    public AdminController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping("/dashboard")
    public String dashboard(Model model) {
        // Load report data: orders, users, revenue, disputes...
        return "admin/dashboard";
    }

    @GetMapping("/categories/overview")
    public String manageCategories() {
        // Parent categories are automatically loaded by GlobalControllerAdvice
        return "admin/categories";
    }

    @GetMapping("/users")
    @PreAuthorize("hasRole('ADMIN')")
    public String listUsers(@RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(required = false) String status,
            Model model) {
        vn.group3.marketplace.domain.enums.UserStatus st = null;
        if (status != null && !status.isBlank()) {
            try {
                st = vn.group3.marketplace.domain.enums.UserStatus.valueOf(status.toUpperCase());
            } catch (IllegalArgumentException ignore) {
                st = null; // nếu sai chuỗi thì bỏ lọc
            }
        }

        Page<User> p = userService.findUsers(page - 1, size, st);

        model.addAttribute("users", p.getContent());
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPages", p.getTotalPages());
        model.addAttribute("pageSize", size);
        model.addAttribute("status", status); // để giữ lại select đã chọn
        model.addAttribute("pageTitle", "Quản lý người dùng");
        return "admin/users";
    }

    @GetMapping("/users/add")
    @PreAuthorize("hasRole('ADMIN')")
    public String showAddUser(Model model) {
        User u = new User();
        model.addAttribute("user", u);
        model.addAttribute("formMode", "create");
        model.addAttribute("pageTitle", "Tạo người dùng");
        // NEW: đưa tất cả roles ra form, và preselect USER
        model.addAttribute("allRoles", userService.getAllRoles());
        model.addAttribute("selectedRoleIds", java.util.Set.of(
                userService.getDefaultUserRoleId() // id role USER (để tick sẵn)
        ));
        return "admin/user_form";
    }

    @GetMapping("/users/edit/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public String showEditUser(@PathVariable Long id, Model model) {
        User u = userService.getUserById(id);
        if (u == null)
            return "redirect:/admin/users";
        model.addAttribute("user", u);
        model.addAttribute("formMode", "edit");
        model.addAttribute("pageTitle", "Chỉnh sửa người dùng: " + u.getUsername());
        // NEW: roles cho form + set các role đang có
        model.addAttribute("allRoles", userService.getAllRoles());
        java.util.Set<Long> selected = new java.util.HashSet<>();
        if (u.getRoles() != null) {
            for (vn.group3.marketplace.domain.entity.Role r : u.getRoles()) {
                selected.add(r.getId());
            }
        }
        model.addAttribute("selectedRoleIds", selected);
        return "admin/user_form";
    }

    @PostMapping("/users/delete/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public String deleteUser(@PathVariable Long id, RedirectAttributes ra) {
        User u = userService.getUserById(id);
        if (u == null) {
            ra.addFlashAttribute("error", "Không tìm thấy người dùng.");
            return "redirect:/admin/users";
        }
        // Thực hiện xóa (permanent) theo yêu cầu. Nếu muốn soft-delete, đổi lại thành
        // update status.
        userService.deleteUserById(id);
        ra.addFlashAttribute("success", "Đã xóa người dùng.");
        return "redirect:/admin/users";
    }

    @PostMapping("/users/toggle/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public String toggleUserStatus(@PathVariable Long id, RedirectAttributes ra) {
        User u = userService.getUserById(id);
        if (u == null) {
            ra.addFlashAttribute("error", "Không tìm thấy người dùng.");
            return "redirect:/admin/users";
        }
        if (u.getStatus() == vn.group3.marketplace.domain.enums.UserStatus.ACTIVE) {
            u.setStatus(vn.group3.marketplace.domain.enums.UserStatus.INACTIVE);
        } else {
            u.setStatus(vn.group3.marketplace.domain.enums.UserStatus.ACTIVE);
        }
        userService.updateUser(u);
        ra.addFlashAttribute("successMessage", "Đã đổi trạng thái người dùng.");
        return "redirect:/admin/users";
    }

    // GIỮ một endpoint lưu duy nhất cho form tạo/sửa
    @PostMapping("/users/save")
    @PreAuthorize("hasRole('ADMIN')")
    public String saveUserFromAdmin(
            @ModelAttribute("user") vn.group3.marketplace.domain.entity.User user,
            @RequestParam(value = "roleIds", required = false) java.util.List<Long> roleIds,
            RedirectAttributes ra) {

        userService.saveFromAdminWithRoles(user, roleIds); // NEW: set mật khẩu mặc định + roles
        ra.addFlashAttribute("success",
                user.getId() == null ? "Tạo người dùng thành công" : "Cập nhật người dùng thành công");
        return "redirect:/admin/users";
    }

}
