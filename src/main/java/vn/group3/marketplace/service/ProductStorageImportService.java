package vn.group3.marketplace.service;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;
import vn.group3.marketplace.dto.*;
import vn.group3.marketplace.domain.entity.*;
import vn.group3.marketplace.domain.enums.ProductStorageStatus;
import vn.group3.marketplace.dto.ImportResult;
import vn.group3.marketplace.dto.ProductStorageImportDTO;
import vn.group3.marketplace.repository.CategoryImportTemplateRepository;
import vn.group3.marketplace.repository.ProductRepository;
import vn.group3.marketplace.repository.ProductStorageRepository;
import vn.group3.marketplace.util.ValidationUtils;

import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

@Service
@RequiredArgsConstructor
@Slf4j
public class ProductStorageImportService {

    private final CategoryImportTemplateRepository templateRepository;
    private final ProductRepository productRepository;
    private final ProductStorageRepository storageRepository;
    private final ObjectMapper objectMapper;

    // Get import templates for a category
    public List<CategoryImportTemplate> getTemplatesByCategory(Long categoryId) {
        return templateRepository.findByCategoryIdOrderByFieldOrder(categoryId);
    }

    // Get category ID by product ID (helper method)
    public Long getCategoryIdByProductId(Long productId) {
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new IllegalArgumentException("Product not found"));
        return product.getCategory().getId();
    }

    // Generate Excel template for download
    public byte[] generateExcelTemplate(Long productId) throws Exception {
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new IllegalArgumentException("Product not found"));

        List<CategoryImportTemplate> templates = getTemplatesByCategory(product.getCategory().getId());

        try (Workbook workbook = new XSSFWorkbook();
                ByteArrayOutputStream out = new ByteArrayOutputStream()) {

            Sheet sheet = workbook.createSheet("Import Data");

            // Create header row
            Row headerRow = sheet.createRow(0);

            // Add STT column
            headerRow.createCell(0).setCellValue("STT");

            // Add template fields
            for (int i = 0; i < templates.size(); i++) {
                CategoryImportTemplate template = templates.get(i);
                headerRow.createCell(i + 1).setCellValue(template.getFieldLabel());
            }

            workbook.write(out);
            return out.toByteArray();
        }
    }

    // Parse uploaded Excel file
    public List<ProductStorageImportDTO> parseExcelFile(MultipartFile file, Long productId) throws Exception {
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new IllegalArgumentException("Product not found"));

        List<CategoryImportTemplate> templates = getTemplatesByCategory(product.getCategory().getId());
        List<ProductStorageImportDTO> result = new ArrayList<>();

        try (InputStream is = file.getInputStream();
                Workbook workbook = WorkbookFactory.create(is)) {

            Sheet sheet = workbook.getSheetAt(0);

            // Validate header row
            validateHeaderRow(sheet, templates);

            int rowNum = 0;

            for (Row row : sheet) {
                rowNum++;

                // Skip header row
                if (rowNum == 1)
                    continue;

                // Skip empty rows
                if (isRowEmpty(row))
                    continue;

                ProductStorageImportDTO dto = ProductStorageImportDTO.builder()
                        .rowNumber(rowNum)
                        .build();

                // Parse each field according to template
                for (int i = 0; i < templates.size(); i++) {
                    CategoryImportTemplate template = templates.get(i);
                    Cell cell = row.getCell(i + 1); // +1 because column 0 is STT

                    String value = getCellValueAsString(cell);
                    dto.addField(template.getFieldName(), value);
                }

                result.add(dto);
            }
        }

        return result;
    }

    // Validate header row matches template
    private void validateHeaderRow(Sheet sheet, List<CategoryImportTemplate> templates) throws Exception {
        String errorMsg = "File không đúng định dạng. Vui lòng tải template và nhập lại.";
        Row headerRow = sheet.getRow(0);

        // Check header exists and column count
        if (headerRow == null || headerRow.getLastCellNum() != templates.size() + 1) {
            throw new IllegalArgumentException(errorMsg);
        }

        // Check STT column
        if (!getCellValueAsString(headerRow.getCell(0)).equalsIgnoreCase("STT")) {
            throw new IllegalArgumentException(errorMsg);
        }

        // Check each template column
        for (int i = 0; i < templates.size(); i++) {
            String actual = getCellValueAsString(headerRow.getCell(i + 1)).trim();
            String expected = templates.get(i).getFieldLabel().trim();
            if (!actual.equalsIgnoreCase(expected)) {
                throw new IllegalArgumentException(errorMsg);
            }
        }
    }

    // Validate data if it unique in the database

    private boolean isRowEmpty(Row row) {
        if (row == null)
            return true;
        for (int i = 0; i < row.getLastCellNum(); i++) {
            Cell cell = row.getCell(i);
            if (cell != null && cell.getCellType() != CellType.BLANK) {
                return false;
            }
        }
        return true;
    }

    // Convert cell value to string
    private String getCellValueAsString(Cell cell) {
        if (cell == null || cell.getCellType() == CellType.BLANK) {
            return "";
        }

        try {
            // Force convert to string using DataFormatter (handles all types automatically)
            DataFormatter formatter = new DataFormatter();
            return formatter.formatCellValue(cell).trim();
        } catch (Exception e) {
            return "";
        }
    }

    // Validate all DTOs according to templates
    public void validateImportData(List<ProductStorageImportDTO> dtoList, Long categoryId) {
        List<CategoryImportTemplate> templates = getTemplatesByCategory(categoryId);

        // Basic validation
        for (ProductStorageImportDTO dto : dtoList) {
            for (CategoryImportTemplate template : templates) {
                String fieldName = template.getFieldName();
                Object value = dto.getField(fieldName);
                validateField(dto, template, value);
            }
        }

        // Unique validation
        validateUniqueFields(dtoList, templates);
    }

    // Validate unique fields
    private void validateUniqueFields(List<ProductStorageImportDTO> dtoList, List<CategoryImportTemplate> templates) {
        for (CategoryImportTemplate template : templates) {
            // Null-safe (defensive programming)
            if (!Boolean.TRUE.equals(template.getIsUnique())) {
                continue;
            }

            String fieldName = template.getFieldName();
            String fieldLabel = template.getFieldLabel();

            // Track accepted values (will be added to database after import)
            Set<String> acceptedValues = new HashSet<>();

            // Check each record sequentially
            for (ProductStorageImportDTO dto : dtoList) {
                String value = dto.getField(fieldName) != null ? dto.getField(fieldName).toString().trim() : "";
                if (value.isEmpty())
                    continue;

                // Check if exists in database OR in previously accepted values
                if (isValueExistsInDatabase(fieldName, value)) {
                    dto.addError(fieldLabel + " đã tồn tại trong hệ thống");
                } else if (acceptedValues.contains(value)) {
                    dto.addError(fieldLabel + " bị trùng lặp trong file");
                } else {
                    // First occurrence - accept it
                    acceptedValues.add(value);
                }
            }
        }
    }

    // Check if value exists in database
    private boolean isValueExistsInDatabase(String fieldName, String value) {
        try {
            List<ProductStorage> allStorage = storageRepository.findAll();
            for (ProductStorage storage : allStorage) {
                if (storage.getPayloadJson() != null) {
                    Map<String, Object> payload = objectMapper.readValue(
                            storage.getPayloadJson(),
                            new TypeReference<Map<String, Object>>() {
                            });
                    Object dbValue = payload.get(fieldName);
                    if (dbValue != null && dbValue.toString().trim().equalsIgnoreCase(value)) {
                        return true;
                    }
                }
            }
            return false;
        } catch (Exception e) {
            log.error("Error checking unique value in database: {}", e.getMessage());
            return false;
        }
    }

    private void validateField(ProductStorageImportDTO dto, CategoryImportTemplate template, Object value) {
        String stringValue = value != null ? value.toString().trim() : "";

        // All fields are required
        if (stringValue.isEmpty()) {
            dto.addError(template.getFieldLabel() + " trống!");
            return;
        }

        // Apply validation rules using ValidationUtils
        String rule = template.getValidationRule();
        if (rule != null && !rule.isEmpty()) {
            if (!ValidationUtils.validateByRule(stringValue, rule)) {
                dto.addError(template.getFieldLabel() + ": " + ValidationUtils.getValidationErrorMessage(rule));
            }
        }
    }

    // Import storage data
    public ImportResult importStorage(Long productId, List<ProductStorageImportDTO> dtoList) {
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new IllegalArgumentException("Product not found"));

        int successCount = 0;
        int errorCount = 0;
        List<ProductStorageImportDTO> errorRecords = new ArrayList<>();

        for (ProductStorageImportDTO dto : dtoList) {
            if (dto.hasErrors()) {
                errorCount++;
                errorRecords.add(dto);
                continue;
            }

            try {
                // Save product storage
                saveProductStorage(product, dto);
                successCount++;
            } catch (Exception e) {
                errorCount++;
                dto.addError("Lỗi lưu dữ liệu: " + e.getMessage());
                errorRecords.add(dto);
            }
        }

        // Update product stock after successful imports
        if (successCount > 0) {
            updateProductStock(productId, successCount);
        }

        return ImportResult.builder()
                .successCount(successCount)
                .errorCount(errorCount)
                .errorRecords(errorRecords)
                .build();
    }

    @Transactional
    private void saveProductStorage(Product product, ProductStorageImportDTO dto) throws Exception {
        String jsonData = objectMapper.writeValueAsString(dto.getData());
        ProductStorage storage = ProductStorage.builder()
                .product(product)
                .status(ProductStorageStatus.AVAILABLE)
                .payloadJson(jsonData)
                .build();
        storageRepository.save(storage);
    }

    // Update product stock
    @Transactional
    private void updateProductStock(Long productId, int quantity) {
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new IllegalArgumentException("Product not found"));
        product.setStock(product.getStock() + quantity);
        productRepository.save(product);
    }
}
