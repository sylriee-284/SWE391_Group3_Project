package vn.group3.marketplace.controller;

import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import vn.group3.marketplace.dto.dashboard.*;
import vn.group3.marketplace.service.SellerDashboardService;
import vn.group3.marketplace.repository.CategoryRepository;

import java.math.BigDecimal;
import java.util.List;

/**
 * Controller for Seller Dashboard screens
 */
@Controller
@RequestMapping("/seller/dashboard")
@RequiredArgsConstructor
@PreAuthorize("hasRole('SELLER')")
@Slf4j
public class SellerDashboardController {

    private final SellerDashboardService dashboardService;
    private final CategoryRepository categoryRepository;

    /**
     * Screen 1: Dashboard Overview
     * GET /seller/dashboard
     */
    @GetMapping
    public String dashboardOverview(
            @RequestParam(value = "timeFilter", defaultValue = "30days") String timeFilter,
            @RequestParam(required = false) String startDate,
            @RequestParam(required = false) String endDate,
            @RequestParam(required = false) Long productId,
            @RequestParam(required = false) Long parentCategoryId,
            @RequestParam(required = false) Long categoryId,
            Model model) {

        log.info(
                "Loading dashboard overview with filters: timeFilter={}, startDate={}, endDate={}, productId={}, parentCategoryId={}, categoryId={}",
                timeFilter, startDate, endDate, productId, parentCategoryId, categoryId);

        try {
            // Determine which category ID to use for filtering
            // If child category is selected, use it; otherwise use parent category
            Long finalCategoryId = categoryId != null ? categoryId : parentCategoryId;
            
            DashboardOverviewDTO dashboardData = dashboardService.getOverview(
                    timeFilter, startDate, endDate, productId, finalCategoryId);

            model.addAttribute("dashboard", dashboardData);
            
            // Add parent categories (danh mục lớn) for filter
            model.addAttribute("parentCategories", categoryRepository.findByParentIsNullAndIsDeletedFalse());
            
            // Load child categories if parent is selected
            if (parentCategoryId != null) {
                model.addAttribute("childCategories", 
                    categoryRepository.findByParentIdAndIsDeletedFalse(parentCategoryId));
                model.addAttribute("selectedParentId", parentCategoryId);
            } else if (categoryId != null) {
                // If only child category is selected (from URL), load parent info
                var selectedCategory = categoryRepository.findByIdAndIsDeletedFalse(categoryId);
                if (selectedCategory.isPresent() && selectedCategory.get().getParent() != null) {
                    Long parentId = selectedCategory.get().getParent().getId();
                    model.addAttribute("childCategories", 
                        categoryRepository.findByParentIdAndIsDeletedFalse(parentId));
                    model.addAttribute("selectedParentId", parentId);
                }
            }
            
            return "seller/dashboard-overview";
        } catch (Exception e) {
            log.error("Error loading dashboard overview", e);
            model.addAttribute("errorMessage", "Không thể tải dữ liệu dashboard: " + e.getMessage());
            return "error/500";
        }
    }

    /**
     * Screen 2: Sales & Escrow Analytics
     * GET /seller/dashboard/sales
     */
    @GetMapping("/sales")
    public String salesAnalytics(
            @RequestParam(value = "timeFilter", defaultValue = "30days") String timeFilter,
            @RequestParam(required = false) String startDate,
            @RequestParam(required = false) String endDate,
            @RequestParam(required = false) String orderStatus,
            @RequestParam(required = false) Long productId,
            @RequestParam(value = "page", defaultValue = "0") int page,
            @RequestParam(value = "size", defaultValue = "5") int size,
            Model model) {

        log.info("Loading sales analytics with filters: timeFilter={}, status={}, productId={}, page={}",
                timeFilter, orderStatus, productId, page);

        try {
            SalesAnalyticsDTO salesData = dashboardService.getSalesAnalytics(
                    timeFilter, startDate, endDate, orderStatus, productId, page, size);

            log.info("Sales data loaded successfully: {} orders, escrowSummary={}", 
                    salesData.getOrders().getTotalElements(),
                    salesData.getEscrowSummary() != null ? "present" : "null");

            model.addAttribute("sales", salesData);
            return "seller/dashboard-sales";
        } catch (Exception e) {
            log.error("Error loading sales analytics: {}", e.getMessage(), e);
            
            // Return to page with error message instead of error/500
            model.addAttribute("errorMessage", "Có lỗi khi tải dữ liệu: " + e.getMessage());
            
            // Create empty DTO to prevent null pointer
            SalesAnalyticsDTO emptyData = SalesAnalyticsDTO.builder()
                    .orders(Page.empty())
                    .escrowSummary(EscrowSummaryDTO.builder()
                            .totalHeld(BigDecimal.ZERO)
                            .totalReleased(BigDecimal.ZERO)
                            .totalRefunded(BigDecimal.ZERO)
                            .heldCount(0)
                            .releasedCount(0)
                            .refundedCount(0)
                            .upcomingReleases(List.of())
                            .build())
                    .revenueByStatusChart(ChartDataDTO.builder()
                            .labels(List.of())
                            .datasets(List.of())
                            .build())
                    .escrowTimelineChart(ChartDataDTO.builder()
                            .labels(List.of())
                            .datasets(List.of())
                            .build())
                    .timeFilter(timeFilter)
                    .orderStatus(orderStatus)
                    .build();
            
            model.addAttribute("sales", emptyData);
            return "seller/dashboard-sales";
        }
    }

    /**
     * Screen 3: Product Performance & Inventory
     * GET /seller/dashboard/products
     */
    @GetMapping("/products")
    public String productInventory(
            @RequestParam(value = "timeFilter", defaultValue = "30days") String timeFilter,
            @RequestParam(required = false) String startDate,
            @RequestParam(required = false) String endDate,
            @RequestParam(required = false) Long categoryId,
            @RequestParam(value = "sortBy", defaultValue = "revenue") String sortBy,
            @RequestParam(value = "page", defaultValue = "0") int page,
            @RequestParam(value = "size", defaultValue = "20") int size,
            Model model) {

        log.info("Loading product inventory with filters: timeFilter={}, categoryId={}, sortBy={}, page={}",
                timeFilter, categoryId, sortBy, page);

        try {
            ProductInventoryDTO productData = dashboardService.getProductInventory(
                    timeFilter, startDate, endDate, categoryId, sortBy, page, size);

            model.addAttribute("products", productData);
            return "seller/dashboard-products";
        } catch (Exception e) {
            log.error("Error loading product inventory", e);
            model.addAttribute("errorMessage", "Không thể tải dữ liệu products: " + e.getMessage());
            return "error/500";
        }
    }

    /**
     * Export Sales data to PDF
     * GET /seller/dashboard/sales/export
     */
    @GetMapping("/sales/export")
    public void exportSalesPDF(
            @RequestParam(value = "timeFilter", defaultValue = "30days") String timeFilter,
            @RequestParam(required = false) String startDate,
            @RequestParam(required = false) String endDate,
            @RequestParam(required = false) String orderStatus,
            @RequestParam(required = false) Long productId,
            HttpServletResponse response) throws Exception {

        log.info("Exporting sales data to PDF with filters - timeFilter: {}, startDate: {}, endDate: {}, orderStatus: {}", 
                 timeFilter, startDate, endDate, orderStatus);

        try {
            // Set response headers BEFORE getting output stream
            response.setContentType("application/pdf");
            response.setHeader("Content-Disposition", "attachment; filename=sales_report.pdf");
            response.setHeader("Cache-Control", "no-cache");

            // Get all data (no pagination)
            SalesAnalyticsDTO salesData = dashboardService.getSalesAnalytics(
                    timeFilter, startDate, endDate, orderStatus, productId, 0, 10000);

            // Validate data
            if (salesData == null) {
                throw new RuntimeException("Không thể lấy dữ liệu bán hàng");
            }
            if (salesData.getOrders() == null || salesData.getOrders().getContent() == null) {
                throw new RuntimeException("Không có đơn hàng nào để xuất");
            }

            log.info("Exporting {} orders to PDF", salesData.getOrders().getContent().size());

            // Create PDF document
            com.itextpdf.kernel.pdf.PdfWriter writer = new com.itextpdf.kernel.pdf.PdfWriter(response.getOutputStream());
            com.itextpdf.kernel.pdf.PdfDocument pdfDoc = new com.itextpdf.kernel.pdf.PdfDocument(writer);
            com.itextpdf.layout.Document document = new com.itextpdf.layout.Document(pdfDoc, com.itextpdf.kernel.geom.PageSize.A4.rotate());

        // Add title
        com.itextpdf.layout.element.Paragraph title = new com.itextpdf.layout.element.Paragraph("Báo cáo Bán hàng & Ký quỹ")
                .setFontSize(18)
                .setBold()
                .setTextAlignment(com.itextpdf.layout.properties.TextAlignment.CENTER);
        document.add(title);

        // Add generated date
        com.itextpdf.layout.element.Paragraph date = new com.itextpdf.layout.element.Paragraph("Ngày tạo: " + java.time.LocalDateTime.now().format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss")))
                .setFontSize(10)
                .setTextAlignment(com.itextpdf.layout.properties.TextAlignment.CENTER)
                .setMarginBottom(20);
        document.add(date);

            // Create table
            float[] columnWidths = {1.5f, 2f, 3f, 1f, 2f, 1.5f, 2f, 2f, 2f, 2f};
            com.itextpdf.layout.element.Table table = new com.itextpdf.layout.element.Table(columnWidths);
            table.setWidth(com.itextpdf.layout.properties.UnitValue.createPercentValue(100));

            // Add headers
            String[] headers = {"Mã đơn", "Ngày", "Sản phẩm", "SL", "Tổng tiền", "Trạng thái", "Người mua", "Đang giữ", "Đã giải ngân", "Giữ đến"};
            for (String header : headers) {
                com.itextpdf.layout.element.Cell cell = new com.itextpdf.layout.element.Cell()
                        .add(new com.itextpdf.layout.element.Paragraph(header))
                        .setBackgroundColor(com.itextpdf.kernel.colors.ColorConstants.LIGHT_GRAY)
                        .setBold()
                        .setTextAlignment(com.itextpdf.layout.properties.TextAlignment.CENTER)
                        .setFontSize(9);
                table.addHeaderCell(cell);
            }

            // Add data rows
            salesData.getOrders().getContent().forEach(order -> {
                try {
                    table.addCell(new com.itextpdf.layout.element.Cell().add(new com.itextpdf.layout.element.Paragraph(order.getOrderCode() != null ? order.getOrderCode() : "N/A").setFontSize(8)));
                    table.addCell(new com.itextpdf.layout.element.Cell().add(new com.itextpdf.layout.element.Paragraph(order.getOrderDate() != null ? order.getOrderDate().toString().substring(0, 10) : "").setFontSize(8)));
                    table.addCell(new com.itextpdf.layout.element.Cell().add(new com.itextpdf.layout.element.Paragraph(order.getProductName() != null ? order.getProductName() : "N/A").setFontSize(8)));
                    table.addCell(new com.itextpdf.layout.element.Cell().add(new com.itextpdf.layout.element.Paragraph(String.valueOf(order.getQuantity())).setFontSize(8)));
                    
                    // Safe BigDecimal formatting
                    String totalAmountStr = "0 VND";
                    if (order.getTotalAmount() != null) {
                        totalAmountStr = String.format("%,.0f VND", order.getTotalAmount().doubleValue());
                    }
                    table.addCell(new com.itextpdf.layout.element.Cell().add(new com.itextpdf.layout.element.Paragraph(totalAmountStr).setFontSize(8)));
                    
                    table.addCell(new com.itextpdf.layout.element.Cell().add(new com.itextpdf.layout.element.Paragraph(order.getStatus() != null ? order.getStatus().name() : "N/A").setFontSize(8)));
                    table.addCell(new com.itextpdf.layout.element.Cell().add(new com.itextpdf.layout.element.Paragraph(order.getBuyerName() != null ? order.getBuyerName() : "N/A").setFontSize(8)));
                    
                    // Safe escrow formatting
                    String escrowHeldStr = "0 VND";
                    if (order.getEscrowHeld() != null) {
                        escrowHeldStr = String.format("%,.0f VND", order.getEscrowHeld().doubleValue());
                    }
                    table.addCell(new com.itextpdf.layout.element.Cell().add(new com.itextpdf.layout.element.Paragraph(escrowHeldStr).setFontSize(8)));
                    
                    String escrowReleasedStr = "0 VND";
                    if (order.getEscrowReleased() != null) {
                        escrowReleasedStr = String.format("%,.0f VND", order.getEscrowReleased().doubleValue());
                    }
                    table.addCell(new com.itextpdf.layout.element.Cell().add(new com.itextpdf.layout.element.Paragraph(escrowReleasedStr).setFontSize(8)));
                    
                    table.addCell(new com.itextpdf.layout.element.Cell().add(new com.itextpdf.layout.element.Paragraph(order.getEscrowHoldUntil() != null ? order.getEscrowHoldUntil().toString().substring(0, 10) : "N/A").setFontSize(8)));
                } catch (Exception e) {
                    log.error("Error adding order row to PDF: orderId={}, error={}", order.getOrderId(), e.getMessage());
                    // Add empty cells to maintain table structure
                    for (int i = 0; i < 10; i++) {
                        table.addCell(new com.itextpdf.layout.element.Cell().add(new com.itextpdf.layout.element.Paragraph("ERROR").setFontSize(8)));
                    }
                }
            });

            document.add(table);
            document.close();
            
            // Flush and close the output stream
            response.getOutputStream().flush();
            
            log.info("Successfully exported sales PDF");
            
        } catch (Exception e) {
            log.error("Error exporting sales PDF", e);
            e.printStackTrace();
            
            String errorMsg = e.getMessage() != null ? e.getMessage() : e.getClass().getSimpleName();
            if (e.getCause() != null && e.getCause().getMessage() != null) {
                errorMsg += " - " + e.getCause().getMessage();
            }
            
            response.reset();
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().write("<script>alert('Lỗi khi xuất PDF: " + errorMsg + "\\n\\nVui lòng kiểm tra console log để biết chi tiết.'); window.history.back();</script>");
        }
    }

    /**
     * Export Product Performance data to PDF
     * GET /seller/dashboard/products/export
     */
    @GetMapping("/products/export")
    public void exportProductsPDF(
            @RequestParam(value = "timeFilter", defaultValue = "30days") String timeFilter,
            @RequestParam(required = false) String startDate,
            @RequestParam(required = false) String endDate,
            @RequestParam(required = false) Long categoryId,
            @RequestParam(value = "sortBy", defaultValue = "revenue") String sortBy,
            HttpServletResponse response) throws Exception {

        log.info("Exporting product performance data to PDF");

        // Set response headers BEFORE getting output stream
        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "attachment; filename=products_report.pdf");
        response.setHeader("Cache-Control", "no-cache");

        // Get all data (no pagination)
        ProductInventoryDTO productData = dashboardService.getProductInventory(
                timeFilter, startDate, endDate, categoryId, sortBy, 0, 10000);

            // Create PDF document
            com.itextpdf.kernel.pdf.PdfWriter writer = new com.itextpdf.kernel.pdf.PdfWriter(response.getOutputStream());
            com.itextpdf.kernel.pdf.PdfDocument pdfDoc = new com.itextpdf.kernel.pdf.PdfDocument(writer);
            com.itextpdf.layout.Document document = new com.itextpdf.layout.Document(pdfDoc, com.itextpdf.kernel.geom.PageSize.A4.rotate());

            // Add title
            com.itextpdf.layout.element.Paragraph title = new com.itextpdf.layout.element.Paragraph("Báo cáo Hiệu suất Sản phẩm")
                    .setFontSize(18)
                    .setBold()
                    .setTextAlignment(com.itextpdf.layout.properties.TextAlignment.CENTER);
            document.add(title);

            // Add generated date
            com.itextpdf.layout.element.Paragraph date = new com.itextpdf.layout.element.Paragraph("Ngày tạo: " + java.time.LocalDateTime.now().format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss")))
                    .setFontSize(10)
                    .setTextAlignment(com.itextpdf.layout.properties.TextAlignment.CENTER)
                    .setMarginBottom(20);
            document.add(date);

            // Create table
            float[] columnWidths = {3f, 2f, 1.5f, 1.5f, 2f, 1.5f, 1.5f, 1.5f, 1.5f, 1.5f};
            com.itextpdf.layout.element.Table table = new com.itextpdf.layout.element.Table(columnWidths);
            table.setWidth(com.itextpdf.layout.properties.UnitValue.createPercentValue(100));

            // Add headers
            String[] headers = {"Tên sản phẩm", "Danh mục", "Giá", "Đã bán", "Doanh thu", "Tỷ lệ bán", "Còn hàng", "Đã giao", "Hết hạn", "Sắp hết hạn"};
            for (String header : headers) {
                com.itextpdf.layout.element.Cell cell = new com.itextpdf.layout.element.Cell()
                        .add(new com.itextpdf.layout.element.Paragraph(header))
                        .setBackgroundColor(com.itextpdf.kernel.colors.ColorConstants.LIGHT_GRAY)
                        .setBold()
                        .setTextAlignment(com.itextpdf.layout.properties.TextAlignment.CENTER)
                        .setFontSize(9);
                table.addHeaderCell(cell);
            }

            // Add data rows
            productData.getProducts().getContent().forEach(product -> {
                table.addCell(new com.itextpdf.layout.element.Cell().add(new com.itextpdf.layout.element.Paragraph(product.getProductName()).setFontSize(8)));
                table.addCell(new com.itextpdf.layout.element.Cell().add(new com.itextpdf.layout.element.Paragraph(product.getCategoryName()).setFontSize(8)));
                table.addCell(new com.itextpdf.layout.element.Cell().add(new com.itextpdf.layout.element.Paragraph(String.format("%,.0f VND", product.getPrice())).setFontSize(8)));
                table.addCell(new com.itextpdf.layout.element.Cell().add(new com.itextpdf.layout.element.Paragraph(String.valueOf(product.getSoldQuantity())).setFontSize(8)));
                table.addCell(new com.itextpdf.layout.element.Cell().add(new com.itextpdf.layout.element.Paragraph(String.format("%,.0f VND", product.getRevenue())).setFontSize(8)));
                table.addCell(new com.itextpdf.layout.element.Cell().add(new com.itextpdf.layout.element.Paragraph(String.format("%.2f%%", product.getSellThroughRate())).setFontSize(8)));
                table.addCell(new com.itextpdf.layout.element.Cell().add(new com.itextpdf.layout.element.Paragraph(String.valueOf(product.getAvailableCount())).setFontSize(8)));
                table.addCell(new com.itextpdf.layout.element.Cell().add(new com.itextpdf.layout.element.Paragraph(String.valueOf(product.getDeliveredCount())).setFontSize(8)));
                table.addCell(new com.itextpdf.layout.element.Cell().add(new com.itextpdf.layout.element.Paragraph(String.valueOf(product.getExpiredCount())).setFontSize(8)));
                table.addCell(new com.itextpdf.layout.element.Cell().add(new com.itextpdf.layout.element.Paragraph(String.valueOf(product.getExpiringSoonCount())).setFontSize(8)));
            });

            document.add(table);
            document.close();
            
            // Flush and close the output stream
            response.getOutputStream().flush();
    }
}
