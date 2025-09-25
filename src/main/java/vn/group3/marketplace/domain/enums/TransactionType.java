package vn.group3.marketplace.domain.enums;

/**
 * Enum representing types of wallet transactions
 * Maps to the 'type' column in the wallet_transactions table
 */
public enum TransactionType {
    DEPOSIT("deposit"),
    WITHDRAWAL("withdrawal"),
    PURCHASE("purchase"),
    SALE("sale"),
    REFUND("refund"),
    ESCROW_HOLD("escrow_hold"),
    ESCROW_RELEASE("escrow_release"),
    STORE_DEPOSIT("store_deposit"),
    STORE_DEPOSIT_REFUND("store_deposit_refund"),
    COMMISSION("commission"),
    PENALTY("penalty");

    private final String value;

    TransactionType(String value) {
        this.value = value;
    }

    public String getValue() {
        return value;
    }

    public static TransactionType fromValue(String value) {
        for (TransactionType type : TransactionType.values()) {
            if (type.value.equals(value)) {
                return type;
            }
        }
        throw new IllegalArgumentException("Unknown TransactionType value: " + value);
    }

    /**
     * Check if this transaction type increases wallet balance
     * @return true if transaction increases balance
     */
    public boolean isCredit() {
        return this == DEPOSIT || this == SALE || this == REFUND || 
               this == ESCROW_RELEASE || this == STORE_DEPOSIT_REFUND;
    }

    /**
     * Check if this transaction type decreases wallet balance
     * @return true if transaction decreases balance
     */
    public boolean isDebit() {
        return this == WITHDRAWAL || this == PURCHASE || this == ESCROW_HOLD || 
               this == STORE_DEPOSIT || this == COMMISSION || this == PENALTY;
    }
}
