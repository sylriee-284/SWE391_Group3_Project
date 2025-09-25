package vn.group3.marketplace.dto.request;

import jakarta.validation.constraints.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Request DTO for updating seller store information
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SellerStoreUpdateRequest {

    @NotBlank(message = "Store name is required")
    @Size(min = 3, max = 100, message = "Store name must be between 3 and 100 characters")
    private String storeName;

    @Size(max = 1000, message = "Store description must not exceed 1000 characters")
    private String storeDescription;

    @Email(message = "Invalid email format")
    @Size(max = 100, message = "Contact email must not exceed 100 characters")
    private String contactEmail;

    @Pattern(regexp = "^[+]?[0-9]{10,15}$", message = "Invalid phone number format")
    private String contactPhone;

    @Size(max = 50, message = "Business license must not exceed 50 characters")
    private String businessLicense;

    private String storeLogoUrl;

    /**
     * Check if any field has been updated
     * @return true if at least one field is not null
     */
    public boolean hasUpdates() {
        return storeName != null || 
               storeDescription != null || 
               contactEmail != null || 
               contactPhone != null || 
               businessLicense != null ||
               storeLogoUrl != null;
    }

    /**
     * Validate that at least one field is provided for update
     * @return true if valid update request
     */
    @AssertTrue(message = "At least one field must be provided for update")
    public boolean isValidUpdateRequest() {
        return hasUpdates();
    }
}
