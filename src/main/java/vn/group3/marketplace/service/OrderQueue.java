package vn.group3.marketplace.service;

import vn.group3.marketplace.dto.OrderTask;
import org.springframework.stereotype.Component;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.LinkedBlockingQueue;

@Component
public class OrderQueue {

    private final BlockingQueue<OrderTask> orderQueue = new LinkedBlockingQueue<>();

    public boolean addOrder(OrderTask orderTask) {
        return orderQueue.offer(orderTask);
    }

    // blocking queue
    public OrderTask takeOrder() throws InterruptedException {
        return orderQueue.take();
    }

    // non-blocking queue
    public OrderTask pollOrder() {
        return orderQueue.poll();
    }

    public int getQueueSize() {
        return orderQueue.size();
    }

    public boolean isEmpty() {
        return orderQueue.isEmpty();
    }
}