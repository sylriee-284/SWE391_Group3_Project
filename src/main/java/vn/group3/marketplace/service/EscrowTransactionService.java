package vn.group3.marketplace.service;

import org.springframework.scheduling.TaskScheduler;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.context.annotation.Lazy;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import vn.group3.marketplace.repository.EscrowTransactionRepository;
import vn.group3.marketplace.repository.WalletTransactionRepository;
import vn.group3.marketplace.repository.UserRepository;
import vn.group3.marketplace.domain.entity.EscrowTransaction;
import vn.group3.marketplace.domain.enums.EscrowStatus;
import vn.group3.marketplace.domain.enums.WalletTransactionStatus;
import vn.group3.marketplace.domain.enums.WalletTransactionType;
import vn.group3.marketplace.domain.entity.Order;
import vn.group3.marketplace.domain.entity.User;
import vn.group3.marketplace.domain.entity.WalletTransaction;

import java.time.Instant;
import java.time.LocalDateTime;
import java.util.concurrent.CompletableFuture;

import org.springframework.transaction.annotation.Transactional;

@Service
public class EscrowTransactionService {

    private static final Logger logger = LoggerFactory.getLogger(EscrowTransactionService.class);

    private final WalletTransactionRepository walletTransactionRepository;
    private final EscrowTransactionRepository escrowTransactionRepository;
    private final UserRepository userRepository;
    private final SystemSettingService systemSettingService;
    private final TaskScheduler taskScheduler;
    private final EscrowTransactionService self;

    public EscrowTransactionService(EscrowTransactionRepository escrowTransactionRepository,
            SystemSettingService systemSettingService, TaskScheduler taskScheduler,
            WalletTransactionRepository walletTransactionRepository,
            UserRepository userRepository,
            @Lazy EscrowTransactionService self) {
        this.escrowTransactionRepository = escrowTransactionRepository;
        this.systemSettingService = systemSettingService;
        this.taskScheduler = taskScheduler;
        this.walletTransactionRepository = walletTransactionRepository;
        this.userRepository = userRepository;
        this.self = self;
    }

    @Transactional
    public void createEscrowTransaction(Order order) {
        try {
            String holdMinutesStr = systemSettingService.getSettingValue("escrow.default_hold_minutes", "1");
            int holdMinutes = Integer.parseInt(holdMinutesStr);

            EscrowTransaction escrowTransaction = EscrowTransaction.builder()
                    .order(order)
                    .amount(order.getTotalAmount())
                    .status(EscrowStatus.HELD)
                    .holdUntil(LocalDateTime.now().plusMinutes(holdMinutes))
                    .build();

            escrowTransactionRepository.save(escrowTransaction);
            logger.info("Escrow transaction created for order: {} with hold until: {}",
                    order.getId(), escrowTransaction.getHoldUntil());
        } catch (Exception e) {
            logger.error("Failed to create escrow transaction for order: {}", order.getId(), e);
            // Don't throw to avoid breaking order process - just log the error
        }
    }

    @Async("escrowTaskExecutor")
    public CompletableFuture<Void> scheduleEscrowTransactionRelease(Order order) {
        try {
            String holdMinutesStr = systemSettingService.getSettingValue("escrow.default_hold_minutes", "1");
            int holdMinutes = Integer.parseInt(holdMinutesStr);

            Instant releaseTime = Instant.now().plusSeconds((long) holdMinutes * 60);
            taskScheduler.schedule(() -> {
                try {
                    self.releasePaymentToSeller(order);
                } catch (Exception e) {
                    logger.error("Failed to release payment for order: {}", order.getId(), e);
                }
            }, releaseTime);

            logger.info("Escrow release scheduled for order: {} at {}", order.getId(), releaseTime);
            return CompletableFuture.completedFuture(null);
        } catch (Exception e) {
            logger.error("Failed to schedule escrow release for order: {}", order.getId(), e);
            return CompletableFuture.failedFuture(e);
        }
    }

    @Async("escrowTaskExecutor")
    @Transactional
    public CompletableFuture<Void> releasePaymentToSeller(Order order) {
        try {
            logger.info("Starting payment release process for order: {}", order.getId());

            // 1. Cập nhật EscrowTransaction status
            EscrowTransaction escrowTransaction = escrowTransactionRepository.findByOrder(order)
                    .orElseThrow(
                            () -> new RuntimeException("Escrow transaction not found for order: " + order.getId()));

            escrowTransaction.setStatus(EscrowStatus.RELEASED);
            escrowTransaction.setReleasedAt(LocalDateTime.now());
            escrowTransactionRepository.save(escrowTransaction);

            // 2. Validate seller store and owner
            if (order.getSellerStore() == null) {
                throw new IllegalArgumentException("Seller store is null for order: " + order.getId());
            }

            User sellerProxy = order.getSellerStore().getOwner();
            if (sellerProxy == null) {
                throw new IllegalArgumentException("Seller is null for order: " + order.getId());
            }

            // 3. Load fresh User entity from database to avoid LazyInitializationException
            User seller = userRepository.findById(sellerProxy.getId())
                    .orElseThrow(
                            () -> new IllegalArgumentException("Seller not found with id: " + sellerProxy.getId()));

            // 4. Tạo WalletTransaction để cập nhật balance seller
            WalletTransaction walletTransaction = WalletTransaction.builder()
                    .user(seller)
                    .amount(order.getTotalAmount())
                    .type(WalletTransactionType.ORDER_PAYMENT)
                    .refOrder(order)
                    .paymentStatus(WalletTransactionStatus.RELEASED)
                    .note("Payment released from escrow for order #" + order.getId())
                    .build();
            walletTransactionRepository.save(walletTransaction);

            // 5. Cập nhật balance của seller
            seller.setBalance(seller.getBalance().add(order.getTotalAmount()));
            userRepository.save(seller);

            logger.info("Payment release completed successfully for order: {} to seller: {}",
                    order.getId(), seller.getId());
            return CompletableFuture.completedFuture(null);
        } catch (Exception e) {
            logger.error("Failed to release payment for order: {}", order.getId(), e);
            return CompletableFuture.failedFuture(e);
        }
    }

    @Async("escrowTaskExecutor")
    public CompletableFuture<Void> processEscrowTransactionAsync(Order order) {
        try {
            logger.info("Processing escrow transaction asynchronously for order: {}", order.getId());

            // Tạo escrow transaction
            self.createEscrowTransaction(order);

            // Lên lịch release payment
            self.scheduleEscrowTransactionRelease(order);

            logger.info("Escrow transaction processing completed for order: {}", order.getId());
            return CompletableFuture.completedFuture(null);
        } catch (Exception e) {
            logger.error("Failed to process escrow transaction for order: {}", order.getId(), e);
            return CompletableFuture.failedFuture(e);
        }
    }
}
