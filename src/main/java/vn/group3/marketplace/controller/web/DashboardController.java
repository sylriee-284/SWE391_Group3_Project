package vn.group3.marketplace.controller.web;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import vn.group3.marketplace.service.interfaces.UserService;
import vn.group3.marketplace.service.interfaces.WalletService;

import java.util.Map;

/**
 * Dashboard controller for main application dashboard
 */
@Controller
@RequiredArgsConstructor
@Slf4j
public class DashboardController {

    private final UserService userService;
    private final WalletService walletService;

    /**
     * Display main dashboard
     */
    @GetMapping("/")
    public String dashboard(Model model) {
        log.info("Loading dashboard");
        
        try {
            // Get user statistics
            Map<String, Long> userStats = userService.getUserStatistics();
            model.addAttribute("userStats", userStats);
            
            // Get wallet statistics
            Map<String, Object> walletStats = walletService.getWalletStatistics();
            model.addAttribute("walletStats", walletStats);
            
            log.info("Dashboard loaded successfully");
        } catch (Exception e) {
            log.error("Error loading dashboard: {}", e.getMessage());
            model.addAttribute("error", "Có lỗi xảy ra khi tải dashboard");
        }
        
        return "dashboard";
    }

    /**
     * Health check endpoint
     */
    @GetMapping("/health")
    public String health(Model model) {
        model.addAttribute("status", "OK");
        model.addAttribute("message", "TaphoaMMO system is running");
        return "health";
    }
}
