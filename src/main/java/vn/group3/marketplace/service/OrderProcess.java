package vn.group3.marketplace.service;

import vn.group3.marketplace.dto.OrderTask;
import vn.group3.marketplace.domain.entity.Order;
import vn.group3.marketplace.domain.entity.User;
import vn.group3.marketplace.domain.entity.WalletTransaction;
import vn.group3.marketplace.domain.entity.Product;
import vn.group3.marketplace.domain.entity.ProductStorage;
import vn.group3.marketplace.domain.entity.SellerStore;
import vn.group3.marketplace.domain.enums.OrderStatus;
import vn.group3.marketplace.domain.enums.ProductStorageStatus;
import vn.group3.marketplace.domain.enums.WalletTransactionType;
import vn.group3.marketplace.repository.*;
import vn.group3.marketplace.util.ValidationUtils;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import jakarta.annotation.PostConstruct;
import jakarta.annotation.PreDestroy;
import jakarta.mail.MessagingException;

import java.math.BigDecimal;
import java.util.List;
import java.util.concurrent.atomic.AtomicBoolean;

@Component
public class OrderProcess {

    private final WalletTransactionRepository walletTransactionRepository;

    @Autowired
    private OrderQueue orderQueue;

    @Autowired
    private OrderRepository orderRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private ProductRepository productRepository;

    @Autowired
    private SellerStoreRepository sellerStoreRepository;

    @Autowired
    private ProductStorageRepository productStorageRepository;

    @Autowired
    private EmailService emailService;

    private Thread orderProcessingThread;
    private final AtomicBoolean isRunning = new AtomicBoolean(true);

    OrderProcess(WalletTransactionRepository walletTransactionRepository) {
        this.walletTransactionRepository = walletTransactionRepository;
    }

    @PostConstruct
    public void startOrderProcessing() {
        orderProcessingThread = new Thread(() -> {
            System.out.println("Order processing thread started");

            while (isRunning.get()) {
                try {
                    // take order from queue (blocking)
                    OrderTask orderTask = orderQueue.takeOrder();

                    // process order
                    processOrder(orderTask);
                } catch (InterruptedException e) {
                    System.out.println("Order processing thread interrupted");
                    Thread.currentThread().interrupt();
                    break;
                } catch (Exception e) {
                    System.out.println("Error processing order: " + e.getMessage());
                }
            }
            System.out.println("Order processing thread stopped");
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
            System.out.println("Processing order: " + orderTask.getUserId());

            // 1. Validate data
            ValidationUtils.validateOrderData(orderTask);

            // 2. Create order entity
            Order order = createOrderEntity(orderTask);

            // 3. Process payment
            processPayment(order);

            // 4. Update product storage
            updateProductStorage(order);

            // 5. Send email
            sendOrderConfirmationEmail(order);

            System.out.println("Order processed successfully: " + order.getId());

        } catch (Exception e) {
            System.err.println("Failed to process order: " + e.getMessage());
        }
    }

    private Order createOrderEntity(OrderTask orderTask) {
        // Take data from database
        User buyer = userRepository.findById(orderTask.getUserId())
                .orElseThrow(() -> new RuntimeException("User not found"));

        Product product = productRepository.findById(orderTask.getProductId())
                .orElseThrow(() -> new RuntimeException("Product not found"));

        SellerStore sellerStore = sellerStoreRepository.findById(orderTask.getSellerStoreId())
                .orElseThrow(() -> new RuntimeException("Seller store not found"));

        // Create order entity
        Order order = Order.builder()
                .buyer(buyer)
                .sellerStore(sellerStore)
                .product(product)
                .productName(orderTask.getProductName())
                .productPrice(orderTask.getTotalAmount().divide(BigDecimal.valueOf(orderTask.getQuantity())))
                .quantity(orderTask.getQuantity())
                .productData(orderTask.getProductData())
                .totalAmount(orderTask.getTotalAmount())
                .status(OrderStatus.PENDING)
                .build();

        return orderRepository.save(order);
    }

    private void processPayment(Order order) {
        // Check balance
        User buyer = order.getBuyer();
        if (buyer.getBalance().compareTo(order.getTotalAmount()) < 0) {
            throw new RuntimeException("Insufficient balance");
        }

        // Subtract balance
        buyer.setBalance(buyer.getBalance().subtract(order.getTotalAmount()));
        userRepository.save(buyer);

        // Create wallet transaction
        WalletTransaction walletTransaction = WalletTransaction.builder()
                .user(buyer)
                .type(WalletTransactionType.PAYMENT)
                .amount(order.getTotalAmount())
                .refOrder(order)
                .build();
        walletTransactionRepository.save(walletTransaction);

        // Update order status
        order.setStatus(OrderStatus.PAID);
        orderRepository.save(order);
    }

    private void updateProductStorage(Order order) {
        // Find product storage available
        ProductStorageService productStorageService = new ProductStorageService();
        List<ProductStorage> productStorages = productStorageService.findByProductIdWithQuantityAvailable(
                order.getProduct().getId(), order.getQuantity(), ProductStorageStatus.AVAILABLE);
        order.setProductStorages(productStorages);
        productStorageRepository.saveAll(productStorages);
    }

    private void sendOrderConfirmationEmail(Order order) throws MessagingException {
        emailService.sendOrderConfirmationEmail(order);
    }
}
