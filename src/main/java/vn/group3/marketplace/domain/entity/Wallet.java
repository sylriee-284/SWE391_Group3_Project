package vn.group3.marketplace.domain.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import lombok.*;
import vn.group3.marketplace.domain.BaseEntity;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

/**
 * Wallet entity representing wallets table in database
 * Manages user's financial balance and transaction history
 */
@Entity
@Table(name = "wallets")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Wallet extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false, unique = true)
    @NotNull(message = "User is required")
    private User user;

    @Column(name = "balance", precision = 18, scale = 2, nullable = false)
    @DecimalMin(value = "0.0", message = "Balance cannot be negative")
    @Builder.Default
    private BigDecimal balance = BigDecimal.ZERO;

    // Relationships
    @OneToMany(mappedBy = "wallet", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @Builder.Default
    private List<WalletTransaction> transactions = new ArrayList<>();

    // Business methods
    
    /**
     * Add funds to wallet
     * @param amount Amount to add
     * @param description Transaction description
     * @return Updated balance
     */
    public BigDecimal addFunds(BigDecimal amount, String description) {
        if (amount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("Amount must be positive");
        }
        this.balance = this.balance.add(amount);
        return this.balance;
    }

    /**
     * Deduct funds from wallet
     * @param amount Amount to deduct
     * @param description Transaction description
     * @return Updated balance
     * @throws IllegalArgumentException if insufficient funds
     */
    public BigDecimal deductFunds(BigDecimal amount, String description) {
        if (amount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("Amount must be positive");
        }
        if (this.balance.compareTo(amount) < 0) {
            throw new IllegalArgumentException("Insufficient funds. Current balance: " + this.balance);
        }
        this.balance = this.balance.subtract(amount);
        return this.balance;
    }

    /**
     * Check if wallet has sufficient funds
     * @param amount Amount to check
     * @return true if sufficient funds available
     */
    public boolean hasSufficientFunds(BigDecimal amount) {
        return this.balance.compareTo(amount) >= 0;
    }

    /**
     * Check if wallet can cover seller store deposit
     * @param depositAmount Required deposit amount
     * @return true if wallet can cover the deposit
     */
    public boolean canCoverDeposit(BigDecimal depositAmount) {
        return hasSufficientFunds(depositAmount);
    }

    /**
     * Get formatted balance as string
     * @return Formatted balance with currency
     */
    public String getFormattedBalance() {
        return String.format("%,.2f VND", balance);
    }

    /**
     * Check if wallet is empty
     * @return true if balance is zero
     */
    public boolean isEmpty() {
        return balance.compareTo(BigDecimal.ZERO) == 0;
    }

    @Override
    public String toString() {
        return "Wallet{" +
                "id=" + id +
                ", userId=" + (user != null ? user.getId() : null) +
                ", balance=" + balance +
                '}';
    }
}
