package vn.group3.marketplace.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import vn.group3.marketplace.domain.entity.SellerStore;
import vn.group3.marketplace.domain.entity.User;
import java.util.Optional;
import java.math.BigDecimal;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.repository.query.Param;

@Repository
public interface SellerStoreRepository extends JpaRepository<SellerStore, Long> {

    @Query("SELECT s FROM SellerStore s WHERE s.id = :id")
    Optional<SellerStore> findById(@Param("id") Long id);

    Optional<SellerStore> findByOwner(User owner);

    @Modifying
    @Query("UPDATE SellerStore s SET s.escrowAmount = CASE WHEN :isAdd = true THEN s.escrowAmount + :amount ELSE s.escrowAmount - :amount END WHERE s.id = :sellerStoreId")
    void updateEscrowAmount(@Param("sellerStoreId") Long sellerStoreId, @Param("amount") BigDecimal amount,
            @Param("isAdd") boolean isAdd);

    // Admin dashboard queries
    @Query("SELECT COUNT(s) FROM SellerStore s")
    long countTotalStores();

    @Query("SELECT COUNT(s) FROM SellerStore s WHERE s.status = 'ACTIVE'")
    long countActiveStores();

    /**
     * Cửa hàng theo trạng thái
     */
    @Query("SELECT s.status, COUNT(s) FROM SellerStore s GROUP BY s.status")
    java.util.List<Object[]> getStoreCountByStatus();

    /**
     * Tăng trưởng cửa hàng theo tháng
     */
    @Query("SELECT COUNT(s), MONTH(s.createdAt), YEAR(s.createdAt) FROM SellerStore s WHERE s.createdAt >= :startDate GROUP BY YEAR(s.createdAt), MONTH(s.createdAt) ORDER BY YEAR(s.createdAt), MONTH(s.createdAt)")
    java.util.List<Object[]> getStoreGrowthByMonth(@Param("startDate") java.time.LocalDateTime startDate);

    /**
     * Top cửa hàng theo doanh thu
     */
    @Query("SELECT s.id, s.storeName, SUM(o.totalAmount) as revenue FROM SellerStore s JOIN Order o ON o.sellerStore.id = s.id WHERE o.status = 'COMPLETED' GROUP BY s.id, s.storeName ORDER BY revenue DESC")
    java.util.List<Object[]> getTopStoresByRevenue(org.springframework.data.domain.Pageable pageable);
}
