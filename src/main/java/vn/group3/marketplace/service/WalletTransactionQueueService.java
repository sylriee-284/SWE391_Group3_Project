package vn.group3.marketplace.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;
import org.springframework.stereotype.Service;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import vn.group3.marketplace.domain.entity.Order;
import vn.group3.marketplace.util.PerUserSerialExecutor;

import java.util.concurrent.Callable;
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
    public Future<Boolean> enqueuePurchasePayment(Long userId, java.math.BigDecimal amount, Order order) {
        try {
            logger.info("Enqueueing purchase payment for user: {}, amount: {}, orderId: {}", userId, amount,
                    order.getId());
            return perUserSerialExecutor.submit(userId, () -> {
                logger.info("Processing purchase payment for user: {}, amount: {}, orderId: {}", userId, amount,
                        order.getId());
                WalletService walletService = ctx.getBean(WalletService.class);
                boolean result = walletService.processPurchasePayment(userId, amount, order);
                logger.info("Purchase payment completed for user: {}, orderId: {}, result: {}", userId, order.getId(),
                        result);
                return result;
            });
        } catch (Exception ex) {
            logger.error("Failed to enqueue purchase payment for user: {}, orderId: {}, error: {}", userId,
                    order.getId(),
                    ex.getMessage(), ex);
            CompletableFuture<Boolean> f = new CompletableFuture<>();
            f.completeExceptionally(ex);
            return f;
        }
    }

    /**
     * Đưa task cộng tiền cho seller vào queue xử lý
     */
    public Future<Boolean> enqueueAddMoneyToSeller(Long sellerId, java.math.BigDecimal amount, Long orderId) {
        try {
            logger.info("Enqueueing add money to seller: {}, amount: {}, orderId: {}", sellerId, amount, orderId);
            return perUserSerialExecutor.submit(sellerId, () -> {
                logger.info("Processing add money to seller: {}, amount: {}, orderId: {}", sellerId, amount, orderId);
                WalletService walletService = ctx.getBean(WalletService.class);
                boolean result = walletService.addMoneyToSeller(sellerId, amount, orderId);
                logger.info("Add money to seller completed for seller: {}, orderId: {}, result: {}", sellerId, orderId, result);
                return result;
            });
        } catch (Exception ex) {
            logger.error("Failed to enqueue add money to seller: {}, orderId: {}, error: {}", sellerId, orderId, ex.getMessage(), ex);
            CompletableFuture<Boolean> f = new CompletableFuture<>();
            f.completeExceptionally(ex);
            return f;
        }
    }

    // Luồng trừ tiền thanh toán shop
    private static final String CREATED_SHOP_PREFIX = "createdShop";

    private void handleStoreActivation(Long storeId) {
        try {
            logger.info("🔄 Attempting to activate store: {}", storeId);
            SellerStoreService sellerStoreService = ctx.getBean(SellerStoreService.class);
            sellerStoreService.activateStore(storeId);
            logger.info("✅ Store {} activated after successful deposit", storeId);
        } catch (Exception e) {
            logger.error("❌ Failed to activate store after successful deposit. storeId: {}. Error: {}",
                    storeId, e.getMessage(), e);
        }
    }

    private boolean isStoreDepositPayment(String paymentRef) {
        return paymentRef != null && paymentRef.startsWith(CREATED_SHOP_PREFIX);
    }

    private String getPaymentCheckStatus(String paymentRef) {
        if (paymentRef == null) {
            return "NULL";
        }
        if (paymentRef.startsWith(CREATED_SHOP_PREFIX)) {
            return "PASS";
        }
        return "Not a createdShop";
    }

    public Future<Boolean> enqueuePurchasePayment(Long userId, java.math.BigDecimal amount, String paymentRef) {
        try {
            logger.info("Enqueueing purchase payment for user: {}, amount: {}, paymentRef: {}", userId, amount,
                    paymentRef);
            
            return perUserSerialExecutor.submit(userId, new Callable<Boolean>() {
                @Override
                public Boolean call() throws Exception {
                    logger.info("Processing purchase payment for user: {}, amount: {}, paymentRef: {}", userId, amount,
                            paymentRef);
                    WalletService walletService = ctx.getBean(WalletService.class);
                    boolean result = walletService.processPurchasePayment(userId, amount, paymentRef);

                    // Process store activation if needed
                    logger.info("Payment result: {}, paymentRef: {}", result, paymentRef);
                    if (isStoreDepositPayment(paymentRef) && result) {
                        try {
                            Long storeId = Long.parseLong(paymentRef.substring(CREATED_SHOP_PREFIX.length()));
                            handleStoreActivation(storeId);
                        } catch (NumberFormatException e) {
                            logger.error("❌ Failed to parse storeId from paymentRef: {}. Error: {}", paymentRef,
                                    e.getMessage(), e);
                        }
                    } else {
                        logger.warn("⚠️ Store activation skipped. Result: {}, paymentRef check: {}", 
                            result, getPaymentCheckStatus(paymentRef));
                    }

                    logger.info("Purchase payment completed for user: {}, paymentRef: {}, result: {}", userId, paymentRef,
                            result);
                    return result;
                }
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

    /**
     * Cập nhật escrow amount của seller store theo queue
     */
    public Future<Boolean> enqueueUpdateSellerStoreEscrowAmount(Long sellerStoreId, java.math.BigDecimal amount, boolean isAdd) {
        try {
            logger.info("Enqueueing update escrow amount for store: {}, amount: {}, isAdd: {}", 
                sellerStoreId, amount, isAdd);
            return perUserSerialExecutor.submit(sellerStoreId, () -> {
                logger.info("Processing update escrow amount for store: {}, amount: {}, isAdd: {}", 
                    sellerStoreId, amount, isAdd);
                SellerStoreService sellerStoreService = ctx.getBean(SellerStoreService.class);
                sellerStoreService.updateEscrowAmount(sellerStoreId, amount, isAdd);
                logger.info("Updated escrow amount for store: {}, amount: {}, isAdd: {}", 
                    sellerStoreId, amount, isAdd);
                return true;
            });
        } catch (Exception ex) {
            logger.error("Failed to update escrow amount for store: {}, error: {}", 
                sellerStoreId, ex.getMessage(), ex);
            CompletableFuture<Boolean> f = new CompletableFuture<>();
            f.completeExceptionally(ex);
            return f;
        }
    }

    public void shutdown() {
        perUserSerialExecutor.shutdown();
    }
}