package vn.group3.marketplace.service;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import jakarta.persistence.EntityNotFoundException;
import vn.group3.marketplace.domain.entity.*;

import vn.group3.marketplace.domain.enums.*;
import vn.group3.marketplace.dto.OrderTask;
import vn.group3.marketplace.repository.*;
import vn.group3.marketplace.util.ValidationUtils;
import vn.group3.marketplace.util.SecurityContextUtils;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.core.JsonProcessingException;

@Service
public class OrderService {

    private static final String ORDER_NOT_FOUND_MESSAGE = "Order not found";

    @PreAuthorize("isAuthenticated()")
    public Page<Order> searchByCurrentBuyerAndProductName(OrderStatus status, String key, Pageable pageable) {
        return orderRepository.searchByBuyerAndProductName(getCurrentUser(), status, key, pageable);
    }

    @PreAuthorize("isAuthenticated() and hasRole('SELLER')")
    public Page<Order> searchByCurrentSellerAndProductName(OrderStatus status, String key, Pageable pageable) {
        SellerStore store = getCurrentUser().getSellerStore();
        if (store == null) {
            throw new IllegalStateException("Current user is not a seller");
        }
        return orderRepository.searchBySellerAndProductName(store, status, key, pageable);
    }

    @PreAuthorize("hasRole('ADMIN')")
    public Page<Order> searchByProductName(OrderStatus status, String key, Pageable pageable) {
        return orderRepository.searchByProductName(status, key, pageable);
    }

    // Lấy đơn hàng kèm productStorages (fetch join)
    @PreAuthorize("isAuthenticated()")
    public Optional<Order> findByIdWithProductStorages(Long id) {
        return orderRepository.findByIdWithProductStorages(id);
    }

    private final OrderRepository orderRepository;
    private final ProductRepository productRepository;
    private final ProductStorageRepository productStorageRepository;
    private final EscrowTransactionRepository escrowTransactionRepository;
    private final WalletTransactionRepository walletTransactionRepository;
    private final UserRepository userRepository;
    private final SellerStoreRepository sellerStoreRepository;
    private final ProductStorageService productStorageService;
    private final ObjectMapper objectMapper;
    private final WebSocketService webSocketService;
    private final EscrowTransactionService escrowTransactionService;

    public OrderService(OrderRepository orderRepository,
            ProductRepository productRepository,
            ProductStorageRepository productStorageRepository,
            EscrowTransactionRepository escrowTransactionRepository,
            WalletTransactionRepository walletTransactionRepository,
            UserRepository userRepository,
            SellerStoreRepository sellerStoreRepository,
            ProductStorageService productStorageService,
            ObjectMapper objectMapper,
            WebSocketService webSocketService,
            EscrowTransactionService escrowTransactionService) {
        this.orderRepository = orderRepository;
        this.productRepository = productRepository;
        this.productStorageRepository = productStorageRepository;
        this.escrowTransactionRepository = escrowTransactionRepository;
        this.walletTransactionRepository = walletTransactionRepository;
        this.userRepository = userRepository;
        this.sellerStoreRepository = sellerStoreRepository;
        this.productStorageService = productStorageService;
        this.objectMapper = objectMapper;
        this.webSocketService = webSocketService;
        this.escrowTransactionService = escrowTransactionService;
    }

    // Helper method để lấy thông tin user hiện tại từ SecurityContext
    private User getCurrentUser() {
        return SecurityContextUtils.getCurrentUserDetails().getUser();
    }

    // Tìm đơn hàng theo ID
    @PreAuthorize("isAuthenticated()")
    public Optional<Order> findById(Long id) {
        return orderRepository.findById(id);
    }

    // Tìm tất cả đơn hàng có phân trang
    @PreAuthorize("hasRole('ADMIN')")
    public Page<Order> findAll(Pageable pageable) {
        return orderRepository.findAll(pageable);
    }

    // Tìm đơn hàng theo người mua hiện tại (đã đăng nhập)
    @PreAuthorize("isAuthenticated()")
    public Page<Order> findByCurrentBuyer(Pageable pageable) {
        return orderRepository.findByBuyer(getCurrentUser(), pageable);
    }

    // Tìm đơn hàng theo người mua hiện tại (đã đăng nhập)
    @PreAuthorize("isAuthenticated()")
    public List<Order> findByCurrentBuyer() {
        return orderRepository.findByBuyer(getCurrentUser());
    }

    // Tìm đơn hàng theo người bán hiện tại (đã đăng nhập)
    @PreAuthorize("isAuthenticated() and hasRole('SELLER')")
    public Page<Order> findByCurrentSeller(Pageable pageable) {
        SellerStore store = getCurrentUser().getSellerStore();
        if (store == null) {
            throw new IllegalStateException("Current user is not a seller");
        }
        return orderRepository.findBySellerStore(store, pageable);
    }

    // Tìm đơn hàng theo người bán hiện tại (đã đăng nhập)
    @PreAuthorize("isAuthenticated() and hasRole('SELLER')")
    public List<Order> findByCurrentSeller() {
        SellerStore store = getCurrentUser().getSellerStore();
        if (store == null) {
            throw new IllegalStateException("Current user is not a seller");
        }
        return orderRepository.findBySellerStore(store);
    }

    // Tìm đơn hàng theo trạng thái
    @PreAuthorize("hasRole('ADMIN')")
    public Page<Order> findByStatus(OrderStatus status, Pageable pageable) {
        return orderRepository.findByStatus(status, pageable);
    }

    // Tìm đơn hàng theo trạng thái
    @PreAuthorize("hasRole('ADMIN')")
    public List<Order> findByStatus(OrderStatus status) {
        return orderRepository.findByStatus(status);
    }

    // Tìm đơn hàng theo người mua hiện tại và trạng thái
    @PreAuthorize("isAuthenticated()")
    public Page<Order> findByCurrentBuyerAndStatus(OrderStatus status, Pageable pageable) {
        return orderRepository.findByBuyerAndStatus(getCurrentUser(), status, pageable);
    }

    // Tìm đơn hàng theo người mua hiện tại và trạng thái
    @PreAuthorize("isAuthenticated()")
    public List<Order> findByCurrentBuyerAndStatus(OrderStatus status) {
        return orderRepository.findByBuyerAndStatus(getCurrentUser(), status);
    }

    // Tìm đơn hàng theo người bán hiện tại và trạng thái
    @PreAuthorize("isAuthenticated() and hasRole('SELLER')")
    public Page<Order> findByCurrentSellerAndStatus(OrderStatus status, Pageable pageable) {
        SellerStore store = getCurrentUser().getSellerStore();
        if (store == null) {
            throw new IllegalStateException("Current user is not a seller");
        }
        return orderRepository.findBySellerStoreAndStatus(store, status, pageable);
    }

    // Tìm đơn hàng theo người bán hiện tại và trạng thái
    @PreAuthorize("isAuthenticated() and hasRole('SELLER')")
    public List<Order> findByCurrentSellerAndStatus(OrderStatus status) {
        SellerStore store = getCurrentUser().getSellerStore();
        if (store == null) {
            throw new IllegalStateException("Current user is not a seller");
        }
        return orderRepository.findBySellerStoreAndStatus(store, status);
    }

    // Đếm số đơn hàng theo người bán hiện tại
    @PreAuthorize("isAuthenticated() and hasRole('SELLER')")
    public Long countByCurrentSeller() {
        SellerStore store = getCurrentUser().getSellerStore();
        if (store == null) {
            throw new IllegalStateException("Current user is not a seller");
        }
        return orderRepository.countBySellerStore(store);
    }

    // Đếm số đơn hàng theo người mua hiện tại
    @PreAuthorize("isAuthenticated()")
    public Long countByCurrentBuyer() {
        return orderRepository.countByBuyer(getCurrentUser());
    }

    // Create order
    @PreAuthorize("isAuthenticated() and #userId == authentication.principal.id")
    public OrderTask createOrderTask(Long userId, Long productId, Integer quantity) {
        // 1. Validate authentication
        if (userId == null) {
            throw new IllegalArgumentException("User must be authenticated");
        }

        // 2. Get product information
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new EntityNotFoundException("Product not found: " + productId));
        if (product == null) {
            throw new IllegalArgumentException("Product not found: " + productId);
        }

        // 3. Validate quantity
        if (quantity == null || quantity <= 0) {
            throw new IllegalArgumentException("Invalid quantity: " + quantity);
        }

        // 4. Validate product status
        if (!product.getStatus().name().equals("ACTIVE")) {
            throw new IllegalArgumentException("Product is not available");
        }

        // 5. Calculate total amount
        BigDecimal totalAmount = product.getPrice().multiply(BigDecimal.valueOf(quantity));

        // 2. Validate user balance
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new EntityNotFoundException("User not found"));
        if (user.getBalance().compareTo(totalAmount) < 0) {
            throw new IllegalArgumentException("User balance is not enough");
        }

        // 6. Create OrderTask
        OrderTask orderTask = new OrderTask(
                userId,
                product.getId(),
                product.getSellerStore().getId(),
                quantity,
                totalAmount,
                product.getName());

        return orderTask;
    }

    // Create order from order task
    // No RBAC - Called by background OrderProcess thread
    @Transactional
    public Order createOrderFromTask(OrderTask orderTask) {
        // Validate order task data
        if (!ValidationUtils.validateOrderTaskData(orderTask)) {
            throw new IllegalArgumentException(ValidationUtils.getOrderValidationErrorMessage());
        }

        // Get entities from database
        User buyer = userRepository.findById(orderTask.getUserId())
                .orElseThrow(() -> new EntityNotFoundException("User not found"));

        Product product = productRepository.findById(orderTask.getProductId())
                .orElseThrow(() -> new EntityNotFoundException("Product not found"));

        SellerStore sellerStore = sellerStoreRepository.findById(orderTask.getSellerStoreId())
                .orElseThrow(
                        () -> new EntityNotFoundException("Seller store not found: " + orderTask.getSellerStoreId()));

        // Create Order entity
        Order order = Order.builder()
                .buyer(buyer)
                .sellerStore(sellerStore)
                .product(product)
                .productName(orderTask.getProductName())
                .productPrice(product.getPrice())
                .quantity(orderTask.getQuantity())
                .productData(orderTask.getProductData())
                .totalAmount(orderTask.getTotalAmount())
                .status(OrderStatus.PENDING_PAYMENT)
                .build();

        // Set createdBy as buyer ID for orders
        order.setCreatedBy(buyer.getId());

        return orderRepository.save(order);
    }

    // check stock availability
    // No RBAC - Internal method called by OrderProcess
    public boolean checkStockAvailability(Order order) {
        Product product = order.getProduct();
        if (product == null || product.getStock() == null) {
            return false;
        }

        long availableStock = productStorageService.getAvailableStock(product.getId());
        if (availableStock < order.getQuantity()) {
            return false;
        }

        return true;
    }

    // Update order status
    // No RBAC - Internal method called by OrderProcess
    @Transactional
    public void updateOrderStatus(Order order, OrderStatus status) {
        if (order == null) {
            throw new IllegalArgumentException("Order cannot be null");
        }
        if (status == null) {
            throw new IllegalArgumentException("Status cannot be null");
        }
        order.setStatus(status);
        orderRepository.save(order);
    }

    // decrement stock
    // No RBAC - Internal method called by OrderProcess
    @Transactional
    public void decrementStock(Order order) {
        if (order == null) {
            throw new IllegalArgumentException("Order cannot be null");
        }
        Product product = order.getProduct();
        if (product == null) {
            throw new IllegalArgumentException("Product cannot be null");
        }
        product.setStock(product.getStock() - order.getQuantity());
        productRepository.save(product);
    }

    // Update order based on payment status
    // No RBAC - Internal method called by OrderProcess
    @Transactional
    public void updateOrderBasedOnPaymentStatus(Order order, WalletTransactionStatus paymentStatus) {
        switch (paymentStatus) {
            case PAID:
                // 1. Update order status to PAID
                order.setStatus(OrderStatus.PAID);

                // 3. Get product storages with quantity (đã valid từ trước)n
                List<ProductStorage> productStoragesToDeliver = productStorageService
                        .findByProductIdWithQuantityAvailable(
                                order.getProduct().getId(),
                                order.getQuantity(),
                                ProductStorageStatus.AVAILABLE);

                // 4. Convert productStoragesToDeliver to JSON string
                try {
                    // Tạo DTO đơn giản để tránh circular reference và lazy loading issues
                    List<java.util.Map<String, Object>> productStorageData = productStoragesToDeliver.stream()
                            .map(ps -> {
                                java.util.Map<String, Object> data = new java.util.HashMap<>();
                                data.put("id", ps.getId());
                                data.put("payloadJson", ps.getPayloadJson());
                                data.put("payloadMask", ps.getPayloadMask());
                                data.put("status", ps.getStatus().toString());
                                data.put("note", ps.getNote());
                                return data;
                            })
                            .collect(java.util.stream.Collectors.toList());

                    String productDataJson = objectMapper.writeValueAsString(productStorageData);
                    order.setProductData(productDataJson);
                } catch (JsonProcessingException e) {
                    throw new RuntimeException("Failed to convert product storages to JSON", e);
                }

                // 5. Update product storages status to DELIVERED
                for (ProductStorage productStorage : productStoragesToDeliver) {
                    productStorage.setStatus(ProductStorageStatus.DELIVERED);
                    productStorage.setDeliveredAt(java.time.LocalDateTime.now());
                    productStorage.setOrder(order);
                }

                // 6. Save updated product storages
                productStorageService.saveAll(productStoragesToDeliver);

                // 7. Process escrow transaction asynchronously
                escrowTransactionService.processEscrowTransactionAsync(order);

                // 8. Update order status to COMPLETED
                order.setStatus(OrderStatus.COMPLETED);

                // 9. Save order
                orderRepository.save(order);

                break;
            case FAILED:
                // 1. Update order status to PAYMENT_FAILED
                order.setStatus(OrderStatus.PAYMENT_FAILED);
                orderRepository.save(order);

                break;
        }
    }

    // Create order notification and send via WebSocket
    // No RBAC - Internal method called by OrderProcess
    public void createOrderNotification(User user, NotificationType type, String title, String content) {
        webSocketService.createAndSendNotification(user, type, title, content);
    }
}