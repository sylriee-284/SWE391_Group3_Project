package vn.group3.marketplace.service;

import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import lombok.RequiredArgsConstructor;
import vn.group3.marketplace.domain.entity.Role;
import vn.group3.marketplace.domain.entity.SellerStore;
import vn.group3.marketplace.domain.entity.User;
import vn.group3.marketplace.domain.enums.StoreStatus;
import vn.group3.marketplace.repository.RoleRepository;
import vn.group3.marketplace.repository.SellerStoreRepository;
import vn.group3.marketplace.repository.UserRepository;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
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

    @Transactional
    public boolean banStore(Long storeId) {
        var s = em.find(SellerStore.class, storeId);
        if (s == null)
            return false;
        if (s.getStatus() != StoreStatus.BANNED)
            s.setStatus(StoreStatus.BANNED);
        return true;
    }

    @PersistenceContext
    private EntityManager em;

    // ✅ LẤY DANH SÁCH STORE (đọc thôi, không cần transaction ghi)
    @Transactional(readOnly = true)
    public List<SellerStore> findAllStores() {
        return sellerStoreRepository.findAll(); // đủ cho JSP (lọc client-side)
    }

    // ✅ server-side filter cho trang Stores
    @Transactional(readOnly = true)
    public List<SellerStore> searchStores(
            Long id,
            String name,
            StoreStatus status,
            Long ownerId,
            LocalDate createdFrom,
            LocalDate createdTo) {
        StringBuilder jpql = new StringBuilder(
                "select distinct s from SellerStore s " +
                        "left join fetch s.owner " +
                        "where 1=1");
        Map<String, Object> p = new HashMap<>();

        if (id != null) {
            jpql.append(" and s.id = :id");
            p.put("id", id);
        }
        if (name != null && !name.isBlank()) {
            jpql.append(" and lower(s.storeName) like lower(concat('%', :name, '%'))");
            p.put("name", name);
        }
        if (status != null) {
            jpql.append(" and s.status = :status");
            p.put("status", status);
        }
        if (ownerId != null) {
            jpql.append(" and s.owner.id = :ownerId");
            p.put("ownerId", ownerId);
        }
        if (createdFrom != null) {
            jpql.append(" and s.createdAt >= :from");
            p.put("from", createdFrom.atStartOfDay());
        }
        if (createdTo != null) {
            jpql.append(" and s.createdAt < :to");
            p.put("to", createdTo.plusDays(1).atStartOfDay());
        }

        jpql.append(" order by s.id desc");

        var q = em.createQuery(jpql.toString(), SellerStore.class);
        p.forEach(q::setParameter);
        return q.getResultList();
    }

    @Transactional
    public void changeStatus(Long storeId, StoreStatus target) {
        if (target == null) {
            throw new IllegalArgumentException("Trạng thái không hợp lệ");
        }

        // Lấy store
        SellerStore s = sellerStoreRepository.findById(storeId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy store #" + storeId));

        // Không cần làm gì nếu trùng trạng thái
        if (s.getStatus() == target)
            return;

        // Điều hướng theo trạng thái
        switch (target) {
            case ACTIVE -> {
                // Dùng đúng flow kích hoạt của bạn (thêm SELLER role, v.v.)
                activateStore(storeId);
            }
            case INACTIVE, PENDING -> {
                s.setStatus(target);
                sellerStoreRepository.save(s);
            }
            case BANNED -> {
                // Không cho đổi sang BANNED bằng dropdown "Đổi trạng thái"
                // (nút Ban riêng sẽ gọi banStore(...))
                throw new IllegalArgumentException("Đổi sang BANNED không được phép ở đây. Vui lòng dùng nút Ban.");
            }
        }
    }
}