package vn.group3.marketplace.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import vn.group3.marketplace.domain.entity.SellerStore;
import java.util.Optional;
import java.math.BigDecimal;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.repository.query.Param;

@Repository
public interface SellerStoreRepository extends JpaRepository<SellerStore, Long> {

    @Query("SELECT s FROM SellerStore s WHERE s.id = :id")
    Optional<SellerStore> findById(@Param("id") Long id);

    @Modifying
    @Query("UPDATE SellerStore s SET s.escrowAmount = CASE WHEN :isAdd = true THEN s.escrowAmount + :amount ELSE s.escrowAmount - :amount END WHERE s.id = :sellerStoreId")
    void updateEscrowAmount(@Param("sellerStoreId") Long sellerStoreId, @Param("amount") BigDecimal amount,
            @Param("isAdd") boolean isAdd);

    // Admin dashboard queries
    @Query("SELECT COUNT(s) FROM SellerStore s")
    long countTotalStores();

    @Query("SELECT COUNT(s) FROM SellerStore s WHERE s.status = 'ACTIVE'")
    long countActiveStores();
}
