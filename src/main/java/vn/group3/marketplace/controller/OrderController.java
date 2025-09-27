package vn.group3.marketplace.controller;

import vn.group3.marketplace.domain.entity.Order;
import vn.group3.marketplace.service.OrderService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/orders")
public class OrderController {
    private final OrderService orderService;

    public OrderController(OrderService orderService) {
        this.orderService = orderService;
    }

    @GetMapping
    public String listOrders(Model model) {
        // model.addAttribute("orders", orderService.findAll());
        return "order/list";
    }

    @GetMapping("/{id}")
    public String getOrder(@PathVariable Long id, Model model) {
        // model.addAttribute("order", orderService.findById(id).orElseThrow());
        return "order/detail";
    }

    @PostMapping
    public String saveOrder(@ModelAttribute Order order) {
        // orderService.save(order);
        return "redirect:/orders";
    }
}
