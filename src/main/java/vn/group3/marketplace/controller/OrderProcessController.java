package vn.group3.marketplace.controller;

import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import vn.group3.marketplace.dto.OrderTask;
import vn.group3.marketplace.security.CustomUserDetails;
import vn.group3.marketplace.service.OrderService;
import vn.group3.marketplace.service.OrderQueue;
import vn.group3.marketplace.service.NotificationService;
import vn.group3.marketplace.domain.enums.NotificationType;

@Controller
@RequestMapping("/order-process")
public class OrderProcessController {

    private final OrderService orderService;
    private final OrderQueue orderQueue;
    private final NotificationService notificationService;

    public OrderProcessController(OrderService orderService, OrderQueue orderQueue,
            NotificationService notificationService) {
        this.orderService = orderService;
        this.orderQueue = orderQueue;
        this.notificationService = notificationService;
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
                // Create notification for successful order creation
                notificationService.createNotification(
                        currentUser.getUser(),
                        NotificationType.ORDER_SUCCESS,
                        "Đặt hàng thành công",
                        "Đơn hàng đã được tạo thành công! Đang xử lý thanh toán...");
            } else {
                // Create error notification
                notificationService.createNotification(
                        currentUser.getUser(),
                        NotificationType.ORDER_FAILED,
                        "Đặt hàng thất bại",
                        "Không thể thêm đơn hàng vào hàng đợi. Vui lòng thử lại.");
            }

            return "redirect:/homepage?showOrderModal=true";

        } catch (Exception e) {
            // Create error notification
            notificationService.createNotification(
                    currentUser.getUser(),
                    NotificationType.ORDER_FAILED,
                    "Đặt hàng thất bại",
                    "Có lỗi xảy ra khi tạo đơn hàng: " + e.getMessage());

            return "redirect:/product/" + productId;
        }
    }
}
