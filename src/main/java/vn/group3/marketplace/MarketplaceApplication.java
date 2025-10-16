package vn.group3.marketplace;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.context.annotation.Bean;
import org.springframework.data.domain.AuditorAware;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;
import vn.group3.marketplace.config.AuditorAwareImpl;

@SpringBootApplication
@EntityScan(basePackages = "vn.group3.marketplace.domain.entity")
@EnableJpaAuditing(auditorAwareRef = "auditorAware")
public class MarketplaceApplication {

	@Bean
	public AuditorAware<Long> auditorAware() {
		return new AuditorAwareImpl();
	}

	public static void main(String[] args) {
		SpringApplication.run(MarketplaceApplication.class, args);
	}

}
