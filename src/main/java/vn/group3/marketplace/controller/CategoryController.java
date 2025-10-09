package vn.group3.marketplace.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import vn.group3.marketplace.domain.entity.Category;
import vn.group3.marketplace.security.CustomUserDetails;
import vn.group3.marketplace.service.CategoryService;

import java.util.List;

@Controller
@RequestMapping("/admin/category-management")
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
    // Display list category
    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping
    public String getAllCategories(Model model) {
        model.addAttribute("categories", categoryService.getAll());
        return "admin/categories"; // JSP hiển thị danh sách category
    }

    // Display form add new category
    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/create")
    public String showCreateCategoryForm(Model model) {
        model.addAttribute("category", new Category());
        model.addAttribute("formTitle", "Thêm danh mục mới");
        return "admin/category_form"; // JSP form add
    }

    // Add category
    @PreAuthorize("hasRole('ADMIN')")
    @PostMapping
    public String createCategory(@ModelAttribute("category") Category category,
            RedirectAttributes redirectAttributes) {
        categoryService.create(category);
        redirectAttributes.addFlashAttribute("success", "Thêm danh mục thành công!");
        return "redirect:/admin/categories";
    }

    // Display form edit category
    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/edit/{id}")
    public String showEditCategoryForm(@PathVariable Long id, Model model) {
        Category existing = categoryService.getById(id)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy category ID: " + id));
        model.addAttribute("category", existing);
        model.addAttribute("formTitle", "Chỉnh sửa danh mục");
        return "admin/category_form"; // JSP form edit
    }

    // Update category
    @PreAuthorize("hasRole('ADMIN')")
    @PostMapping("/update/{id}")
    public String updateCategory(@PathVariable Long id,
            @ModelAttribute("category") Category category,
            RedirectAttributes redirectAttributes) {
        categoryService.update(id, category);
        redirectAttributes.addFlashAttribute("success", "Cập nhật danh mục thành công!");
        return "redirect:/admin/categories";
    }

    // Soft deletle category
    @PreAuthorize("hasRole('ADMIN')")
    @PostMapping("/delete/{id}")
    public String softDeleteCategory(@PathVariable Long id,
            Authentication auth,
            RedirectAttributes redirectAttributes) {
        CustomUserDetails admin = (CustomUserDetails) auth.getPrincipal();
        categoryService.softDelete(id, admin.getId());
        redirectAttributes.addFlashAttribute("success", "Đã xóa danh mục thành công (soft delete)!");
        return "redirect:/admin/categories";
    }
    // --- CRUD: End of Admin Category Management ---
}
