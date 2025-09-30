package vn.group3.marketplace.config;

import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import lombok.RequiredArgsConstructor;
import vn.group3.marketplace.domain.entity.Role;
import vn.group3.marketplace.repository.RoleRepository;

@Component
@RequiredArgsConstructor
public class DataInitializer implements CommandLineRunner {

    private final RoleRepository roleRepository;

    @Override
    public void run(String... args) throws Exception {
        // Tạo role USER nếu chưa tồn tại
        if (roleRepository.findByCode("USER").isEmpty()) {
            Role userRole = Role.builder()
                    .code("USER")
                    .name("User")
                    .description("Default user role")
                    .build();
            roleRepository.save(userRole);
            System.out.println("Created USER role");
        }

        // Tạo role ADMIN nếu chưa tồn tại
        if (roleRepository.findByCode("ADMIN").isEmpty()) {
            Role adminRole = Role.builder()
                    .code("ADMIN")
                    .name("Administrator")
                    .description("Administrator role")
                    .build();
            roleRepository.save(adminRole);
            System.out.println("Created ADMIN role");
        }
    }
}