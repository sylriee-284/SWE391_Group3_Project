package vn.group3.marketplace.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

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

    @GetMapping("/dashboard")
    public String dashboard(Model model) {
        // Load report data: orders, users, revenue, disputes...
        return "admin/dashboard";
    }

    @GetMapping("/categories")
    public String manageCategories() {
        // Parent categories are automatically loaded by GlobalControllerAdvice
        return "admin/categories";
    }

    // --- CRUD: Start of Admin Account Management ---
    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/api/admin/users")
    public ResponseEntity<?> getAllUsers() {
        return ResponseEntity.ok(userService.getAllActiveUsers());
    }

    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/api/admin/users/{id}")
    public ResponseEntity<?> getUserById(@PathVariable Long id) {
        return userService.getUserById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PreAuthorize("hasRole('ADMIN')")
    @PostMapping("/api/admin/users")
    public ResponseEntity<?> createUser(@RequestBody User user) {
        return ResponseEntity.ok(userService.createUser(user));
    }

    @PreAuthorize("hasRole('ADMIN')")
    @PutMapping("/api/admin/users/{id}")
    public ResponseEntity<?> updateUser(@PathVariable Long id, @RequestBody User updatedUser) {
        return ResponseEntity.ok(userService.updateUser(id, updatedUser));
    }

    @PreAuthorize("hasRole('ADMIN')")
    @DeleteMapping("/api/admin/users/{id}")
    public ResponseEntity<?> softDeleteUser(@PathVariable Long id, Authentication auth) {
        CustomUserDetails admin = (CustomUserDetails) auth.getPrincipal();
        userService.softDeleteUser(id, admin.getId());
        return ResponseEntity.ok("User deleted successfully (soft delete)");
    }
    // --- CRUD: End of Admin Account Management ---

}
