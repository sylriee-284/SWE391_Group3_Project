package vn.group3.marketplace.controller;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import vn.group3.marketplace.domain.entity.Order;
import vn.group3.marketplace.domain.enums.OrderStatus;
import vn.group3.marketplace.security.CustomUserDetails;
import vn.group3.marketplace.service.OrderService;

@Controller
@RequestMapping("/orders")
public class OrderController {

    private final OrderService orderService;

    public OrderController(OrderService orderService) {
        this.orderService = orderService;
    }

    @GetMapping
    public String listOrders(
            @AuthenticationPrincipal CustomUserDetails currentUser,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(required = false) OrderStatus status,
            @RequestParam(required = false) String key,
            Model model) {
        if (page < 0)
            page = 0;
        if (size <= 0 || size > 100)
            size = 10;

        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createdAt"));

        // Show only orders purchased by current user (buyer)
        Page<Order> ordersPage;
        if (key != null && !key.isEmpty()) {
            ordersPage = orderService.searchByCurrentBuyerAndProductName(status, key, pageable);
        } else {
            ordersPage = status != null
                    ? orderService.findByCurrentBuyerAndStatus(status, pageable)
                    : orderService.findByCurrentBuyer(pageable);
        }

        // Paging helpers
        int totalPages = ordersPage.getTotalPages();
        int currentPage = page;
        int window = 2; // show current-2 .. current+2
        int start = Math.max(0, currentPage - window);
        int end = Math.min(Math.max(0, totalPages - 1), currentPage + window);

        java.util.List<Integer> pages = new java.util.ArrayList<>();
        for (int i = start; i <= end; i++) {
            pages.add(i);
        }

        // Add all model attributes
        model.addAttribute("orders", ordersPage.getContent());
        model.addAttribute("currentPage", currentPage);
        model.addAttribute("totalPages", totalPages);
        model.addAttribute("totalElements", ordersPage.getTotalElements());
        model.addAttribute("size", size);
        model.addAttribute("pages", pages);
        model.addAttribute("hasPrev", currentPage > 0);
        model.addAttribute("hasNext", currentPage + 1 < totalPages);
        model.addAttribute("orderStatuses", OrderStatus.values()); // Send all enum values
        model.addAttribute("selectedStatus", status); // Current selected status
        model.addAttribute("key", key);

        return "order/list";
    }

    @GetMapping("/{id}")
    public String orderDetail(
            @AuthenticationPrincipal CustomUserDetails currentUser,
            @PathVariable Long id,
            Model model) {
        Order order = orderService.findByIdWithProductStorages(id)
                .orElse(null);

        if (order == null) {
            return "redirect:/error";
        }

        boolean canView = (order.getBuyer() != null && currentUser != null
                && order.getBuyer().getId().equals(currentUser.getId()))
                || (order.getSellerStore() != null && currentUser != null
                        && order.getSellerStore().getOwner() != null
                        && order.getSellerStore().getOwner().getId().equals(currentUser.getId()));

        if (!canView) {
            return "redirect:/error";
        }

        // Lấy trực tiếp các ProductStorage đã gán cho order này qua quan hệ @OneToMany
        model.addAttribute("deliveredStorages", order.getProductStorages());
        model.addAttribute("order", order);
        model.addAttribute("orderStatuses", OrderStatus.values()); // Send all enum values
        model.addAttribute("selectedStatus", order.getStatus()); // Current order status
        return "order/detail";
    }

    @PostMapping("/{id}/rate")
    public String rateProduct(
            @PathVariable Long id,
            @RequestParam Integer rating,
            @AuthenticationPrincipal CustomUserDetails currentUser,
            RedirectAttributes redirectAttributes) {
        
        try {
            orderService.rateOrder(id, rating, null);
            redirectAttributes.addFlashAttribute("success", "Rating submitted successfully");
        } catch (IllegalStateException | IllegalArgumentException e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "An error occurred while submitting the rating");
        }
        
        return "redirect:/orders";
    }
}
