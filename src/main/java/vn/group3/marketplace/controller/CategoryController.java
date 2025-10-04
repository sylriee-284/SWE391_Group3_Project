package vn.group3.marketplace.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import vn.group3.marketplace.domain.entity.Category;
import vn.group3.marketplace.service.CategoryService;

import java.util.List;

@Controller
@RequestMapping("/categories")
public class CategoryController {

    private final CategoryService categoryService;

    public CategoryController(CategoryService categoryService) {
        this.categoryService = categoryService;
    }

    /**
     * Display all parent categories
     * Note: parentCategories are automatically loaded by GlobalControllerAdvice
     */
    @GetMapping("/parents")
    public String getParentCategories() {
        return "category/parent-categories";
    }

    /**
     * Display child categories of a specific parent
     */
    @GetMapping("/{parentId}/children")
    public String getChildCategories(@PathVariable Long parentId, Model model) {
        List<Category> childCategories = categoryService.getChildCategories(parentId);
        Category parentCategory = categoryService.getCategoryById(parentId);

        model.addAttribute("childCategories", childCategories);
        model.addAttribute("parentCategory", parentCategory);
        return "category/child-categories";
    }

    /**
     * API endpoint to get parent categories as JSON
     */
    @GetMapping("/api/parents")
    @ResponseBody
    public List<Category> getParentCategoriesApi() {
        return categoryService.getParentCategories();
    }

    /**
     * API endpoint to get child categories as JSON
     */
    @GetMapping("/api/{parentId}/children")
    @ResponseBody
    public List<Category> getChildCategoriesApi(@PathVariable Long parentId) {
        return categoryService.getChildCategories(parentId);
    }
}
