package vn.group3.marketplace.service;

import org.springframework.scheduling.TaskScheduler;
import org.springframework.stereotype.Service;

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

import org.springframework.transaction.annotation.Transactional;

@Service
public class EscrowTransactionService {

    private final WalletTransactionRepository walletTransactionRepository;

    private final EscrowTransactionRepository escrowTransactionRepository;

    private final UserRepository userRepository;

    private final SystemSettingService systemSettingService;

    private final TaskScheduler taskScheduler;

    private final OrderService orderService;

    private final WalletTransactionService walletTransactionService;

    public EscrowTransactionService(EscrowTransactionRepository escrowTransactionRepository,
            SystemSettingService systemSettingService, TaskScheduler taskScheduler, OrderService orderService,
            WalletTransactionService walletTransactionService,
            WalletTransactionRepository walletTransactionRepository,
            UserRepository userRepository) {
        this.escrowTransactionRepository = escrowTransactionRepository;
        this.systemSettingService = systemSettingService;
        this.taskScheduler = taskScheduler;
        this.orderService = orderService;
        this.walletTransactionService = walletTransactionService;
        this.walletTransactionRepository = walletTransactionRepository;
        this.userRepository = userRepository;
    }

    @Transactional
    public void createEscrowTransaction(Order order) {
        EscrowTransaction escrowTransaction = EscrowTransaction.builder()
                .order(order)
                .amount(order.getTotalAmount())
                .status(EscrowStatus.HELD)
                .holdUntil(LocalDateTime.now().plusMinutes(
                        Integer.parseInt(systemSettingService.getSettingValue("escrow.default_hold_minutes", "1"))))
                .build();
        escrowTransactionRepository.save(escrowTransaction);
    }

    public void scheduleEscrowTransactionRelease(Order order) {
        Instant releaseTime = Instant.now().plusSeconds(
                (long) Integer.parseInt(systemSettingService.getSettingValue("escrow.default_hold_minutes", "1")) * 60);

        taskScheduler.schedule(() -> {
            // Tạo proxy để gọi method transactional
            EscrowTransactionService.this.releasePaymentToSeller(order);
        }, releaseTime);
    }

    @Transactional
    public void releasePaymentToSeller(Order order) {
        // 1. Cập nhật EscrowTransaction status
        EscrowTransaction escrowTransaction = escrowTransactionRepository.findByOrder(order)
                .orElseThrow(() -> new RuntimeException("Escrow transaction not found for order: " + order.getId()));

        escrowTransaction.setStatus(EscrowStatus.RELEASED);
        escrowTransaction.setReleasedAt(LocalDateTime.now());
        escrowTransactionRepository.save(escrowTransaction);

        // 2. Tạo WalletTransaction để cập nhật balance seller
        WalletTransaction walletTransaction = WalletTransaction.builder()
                .user(order.getSellerStore().getOwner())
                .amount(order.getTotalAmount())
                .type(WalletTransactionType.ORDER_PAYMENT)
                .refOrder(order)
                .paymentStatus(WalletTransactionStatus.RELEASED)
                .note("Payment released from escrow for order #" + order.getId())
                .build();
        walletTransactionRepository.save(walletTransaction);

        // 3. Cập nhật balance của seller
        User seller = order.getSellerStore().getOwner();
        seller.setBalance(seller.getBalance().add(order.getTotalAmount()));
        userRepository.save(seller);
    }
}
