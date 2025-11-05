package vn.group3.marketplace.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import vn.group3.marketplace.service.SystemSettingService;

@Configuration
public class GlobalConfig {

    // Base URL
    public static final String BASE_URL = "http://localhost:8080";

    // Escrow scan interval - 1 minute (60 seconds)
    @Bean
    public Long escrowScanIntervalHours(SystemSettingService systemSettingService) {
        // Fixed at 1 minute (60000 milliseconds) for automatic escrow release
        return 60000L; // 1 minute = 60 seconds = 60000 milliseconds
    }
}
