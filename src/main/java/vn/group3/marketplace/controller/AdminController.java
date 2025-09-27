package vn.group3.marketplace.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/admin")
public class AdminController {

    @GetMapping("/dashboard")
    public String dashboard(Model model) {
        // load các số liệu báo cáo: orders, users, revenue, disputes...
        return "admin/dashboard";
    }

    @GetMapping("/categories")
    public String manageCategories(Model model) {
        // load danh mục
        return "admin/categories";
    }

    @GetMapping("/complaints")
    public String manageComplaints(Model model) {
        // load danh sách complaint/dispute
        return "admin/complaints";
    }
}
