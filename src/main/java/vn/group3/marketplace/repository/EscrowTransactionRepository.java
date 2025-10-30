package vn.group3.marketplace.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import vn.group3.marketplace.domain.entity.EscrowTransaction;
import vn.group3.marketplace.domain.entity.Order;
import vn.group3.marketplace.domain.enums.EscrowStatus;

import java.time.LocalDateTime;
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
}
