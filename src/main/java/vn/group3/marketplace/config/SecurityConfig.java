package vn.group3.marketplace.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import vn.group3.marketplace.security.CustomAuthenticationSuccessHandler;

@Configuration
public class SecurityConfig {

    private final CustomAuthenticationSuccessHandler successHandler;

    public SecurityConfig(CustomAuthenticationSuccessHandler successHandler) {
        this.successHandler = successHandler;
    }

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers("/", "/home", "/login",
                                "/css/**", "/js/**", "/images/**")
                        .permitAll()
                        .requestMatchers("/admin/**").hasRole("ADMIN")
                        .requestMatchers("/seller/**").hasRole("SELLER")
                        .requestMatchers("/user/**").hasRole("USER")
                        .anyRequest().authenticated())
                .formLogin(login -> login
                        .loginPage("/login")
                        .successHandler(successHandler) // ✅ dùng custom handler
                        .permitAll())
                .logout(logout -> logout
                        .logoutUrl("/logout")
                        .logoutSuccessUrl("/home")
                        .permitAll())
                .csrf(csrf -> csrf.disable());

        return http.build();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}