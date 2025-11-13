package vn.group3.marketplace.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import vn.group3.marketplace.service.SystemSettingService;

@Configuration
public class GlobalConfig {

    // Base URL
    public static final String BASE_URL = "http://localhost:8080";

    // Escrow scan interval (lấy từ database, đơn vị: giờ)
    @Bean
    public Long escrowScanIntervalHours(SystemSettingService systemSettingService) {
        // Lấy giá trị từ database (đơn vị: giờ)
        Double hours = systemSettingService.getDoubleValue("escrow.default_scan_hours", 0.02);
        // Convert từ giờ sang milliseconds
        return Math.round(hours * 3600 * 1000);
    }
}
