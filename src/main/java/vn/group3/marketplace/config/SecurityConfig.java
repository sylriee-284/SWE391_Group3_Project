package vn.group3.marketplace.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import vn.group3.marketplace.security.CustomAuthenticationSuccessHandler;
import vn.group3.marketplace.security.CustomUserDetailsService;

@EnableMethodSecurity
@Configuration
public class SecurityConfig {

        @Bean
        public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
                http
                                .csrf(csrf -> csrf.disable())
                                .authorizeHttpRequests(auth -> auth
                                                .requestMatchers("/", "/homepage", "/products/**",
                                                                "/login", "/logout", "/register",
                                                                "/css/**", "/js/**", "/images/**",
                                                                "/webjars/**", "/static/**",
                                                                "/WEB-INF/view/**")
                                                .permitAll()
                                                .requestMatchers("/admin/**").hasRole("ADMIN")
                                                .requestMatchers("/seller/**").hasRole("SELLER")
                                                .requestMatchers("/orders/**").hasAnyRole("USER", "SELLER")
                                                .anyRequest().permitAll())
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
