package vn.group3.marketplace.controller;

import vn.group3.marketplace.dto.OrderTask;
import vn.group3.marketplace.service.OrderQueue;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@Controller
@RequestMapping("/orders")
public class OrderController {
    @Autowired
    private OrderQueue orderQueue;

    @PostMapping("/create-order")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> createOrder(@RequestBody OrderTask orderTask) {
        try {
            boolean queued = orderQueue.addOrder(orderTask);

            if (queued) {
                // IMMEDIATE RESPONSE (Non-blocking)
                return ResponseEntity.ok(createSuccessResponse(
                        "Ordered successfully, please wait a moment",
                        orderQueue.getQueueSize()));
            } else {
                return ResponseEntity.status(503)
                        .body(createErrorResponse("Queue is full, please try again"));
            }

        } catch (Exception e) {
            return ResponseEntity.status(500)
                    .body(createErrorResponse("Internal server error: " + e.getMessage()));
        }
    }

    private Map<String, Object> createSuccessResponse(String message, int queueSize) {
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", message);
        response.put("queueSize", queueSize);
        response.put("timestamp", LocalDateTime.now());
        return response;
    }

    private Map<String, Object> createErrorResponse(String message) {
        Map<String, Object> response = new HashMap<>();
        response.put("error", true);
        response.put("message", message);
        response.put("timestamp", LocalDateTime.now());
        return response;
    }
}
