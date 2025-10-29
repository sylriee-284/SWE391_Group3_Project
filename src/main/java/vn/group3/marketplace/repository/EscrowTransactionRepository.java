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

import vn.group3.marketplace.domain.entity.SellerStore;

@Repository
public interface EscrowTransactionRepository extends JpaRepository<EscrowTransaction, Long> {

    Optional<EscrowTransaction> findByOrder(Order order);

    @Query("SELECT SUM(e.sellerAmount) FROM EscrowTransaction e WHERE e.sellerStore = :store AND e.status = :status")
    BigDecimal sumAmountBySellerStoreAndStatus(@Param("store") SellerStore store, @Param("status") EscrowStatus status);

    @Query("SELECT e FROM EscrowTransaction e WHERE e.status = :status AND e.holdUntil <= :currentTime")
    List<EscrowTransaction> findByStatusAndHoldUntilBefore(@Param("status") EscrowStatus status,
            @Param("currentTime") LocalDateTime currentTime);
}
