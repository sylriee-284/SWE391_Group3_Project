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

import java.math.BigDecimal;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class SellerStoreService {

	private final SellerStoreRepository sellerStoreRepository;
	private final UserRepository userRepository;
	private final RoleRepository roleRepository;
	private final WalletTransactionQueueService walletTransactionQueueService;
	private final SystemSettingService systemSettingService;

	/**
	 * Check if user already has a store
	 */
	public boolean hasExistingStore(User owner) {
		if (owner == null)
			return false;
		return sellerStoreRepository.findById(owner.getSellerStore() != null ? owner.getSellerStore().getId() : -1L)
				.isPresent();
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

		if (owner.getBalance().compareTo(depositAmount) < 0) {
			throw new IllegalArgumentException("Số dư không đủ để ký quỹ");
		}

		// Add SELLER role if present
		Role sellerRole = roleRepository.findByCode("SELLER").orElse(null);
		if (sellerRole != null) {
			owner.getRoles().add(sellerRole);
			userRepository.save(owner);
		}

		// Get max listing price rate from system settings
		Double maxListingPriceRate = systemSettingService.getDoubleValue("listing.max_listing_price_rate", 0.1);

		store.setStatus(StoreStatus.INACTIVE);
		store.setMaxListingPrice(depositAmount.multiply(BigDecimal.valueOf(maxListingPriceRate)));

		SellerStore saved = sellerStoreRepository.save(store);

		// Enqueue deposit payment using paymentRef createdShop{storeId}
		String paymentRef = "createdShop" + saved.getId();
		walletTransactionQueueService.enqueuePurchasePayment(owner.getId(), depositAmount, paymentRef);

		return saved;
	}

	@Transactional
	public void activateStore(Long storeId) {
		SellerStore store = sellerStoreRepository.findById(storeId)
				.orElseThrow(() -> new RuntimeException("Store not found with id: " + storeId));
		store.setStatus(StoreStatus.ACTIVE);
		sellerStoreRepository.save(store);
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
		return systemSettingService.getDoubleValue("fee.platform_rate", 0.1);
	}
}
