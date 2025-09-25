package vn.group3.marketplace.service.interfaces;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import vn.group3.marketplace.domain.entity.SellerStore;
import vn.group3.marketplace.dto.request.SellerStoreCreateRequest;
import vn.group3.marketplace.dto.request.SellerStoreUpdateRequest;
import vn.group3.marketplace.dto.response.SellerStoreResponse;
import vn.group3.marketplace.dto.response.StoreDashboardResponse;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * Service interface for SellerStore management
 * Provides business logic for seller store operations
 */
public interface SellerStoreService {

    /**
     * Create a new seller store
     * @param userId Owner user ID
     * @param request Store creation request
     * @return Created SellerStore
     */
    SellerStore createStore(Long userId, SellerStoreCreateRequest request);

    /**
     * Update seller store information
     * @param storeId Store ID
     * @param request Store update request
     * @return Updated SellerStore
     */
    SellerStore updateStore(Long storeId, SellerStoreUpdateRequest request);

    /**
     * Get seller store by ID
     * @param storeId Store ID
     * @return Optional SellerStore
     */
    Optional<SellerStore> getStoreById(Long storeId);

    /**
     * Get seller store by owner user ID
     * @param userId Owner user ID
     * @return Optional SellerStore
     */
    Optional<SellerStore> getStoreByOwnerId(Long userId);

    /**
     * Get store dashboard data
     * @param storeId Store ID
     * @return Store dashboard response
     */
    StoreDashboardResponse getStoreDashboard(Long storeId);

    /**
     * Get all active stores
     * @param pageable Pagination information
     * @return Page of active stores
     */
    Page<SellerStoreResponse> getAllActiveStores(Pageable pageable);

    /**
     * Search stores by name or description
     * @param searchTerm Search term
     * @param pageable Pagination information
     * @return Page of matching stores
     */
    Page<SellerStoreResponse> searchStores(String searchTerm, Pageable pageable);

    /**
     * Get stores by status
     * @param status Store status
     * @param pageable Pagination information
     * @return Page of stores with specified status
     */
    Page<SellerStoreResponse> getStoresByStatus(String status, Pageable pageable);

    /**
     * Get verified stores
     * @param pageable Pagination information
     * @return Page of verified stores
     */
    Page<SellerStoreResponse> getVerifiedStores(Pageable pageable);

    /**
     * Verify a seller store
     * @param storeId Store ID
     * @param verifiedBy Admin user ID who verified
     * @return Updated SellerStore
     */
    SellerStore verifyStore(Long storeId, Long verifiedBy);

    /**
     * Suspend a seller store
     * @param storeId Store ID
     * @param suspendedBy Admin user ID who suspended
     * @param reason Suspension reason
     * @return Updated SellerStore
     */
    SellerStore suspendStore(Long storeId, Long suspendedBy, String reason);

    /**
     * Activate a seller store
     * @param storeId Store ID
     * @param activatedBy Admin user ID who activated
     * @return Updated SellerStore
     */
    SellerStore activateStore(Long storeId, Long activatedBy);

    /**
     * Deactivate a seller store
     * @param storeId Store ID
     * @param deactivatedBy User ID who deactivated
     * @return Updated SellerStore
     */
    SellerStore deactivateStore(Long storeId, Long deactivatedBy);

    /**
     * Delete a seller store (soft delete)
     * @param storeId Store ID
     * @param deletedBy User ID who deleted
     */
    void deleteStore(Long storeId, Long deletedBy);

    /**
     * Check if user can create a seller store
     * @param userId User ID
     * @param depositAmount Proposed deposit amount
     * @return true if user can create store
     */
    boolean canCreateStore(Long userId, BigDecimal depositAmount);

    /**
     * Check if store can list product with specified price
     * @param storeId Store ID
     * @param productPrice Product price
     * @return true if store can list product
     */
    boolean canListProduct(Long storeId, BigDecimal productPrice);

    /**
     * Validate store name uniqueness
     * @param storeName Store name
     * @param excludeStoreId Store ID to exclude (for updates)
     * @return true if store name is available
     */
    boolean isStoreNameAvailable(String storeName, Long excludeStoreId);

    /**
     * Get store statistics
     * @return Map containing store statistics
     */
    Map<String, Object> getStoreStatistics();

    /**
     * Get top performing stores
     * @param limit Number of top stores
     * @return List of top performing stores
     */
    List<SellerStoreResponse> getTopPerformingStores(int limit);

    /**
     * Get stores pending verification
     * @param pageable Pagination information
     * @return Page of stores pending verification
     */
    Page<SellerStoreResponse> getStoresPendingVerification(Pageable pageable);

    /**
     * Update store deposit amount
     * @param storeId Store ID
     * @param newDepositAmount New deposit amount
     * @param updatedBy User ID who updated
     * @return Updated SellerStore
     */
    SellerStore updateStoreDeposit(Long storeId, BigDecimal newDepositAmount, Long updatedBy);

    /**
     * Get minimum required deposit amount
     * @return Minimum deposit amount
     */
    BigDecimal getMinimumDepositAmount();

    /**
     * Calculate max listing price for deposit amount
     * @param depositAmount Deposit amount
     * @return Maximum listing price
     */
    BigDecimal calculateMaxListingPrice(BigDecimal depositAmount);

    /**
     * Check if user owns the store
     * @param userId User ID
     * @param storeId Store ID
     * @return true if user owns the store
     */
    boolean isStoreOwner(Long userId, Long storeId);

    /**
     * Get store owner ID
     * @param storeId Store ID
     * @return Owner user ID
     */
    Optional<Long> getStoreOwnerId(Long storeId);

    /**
     * Upload store logo
     * @param storeId Store ID
     * @param logoFile Logo file
     * @return Updated SellerStore
     */
    SellerStore uploadStoreLogo(Long storeId, org.springframework.web.multipart.MultipartFile logoFile);

    /**
     * Remove store logo
     * @param storeId Store ID
     * @return Updated SellerStore
     */
    SellerStore removeStoreLogo(Long storeId);
}
