package vn.group3.marketplace.domain.enums;

public enum OrderStatus {
    PENDING,
    PENDING_PAYMENT,
    PAYMENT_PROCESSING,
    PAID,
    PAYMENT_FAILED,
    OUT_OF_STOCK,
    REFUNDED,
    CONFIRMED,
    COMPLETED,
    CANCELLED
}
