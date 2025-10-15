package vn.group3.marketplace.controller;

import java.util.List;
import java.util.stream.Collectors;
import vn.group3.marketplace.repository.RoleRepository;

import org.springframework.beans.factory.annotation.Autowired;
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

    @Autowired
    private RoleRepository roleRepository;

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

    // @GetMapping("/categories")
    // public String manageCategories() {
    // // Parent categories are automatically loaded by GlobalControllerAdvice
    // return "admin/categories";
    // }

    // --- CRUD: Start of Admin Account Management ---
    // Danh sách tài khoản
    /**
     * @param model
     * @return
     */
    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/users")
    public String getAllUsers(@RequestParam(value = "status", required = false) String status,
            @RequestParam(value = "page", defaultValue = "1") int page,
            @RequestParam(value = "size", defaultValue = "10") int size,
            Model model) {

        List<User> users = userService.getFilteredUsers(status)
                .stream()
                .filter(u -> u.getRoles() == null
                        || u.getRoles().stream().noneMatch(r -> "ADMIN".equalsIgnoreCase(r.getCode()))) // ẩn ADMIN
                // === THÊM DÒNG SẮP XẾP THEO USERNAME ===
                .sorted((a, b) -> {
                    String ua = a.getUsername() == null ? "" : a.getUsername();
                    String ub = b.getUsername() == null ? "" : b.getUsername();
                    return naturalCompareUsername(ua, ub);
                })
                .collect(java.util.stream.Collectors.toList());

        // --- phân trang ---
        int total = users.size();
        int totalPages = (int) Math.ceil((double) total / size);
        page = Math.max(1, Math.min(page, Math.max(totalPages, 1)));
        int from = Math.max((page - 1) * size, 0);
        int to = Math.min(from + size, total);
        List<User> pagedUsers = users.subList(from, to);

        model.addAttribute("users", pagedUsers);
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPages", totalPages);
        model.addAttribute("statusFilter", status == null ? "" : status);
        model.addAttribute("pageSize", size);

        return "admin/users";
    }

    @PostMapping("/users/save")
    public String saveUser(@ModelAttribute User user,
            @RequestParam(value = "roles", required = false) List<String> roles,
            RedirectAttributes ra) {

        userService.saveUserWithRoles(user, roles);
        ra.addFlashAttribute("successMessage", "Đã tạo tài khoản thành công!");
        return "redirect:/admin/users";
    }

    private static int naturalCompareUsername(String s1, String s2) {
        int i = 0, j = 0;
        final int n1 = s1.length(), n2 = s2.length();

        while (i < n1 && j < n2) {
            char c1 = s1.charAt(i);
            char c2 = s2.charAt(j);
            boolean d1 = Character.isDigit(c1);
            boolean d2 = Character.isDigit(c2);

            if (d1 && d2) {
                // so sánh block số theo giá trị (không theo chữ)
                long num1 = 0;
                while (i < n1 && Character.isDigit(s1.charAt(i))) {
                    num1 = num1 * 10 + (s1.charAt(i) - '0');
                    i++;
                }
                long num2 = 0;
                while (j < n2 && Character.isDigit(s2.charAt(j))) {
                    num2 = num2 * 10 + (s2.charAt(j) - '0');
                    j++;
                }
                if (num1 != num2)
                    return Long.compare(num1, num2);
            } else {
                // so sánh chữ: không phân biệt hoa/thường trước
                int cmp = Character.toLowerCase(c1) - Character.toLowerCase(c2);
                if (cmp != 0)
                    return cmp;

                // nếu cùng chữ khi bỏ qua case -> ưu tiên chữ HOA trước thường
                if (c1 != c2)
                    return c1 - c2; // 'A'(65) < 'a'(97)

                i++;
                j++;
            }
        }

        // nếu tiền tố giống nhau -> chuỗi ngắn hơn đứng trước
        return (n1 - i) - (n2 - j);
    }

    @PostMapping("/users/create")
    @PreAuthorize("hasRole('ADMIN')")
    public String createUserSubmit(
            @ModelAttribute("user") User user,
            @RequestParam(value = "roles", required = false) List<String> roles,
            RedirectAttributes redirectAttributes) {

        userService.saveUserWithRoles(user, roles); // dùng method bạn đã có

        redirectAttributes.addFlashAttribute("successMessage", "Cập nhật tài khoản thành công!");
        return "redirect:/admin/users";
    }

    // Toggle trạng thái (ACTIVE <-> INACTIVE)
    @PreAuthorize("hasRole('ADMIN')")
    @PostMapping("/users/toggle/{id}")
    public ResponseEntity<Void> toggleUserStatus(@PathVariable Long id) {
        userService.toggleUserStatus(id);
        return ResponseEntity.noContent().build();
    }

    // ✳️ API: Lấy số dư 1 user để nút "Hiện" dùng (AJAX)
    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/users/balance/{id}")
    @ResponseBody
    public java.util.Map<String, Object> getUserBalance(@PathVariable Long id) {
        var u = userService.getUserById(id)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy user ID: " + id));
        var resp = new java.util.HashMap<String, Object>();
        resp.put("id", u.getId());
        resp.put("balance", u.getBalance());
        return resp;
    }

    // THÊM MỚI – nhận form tạo user
    @PreAuthorize("hasRole('ADMIN')")
    @PostMapping("/users")
    public String createUser(@ModelAttribute("user") User user,
            @RequestParam(value = "roles", required = false) List<String> roles,
            @RequestParam(value = "passwordPlain", required = false) String passwordPlain,
            RedirectAttributes ra) {
        userService.saveUserWithRolesAndPassword(user, roles, passwordPlain);
        ra.addFlashAttribute("success", "Tạo tài khoản thành công!");
        return "redirect:/admin/users";
    }

    // Form thêm mới tài khoản
    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/users/create")
    public String showCreateUserForm(Model model) {
        model.addAttribute("user", new User());
        model.addAttribute("formTitle", "Tạo tài khoản mới");
        model.addAttribute("allRoles", roleRepository.findAll());
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
        model.addAttribute("allRoles", roleRepository.findAll());
        return "admin/user_form";
    }

    // Xử lý cập nhật
    @PreAuthorize("hasRole('ADMIN')")
    @PostMapping("/users/update/{id}")
    public String updateUser(@PathVariable Long id,
            @ModelAttribute("user") User updatedUser,
            @RequestParam(value = "roles", required = false) List<String> roles,
            @RequestParam(value = "passwordPlain", required = false) String passwordPlain,
            RedirectAttributes redirectAttributes) {
        try {
            updatedUser.setId(id);
            userService.saveUserWithRolesAndPassword(updatedUser, roles, passwordPlain);
            redirectAttributes.addFlashAttribute("success", "Cập nhật tài khoản thành công!");
            return "redirect:/admin/users";
        } catch (IllegalArgumentException ex) {
            redirectAttributes.addFlashAttribute("error", ex.getMessage());
            return "redirect:/admin/users/edit/" + id;
        }
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
