package vn.group3.marketplace.config;

import org.springframework.boot.web.servlet.MultipartConfigFactory;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.util.unit.DataSize;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import jakarta.servlet.MultipartConfigElement;

/**
 * Configuration for file upload functionality
 */
@Configuration
public class FileUploadConfig implements WebMvcConfigurer {

    /**
     * Configure multipart file upload settings
     */
    @Bean
    public MultipartConfigElement multipartConfigElement() {
        MultipartConfigFactory factory = new MultipartConfigFactory();
        
        // Set max file size to 2MB
        factory.setMaxFileSize(DataSize.ofMegabytes(2));
        
        // Set max request size to 10MB (for multiple files)
        factory.setMaxRequestSize(DataSize.ofMegabytes(10));
        
        // Set file size threshold to 1KB (files larger than this will be written to disk)
        factory.setFileSizeThreshold(DataSize.ofKilobytes(1));
        
        return factory.createMultipartConfig();
    }

    /**
     * Configure static resource handlers for uploaded files
     */
    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        // Serve uploaded files from /uploads/** URL pattern
        registry.addResourceHandler("/uploads/**")
                .addResourceLocations("file:uploads/")
                .setCachePeriod(3600); // Cache for 1 hour
    }
}
