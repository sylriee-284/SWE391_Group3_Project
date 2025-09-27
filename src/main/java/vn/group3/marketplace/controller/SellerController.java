package vn.group3.marketplace.controller;

import vn.group3.marketplace.service.ProductService;
import vn.group3.marketplace.service.OrderService;
import vn.group3.marketplace.service.WalletService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/seller")
public class SellerController {

    private final ProductService productService;
    private final OrderService orderService;
    private final WalletService walletService;

    public SellerController(ProductService productService,
            OrderService orderService,
            WalletService walletService) {
        this.productService = productService;
        this.orderService = orderService;
        this.walletService = walletService;
    }

    // // Trang chính của seller
    // @GetMapping("/dashboard")
    // public String dashboard(Model model) {
    // // Thêm thống kê: tổng số sản phẩm, đơn hàng, doanh thu
    // model.addAttribute("productCount", productService.countByCurrentSeller());
    // model.addAttribute("orderCount", orderService.countByCurrentSeller());
    // model.addAttribute("revenue", walletService.getRevenueByCurrentSeller());
    // return "seller/dashboard";
    // }

    // // Quản lý sản phẩm
    // @GetMapping("/products")
    // public String manageProducts(Model model) {
    // model.addAttribute("products", productService.findByCurrentSeller());
    // return "seller/products";
    // }

    // // Quản lý đơn hàng
    // @GetMapping("/orders")
    // public String manageOrders(Model model) {
    // model.addAttribute("orders", orderService.findByCurrentSeller());
    // return "seller/orders";
    // }

    // // Xem báo cáo doanh thu
    // @GetMapping("/revenue")
    // public String revenueReport(Model model) {
    // model.addAttribute("revenue", walletService.getRevenueByCurrentSeller());
    // return "seller/revenue";
    // }
}
