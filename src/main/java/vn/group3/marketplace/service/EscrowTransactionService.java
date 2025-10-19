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

    public EscrowTransactionService(EscrowTransactionRepository escrowTransactionRepository,
            SystemSettingService systemSettingService, TaskScheduler taskScheduler,
            WalletTransactionRepository walletTransactionRepository,
            UserRepository userRepository) {
        this.escrowTransactionRepository = escrowTransactionRepository;
        this.systemSettingService = systemSettingService;
        this.taskScheduler = taskScheduler;
        this.walletTransactionRepository = walletTransactionRepository;
        this.userRepository = userRepository;
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
        } catch (Exception e) {
            // Don't throw to avoid breaking order process - just log the error
        }
    }

    public void scheduleEscrowTransactionRelease(Order order) {
        try {
            String holdMinutesStr = systemSettingService.getSettingValue("escrow.default_hold_minutes", "1");
            int holdMinutes = Integer.parseInt(holdMinutesStr);

            Instant releaseTime = Instant.now().plusSeconds((long) holdMinutes * 60);
            taskScheduler.schedule(() -> EscrowTransactionService.this.releasePaymentToSeller(order), releaseTime);
        } catch (Exception e) {
            // Don't throw to avoid breaking order process
        }
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
