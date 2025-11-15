package vn.group3.marketplace.controller;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import vn.group3.marketplace.domain.entity.Product;
import vn.group3.marketplace.dto.ImportResult;
import vn.group3.marketplace.dto.ProductStorageImportDTO;
import vn.group3.marketplace.service.ProductService;
import vn.group3.marketplace.service.ProductStorageImportService;
import vn.group3.marketplace.service.ProductStorageService;

import java.util.List;

@Controller
@RequiredArgsConstructor
@Slf4j
@RequestMapping("/seller/import")
public class ProductImportController {

    private final ProductStorageImportService productStorageImportService;
    private final ProductService productService;
    private final ProductStorageService productStorageService;

    // Constants
    private static final String ERROR_MESSAGE = "errorMessage";
    private static final String SUCCESS_MESSAGE = "successMessage";
    private static final String WARNING_MESSAGE = "warningMessage";
    private static final String REDIRECT_IMPORT = "redirect:/seller/import/";
    private static final String PRODUCT_NOT_FOUND = "Không tìm thấy sản phẩm";

    // Import limits
    private static final long MAX_FILE_SIZE = 1L * 1024 * 1024; // 1MB

    // 1. Show import page
    @GetMapping("/{productId}")
    public String showImportPage(@PathVariable Long productId, Model model) {
        try {
            Product product = productService.getProductById(productId);

            if (product == null) {
                model.addAttribute(ERROR_MESSAGE, PRODUCT_NOT_FOUND);
                return "redirect:/seller/products";
            }

            // Calculate dynamic stock
            long dynamicStock = productStorageService.getAvailableStock(product.getId());
            // Store dynamic stock in the stock field for JSP access
            product.setStock((int) dynamicStock);

            model.addAttribute("product", product);
            model.addAttribute("productId", productId);

            return "seller/import-product"; // JSP view path

        } catch (Exception e) {
            log.error("Error showing import page for product {}: {}", productId, e.getMessage(), e);
            model.addAttribute(ERROR_MESSAGE, "Lỗi tải trang import");
            return "redirect:/seller/products";
        }
    }

    // 2. Download import template
    @GetMapping("/{productId}/template")
    @ResponseBody
    public ResponseEntity<byte[]> downloadTemplate(@PathVariable Long productId, Model model) {
        try {
            log.info("Generating template for product {}", productId);
            byte[] template = productStorageImportService.generateExcelTemplate(productId);

            if (template == null || template.length == 0) {
                log.error("Template generation returned empty data for product {}", productId);
                model.addAttribute(ERROR_MESSAGE, "Template không tồn tại");
                return ResponseEntity.badRequest().build();
            }

            Product product = productService.getProductById(productId);

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_OCTET_STREAM);
            headers.setContentDispositionFormData("attachment",
                    "import_template_product_" + product.getCategory().getName() + ".xlsx");

            log.info("Successfully generated template for product {}. Size: {} bytes", productId, template.length);
            return ResponseEntity.ok()
                    .headers(headers)
                    .body(template);

        } catch (Exception e) {
            log.error("Error generating template for product {}: {}", productId, e.getMessage(), e);
            model.addAttribute(ERROR_MESSAGE, "Lỗi tải template");
            return ResponseEntity.badRequest().build();
        }
    }

    // 3. Execute import (direct from file upload)
    @PostMapping("/{productId}/execute")
    public String executeImport(
            @PathVariable Long productId,
            @RequestParam("file") MultipartFile file,
            RedirectAttributes redirectAttributes) {

        log.info("Starting import for product: {}, file: {}", productId, file.getOriginalFilename());

        try {
            // Validate file
            if (file.isEmpty()) {
                redirectAttributes.addFlashAttribute(ERROR_MESSAGE, "Vui lòng chọn file để import");
                return REDIRECT_IMPORT + productId;
            }

            // Validate file extension
            String fileName = file.getOriginalFilename();
            if (fileName == null || !fileName.toLowerCase().endsWith(".xlsx")) {
                redirectAttributes.addFlashAttribute(ERROR_MESSAGE,
                        "Vui lòng import file Excel (.xlsx).");
                return REDIRECT_IMPORT + productId;
            }

            // Validate file size (Max 1MB)
            if (file.getSize() > MAX_FILE_SIZE) {
                redirectAttributes.addFlashAttribute(ERROR_MESSAGE,
                        "File không được vượt quá 1MB. Vui lòng giảm số lượng records hoặc chia nhỏ file.");
                return REDIRECT_IMPORT + productId;
            }

            // Validate product
            Product product = productService.getProductById(productId);
            if (product == null) {
                redirectAttributes.addFlashAttribute(ERROR_MESSAGE, PRODUCT_NOT_FOUND);
                return REDIRECT_IMPORT + productId;
            }

            // Parse Excel file
            List<ProductStorageImportDTO> dtoList = productStorageImportService.parseExcelFile(file, productId);

            if (dtoList.isEmpty()) {
                redirectAttributes.addFlashAttribute(ERROR_MESSAGE,
                        "File không có dữ liệu hợp lệ. Vui lòng kiểm tra lại file Excel.");
                return REDIRECT_IMPORT + productId;
            }

            // Validate business rules
            Long categoryId = product.getCategory().getId();
            productStorageImportService.validateImportData(dtoList, categoryId);

            log.info("Executing import for product {}: file={}, records={}", productId, fileName, dtoList.size());

            // Execute import
            ImportResult result = productStorageImportService.importStorage(productId, dtoList);

            // Prepare result for display
            if (result.isFullSuccess()) {
                redirectAttributes.addFlashAttribute(SUCCESS_MESSAGE,
                        String.format("Import thành công %d sản phẩm!", result.getSuccessCount()));
            } else if (result.hasAnySuccess()) {
                redirectAttributes.addFlashAttribute(WARNING_MESSAGE,
                        String.format("Import thành công %d/%d sản phẩm. %d sản phẩm bị lỗi.",
                                result.getSuccessCount(),
                                result.getTotalCount(),
                                result.getErrorCount()));
            } else {
                redirectAttributes.addFlashAttribute(ERROR_MESSAGE,
                        String.format("Import thất bại! Tất cả %d sản phẩm đều có lỗi.", result.getErrorCount()));
            }

            // Always add importResult for detailed view
            redirectAttributes.addFlashAttribute("importResult", result);

            return REDIRECT_IMPORT + productId;

        } catch (Exception e) {
            log.error("Error executing import for product {}: {}", productId, e.getMessage(), e);
            redirectAttributes.addFlashAttribute(ERROR_MESSAGE, "Lỗi import: " + e.getMessage());
            return REDIRECT_IMPORT + productId;
        }
    }
}
