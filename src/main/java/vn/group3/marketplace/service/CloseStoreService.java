package vn.group3.marketplace.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import vn.group3.marketplace.domain.entity.SellerStore;
import vn.group3.marketplace.domain.entity.User;
import vn.group3.marketplace.domain.entity.WalletTransaction;
import vn.group3.marketplace.domain.enums.OrderStatus;
import vn.group3.marketplace.domain.enums.StoreStatus;
import vn.group3.marketplace.domain.enums.WalletTransactionStatus;
import vn.group3.marketplace.domain.enums.WalletTransactionType;
import vn.group3.marketplace.dto.CloseStoreConfirmRequestDTO;
import vn.group3.marketplace.dto.CloseStorePreviewDTO;
import vn.group3.marketplace.dto.CloseStoreResultDTO;
import vn.group3.marketplace.dto.CloseStoreValidationDTO;
import vn.group3.marketplace.repository.EscrowTransactionRepository;
import vn.group3.marketplace.repository.OrderRepository;
import vn.group3.marketplace.repository.ProductRepository;
import vn.group3.marketplace.repository.SellerStoreRepository;
import vn.group3.marketplace.repository.UserRepository;
import vn.group3.marketplace.repository.WalletTransactionRepository;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

@Service
public class CloseStoreService {

    private static final Logger logger = LoggerFactory.getLogger(CloseStoreService.class);

    @Autowired
    private SellerStoreRepository sellerStoreRepository;

    @Autowired
    private OrderRepository orderRepository;

    @Autowired
    private EscrowTransactionRepository escrowTransactionRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private WalletTransactionRepository walletTransactionRepository;

    @Autowired
    private ProductRepository productRepository;

    /**
     * Get close store preview data
     */
    public CloseStorePreviewDTO getClosePreview(Long storeId, User owner) {
        logger.info("Getting close preview for store {} by user {}", storeId, owner.getId());

        SellerStore store = sellerStoreRepository.findById(storeId)
                .orElseThrow(() -> new RuntimeException("Store not found with id: " + storeId));

        // Security check: verify ownership
        if (!store.getOwner().getId().equals(owner.getId())) {
            throw new RuntimeException("Unauthorized: You are not the owner of this store");
        }

        // Calculate open months
        int openMonths = calculateOpenMonths(store.getCreatedAt());

        // Count pending orders
        long pendingOrders = countPendingOrders(storeId);

        // Sum escrow held
        BigDecimal escrowHeld = sumEscrowHeld(storeId);

        // Format created date
        String createdAt = store.getCreatedAt().format(DateTimeFormatter.ISO_DATE_TIME);

        return CloseStorePreviewDTO.builder()
                .storeId(storeId)
                .storeName(store.getStoreName())
                .status(store.getStatus().name())
                .createdAt(createdAt)
                .feeModel(store.getFeeModel() != null ? store.getFeeModel().name() : "UNKNOWN")
                .depositAmount(store.getDepositAmount())
                .openMonths(openMonths)
                .pendingOrders(pendingOrders)
                .pendingRefunds(0L) // Future feature
                .escrowHeld(escrowHeld)
                .walletBalance(owner.getBalance())
                .build();
    }

    /**
     * Validate if store can be closed
     */
    public CloseStoreValidationDTO validateClose(Long storeId, User owner) {
        logger.info("Validating close store for store {} by user {}", storeId, owner.getId());

        CloseStorePreviewDTO preview = getClosePreview(storeId, owner);
        List<CloseStoreValidationDTO.ValidationError> errors = new ArrayList<>();

        // Rule 1: No pending orders
        if (preview.getPendingOrders() > 0) {
            errors.add(CloseStoreValidationDTO.ValidationError.builder()
                    .code("PENDING_ORDERS")
                    .message("You still have " + preview.getPendingOrders()
                            + " processing orders. Please complete them first.")
                    .link("/seller/orders?status=PENDING")
                    .build());
        }

        // Rule 2: No escrow held
        if (preview.getEscrowHeld().compareTo(BigDecimal.ZERO) > 0) {
            errors.add(CloseStoreValidationDTO.ValidationError.builder()
                    .code("ESCROW_HELD")
                    .message(
                            "You have " + preview.getEscrowHeld() + " VND held in escrow. Wait for orders to complete.")
                    .link("/seller/orders")
                    .build());
        }

        // Rule 3: Wallet balance must be non-negative
        if (preview.getWalletBalance().compareTo(BigDecimal.ZERO) < 0) {
            errors.add(CloseStoreValidationDTO.ValidationError.builder()
                    .code("NEGATIVE_WALLET")
                    .message("Your wallet balance is negative: " + preview.getWalletBalance()
                            + " VND. Please settle your debts.")
                    .link("/wallet")
                    .build());
        }

        // If there are errors, return failure
        if (!errors.isEmpty()) {
            return CloseStoreValidationDTO.builder()
                    .ok(false)
                    .errors(errors)
                    .build();
        }

        // Calculate refund
        BigDecimal refund = calculateRefund(preview);
        String rule = determineRule(preview);

        logger.info("Validation passed. Refund: {}, Rule: {}", refund, rule);

        return CloseStoreValidationDTO.builder()
                .ok(true)
                .ruleApplied(rule)
                .depositRefund(refund)
                .build();
    }

    /**
     * Confirm and close the store (TRANSACTIONAL + IDEMPOTENT)
     */
    @Transactional
    public CloseStoreResultDTO confirmClose(Long storeId, User owner, CloseStoreConfirmRequestDTO request) {
        logger.info("Confirming close store for store {} by user {}", storeId, owner.getId());

        SellerStore store = sellerStoreRepository.findById(storeId)
                .orElseThrow(() -> new RuntimeException("Store not found with id: " + storeId));

        // Security check
        if (!store.getOwner().getId().equals(owner.getId())) {
            throw new RuntimeException("Unauthorized: You are not the owner of this store");
        }

        // IDEMPOTENT CHECK: If already closed, return existing result
        if (store.getStatus() == StoreStatus.INACTIVE) {
            logger.info("Store {} is already INACTIVE. Returning idempotent result.", storeId);

            // Try to find the last deposit refund transaction
            BigDecimal lastRefund = store.getDepositAmount(); // Default to full deposit

            return CloseStoreResultDTO.builder()
                    .ok(true)
                    .status("INACTIVE")
                    .depositRefund(lastRefund)
                    .walletBalanceAfter(owner.getBalance())
                    .build();
        }

        // Re-validate before closing
        CloseStoreValidationDTO validation = validateClose(storeId, owner);
        if (!validation.isOk()) {
            throw new RuntimeException("Validation failed: Cannot close store with pending issues");
        }

        BigDecimal refund = validation.getDepositRefund();

        // Update user wallet balance using atomic increment to avoid race condition
        int updatedRows = userRepository.incrementBalance(owner.getId(), refund);
        if (updatedRows == 0) {
            throw new RuntimeException("Failed to update wallet balance for user: " + owner.getId());
        }

        // Refresh owner entity to get updated balance
        owner = userRepository.findById(owner.getId())
                .orElseThrow(() -> new RuntimeException("User not found after balance update"));

        logger.info("Updated wallet balance for user {} using atomic increment. New balance: {}",
                owner.getId(), owner.getBalance());

        // Create wallet transaction log
        WalletTransaction walletTx = WalletTransaction.builder()
                .user(owner)
                .type(WalletTransactionType.DEPOSIT_REFUND)
                .amount(refund)
                .note("Store deposit refund for: " + store.getStoreName() +
                        (request.getReason() != null ? " | Reason: " + request.getReason() : ""))
                .paymentStatus(WalletTransactionStatus.SUCCESS)
                .build();
        walletTransactionRepository.save(walletTx);

        logger.info("Created wallet transaction {} for deposit refund", walletTx.getId());

        // Deactivate all products of this store
        int deactivatedProductsCount = productRepository.deactivateAllProductsByStore(storeId);
        logger.info("Deactivated {} products for store {}", deactivatedProductsCount, storeId);

        // Update store status to INACTIVE
        store.setStatus(StoreStatus.INACTIVE);
        sellerStoreRepository.save(store);

        logger.info("Store {} status updated to INACTIVE", storeId);

        return CloseStoreResultDTO.builder()
                .ok(true)
                .status("INACTIVE")
                .depositRefund(refund)
                .walletBalanceAfter(owner.getBalance())
                .build();
    }

    /**
     * Get close result (for result page)
     */
    public CloseStoreResultDTO getCloseResult(Long storeId, User owner) {
        logger.info("Getting close result for store {} by user {}", storeId, owner.getId());

        SellerStore store = sellerStoreRepository.findById(storeId)
                .orElseThrow(() -> new RuntimeException("Store not found with id: " + storeId));

        if (!store.getOwner().getId().equals(owner.getId())) {
            throw new RuntimeException("Unauthorized: You are not the owner of this store");
        }

        // Find the deposit refund transaction
        BigDecimal refundAmount = store.getDepositAmount(); // Default

        return CloseStoreResultDTO.builder()
                .ok(true)
                .status(store.getStatus().name())
                .depositRefund(refundAmount)
                .walletBalanceAfter(owner.getBalance())
                .build();
    }

    // ==================== HELPER METHODS ====================

    /**
     * Calculate number of months since store creation
     */
    private int calculateOpenMonths(LocalDateTime createdAt) {
        return (int) ChronoUnit.MONTHS.between(createdAt, LocalDateTime.now());
    }

    /**
     * Count pending orders (PENDING, PENDING_PAYMENT, PAYMENT_PROCESSING, PAID,
     * CONFIRMED)
     */
    private long countPendingOrders(Long storeId) {
        List<OrderStatus> pendingStatuses = Arrays.asList(
                OrderStatus.PENDING,
                OrderStatus.PENDING_PAYMENT,
                OrderStatus.PAYMENT_PROCESSING,
                OrderStatus.PAID,
                OrderStatus.CONFIRMED);
        return orderRepository.countBySellerStoreIdAndStatusIn(storeId, pendingStatuses);
    }

    /**
     * Sum total amount held in escrow for this store
     */
    private BigDecimal sumEscrowHeld(Long storeId) {
        return escrowTransactionRepository.sumHeldAmountByStore(storeId)
                .orElse(BigDecimal.ZERO);
    }

    /**
     * Calculate deposit refund based on business rules
     */
    private BigDecimal calculateRefund(CloseStorePreviewDTO preview) {
        String feeModel = preview.getFeeModel();
        int openMonths = preview.getOpenMonths();
        BigDecimal deposit = preview.getDepositAmount();

        // Rule 1: NO_FEE -> 50% refund
        if ("NO_FEE".equalsIgnoreCase(feeModel)) {
            return deposit.multiply(new BigDecimal("0.50"));
        }

        // Rule 2: Standard fee model
        if (openMonths >= 12) {
            // >= 12 months -> 100% refund
            return deposit;
        } else {
            // < 12 months -> 70% refund
            return deposit.multiply(new BigDecimal("0.70"));
        }
    }

    /**
     * Determine which rule was applied
     */
    private String determineRule(CloseStorePreviewDTO preview) {
        String feeModel = preview.getFeeModel();
        int openMonths = preview.getOpenMonths();

        if ("NO_FEE".equalsIgnoreCase(feeModel)) {
            return "NO_FEE";
        }

        return openMonths >= 12 ? "GE_12M" : "LT_12M";
    }
}
