package vn.group3.marketplace.controller;

import org.springframework.data.domain.Page;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import vn.group3.marketplace.domain.entity.Category;
import vn.group3.marketplace.domain.entity.Product;
import vn.group3.marketplace.service.CategoryService;
import vn.group3.marketplace.service.ProductService;
import vn.group3.marketplace.service.ProductStorageService;

import java.util.List;

@Controller
public class CategoryController {

    private final CategoryService categoryService;
    private final ProductService productService;
    private final ProductStorageService productStorageService;

    public CategoryController(CategoryService categoryService, ProductService productService,
            ProductStorageService productStorageService) {
        this.categoryService = categoryService;
        this.productService = productService;
        this.productStorageService = productStorageService;
    }

    /**
     * Display category products with filtering and pagination
     */
    // test
    @GetMapping("/category/{categoryName}")
    public String getCategoryByName(
            @PathVariable String categoryName,
            @RequestParam(value = "page", defaultValue = "0") int page,
            @RequestParam(value = "size", defaultValue = "12") int size,
            @RequestParam(value = "sort", defaultValue = "name") String sortBy,
            @RequestParam(value = "direction", defaultValue = "asc") String sortDirection,
            @RequestParam(value = "keyword", required = false) String keyword,
            @RequestParam(value = "childCategory", required = false) Long childCategoryId,
            Model model) {

        // Find parent category by name (case insensitive)
        Category parentCategory = categoryService.getParentCategoryByName(categoryName);

        if (parentCategory == null) {
            // Handle category not found - redirect to home with error
            model.addAttribute("errorMessage", "Không tìm thấy danh mục: " + categoryName);
            return "redirect:/";
        }

        Page<Product> products;

        // If child category is selected, filter by child category
        if (childCategoryId != null) {
            Category childCategory = categoryService.getCategoryById(childCategoryId);
            if (childCategory != null && childCategory.getParent().getId().equals(parentCategory.getId())) {
                if (keyword != null && !keyword.trim().isEmpty()) {
                    products = productService.searchProductsByCategory(childCategory, keyword, page, size, sortBy,
                            sortDirection);
                } else {
                    products = productService.getProductsByCategory(childCategory, page, size, sortBy, sortDirection);
                }
            } else {
                // Invalid child category, fall back to parent category
                if (keyword != null && !keyword.trim().isEmpty()) {
                    products = productService.searchProductsByParentCategory(parentCategory, keyword, page, size,
                            sortBy, sortDirection);
                } else {
                    products = productService.getProductsByParentCategory(parentCategory, page, size, sortBy,
                            sortDirection);
                }
            }
        } else {
            // Show all products from parent category
            if (keyword != null && !keyword.trim().isEmpty()) {
                products = productService.searchProductsByParentCategory(parentCategory, keyword, page, size, sortBy,
                        sortDirection);
            } else {
                products = productService.getProductsByParentCategory(parentCategory, page, size, sortBy,
                        sortDirection);
            }
        }

        // Get child categories for filter
        List<Category> childCategories = categoryService.getChildCategories(parentCategory.getId());

        // Calculate dynamic stock for each product
        products.getContent().forEach(product -> {
            long dynamicStock = productStorageService.getAvailableStock(product.getId());
            // Store dynamic stock in a custom attribute for JSP access
            product.setStock((int) dynamicStock); // Convert long to int for existing stock field
        });

        // Add attributes to model
        model.addAttribute("parentCategory", parentCategory);
        model.addAttribute("childCategories", childCategories);
        model.addAttribute("products", products);
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPages", products.getTotalPages());
        model.addAttribute("totalElements", products.getTotalElements());
        model.addAttribute("sortBy", sortBy);
        model.addAttribute("sortDirection", sortDirection);
        model.addAttribute("keyword", keyword);
        model.addAttribute("selectedChildCategory", childCategoryId);

        // Pagination info
        model.addAttribute("hasPrevious", products.hasPrevious());
        model.addAttribute("hasNext", products.hasNext());
        model.addAttribute("previousPage", page > 0 ? page - 1 : 0);
        model.addAttribute("nextPage", page + 1);

        return "category/category-products";
    }
}