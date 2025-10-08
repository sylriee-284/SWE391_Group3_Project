package vn.group3.marketplace.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/seller")
public class SellerController {

    // // Seller main page
    // @GetMapping("/dashboard")
    // public String dashboard(Model model) {
    // // Add statistics: total products, orders, revenue
    // model.addAttribute("productCount", productService.countByCurrentSeller());
    // model.addAttribute("orderCount", orderService.countByCurrentSeller());
    // model.addAttribute("revenue", walletService.getRevenueByCurrentSeller());
    // return "seller/dashboard";
    // }

    // // Manage products
    // @GetMapping("/products")
    // public String manageProducts(Model model) {
    // model.addAttribute("products", productService.findByCurrentSeller());
    // return "seller/products";
    // }

    // // Manage orders
    // @GetMapping("/orders")
    // public String manageOrders(Model model) {
    // model.addAttribute("orders", orderService.findByCurrentSeller());
    // return "seller/orders";
    // }

    // // View revenue report
    // @GetMapping("/revenue")
    // public String revenueReport(Model model) {
    // model.addAttribute("revenue", walletService.getRevenueByCurrentSeller());
    // return "seller/revenue";
    // }
}
