package vn.group3.marketplace.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import vn.group3.marketplace.domain.entity.Role;

@Repository
public interface RoleRepository extends JpaRepository<Role, Long> {
    java.util.Optional<Role> findByCode(String code);

}
