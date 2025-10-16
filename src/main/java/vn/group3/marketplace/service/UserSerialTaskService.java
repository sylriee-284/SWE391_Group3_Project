package vn.group3.marketplace.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;
import org.springframework.stereotype.Service;

import vn.group3.marketplace.util.PerUserSerialExecutor;

import java.util.concurrent.CompletableFuture;
import java.util.concurrent.Future;

/**
 * Generic per-user serial task service.
 * Tasks submitted for the same userId will execute sequentially.
 */
@Service
public class UserSerialTaskService {

    private final PerUserSerialExecutor perUserSerialExecutor;
    private final ApplicationContext ctx;

    @Autowired
    public UserSerialTaskService(ApplicationContext ctx) {
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

    public void shutdown() {
        perUserSerialExecutor.shutdown();
    }
}
