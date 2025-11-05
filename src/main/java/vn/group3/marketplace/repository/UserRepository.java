package vn.group3.marketplace.repository;

import java.math.BigDecimal;
import java.util.Optional;

import vn.group3.marketplace.domain.entity.User;
import vn.group3.marketplace.domain.enums.UserStatus;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
public interface UserRepository extends JpaRepository<User, Long>, JpaSpecificationExecutor<User> {

        @Query("SELECT u FROM User u LEFT JOIN FETCH u.sellerStore WHERE u.username = :username")
        Optional<User> findByUsername(@Param("username") String username);

        Optional<User> findByEmail(String email);

        Page<User> findByStatus(UserStatus status, Pageable pageable);

        Optional<User> findByPhone(String phone);

        // Optimized: Check both username and email in a single query to reduce DB calls
        @Query("SELECT u FROM User u WHERE u.username = :username OR u.email = :email")
        Optional<User> findByUsernameOrEmail(@Param("username") String username, @Param("email") String email);

        Optional<User> findBySellerStore_StoreName(String storeName);

        Optional<User> findByFullName(String fullName);

        @Modifying
        @Transactional
        @Query(value = "UPDATE users SET password_hash = ?1 WHERE email = ?2", nativeQuery = true)
        void updatePassword(String password, String email);

        @Modifying
        @Query(value = "UPDATE users SET balance = balance + :amount WHERE id = :id", nativeQuery = true)
        int incrementBalance(@Param("id") Long id, @Param("amount") BigDecimal amount);

        @Modifying
        @Query(value = "UPDATE users SET balance = balance - :amount WHERE id = :id AND balance >= :amount", nativeQuery = true)
        int decrementBalance(@Param("id") Long id, @Param("amount") BigDecimal amount);

        @Modifying
        @Transactional
        @Query(value = "UPDATE users SET balance = balance - :amount WHERE id = :id AND balance >= :amount", nativeQuery = true)
        int decrementIfEnough(@Param("id") Long id, @Param("amount") BigDecimal amount);

        // Admin dashboard queries
        @Query("SELECT COUNT(u) FROM User u WHERE u.status = 'ACTIVE'")
        long countActiveUsers();

        @Query("SELECT COUNT(u) FROM User u WHERE u.createdAt >= :startOfMonth AND u.createdAt < :endOfMonth")
        long countNewUsersThisMonth(@Param("startOfMonth") java.time.LocalDateTime startOfMonth,
                        @Param("endOfMonth") java.time.LocalDateTime endOfMonth);

        /**
         * Tăng trưởng người dùng theo tháng
         */
        @Query("SELECT COUNT(u), MONTH(u.createdAt), YEAR(u.createdAt) FROM User u WHERE u.createdAt >= :startDate GROUP BY YEAR(u.createdAt), MONTH(u.createdAt) ORDER BY YEAR(u.createdAt), MONTH(u.createdAt)")
        java.util.List<Object[]> getUserGrowthByMonth(@Param("startDate") java.time.LocalDateTime startDate);

        /**
         * Phân tích độ tuổi người dùng (nếu có dateOfBirth)
         */
        @Query("SELECT CASE WHEN YEAR(CURRENT_DATE) - YEAR(u.dateOfBirth) < 25 THEN 'Dưới 25' WHEN YEAR(CURRENT_DATE) - YEAR(u.dateOfBirth) < 35 THEN '25-35' WHEN YEAR(CURRENT_DATE) - YEAR(u.dateOfBirth) < 50 THEN '35-50' ELSE 'Trên 50' END as ageGroup, COUNT(u) FROM User u WHERE u.dateOfBirth IS NOT NULL GROUP BY CASE WHEN YEAR(CURRENT_DATE) - YEAR(u.dateOfBirth) < 25 THEN 'Dưới 25' WHEN YEAR(CURRENT_DATE) - YEAR(u.dateOfBirth) < 35 THEN '25-35' WHEN YEAR(CURRENT_DATE) - YEAR(u.dateOfBirth) < 50 THEN '35-50' ELSE 'Trên 50' END")
        java.util.List<Object[]> getUserCountByAgeGroup();

        /**
         * Người dùng có cửa hàng vs không có
         */
        @Query("SELECT CASE WHEN s.id IS NOT NULL THEN 'Có cửa hàng' ELSE 'Khách hàng' END as userType, COUNT(u) FROM User u LEFT JOIN u.sellerStore s GROUP BY CASE WHEN s.id IS NOT NULL THEN 'Có cửa hàng' ELSE 'Khách hàng' END")
        java.util.List<Object[]> getUserCountByType();

}
