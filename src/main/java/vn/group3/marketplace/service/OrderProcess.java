package vn.group3.marketplace.service;

import vn.group3.marketplace.dto.OrderTask;
import vn.group3.marketplace.domain.entity.*;
import vn.group3.marketplace.domain.enums.*;
import vn.group3.marketplace.repository.*;

import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import jakarta.annotation.PostConstruct;
import jakarta.annotation.PreDestroy;

import java.util.concurrent.atomic.AtomicBoolean;

@Component
public class OrderProcess {

    private static final Logger logger = LoggerFactory.getLogger(OrderProcess.class);

    // Dependencies
    private final OrderQueue orderQueue;
    private final OrderService orderService;
    private final WalletTransactionQueueService walletTransactionQueueService;
    private final UserRepository userRepository;
    private final EmailService emailService;
    private final AuthenticationRefreshService authenticationRefreshService;
    private final NotificationService notificationService;

    // Thread management
    private Thread orderProcessingThread;
    private final AtomicBoolean isRunning = new AtomicBoolean(true);

    // Constructor injection
    public OrderProcess(OrderQueue orderQueue, OrderService orderService,
            WalletTransactionQueueService walletTransactionQueueService, UserRepository userRepository,
            EmailService emailService, AuthenticationRefreshService authenticationRefreshService,
            NotificationService notificationService) {
        this.orderQueue = orderQueue;
        this.orderService = orderService;
        this.walletTransactionQueueService = walletTransactionQueueService;
        this.userRepository = userRepository;
        this.emailService = emailService;
        this.authenticationRefreshService = authenticationRefreshService;
        this.notificationService = notificationService;
    }

    @PostConstruct
    public void startOrderProcessing() {
        orderProcessingThread = new Thread(() -> {
            logger.info("Order processing thread started");

            while (isRunning.get()) {
                try {
                    // Take order from queue (blocking)
                    OrderTask orderTask = orderQueue.takeOrder();

                    // Process order
                    processOrder(orderTask);

                } catch (InterruptedException e) {
                    logger.info("Order processing thread interrupted");
                    Thread.currentThread().interrupt();
                    break;
                } catch (Exception e) {
                    logger.error("Error processing order: {}", e.getMessage(), e);
                }
            }
            logger.info("Order processing thread stopped");
        });

        orderProcessingThread.setName("OrderProcessingThread");
        orderProcessingThread.setDaemon(false);
        orderProcessingThread.start();
    }

    @PreDestroy
    public void stopOrderProcessing() {
        isRunning.set(false);
        if (orderProcessingThread != null) {
            orderProcessingThread.interrupt();
        }
    }

    @Transactional
    public void processOrder(OrderTask orderTask) {
        try {
            // 1. Create order from order task
            Order order = orderService.createOrderFromTask(orderTask);
            // 2. Check stock availability
            boolean isStockAvailable = orderService.checkStockAvailability(order);
            switch (isStockAvailable ? 1 : 0) {
                // 2.2. Case stock is available, continue processing
                case 1:
                    // 3. Process payment
                    var future = walletTransactionQueueService.enqueuePurchasePayment(orderTask.getUserId(),
                            order.getTotalAmount(), order.getId().toString());

                    try {
                        // Wait for payment completion (blocking call) - Tăng timeout lên 30 giây
                        logger.info("Waiting for payment completion for order {}...", order.getId());
                        Boolean paymentResult = future.get(30, java.util.concurrent.TimeUnit.SECONDS);

                        // Immediately refresh authentication context to update user balance in session
                        authenticationRefreshService.refreshAuthenticationContextForUser(orderTask.getUserId());

                        logger.info("Payment result for order {}: {}", order.getId(), paymentResult);

                        if (paymentResult != null && paymentResult) {
                            // 5.1. Case payment successful:
                            logger.info("Updating order {} status to PAID", order.getId());
                            orderService.updateOrderBasedOnPaymentStatus(order, WalletTransactionStatus.PAID);

                            // Create notifications for successful process (all 3 stages)
                            User buyer = userRepository.findById(orderTask.getUserId()).orElse(null);
                            if (buyer != null) {
                                // 1. Payment success notification
                                notificationService.createNotification(
                                        buyer,
                                        NotificationType.PAYMENT_SUCCESS,
                                        "Thanh toán thành công",
                                        "Đơn hàng #" + order.getId() + " đã thanh toán thành công!");

                                // 2. Purchase success notification
                                notificationService.createNotification(
                                        buyer,
                                        NotificationType.PURCHASE_SUCCESS,
                                        "Mua hàng thành công",
                                        "Đơn hàng #" + order.getId() + " đã được xử lý hoàn tất!");
                            }

                            // 6. Send confirmation email
                            try {
                                emailService.sendOrderConfirmationEmail(order);
                            } catch (Exception e) {
                                logger.error("Failed to send confirmation email for order: {}, error: {}",
                                        order.getId(), e.getMessage(), e);
                            }

                            logger.info("Order processed successfully: {}", order.getId());
                        } else {
                            // 5.2. Case payment failed:
                            orderService.updateOrderBasedOnPaymentStatus(order, WalletTransactionStatus.FAILED);
                            logger.warn("Order payment failed: {}", order.getId());

                            // Create notification for failed payment
                            User buyer = userRepository.findById(orderTask.getUserId()).orElse(null);
                            if (buyer != null) {
                                notificationService.createNotification(
                                        buyer,
                                        NotificationType.PAYMENT_FAILED,
                                        "Thanh toán thất bại",
                                        "Đơn hàng #" + order.getId() + " thanh toán thất bại. Vui lòng thử lại!");

                                // Create notification for failed purchase
                                notificationService.createNotification(
                                        buyer,
                                        NotificationType.PURCHASE_FAILED,
                                        "Mua hàng thất bại",
                                        "Đơn hàng #" + order.getId() + " không thể hoàn tất do thanh toán thất bại!");
                            }
                        }

                    } catch (java.util.concurrent.TimeoutException e) {
                        // Payment timeout - Log chi tiết
                        logger.error("Order payment timeout after 30 seconds for order: {}", order.getId());
                        logger.error("Timeout details: {}", e.getMessage());
                        orderService.updateOrderBasedOnPaymentStatus(order, WalletTransactionStatus.FAILED);
                        logger.warn("Order payment timeout: {}", order.getId());

                        // Create notification for timeout
                        User buyer = userRepository.findById(orderTask.getUserId()).orElse(null);
                        if (buyer != null) {
                            notificationService.createNotification(
                                    buyer,
                                    NotificationType.PAYMENT_FAILED,
                                    "Thanh toán timeout",
                                    "Đơn hàng #" + order.getId() + " thanh toán bị timeout. Vui lòng thử lại!");

                            notificationService.createNotification(
                                    buyer,
                                    NotificationType.PURCHASE_FAILED,
                                    "Mua hàng thất bại",
                                    "Đơn hàng #" + order.getId() + " không thể hoàn tất do thanh toán timeout!");
                        }
                    } catch (Exception e) {
                        // Payment error
                        orderService.updateOrderBasedOnPaymentStatus(order, WalletTransactionStatus.FAILED);
                        logger.error("Order payment error: {}, error: {}", order.getId(), e.getMessage(), e);

                        // Create notification for error
                        User buyer = userRepository.findById(orderTask.getUserId()).orElse(null);
                        if (buyer != null) {
                            notificationService.createNotification(
                                    buyer,
                                    NotificationType.PAYMENT_FAILED,
                                    "Lỗi thanh toán",
                                    "Đơn hàng #" + order.getId() + " gặp lỗi trong quá trình thanh toán!");

                            notificationService.createNotification(
                                    buyer,
                                    NotificationType.PURCHASE_FAILED,
                                    "Mua hàng thất bại",
                                    "Đơn hàng #" + order.getId() + " không thể hoàn tất do lỗi thanh toán!");
                        }
                    }

                    break;
                // 2.1. Case stock is not available, update order status to OUT_OF_STOCK, end
                // processing
                case 0:
                    // 2.1. Case stock is not available, update order status to OUT_OF_STOCK, end
                    orderService.updateOrderStatus(order, OrderStatus.OUT_OF_STOCK);

                    // Create notification for out of stock
                    User buyer = userRepository.findById(orderTask.getUserId()).orElse(null);
                    if (buyer != null) {
                        notificationService.createNotification(
                                buyer,
                                NotificationType.ORDER_FAILED,
                                "Đặt hàng thất bại",
                                "Sản phẩm trong đơn hàng #" + order.getId() + " đã hết hàng!");

                        notificationService.createNotification(
                                buyer,
                                NotificationType.PURCHASE_FAILED,
                                "Mua hàng thất bại",
                                "Đơn hàng #" + order.getId() + " không thể hoàn tất do hết hàng!");
                    }
                    break;
            }
        } catch (Exception e) {
            // 6. end processing
            throw new RuntimeException("Failed to process order", e);
        }
    }

}
