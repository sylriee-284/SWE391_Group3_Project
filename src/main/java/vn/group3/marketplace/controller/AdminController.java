package vn.group3.marketplace.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/admin")
public class AdminController {

    @GetMapping("/dashboard")
    public String dashboard(Model model) {
        // Load report data: orders, users, revenue...
        return "admin/dashboard";
    }

    @GetMapping("/categories")
    public String manageCategories() {
        // Parent categories are automatically loaded by GlobalControllerAdvice
        return "admin/categories";
    }

}
