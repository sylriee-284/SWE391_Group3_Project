package vn.group3.marketplace.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import vn.group3.marketplace.domain.entity.Category;
import vn.group3.marketplace.security.CustomUserDetails;
import vn.group3.marketplace.service.CategoryService;

import java.util.List;

@Controller
public class CategoryController {

    private final CategoryService categoryService;

    public CategoryController(CategoryService categoryService) {
        this.categoryService = categoryService;
    }

    /**
     * Display category by name
     */
    @GetMapping("/category/{categoryName}")
    public String getCategoryByName(@PathVariable String categoryName) {
        // Simple redirect to homepage for now
        return "redirect:/homepage";
    }

    // --- CRUD: Start of Admin Category Management ---
    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/api/admin/categories")
    public ResponseEntity<?> getAllCategories() {
        return ResponseEntity.ok(categoryService.getAll());
    }

    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/api/admin/categories/{id}")
    public ResponseEntity<?> getCategoryById(@PathVariable Long id) {
        return categoryService.getById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PreAuthorize("hasRole('ADMIN')")
    @PostMapping("/api/admin/categories")
    public ResponseEntity<?> createCategory(@RequestBody Category category) {
        return ResponseEntity.ok(categoryService.create(category));
    }

    @PreAuthorize("hasRole('ADMIN')")
    @PutMapping("/api/admin/categories/{id}")
    public ResponseEntity<?> updateCategory(@PathVariable Long id, @RequestBody Category category) {
        return ResponseEntity.ok(categoryService.update(id, category));
    }

    @PreAuthorize("hasRole('ADMIN')")
    @DeleteMapping("/api/admin/categories/{id}")
    public ResponseEntity<?> softDeleteCategory(@PathVariable Long id, Authentication auth) {
        CustomUserDetails admin = (CustomUserDetails) auth.getPrincipal();
        categoryService.softDelete(id, admin.getId());
        return ResponseEntity.ok("Category deleted successfully (soft delete)");
    }
    // --- CRUD: End of Admin Category Management ---
}
