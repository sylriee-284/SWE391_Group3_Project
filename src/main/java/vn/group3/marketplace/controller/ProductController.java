package vn.group3.marketplace.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import vn.group3.marketplace.domain.entity.Product;
import vn.group3.marketplace.security.CustomUserDetails;
import vn.group3.marketplace.service.ProductService;
import vn.group3.marketplace.service.ProductStorageService;

@Controller
@RequestMapping("/product")
@RequiredArgsConstructor
public class ProductController {

    private final ProductService productService;
    private final ProductStorageService productStorageService;

    /**
     * Display product detail page
     * 
     * @param productId Product ID
     * @param model     Model to pass data to view
     * @return Product detail view
     */

    @GetMapping("/{slug}")
    public String getProductDetail(@PathVariable String slug,
            @AuthenticationPrincipal CustomUserDetails currentUser,
            Model model) {
        Product product = productService.getProductBySlug(slug);

        if (product == null) {
            model.addAttribute("errorMessage", "Không tìm thấy sản phẩm");
            return "redirect:/";
        }

        // Check if product is active
        if (!product.getStatus().name().equals("ACTIVE")) {
            model.addAttribute("errorMessage", "Sản phẩm này hiện không khả dụng");
            return "redirect:/";
        }

        // Calculate dynamic stock from ProductStorage
        long dynamicStock = productStorageService.getAvailableStock(product.getId());

        // Add product and shop information to model
        model.addAttribute("product", product);
        model.addAttribute("dynamicStock", dynamicStock);
        model.addAttribute("shop", product.getSellerStore());
        model.addAttribute("shopOwner", product.getSellerStore().getOwner());

        // Add user balance if user is authenticated
        if (currentUser != null) {
            model.addAttribute("userBalance", currentUser.getBalance());
        } else {
            model.addAttribute("userBalance", java.math.BigDecimal.ZERO);
        }

        return "product/detail";
    }

}