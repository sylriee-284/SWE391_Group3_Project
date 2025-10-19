package vn.group3.marketplace.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class OrderTask {
    private Long userId;
    private Long productId;
    private Long sellerStoreId;
    private Integer quantity;
    private BigDecimal totalAmount;
    private String productName;
    private String productData;
    private LocalDateTime createdAt;

    public OrderTask(Long userId, Long productId, Long sellerStoreId,
            Integer quantity, BigDecimal totalAmount,
            String productName) {
        this.userId = userId;
        this.productId = productId;
        this.sellerStoreId = sellerStoreId;
        this.quantity = quantity;
        this.totalAmount = totalAmount;
        this.productName = productName;
        this.productData = null; // Always null when creating OrderTask
        this.createdAt = LocalDateTime.now();
    }
}