package vn.group3.marketplace.controller;

import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import vn.group3.marketplace.domain.Product;
import vn.group3.marketplace.service.ProductService;

@Controller
public class ProductController {

    private final ProductService service;

    public ProductController(ProductService service) {
        this.service = service;
    }

    @GetMapping("/")
    public String home() {
        return "redirect:/seller/products";
    }

    // Danh sách
    @GetMapping("/seller/products")
    public String list(Model model) {
        model.addAttribute("products", service.findAll());
        return "product_list";
    }

    // Mở form Add
    @GetMapping("/seller/products/new")
    public String addForm(Model model) {
        Product p = new Product();
        p.setType("ACCOUNT");
        p.setStatus("ACTIVE");
        model.addAttribute("product", p);
        return "product_add";
    }

    // Submit tạo
    @PostMapping("/seller/products")
    public String create(@ModelAttribute("product") Product product,
            Model model,
            RedirectAttributes ra) {
        try {
            if (product.getSellerId() != null && product.getSellerId() <= 0) {
                product.setSellerId(null);
            }
            service.create(product);
            ra.addFlashAttribute("successMessage", "Đã thêm sản phẩm: " + product.getName());
            return "redirect:/seller/products";
        } catch (org.springframework.dao.DataIntegrityViolationException ex) {
            model.addAttribute("errorMessage",
                    "Không lưu được vì Seller ID không tồn tại trong bảng users. Hãy để trống hoặc nhập ID hợp lệ.");
            return "product_add";
        }
    }

}
