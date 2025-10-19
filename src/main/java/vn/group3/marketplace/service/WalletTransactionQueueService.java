package vn.group3.marketplace.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;
import org.springframework.stereotype.Service;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import vn.group3.marketplace.util.PerUserSerialExecutor;

import java.util.concurrent.CompletableFuture;
import java.util.concurrent.Future;

/**
 * Service xử lý giao dịch ví theo queue.
 * Mỗi user có một queue riêng, đảm bảo các giao dịch được xử lý tuần tự.
 * Sử dụng PerUserSerialExecutor để quản lý các queue theo userId.
 */
@Service
public class WalletTransactionQueueService {

    private static final Logger logger = LoggerFactory.getLogger(WalletTransactionQueueService.class);
    private final PerUserSerialExecutor perUserSerialExecutor;
    private final ApplicationContext ctx;

    @Autowired
    public WalletTransactionQueueService(ApplicationContext ctx) {
        this.ctx = ctx;
        // Nếu hàng đợi quá lâu (60 giây), thì hủy bỏ
        // Giới hạn tối đa 1000 tác vụ trong hàng đợi

        this.perUserSerialExecutor = new PerUserSerialExecutor(60_000L, 1000);
    }

    /**
     * Enqueue a deposit processing task (keeps compatibility).
     */
    public Future<Void> enqueueDeposit(Long userId, String paymentRef) {
        try {
            return perUserSerialExecutor.submit(userId, () -> {
                WalletService walletService = ctx.getBean(WalletService.class);
                walletService.processSuccessfulDeposit(paymentRef);
                return null;
            });
        } catch (Exception ex) {
            CompletableFuture<Void> f = new CompletableFuture<>();
            f.completeExceptionally(ex);
            return f;
        }
    }

    /**
     * Đưa task trừ tiền mua hàng vào queue xử lý
     */
    public Future<Boolean> enqueuePurchasePayment(Long userId, java.math.BigDecimal amount, String paymentRef) {
        try {
            logger.info("Enqueueing purchase payment for user: {}, amount: {}, paymentRef: {}", userId, amount,
                    paymentRef);
            return perUserSerialExecutor.submit(userId, () -> {
                logger.info("Processing purchase payment for user: {}, amount: {}, paymentRef: {}", userId, amount,
                        paymentRef);
                WalletService walletService = ctx.getBean(WalletService.class);
                boolean result = walletService.processPurchasePayment(userId, amount, paymentRef);

                // If this is a store deposit payment for created shop and it's successful,
                // activate the store
                if (result && paymentRef != null && paymentRef.startsWith("createdShop")) {
                    try {
                        Long storeId = Long.parseLong(paymentRef.substring("createdShop".length()));
                        SellerStoreService sellerStoreService = ctx.getBean(SellerStoreService.class);
                        sellerStoreService.activateStore(storeId);
                        logger.info("Store {} activated after successful deposit", storeId);
                    } catch (Exception e) {
                        logger.error("Failed to activate store after successful deposit. paymentRef: {}", paymentRef,
                                e);
                    }
                }

                logger.info("Purchase payment completed for user: {}, paymentRef: {}, result: {}", userId, paymentRef,
                        result);
                return result;
            });
        } catch (Exception ex) {
            logger.error("Failed to enqueue purchase payment for user: {}, paymentRef: {}, error: {}", userId,
                    paymentRef,
                    ex.getMessage(), ex);
            CompletableFuture<Boolean> f = new CompletableFuture<>();
            f.completeExceptionally(ex);
            return f;
        }
    }

    public void shutdown() {
        perUserSerialExecutor.shutdown();
    }
}
