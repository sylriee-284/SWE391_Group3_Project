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
    @GetMapping("/{productId}")
    public String getProductDetail(@PathVariable Long productId, Model model) {
        Product product = productService.getProductById(productId);

        if (product == null) {
            model.addAttribute("errorMessage", "Không tìm thấy sản phẩm");
            return "redirect:/";
        }

        // Check if product is active
        if (!product.getStatus().name().equals("ACTIVE")) {
            model.addAttribute("errorMessage", "Sản phẩm này hiện không khả dụng");
            return "redirect:/";
        }

        model.addAttribute("product", product);
        return "product/detail";
    }

    /**
     * Handle buy now action
     * 
     * @param productId Product ID
     * @param quantity  Quantity to buy
     * @param model     Model for response
     * @return Response view or redirect
     */
    @PostMapping("/{productId}/buy-now")
    public String buyNow(@PathVariable Long productId,
            @RequestParam(defaultValue = "1") Integer quantity,
            Model model) {
        try {
            Product product = productService.getProductById(productId);

            if (product == null) {
                model.addAttribute("errorMessage", "Không tìm thấy sản phẩm");
                return "redirect:/product/" + productId;
            }

            if (quantity > product.getStock()) {
                model.addAttribute("errorMessage", "Số lượng yêu cầu vượt quá tồn kho");
                return "redirect:/product/" + productId;
            }

            // TODO: Implement buy now logic - redirect to checkout
            // For now, redirect to product page with message
            model.addAttribute("successMessage", "Chuyển đến trang thanh toán");
            return "redirect:/checkout?productId=" + productId + "&quantity=" + quantity;

        } catch (Exception e) {
            model.addAttribute("errorMessage", "Có lỗi xảy ra khi mua sản phẩm");
            return "redirect:/product/" + productId;
        }
    }
}