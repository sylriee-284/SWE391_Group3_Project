package vn.group3.marketplace.repository;

import java.util.Optional;

import vn.group3.marketplace.domain.entity.User;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {

    Optional<User> findByUsername(String username);

}
