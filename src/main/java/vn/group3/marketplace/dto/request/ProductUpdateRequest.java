package vn.group3.marketplace.dto.request;

import jakarta.validation.constraints.*;
import lombok.*;
import vn.group3.marketplace.domain.enums.ProductCategory;

import java.math.BigDecimal;

/**
 * DTO for updating an existing product
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ProductUpdateRequest {

    @NotBlank(message = "Tên sản phẩm không được để trống")
    @Size(max = 200, message = "Tên sản phẩm không được vượt quá 200 ký tự")
    private String productName;

    @Size(max = 5000, message = "Mô tả không được vượt quá 5000 ký tự")
    private String description;

    @NotNull(message = "Giá sản phẩm không được để trống")
    @DecimalMin(value = "1000.0", message = "Giá sản phẩm phải từ 1,000 VND trở lên")
    @DecimalMax(value = "999999999.99", message = "Giá sản phẩm không được vượt quá 999,999,999 VND")
    private BigDecimal price;

    @NotNull(message = "Số lượng tồn kho không được để trống")
    @Min(value = 0, message = "Số lượng tồn kho không được âm")
    @Max(value = 999999, message = "Số lượng tồn kho không được vượt quá 999,999")
    private Integer stockQuantity;

    @NotNull(message = "Danh mục sản phẩm không được để trống")
    private ProductCategory category;

    @Size(max = 50, message = "SKU không được vượt quá 50 ký tự")
    private String sku;

    private String productImages; // JSON array or comma-separated URLs

    private Boolean isActive;
}
