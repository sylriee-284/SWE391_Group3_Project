package vn.group3.marketplace.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import vn.group3.marketplace.domain.entity.SellerStore;
import java.util.Optional;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

@Repository
public interface SellerStoreRepository extends JpaRepository<SellerStore, Long> {

    @Query("SELECT s FROM SellerStore s WHERE s.id = :id")
    Optional<SellerStore> findById(@Param("id") Long id);
}
