package vn.group3.marketplace.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import vn.group3.marketplace.domain.entity.Product;
import vn.group3.marketplace.security.CustomUserDetails;
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

        // Add product and shop information to model
        model.addAttribute("product", product);
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

    /**
     * Buy now action with server-side quantity validation
     */
    @PostMapping("/{slug}/buy-now")
    public String buyNow(
            @PathVariable String slug,
            @RequestParam(name = "quantity", required = false) String quantityStr,
            RedirectAttributes redirectAttributes) {

        Product product = productService.getProductBySlug(slug);
        if (product == null) {
            redirectAttributes.addFlashAttribute("errorMessage", "Không tìm thấy sản phẩm");
            return "redirect:/";
        }

        if (!"ACTIVE".equals(product.getStatus().name())) {
            redirectAttributes.addFlashAttribute("errorMessage", "Sản phẩm này hiện không khả dụng");
            return "redirect:/";
        }

        // Basic validation: quantity must be digits
        if (quantityStr == null || !quantityStr.matches("\\d+")) {
            redirectAttributes.addFlashAttribute("errorMessage",
                    "Số lượng không hợp lệ. Vui lòng nhập số nguyên dương.");
            redirectAttributes.addFlashAttribute("lastQuantity", quantityStr);
            return "redirect:/product/" + slug;
        }

        int quantity;
        try {
            quantity = Integer.parseInt(quantityStr);
        } catch (NumberFormatException ex) {
            redirectAttributes.addFlashAttribute("errorMessage", "Số lượng không hợp lệ.");
            redirectAttributes.addFlashAttribute("lastQuantity", quantityStr);
            return "redirect:/product/" + slug;
        }

        if (quantity < 1) {
            redirectAttributes.addFlashAttribute("errorMessage", "Số lượng tối thiểu là 1.");
            redirectAttributes.addFlashAttribute("lastQuantity", quantity);
            return "redirect:/product/" + slug;
        }

        if (product.getStock() != null && quantity > product.getStock()) {
            redirectAttributes.addFlashAttribute("errorMessage", "Số lượng vượt quá tồn kho.");
            redirectAttributes.addFlashAttribute("lastQuantity", quantity);
            return "redirect:/product/" + slug;
        }

        // TODO: tiếp tục luồng đặt hàng/checkout tại đây
        // Hiện tại chỉ xác thực đầu vào và quay lại trang chi tiết với thông báo thành
        // công
        redirectAttributes.addFlashAttribute("successMessage",
                "Số lượng hợp lệ: " + quantity + ". Tiếp tục quy trình mua hàng.");
        redirectAttributes.addFlashAttribute("lastQuantity", quantity);
        return "redirect:/product/" + slug;
    }

}