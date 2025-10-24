package vn.group3.marketplace.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import vn.group3.marketplace.service.SystemSettingService;

@Configuration
public class GlobalConfig {

    // Base URL
    public static final String BASE_URL = "http://localhost:8080";

    // Escrow scan interval hours
    @Bean
    public Long escrowScanIntervalHours(SystemSettingService systemSettingService) {
        String hoursStr = systemSettingService.getSettingValue("escrow.default_scan_hours", "0.02");
        // Parse as double and convert to milliseconds
        double hours = Double.parseDouble(hoursStr);
        return (long) (hours * 60 * 60 * 1000);
    }
}
