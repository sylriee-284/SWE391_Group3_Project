// package vn.group3.marketplace.config;

// import org.springframework.context.annotation.Bean;
// import org.springframework.context.annotation.Configuration;
// import org.springframework.security.config.annotation.web.builders.HttpSecurity;
// import org.springframework.security.core.userdetails.User;
// import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
// import org.springframework.security.crypto.password.PasswordEncoder;
// import org.springframework.security.web.SecurityFilterChain;

// @Configuration
// public class SecurityConfig {

//         @Bean
//         public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
//                 http
//                                 .formLogin(form -> form
//                                                 .loginPage("/login") // Trang đăng nhập tùy chỉnh
//                                                 .loginProcessingUrl("/login") // URL xử lý login (có thể thay đổi nếu
//                                                                               // cần)
//                                                 .defaultSuccessUrl("/homepage", true) // Chuyển hướng sau khi đăng nhập
//                                                                                       // thành công
//                                                 .permitAll())
//                                 .logout(logout -> logout
//                                                 .permitAll() // Cho phép tất cả người dùng logout
//                                 )
//                                 .authorizeHttpRequests(authorizeRequests -> authorizeRequests
//                                                 .requestMatchers("/", "/homepage", "/product/**").permitAll() // Cho
//                                                                                                               // phép
//                                                                                                               // truy
//                                                                                                               // cập vào
//                                                                                                               // homepage
//                                                                                                               // và
//                                                                                                               // product
//                                                 .requestMatchers("/admin/**").hasRole("ADMIN")
//                                                 .requestMatchers("/seller/**").hasRole("SELLER")
//                                                 .requestMatchers("/user/**").hasRole("USER")
//                                                 .anyRequest().authenticated() // Các yêu cầu còn lại đều cần đăng nhập
//                                 );

//                 return http.build();
//         }

//         @Bean
//         public PasswordEncoder passwordEncoder() {
//                 return new BCryptPasswordEncoder(); // Mã hóa mật khẩu bằng BCrypt
//         }
// }

package vn.group3.marketplace.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;

@EnableMethodSecurity
@Configuration
public class SecurityConfig {

        @Bean
        public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
                http
                                .csrf(csrf -> csrf.disable())
                                .sessionManagement(session -> session
                                                .sessionCreationPolicy(
                                                                org.springframework.security.config.http.SessionCreationPolicy.IF_REQUIRED)
                                                .maximumSessions(1)
                                                .maxSessionsPreventsLogin(false))
                                .authorizeHttpRequests(auth -> auth
                                                .requestMatchers("/", "/homepage", "/products/**",
                                                                "/login", "/logout", "/register",
                                                                "/css/**", "/js/**", "/images/**",
                                                                "/webjars/**", "/static/**",
                                                                "/WEB-INF/view/**")
                                                .permitAll()
                                                .requestMatchers("/admin/**").hasRole("ADMIN")
                                                .requestMatchers("/seller/**").hasRole("SELLER")
                                                .requestMatchers("/orders/**", "/wallet/**")
                                                .hasAnyRole("USER", "SELLER", "ADMIN")
                                                .anyRequest().authenticated())
                                .formLogin(form -> form
                                                .loginPage("/login")
                                                .loginProcessingUrl("/login")
                                                .defaultSuccessUrl("/homepage", false)
                                                .permitAll())
                                .logout(logout -> logout
                                                .logoutUrl("/logout")
                                                .logoutSuccessUrl("/")
                                                .permitAll());

                return http.build();
        }

        @Bean
        public AuthenticationManager authenticationManager(AuthenticationConfiguration cfg) throws Exception {
                return cfg.getAuthenticationManager();
        }

        @Bean
        public PasswordEncoder passwordEncoder() {
                return new org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder();
        }
}
