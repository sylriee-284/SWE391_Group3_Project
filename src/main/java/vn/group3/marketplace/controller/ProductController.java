package vn.group3.marketplace.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import vn.group3.marketplace.domain.entity.Product;
import vn.group3.marketplace.service.ProductService;

@Controller
@RequestMapping("/product")
@RequiredArgsConstructor
public class ProductController {

    private final ProductService productService;

    /**
     * Display product detail page
     * 
     * @param productId Product ID
     * @param model     Model to pass data to view
     * @return Product detail view
     */

    @GetMapping("/{slug}")
    public String getProductDetail(@PathVariable String slug, Model model) {
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

        // Add product and shop information to model
        model.addAttribute("product", product);
        model.addAttribute("shop", product.getSellerStore());
        model.addAttribute("shopOwner", product.getSellerStore().getOwner());

        return "product/detail";
    }

}