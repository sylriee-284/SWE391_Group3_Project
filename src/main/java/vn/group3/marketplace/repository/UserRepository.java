package vn.group3.marketplace.repository;

import java.math.BigDecimal;
import java.util.Optional;

import vn.group3.marketplace.domain.entity.User;
import vn.group3.marketplace.domain.enums.UserStatus;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {

        Optional<User> findByUsername(String username);

        Optional<User> findByEmail(String email);

        Page<User> findByStatus(UserStatus status, Pageable pageable);

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

}
