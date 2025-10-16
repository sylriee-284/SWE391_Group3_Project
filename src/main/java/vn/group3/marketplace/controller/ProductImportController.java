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
import vn.group3.marketplace.domain.dto.ImportResult;
import vn.group3.marketplace.domain.dto.ProductStorageImportDTO;
import vn.group3.marketplace.domain.entity.Product;
import vn.group3.marketplace.service.ProductService;
import vn.group3.marketplace.service.ProductStorageImportService;

import java.util.List;

@Controller
@RequiredArgsConstructor
@Slf4j
@RequestMapping("/seller/product")
public class ProductImportController {

    private final ProductStorageImportService productStorageImportService;
    private final ProductService productService;

    // 1. Show import page
    @GetMapping("/{productId}/import")
    public String showImportPage(@PathVariable Long productId, Model model) {
        try {
            Product product = productService.getProductById(productId);

            if (product == null) {
                model.addAttribute("errorMessage", "Không tìm thấy sản phẩm");
                return "redirect:/seller/products";
            }

            model.addAttribute("product", product);
            model.addAttribute("productId", productId);

            return "seller/product-import"; // JSP view path

        } catch (Exception e) {
            log.error("Error showing import page for product {}: {}", productId, e.getMessage(), e);
            model.addAttribute("errorMessage", "Lỗi tải trang import");
            return "redirect:/seller/products";
        }
    }

    // 2. Download import template
    @GetMapping("/{productId}/import/template")
    @ResponseBody // Required for binary response
    public ResponseEntity<byte[]> downloadTemplate(@PathVariable Long productId) {
        try {
            byte[] template = productStorageImportService.generateExcelTemplate(productId);

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_OCTET_STREAM);
            headers.setContentDispositionFormData("attachment",
                    "import_template_product_" + productId + ".xlsx");

            return ResponseEntity.ok()
                    .headers(headers)
                    .body(template);

        } catch (Exception e) {
            log.error("Error generating template for product {}: {}", productId, e.getMessage(), e);
            return ResponseEntity.internalServerError().build();
        }
    }

    // 3. Upload and preview import file
    @PostMapping("/{productId}/import/upload")
    public String importStorage(
            @PathVariable Long productId,
            @RequestParam("file") MultipartFile file,
            RedirectAttributes redirectAttributes) {

        try {
            // Validate file
            if (file.isEmpty()) {
                redirectAttributes.addFlashAttribute("errorMessage", "Vui lòng chọn file để import");
                return "redirect:/seller/product/" + productId + "/import";
            }

            // Validate file extension
            String fileName = file.getOriginalFilename();
            if (fileName == null || !fileName.endsWith(".xlsx")) {
                redirectAttributes.addFlashAttribute("errorMessage", "Chỉ chấp nhận file Excel (.xlsx)");
                return "redirect:/seller/product/" + productId + "/import";
            }

            // Validate file size (Max 10MB)
            if (file.getSize() > 10 * 1024 * 1024) {
                redirectAttributes.addFlashAttribute("errorMessage", "File không được vượt quá 10MB");
                return "redirect:/seller/product/" + productId + "/import";
            }

            // Parse file
            List<ProductStorageImportDTO> dtoList = productStorageImportService.parseExcelFile(file, productId);

            if (dtoList.isEmpty()) {
                redirectAttributes.addFlashAttribute("errorMessage", "File không có dữ liệu");
                return "redirect:/seller/product/" + productId + "/import";
            }

            // Validate data
            Product product = productService.getProductById(productId);
            if (product == null) {
                redirectAttributes.addFlashAttribute("errorMessage", "Không tìm thấy sản phẩm");
                return "redirect:/seller/product/" + productId + "/import";
            }

            Long categoryId = product.getCategory().getId();
            productStorageImportService.validateImportData(dtoList, categoryId);

            // Count valid and invalid rows
            long validCount = dtoList.stream().filter(dto -> !dto.hasErrors()).count();
            long errorCount = dtoList.stream().filter(dto -> dto.hasErrors()).count();

            // Add preview data to flash attributes
            redirectAttributes.addFlashAttribute("previewMode", true);
            redirectAttributes.addFlashAttribute("records", dtoList);
            redirectAttributes.addFlashAttribute("validCount", validCount);
            redirectAttributes.addFlashAttribute("errorCount", errorCount);
            redirectAttributes.addFlashAttribute("totalCount", dtoList.size());
            redirectAttributes.addFlashAttribute("fileName", fileName);

            return "redirect:/seller/product/" + productId + "/import";

        } catch (Exception e) {
            log.error("Error previewing import for product {}: {}", productId, e.getMessage(), e);
            redirectAttributes.addFlashAttribute("errorMessage", "Lỗi xử lý file: " + e.getMessage());
            return "redirect:/seller/product/" + productId + "/import";
        }
    }

    // 4. Execute import
    @PostMapping("/{productId}/import/execute")
    public String executeImport(
            @PathVariable Long productId,
            @RequestParam("file") MultipartFile file,
            RedirectAttributes redirectAttributes) {

        try {
            // Parse file and validate data
            List<ProductStorageImportDTO> dtoList = productStorageImportService.parseExcelFile(file, productId);

            Product product = productService.getProductById(productId);
            if (product == null) {
                redirectAttributes.addFlashAttribute("errorMessage", "Không tìm thấy sản phẩm");
                return "redirect:/seller/product/" + productId + "/import";
            }

            Long categoryId = product.getCategory().getId();
            productStorageImportService.validateImportData(dtoList, categoryId);

            // Execute import
            ImportResult result = productStorageImportService.importStorage(productId, dtoList);

            // Prepare result for display
            if (result.isFullSuccess()) {
                redirectAttributes.addFlashAttribute("successMessage",
                        String.format("Import thành công %d sản phẩm!", result.getSuccessCount()));
            } else if (result.hasAnySuccess()) {
                redirectAttributes.addFlashAttribute("warningMessage",
                        String.format("Import thành công %d/%d sản phẩm. %d sản phẩm bị lỗi.",
                                result.getSuccessCount(),
                                result.getTotalCount(),
                                result.getErrorCount()));
                redirectAttributes.addFlashAttribute("importResult", result);
            } else {
                redirectAttributes.addFlashAttribute("errorMessage",
                        "Import thất bại! Tất cả sản phẩm đều có lỗi.");
                redirectAttributes.addFlashAttribute("importResult", result);
            }

            return "redirect:/seller/product/" + productId + "/import";

        } catch (Exception e) {
            log.error("Error executing import for product {}: {}", productId, e.getMessage(), e);
            redirectAttributes.addFlashAttribute("errorMessage", "Lỗi import: " + e.getMessage());
            return "redirect:/seller/product/" + productId + "/import";
        }
    }
}
