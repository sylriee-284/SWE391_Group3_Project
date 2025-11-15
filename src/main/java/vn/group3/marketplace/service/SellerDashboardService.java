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
import vn.group3.marketplace.domain.enums.SellerStoresType;
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
        private final SellerStoreRepository sellerStoreRepository;

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
                                .build();

                // KPI Cards
                dto.setRevenue(calculateRevenueKPI(store.getId(), start, end, prevStart, prevEnd));
                dto.setOrderCount(calculateOrderCountKPI(store.getId(), start, end, prevStart, prevEnd));
                dto.setAverageOrderValue(calculateAOVKPI(store.getId(), start, end, prevStart, prevEnd));

                // Escrow KPIs
                EscrowSummaryDTO escrowSummary = getEscrowSummary(store.getId(), start, end);
                dto.setEscrowHeld(createKPICard("Escrow Held", escrowSummary.getTotalHeld(), "VND", null, "neutral",
                                escrowSummary.getHeldCount() + " orders"));
                dto.setEscrowReleased(
                                createKPICard("Escrow Released", escrowSummary.getTotalReleased(), "VND", null, "up",
                                                escrowSummary.getReleasedCount() + " orders"));
                dto.setEscrowRefunded(
                                createKPICard("Escrow Refunded", escrowSummary.getTotalRefunded(), "VND", null, "down",
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
                // Convert orderStatus string to OrderStatus enum
                OrderStatus status = null;
                if (orderStatus != null && !orderStatus.isEmpty()) {
                        try {
                                status = OrderStatus.valueOf(orderStatus);
                        } catch (IllegalArgumentException e) {
                                log.warn("Invalid order status: {}", orderStatus);
                        }
                }
                Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createdAt"));

                // Get orders
                Page<Order> orders = orderRepository.findOrdersForDashboard(
                                store.getId(), status, productId, start, end, pageable);

                // Convert to DTOs
                Page<OrderSummaryDTO> orderDTOs = orders.map(this::convertToOrderSummaryDTO);

                // Build DTO (omit orderStatus since filter removed)
                return SalesAnalyticsDTO.builder()
                                .orders(orderDTOs)
                                .escrowSummary(getEscrowSummary(store.getId(), start, end))
                                .revenueByStatusChart(buildRevenueByStatusChart(store.getId(), start, end))
                                .escrowTimelineChart(buildEscrowTimelineChart(store.getId(), start, end))
                                .timeFilter(timeFilter != null ? timeFilter : "30days")
                                .startDate(startDate)
                                .endDate(endDate)
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
                // Calculate revenue as seller_amount from RELEASED orders (after commission
                // deduction)
                BigDecimal currentRevenue = escrowRepository.sumSellerAmountForReleasedOrders(storeId, start, end);
                BigDecimal prevRevenue = escrowRepository.sumSellerAmountForReleasedOrders(storeId, prevStart, prevEnd);

                BigDecimal changePercent = calculateChangePercent(currentRevenue, prevRevenue);
                String direction = changePercent.compareTo(BigDecimal.ZERO) >= 0 ? "up" : "down";

                return createKPICard("Doanh thu", currentRevenue, "VND", changePercent, direction,
                                "Tổng tiền nhận được sau trừ hoa hồng");
        }

        private KPICardDTO calculateOrderCountKPI(Long storeId, LocalDateTime start, LocalDateTime end,
                        LocalDateTime prevStart, LocalDateTime prevEnd) {
                Long currentCount = orderRepository.countByStoreAndDateRange(storeId, start, end);
                Long prevCount = orderRepository.countByStoreAndDateRange(storeId, prevStart, prevEnd);

                BigDecimal changePercent = calculateChangePercent(
                                BigDecimal.valueOf(currentCount), BigDecimal.valueOf(prevCount));
                String direction = changePercent.compareTo(BigDecimal.ZERO) >= 0 ? "up" : "down";

                return createKPICard("Tổng đơn hàng", BigDecimal.valueOf(currentCount), "đơn",
                                changePercent, direction, "Tất cả trạng thái đơn hàng");
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
                BigDecimal prevAOV = prevCount > 0
                                ? prevRevenue.divide(BigDecimal.valueOf(prevCount), 2, RoundingMode.HALF_UP)
                                : BigDecimal.ZERO;

                BigDecimal changePercent = calculateChangePercent(currentAOV, prevAOV);
                String direction = changePercent.compareTo(BigDecimal.ZERO) >= 0 ? "up" : "down";

                return createKPICard("Giá trị đơn hàng trung bình", currentAOV, "VND/đơn", changePercent, direction,
                                "Doanh thu mỗi đơn hàng");
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
                BigDecimal totalRefunded = BigDecimal.ZERO;

                if (!summary.isEmpty()) {
                        Object[] row = summary.get(0);
                        totalHeld = row[0] != null ? (BigDecimal) row[0] : BigDecimal.ZERO;
                        // row[1] was totalReleased - no longer used
                        totalRefunded = row[2] != null ? (BigDecimal) row[2] : BigDecimal.ZERO;
                }

                Long heldCount = escrowRepository.countByStoreAndStatus(storeId, EscrowStatus.HELD);
                Long refundedCount = escrowRepository.countByStoreAndStatus(storeId, EscrowStatus.CANCELLED);

                // Get escrow_amount from seller_stores table
                BigDecimal escrowAmount = sellerStoreRepository.findById(storeId)
                                .map(SellerStore::getEscrowAmount)
                                .orElse(BigDecimal.ZERO);

                // Get seller store to check fee model
                SellerStore sellerStore = sellerStoreRepository.findById(storeId).orElse(null);
                SellerStoresType feeModel = sellerStore != null ? sellerStore.getFeeModel()
                                : SellerStoresType.PERCENTAGE;
                BigDecimal commissionRate = BigDecimal.ZERO;

                // Set commission rate based on fee model
                if (feeModel == SellerStoresType.PERCENTAGE) {
                        commissionRate = sellerStore.getFeePercentageRate() != null
                                        ? sellerStore.getFeePercentageRate()
                                        : BigDecimal.valueOf(3.00);
                } else if (feeModel == SellerStoresType.NO_FEE) {
                        commissionRate = BigDecimal.ZERO;
                }

                // Calculate total held amount after fee deduction
                BigDecimal totalHeldAfterFee = BigDecimal.ZERO;
                if (totalHeld.compareTo(BigDecimal.ZERO) > 0) {
                        if (feeModel == SellerStoresType.NO_FEE) {
                                totalHeldAfterFee = totalHeld;
                        } else {
                                BigDecimal commissionAmount = totalHeld
                                                .multiply(commissionRate)
                                                .divide(BigDecimal.valueOf(100), 2, RoundingMode.HALF_UP);
                                totalHeldAfterFee = totalHeld.subtract(commissionAmount);
                        }
                }

                // Calculate total seller amount from RELEASED orders in the selected date range
                BigDecimal totalSellerAmount = escrowRepository.sumSellerAmountForReleasedOrders(storeId, start, end);
                Long releasedCount = escrowRepository.countReleasedOrdersInDateRange(storeId, start, end);

                // Upcoming releases (next 30 days)
                LocalDateTime releaseEnd = LocalDateTime.now().plusDays(30);
                List<Object[]> releaseData = escrowRepository.findUpcomingReleaseSchedule(storeId, LocalDateTime.now(),
                                releaseEnd);
                List<ReleaseScheduleDTO> upcomingReleases = releaseData.stream()
                                .map(row -> ReleaseScheduleDTO.builder()
                                                .releaseDate((LocalDateTime) row[0])
                                                .amount((BigDecimal) row[1])
                                                .orderCount(((Long) row[2]).intValue())
                                                .build())
                                .collect(Collectors.toList());

                return EscrowSummaryDTO.builder()
                                .totalHeld(totalHeld)
                                .totalHeldAfterFee(totalHeldAfterFee)
                                .totalReleased(totalSellerAmount != null ? totalSellerAmount : BigDecimal.ZERO)
                                .totalRefunded(totalRefunded)
                                .heldCount(heldCount.intValue())
                                .releasedCount(releasedCount != null ? releasedCount.intValue() : 0)
                                .refundedCount(refundedCount.intValue())
                                .escrowAmount(escrowAmount)
                                .upcomingReleases(upcomingReleases)
                                .build();
        }

        private ChartDataDTO buildRevenueChart(Long storeId, LocalDateTime start, LocalDateTime end) {
                // Get seller_amount from RELEASED orders (revenue after commission deduction)
                List<Object[]> data = escrowRepository.findSellerAmountByDateRange(storeId, start, end);

                // Create a map of date -> seller amount from actual data
                Map<LocalDate, BigDecimal> revenueMap = new HashMap<>();
                for (Object[] row : data) {
                        LocalDate date = ((java.sql.Date) row[0]).toLocalDate();
                        BigDecimal revenue = (BigDecimal) row[1];
                        revenueMap.put(date, revenue);
                }

                // Fill all dates in the range with 0 for missing dates
                List<String> labels = new ArrayList<>();
                List<Object> values = new ArrayList<>();
                DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM");

                LocalDate currentDate = start.toLocalDate();
                LocalDate endDate = end.toLocalDate();

                while (!currentDate.isAfter(endDate)) {
                        labels.add(currentDate.format(formatter));
                        // Use actual seller amount if exists, otherwise 0
                        BigDecimal revenue = revenueMap.getOrDefault(currentDate, BigDecimal.ZERO);
                        values.add(revenue);
                        currentDate = currentDate.plusDays(1);
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
                        labels.add(translateOrderStatus(status));
                        values.add(revenue);
                }

                DatasetDTO dataset = DatasetDTO.builder()
                                .label("Doanh thu theo trạng thái")
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
                                                DatasetDTO.builder().label("Đang giữ").data(heldData)
                                                                .backgroundColor("rgba(255, 206, 86, 0.5)")
                                                                .borderColor("rgba(255, 206, 86, 1)")
                                                                .borderWidth(2).build(),
                                                DatasetDTO.builder().label("Đã giải ngân").data(releasedData)
                                                                .backgroundColor("rgba(75, 192, 192, 0.5)")
                                                                .borderColor("rgba(75, 192, 192, 1)")
                                                                .borderWidth(2).build(),
                                                DatasetDTO.builder().label("Đã hoàn tiền").data(refundedData)
                                                                .backgroundColor("rgba(255, 99, 132, 0.5)")
                                                                .borderColor("rgba(255, 99, 132, 1)")
                                                                .borderWidth(2).build()))
                                .build();
        }

        private ChartDataDTO buildRevenueByProductChart(Long storeId, LocalDateTime start, LocalDateTime end) {
                // Get seller_amount from RELEASED orders (revenue after commission deduction)
                List<Object[]> data = escrowRepository.findTopProductsBySellerAmount(storeId, start, end, 10);

                List<String> labels = new ArrayList<>();
                List<Object> values = new ArrayList<>();

                for (Object[] row : data) {
                        String productName = (String) row[1];
                        BigDecimal revenue = (BigDecimal) row[3];
                        labels.add(productName.length() > 15 ? productName.substring(0, 15) + "..." : productName);
                        values.add(revenue);
                }

                DatasetDTO dataset = DatasetDTO.builder()
                                .label("Doanh thu theo sản phẩm")
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

                List<String> labels = List.of("Còn hàng", "Đã giao", "Hết hạn");
                List<Object> values = List.of(
                                statusCounts.get("AVAILABLE"),
                                statusCounts.get("DELIVERED"),
                                statusCounts.get("EXPIRED"));

                DatasetDTO dataset = DatasetDTO.builder()
                                .label("Trạng thái kho hàng")
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
                                        .title("Cảnh báo tồn kho thấp")
                                        .message(productName + " chỉ còn " + stock + " sản phẩm")
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
                                        .title("Cảnh báo sản phẩm sắp hết hạn")
                                        .message(productName + " sẽ hết hạn vào ngày " + expiryDate.toLocalDate())
                                        .productId(productId)
                                        .timestamp(LocalDateTime.now())
                                        .build());
                }

                return alerts;
        }

        private OrderSummaryDTO convertToOrderSummaryDTO(Order order) {
                EscrowTransaction escrow = escrowRepository.findByOrder(order).orElse(null);

                // Get buyer name safely - handle null case
                String buyerName = null;
                if (order.getBuyer() != null) {
                        buyerName = order.getBuyer().getFullName();
                }

                // Get seller store to check fee model
                SellerStore sellerStore = order.getSellerStore();
                SellerStoresType feeModel = sellerStore != null ? sellerStore.getFeeModel()
                                : SellerStoresType.PERCENTAGE;
                BigDecimal commissionRate = BigDecimal.ZERO;

                // Set commission rate based on fee model
                if (feeModel == SellerStoresType.PERCENTAGE) {
                        // Use configured rate or default 3%
                        commissionRate = sellerStore.getFeePercentageRate() != null
                                        ? sellerStore.getFeePercentageRate()
                                        : BigDecimal.valueOf(3.00);
                } else if (feeModel == SellerStoresType.NO_FEE) {
                        commissionRate = BigDecimal.ZERO;
                }

                // Calculate escrow held amount after fee deduction
                BigDecimal escrowHeldTotal = escrow != null && escrow.getStatus() == EscrowStatus.HELD
                                ? escrow.getTotalAmount()
                                : BigDecimal.ZERO;

                BigDecimal escrowHeldAfterFee = BigDecimal.ZERO;
                if (escrowHeldTotal.compareTo(BigDecimal.ZERO) > 0) {
                        if (feeModel == SellerStoresType.NO_FEE) {
                                // No fee - seller receives 100%
                                escrowHeldAfterFee = escrowHeldTotal;
                        } else {
                                // Calculate after commission deduction
                                BigDecimal commissionAmount = escrowHeldTotal
                                                .multiply(commissionRate)
                                                .divide(BigDecimal.valueOf(100), 2, RoundingMode.HALF_UP);
                                escrowHeldAfterFee = escrowHeldTotal.subtract(commissionAmount);
                        }
                }

                // Calculate commission amount and seller amount (for both HELD and RELEASED
                // orders)
                BigDecimal commissionAmount = BigDecimal.ZERO;
                BigDecimal sellerAmount = BigDecimal.ZERO;

                if (escrow != null) {
                        // Use admin_amount from escrow_transactions table as commission amount
                        commissionAmount = escrow.getAdminAmount() != null ? escrow.getAdminAmount() : BigDecimal.ZERO;
                        sellerAmount = escrow.getSellerAmount();
                }

                return OrderSummaryDTO.builder()
                                .orderId(order.getId())
                                .orderCode("ORD-" + order.getId())
                                .orderDate(order.getCreatedAt())
                                .productName(order.getProductName())
                                .quantity(order.getQuantity())
                                .totalAmount(order.getTotalAmount())
                                .status(order.getStatus())
                                .statusText(translateOrderStatus(order.getStatus()))
                                .buyerName(buyerName)
                                .escrowHeld(escrowHeldTotal)
                                .escrowHeldAfterFee(escrowHeldAfterFee)
                                .sellerAmount(sellerAmount)
                                .escrowHoldUntil(escrow != null ? escrow.getHoldUntil() : null)
                                .isReleased(escrow != null && escrow.getStatus() == EscrowStatus.RELEASED)
                                .feeModel(feeModel)
                                .commissionRate(commissionRate)
                                .commissionAmount(commissionAmount)
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

                // Calculate revenue for the specific product (using sellerAmount from RELEASED
                // escrow transactions)
                BigDecimal revenue = escrowRepository.sumSellerAmountByProduct(
                                getCurrentSellerStore().getId(), productId, start, end);

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
                                ? BigDecimal.valueOf(deliveredCount)
                                                .divide(BigDecimal.valueOf(totalInventory), 4, RoundingMode.HALF_UP)
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

        /**
         * Helper method to translate OrderStatus to Vietnamese
         */
        private String translateOrderStatus(OrderStatus status) {
                return switch (status) {
                        case PENDING -> "Chờ xử lý";
                        case PAID -> "Đã thanh toán";
                        case COMPLETED -> "Hoàn thành";
                        case CANCELLED -> "Đã hủy";
                        case REFUNDED -> "Đã hoàn tiền";
                        default -> status.name();
                };
        }
}
