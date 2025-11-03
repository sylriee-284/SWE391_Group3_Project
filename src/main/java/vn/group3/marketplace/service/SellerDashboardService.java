package vn.group3.marketplace.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.group3.marketplace.domain.entity.*;
import vn.group3.marketplace.domain.enums.EscrowStatus;
import vn.group3.marketplace.domain.enums.OrderStatus;
import vn.group3.marketplace.domain.enums.ProductStorageStatus;
import vn.group3.marketplace.dto.dashboard.*;
import vn.group3.marketplace.dto.dashboard.ChartDataDTO.DatasetDTO;
import vn.group3.marketplace.dto.dashboard.EscrowSummaryDTO.ReleaseScheduleDTO;
import vn.group3.marketplace.repository.*;
import vn.group3.marketplace.security.CustomUserDetails;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * Service for Seller Dashboard operations
 */
@Service
@RequiredArgsConstructor
@Slf4j
@Transactional(readOnly = true)
public class SellerDashboardService {

    private final OrderRepository orderRepository;
    private final ProductRepository productRepository;
    private final EscrowTransactionRepository escrowRepository;
    private final ProductStorageRepository productStorageRepository;

    private static final int LOW_STOCK_THRESHOLD = 10;
    private static final int EXPIRING_SOON_DAYS = 7;

    /**
     * Get current authenticated seller's store
     */
    private SellerStore getCurrentSellerStore() {
        CustomUserDetails userDetails = (CustomUserDetails) SecurityContextHolder.getContext()
                .getAuthentication().getPrincipal();
        SellerStore store = userDetails.getUser().getSellerStore();
        if (store == null) {
            throw new IllegalStateException("Current user is not a seller");
        }
        return store;
    }

    /**
     * Parse date range from filter parameters
     */
    private LocalDateTime[] parseDateRange(String timeFilter, String startDate, String endDate) {
        LocalDateTime start;
        LocalDateTime end = LocalDateTime.now();

        if ("custom".equals(timeFilter) && startDate != null && endDate != null) {
            start = LocalDate.parse(startDate).atStartOfDay();
            end = LocalDate.parse(endDate).atTime(LocalTime.MAX);
        } else if ("today".equals(timeFilter)) {
            start = LocalDate.now().atStartOfDay();
        } else if ("7days".equals(timeFilter)) {
            start = LocalDateTime.now().minusDays(7);
        } else { // default 30days
            start = LocalDateTime.now().minusDays(30);
        }

        return new LocalDateTime[] { start, end };
    }

    /**
     * Screen 1: Get Dashboard Overview
     */
    @PreAuthorize("hasRole('SELLER')")
    public DashboardOverviewDTO getOverview(String timeFilter, String startDate, String endDate,
            Long productId, Long categoryId) {
        SellerStore store = getCurrentSellerStore();
        LocalDateTime[] dateRange = parseDateRange(timeFilter, startDate, endDate);
        LocalDateTime start = dateRange[0];
        LocalDateTime end = dateRange[1];

        // Calculate previous period for comparison
        long daysDiff = java.time.Duration.between(start, end).toDays();
        LocalDateTime prevStart = start.minusDays(daysDiff);
        LocalDateTime prevEnd = start;

        // Build DTO
        DashboardOverviewDTO dto = DashboardOverviewDTO.builder()
                .timeFilter(timeFilter != null ? timeFilter : "30days")
                .startDate(startDate)
                .endDate(endDate)
                .productId(productId)
                .categoryId(categoryId)
                .build();

        // KPI Cards
        dto.setRevenue(calculateRevenueKPI(store.getId(), start, end, prevStart, prevEnd));
        dto.setOrderCount(calculateOrderCountKPI(store.getId(), start, end, prevStart, prevEnd));
        dto.setAverageOrderValue(calculateAOVKPI(store.getId(), start, end, prevStart, prevEnd));

        // Escrow KPIs
        EscrowSummaryDTO escrowSummary = getEscrowSummary(store.getId(), start, end);
        dto.setEscrowHeld(createKPICard("Escrow Held", escrowSummary.getTotalHeld(), "VND", null, "neutral",
                escrowSummary.getHeldCount() + " orders"));
        dto.setEscrowReleased(createKPICard("Escrow Released", escrowSummary.getTotalReleased(), "VND", null, "up",
                escrowSummary.getReleasedCount() + " orders"));
        dto.setEscrowRefunded(createKPICard("Escrow Refunded", escrowSummary.getTotalRefunded(), "VND", null, "down",
                escrowSummary.getRefundedCount() + " orders"));

        // Shop rating
        dto.setShopRating(calculateShopRatingKPI(store.getId()));

        // Low stock count
        Long lowStockCount = productRepository.countLowStockByStore(store.getId(), LOW_STOCK_THRESHOLD);
        dto.setLowStockCount(createKPICard("Low Stock Products", BigDecimal.valueOf(lowStockCount),
                "products", null, "neutral", "Need attention"));

        // Charts
        dto.setRevenueChart(buildRevenueChart(store.getId(), start, end));
        dto.setTopProductsChart(buildTopProductsChart(store.getId(), start, end));

        // Alerts
        dto.setAlerts(buildAlerts(store.getId()));

        return dto;
    }

    /**
     * Screen 2: Get Sales Analytics
     */
    @PreAuthorize("hasRole('SELLER')")
    public SalesAnalyticsDTO getSalesAnalytics(String timeFilter, String startDate, String endDate,
            String orderStatus, Long productId, int page, int size) {
        SellerStore store = getCurrentSellerStore();
        LocalDateTime[] dateRange = parseDateRange(timeFilter, startDate, endDate);
        LocalDateTime start = dateRange[0];
        LocalDateTime end = dateRange[1];

        // Fix: Check for empty string as well as null
        OrderStatus status = (orderStatus != null && !orderStatus.isEmpty()) 
                ? OrderStatus.valueOf(orderStatus) 
                : null;
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createdAt"));

        // Get orders
        Page<Order> orders = orderRepository.findOrdersForDashboard(
                store.getId(), status, productId, start, end, pageable);

        // Convert to DTOs
        Page<OrderSummaryDTO> orderDTOs = orders.map(this::convertToOrderSummaryDTO);

        // Build DTO
        return SalesAnalyticsDTO.builder()
                .orders(orderDTOs)
                .escrowSummary(getEscrowSummary(store.getId(), start, end))
                .revenueByStatusChart(buildRevenueByStatusChart(store.getId(), start, end))
                .escrowTimelineChart(buildEscrowTimelineChart(store.getId(), start, end))
                .timeFilter(timeFilter != null ? timeFilter : "30days")
                .startDate(startDate)
                .endDate(endDate)
                .orderStatus(orderStatus)
                .productId(productId)
                .build();
    }

    /**
     * Screen 3: Get Product Performance & Inventory
     */
    @PreAuthorize("hasRole('SELLER')")
    public ProductInventoryDTO getProductInventory(String timeFilter, String startDate, String endDate,
            Long categoryId, String sortBy, int page, int size) {
        SellerStore store = getCurrentSellerStore();
        LocalDateTime[] dateRange = parseDateRange(timeFilter, startDate, endDate);
        LocalDateTime start = dateRange[0];
        LocalDateTime end = dateRange[1];

        // Sort options
        Sort sort = switch (sortBy != null ? sortBy : "revenue") {
            case "sold" -> Sort.by(Sort.Direction.DESC, "soldQuantity");
            case "rating" -> Sort.by(Sort.Direction.DESC, "rating");
            default -> Sort.by(Sort.Direction.DESC, "soldQuantity"); // revenue calculated separately
        };

        Pageable pageable = PageRequest.of(page, size, sort);

        // Get product performance
        Page<Object[]> productData = productRepository.findProductPerformanceByStore(
                store.getId(), categoryId, pageable);

        // Convert to DTOs with inventory data
        Page<ProductPerformanceDTO> products = productData.map(row -> {
            Long productId = (Long) row[0];
            return buildProductPerformanceDTO(productId, row, start, end);
        });

        return ProductInventoryDTO.builder()
                .products(products)
                .revenueByProductChart(buildRevenueByProductChart(store.getId(), start, end))
                .inventoryStatusChart(buildInventoryStatusChart(store.getId()))
                .timeFilter(timeFilter != null ? timeFilter : "30days")
                .startDate(startDate)
                .endDate(endDate)
                .categoryId(categoryId)
                .sortBy(sortBy)
                .build();
    }

    // ===== Helper Methods =====

    private KPICardDTO calculateRevenueKPI(Long storeId, LocalDateTime start, LocalDateTime end,
            LocalDateTime prevStart, LocalDateTime prevEnd) {
        BigDecimal currentRevenue = orderRepository.sumRevenueByStoreAndDateRange(storeId, start, end);
        BigDecimal prevRevenue = orderRepository.sumRevenueByStoreAndDateRange(storeId, prevStart, prevEnd);

        BigDecimal changePercent = calculateChangePercent(currentRevenue, prevRevenue);
        String direction = changePercent.compareTo(BigDecimal.ZERO) >= 0 ? "up" : "down";

        return createKPICard("Revenue", currentRevenue, "VND", changePercent, direction, "Total completed orders");
    }

    private KPICardDTO calculateOrderCountKPI(Long storeId, LocalDateTime start, LocalDateTime end,
            LocalDateTime prevStart, LocalDateTime prevEnd) {
        Long currentCount = orderRepository.countByStoreAndDateRange(storeId, start, end);
        Long prevCount = orderRepository.countByStoreAndDateRange(storeId, prevStart, prevEnd);

        BigDecimal changePercent = calculateChangePercent(
                BigDecimal.valueOf(currentCount), BigDecimal.valueOf(prevCount));
        String direction = changePercent.compareTo(BigDecimal.ZERO) >= 0 ? "up" : "down";

        return createKPICard("Total Orders", BigDecimal.valueOf(currentCount), "orders",
                changePercent, direction, "All order statuses");
    }

    private KPICardDTO calculateAOVKPI(Long storeId, LocalDateTime start, LocalDateTime end,
            LocalDateTime prevStart, LocalDateTime prevEnd) {
        BigDecimal currentRevenue = orderRepository.sumRevenueByStoreAndDateRange(storeId, start, end);
        Long currentCount = orderRepository.countByStoreAndDateRange(storeId, start, end);
        BigDecimal currentAOV = currentCount > 0
                ? currentRevenue.divide(BigDecimal.valueOf(currentCount), 2, RoundingMode.HALF_UP)
                : BigDecimal.ZERO;

        BigDecimal prevRevenue = orderRepository.sumRevenueByStoreAndDateRange(storeId, prevStart, prevEnd);
        Long prevCount = orderRepository.countByStoreAndDateRange(storeId, prevStart, prevEnd);
        BigDecimal prevAOV = prevCount > 0 ? prevRevenue.divide(BigDecimal.valueOf(prevCount), 2, RoundingMode.HALF_UP)
                : BigDecimal.ZERO;

        BigDecimal changePercent = calculateChangePercent(currentAOV, prevAOV);
        String direction = changePercent.compareTo(BigDecimal.ZERO) >= 0 ? "up" : "down";

        return createKPICard("Average Order Value", currentAOV, "VND/order", changePercent, direction,
                "Revenue per order");
    }

    private KPICardDTO calculateShopRatingKPI(Long storeId) {
        BigDecimal rating = orderRepository.findStoreRating(storeId);
        Long ratingCount = orderRepository.countStoreRatings(storeId);

        return createKPICard("Shop Rating", rating, "stars", null, "neutral",
                ratingCount + " ratings");
    }

    private KPICardDTO createKPICard(String title, BigDecimal value, String unit, BigDecimal changePercent,
            String direction, String description) {
        return KPICardDTO.builder()
                .title(title)
                .value(value)
                .unit(unit)
                .changePercent(changePercent != null ? changePercent : BigDecimal.ZERO)
                .changeDirection(direction)
                .description(description)
                .build();
    }

    private BigDecimal calculateChangePercent(BigDecimal current, BigDecimal previous) {
        if (previous.compareTo(BigDecimal.ZERO) == 0) {
            return current.compareTo(BigDecimal.ZERO) > 0 ? BigDecimal.valueOf(100) : BigDecimal.ZERO;
        }
        return current.subtract(previous)
                .divide(previous, 4, RoundingMode.HALF_UP)
                .multiply(BigDecimal.valueOf(100))
                .setScale(2, RoundingMode.HALF_UP);
    }

    private EscrowSummaryDTO getEscrowSummary(Long storeId, LocalDateTime start, LocalDateTime end) {
        List<Object[]> summary = escrowRepository.findEscrowSummaryByStore(storeId);

        BigDecimal totalHeld = BigDecimal.ZERO;
        BigDecimal totalReleased = BigDecimal.ZERO;
        BigDecimal totalRefunded = BigDecimal.ZERO;

        if (!summary.isEmpty()) {
            Object[] row = summary.get(0);
            totalHeld = row[0] != null ? (BigDecimal) row[0] : BigDecimal.ZERO;
            totalReleased = row[1] != null ? (BigDecimal) row[1] : BigDecimal.ZERO;
            totalRefunded = row[2] != null ? (BigDecimal) row[2] : BigDecimal.ZERO;
        }

        Long heldCount = escrowRepository.countByStoreAndStatus(storeId, EscrowStatus.HELD);
        Long releasedCount = escrowRepository.countByStoreAndStatus(storeId, EscrowStatus.RELEASED);
        Long refundedCount = escrowRepository.countByStoreAndStatus(storeId, EscrowStatus.CANCELLED);

        // Upcoming releases (next 30 days)
        LocalDateTime releaseEnd = LocalDateTime.now().plusDays(30);
        List<Object[]> releaseData = escrowRepository.findUpcomingReleaseSchedule(storeId, LocalDateTime.now(),
                releaseEnd);
        List<ReleaseScheduleDTO> upcomingReleases = releaseData.stream()
                .map(row -> ReleaseScheduleDTO.builder()
                        .releaseDate(((java.sql.Date) row[0]).toLocalDate().atStartOfDay())
                        .amount((BigDecimal) row[1])
                        .orderCount(((Long) row[2]).intValue())
                        .build())
                .collect(Collectors.toList());

        return EscrowSummaryDTO.builder()
                .totalHeld(totalHeld)
                .totalReleased(totalReleased)
                .totalRefunded(totalRefunded)
                .heldCount(heldCount.intValue())
                .releasedCount(releasedCount.intValue())
                .refundedCount(refundedCount.intValue())
                .upcomingReleases(upcomingReleases)
                .build();
    }

    private ChartDataDTO buildRevenueChart(Long storeId, LocalDateTime start, LocalDateTime end) {
        List<Object[]> data = orderRepository.findRevenueByDateRange(storeId, OrderStatus.COMPLETED, start, end);

        List<String> labels = new ArrayList<>();
        List<Object> values = new ArrayList<>();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM");

        for (Object[] row : data) {
            LocalDate date = ((java.sql.Date) row[0]).toLocalDate();
            BigDecimal revenue = (BigDecimal) row[1];
            labels.add(date.format(formatter));
            values.add(revenue);
        }

        DatasetDTO dataset = DatasetDTO.builder()
                .label("Revenue")
                .data(values)
                .backgroundColor("rgba(54, 162, 235, 0.5)")
                .borderColor("rgba(54, 162, 235, 1)")
                .borderWidth(2)
                .build();

        return ChartDataDTO.builder()
                .labels(labels)
                .datasets(List.of(dataset))
                .build();
    }

    private ChartDataDTO buildTopProductsChart(Long storeId, LocalDateTime start, LocalDateTime end) {
        List<Object[]> data = orderRepository.findTopProductsByStore(storeId, start, end, 10);

        List<String> labels = new ArrayList<>();
        List<Object> revenues = new ArrayList<>();
        List<Object> quantities = new ArrayList<>();

        for (Object[] row : data) {
            String productName = (String) row[1];
            BigDecimal revenue = (BigDecimal) row[3];
            Long quantity = (Long) row[4];

            labels.add(productName.length() > 20 ? productName.substring(0, 20) + "..." : productName);
            revenues.add(revenue);
            quantities.add(quantity);
        }

        DatasetDTO revenueDataset = DatasetDTO.builder()
                .label("Revenue (VND)")
                .data(revenues)
                .backgroundColor("rgba(75, 192, 192, 0.5)")
                .borderColor("rgba(75, 192, 192, 1)")
                .borderWidth(2)
                .build();

        return ChartDataDTO.builder()
                .labels(labels)
                .datasets(List.of(revenueDataset))
                .build();
    }

    private ChartDataDTO buildRevenueByStatusChart(Long storeId, LocalDateTime start, LocalDateTime end) {
        List<Object[]> data = orderRepository.countOrdersByStatusAndDateRange(storeId, start, end);

        List<String> labels = new ArrayList<>();
        List<Object> values = new ArrayList<>();

        for (Object[] row : data) {
            OrderStatus status = (OrderStatus) row[0];
            BigDecimal revenue = row[2] != null ? (BigDecimal) row[2] : BigDecimal.ZERO;
            labels.add(status.name());
            values.add(revenue);
        }

        DatasetDTO dataset = DatasetDTO.builder()
                .label("Revenue by Status")
                .data(values)
                .backgroundColor("rgba(255, 99, 132, 0.5)")
                .borderColor("rgba(255, 99, 132, 1)")
                .borderWidth(2)
                .build();

        return ChartDataDTO.builder()
                .labels(labels)
                .datasets(List.of(dataset))
                .build();
    }

    private ChartDataDTO buildEscrowTimelineChart(Long storeId, LocalDateTime start, LocalDateTime end) {
        List<Object[]> data = escrowRepository.findEscrowTimelineByDateRange(storeId, start, end);

        Map<String, BigDecimal> heldMap = new HashMap<>();
        Map<String, BigDecimal> releasedMap = new HashMap<>();
        Map<String, BigDecimal> refundedMap = new HashMap<>();
        List<String> allDates = new ArrayList<>();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM");

        for (Object[] row : data) {
            LocalDate date = ((java.sql.Date) row[0]).toLocalDate();
            String dateStr = date.format(formatter);
            EscrowStatus status = (EscrowStatus) row[1];
            BigDecimal amount = (BigDecimal) row[2];

            if (!allDates.contains(dateStr)) {
                allDates.add(dateStr);
            }

            switch (status) {
                case HELD -> heldMap.put(dateStr, amount);
                case RELEASED -> releasedMap.put(dateStr, amount);
                case CANCELLED -> refundedMap.put(dateStr, amount);
            }
        }

        List<Object> heldData = allDates.stream().map(d -> heldMap.getOrDefault(d, BigDecimal.ZERO))
                .collect(Collectors.toList());
        List<Object> releasedData = allDates.stream().map(d -> releasedMap.getOrDefault(d, BigDecimal.ZERO))
                .collect(Collectors.toList());
        List<Object> refundedData = allDates.stream().map(d -> refundedMap.getOrDefault(d, BigDecimal.ZERO))
                .collect(Collectors.toList());

        return ChartDataDTO.builder()
                .labels(allDates)
                .datasets(List.of(
                        DatasetDTO.builder().label("Held").data(heldData)
                                .backgroundColor("rgba(255, 206, 86, 0.5)").borderColor("rgba(255, 206, 86, 1)")
                                .borderWidth(2).build(),
                        DatasetDTO.builder().label("Released").data(releasedData)
                                .backgroundColor("rgba(75, 192, 192, 0.5)").borderColor("rgba(75, 192, 192, 1)")
                                .borderWidth(2).build(),
                        DatasetDTO.builder().label("Refunded").data(refundedData)
                                .backgroundColor("rgba(255, 99, 132, 0.5)").borderColor("rgba(255, 99, 132, 1)")
                                .borderWidth(2).build()))
                .build();
    }

    private ChartDataDTO buildRevenueByProductChart(Long storeId, LocalDateTime start, LocalDateTime end) {
        List<Object[]> data = orderRepository.findTopProductsByStore(storeId, start, end, 10);

        List<String> labels = new ArrayList<>();
        List<Object> values = new ArrayList<>();

        for (Object[] row : data) {
            String productName = (String) row[1];
            BigDecimal revenue = (BigDecimal) row[3];
            labels.add(productName.length() > 15 ? productName.substring(0, 15) + "..." : productName);
            values.add(revenue);
        }

        DatasetDTO dataset = DatasetDTO.builder()
                .label("Revenue by Product")
                .data(values)
                .backgroundColor("rgba(153, 102, 255, 0.5)")
                .borderColor("rgba(153, 102, 255, 1)")
                .borderWidth(2)
                .build();

        return ChartDataDTO.builder()
                .labels(labels)
                .datasets(List.of(dataset))
                .build();
    }

    private ChartDataDTO buildInventoryStatusChart(Long storeId) {
        List<Object[]> data = productStorageRepository.countInventoryByStoreGroupByStatus(storeId);

        Map<String, Long> statusCounts = new HashMap<>();
        statusCounts.put("AVAILABLE", 0L);
        statusCounts.put("DELIVERED", 0L);
        statusCounts.put("EXPIRED", 0L);

        for (Object[] row : data) {
            ProductStorageStatus status = (ProductStorageStatus) row[1];
            Long count = (Long) row[2];
            statusCounts.put(status.name(), statusCounts.getOrDefault(status.name(), 0L) + count);
        }

        List<String> labels = List.of("Available", "Delivered", "Expired");
        List<Object> values = List.of(
                statusCounts.get("AVAILABLE"),
                statusCounts.get("DELIVERED"),
                statusCounts.get("EXPIRED"));

        DatasetDTO dataset = DatasetDTO.builder()
                .label("Inventory Status")
                .data(values)
                .backgroundColor("rgba(255, 159, 64, 0.5)")
                .borderColor("rgba(255, 159, 64, 1)")
                .borderWidth(2)
                .build();

        return ChartDataDTO.builder()
                .labels(labels)
                .datasets(List.of(dataset))
                .build();
    }

    private List<AlertDTO> buildAlerts(Long storeId) {
        List<AlertDTO> alerts = new ArrayList<>();
        LocalDateTime thresholdDate = LocalDateTime.now().plusDays(EXPIRING_SOON_DAYS);

        // Low stock alerts
        List<Object[]> lowStock = productRepository.findLowStockProducts(storeId, LOW_STOCK_THRESHOLD);
        for (Object[] row : lowStock) {
            Long productId = (Long) row[0];
            String productName = (String) row[1];
            Integer stock = (Integer) row[2];
            alerts.add(AlertDTO.builder()
                    .type("low-stock")
                    .severity("high")
                    .title("Low Stock Alert")
                    .message(productName + " has only " + stock + " items left")
                    .productId(productId)
                    .timestamp(LocalDateTime.now())
                    .build());
        }

        // Expiring stock alerts
        List<Object[]> expiring = productStorageRepository.findExpiringStock(storeId, thresholdDate, 5);
        for (Object[] row : expiring) {
            Long productId = (Long) row[0];
            String productName = (String) row[1];
            LocalDateTime expiryDate = (LocalDateTime) row[2];
            alerts.add(AlertDTO.builder()
                    .type("expired-soon")
                    .severity("medium")
                    .title("Expiring Stock Alert")
                    .message(productName + " will expire on " + expiryDate.toLocalDate())
                    .productId(productId)
                    .timestamp(LocalDateTime.now())
                    .build());
        }

        return alerts;
    }

    private OrderSummaryDTO convertToOrderSummaryDTO(Order order) {
        EscrowTransaction escrow = escrowRepository.findByOrder(order).orElse(null);

        return OrderSummaryDTO.builder()
                .orderId(order.getId())
                .orderCode("ORD-" + order.getId())
                .orderDate(order.getCreatedAt())
                .productName(order.getProductName())
                .quantity(order.getQuantity())
                .totalAmount(order.getTotalAmount())
                .status(order.getStatus())
                .buyerName(order.getBuyer().getFullName())
                .escrowHeld(escrow != null && escrow.getStatus() == EscrowStatus.HELD ? escrow.getTotalAmount()
                        : BigDecimal.ZERO)
                .escrowReleased(escrow != null && escrow.getStatus() == EscrowStatus.RELEASED ? escrow.getTotalAmount()
                        : BigDecimal.ZERO)
                .escrowHoldUntil(escrow != null ? escrow.getHoldUntil() : null)
                .build();
    }

    private ProductPerformanceDTO buildProductPerformanceDTO(Long productId, Object[] row,
            LocalDateTime start, LocalDateTime end) {
        String productName = (String) row[1];
        String categoryName = (String) row[2];
        BigDecimal price = (BigDecimal) row[3];
        Integer soldQuantity = (Integer) row[4];
        BigDecimal rating = (BigDecimal) row[5];
        Integer ratingCount = (Integer) row[6];
        // Integer stock = (Integer) row[7]; // Not used in DTO

        // Calculate revenue for the period
        BigDecimal revenue = orderRepository.sumRevenueByStoreAndStatusAndDateRange(
                getCurrentSellerStore().getId(), OrderStatus.COMPLETED, start, end);

        // Get inventory status
        List<Object[]> inventoryData = productStorageRepository.countByProductIdAndGroupByStatus(productId);
        Map<ProductStorageStatus, Long> inventoryCounts = new HashMap<>();
        for (Object[] inv : inventoryData) {
            ProductStorageStatus status = (ProductStorageStatus) inv[0];
            Long count = (Long) inv[1];
            inventoryCounts.put(status, count);
        }

        Integer availableCount = inventoryCounts.getOrDefault(ProductStorageStatus.AVAILABLE, 0L).intValue();
        Integer deliveredCount = inventoryCounts.getOrDefault(ProductStorageStatus.DELIVERED, 0L).intValue();
        Integer expiredCount = inventoryCounts.getOrDefault(ProductStorageStatus.EXPIRED, 0L).intValue();

        // Calculate sell-through rate
        Integer totalInventory = availableCount + deliveredCount + expiredCount;
        BigDecimal sellThroughRate = totalInventory > 0
                ? BigDecimal.valueOf(deliveredCount).divide(BigDecimal.valueOf(totalInventory), 4, RoundingMode.HALF_UP)
                        .multiply(BigDecimal.valueOf(100)).setScale(2, RoundingMode.HALF_UP)
                : BigDecimal.ZERO;

        // Count expiring soon
        LocalDateTime thresholdDate = LocalDateTime.now().plusDays(EXPIRING_SOON_DAYS);
        Long expiringSoonCount = productStorageRepository.countExpiringStock(getCurrentSellerStore().getId(),
                thresholdDate);

        return ProductPerformanceDTO.builder()
                .productId(productId)
                .productName(productName)
                .categoryName(categoryName)
                .price(price)
                .soldQuantity(soldQuantity != null ? soldQuantity : 0)
                .revenue(revenue != null ? revenue : BigDecimal.ZERO)
                .rating(rating != null ? rating : BigDecimal.ZERO)
                .ratingCount(ratingCount != null ? ratingCount : 0)
                .sellThroughRate(sellThroughRate)
                .availableCount(availableCount)
                .reservedCount(0) // Reserved is not tracked separately in current schema
                .deliveredCount(deliveredCount)
                .expiredCount(expiredCount)
                .expiringSoonCount(expiringSoonCount.intValue())
                .build();
    }
}
