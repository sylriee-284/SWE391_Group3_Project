package vn.group3.marketplace.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import vn.group3.marketplace.domain.entity.User;
import vn.group3.marketplace.domain.entity.WalletTransaction;
import vn.group3.marketplace.domain.enums.WalletTransactionType;
import vn.group3.marketplace.domain.enums.WalletTransactionStatus;

@Repository
public interface WalletTransactionRepository extends JpaRepository<WalletTransaction, Long> {

    Optional<WalletTransaction> findByPaymentRef(String paymentRef);

    /**
     * Tìm tất cả giao dịch của 1 user (có phân trang)
     */
    Page<WalletTransaction> findByUserOrderByIdDesc(User user, Pageable pageable);

    /**
     * Tìm giao dịch theo user và loại giao dịch
     */
    Page<WalletTransaction> findByUserAndTypeOrderByIdDesc(User user, WalletTransactionType type, Pageable pageable);

    /**
     * Tìm giao dịch theo user và trạng thái thanh toán
     */
    Page<WalletTransaction> findByUserAndPaymentStatusOrderByIdDesc(User user, WalletTransactionStatus status,
            Pageable pageable);

    /**
     * Tìm giao dịch theo user, loại giao dịch và trạng thái thanh toán
     */
    Page<WalletTransaction> findByUserAndTypeAndPaymentStatusOrderByIdDesc(User user, WalletTransactionType type,
            WalletTransactionStatus status, Pageable pageable);

    /**
     * Tìm giao dịch gần đây của user (top 10)
     */
    List<WalletTransaction> findTop10ByUserOrderByIdDesc(User user);

    /**
     * Đếm tổng số giao dịch của user
     */
    long countByUser(User user);

    /**
     * Đếm số giao dịch theo loại
     */
    long countByUserAndType(User user, WalletTransactionType type);

    /**
     * Đếm số giao dịch theo trạng thái
     */
    long countByUserAndPaymentStatus(User user, WalletTransactionStatus status);

    
    /**
     * Kiểm tra xem user có giao dịch với loại và trạng thái cụ thể không
     */
    boolean existsByUserAndTypeAndPaymentStatus(User user, WalletTransactionType type, WalletTransactionStatus status);

    /**
     * Tìm tất cả giao dịch theo loại (cho admin)
     */
    Page<WalletTransaction> findByTypeOrderByIdDesc(WalletTransactionType type, Pageable pageable);

    /**
     * Tìm giao dịch theo loại và trạng thái (cho admin)
     */
    Page<WalletTransaction> findByTypeAndPaymentStatusOrderByIdDesc(WalletTransactionType type, 
                                                                   WalletTransactionStatus status, 
                                                                   Pageable pageable);

    /**
     * Tìm tất cả giao dịch theo loại với JOIN FETCH user (cho admin)
     */
    @Query("SELECT w FROM WalletTransaction w JOIN FETCH w.user WHERE w.type = :type ORDER BY w.id DESC")
    Page<WalletTransaction> findByTypeWithUserOrderByIdDesc(@Param("type") WalletTransactionType type, Pageable pageable);

    /**
     * Tìm giao dịch theo loại và trạng thái với JOIN FETCH user (cho admin)
     */
    @Query("SELECT w FROM WalletTransaction w JOIN FETCH w.user WHERE w.type = :type AND w.paymentStatus = :status ORDER BY w.id DESC")
    Page<WalletTransaction> findByTypeAndPaymentStatusWithUserOrderByIdDesc(
        @Param("type") WalletTransactionType type,
        @Param("status") WalletTransactionStatus status,
        Pageable pageable);

}
