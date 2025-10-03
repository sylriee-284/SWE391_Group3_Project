package vn.group3.marketplace.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import vn.group3.marketplace.domain.entity.User;
import vn.group3.marketplace.domain.entity.WalletTransaction;
import vn.group3.marketplace.domain.enums.WalletTransactionType;

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
    Page<WalletTransaction> findByUserAndPaymentStatusOrderByIdDesc(User user, String status, Pageable pageable);

    /**
     * Tìm giao dịch theo user, loại giao dịch và trạng thái thanh toán
     */
    Page<WalletTransaction> findByUserAndTypeAndPaymentStatusOrderByIdDesc(User user, WalletTransactionType type,
            String status, Pageable pageable);

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
    long countByUserAndPaymentStatus(User user, String status);

}
