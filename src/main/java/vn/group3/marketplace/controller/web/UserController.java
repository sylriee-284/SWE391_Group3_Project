package vn.group3.marketplace.controller.web;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import vn.group3.marketplace.domain.entity.User;
import vn.group3.marketplace.service.interfaces.UserService;
import vn.group3.marketplace.service.interfaces.WalletService;

import jakarta.validation.Valid;
import java.security.Principal;
import java.util.Map;
import java.util.Optional;

/**
 * Web controller for User management
 * Handles JSP-based user interface for user operations
 */
@Controller
@RequestMapping("/users")
@RequiredArgsConstructor
@Slf4j
public class UserController {

    private final UserService userService;
    private final WalletService walletService;

    /**
     * Display user list page
     */
    @GetMapping
    public String listUsers(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "id") String sort,
            @RequestParam(defaultValue = "desc") String direction,
            @RequestParam(required = false) String search,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String role,
            Model model) {

        Sort.Direction sortDirection = "desc".equalsIgnoreCase(direction) ? 
            Sort.Direction.DESC : Sort.Direction.ASC;
        Pageable pageable = PageRequest.of(page, size, Sort.by(sortDirection, sort));

        Page<User> users;
        
        if (search != null && !search.trim().isEmpty()) {
            users = userService.searchUsers(search.trim(), pageable);
            model.addAttribute("search", search);
        } else if (status != null && !status.trim().isEmpty()) {
            users = userService.getUsersByStatus(status, pageable);
            model.addAttribute("status", status);
        } else if (role != null && !role.trim().isEmpty()) {
            users = userService.getUsersByRole(role, pageable);
            model.addAttribute("role", role);
        } else {
            users = userService.getAllUsers(pageable);
        }

        model.addAttribute("users", users);
        model.addAttribute("currentPage", page);
        model.addAttribute("pageSize", size);
        model.addAttribute("sortField", sort);
        model.addAttribute("sortDirection", direction);
        
        // Add statistics
        Map<String, Long> stats = userService.getUserStatistics();
        model.addAttribute("userStats", stats);

        return "user/list";
    }

    /**
     * Display user profile page
     */
    @GetMapping("/profile")
    public String userProfile(Principal principal, Model model) {
        if (principal == null) {
            return "redirect:/auth/login";
        }

        Optional<User> userOpt = userService.findByUsername(principal.getName());
        if (userOpt.isEmpty()) {
            return "redirect:/auth/login";
        }

        User user = userOpt.get();
        model.addAttribute("user", user);
        
        // Add wallet information
        if (user.getWallet() != null) {
            model.addAttribute("walletBalance", user.getWallet().getBalance());
            model.addAttribute("formattedBalance", user.getWallet().getFormattedBalance());
        }

        return "user/profile";
    }

    /**
     * Display user details page
     */
    @GetMapping("/{id}")
    public String userDetails(@PathVariable Long id, Model model) {
        Optional<User> userOpt = userService.findById(id);
        if (userOpt.isEmpty()) {
            return "redirect:/users?error=User not found";
        }

        User user = userOpt.get();
        model.addAttribute("user", user);
        
        // Add wallet information
        if (user.getWallet() != null) {
            model.addAttribute("walletBalance", user.getWallet().getBalance());
        }

        return "user/details";
    }

    /**
     * Display user registration form
     */
    @GetMapping("/register")
    public String showRegistrationForm(Model model) {
        model.addAttribute("user", new User());
        return "user/register";
    }

    /**
     * Process user registration
     */
    @PostMapping("/register")
    public String registerUser(
            @Valid @ModelAttribute User user,
            BindingResult bindingResult,
            @RequestParam String password,
            @RequestParam String confirmPassword,
            Model model,
            RedirectAttributes redirectAttributes) {

        // Validate passwords match
        if (!password.equals(confirmPassword)) {
            bindingResult.rejectValue("passwordHash", "error.user", "Passwords do not match");
        }

        // Check for validation errors
        if (bindingResult.hasErrors()) {
            model.addAttribute("user", user);
            return "user/register";
        }

        try {
            User registeredUser = userService.registerUser(user, password);
            redirectAttributes.addFlashAttribute("success", 
                "Registration successful! Welcome " + registeredUser.getDisplayName());
            return "redirect:/auth/login";
        } catch (IllegalArgumentException e) {
            bindingResult.rejectValue("username", "error.user", e.getMessage());
            model.addAttribute("user", user);
            return "user/register";
        }
    }

    /**
     * Display edit profile form
     */
    @GetMapping("/edit")
    public String showEditForm(Principal principal, Model model) {
        if (principal == null) {
            return "redirect:/auth/login";
        }

        Optional<User> userOpt = userService.findByUsername(principal.getName());
        if (userOpt.isEmpty()) {
            return "redirect:/auth/login";
        }

        model.addAttribute("user", userOpt.get());
        return "user/edit";
    }

    /**
     * Process profile update
     */
    @PostMapping("/edit")
    public String updateProfile(
            @Valid @ModelAttribute User user,
            BindingResult bindingResult,
            Principal principal,
            Model model,
            RedirectAttributes redirectAttributes) {

        if (bindingResult.hasErrors()) {
            model.addAttribute("user", user);
            return "user/edit";
        }

        try {
            User updatedUser = userService.updateUser(user);
            redirectAttributes.addFlashAttribute("success", "Profile updated successfully!");
            return "redirect:/users/profile";
        } catch (IllegalArgumentException e) {
            bindingResult.rejectValue("id", "error.user", e.getMessage());
            model.addAttribute("user", user);
            return "user/edit";
        }
    }

    /**
     * Display change password form
     */
    @GetMapping("/change-password")
    public String showChangePasswordForm() {
        return "user/change-password";
    }

    /**
     * Process password change
     */
    @PostMapping("/change-password")
    public String changePassword(
            @RequestParam String oldPassword,
            @RequestParam String newPassword,
            @RequestParam String confirmPassword,
            Principal principal,
            RedirectAttributes redirectAttributes) {

        if (principal == null) {
            return "redirect:/auth/login";
        }

        // Validate new passwords match
        if (!newPassword.equals(confirmPassword)) {
            redirectAttributes.addFlashAttribute("error", "New passwords do not match");
            return "redirect:/users/change-password";
        }

        Optional<User> userOpt = userService.findByUsername(principal.getName());
        if (userOpt.isEmpty()) {
            return "redirect:/auth/login";
        }

        boolean success = userService.changePassword(userOpt.get().getId(), oldPassword, newPassword);
        if (success) {
            redirectAttributes.addFlashAttribute("success", "Password changed successfully!");
        } else {
            redirectAttributes.addFlashAttribute("error", "Current password is incorrect");
        }

        return "redirect:/users/change-password";
    }

    /**
     * Check username availability (AJAX endpoint)
     */
    @GetMapping("/check-username")
    @ResponseBody
    public Map<String, Boolean> checkUsername(@RequestParam String username) {
        boolean available = userService.isUsernameAvailable(username);
        return Map.of("available", available);
    }

    /**
     * Check email availability (AJAX endpoint)
     */
    @GetMapping("/check-email")
    @ResponseBody
    public Map<String, Boolean> checkEmail(@RequestParam String email) {
        boolean available = userService.isEmailAvailable(email);
        return Map.of("available", available);
    }

    /**
     * Toggle user status (AJAX endpoint)
     */
    @PostMapping("/{id}/toggle-status")
    @ResponseBody
    public Map<String, Object> toggleUserStatus(
            @PathVariable Long id,
            @RequestParam boolean enabled) {

        try {
            User user = userService.setUserEnabled(id, enabled);
            return Map.of(
                "success", true,
                "message", enabled ? "Người dùng đã được kích hoạt" : "Người dùng đã bị vô hiệu hóa",
                "enabled", user.isEnabled()
            );
        } catch (Exception e) {
            return Map.of(
                "success", false,
                "message", "Có lỗi xảy ra: " + e.getMessage()
            );
        }
    }
}
