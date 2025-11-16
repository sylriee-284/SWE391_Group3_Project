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
import vn.group3.marketplace.service.ProductStorageService;

/**
 * Controller for all products listing page
 */
@Controller
@RequestMapping("/products")
@RequiredArgsConstructor
public class ProductListController {

    private final ProductService productService;
    private final ProductStorageService productStorageService;

    @GetMapping
    public String getAllProducts(
            @RequestParam(value = "sort", defaultValue = "soldQuantity") String sort,
            @PageableDefault(size = 12) Pageable pageable,
            Model model) {

        // Validate pagination parameters
        int page = pageable.getPageNumber();
        int size = pageable.getPageSize();

        if (page < 0) {
            page = 0;
        }

        if (size <= 0 || size > 100) {
            size = 12; // Reset to default if invalid
        }

        String originalSort = sort; // Keep original sort value for UI display

        // Determine sort direction based on field
        String sortDirection;
        switch (sort) {
            case "price":
                sortDirection = "asc"; // Giá từ thấp đến cao
                break;
            case "priceDesc":
                sortDirection = "desc"; // Giá từ cao đến thấp
                sort = "price"; // Use 'price' field but desc direction
                break;
            case "soldQuantity":
                sortDirection = "desc"; // Sản phẩm nổi bật từ cao đến thấp
                break;
            case "createdAt":
                sortDirection = "desc"; // Mới nhất trước
                break;
            default:
                sortDirection = "desc"; // Mặc định từ cao đến thấp
                sort = "soldQuantity";
                originalSort = "soldQuantity";
        }

        // Get all products with sorting
        Page<Product> products = productService.getAllProducts(
                page, // Use validated page
                size, // Use validated size
                sort,
                sortDirection);

        // Calculate dynamic stock for each product from ProductStorage
        java.util.Map<Long, Long> dynamicStockMap = new java.util.HashMap<>();
        products.getContent().forEach(product -> {
            long dynamicStock = productStorageService.getAvailableStock(product.getId());
            dynamicStockMap.put(product.getId(), dynamicStock);
        });

        // Validate page number against actual total pages
        if (page >= products.getTotalPages() && products.getTotalPages() > 0) {
            // Redirect to last page if current page is beyond available pages
            int lastPage = products.getTotalPages() - 1;
            return "redirect:/products?page=" + lastPage + "&size=" + size + "&sort=" + originalSort;
        }

        // Calculate dynamic stock for each product
        products.getContent().forEach(product -> {
            long dynamicStock = productStorageService.getAvailableStock(product.getId());
            // Store dynamic stock in the stock field for JSP access
            product.setStock((int) dynamicStock);
        });

        // Add attributes to model
        model.addAttribute("products", products);
        model.addAttribute("dynamicStockMap", dynamicStockMap);
        model.addAttribute("sortBy", sort);
        model.addAttribute("originalSort", originalSort); // For radio button selection
        model.addAttribute("sortDirection", sortDirection);

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
            @PageableDefault(size = 12) Pageable pageable,
            Model model) {

        // Validate pagination parameters
        int page = pageable.getPageNumber();
        int size = pageable.getPageSize();

        if (page < 0) {
            page = 0;
        }

        if (size <= 0 || size > 100) {
            size = 12; // Reset to default if invalid
        }

        String originalSort = sort; // Keep original sort value for UI display

        // Determine sort direction based on field (same logic as getAllProducts)
        String sortDirection;
        switch (sort) {
            case "price":
                sortDirection = "asc"; // Giá từ thấp đến cao
                break;
            case "priceDesc":
                sortDirection = "desc"; // Giá từ cao đến thấp
                sort = "price"; // Use 'price' field but desc direction
                break;
            case "soldQuantity":
                sortDirection = "desc"; // Sản phẩm nổi bật từ cao đến thấp
                break;
            case "createdAt":
                sortDirection = "desc"; // Mới nhất trước
                break;
            default:
                sortDirection = "desc"; // Mặc định từ cao đến thấp
                sort = "soldQuantity";
                originalSort = "soldQuantity";
        }

        // Use search with sorting
        Page<Product> products = productService.searchAllProducts(
                keyword != null ? keyword.trim() : "",
                page, // Use validated page
                size, // Use validated size
                sort,
                sortDirection);

        // Calculate dynamic stock for each product from ProductStorage
        java.util.Map<Long, Long> dynamicStockMap = new java.util.HashMap<>();
        products.getContent().forEach(product -> {
            long dynamicStock = productStorageService.getAvailableStock(product.getId());
            dynamicStockMap.put(product.getId(), dynamicStock);
        });

        // Validate page number against actual total pages
        if (page >= products.getTotalPages() && products.getTotalPages() > 0) {
            // Redirect to last page if current page is beyond available pages
            int lastPage = products.getTotalPages() - 1;
            String keywordParam = keyword != null
                    ? "&keyword=" + java.net.URLEncoder.encode(keyword, java.nio.charset.StandardCharsets.UTF_8)
                    : "";
            return "redirect:/products/search?page=" + lastPage + "&size=" + size + "&sort=" + originalSort
                    + keywordParam;
        }

        // Calculate dynamic stock for each product
        products.getContent().forEach(product -> {
            long dynamicStock = productStorageService.getAvailableStock(product.getId());
            // Store dynamic stock in the stock field for JSP access
            product.setStock((int) dynamicStock);
        });

        // Add attributes to model
        model.addAttribute("products", products);
        model.addAttribute("dynamicStockMap", dynamicStockMap);
        model.addAttribute("keyword", keyword);
        model.addAttribute("sortBy", sort);
        model.addAttribute("originalSort", originalSort); // For radio button selection
        model.addAttribute("sortDirection", sortDirection);

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