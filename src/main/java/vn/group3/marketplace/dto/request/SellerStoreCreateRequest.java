package vn.group3.marketplace.dto.request;

import jakarta.validation.constraints.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

/**
 * Request DTO for creating a new seller store
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SellerStoreCreateRequest {

    @NotBlank(message = "Store name is required")
    @Size(min = 3, max = 100, message = "Store name must be between 3 and 100 characters")
    private String storeName;

    @Size(max = 1000, message = "Store description must not exceed 1000 characters")
    private String storeDescription;

    @NotNull(message = "Deposit amount is required")
    @DecimalMin(value = "5000000", message = "Minimum deposit is 5,000,000 VND")
    @DecimalMax(value = "1000000000", message = "Maximum deposit is 1,000,000,000 VND")
    private BigDecimal depositAmount;

    @Email(message = "Invalid email format")
    @Size(max = 100, message = "Contact email must not exceed 100 characters")
    private String contactEmail;

    @Pattern(regexp = "^[+]?[0-9]{10,15}$", message = "Invalid phone number format")
    private String contactPhone;

    @Size(max = 50, message = "Business license must not exceed 50 characters")
    private String businessLicense;

    @Builder.Default
    private Boolean agreeToTerms = false;

    @AssertTrue(message = "You must agree to the terms and conditions")
    public boolean isAgreeToTerms() {
        return Boolean.TRUE.equals(agreeToTerms);
    }

    /**
     * Calculate maximum listing price based on deposit
     * @return Maximum listing price
     */
    public BigDecimal getCalculatedMaxListingPrice() {
        if (depositAmount == null) {
            return BigDecimal.ZERO;
        }
        return depositAmount.divide(BigDecimal.TEN, 2, java.math.RoundingMode.DOWN);
    }

    /**
     * Validate deposit amount against minimum requirement
     * @return true if deposit is sufficient
     */
    public boolean isDepositSufficient() {
        return depositAmount != null && depositAmount.compareTo(new BigDecimal("5000000")) >= 0;
    }

    /**
     * Get formatted deposit amount for display
     * @return Formatted deposit string
     */
    public String getFormattedDeposit() {
        if (depositAmount == null) return "0 VND";
        return String.format("%,.0f VND", depositAmount);
    }

    /**
     * Get formatted max listing price for display
     * @return Formatted max listing price string
     */
    public String getFormattedMaxListingPrice() {
        BigDecimal maxPrice = getCalculatedMaxListingPrice();
        return String.format("%,.0f VND", maxPrice);
    }
}
