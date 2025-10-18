package vn.group3.marketplace.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import vn.group3.marketplace.domain.entity.EscrowTransaction;
import vn.group3.marketplace.domain.entity.Order;

import java.util.Optional;

@Repository
public interface EscrowTransactionRepository extends JpaRepository<EscrowTransaction, Long> {

    Optional<EscrowTransaction> findByOrder(Order order);
}
