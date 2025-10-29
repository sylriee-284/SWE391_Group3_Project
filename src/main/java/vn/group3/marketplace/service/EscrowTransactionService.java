package vn.group3.marketplace.service;

import org.springframework.scheduling.annotation.Async;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.context.annotation.Lazy;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import vn.group3.marketplace.repository.EscrowTransactionRepository;
import vn.group3.marketplace.repository.SellerStoreRepository;
import vn.group3.marketplace.repository.WalletTransactionRepository;
import vn.group3.marketplace.repository.UserRepository;
import vn.group3.marketplace.domain.entity.EscrowTransaction;
import vn.group3.marketplace.domain.enums.EscrowStatus;
import vn.group3.marketplace.domain.enums.SellerStoresType;
import vn.group3.marketplace.domain.enums.WalletTransactionStatus;
import vn.group3.marketplace.domain.enums.WalletTransactionType;
import vn.group3.marketplace.domain.entity.Order;
import vn.group3.marketplace.domain.entity.SellerStore;
import vn.group3.marketplace.domain.entity.User;
import vn.group3.marketplace.domain.entity.WalletTransaction;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.concurrent.CompletableFuture;

import org.springframework.transaction.annotation.Transactional;

@Service
public class EscrowTransactionService {

    private final SellerStoreRepository sellerStoreRepository;

    private static final Logger logger = LoggerFactory.getLogger(EscrowTransactionService.class);

    private final WalletTransactionRepository walletTransactionRepository;
    private final EscrowTransactionRepository escrowTransactionRepository;
    private final UserRepository userRepository;
    private final WalletTransactionQueueService walletTransactionQueueService;
    private final SystemSettingService systemSettingService;
    private final EscrowTransactionService self;

    public EscrowTransactionService(EscrowTransactionRepository escrowTransactionRepository,
            SystemSettingService systemSettingService,
            WalletTransactionRepository walletTransactionRepository,
            UserRepository userRepository,
            @Lazy EscrowTransactionService self, 
            SellerStoreRepository sellerStoreRepository,
            WalletTransactionQueueService walletTransactionQueueService) {
        this.escrowTransactionRepository = escrowTransactionRepository;
        this.systemSettingService = systemSettingService;
        this.walletTransactionRepository = walletTransactionRepository;
        this.userRepository = userRepository;
        this.self = self;
        this.sellerStoreRepository = sellerStoreRepository;
        this.walletTransactionQueueService = walletTransactionQueueService;
    }

    @Transactional
    public void createEscrowTransaction(Order order) {
        try {
            String holdHoursStr = systemSettingService.getSettingValue("escrow.default_hold_hours", "1");
            double holdHours = Double.parseDouble(holdHoursStr);

            SellerStore sellerStore = order.getSellerStore();
            if (sellerStore.getFeeModel().equals(SellerStoresType.PERCENTAGE)) {
                // Calculate fee based on order total
                BigDecimal minOrderWithFreeFee = new BigDecimal(
                        systemSettingService.getSettingValue("fee.min_order_with_free_fee", "30000"));
                BigDecimal feeAmount = calculateFee(order);
                // If order total is less than min order with free fee, set fee amount to 0
                if (order.getTotalAmount().compareTo(minOrderWithFreeFee) <= 0) {
                    feeAmount = BigDecimal.ZERO;
                }
                BigDecimal sellerAmount = order.getTotalAmount().subtract(feeAmount);

                // Create single escrow transaction with both seller and admin amounts
                EscrowTransaction escrowTransaction = EscrowTransaction.builder()
                        .order(order)
                        .sellerStore(sellerStore)  // Add this line to set sellerStore
                        .totalAmount(order.getTotalAmount()) // Total amount
                        .sellerAmount(sellerAmount) // Amount for seller
                        .adminAmount(feeAmount) // Amount for admin
                        .status(EscrowStatus.HELD)
                        .holdUntil(LocalDateTime.now().plusSeconds((long) (holdHours * 3600)))
                        .build();
                escrowTransaction.setCreatedBy(0L);
                escrowTransactionRepository.save(escrowTransaction);

                // Update seller store escrow amount through queue (no need to wait)
                walletTransactionQueueService.enqueueUpdateSellerStoreEscrowAmount(
                    sellerStore.getId(), 
                    sellerAmount,
                    true // true for add, false for subtract
                );

                logger.info("Escrow transaction created for order: {} with total amount: {}",
                        order.getId(), order.getTotalAmount());
                logger.info("Escrow transaction created for order: {} with seller amount: {}",
                        order.getId(), sellerAmount);
                logger.info("Escrow transaction created for order: {} with admin amount: {}",
                        order.getId(), feeAmount);
                logger.info("Escrow transaction created for order: {} with hold until: {}",
                        order.getId(), escrowTransaction.getHoldUntil());
            } else {
                EscrowTransaction escrowTransaction = EscrowTransaction.builder()
                        .order(order)
                        .sellerStore(sellerStore)  // Add this line to set sellerStore
                        .totalAmount(order.getTotalAmount())
                        .sellerAmount(order.getTotalAmount()) // Full amount goes to seller
                        .adminAmount(BigDecimal.ZERO) // No admin fee
                        .status(EscrowStatus.HELD)
                        .holdUntil(LocalDateTime.now().plusSeconds((long) (holdHours * 3600)))
                        .build();
                escrowTransaction.setCreatedBy(0L);
                escrowTransactionRepository.save(escrowTransaction);

                // Update seller store escrow amount through queue (no need to wait)
                walletTransactionQueueService.enqueueUpdateSellerStoreEscrowAmount(
                    sellerStore.getId(), 
                    order.getTotalAmount(),
                    true // true for add, false for subtract
                );

                logger.info("Escrow transaction created for order: {} with hold until: {}",
                        order.getId(), escrowTransaction.getHoldUntil());
            }

        } catch (Exception e) {
            logger.error("Failed to create escrow transaction for order: {}", order.getId(), e);
            // Don't throw to avoid breaking order process - just log the error
        }
    }

    private BigDecimal calculateFee(Order order) {
        BigDecimal threshold = new BigDecimal("100000");
        SellerStore sellerStore = order.getSellerStore();

        if (order.getTotalAmount().compareTo(threshold) <= 0) {
            // Use fixed fee for orders <= 100000
            String fixedFeeStr = systemSettingService.getSettingValue("fee.fixed_fee", "5000");
            return new BigDecimal(fixedFeeStr);
        } else {
            // Use percentage fee for orders > 100000
            String percentageFeeStr = sellerStore.getFeePercentageRate().toString();
            BigDecimal percentageFee = new BigDecimal(percentageFeeStr);
            return order.getTotalAmount().multiply(percentageFee).divide(new BigDecimal("100"));
        }
    }

    @Scheduled(fixedDelayString = "#{@escrowScanIntervalHours}")
    @Transactional
    public void scheduleEscrowTransactionRelease() {
        try {
            logger.info("Starting scheduled escrow transaction scan...");

            // Get all escrow transactions that are ready to be released
            List<EscrowTransaction> transactionsToRelease = escrowTransactionRepository
                    .findByStatusAndHoldUntilBefore(EscrowStatus.HELD, LocalDateTime.now());

            if (transactionsToRelease.isEmpty()) {
                logger.info("No escrow transactions ready for release");
                return;
            }

            logger.info("Found {} escrow transaction(s) ready for release", transactionsToRelease.size());

            // Release each transaction
            for (EscrowTransaction escrowTransaction : transactionsToRelease) {
                try {
                    Order order = escrowTransaction.getOrder();
                    logger.info("Releasing escrow for order: {}", order.getId());
                    self.releasePaymentFromEscrow(order).get();
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                    logger.error("Thread interrupted while releasing escrow transaction: {}", escrowTransaction.getId(),
                            e);
                } catch (Exception e) {
                    logger.error("Failed to release escrow transaction: {}", escrowTransaction.getId(), e);
                }
            }

            logger.info("Escrow transaction scan completed");
        } catch (Exception e) {
            logger.error("Error during escrow transaction scan", e);
        }
    }

    @Async("escrowTaskExecutor")
    @Transactional
    public CompletableFuture<Void> releasePaymentFromEscrow(Order order) {
        // Get admin default wallet id from system setting
        // (wallet.admin_default_receive_commission)
        Long adminDefaultWalletId = Long
                .parseLong(systemSettingService.getSettingValue("wallet.admin_default_receive_commission", "32"));
        try {
            logger.info("Starting payment release process for order: {}", order.getId());

            // 1. Update EscrowTransaction status
            EscrowTransaction escrowTransaction = escrowTransactionRepository.findByOrder(order)
                    .orElseThrow(
                            () -> new RuntimeException("Escrow transaction not found for order: " + order.getId()));

            escrowTransaction.setStatus(EscrowStatus.RELEASED);
            escrowTransaction.setReleasedAt(LocalDateTime.now());
            escrowTransactionRepository.save(escrowTransaction);

            // 2. Validate seller owner
            User sellerProxy = order.getSellerStore().getOwner();
            if (sellerProxy == null) {
                throw new IllegalArgumentException("Seller is null for order: " + order.getId());
            }
            Long sellerId = sellerProxy.getId();

            // 3. Create User entities for wallet transactions
            User seller = userRepository.getReferenceById(sellerId);
            User admin = userRepository.getReferenceById(adminDefaultWalletId);

            // 4. Get amounts from escrow transaction
            BigDecimal sellerAmount = escrowTransaction.getSellerAmount();
            BigDecimal adminAmount = escrowTransaction.getAdminAmount();

            // 5. Create WalletTransaction to update seller balance
            String storeName = order.getSellerStore().getStoreName();
            WalletTransaction walletTransaction = WalletTransaction.builder()
                    .user(seller)
                    .amount(sellerAmount)
                    .type(WalletTransactionType.ORDER_RELEASE)
                    .refOrder(order)
                    .paymentStatus(WalletTransactionStatus.RELEASED)
                    .note("Payment released from escrow for order #" + order.getId() + " to seller " + storeName)
                    .paymentRef(order.getId().toString())
                    .paymentMethod("INTERNAL")
                    .build();
            walletTransaction.setCreatedBy(0L);
            walletTransactionRepository.save(walletTransaction);

            // 6. Create WalletTransaction to update admin balance
            if (adminAmount.compareTo(BigDecimal.ZERO) > 0) {
                WalletTransaction adminWalletTransaction = WalletTransaction.builder()
                        .user(admin)
                        .amount(adminAmount)
                        .type(WalletTransactionType.ADMIN_COMMISSION_FEE)
                        .refOrder(order)
                        .paymentStatus(WalletTransactionStatus.RELEASED)
                        .note("Admin commission fee released for order #" + order.getId())
                        .paymentRef(order.getId().toString())
                        .paymentMethod("INTERNAL")
                        .build();
                adminWalletTransaction.setCreatedBy(0L);
                walletTransactionRepository.save(adminWalletTransaction);
            }

            // 7. Enqueue add money to seller through queue (no need to wait)
            walletTransactionQueueService.enqueueAddMoneyToSeller(sellerId, sellerAmount, order.getId());

            // 8. Enqueue add money to admin through queue (no need to wait)
            if (adminAmount.compareTo(BigDecimal.ZERO) > 0) {
                walletTransactionQueueService.enqueueAddMoneyToSeller(admin.getId(), adminAmount, order.getId());
            }
            
            logger.info("Enqueued balance update for seller {} amount {}", sellerId, sellerAmount);
            logger.info("Enqueued balance update for admin {} amount {}", admin.getId(), adminAmount);

            // 9. Update escrow amount of seller store
            SellerStore sellerStore = order.getSellerStore();
            sellerStore.setEscrowAmount(sellerStore.getEscrowAmount().subtract(sellerAmount));
            sellerStoreRepository.save(sellerStore);

            logger.info("Payment release completed successfully for order: {} to seller: {}",
                    order.getId(), sellerId);
            logger.info("Payment release completed successfully for order: {} to admin: {}",
                    order.getId(), admin.getId());
            return CompletableFuture.completedFuture(null);
        } catch (Exception e) {
            logger.error("Failed to release payment for order: {}", order.getId(), e);
            return CompletableFuture.failedFuture(e);
        }
    }

    // OrderProcess
    @Async("escrowTaskExecutor")
    public CompletableFuture<Void> processEscrowTransactionAsync(Order order) {
        try {
            logger.info("Processing escrow transaction asynchronously for order: {}", order.getId());

            // Create escrow transaction
            self.createEscrowTransaction(order);

            // Payment release will be handled automatically by the scheduled task
            logger.info("Escrow transaction created for order: {}. Release will be handled by scheduled task.",
                    order.getId());

            logger.info("Escrow transaction processing completed for order: {}", order.getId());
            return CompletableFuture.completedFuture(null);
        } catch (Exception e) {
            logger.error("Failed to process escrow transaction for order: {}", order.getId(), e);
            return CompletableFuture.failedFuture(e);
        }
    }
}
