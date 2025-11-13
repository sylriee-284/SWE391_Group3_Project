package vn.group3.marketplace.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import vn.group3.marketplace.domain.entity.ProductStorage;
import vn.group3.marketplace.domain.enums.ProductStorageStatus;

import org.springframework.data.jpa.repository.Modifying;

import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ProductStorageRepository extends JpaRepository<ProductStorage, Long> {

  @Query("""
          SELECT COUNT(ps) FROM ProductStorage ps
          WHERE ps.product.id = :productId
            AND ps.status = :status
            AND ps.isDeleted = false
      """)
  long countAvailable(@Param("productId") Long productId,
      @Param("status") ProductStorageStatus status);

  List<ProductStorage> findByProductIdAndStatusOrderByCreatedAtAsc(Long productId, ProductStorageStatus status);

  List<ProductStorage> findByProductIdAndStatusAndOrderIsNull(Long productId, ProductStorageStatus status);

  @Query("SELECT COUNT(ps) FROM ProductStorage ps WHERE ps.product.id = :productId AND ps.status = :status AND ps.order IS NULL")
  long countAvailableStockByProductId(@Param("productId") Long productId,
      @Param("status") ProductStorageStatus status);

  @Modifying
  @Query("UPDATE ProductStorage ps SET ps.status = :status WHERE ps.product.id = :productId AND ps.status = :currentStatus")
  void updateStatus(Long productId, ProductStorageStatus currentStatus, ProductStorageStatus newStatus);

  // Dashboard queries
  @Query("SELECT COUNT(ps) FROM ProductStorage ps " +
      "WHERE ps.product.sellerStore.id = :storeId " +
      "AND ps.reservedUntil IS NOT NULL " +
      "AND ps.reservedUntil < :thresholdDate " +
      "AND ps.status = 'AVAILABLE'")
  Long countExpiringStock(@Param("storeId") Long storeId,
      @Param("thresholdDate") java.time.LocalDateTime thresholdDate);

  @Query("SELECT ps.product.id, ps.product.name, ps.reservedUntil " +
      "FROM ProductStorage ps " +
      "WHERE ps.product.sellerStore.id = :storeId " +
      "AND ps.reservedUntil IS NOT NULL " +
      "AND ps.reservedUntil < :thresholdDate " +
      "AND ps.status = 'AVAILABLE' " +
      "ORDER BY ps.reservedUntil ASC")
  List<Object[]> findExpiringStock(@Param("storeId") Long storeId,
      @Param("thresholdDate") java.time.LocalDateTime thresholdDate,
      @Param("limit") int limit);

  // Dashboard: Count product storage by status and product
  @Query("SELECT ps.status, COUNT(ps) " +
      "FROM ProductStorage ps " +
      "WHERE ps.product.id = :productId " +
      "GROUP BY ps.status")
  List<Object[]> countByProductIdAndGroupByStatus(@Param("productId") Long productId);

  // Dashboard: Get inventory status for all products in a store
  @Query("SELECT ps.product.id, ps.status, COUNT(ps) " +
      "FROM ProductStorage ps " +
      "WHERE ps.product.sellerStore.id = :storeId " +
      "GROUP BY ps.product.id, ps.status")
  List<Object[]> countInventoryByStoreGroupByStatus(@Param("storeId") Long storeId);
}
