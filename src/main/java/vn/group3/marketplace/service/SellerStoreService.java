package vn.group3.marketplace.service;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import lombok.RequiredArgsConstructor;
import vn.group3.marketplace.domain.entity.Role;
import vn.group3.marketplace.domain.entity.SellerStore;
import vn.group3.marketplace.domain.entity.User;
import vn.group3.marketplace.domain.enums.StoreStatus;
import vn.group3.marketplace.repository.RoleRepository;
import vn.group3.marketplace.repository.SellerStoreRepository;
import vn.group3.marketplace.repository.UserRepository;
import vn.group3.marketplace.repository.EscrowTransactionRepository;
import vn.group3.marketplace.domain.enums.EscrowStatus;

import java.math.BigDecimal;
import java.util.Optional;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Service
@RequiredArgsConstructor
public class SellerStoreService {
    
    private static final Logger logger = LoggerFactory.getLogger(SellerStoreService.class);

	private final SellerStoreRepository sellerStoreRepository;
	private final UserRepository userRepository;

    /**
     * Cập nhật escrow amount cho seller store
     * @param sellerStoreId ID của seller store
     * @param amount Số tiền cần thay đổi
     * @param isAdd true nếu cộng thêm, false nếu trừ đi
     */
    @Transactional
    public void updateEscrowAmount(Long sellerStoreId, BigDecimal amount, boolean isAdd) {
        try {
            sellerStoreRepository.updateEscrowAmount(sellerStoreId, amount, isAdd);
            logger.info("Updated escrow amount for store {}: {} {}", 
                sellerStoreId, 
                isAdd ? "+" : "-", 
                amount);
        } catch (Exception e) {
            logger.error("Failed to update escrow amount for store {}", sellerStoreId, e);
            throw e;
        }
    }
	private final RoleRepository roleRepository;
	private final WalletTransactionQueueService walletTransactionQueueService;
	private final SystemSettingService systemSettingService;
	private final EscrowTransactionRepository escrowTransactionRepository;

	/**
	 * Check if user has an active store
	 */
	public boolean hasActiveStore(User owner) {
		if (owner == null || owner.getSellerStore() == null)
			return false;
		return sellerStoreRepository.findById(owner.getSellerStore().getId())
				.map(store -> store.getStatus() == StoreStatus.ACTIVE)
				.orElse(false);
	}

	/**
	 * Check if user has any store (active or inactive)
	 */
	public boolean hasExistingStore(User owner) {
		if (owner == null)
			return false;
		return sellerStoreRepository.findById(owner.getSellerStore() != null ? owner.getSellerStore().getId() : -1L)
				.isPresent();
	}

	/**
	 * Find inactive store owned by user
	 */
	public SellerStore findInactiveStoreByOwner(User owner) {
		if (owner == null || owner.getSellerStore() == null)
			return null;
		return sellerStoreRepository.findById(owner.getSellerStore().getId())
				.filter(store -> store.getStatus() == StoreStatus.INACTIVE)
				.orElse(null);
	}

	/**
	 * Find pending store owned by user (waiting for activation/payment)
	 */
	public SellerStore findPendingStoreByOwner(User owner) {
		if (owner == null || owner.getSellerStore() == null)
			return null;
		return sellerStoreRepository.findById(owner.getSellerStore().getId())
				.filter(store -> store.getStatus() == StoreStatus.PENDING)
				.orElse(null);
	}

	/**
	 * Find any non-active store (PENDING or INACTIVE) owned by user
	 */
	public SellerStore findNonActiveStoreByOwner(User owner) {
		if (owner == null || owner.getSellerStore() == null)
			return null;
		return sellerStoreRepository.findById(owner.getSellerStore().getId())
				.filter(store -> store.getStatus() == StoreStatus.PENDING || store.getStatus() == StoreStatus.INACTIVE)
				.orElse(null);
	}

	public boolean isStoreNameExists(String storeName) {
		return sellerStoreRepository.findAll().stream()
				.anyMatch(s -> s.getStoreName().equalsIgnoreCase(storeName));
	}

	/**
	 * Create new seller store with initial INACTIVE status and enqueue deposit
	 * processing
	 */
	@Transactional
	public SellerStore createStore(SellerStore store) {
		User owner = store.getOwner();
		BigDecimal depositAmount = store.getDepositAmount();

		if (depositAmount == null) {
			throw new IllegalArgumentException("Số tiền ký quỹ không được rỗng");
		}

		// Get min deposit amount from system settings
		Double minDepositAmount = systemSettingService.getDoubleValue("min_deposit_amount", 5000000.0);
		BigDecimal minDeposit = BigDecimal.valueOf(minDepositAmount);

		// Basic validations
		if (depositAmount.compareTo(minDeposit) < 0) {
			throw new IllegalArgumentException(
					"Số tiền ký quỹ phải từ " + String.format("%,.0f", minDepositAmount) + " VNĐ trở lên");
		}

		// Get max listing price rate from system settings
		Double maxListingPriceRate = systemSettingService.getDoubleValue("listing.max_listing_price_rate", 0.1);

		store.setStatus(StoreStatus.PENDING);
		store.setMaxListingPrice(depositAmount.multiply(BigDecimal.valueOf(maxListingPriceRate)));

		SellerStore saved = sellerStoreRepository.save(store);

		// DO NOT enqueue payment immediately - user will manually activate later
		// Payment will be enqueued when user clicks activate button

		return saved;
	}

	@Transactional
	public void activateStore(Long storeId) {
		// Find store and validate
		SellerStore store = sellerStoreRepository.findById(storeId)
				.orElseThrow(() -> new RuntimeException("Store not found with id: " + storeId));

		// Activate store
		store.setStatus(StoreStatus.ACTIVE);
		sellerStoreRepository.save(store);

		// Get store owner
		User owner = store.getOwner();
		if (owner == null) {
			throw new RuntimeException("Store owner not found for store id: " + storeId);
		}

		try {
			// Add SELLER role to owner
			Role sellerRole = roleRepository.findByCode("SELLER")
					.orElseThrow(() -> new RuntimeException("SELLER role not found"));

			if (owner.getRoles().stream().noneMatch(r -> "SELLER".equals(r.getCode()))) {
				owner.getRoles().add(sellerRole);
				userRepository.save(owner);
			}
		} catch (Exception e) {
			// Log error but don't prevent store activation
			throw new RuntimeException("Failed to add SELLER role to user: " + owner.getUsername(), e);
		}
	}

	public Optional<SellerStore> findById(Long id) {
		return sellerStoreRepository.findById(id);
	}

	/**
	 * Get minimum deposit amount from system settings
	 */
	public BigDecimal getMinDepositAmount() {
		Double minDepositAmount = systemSettingService.getDoubleValue("min_deposit_amount", 5000000.0);
		return BigDecimal.valueOf(minDepositAmount);
	}

	/**
	 * Get max listing price rate from system settings
	 */
	public Double getMaxListingPriceRate() {
		return systemSettingService.getDoubleValue("listing.max_listing_price_rate", 0.1);
	}

	/**
	 * Get platform fee rate from system settings
	 */
	public Double getPlatformFeeRate() {
		return systemSettingService.getDoubleValue("fee.fee.percentage_fee", 3.0);
	}

	/**
	 * Get total deposit amount being held for active stores owned by user
	 * Returns the sum of all deposit amounts from ACTIVE stores
	 */
	public BigDecimal getTotalDepositHeld(User owner) {
		if (owner == null || owner.getSellerStore() == null) {
			return BigDecimal.ZERO;
		}
		
		return sellerStoreRepository.findById(owner.getSellerStore().getId())
				.filter(store -> store.getStatus() == StoreStatus.ACTIVE)
				.map(SellerStore::getDepositAmount)
				.orElse(BigDecimal.ZERO);
	}

	/**
	 * Get total escrow amount being held for active stores owned by user
	 * Returns the sum of all escrow amounts from ACTIVE stores
	 */
	public BigDecimal getTotalEscrowHeld(User owner) {
		if (owner == null || owner.getSellerStore() == null) {
			logger.debug("getTotalEscrowHeld: owner or store is null");
			return BigDecimal.ZERO;
		}

		return sellerStoreRepository.findById(owner.getSellerStore().getId())
				.filter(store -> store.getStatus() == StoreStatus.ACTIVE)
				.map(store -> {
					logger.debug("getTotalEscrowHeld: calculating for store id={}", store.getId());
					java.math.BigDecimal sum = escrowTransactionRepository
							.sumAmountBySellerStoreAndStatus(store, EscrowStatus.HELD);
					logger.debug("getTotalEscrowHeld: sum={}", sum);
					return sum == null ? BigDecimal.ZERO : sum;
				})
				.orElse(BigDecimal.ZERO);
	}


}
