package vn.group3.marketplace.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import vn.group3.marketplace.domain.entity.EscrowTransaction;
import vn.group3.marketplace.domain.entity.Order;

import java.util.List;
import java.util.Optional;

@Repository
public interface EscrowTransactionRepository extends JpaRepository<EscrowTransaction, Long> {

    Optional<EscrowTransaction> findByOrder(Order order);

    // Dashboard queries
    @Query("SELECT " +
            "SUM(CASE WHEN et.status = 'HELD' THEN et.amount ELSE 0 END), " +
            "SUM(CASE WHEN et.status = 'RELEASED' THEN et.amount ELSE 0 END), " +
            "SUM(CASE WHEN et.status = 'REFUNDED' THEN et.amount ELSE 0 END) " +
            "FROM EscrowTransaction et " +
            "WHERE et.order.sellerStore.id = :storeId")
    List<Object[]> findEscrowSummaryByStore(@Param("storeId") Long storeId);
}
