package vn.group3.marketplace.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.group3.marketplace.domain.dto.*;
import vn.group3.marketplace.domain.enums.OrderStatus;
import vn.group3.marketplace.repository.*;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class DashboardService {

    private final OrderRepository orderRepository;
    private final ProductRepository productRepository;
    private final ProductStorageRepository productStorageRepository;
    private final EscrowTransactionRepository escrowTransactionRepository;

    /**
     * Get all KPIs for dashboard
     */
    public DashboardKPIDTO getKPIs(Long storeId, DashboardFilterDTO filter) {
        LocalDate startDate = filter.getEffectiveStartDate();
        LocalDate endDate = filter.getEffectiveEndDate();

        // Convert to LocalDateTime for queries
        LocalDateTime startDateTime = startDate.atStartOfDay();
        LocalDateTime endDateTime = endDate.atTime(23, 59, 59);

        DashboardKPIDTO kpi = new DashboardKPIDTO();

        // Revenue calculation
        List<Object[]> revenueData = orderRepository
                .findRevenueByStoreAndDateRange(storeId, startDateTime, endDateTime);

        if (!revenueData.isEmpty()) {
            Object[] data = revenueData.get(0);
            kpi.setGrossSales((BigDecimal) data[0]);
            kpi.setNetSales((BigDecimal) data[1]); // After refunds
        } else {
            kpi.setGrossSales(BigDecimal.ZERO);
            kpi.setNetSales(BigDecimal.ZERO);
        }

        // Order counts
        kpi.setTotalOrders(orderRepository.countByStoreAndDateRange(storeId, startDateTime, endDateTime));
        kpi.setPendingOrders(orderRepository.countByStoreAndStatusAndDateRange(
                storeId, OrderStatus.PENDING, startDateTime, endDateTime));
        kpi.setCompletedOrders(orderRepository.countByStoreAndStatusAndDateRange(
                storeId, OrderStatus.COMPLETED, startDateTime, endDateTime));
        kpi.setCancelledOrders(orderRepository.countByStoreAndStatusAndDateRange(
                storeId, OrderStatus.CANCELLED, startDateTime, endDateTime));

        // AOV (Average Order Value)
        if (kpi.getTotalOrders() > 0) {
            kpi.setAverageOrderValue(kpi.getGrossSales()
                    .divide(BigDecimal.valueOf(kpi.getTotalOrders()), 2, RoundingMode.HALF_UP));
        } else {
            kpi.setAverageOrderValue(BigDecimal.ZERO);
        }

        // Escrow data
        List<Object[]> escrowData = escrowTransactionRepository.findEscrowSummaryByStore(storeId);
        if (!escrowData.isEmpty()) {
            Object[] data = escrowData.get(0);
            kpi.setEscrowHeld((BigDecimal) data[0]);
            kpi.setEscrowReleased((BigDecimal) data[1]);
            kpi.setEscrowRefunded((BigDecimal) data[2]);
        } else {
            kpi.setEscrowHeld(BigDecimal.ZERO);
            kpi.setEscrowReleased(BigDecimal.ZERO);
            kpi.setEscrowRefunded(BigDecimal.ZERO);
        }

        // Shop rating from SellerStore entity
        BigDecimal rating = orderRepository.findStoreRating(storeId);
        kpi.setShopRating(rating != null ? rating : BigDecimal.ZERO);

        // Stock alerts
        kpi.setLowStockProducts(productRepository.countLowStockByStore(storeId, 10)); // threshold = 10
        kpi.setOutOfStockProducts(productRepository.countOutOfStockByStore(storeId));

        // Refund/Cancel rates
        Long refundCount = orderRepository.countByStoreAndStatusAndDateRange(
                storeId, OrderStatus.REFUNDED, startDateTime, endDateTime);
        Long cancelCount = kpi.getCancelledOrders();

        if (kpi.getTotalOrders() > 0) {
            kpi.setRefundRate((double) refundCount / kpi.getTotalOrders() * 100);
            kpi.setCancelRate((double) cancelCount / kpi.getTotalOrders() * 100);
        } else {
            kpi.setRefundRate(0.0);
            kpi.setCancelRate(0.0);
        }

        // Unique/Repeat buyers
        Long uniqueBuyers = orderRepository.countUniqueBuyers(storeId, startDateTime, endDateTime);
        List<Object[]> repeatBuyersList = orderRepository.findRepeatBuyers(storeId, startDateTime, endDateTime);
        Long repeatBuyers = (long) repeatBuyersList.size();

        kpi.setUniqueBuyers(uniqueBuyers != null ? uniqueBuyers : 0L);
        kpi.setRepeatBuyers(repeatBuyers);

        // Expiring stock (within 7 days)
        LocalDateTime expiryThreshold = LocalDateTime.now().plusDays(7);
        kpi.setExpiringStockCount(productStorageRepository
                .countExpiringStock(storeId, expiryThreshold));

        return kpi;
    }

    /**
     * Get sales chart data
     */
    public SalesChartDTO getSalesChart(Long storeId, DashboardFilterDTO filter) {
        LocalDate startDate = filter.getEffectiveStartDate();
        LocalDate endDate = filter.getEffectiveEndDate();

        List<SalesChartDTO.DataPoint> dataPoints = new ArrayList<>();

        // Determine grouping by date range
        long daysBetween = ChronoUnit.DAYS.between(startDate, endDate);

        if (daysBetween <= 1) {
            // Group by hour for today
            dataPoints = getSalesDataByHour(storeId, startDate);
        } else if (daysBetween <= 31) {
            // Group by day
            dataPoints = getSalesDataByDay(storeId, startDate, endDate);
        } else if (daysBetween <= 90) {
            // Group by week
            dataPoints = getSalesDataByWeek(storeId, startDate, endDate);
        } else {
            // Group by month
            dataPoints = getSalesDataByMonth(storeId, startDate, endDate);
        }

        return SalesChartDTO.builder()
                .dataPoints(dataPoints)
                .build();
    }

    private List<SalesChartDTO.DataPoint> getSalesDataByDay(Long storeId, LocalDate start, LocalDate end) {
        List<SalesChartDTO.DataPoint> points = new ArrayList<>();

        LocalDate current = start;
        while (!current.isAfter(end)) {
            LocalDateTime dayStart = current.atStartOfDay();
            LocalDateTime dayEnd = current.atTime(23, 59, 59);

            BigDecimal revenue = orderRepository.sumRevenueByStoreAndDateRange(
                    storeId, dayStart, dayEnd);
            Long orderCount = orderRepository.countByStoreAndDateRange(storeId, dayStart, dayEnd);
            Long refundCount = orderRepository.countByStoreAndStatusAndDateRange(
                    storeId, OrderStatus.REFUNDED, dayStart, dayEnd);
            Long cancelCount = orderRepository.countByStoreAndStatusAndDateRange(
                    storeId, OrderStatus.CANCELLED, dayStart, dayEnd);

            points.add(SalesChartDTO.DataPoint.builder()
                    .label(current.toString())
                    .date(current)
                    .revenue(revenue != null ? revenue : BigDecimal.ZERO)
                    .orderCount(orderCount != null ? orderCount : 0L)
                    .refundCount(refundCount != null ? refundCount : 0L)
                    .cancelCount(cancelCount != null ? cancelCount : 0L)
                    .build());

            current = current.plusDays(1);
        }

        return points;
    }

    private List<SalesChartDTO.DataPoint> getSalesDataByHour(Long storeId, LocalDate date) {
        List<SalesChartDTO.DataPoint> points = new ArrayList<>();

        for (int hour = 0; hour < 24; hour++) {
            LocalDateTime hourStart = date.atTime(hour, 0);
            LocalDateTime hourEnd = date.atTime(hour, 59, 59);

            BigDecimal revenue = orderRepository.sumRevenueByStoreAndDateRange(
                    storeId, hourStart, hourEnd);
            Long orderCount = orderRepository.countByStoreAndDateRange(storeId, hourStart, hourEnd);

            points.add(SalesChartDTO.DataPoint.builder()
                    .label(String.format("%02d:00", hour))
                    .date(date)
                    .revenue(revenue != null ? revenue : BigDecimal.ZERO)
                    .orderCount(orderCount != null ? orderCount : 0L)
                    .refundCount(0L)
                    .cancelCount(0L)
                    .build());
        }

        return points;
    }

    private List<SalesChartDTO.DataPoint> getSalesDataByWeek(Long storeId, LocalDate start, LocalDate end) {
        // Implementation similar to byDay but group by week
        return getSalesDataByDay(storeId, start, end); // Simplified for now
    }

    private List<SalesChartDTO.DataPoint> getSalesDataByMonth(Long storeId, LocalDate start, LocalDate end) {
        // Implementation similar to byDay but group by month
        return getSalesDataByDay(storeId, start, end); // Simplified for now
    }

    /**
     * Get top products by revenue or units
     */
    public List<TopProductDTO> getTopProducts(Long storeId, DashboardFilterDTO filter,
            String sortBy, int limit) {
        LocalDate startDate = filter.getEffectiveStartDate();
        LocalDate endDate = filter.getEffectiveEndDate();
        LocalDateTime startDateTime = startDate.atStartOfDay();
        LocalDateTime endDateTime = endDate.atTime(23, 59, 59);

        List<Object[]> results = orderRepository.findTopProductsByStore(
                storeId, startDateTime, endDateTime, limit);

        return results.stream()
                .map(row -> TopProductDTO.builder()
                        .productId((Long) row[0])
                        .productName((String) row[1])
                        .categoryName((String) row[2])
                        .totalRevenue((BigDecimal) row[3])
                        .totalUnits((Long) row[4])
                        .currentStock((Integer) row[5])
                        .productRating((BigDecimal) row[6])
                        .build())
                .collect(Collectors.toList());
    }

    /**
     * Get dashboard alerts
     */
    public List<DashboardAlertDTO> getAlerts(Long storeId) {
        List<DashboardAlertDTO> alerts = new ArrayList<>();

        // Low stock alerts
        List<Object[]> lowStockProducts = productRepository.findLowStockProducts(storeId, 10);
        for (Object[] row : lowStockProducts) {
            alerts.add(DashboardAlertDTO.builder()
                    .type("LOW_STOCK")
                    .severity("MEDIUM")
                    .title("Low Stock Alert")
                    .message(String.format("Product '%s' has only %d items left",
                            row[1], row[2]))
                    .link("/seller/products/" + row[0] + "?storeId=" + storeId)
                    .relatedId((Long) row[0])
                    .timestamp(LocalDateTime.now())
                    .build());
        }

        // Out of stock alerts
        List<Object[]> outOfStockProducts = productRepository.findOutOfStockProducts(storeId);
        for (Object[] row : outOfStockProducts) {
            alerts.add(DashboardAlertDTO.builder()
                    .type("OUT_OF_STOCK")
                    .severity("HIGH")
                    .title("Out of Stock")
                    .message(String.format("Product '%s' is out of stock", row[1]))
                    .link("/seller/products/" + row[0] + "?storeId=" + storeId)
                    .relatedId((Long) row[0])
                    .timestamp(LocalDateTime.now())
                    .build());
        }

        // Expiring stock alerts
        LocalDateTime expiryThreshold = LocalDateTime.now().plusDays(7);
        List<Object[]> expiringStock = productStorageRepository
                .findExpiringStock(storeId, expiryThreshold, 20);

        for (Object[] row : expiringStock) {
            alerts.add(DashboardAlertDTO.builder()
                    .type("EXPIRING")
                    .severity("MEDIUM")
                    .title("Stock Expiring Soon")
                    .message(String.format("Product '%s' batch expires on %s",
                            row[1], row[2]))
                    .link("/seller/products/" + row[0] + "?storeId=" + storeId)
                    .relatedId((Long) row[0])
                    .timestamp(LocalDateTime.now())
                    .build());
        }

        // Pending orders
        Long pendingCount = orderRepository.countByStoreAndStatus(storeId, OrderStatus.PENDING);
        if (pendingCount > 0) {
            alerts.add(DashboardAlertDTO.builder()
                    .type("PENDING_ORDER")
                    .severity("MEDIUM")
                    .title("Pending Orders")
                    .message(String.format("You have %d pending orders to process", pendingCount))
                    .link("/seller/orders?status=PENDING")
                    .timestamp(LocalDateTime.now())
                    .build());
        }

        // Refunded orders
        Long refundedCount = orderRepository.countByStoreAndStatus(storeId, OrderStatus.REFUNDED);
        if (refundedCount > 0) {
            alerts.add(DashboardAlertDTO.builder()
                    .type("REFUNDED_ORDER")
                    .severity("LOW")
                    .title("Refunded Orders")
                    .message(String.format("You have %d refunded orders", refundedCount))
                    .link("/seller/orders?status=REFUNDED")
                    .timestamp(LocalDateTime.now())
                    .build());
        }

        // Sort by severity and timestamp
        alerts.sort(Comparator
                .comparing((DashboardAlertDTO a) -> getSeverityOrder(a.getSeverity()))
                .thenComparing(DashboardAlertDTO::getTimestamp, Comparator.reverseOrder()));

        return alerts;
    }

    private int getSeverityOrder(String severity) {
        return switch (severity) {
            case "HIGH" -> 1;
            case "MEDIUM" -> 2;
            case "LOW" -> 3;
            default -> 4;
        };
    }
}
