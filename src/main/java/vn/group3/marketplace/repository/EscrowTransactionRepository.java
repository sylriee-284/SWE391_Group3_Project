package vn.group3.marketplace.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import vn.group3.marketplace.domain.entity.EscrowTransaction;
import vn.group3.marketplace.domain.entity.Order;
import vn.group3.marketplace.domain.enums.EscrowStatus;

import java.time.LocalDateTime;
import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

@Repository
public interface EscrowTransactionRepository extends JpaRepository<EscrowTransaction, Long> {

        Optional<EscrowTransaction> findByOrder(Order order);

        // Dashboard queries
        @Query("SELECT " +
                        "SUM(CASE WHEN et.status = 'HELD' THEN et.totalAmount ELSE 0 END), " +
                        "SUM(CASE WHEN et.status = 'RELEASED' THEN et.totalAmount ELSE 0 END), " +
                        "SUM(CASE WHEN et.status = 'REFUNDED' THEN et.totalAmount ELSE 0 END) " +
                        "FROM EscrowTransaction et " +
                        "WHERE et.order.sellerStore.id = :storeId")
        List<Object[]> findEscrowSummaryByStore(@Param("storeId") Long storeId);

        @Query("SELECT e FROM EscrowTransaction e WHERE e.status = :status AND e.holdUntil <= :currentTime")
        List<EscrowTransaction> findByStatusAndHoldUntilBefore(@Param("status") EscrowStatus status,
                        @Param("currentTime") LocalDateTime currentTime);

        // Dashboard: Count escrow by status and store
        @Query("SELECT COUNT(et) FROM EscrowTransaction et " +
                        "WHERE et.order.sellerStore.id = :storeId " +
                        "AND et.status = :status")
        Long countByStoreAndStatus(@Param("storeId") Long storeId, @Param("status") EscrowStatus status);

        // Sum total amount held in escrow for a store (for Close Store validation)
        @Query("SELECT COALESCE(SUM(et.totalAmount), 0) FROM EscrowTransaction et " +
                        "WHERE et.order.sellerStore.id = :storeId AND et.status = 'HELD'")
        Optional<BigDecimal> sumHeldAmountByStore(@Param("storeId") Long storeId);

        // Dashboard: Upcoming release schedule
        @Query("SELECT DATE(et.holdUntil), SUM(et.sellerAmount), COUNT(et) " +
                        "FROM EscrowTransaction et " +
                        "WHERE et.order.sellerStore.id = :storeId " +
                        "AND et.status = 'HELD' " +
                        "AND et.holdUntil BETWEEN :startDate AND :endDate " +
                        "GROUP BY DATE(et.holdUntil) " +
                        "ORDER BY DATE(et.holdUntil)")
        List<Object[]> findUpcomingReleaseSchedule(@Param("storeId") Long storeId,
                        @Param("startDate") LocalDateTime startDate,
                        @Param("endDate") LocalDateTime endDate);

        // Dashboard: Escrow timeline (grouped by date)
        @Query("SELECT DATE(et.createdAt), et.status, SUM(et.totalAmount) " +
                        "FROM EscrowTransaction et " +
                        "WHERE et.order.sellerStore.id = :storeId " +
                        "AND et.createdAt BETWEEN :startDate AND :endDate " +
                        "GROUP BY DATE(et.createdAt), et.status " +
                        "ORDER BY DATE(et.createdAt)")
        List<Object[]> findEscrowTimelineByDateRange(@Param("storeId") Long storeId,
                        @Param("startDate") LocalDateTime startDate,
                        @Param("endDate") LocalDateTime endDate);

        // Sum total seller amount (đã quyết toán) for RELEASED orders in date range
        @Query("SELECT COALESCE(SUM(et.sellerAmount), 0) FROM EscrowTransaction et " +
                        "WHERE et.order.sellerStore.id = :storeId " +
                        "AND et.status = 'RELEASED' " +
                        "AND et.releasedAt BETWEEN :startDate AND :endDate")
        BigDecimal sumSellerAmountForReleasedOrders(@Param("storeId") Long storeId,
                        @Param("startDate") LocalDateTime startDate,
                        @Param("endDate") LocalDateTime endDate);

        // Count RELEASED orders in date range
        @Query("SELECT COUNT(et) FROM EscrowTransaction et " +
                        "WHERE et.order.sellerStore.id = :storeId " +
                        "AND et.status = 'RELEASED' " +
                        "AND et.releasedAt BETWEEN :startDate AND :endDate")
        Long countReleasedOrdersInDateRange(@Param("storeId") Long storeId,
                        @Param("startDate") LocalDateTime startDate,
                        @Param("endDate") LocalDateTime endDate);

        // Get seller_amount by date for revenue chart (after commission deduction)
        @Query("SELECT DATE(et.releasedAt), SUM(et.sellerAmount) " +
                        "FROM EscrowTransaction et " +
                        "WHERE et.order.sellerStore.id = :storeId " +
                        "AND et.status = 'RELEASED' " +
                        "AND et.releasedAt BETWEEN :startDate AND :endDate " +
                        "GROUP BY DATE(et.releasedAt) " +
                        "ORDER BY DATE(et.releasedAt)")
        List<Object[]> findSellerAmountByDateRange(@Param("storeId") Long storeId,
                        @Param("startDate") LocalDateTime startDate,
                        @Param("endDate") LocalDateTime endDate);

        // Get top products by seller_amount (revenue after commission) for chart
        @Query("SELECT p.id, p.name, c.name, " +
                        "SUM(et.sellerAmount) as revenue, " +
                        "SUM(o.quantity) as units " +
                        "FROM EscrowTransaction et " +
                        "JOIN et.order o " +
                        "JOIN o.product p " +
                        "JOIN p.category c " +
                        "WHERE o.sellerStore.id = :storeId " +
                        "AND et.status = 'RELEASED' " +
                        "AND et.releasedAt BETWEEN :startDate AND :endDate " +
                        "GROUP BY p.id, p.name, c.name " +
                        "ORDER BY revenue DESC")
        List<Object[]> findTopProductsBySellerAmount(@Param("storeId") Long storeId,
                        @Param("startDate") LocalDateTime startDate,
                        @Param("endDate") LocalDateTime endDate,
                        @Param("limit") int limit);

        // Sum seller_amount for a specific product in date range (revenue after
        // commission)
        @Query("SELECT COALESCE(SUM(et.sellerAmount), 0) FROM EscrowTransaction et " +
                        "WHERE et.order.sellerStore.id = :storeId " +
                        "AND et.order.product.id = :productId " +
                        "AND et.status = 'RELEASED' " +
                        "AND et.releasedAt BETWEEN :startDate AND :endDate")
        BigDecimal sumSellerAmountByProduct(@Param("storeId") Long storeId,
                        @Param("productId") Long productId,
                        @Param("startDate") LocalDateTime startDate,
                        @Param("endDate") LocalDateTime endDate);
}
