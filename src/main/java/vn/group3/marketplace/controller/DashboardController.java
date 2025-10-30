package vn.group3.marketplace.controller;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import vn.group3.marketplace.dto.*;
import vn.group3.marketplace.domain.entity.SellerStore;
import vn.group3.marketplace.domain.entity.User;
import vn.group3.marketplace.repository.SellerStoreRepository;
import vn.group3.marketplace.service.DashboardService;
import vn.group3.marketplace.security.CustomUserDetails;

import java.time.LocalDate;
import java.util.List;

@Controller
@RequestMapping("/seller/dashboard")
@RequiredArgsConstructor
public class DashboardController {

        private final DashboardService dashboardService;
        private final SellerStoreRepository sellerStoreRepository;
        private final ObjectMapper objectMapper;

        @GetMapping
        public String dashboard(
                        @AuthenticationPrincipal CustomUserDetails userDetails,
                        @RequestParam(required = false, defaultValue = "LAST_7_DAYS") String timeRange,
                        @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
                        @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
                        @RequestParam(required = false) Long productId,
                        @RequestParam(required = false) Long categoryId,
                        Model model) throws JsonProcessingException {

                if (userDetails == null) {
                        model.addAttribute("error", "Vui lòng đăng nhập để truy cập dashboard");
                        return "error/403";
                }

                User user = userDetails.getUser();

                // Get seller store
                SellerStore store = sellerStoreRepository.findByOwner(user)
                                .orElseThrow(() -> new RuntimeException(
                                                "Bạn chưa có cửa hàng. Vui lòng tạo cửa hàng trước khi truy cập dashboard."));

                // Build filter
                DashboardFilterDTO filter = DashboardFilterDTO.builder()
                                .timeRange(timeRange)
                                .startDate(startDate)
                                .endDate(endDate)
                                .productId(productId)
                                .categoryId(categoryId)
                                .build();

                // Get dashboard data
                DashboardKPIDTO kpis = dashboardService.getKPIs(store.getId(), filter);
                SalesChartDTO salesChart = dashboardService.getSalesChart(store.getId(), filter);
                List<TopProductDTO> topProducts = dashboardService.getTopProducts(store.getId(), filter, "revenue", 10);
                List<DashboardAlertDTO> alerts = dashboardService.getAlerts(store.getId());

                // Convert to JSON for JavaScript
                String salesChartJson = objectMapper.writeValueAsString(salesChart);
                String topProductsJson = objectMapper.writeValueAsString(topProducts);

                // Add to model
                model.addAttribute("store", store);
                model.addAttribute("kpis", kpis);
                model.addAttribute("salesChart", salesChart);
                model.addAttribute("topProducts", topProducts);
                model.addAttribute("alerts", alerts);
                model.addAttribute("filter", filter);
                model.addAttribute("timeRange", timeRange);
                model.addAttribute("salesChartJson", salesChartJson);
                model.addAttribute("topProductsJson", topProductsJson);

                return "seller/dashboard";
        }

        @GetMapping("/api/kpis")
        @ResponseBody
        public DashboardKPIDTO getKPIs(
                        @AuthenticationPrincipal CustomUserDetails userDetails,
                        @RequestParam(required = false, defaultValue = "LAST_7_DAYS") String timeRange,
                        @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
                        @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
                        @RequestParam(required = false) Long productId,
                        @RequestParam(required = false) Long categoryId) {

                User user = userDetails.getUser();
                SellerStore store = sellerStoreRepository.findByOwner(user)
                                .orElseThrow(() -> new RuntimeException("Store not found"));

                DashboardFilterDTO filter = DashboardFilterDTO.builder()
                                .timeRange(timeRange)
                                .startDate(startDate)
                                .endDate(endDate)
                                .productId(productId)
                                .categoryId(categoryId)
                                .build();

                return dashboardService.getKPIs(store.getId(), filter);
        }

        @GetMapping("/api/sales-chart")
        @ResponseBody
        public SalesChartDTO getSalesChart(
                        @AuthenticationPrincipal CustomUserDetails userDetails,
                        @RequestParam(required = false, defaultValue = "LAST_7_DAYS") String timeRange,
                        @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
                        @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {

                User user = userDetails.getUser();
                SellerStore store = sellerStoreRepository.findByOwner(user)
                                .orElseThrow(() -> new RuntimeException("Store not found"));

                DashboardFilterDTO filter = DashboardFilterDTO.builder()
                                .timeRange(timeRange)
                                .startDate(startDate)
                                .endDate(endDate)
                                .build();

                return dashboardService.getSalesChart(store.getId(), filter);
        }

        @GetMapping("/api/top-products")
        @ResponseBody
        public List<TopProductDTO> getTopProducts(
                        @AuthenticationPrincipal CustomUserDetails userDetails,
                        @RequestParam(required = false, defaultValue = "LAST_7_DAYS") String timeRange,
                        @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
                        @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
                        @RequestParam(required = false, defaultValue = "revenue") String sortBy,
                        @RequestParam(required = false, defaultValue = "10") int limit) {

                User user = userDetails.getUser();
                SellerStore store = sellerStoreRepository.findByOwner(user)
                                .orElseThrow(() -> new RuntimeException("Store not found"));

                DashboardFilterDTO filter = DashboardFilterDTO.builder()
                                .timeRange(timeRange)
                                .startDate(startDate)
                                .endDate(endDate)
                                .build();

                return dashboardService.getTopProducts(store.getId(), filter, sortBy, limit);
        }

        @GetMapping("/api/alerts")
        @ResponseBody
        public List<DashboardAlertDTO> getAlerts(@AuthenticationPrincipal CustomUserDetails userDetails) {
                User user = userDetails.getUser();
                SellerStore store = sellerStoreRepository.findByOwner(user)
                                .orElseThrow(() -> new RuntimeException("Store not found"));

                return dashboardService.getAlerts(store.getId());
        }
}
