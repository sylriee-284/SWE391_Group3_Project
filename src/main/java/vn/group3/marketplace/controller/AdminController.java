package vn.group3.marketplace.controller;

import org.springframework.data.domain.Page;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import vn.group3.marketplace.domain.entity.User;
import vn.group3.marketplace.service.UserService;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;

import lombok.*;
import lombok.extern.slf4j.Slf4j;
import vn.group3.marketplace.domain.entity.SystemSetting;
import vn.group3.marketplace.service.SystemSettingService;

@Controller
@RequestMapping("/admin")
@RequiredArgsConstructor
@Slf4j
public class AdminController {

    private final UserService userService;
    private final SystemSettingService systemSettingService;

    private static final String SUCCESS_MESSAGE = "successMessage";
    private static final String ERROR_MESSAGE = "errorMessage";
    private static final String MODEL_SYSTEM_SETTINGS = "systemSettings";
    private static final String REDIRECT_SYSTEM_CONFIG = "redirect:/admin/system-config";
    private static final int DEFAULT_PAGE_SIZE = 10;

    @GetMapping("/dashboard")
    public String dashboard(Model model) {
        // Load report data: orders, users, revenue, disputes...
        return "admin/dashboard";
    }

    // API endpoints for chart data
    @GetMapping("/api/user-growth-data")
    @ResponseBody
    public java.util.Map<String, Object> getUserGrowthData() {
        // TODO: Replace with actual database queries
        java.util.Map<String, Object> data = new java.util.HashMap<>();
        data.put("labels", java.util.Arrays.asList("Tháng 1", "Tháng 2", "Tháng 3", "Tháng 4", "Tháng 5", "Tháng 6"));
        data.put("data", java.util.Arrays.asList(45, 78, 95, 120, 145, 178));
        return data;
    }

    @GetMapping("/api/order-stats-data")
    @ResponseBody
    public java.util.Map<String, Object> getOrderStatsData() {
        // TODO: Replace with actual database queries from Order entity
        java.util.Map<String, Object> data = new java.util.HashMap<>();
        data.put("labels", java.util.Arrays.asList("Hoàn thành", "Đang xử lý", "Đã hủy", "Chờ thanh toán"));
        data.put("data", java.util.Arrays.asList(65, 20, 10, 5));
        return data;
    }

    @GetMapping("/api/revenue-data")
    @ResponseBody
    public java.util.Map<String, Object> getRevenueData() {
        // TODO: Replace with actual database queries from WalletTransaction entity
        java.util.Map<String, Object> data = new java.util.HashMap<>();
        data.put("labels",
                java.util.Arrays.asList("T1", "T2", "T3", "T4", "T5", "T6", "T7", "T8", "T9", "T10", "T11", "T12"));
        data.put("data", java.util.Arrays.asList(25000000, 32000000, 28000000, 35000000, 42000000, 38000000, 45000000,
                48000000, 52000000, 47000000, 55000000, 60000000));
        return data;
    }

    @GetMapping("/api/category-data")
    @ResponseBody
    public java.util.Map<String, Object> getCategoryData() {
        // TODO: Replace with actual database queries from Category/Product entities
        java.util.Map<String, Object> data = new java.util.HashMap<>();
        data.put("labels", java.util.Arrays.asList("Phần mềm", "Tài khoản", "Dịch vụ", "Khác"));
        data.put("data", java.util.Arrays.asList(35, 25, 30, 10));
        return data;
    }

    @GetMapping("/api/kpi-data")
    @ResponseBody
    public java.util.Map<String, Object> getKpiData() {
        // TODO: Replace with actual database queries
        java.util.Map<String, Object> data = new java.util.HashMap<>();

        // Total users count (from User entity)
        data.put("totalUsers", 1234);
        data.put("newUsersThisMonth", 56);

        // Total orders count (from Order entity)
        data.put("totalOrders", 2847);
        data.put("pendingOrders", 23);

        // Total products count (from Product entity)
        data.put("totalProducts", 456);
        data.put("activeProducts", 398);

        // Total stores count (from SellerStore entity)
        data.put("totalStores", 89);
        data.put("activeStores", 76);

        // Active users now (could be from sessions or recent activity)
        data.put("activeUsersNow", 45);

        return data;
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

    @GetMapping("/system-config")
    public String systemConfig(@RequestParam(defaultValue = "0") int page,
            @RequestParam(required = false) Integer size,
            Model model) {
        if (page < 0)
            page = 0;
        int pageSize = (size == null || size <= 0) ? DEFAULT_PAGE_SIZE : size;

        Pageable pageable = PageRequest.of(page, pageSize, Sort.by(Sort.Direction.DESC, "createdAt"));
        Page<SystemSetting> pageResult = systemSettingService.getSettings(pageable);

        // Paging helpers
        int totalPages = pageResult.getTotalPages();
        int currentPage = page;
        int window = 2;
        int start = Math.max(0, currentPage - window);
        int end = Math.min(Math.max(0, totalPages - 1), currentPage + window);
        java.util.List<Integer> pages = new java.util.ArrayList<>();
        for (int i = start; i <= end; i++) {
            pages.add(i);
        }

        model.addAttribute(MODEL_SYSTEM_SETTINGS, pageResult.getContent());
        model.addAttribute("currentPage", currentPage);
        model.addAttribute("totalPages", totalPages);
        model.addAttribute("totalElements", pageResult.getTotalElements());
        model.addAttribute("size", pageSize);
        model.addAttribute("pages", pages);
        model.addAttribute("hasPrev", currentPage > 0);
        model.addAttribute("hasNext", currentPage < totalPages - 1);

        return "admin/system-config";
    }

    // filter system settings
    @PostMapping("/system-config/filter")
    public String filterSystemSettings(
            @RequestParam(required = false) String id,
            @RequestParam(required = false) String settingKey,
            @RequestParam(required = false) String settingValue,
            @RequestParam(required = false, name = "createdFrom") String createdFrom,
            @RequestParam(required = false, name = "createdTo") String createdTo,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(required = false) Integer size,
            Model model) {

        Long parsedId = null;
        try {
            if (id != null && !id.isBlank()) {
                parsedId = Long.parseLong(id.trim());
            }
        } catch (NumberFormatException ex) {
        }

        java.time.LocalDate from = null;
        java.time.LocalDate to = null;
        try {
            if (createdFrom != null && !createdFrom.isBlank()) {
                from = java.time.LocalDate.parse(createdFrom);
            }
            if (createdTo != null && !createdTo.isBlank()) {
                to = java.time.LocalDate.parse(createdTo);
            }
        } catch (Exception ex) {
        }

        if (page < 0)
            page = 0;
        int pageSize = (size == null || size <= 0) ? DEFAULT_PAGE_SIZE : size;
        Pageable pageable = PageRequest.of(page, pageSize, Sort.by(Sort.Direction.DESC, "createdAt"));

        Page<SystemSetting> filtered = systemSettingService.filterSettings(
                parsedId,
                settingKey,
                settingValue,
                from,
                to,
                pageable);

        // Paging helpers
        int totalPages = filtered.getTotalPages();
        int currentPage = page;
        int window = 2;
        int start = Math.max(0, currentPage - window);
        int end = Math.min(Math.max(0, totalPages - 1), currentPage + window);
        java.util.List<Integer> pages = new java.util.ArrayList<>();
        for (int i = start; i <= end; i++) {
            pages.add(i);
        }

        model.addAttribute(MODEL_SYSTEM_SETTINGS, filtered.getContent());
        model.addAttribute("currentPage", currentPage);
        model.addAttribute("totalPages", totalPages);
        model.addAttribute("totalElements", filtered.getTotalElements());
        model.addAttribute("size", pageSize);
        model.addAttribute("pages", pages);
        model.addAttribute("hasPrev", currentPage > 0);
        model.addAttribute("hasNext", currentPage < totalPages - 1);
        model.addAttribute("filtered", true);
        model.addAttribute("filterId", id);
        model.addAttribute("filterSettingKey", settingKey);
        model.addAttribute("filterSettingValue", settingValue);
        model.addAttribute("filterCreatedFrom", createdFrom);
        model.addAttribute("filterCreatedTo", createdTo);

        return "admin/system-config";
    }

    // Handle pagination for filtered results
    @GetMapping("/system-config/filter")
    public String filterSystemSettingsGet(
            @RequestParam(required = false) String id,
            @RequestParam(required = false) String settingKey,
            @RequestParam(required = false) String settingValue,
            @RequestParam(required = false, name = "createdFrom") String createdFrom,
            @RequestParam(required = false, name = "createdTo") String createdTo,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(required = false) Integer size,
            Model model) {

        Long parsedId = null;
        try {
            if (id != null && !id.isBlank()) {
                parsedId = Long.parseLong(id.trim());
            }
        } catch (NumberFormatException ex) {
        }

        java.time.LocalDate from = null;
        java.time.LocalDate to = null;
        try {
            if (createdFrom != null && !createdFrom.isBlank()) {
                from = java.time.LocalDate.parse(createdFrom);
            }
            if (createdTo != null && !createdTo.isBlank()) {
                to = java.time.LocalDate.parse(createdTo);
            }
        } catch (Exception ex) {
        }

        if (page < 0)
            page = 0;
        int pageSize = (size == null || size <= 0) ? DEFAULT_PAGE_SIZE : size;
        Pageable pageable = PageRequest.of(page, pageSize, Sort.by(Sort.Direction.DESC, "createdAt"));

        Page<SystemSetting> filtered = systemSettingService.filterSettings(
                parsedId,
                settingKey,
                settingValue,
                from,
                to,
                pageable);

        // Paging helpers
        int totalPages = filtered.getTotalPages();
        int currentPage = page;
        int window = 2;
        int start = Math.max(0, currentPage - window);
        int end = Math.min(Math.max(0, totalPages - 1), currentPage + window);
        java.util.List<Integer> pages = new java.util.ArrayList<>();
        for (int i = start; i <= end; i++) {
            pages.add(i);
        }

        model.addAttribute(MODEL_SYSTEM_SETTINGS, filtered.getContent());
        model.addAttribute("currentPage", currentPage);
        model.addAttribute("totalPages", totalPages);
        model.addAttribute("totalElements", filtered.getTotalElements());
        model.addAttribute("size", pageSize);
        model.addAttribute("pages", pages);
        model.addAttribute("hasPrev", currentPage > 0);
        model.addAttribute("hasNext", currentPage < totalPages - 1);
        model.addAttribute("filtered", true);
        model.addAttribute("filterId", id);
        model.addAttribute("filterSettingKey", settingKey);
        model.addAttribute("filterSettingValue", settingValue);
        model.addAttribute("filterCreatedFrom", createdFrom);
        model.addAttribute("filterCreatedTo", createdTo);

        return "admin/system-config";
    }

    @PostMapping("/system-config/add")
    public String addSystemSetting(@RequestParam String settingKey,
            @RequestParam String settingValue,
            RedirectAttributes redirectAttributes) {
        try {
            systemSettingService.updateSetting(settingKey, settingValue);
            redirectAttributes.addFlashAttribute(SUCCESS_MESSAGE, "Đã thêm cài đặt hệ thống thành công!");
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute(ERROR_MESSAGE, "Lỗi khi thêm cài đặt: " + e.getMessage());
        }
        return REDIRECT_SYSTEM_CONFIG;
    }

    @PostMapping("/system-config/update")
    public String updateSystemSetting(@RequestParam Long id,
            @RequestParam String settingKey,
            @RequestParam String settingValue,
            RedirectAttributes redirectAttributes) {
        try {
            systemSettingService.updateSetting(settingKey, settingValue);
            redirectAttributes.addFlashAttribute(SUCCESS_MESSAGE, "Đã cập nhật cài đặt hệ thống thành công!");
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute(ERROR_MESSAGE, "Lỗi khi cập nhật cài đặt: " + e.getMessage());
        }
        return REDIRECT_SYSTEM_CONFIG;
    }

    @PostMapping("/system-config/delete")
    public String deleteSystemSetting(@RequestParam Long id,
            RedirectAttributes redirectAttributes) {
        try {
            systemSettingService.deleteSetting(id);
            redirectAttributes.addFlashAttribute(SUCCESS_MESSAGE, "Đã xóa cài đặt hệ thống thành công!");
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute(ERROR_MESSAGE, "Lỗi khi xóa cài đặt: " + e.getMessage());
        }
        return REDIRECT_SYSTEM_CONFIG;
    }

}
