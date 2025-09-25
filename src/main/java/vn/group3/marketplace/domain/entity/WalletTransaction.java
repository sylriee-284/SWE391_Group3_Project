package vn.group3.marketplace.domain.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.*;
import vn.group3.marketplace.domain.BaseEntity;

import java.math.BigDecimal;

/**
 * WalletTransaction entity representing wallet_transactions table in database
 * Tracks all financial transactions for audit and history purposes
 */
@Entity
@Table(name = "wallet_transactions")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class WalletTransaction extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "wallet_id", nullable = false)
    @NotNull(message = "Wallet is required")
    private Wallet wallet;

    @Column(name = "type", length = 50, nullable = false)
    @NotNull(message = "Transaction type is required")
    private String type;

    @Column(name = "amount", precision = 18, scale = 2, nullable = false)
    @NotNull(message = "Amount is required")
    @DecimalMin(value = "0.0", message = "Amount must be positive")
    private BigDecimal amount;

    @Column(name = "balance_before", precision = 18, scale = 2, nullable = false)
    @NotNull(message = "Balance before is required")
    @DecimalMin(value = "0.0", message = "Balance before cannot be negative")
    private BigDecimal balanceBefore;

    @Column(name = "balance_after", precision = 18, scale = 2, nullable = false)
    @NotNull(message = "Balance after is required")
    @DecimalMin(value = "0.0", message = "Balance after cannot be negative")
    private BigDecimal balanceAfter;

    @Column(name = "description", nullable = false)
    @NotBlank(message = "Description is required")
    @Size(max = 500, message = "Description must not exceed 500 characters")
    private String description;

    @Column(name = "reference_id")
    private Long referenceId;

    @Column(name = "reference_type", length = 50)
    @Size(max = 50, message = "Reference type must not exceed 50 characters")
    private String referenceType;

    // Business methods

    /**
     * Create a credit transaction (increases balance)
     * @param wallet Target wallet
     * @param type Transaction type
     * @param amount Amount to credit
     * @param description Transaction description
     * @param referenceId Optional reference ID
     * @param referenceType Optional reference type
     * @return New credit transaction
     */
    public static WalletTransaction createCredit(Wallet wallet, String type,
                                               BigDecimal amount, String description,
                                               Long referenceId, String referenceType) {
        if (!isCreditType(type)) {
            throw new IllegalArgumentException("Transaction type must be a credit type");
        }
        
        BigDecimal balanceBefore = wallet.getBalance();
        BigDecimal balanceAfter = balanceBefore.add(amount);
        
        return WalletTransaction.builder()
                .wallet(wallet)
                .type(type)
                .amount(amount)
                .balanceBefore(balanceBefore)
                .balanceAfter(balanceAfter)
                .description(description)
                .referenceId(referenceId)
                .referenceType(referenceType)
                .build();
    }

    /**
     * Create a debit transaction (decreases balance)
     * @param wallet Target wallet
     * @param type Transaction type
     * @param amount Amount to debit
     * @param description Transaction description
     * @param referenceId Optional reference ID
     * @param referenceType Optional reference type
     * @return New debit transaction
     */
    public static WalletTransaction createDebit(Wallet wallet, String type,
                                              BigDecimal amount, String description,
                                              Long referenceId, String referenceType) {
        if (!isDebitType(type)) {
            throw new IllegalArgumentException("Transaction type must be a debit type");
        }
        
        BigDecimal balanceBefore = wallet.getBalance();
        BigDecimal balanceAfter = balanceBefore.subtract(amount);
        
        if (balanceAfter.compareTo(BigDecimal.ZERO) < 0) {
            throw new IllegalArgumentException("Insufficient funds for transaction");
        }
        
        return WalletTransaction.builder()
                .wallet(wallet)
                .type(type)
                .amount(amount)
                .balanceBefore(balanceBefore)
                .balanceAfter(balanceAfter)
                .description(description)
                .referenceId(referenceId)
                .referenceType(referenceType)
                .build();
    }

    /**
     * Get formatted amount with currency
     * @return Formatted amount string
     */
    public String getFormattedAmount() {
        return String.format("%,.2f VND", amount);
    }

    /**
     * Check if this is a credit transaction
     * @return true if transaction increases balance
     */
    public boolean isCredit() {
        return isCreditType(type);
    }

    /**
     * Check if this is a debit transaction
     * @return true if transaction decreases balance
     */
    public boolean isDebit() {
        return isDebitType(type);
    }

    /**
     * Check if transaction type is a credit type (increases balance)
     * @param type Transaction type string
     * @return true if transaction increases balance
     */
    public static boolean isCreditType(String type) {
        return "deposit".equals(type) || "sale".equals(type) || "refund".equals(type) ||
               "escrow_release".equals(type) || "store_deposit_refund".equals(type);
    }

    /**
     * Check if transaction type is a debit type (decreases balance)
     * @param type Transaction type string
     * @return true if transaction decreases balance
     */
    public static boolean isDebitType(String type) {
        return "withdrawal".equals(type) || "purchase".equals(type) || "escrow_hold".equals(type) ||
               "store_deposit".equals(type) || "commission".equals(type) || "penalty".equals(type);
    }

    @Override
    public String toString() {
        return "WalletTransaction{" +
                "id=" + id +
                ", walletId=" + (wallet != null ? wallet.getId() : null) +
                ", type=" + type +
                ", amount=" + amount +
                ", description='" + description + '\'' +
                '}';
    }
}
