package vn.group3.marketplace.config;

import java.util.Properties;

import org.springframework.boot.autoconfigure.mail.MailProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.JavaMailSenderImpl;

@Configuration
public class MailConfig {

    @Bean
    public MailProperties mailProperties() {
        return new MailProperties();
    }

    @Bean
    public JavaMailSender javaMailSender(MailProperties mailProperties) {
        JavaMailSenderImpl mailSender = new JavaMailSenderImpl();
        mailSender.setHost(mailProperties.getHost());
        mailSender.setPort(mailProperties.getPort());
        mailSender.setUsername(mailProperties.getUsername());
        mailSender.setPassword(mailProperties.getPassword());

        // Cấu hình STARTTLS
        Properties javaMailProperties = new Properties();
        javaMailProperties.put("mail.smtp.auth", "true");
        javaMailProperties.put("mail.smtp.starttls.enable", "true"); // Bật STARTTLS
        javaMailProperties.put("mail.smtp.host", mailProperties.getHost());
        javaMailProperties.put("mail.smtp.port", mailProperties.getPort());

        mailSender.setJavaMailProperties(javaMailProperties);
        return mailSender;
    }
}
