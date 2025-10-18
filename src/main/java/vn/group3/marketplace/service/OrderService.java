package vn.group3.marketplace.service;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import vn.group3.marketplace.domain.entity.Order;
import vn.group3.marketplace.domain.entity.User;
import vn.group3.marketplace.domain.entity.SellerStore;
import vn.group3.marketplace.domain.enums.OrderStatus;
import vn.group3.marketplace.repository.OrderRepository;
import vn.group3.marketplace.security.CustomUserDetails;

import java.util.List;
import java.util.Optional;

@Service
public class OrderService {
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

    /**
     * Lấy đơn hàng kèm productStorages (fetch join)
     */
    public Optional<Order> findByIdWithProductStorages(Long id) {
        return orderRepository.findByIdWithProductStorages(id);
    }

    private final OrderRepository orderRepository;

    public OrderService(OrderRepository orderRepository) {
        this.orderRepository = orderRepository;
    }

    /**
     * Helper method để lấy thông tin user hiện tại từ SecurityContext
     */
    private User getCurrentUser() {
        CustomUserDetails userDetails = (CustomUserDetails) SecurityContextHolder.getContext()
                .getAuthentication().getPrincipal();
        return userDetails.getUser();
    }

    /**
     * Tìm đơn hàng theo ID
     */
    public Optional<Order> findById(Long id) {
        return orderRepository.findById(id);
    }

    /**
     * Tìm tất cả đơn hàng có phân trang
     */
    public Page<Order> findAll(Pageable pageable) {
        return orderRepository.findAll(pageable);
    }

    /**
     * Tìm đơn hàng theo người mua hiện tại (đã đăng nhập)
     */
    public Page<Order> findByCurrentBuyer(Pageable pageable) {
        return orderRepository.findByBuyer(getCurrentUser(), pageable);
    }

    public List<Order> findByCurrentBuyer() {
        return orderRepository.findByBuyer(getCurrentUser());
    }

    /**
     * Tìm đơn hàng theo người bán hiện tại (đã đăng nhập)
     */
    public Page<Order> findByCurrentSeller(Pageable pageable) {
        SellerStore store = getCurrentUser().getSellerStore();
        if (store == null) {
            throw new IllegalStateException("Current user is not a seller");
        }
        return orderRepository.findBySellerStore(store, pageable);
    }

    public List<Order> findByCurrentSeller() {
        SellerStore store = getCurrentUser().getSellerStore();
        if (store == null) {
            throw new IllegalStateException("Current user is not a seller");
        }
        return orderRepository.findBySellerStore(store);
    }

    /**
     * Tìm đơn hàng theo trạng thái
     */
    public Page<Order> findByStatus(OrderStatus status, Pageable pageable) {
        return orderRepository.findByStatus(status, pageable);
    }

    public List<Order> findByStatus(OrderStatus status) {
        return orderRepository.findByStatus(status);
    }

    /**
     * Tìm đơn hàng theo người mua và trạng thái
     */
    public Page<Order> findByCurrentBuyerAndStatus(OrderStatus status, Pageable pageable) {
        return orderRepository.findByBuyerAndStatus(getCurrentUser(), status, pageable);
    }

    public List<Order> findByCurrentBuyerAndStatus(OrderStatus status) {
        return orderRepository.findByBuyerAndStatus(getCurrentUser(), status);
    }

    /**
     * Tìm đơn hàng theo người bán và trạng thái
     */
    public Page<Order> findByCurrentSellerAndStatus(OrderStatus status, Pageable pageable) {
        SellerStore store = getCurrentUser().getSellerStore();
        if (store == null) {
            throw new IllegalStateException("Current user is not a seller");
        }
        return orderRepository.findBySellerStoreAndStatus(store, status, pageable);
    }

    public List<Order> findByCurrentSellerAndStatus(OrderStatus status) {
        SellerStore store = getCurrentUser().getSellerStore();
        if (store == null) {
            throw new IllegalStateException("Current user is not a seller");
        }
        return orderRepository.findBySellerStoreAndStatus(store, status);
    }

    /**
     * Đếm số đơn hàng theo người bán hiện tại
     */
    public Long countByCurrentSeller() {
        SellerStore store = getCurrentUser().getSellerStore();
        if (store == null) {
            throw new IllegalStateException("Current user is not a seller");
        }
        return orderRepository.countBySellerStore(store);
    }

    /**
     * Đếm số đơn hàng theo người mua hiện tại
     */
    public Long countByCurrentBuyer() {
        return orderRepository.countByBuyer(getCurrentUser());
    }
}