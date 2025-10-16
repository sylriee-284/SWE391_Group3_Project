package vn.group3.marketplace.repository;

import java.util.Optional;

import vn.group3.marketplace.domain.entity.User;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {

    Optional<User> findByUsername(String username);

    Optional<User> findByEmail(String email);

    @Modifying
    @Transactional
    @Query(value = "UPDATE users SET password_hash = ?1 WHERE email = ?2", nativeQuery = true)
    void updatePassword(String password, String email);

    @Modifying
    @Transactional
    @Query(value = "UPDATE users SET balance = balance + :amount WHERE id = :id", nativeQuery = true)
    int incrementBalance(@org.springframework.data.repository.query.Param("id") Long id,
            @org.springframework.data.repository.query.Param("amount") java.math.BigDecimal amount);

    @Modifying
    @Transactional
    @Query(value = "UPDATE users SET balance = balance - :amount WHERE id = :id AND balance >= :amount", nativeQuery = true)
    int decrementIfEnough(@org.springframework.data.repository.query.Param("id") Long id,
            @org.springframework.data.repository.query.Param("amount") java.math.BigDecimal amount);

}
