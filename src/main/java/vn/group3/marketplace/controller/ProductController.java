package vn.group3.marketplace.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
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
    public String create(@ModelAttribute("product") Product product) {
        service.create(product);
        return "redirect:/seller/products";
    }
}
