package vn.group3.marketplace.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;

/**
 * Configuration properties for marketplace business rules
 * Maps to marketplace.* properties in application.properties
 */
@Data
@Component
@ConfigurationProperties(prefix = "marketplace")
public class MarketplaceProperties {

    /**
     * Seller configuration
     */
    private Seller seller = new Seller();

    /**
     * Escrow configuration
     */
    private Escrow escrow = new Escrow();

    /**
     * Wallet configuration
     */
    private Wallet wallet = new Wallet();

    @Data
    public static class Seller {
        /**
         * Minimum deposit amount for seller store (default: 5,000,000 VND)
         */
        private BigDecimal minimumDeposit = new BigDecimal("5000000");
    }

    @Data
    public static class Escrow {
        /**
         * Number of days to hold funds in escrow (default: 3 days)
         */
        private int holdDays = 3;
    }

    @Data
    public static class Wallet {
        /**
         * Default currency for wallet transactions (default: VND)
         */
        private String currency = "VND";
    }

    // Convenience methods
    public BigDecimal getMinimumSellerDeposit() {
        return seller.getMinimumDeposit();
    }

    public int getEscrowHoldDays() {
        return escrow.getHoldDays();
    }

    public String getWalletCurrency() {
        return wallet.getCurrency();
    }
}
