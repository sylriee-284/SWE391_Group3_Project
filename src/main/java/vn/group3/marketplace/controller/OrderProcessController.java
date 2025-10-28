package vn.group3.marketplace.controller;

import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import vn.group3.marketplace.dto.OrderTask;
import vn.group3.marketplace.security.CustomUserDetails;
import vn.group3.marketplace.service.OrderService;
import vn.group3.marketplace.service.OrderQueue;

@Controller
@RequestMapping("/order-process")
public class OrderProcessController {

    private final OrderService orderService;
    private final OrderQueue orderQueue;

    public OrderProcessController(OrderService orderService, OrderQueue orderQueue) {
        this.orderService = orderService;
        this.orderQueue = orderQueue;
    }

    @PostMapping("/buy-now")
    public String processBuyNow(
            @AuthenticationPrincipal CustomUserDetails currentUser,
            @RequestParam Long productId,
            @RequestParam Integer quantity,
            RedirectAttributes redirectAttributes) {

        try {
            // Create order task (validation sẽ được thực hiện trong service)
            OrderTask orderTask = orderService.createOrderTask(currentUser.getId(), productId, quantity);

            // Thêm order task vào queue để xử lý ngầm
            boolean addedToQueue = orderQueue.addOrder(orderTask);

            if (addedToQueue) {
                redirectAttributes.addFlashAttribute("successMessage",
                        "Đơn hàng đã được tạo thành công! Đang xử lý thanh toán...");
                return "redirect:/homepage?showOrderModal=true";
            } else {
                redirectAttributes.addFlashAttribute("errorMessage",
                        "Không thể thêm đơn hàng vào hàng đợi. Vui lòng thử lại.");
                return "redirect:/homepage";
            }

        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("errorMessage",
                    "Có lỗi xảy ra khi tạo đơn hàng: " + e.getMessage());
            return "redirect:/homepage";
        }
    }
}
