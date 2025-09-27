package vn.group3.marketplace.controller;

import vn.group3.marketplace.domain.entity.Product;
import vn.group3.marketplace.service.ProductService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/products")
public class ProductController {
    private final ProductService productService;

    public ProductController(ProductService productService) {
        this.productService = productService;
    }

    @GetMapping
    public String listProducts(Model model) {
        // model.addAttribute("products", productService.findAll());
        return "product/list";
    }

    @GetMapping("/{id}")
    public String getProduct(@PathVariable Long id, Model model) {
        // model.addAttribute("product", productService.findById(id).orElseThrow());
        return "product/detail";
    }

    @PostMapping
    public String saveProduct(@ModelAttribute Product product) {
        // productService.save(product);
        return "redirect:/products";
    }
}
