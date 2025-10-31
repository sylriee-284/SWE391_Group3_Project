package vn.group3.marketplace.util;

import java.util.Map;
import java.util.concurrent.*;

/**
 * Simple per-user serial executor: tasks submitted for the same key (userId)
 * will be executed sequentially on a dedicated single-thread executor.
 * Executors are created lazily and cleaned up after being idle.
 */
public class PerUserSerialExecutor {

    private final ConcurrentHashMap<Long, UserExecutor> executors = new ConcurrentHashMap<>();
    private final ScheduledExecutorService janitor = Executors.newSingleThreadScheduledExecutor(r -> {
        Thread t = new Thread(r, "PerUserSerialExecutor-Janitor");
        t.setDaemon(true); //không giữ JVM sống nếu tất cả luồng “chính” (non-daemon) đã kết thúc.
        return t;
    });

    private final long idleMillis;
    private final int queueCapacity;

    public PerUserSerialExecutor(long idleMillis, int queueCapacity) {
        this.idleMillis = idleMillis;  // Thời gian chờ trước khi xóa (ms)
        this.queueCapacity = queueCapacity; // Kích cỡ tối đa của queue
        janitor.scheduleAtFixedRate(this::cleanupIdleExecutors, idleMillis, idleMillis, TimeUnit.MILLISECONDS);
    }

    public PerUserSerialExecutor() {
        this(60_000L, 1000); // default: cleanup every 60s, queue cap 1000
    }

    public <T> Future<T> submit(Long userId, Callable<T> task) throws RejectedExecutionException {
        UserExecutor ue = executors.computeIfAbsent(userId, id -> new UserExecutor(id));
        ue.updateLastAccess();
        return ue.submit(task);
    }

    public Future<?> submit(Long userId, Runnable task) throws RejectedExecutionException {
        return submit(userId, Executors.callable(task, null));
    }

    private void cleanupIdleExecutors() {
        long now = System.currentTimeMillis();
        for (Map.Entry<Long, UserExecutor> e : executors.entrySet()) {
            UserExecutor ue = e.getValue();
            if (now - ue.getLastAccess() > idleMillis) {
                if (executors.remove(e.getKey(), ue)) {
                    ue.shutdown();
                }
            }
        }
    }

    public void shutdown() {
        janitor.shutdownNow();
        for (UserExecutor ue : executors.values()) {
            ue.shutdown();
        }
        executors.clear();
    }

    private class UserExecutor {
        private final Long userId;
        private final ThreadPoolExecutor executor;
        private volatile long lastAccess = System.currentTimeMillis();

        UserExecutor(Long userId) {
            this.userId = userId;
            this.executor = new ThreadPoolExecutor(1, 1,
                    60L, TimeUnit.SECONDS,
                    new LinkedBlockingQueue<>(queueCapacity),
                    r -> {
                        Thread t = new Thread(r, "per-user-exec-" + userId);
                        t.setDaemon(true);
                        return t;
                    }, new ThreadPoolExecutor.AbortPolicy()); // Ném lỗi RejectedExecutionException khi queue đầy 
        }

        <T> Future<T> submit(Callable<T> task) {
            this.lastAccess = System.currentTimeMillis();
            return executor.submit(task);
        }

        void updateLastAccess() {
            this.lastAccess = System.currentTimeMillis();
        }

        long getLastAccess() {
            return lastAccess;
        }
       // Dừng nhận task mới → chờ 5s → nếu chưa xong thì ép dừng mọi thứ.
        void shutdown() {
            try {
                executor.shutdown();
                executor.awaitTermination(5, TimeUnit.SECONDS);
            } catch (InterruptedException ignored) {
            } finally {
                executor.shutdownNow();
            }
        }
    }
}
