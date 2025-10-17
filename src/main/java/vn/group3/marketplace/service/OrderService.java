package vn.group3.marketplace.service;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import jakarta.persistence.EntityNotFoundException;
import vn.group3.marketplace.domain.entity.*;

import vn.group3.marketplace.domain.enums.*;
import vn.group3.marketplace.repository.*;
import vn.group3.marketplace.security.CustomUserDetails;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class OrderService {

    private static final String ORDER_NOT_FOUND_MESSAGE = "Order not found";

    public Page<Order> searchByCurrentBuyerAndProductName(OrderStatus status, String key, Pageable pageable) {
        return orderRepository.searchByBuyerAndProductName(getCurrentUser(), status, key, pageable);
    }

    public Page<Order> searchByCurrentSellerAndProductName(OrderStatus status, String key, Pageable pageable) {
        SellerStore store = getCurrentUser().getSellerStore();
        if (store == null) {
            throw new IllegalStateException("Current user is not a seller");
        }
        return orderRepository.searchBySellerAndProductName(store, status, key, pageable);
    }

    public Page<Order> searchByProductName(OrderStatus status, String key, Pageable pageable) {
        return orderRepository.searchByProductName(status, key, pageable);
    }

    // Lấy đơn hàng kèm productStorages (fetch join)
    public Optional<Order> findByIdWithProductStorages(Long id) {
        return orderRepository.findByIdWithProductStorages(id);
    }

    private final OrderRepository orderRepository;
    private final ProductRepository productRepository;
    private final ProductStorageRepository productStorageRepository;
    private final EscrowTransactionRepository escrowTransactionRepository;
    private final WalletTransactionRepository walletTransactionRepository;
    private final UserRepository userRepository;

    public OrderService(OrderRepository orderRepository,
            ProductRepository productRepository,
            ProductStorageRepository productStorageRepository,
            EscrowTransactionRepository escrowTransactionRepository,
            WalletTransactionRepository walletTransactionRepository,
            UserRepository userRepository) {
        this.orderRepository = orderRepository;
        this.productRepository = productRepository;
        this.productStorageRepository = productStorageRepository;
        this.escrowTransactionRepository = escrowTransactionRepository;
        this.walletTransactionRepository = walletTransactionRepository;
        this.userRepository = userRepository;
    }

    // Helper method để lấy thông tin user hiện tại từ SecurityContext
    private User getCurrentUser() {
        CustomUserDetails userDetails = (CustomUserDetails) SecurityContextHolder.getContext()
                .getAuthentication().getPrincipal();
        return userDetails.getUser();
    }

    // Tìm đơn hàng theo ID
    public Optional<Order> findById(Long id) {
        return orderRepository.findById(id);
    }

    // Tìm tất cả đơn hàng có phân trang
    public Page<Order> findAll(Pageable pageable) {
        return orderRepository.findAll(pageable);
    }

    // Tìm đơn hàng theo người mua hiện tại (đã đăng nhập)
    public Page<Order> findByCurrentBuyer(Pageable pageable) {
        return orderRepository.findByBuyer(getCurrentUser(), pageable);
    }

    // Tìm đơn hàng theo người mua hiện tại (đã đăng nhập)
    public List<Order> findByCurrentBuyer() {
        return orderRepository.findByBuyer(getCurrentUser());
    }

    // Tìm đơn hàng theo người bán hiện tại (đã đăng nhập)
    public Page<Order> findByCurrentSeller(Pageable pageable) {
        SellerStore store = getCurrentUser().getSellerStore();
        if (store == null) {
            throw new IllegalStateException("Current user is not a seller");
        }
        return orderRepository.findBySellerStore(store, pageable);
    }

    // Tìm đơn hàng theo người bán hiện tại (đã đăng nhập)
    public List<Order> findByCurrentSeller() {
        SellerStore store = getCurrentUser().getSellerStore();
        if (store == null) {
            throw new IllegalStateException("Current user is not a seller");
        }
        return orderRepository.findBySellerStore(store);
    }

    // Tìm đơn hàng theo trạng thái
    public Page<Order> findByStatus(OrderStatus status, Pageable pageable) {
        return orderRepository.findByStatus(status, pageable);
    }

    // Tìm đơn hàng theo trạng thái
    public List<Order> findByStatus(OrderStatus status) {
        return orderRepository.findByStatus(status);
    }

    // Tìm đơn hàng theo người mua hiện tại và trạng thái
    public Page<Order> findByCurrentBuyerAndStatus(OrderStatus status, Pageable pageable) {
        return orderRepository.findByBuyerAndStatus(getCurrentUser(), status, pageable);
    }

    // Tìm đơn hàng theo người mua hiện tại và trạng thái
    public List<Order> findByCurrentBuyerAndStatus(OrderStatus status) {
        return orderRepository.findByBuyerAndStatus(getCurrentUser(), status);
    }

    // Tìm đơn hàng theo người bán hiện tại và trạng thái
    public Page<Order> findByCurrentSellerAndStatus(OrderStatus status, Pageable pageable) {
        SellerStore store = getCurrentUser().getSellerStore();
        if (store == null) {
            throw new IllegalStateException("Current user is not a seller");
        }
        return orderRepository.findBySellerStoreAndStatus(store, status, pageable);
    }

    // Tìm đơn hàng theo người bán hiện tại và trạng thái
    public List<Order> findByCurrentSellerAndStatus(OrderStatus status) {
        SellerStore store = getCurrentUser().getSellerStore();
        if (store == null) {
            throw new IllegalStateException("Current user is not a seller");
        }
        return orderRepository.findBySellerStoreAndStatus(store, status);
    }

    // Đếm số đơn hàng theo người bán hiện tại
    public Long countByCurrentSeller() {
        SellerStore store = getCurrentUser().getSellerStore();
        if (store == null) {
            throw new IllegalStateException("Current user is not a seller");
        }
        return orderRepository.countBySellerStore(store);
    }

    // Đếm số đơn hàng theo người mua hiện tại
    public Long countByCurrentBuyer() {
        return orderRepository.countByBuyer(getCurrentUser());
    }

    // Create order
    public Order createOrder(Order order) {
        return orderRepository.save(order);
    }

    // Update order status
    public Order updateOrderStatus(Long id, OrderStatus status) {
        Order order = orderRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException(ORDER_NOT_FOUND_MESSAGE));
        order.setStatus(status);
        return orderRepository.save(order);
    }

    // Check stock availability

    // decrement stock
}