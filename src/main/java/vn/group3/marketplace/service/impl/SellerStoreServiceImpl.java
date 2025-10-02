package vn.group3.marketplace.service.impl;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;
import vn.group3.marketplace.config.MarketplaceProperties;
import vn.group3.marketplace.domain.entity.SellerStore;
import vn.group3.marketplace.domain.entity.User;
import vn.group3.marketplace.domain.constants.StoreStatus;
import vn.group3.marketplace.dto.request.SellerStoreCreateRequest;
import vn.group3.marketplace.dto.request.SellerStoreUpdateRequest;
import vn.group3.marketplace.dto.response.SellerStoreResponse;
import vn.group3.marketplace.dto.response.StoreDashboardResponse;
import vn.group3.marketplace.repository.SellerStoreRepository;
import vn.group3.marketplace.repository.UserRepository;
import vn.group3.marketplace.service.interfaces.SellerStoreService;
import vn.group3.marketplace.service.interfaces.UserService;
import vn.group3.marketplace.service.interfaces.WalletService;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.*;

/**
 * Implementation of SellerStoreService
 * Provides business logic for seller store management
 */
@Slf4j
@Service
@RequiredArgsConstructor
@Transactional
public class SellerStoreServiceImpl implements SellerStoreService {

    private final SellerStoreRepository sellerStoreRepository;
    private final UserRepository userRepository;
    private final UserService userService;
    private final WalletService walletService;
    private final MarketplaceProperties marketplaceProperties;

    @Override
    public SellerStore createStore(Long userId, SellerStoreCreateRequest request) {
        log.info("Creating seller store for user {}", userId);

        // Validate user exists and can create store
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found: " + userId));

        // TEMPORARILY DISABLED: Deposit validation
        // if (!canCreateStore(userId, request.getDepositAmount())) {
        //     throw new IllegalStateException("User cannot create seller store");
        // }

        // Validate store name uniqueness
        if (!isStoreNameAvailable(request.getStoreName(), null)) {
            throw new IllegalArgumentException("Store name already exists: " + request.getStoreName());
        }

        // Create seller store (deposit temporarily disabled)
        SellerStore store = SellerStore.builder()
                .ownerUser(user)
                .storeName(request.getStoreName())
                .storeDescription(request.getStoreDescription())
                .depositAmount(request.getDepositAmount() != null ? request.getDepositAmount() : BigDecimal.ZERO)
                .maxListingPrice(request.getDepositAmount() != null ? calculateMaxListingPrice(request.getDepositAmount()) : BigDecimal.valueOf(999999999))
                .contactEmail(request.getContactEmail())
                .contactPhone(request.getContactPhone())
                .businessLicense(request.getBusinessLicense())
                .status(StoreStatus.ACTIVE)
                .isVerified(false)
                .isActive(true)
                .build();

        store.setCreatedBy(userId);
        store = sellerStoreRepository.save(store);

        // TEMPORARILY DISABLED: Deposit payment processing
        // try {
        //     walletService.processStoreDeposit(userId, request.getDepositAmount(), store.getId());
        // } catch (Exception e) {
        //     log.error("Failed to process store deposit for user {}: {}", userId, e.getMessage());
        //     throw new IllegalStateException("Failed to process deposit payment: " + e.getMessage());
        // }

        // TEMPORARILY DISABLED: Assign SELLER role (role doesn't exist yet)
        // try {
        //     userService.assignRole(userId, "SELLER");
        // } catch (Exception e) {
        //     log.warn("Failed to assign SELLER role to user {}: {}", userId, e.getMessage());
        // }

        log.info("Successfully created seller store {} for user {} (deposit and role assignment disabled)", store.getId(), userId);
        return store;
    }

    @Override
    public SellerStore updateStore(Long storeId, SellerStoreUpdateRequest request) {
        log.info("Updating seller store {}", storeId);

        SellerStore store = sellerStoreRepository.findById(storeId)
                .orElseThrow(() -> new IllegalArgumentException("Store not found: " + storeId));

        // Validate store name uniqueness if changed
        if (request.getStoreName() != null && 
            !request.getStoreName().equals(store.getStoreName()) &&
            !isStoreNameAvailable(request.getStoreName(), storeId)) {
            throw new IllegalArgumentException("Store name already exists: " + request.getStoreName());
        }

        // Update fields
        if (request.getStoreName() != null) {
            store.setStoreName(request.getStoreName());
        }
        if (request.getStoreDescription() != null) {
            store.setStoreDescription(request.getStoreDescription());
        }
        if (request.getContactEmail() != null) {
            store.setContactEmail(request.getContactEmail());
        }
        if (request.getContactPhone() != null) {
            store.setContactPhone(request.getContactPhone());
        }
        if (request.getBusinessLicense() != null) {
            store.setBusinessLicense(request.getBusinessLicense());
        }
        if (request.getStoreLogoUrl() != null) {
            store.setStoreLogoUrl(request.getStoreLogoUrl());
        }

        store.setUpdatedAt(LocalDateTime.now());
        store = sellerStoreRepository.save(store);

        log.info("Successfully updated seller store {}", storeId);
        return store;
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<SellerStore> getStoreById(Long storeId) {
        return sellerStoreRepository.findByIdWithOwner(storeId);
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<SellerStore> getStoreByOwnerId(Long userId) {
        return sellerStoreRepository.findByOwnerUserIdAndIsDeletedFalse(userId);
    }

    @Override
    @Transactional(readOnly = true)
    public StoreDashboardResponse getStoreDashboard(Long storeId) {
        log.info("Getting dashboard data for store {}", storeId);

        SellerStore store = getStoreById(storeId)
                .orElseThrow(() -> new IllegalArgumentException("Store not found: " + storeId));

        // TODO: Implement dashboard data aggregation
        // This will be expanded when Order, Product, and Review entities are implemented
        
        return StoreDashboardResponse.builder()
                .storeId(store.getId())
                .storeName(store.getStoreName())
                .status(store.getStatus())
                .isVerified(store.getIsVerified())
                .isActive(store.getIsActive())
                .createdAt(store.getCreatedAt())
                .depositAmount(store.getDepositAmount())
                .maxListingPrice(store.getMaxListingPrice())
                .totalRevenue(BigDecimal.ZERO)
                .totalProfit(BigDecimal.ZERO)
                .pendingEscrow(BigDecimal.ZERO)
                .availableBalance(BigDecimal.ZERO)
                .totalProducts(0L)
                .activeProducts(0L)
                .inactiveProducts(0L)
                .outOfStockProducts(0L)
                .totalOrders(0L)
                .pendingOrders(0L)
                .completedOrders(0L)
                .cancelledOrders(0L)
                .totalCustomers(0L)
                .repeatCustomers(0L)
                .customerRetentionRate(0.0)
                .totalReviews(0L)
                .averageRating(0.0)
                .ratingDistribution(new HashMap<>())
                .conversionRate(BigDecimal.ZERO)
                .averageOrderValue(BigDecimal.ZERO)
                .totalViews(0L)
                .uniqueVisitors(0L)
                .recentOrders(new ArrayList<>())
                .recentReviews(new ArrayList<>())
                .topProducts(new ArrayList<>())
                .revenueByDay(new HashMap<>())
                .ordersByDay(new HashMap<>())
                .revenueByMonth(new HashMap<>())
                .build();
    }

    @Override
    @Transactional(readOnly = true)
    public Page<SellerStoreResponse> getAllActiveStores(Pageable pageable) {
        return sellerStoreRepository.findAllActive(pageable)
                .map(SellerStoreResponse::fromEntity);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<SellerStoreResponse> searchStores(String searchTerm, Pageable pageable) {
        return sellerStoreRepository.searchStores(searchTerm, pageable)
                .map(SellerStoreResponse::fromEntity);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<SellerStoreResponse> getStoresByStatus(String status, Pageable pageable) {
        return sellerStoreRepository.findByStatus(status, pageable)
                .map(SellerStoreResponse::fromEntity);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<SellerStoreResponse> getVerifiedStores(Pageable pageable) {
        return sellerStoreRepository.findVerifiedStores(pageable)
                .map(SellerStoreResponse::fromEntity);
    }

    @Override
    public SellerStore verifyStore(Long storeId, Long verifiedBy) {
        log.info("Verifying store {} by user {}", storeId, verifiedBy);

        SellerStore store = getStoreById(storeId)
                .orElseThrow(() -> new IllegalArgumentException("Store not found: " + storeId));

        store.setIsVerified(true);
        store.setUpdatedAt(LocalDateTime.now());

        store = sellerStoreRepository.save(store);
        log.info("Successfully verified store {}", storeId);
        return store;
    }

    @Override
    public SellerStore suspendStore(Long storeId, Long suspendedBy, String reason) {
        log.info("Suspending store {} by user {} for reason: {}", storeId, suspendedBy, reason);

        SellerStore store = getStoreById(storeId)
                .orElseThrow(() -> new IllegalArgumentException("Store not found: " + storeId));

        store.setStatus(StoreStatus.SUSPENDED);
        store.setIsActive(false);
        store.setUpdatedAt(LocalDateTime.now());

        store = sellerStoreRepository.save(store);
        log.info("Successfully suspended store {}", storeId);
        return store;
    }

    @Override
    public SellerStore activateStore(Long storeId, Long activatedBy) {
        log.info("Activating store {} by user {}", storeId, activatedBy);

        SellerStore store = getStoreById(storeId)
                .orElseThrow(() -> new IllegalArgumentException("Store not found: " + storeId));

        store.setStatus(StoreStatus.ACTIVE);
        store.setIsActive(true);
        store.setUpdatedAt(LocalDateTime.now());

        store = sellerStoreRepository.save(store);
        log.info("Successfully activated store {}", storeId);
        return store;
    }

    @Override
    public SellerStore deactivateStore(Long storeId, Long deactivatedBy) {
        log.info("Deactivating store {} by user {}", storeId, deactivatedBy);

        SellerStore store = getStoreById(storeId)
                .orElseThrow(() -> new IllegalArgumentException("Store not found: " + storeId));

        store.setIsActive(false);
        store.setUpdatedAt(LocalDateTime.now());

        store = sellerStoreRepository.save(store);
        log.info("Successfully deactivated store {}", storeId);
        return store;
    }

    @Override
    public void deleteStore(Long storeId, Long deletedBy) {
        log.info("Deleting store {} by user {}", storeId, deletedBy);

        SellerStore store = getStoreById(storeId)
                .orElseThrow(() -> new IllegalArgumentException("Store not found: " + storeId));

        // TODO: Check if store has pending orders before deletion

        store.setIsDeleted(true);
        store.setDeletedBy(deletedBy);
        store.setUpdatedAt(LocalDateTime.now());

        sellerStoreRepository.save(store);
        log.info("Successfully deleted store {}", storeId);
    }

    @Override
    @Transactional(readOnly = true)
    public boolean canCreateStore(Long userId, BigDecimal depositAmount) {
        // Check if user already has a store
        if (getStoreByOwnerId(userId).isPresent()) {
            return false;
        }

        // Check if deposit amount is sufficient
        BigDecimal minDeposit = getMinimumDepositAmount();
        if (depositAmount.compareTo(minDeposit) < 0) {
            return false;
        }

        // Check if user has sufficient wallet balance
        return walletService.hasSufficientFunds(userId, depositAmount);
    }

    @Override
    @Transactional(readOnly = true)
    public boolean canListProduct(Long storeId, BigDecimal productPrice) {
        return getStoreById(storeId)
                .map(store -> store.canListProduct(productPrice))
                .orElse(false);
    }

    @Override
    @Transactional(readOnly = true)
    public boolean isStoreNameAvailable(String storeName, Long excludeStoreId) {
        return !sellerStoreRepository.existsByStoreNameIgnoreCase(storeName, excludeStoreId);
    }

    @Override
    @Transactional(readOnly = true)
    public Map<String, Object> getStoreStatistics() {
        Map<String, Object> stats = new HashMap<>();
        
        stats.put("totalStores", sellerStoreRepository.count());
        stats.put("activeStores", sellerStoreRepository.countByStatus("active"));
        stats.put("verifiedStores", sellerStoreRepository.countVerifiedStores());
        stats.put("totalDeposits", sellerStoreRepository.calculateTotalDeposits());
        
        return stats;
    }

    @Override
    @Transactional(readOnly = true)
    public List<SellerStoreResponse> getTopPerformingStores(int limit) {
        Pageable pageable = PageRequest.of(0, limit);
        return sellerStoreRepository.findTopPerformingStores(pageable)
                .getContent()
                .stream()
                .map(SellerStoreResponse::fromEntity)
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public Page<SellerStoreResponse> getStoresPendingVerification(Pageable pageable) {
        return sellerStoreRepository.findPendingVerification(pageable)
                .map(SellerStoreResponse::fromEntity);
    }

    @Override
    public SellerStore updateStoreDeposit(Long storeId, BigDecimal newDepositAmount, Long updatedBy) {
        log.info("Updating deposit for store {} to {} by user {}", storeId, newDepositAmount, updatedBy);

        SellerStore store = getStoreById(storeId)
                .orElseThrow(() -> new IllegalArgumentException("Store not found: " + storeId));

        BigDecimal currentDeposit = store.getDepositAmount();
        BigDecimal difference = newDepositAmount.subtract(currentDeposit);

        // Get owner ID safely to avoid lazy loading issues
        Long ownerId = store.getOwnerUser().getId();

        if (difference.compareTo(BigDecimal.ZERO) > 0) {
            // Additional deposit required
            walletService.processStoreDeposit(ownerId, difference, storeId);
        } else if (difference.compareTo(BigDecimal.ZERO) < 0) {
            // Refund excess deposit
            walletService.refundStoreDeposit(ownerId, difference.abs(), storeId);
        }

        store.setDepositAmount(newDepositAmount);
        store.setMaxListingPrice(calculateMaxListingPrice(newDepositAmount));
        store.setUpdatedAt(LocalDateTime.now());

        store = sellerStoreRepository.save(store);
        log.info("Successfully updated deposit for store {}", storeId);
        return store;
    }

    @Override
    @Transactional(readOnly = true)
    public BigDecimal getMinimumDepositAmount() {
        return marketplaceProperties.getSeller().getMinimumDeposit();
    }

    @Override
    @Transactional(readOnly = true)
    public BigDecimal calculateMaxListingPrice(BigDecimal depositAmount) {
        if (depositAmount == null) {
            return BigDecimal.ZERO;
        }
        return depositAmount.divide(BigDecimal.TEN, 2, RoundingMode.DOWN);
    }

    @Override
    @Transactional(readOnly = true)
    public boolean isStoreOwner(Long userId, Long storeId) {
        return sellerStoreRepository.findByOwnerUserIdWithOwner(userId)
                .map(store -> store.getId().equals(storeId))
                .orElse(false);
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<Long> getStoreOwnerId(Long storeId) {
        return sellerStoreRepository.findById(storeId)
                .filter(store -> !store.isDeleted())
                .map(store -> store.getOwnerUser().getId());
    }

    @Override
    public SellerStore uploadStoreLogo(Long storeId, MultipartFile logoFile) {
        // TODO: Implement file upload logic
        throw new UnsupportedOperationException("File upload not implemented yet");
    }

    @Override
    public SellerStore removeStoreLogo(Long storeId) {
        SellerStore store = getStoreById(storeId)
                .orElseThrow(() -> new IllegalArgumentException("Store not found: " + storeId));

        store.setStoreLogoUrl(null);
        store.setUpdatedAt(LocalDateTime.now());

        return sellerStoreRepository.save(store);
    }
}
