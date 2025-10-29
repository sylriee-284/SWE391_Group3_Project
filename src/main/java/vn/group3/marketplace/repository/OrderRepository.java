// ...existing code...
// Lấy order kèm productStorages (fetch join)
package vn.group3.marketplace.repository;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import vn.group3.marketplace.domain.entity.Order;
import vn.group3.marketplace.domain.entity.User;
import vn.group3.marketplace.domain.entity.SellerStore;
import vn.group3.marketplace.domain.enums.OrderStatus;

import java.util.List;

@Repository
public interface OrderRepository extends JpaRepository<Order, Long> {
        // Tìm đơn hàng theo người mua và tên sản phẩm (phân trang)
        @Query("SELECT o FROM Order o WHERE o.buyer = :buyer AND (:status IS NULL OR o.status = :status) AND (:key IS NULL OR LOWER(o.productName) LIKE LOWER(CONCAT('%', :key, '%')))")
        Page<Order> searchByBuyerAndProductName(@Param("buyer") User buyer, @Param("status") OrderStatus status,
                        @Param("key") String key, Pageable pageable);

        // Tìm đơn hàng theo người bán và tên sản phẩm (phân trang)
        @Query("SELECT o FROM Order o WHERE o.sellerStore = :sellerStore AND (:status IS NULL OR o.status = :status) AND (:key IS NULL OR LOWER(o.productName) LIKE LOWER(CONCAT('%', :key, '%')))")
        Page<Order> searchBySellerAndProductName(@Param("sellerStore") SellerStore sellerStore,
                        @Param("status") OrderStatus status, @Param("key") String key, Pageable pageable);

        // Tìm đơn hàng cho admin theo tên sản phẩm (phân trang)
        @Query("SELECT o FROM Order o WHERE (:status IS NULL OR o.status = :status) AND (:key IS NULL OR LOWER(o.productName) LIKE LOWER(CONCAT('%', :key, '%')))")
        Page<Order> searchByProductName(@Param("status") OrderStatus status, @Param("key") String key,
                        Pageable pageable);

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

        // Lấy order kèm productStorages (fetch join)
        @Query("SELECT o FROM Order o LEFT JOIN FETCH o.productStorages WHERE o.id = :id")
        java.util.Optional<Order> findByIdWithProductStorages(@Param("id") Long id);

        // Aggregate total quantity sold per product for a given store
        @Query("SELECT o.product.id, SUM(o.quantity) " +
                        "FROM Order o WHERE o.sellerStore.id = :storeId AND (:status IS NULL OR o.status = :status) " +
                        "GROUP BY o.product.id ORDER BY SUM(o.quantity) DESC")
        java.util.List<Object[]> findTopSoldProductIdsByStore(@Param("storeId") Long storeId,
                        @Param("status") vn.group3.marketplace.domain.enums.OrderStatus status, Pageable pageable);

        // Aggregate total quantity sold per product excluding a specific store (for
        // suggestions from other shops)
        @Query("SELECT o.product.id, SUM(o.quantity) " +
                        "FROM Order o WHERE (:excludeStoreId IS NULL OR o.sellerStore.id <> :excludeStoreId) " +
                        "GROUP BY o.product.id ORDER BY SUM(o.quantity) DESC")
        java.util.List<Object[]> findTopSoldProductIdsExcludingStore(@Param("excludeStoreId") Long excludeStoreId,
                        Pageable pageable);

        // Sum total quantity sold for a given store across provided statuses
        @Query("SELECT COALESCE(SUM(o.quantity),0) FROM Order o WHERE o.sellerStore.id = :storeId " +
                        "AND (:statuses IS NULL OR o.status IN (:statuses))")
        Long sumQuantityByStoreAndStatuses(@Param("storeId") Long storeId,
                        @Param("statuses") java.util.List<vn.group3.marketplace.domain.enums.OrderStatus> statuses);

        // Dashboard queries
        @Query("SELECT SUM(o.totalAmount) as grossSales, " +
                        "SUM(CASE WHEN o.status = 'COMPLETED' THEN o.totalAmount ELSE 0 END) as netSales " +
                        "FROM Order o WHERE o.sellerStore.id = :storeId " +
                        "AND o.createdAt BETWEEN :startDate AND :endDate")
        List<Object[]> findRevenueByStoreAndDateRange(@Param("storeId") Long storeId,
                        @Param("startDate") java.time.LocalDateTime startDate,
                        @Param("endDate") java.time.LocalDateTime endDate);

        @Query("SELECT COUNT(o) FROM Order o WHERE o.sellerStore.id = :storeId " +
                        "AND o.createdAt BETWEEN :startDate AND :endDate")
        Long countByStoreAndDateRange(@Param("storeId") Long storeId,
                        @Param("startDate") java.time.LocalDateTime startDate,
                        @Param("endDate") java.time.LocalDateTime endDate);

        @Query("SELECT COUNT(o) FROM Order o WHERE o.sellerStore.id = :storeId " +
                        "AND o.status = :status AND o.createdAt BETWEEN :startDate AND :endDate")
        Long countByStoreAndStatusAndDateRange(@Param("storeId") Long storeId,
                        @Param("status") OrderStatus status,
                        @Param("startDate") java.time.LocalDateTime startDate,
                        @Param("endDate") java.time.LocalDateTime endDate);

        @Query("SELECT COUNT(o) FROM Order o WHERE o.sellerStore.id = :storeId AND o.status = :status")
        Long countByStoreAndStatus(@Param("storeId") Long storeId, @Param("status") OrderStatus status);

        @Query("SELECT s.rating FROM SellerStore s WHERE s.id = :storeId")
        java.math.BigDecimal findStoreRating(@Param("storeId") Long storeId);

        @Query("SELECT COUNT(DISTINCT o.buyer.id) FROM Order o " +
                        "WHERE o.sellerStore.id = :storeId " +
                        "AND o.createdAt BETWEEN :startDate AND :endDate")
        Long countUniqueBuyers(@Param("storeId") Long storeId,
                        @Param("startDate") java.time.LocalDateTime startDate,
                        @Param("endDate") java.time.LocalDateTime endDate);

        @Query("SELECT o.buyer.id, COUNT(o) FROM Order o " +
                        "WHERE o.sellerStore.id = :storeId " +
                        "AND o.createdAt BETWEEN :startDate AND :endDate " +
                        "GROUP BY o.buyer.id HAVING COUNT(o) > 1")
        List<Object[]> findRepeatBuyers(@Param("storeId") Long storeId,
                        @Param("startDate") java.time.LocalDateTime startDate,
                        @Param("endDate") java.time.LocalDateTime endDate);

        @Query("SELECT COALESCE(SUM(o.totalAmount), 0) FROM Order o " +
                        "WHERE o.sellerStore.id = :storeId " +
                        "AND o.status = 'COMPLETED' " +
                        "AND o.createdAt BETWEEN :startDate AND :endDate")
        java.math.BigDecimal sumRevenueByStoreAndDateRange(@Param("storeId") Long storeId,
                        @Param("startDate") java.time.LocalDateTime startDate,
                        @Param("endDate") java.time.LocalDateTime endDate);

        @Query("SELECT COALESCE(SUM(o.totalAmount), 0) FROM Order o " +
                        "WHERE o.sellerStore.id = :storeId " +
                        "AND o.status = :status " +
                        "AND o.createdAt BETWEEN :startDate AND :endDate")
        java.math.BigDecimal sumRevenueByStoreAndStatusAndDateRange(
                        @Param("storeId") Long storeId,
                        @Param("status") OrderStatus status,
                        @Param("startDate") java.time.LocalDateTime startDate,
                        @Param("endDate") java.time.LocalDateTime endDate);

        @Query("SELECT p.id, p.name, c.name, " +
                        "SUM(o.totalAmount) as revenue, " +
                        "SUM(o.quantity) as units, " +
                        "p.stock, p.rating " +
                        "FROM Order o " +
                        "JOIN o.product p " +
                        "JOIN p.category c " +
                        "WHERE o.sellerStore.id = :storeId " +
                        "AND o.status = 'COMPLETED' " +
                        "AND o.createdAt BETWEEN :startDate AND :endDate " +
                        "GROUP BY p.id, p.name, c.name, p.stock, p.rating " +
                        "ORDER BY revenue DESC")
        List<Object[]> findTopProductsByStore(@Param("storeId") Long storeId,
                        @Param("startDate") java.time.LocalDateTime startDate,
                        @Param("endDate") java.time.LocalDateTime endDate,
                        @Param("limit") int limit);
}
