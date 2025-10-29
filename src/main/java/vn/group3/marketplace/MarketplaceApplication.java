package vn.group3.marketplace;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EntityScan(basePackages = "vn.group3.marketplace.domain.entity")
@EnableJpaAuditing(auditorAwareRef = "auditorAwareImpl")
@EnableScheduling
public class MarketplaceApplication {

	public static void main(String[] args) {
		// Set JVM timezone to Vietnam time (GMT+7)
		System.setProperty("user.timezone", "Asia/Ho_Chi_Minh");
		SpringApplication.run(MarketplaceApplication.class, args);
	}

}
