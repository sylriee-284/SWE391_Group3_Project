package vn.group3.marketplace.repository;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import vn.group3.marketplace.domain.entity.Order;
import vn.group3.marketplace.domain.entity.User;
import vn.group3.marketplace.domain.entity.SellerStore;
import vn.group3.marketplace.domain.enums.OrderStatus;

import java.util.List;

@Repository
public interface OrderRepository extends JpaRepository<Order, Long> {
    // Tìm đơn hàng theo người mua
    Page<Order> findByBuyer(User buyer, Pageable pageable);

    List<Order> findByBuyer(User buyer);

    // Tìm đơn hàng theo cửa hàng bán
    Page<Order> findBySellerStore(SellerStore sellerStore, Pageable pageable);

    List<Order> findBySellerStore(SellerStore sellerStore);

    // Tìm đơn hàng theo trạng thái
    Page<Order> findByStatus(OrderStatus status, Pageable pageable);

    List<Order> findByStatus(OrderStatus status);

    // Tìm đơn hàng theo người mua và trạng thái
    Page<Order> findByBuyerAndStatus(User buyer, OrderStatus status, Pageable pageable);

    List<Order> findByBuyerAndStatus(User buyer, OrderStatus status);

    // Tìm đơn hàng theo cửa hàng và trạng thái
    Page<Order> findBySellerStoreAndStatus(SellerStore sellerStore, OrderStatus status, Pageable pageable);

    List<Order> findBySellerStoreAndStatus(SellerStore sellerStore, OrderStatus status);

    // Đếm số đơn hàng theo cửa hàng
    Long countBySellerStore(SellerStore sellerStore);

    // Đếm số đơn hàng theo người mua
    Long countByBuyer(User buyer);
}
