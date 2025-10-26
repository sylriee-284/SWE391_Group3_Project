package vn.group3.marketplace.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import vn.group3.marketplace.domain.entity.Product;
import vn.group3.marketplace.service.ProductService;

/**
 * Controller for all products listing page
 */
@Controller
@RequestMapping("/products")
@RequiredArgsConstructor
public class ProductListController {

    private final ProductService productService;
    private final vn.group3.marketplace.service.CategoryService categoryService;

    @GetMapping
    public String getAllProducts(
            @RequestParam(value = "sort", defaultValue = "soldQuantity") String sort,
            @PageableDefault(size = 12) Pageable pageable,
            Model model) {

        // Determine sort direction based on field
        String sortDirection;
        switch (sort) {
            case "price":
                sortDirection = "asc"; // Giá từ thấp đến cao
                break;
            case "soldQuantity":
                sortDirection = "desc"; // Sản phẩm nổi bật từ cao đến thấp
                break;
            case "createdAt":
                sortDirection = "desc"; // Mới nhất trước
                break;
            default:
                sortDirection = "desc"; // Mặc định từ cao đến thấp
        }

        // Get all products with sorting
        Page<Product> products = productService.getAllProducts(
                pageable.getPageNumber(),
                pageable.getPageSize(),
                sort,
                sortDirection);

        // Add attributes to model
        model.addAttribute("products", products);
        model.addAttribute("sortBy", sort);

        // Pagination attributes
        model.addAttribute("currentPage", products.getNumber());
        model.addAttribute("totalPages", products.getTotalPages());
        model.addAttribute("totalElements", products.getTotalElements());
        model.addAttribute("size", products.getSize());
        model.addAttribute("hasPrevious", products.hasPrevious());
        model.addAttribute("hasNext", products.hasNext());
        model.addAttribute("previousPage", products.hasPrevious() ? products.getNumber() - 1 : 0);
        model.addAttribute("nextPage", products.hasNext() ? products.getNumber() + 1 : products.getTotalPages() - 1);

        return "product/list";
    }

    @GetMapping("/search")
    public String searchProducts(
            @RequestParam(value = "keyword", required = false) String keyword,
            @RequestParam(value = "sort", defaultValue = "soldQuantity") String sort,
            @RequestParam(value = "direction", defaultValue = "desc") String direction,
            @RequestParam(value = "parentCategory", required = false) Long parentCategoryId,
            @RequestParam(value = "childCategory", required = false) Long childCategoryId,
            @PageableDefault(size = 5) Pageable pageable,
            Model model) {

        // Allow searching with just category filter, no keyword required
        if (keyword == null) {
            keyword = "";
        }

        // Determine sort direction - use provided direction or default based on field
        String sortDirection = direction;
        if (sortDirection == null || sortDirection.trim().isEmpty()) {
            switch (sort) {
                case "price":
                    sortDirection = "asc"; // Giá từ thấp đến cao
                    break;
                case "soldQuantity":
                    sortDirection = "desc"; // Sản phẩm nổi bật từ cao đến thấp
                    break;
                case "createdAt":
                    sortDirection = "desc"; // Mới nhất trước
                    break;
                default:
                    sortDirection = "desc"; // Mặc định từ cao đến thấp
            }
        }

        // Search products with filters - need to implement searchProductsWithFilters
        // method
        Page<Product> products;
        if (parentCategoryId != null || childCategoryId != null) {
            // Use filtered search method
            products = productService.searchProductsWithFilters(
                    keyword.trim(),
                    parentCategoryId,
                    childCategoryId,
                    pageable.getPageNumber(),
                    pageable.getPageSize(),
                    sort,
                    sortDirection);
        } else {
            // Use basic search method
            products = productService.searchAllProducts(
                    keyword.trim(),
                    pageable.getPageNumber(),
                    pageable.getPageSize(),
                    sort,
                    sortDirection);
        }

        // Load categories for dropdowns
        try {
            model.addAttribute("parentCategories", categoryService.getParentCategories());
            if (parentCategoryId != null) {
                model.addAttribute("childCategories", categoryService.getChildCategories(parentCategoryId));
            } else {
                model.addAttribute("childCategories", java.util.Collections.emptyList());
            }
        } catch (Exception e) {
            // Fallback if category service fails
            model.addAttribute("parentCategories", java.util.Collections.emptyList());
            model.addAttribute("childCategories", java.util.Collections.emptyList());
        }

        // Add attributes to model
        model.addAttribute("products", products);
        model.addAttribute("sortBy", sort);
        model.addAttribute("sortDirection", sortDirection);
        model.addAttribute("keyword", keyword);
        model.addAttribute("selectedParentCategory", parentCategoryId);
        model.addAttribute("selectedChildCategory", childCategoryId);

        // Pagination attributes
        model.addAttribute("currentPage", products.getNumber());
        model.addAttribute("totalPages", products.getTotalPages());
        model.addAttribute("totalElements", products.getTotalElements());
        model.addAttribute("size", products.getSize());
        model.addAttribute("hasPrevious", products.hasPrevious());
        model.addAttribute("hasNext", products.hasNext());
        model.addAttribute("previousPage", products.hasPrevious() ? products.getNumber() - 1 : 0);
        model.addAttribute("nextPage", products.hasNext() ? products.getNumber() + 1 : products.getTotalPages() - 1);

        return "product/search-results";
    }
}