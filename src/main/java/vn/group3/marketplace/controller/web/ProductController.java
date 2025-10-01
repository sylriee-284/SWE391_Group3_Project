package vn.group3.marketplace.controller.web;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import vn.group3.marketplace.domain.entity.Product;
import vn.group3.marketplace.domain.entity.User;
import vn.group3.marketplace.domain.enums.ProductCategory;
import vn.group3.marketplace.dto.request.ProductCreateRequest;
import vn.group3.marketplace.dto.request.ProductUpdateRequest;
import vn.group3.marketplace.dto.response.ProductResponse;
import vn.group3.marketplace.service.interfaces.ProductService;

import java.util.Arrays;
import java.util.List;
import java.util.Optional;

/**
 * Controller for product management
 * Handles web requests for product operations
 */
@Slf4j
@Controller
@RequestMapping("/products")
@RequiredArgsConstructor
public class ProductController {

    private final ProductService productService;

    /**
     * Show all active products (public view)
     */
    @GetMapping
    public String listProducts(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "12") int size,
            @RequestParam(defaultValue = "createdAt") String sort,
            @RequestParam(defaultValue = "desc") String direction,
            @RequestParam(required = false) String search,
            @RequestParam(required = false) String category,
            Model model) {

        Sort.Direction sortDirection = "desc".equalsIgnoreCase(direction) ?
                Sort.Direction.DESC : Sort.Direction.ASC;
        Pageable pageable = PageRequest.of(page, size, Sort.by(sortDirection, sort));

        Page<ProductResponse> products;

        if (search != null && !search.trim().isEmpty()) {
            String sanitizedSearch = sanitizeSearchInput(search.trim());

            if (category != null && !category.trim().isEmpty()) {
                ProductCategory productCategory = parseCategory(category);
                if (productCategory != null) {
                    products = productService.searchProducts(sanitizedSearch, productCategory, pageable);
                    model.addAttribute("category", category);
                } else {
                    products = productService.searchProducts(sanitizedSearch, pageable);
                }
            } else {
                products = productService.searchProducts(sanitizedSearch, pageable);
            }
            model.addAttribute("search", sanitizedSearch);
        } else if (category != null && !category.trim().isEmpty()) {
            ProductCategory productCategory = parseCategory(category);
            if (productCategory != null) {
                products = productService.getProductsByCategory(productCategory, pageable);
                model.addAttribute("category", category);
            } else {
                products = productService.getActiveProducts(pageable);
            }
        } else {
            products = productService.getActiveProducts(pageable);
        }

        model.addAttribute("products", products);
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPages", products.getTotalPages());
        model.addAttribute("totalElements", products.getTotalElements());
        model.addAttribute("sort", sort);
        model.addAttribute("direction", direction);
        model.addAttribute("categories", ProductCategory.values());

        return "product/list";
    }

    /**
     * Show product details (public view)
     */
    @GetMapping("/{productId}")
    @org.springframework.transaction.annotation.Transactional(readOnly = true)
    public String viewProduct(@PathVariable Long productId, Model model) {
        Optional<ProductResponse> productOpt = productService.getProductResponseById(productId);

        if (productOpt.isEmpty()) {
            return "redirect:/products?error=product_not_found";
        }

        ProductResponse product = productOpt.get();
        model.addAttribute("product", product);

        // Parse images if stored as comma-separated
        if (product.getProductImages() != null && !product.getProductImages().isEmpty()) {
            String[] images = product.getProductImages().split(",");
            model.addAttribute("productImagesList", Arrays.asList(images));
        }

        return "product/detail";
    }

    /**
     * Show seller's products dashboard
     */
    @GetMapping("/my-products")
    @PreAuthorize("hasRole('SELLER')")
    public String myProducts(
            @AuthenticationPrincipal User currentUser,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "createdAt") String sort,
            @RequestParam(defaultValue = "desc") String direction,
            Model model) {

        Sort.Direction sortDirection = "desc".equalsIgnoreCase(direction) ?
                Sort.Direction.DESC : Sort.Direction.ASC;
        Pageable pageable = PageRequest.of(page, size, Sort.by(sortDirection, sort));

        Page<ProductResponse> products = productService.getProductsBySeller(currentUser.getId(), pageable);

        // Get statistics
        long totalProducts = productService.countProductsBySeller(currentUser.getId());
        long activeProducts = productService.countActiveProductsBySeller(currentUser.getId());
        List<Product> lowStockProducts = productService.getLowStockProducts(currentUser.getId(), 10);
        List<Product> outOfStockProducts = productService.getOutOfStockProducts(currentUser.getId());

        model.addAttribute("products", products);
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPages", products.getTotalPages());
        model.addAttribute("totalElements", products.getTotalElements());
        model.addAttribute("sort", sort);
        model.addAttribute("direction", direction);

        model.addAttribute("totalProducts", totalProducts);
        model.addAttribute("activeProducts", activeProducts);
        model.addAttribute("lowStockProducts", lowStockProducts);
        model.addAttribute("outOfStockProducts", outOfStockProducts);

        return "product/my-products";
    }

    /**
     * Show create product form
     */
    @GetMapping("/create")
    @PreAuthorize("hasRole('SELLER')")
    public String showCreateForm(@AuthenticationPrincipal User currentUser, Model model) {
        model.addAttribute("createRequest", new ProductCreateRequest());
        model.addAttribute("categories", ProductCategory.values());
        return "product/create";
    }

    /**
     * Process product creation
     */
    @PostMapping("/create")
    @PreAuthorize("hasRole('SELLER')")
    public String createProduct(
            @Valid @ModelAttribute("createRequest") ProductCreateRequest request,
            BindingResult bindingResult,
            @AuthenticationPrincipal User currentUser,
            RedirectAttributes redirectAttributes,
            Model model) {

        if (bindingResult.hasErrors()) {
            model.addAttribute("categories", ProductCategory.values());
            return "product/create";
        }

        try {
            Product product = productService.createProduct(currentUser.getId(), request);
            redirectAttributes.addFlashAttribute("success",
                "Sản phẩm đã được tạo thành công! ID: " + product.getId());
            return "redirect:/products/my-products";
        } catch (Exception e) {
            log.error("Failed to create product for user {}: {}", currentUser.getId(), e.getMessage());
            redirectAttributes.addFlashAttribute("error",
                "Không thể tạo sản phẩm: " + e.getMessage());
            return "redirect:/products/create";
        }
    }

    /**
     * Show edit product form
     */
    @GetMapping("/{productId}/edit")
    @PreAuthorize("hasRole('SELLER')")
    public String showEditForm(
            @PathVariable Long productId,
            @AuthenticationPrincipal User currentUser,
            Model model) {

        Optional<Product> productOpt = productService.getProductById(productId);

        if (productOpt.isEmpty()) {
            return "redirect:/products/my-products?error=product_not_found";
        }

        Product product = productOpt.get();

        // Verify ownership
        if (!product.getSeller().getId().equals(currentUser.getId())) {
            return "redirect:/products/my-products?error=unauthorized";
        }

        // Create update request from current product data
        ProductUpdateRequest updateRequest = ProductUpdateRequest.builder()
                .productName(product.getProductName())
                .description(product.getDescription())
                .price(product.getPrice())
                .stockQuantity(product.getStockQuantity())
                .category(product.getCategory())
                .sku(product.getSku())
                .productImages(product.getProductImages())
                .isActive(product.getIsActive())
                .build();

        model.addAttribute("product", product);
        model.addAttribute("updateRequest", updateRequest);
        model.addAttribute("categories", ProductCategory.values());

        return "product/edit";
    }

    /**
     * Process product update
     */
    @PostMapping("/{productId}/edit")
    @PreAuthorize("hasRole('SELLER')")
    public String updateProduct(
            @PathVariable Long productId,
            @Valid @ModelAttribute("updateRequest") ProductUpdateRequest request,
            BindingResult bindingResult,
            @AuthenticationPrincipal User currentUser,
            RedirectAttributes redirectAttributes,
            Model model) {

        Optional<Product> productOpt = productService.getProductById(productId);

        if (productOpt.isEmpty()) {
            return "redirect:/products/my-products?error=product_not_found";
        }

        Product product = productOpt.get();

        if (bindingResult.hasErrors()) {
            model.addAttribute("product", product);
            model.addAttribute("categories", ProductCategory.values());
            return "product/edit";
        }

        try {
            productService.updateProduct(productId, currentUser.getId(), request);
            redirectAttributes.addFlashAttribute("success", "Sản phẩm đã được cập nhật!");
            return "redirect:/products/my-products";
        } catch (Exception e) {
            log.error("Failed to update product {} for user {}: {}",
                productId, currentUser.getId(), e.getMessage());
            redirectAttributes.addFlashAttribute("error",
                "Không thể cập nhật sản phẩm: " + e.getMessage());
            return "redirect:/products/" + productId + "/edit";
        }
    }

    /**
     * Delete product
     */
    @PostMapping("/{productId}/delete")
    @PreAuthorize("hasRole('SELLER')")
    public String deleteProduct(
            @PathVariable Long productId,
            @AuthenticationPrincipal User currentUser,
            RedirectAttributes redirectAttributes) {

        try {
            productService.deleteProduct(productId, currentUser.getId());
            redirectAttributes.addFlashAttribute("success", "Sản phẩm đã được xóa!");
        } catch (Exception e) {
            log.error("Failed to delete product {}: {}", productId, e.getMessage());
            redirectAttributes.addFlashAttribute("error",
                "Không thể xóa sản phẩm: " + e.getMessage());
        }

        return "redirect:/products/my-products";
    }

    /**
     * Toggle product active status
     */
    @PostMapping("/{productId}/toggle-status")
    @PreAuthorize("hasRole('SELLER')")
    public String toggleProductStatus(
            @PathVariable Long productId,
            @AuthenticationPrincipal User currentUser,
            RedirectAttributes redirectAttributes) {

        try {
            Product product = productService.toggleProductStatus(productId, currentUser.getId());
            String status = product.getIsActive() ? "kích hoạt" : "tạm ngưng";
            redirectAttributes.addFlashAttribute("success",
                "Sản phẩm đã được " + status + "!");
        } catch (Exception e) {
            log.error("Failed to toggle product status {}: {}", productId, e.getMessage());
            redirectAttributes.addFlashAttribute("error",
                "Không thể thay đổi trạng thái: " + e.getMessage());
        }

        return "redirect:/products/my-products";
    }

    /**
     * Upload product images
     */
    @PostMapping("/{productId}/upload-images")
    @PreAuthorize("hasRole('SELLER')")
    public String uploadImages(
            @PathVariable Long productId,
            @RequestParam("imageFiles") List<MultipartFile> imageFiles,
            @AuthenticationPrincipal User currentUser,
            RedirectAttributes redirectAttributes) {

        if (imageFiles == null || imageFiles.isEmpty()) {
            redirectAttributes.addFlashAttribute("error", "Vui lòng chọn ít nhất một ảnh!");
            return "redirect:/products/" + productId + "/edit";
        }

        try {
            productService.uploadProductImages(productId, currentUser.getId(), imageFiles);
            redirectAttributes.addFlashAttribute("success", "Ảnh đã được tải lên!");
        } catch (Exception e) {
            log.error("Failed to upload images for product {}: {}", productId, e.getMessage());
            redirectAttributes.addFlashAttribute("error",
                "Không thể tải lên ảnh: " + e.getMessage());
        }

        return "redirect:/products/" + productId + "/edit";
    }

    /**
     * Check SKU availability (AJAX)
     */
    @GetMapping("/check-sku")
    @ResponseBody
    public boolean checkSkuAvailability(
            @RequestParam String sku,
            @RequestParam(required = false) Long excludeProductId) {
        return productService.isSkuAvailable(sku, excludeProductId);
    }

    // Helper methods

    /**
     * Sanitize search input to prevent injection attacks
     */
    private String sanitizeSearchInput(String search) {
        if (search == null) return "";

        // Remove potentially dangerous characters
        String sanitized = search.replaceAll("[<>\"'%;()&+]", "");

        // Limit length
        if (sanitized.length() > 100) {
            sanitized = sanitized.substring(0, 100);
        }

        return sanitized.trim();
    }

    /**
     * Parse category string to ProductCategory enum
     */
    private ProductCategory parseCategory(String category) {
        try {
            return ProductCategory.valueOf(category.toUpperCase());
        } catch (IllegalArgumentException e) {
            log.warn("Invalid category: {}", category);
            return null;
        }
    }
}
