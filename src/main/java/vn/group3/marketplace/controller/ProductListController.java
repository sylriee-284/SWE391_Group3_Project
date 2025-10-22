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
}