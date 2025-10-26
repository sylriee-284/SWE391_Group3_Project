package vn.group3.marketplace.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.*;

@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Value("${app.upload.dir:uploads}")
    private String uploadDir;

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        registry.addResourceHandler("/uploads/**")
                .addResourceLocations("file:" + uploadDir + "/", "classpath:/static/images/products/");
        // Serve images moved to classpath static folder under /images/products/**
        registry.addResourceHandler("/images/products/**")
                .addResourceLocations("classpath:/static/images/products/");
        // Serve old path for backward compatibility
        registry.addResourceHandler("/image/products/**")
                .addResourceLocations("classpath:/static/images/products/");
    }
}
