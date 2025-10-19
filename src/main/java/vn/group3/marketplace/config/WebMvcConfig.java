package vn.group3.marketplace.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.ViewResolver;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.ViewResolverRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;
import org.springframework.lang.NonNull;
import org.springframework.web.servlet.view.InternalResourceViewResolver;
import org.springframework.web.servlet.view.JstlView;

@Configuration
public class WebMvcConfig implements WebMvcConfigurer {

        @Bean
        public ViewResolver viewResolver() {
                final InternalResourceViewResolver bean = new InternalResourceViewResolver();
                bean.setViewClass(JstlView.class);
                bean.setPrefix("/WEB-INF/view/");
                bean.setSuffix(".jsp");
                return bean;
        }

        @Override
        public void configureViewResolvers(@NonNull ViewResolverRegistry registry) {
                registry.viewResolver(viewResolver());
        }

        @Override
        public void addResourceHandlers(@NonNull ResourceHandlerRegistry registry) {
                // Images
                registry.addResourceHandler("/images/**")
                                .addResourceLocations("classpath:/static/images/");

                // CSS files
                registry.addResourceHandler("/resources/css/**")
                                .addResourceLocations("classpath:/static/resources/css/");

                // JS files
                registry.addResourceHandler("/resources/js/**")
                                .addResourceLocations("classpath:/static/resources/js/");

                // All resources
                registry.addResourceHandler("/resources/**")
                                .addResourceLocations("classpath:/static/resources/");

                // Static resources fallback
                registry.addResourceHandler("/**")
                                .addResourceLocations("classpath:/static/");
        }

}
