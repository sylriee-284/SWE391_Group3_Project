package vn.group3.marketplace.config;

import java.util.Properties;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.JavaMailSenderImpl;

import lombok.extern.slf4j.Slf4j;
import vn.group3.marketplace.service.SystemSettingService;

@Configuration
@Slf4j
public class MailConfig {

@Bean
public JavaMailSender javaMailSender(SystemSettingService
systemSettingService) {
JavaMailSenderImpl mailSender = new JavaMailSenderImpl();

// Lấy cấu hình email từ database
String host = systemSettingService.getSettingValue("email.smtp_host");
Integer port = systemSettingService.getIntValue("email.smtp_port", 587);
String username =
systemSettingService.getSettingValue("email.smtp_username");
String password =
systemSettingService.getSettingValue("email.smtp_password");

// Kiểm tra config bắt buộc
if (host == null || username == null || password == null) {
log.error("Missing required email configuration in database!");
log.error("Required keys: email.smtp_host, email.smtp_username,
email.smtp_password");
throw new IllegalStateException(
"Email configuration not found in database. Please insert email settings into
system_settings table.");
}

// Log cấu hình (ẩn password)
log.info("Email Configuration loaded from database - Host: {}, Port: {},
Username: {}",
host, port, username);
mailSender.setHost(host);
mailSender.setPort(port);
mailSender.setUsername(username);
mailSender.setPassword(password);

// Cấu hình STARTTLS
Properties javaMailProperties = new Properties();
javaMailProperties.put("mail.smtp.auth", "true");
javaMailProperties.put("mail.smtp.starttls.enable", "true");
javaMailProperties.put("mail.smtp.host", host);
javaMailProperties.put("mail.smtp.port", port);

// Timeout settings từ database
Integer connectionTimeout =
systemSettingService.getIntValue("email.smtp_connection_timeout", 3000);
Integer timeout = systemSettingService.getIntValue("email.smtp_timeout",
3000);
Integer writeTimeout =
systemSettingService.getIntValue("email.smtp_write_timeout", 3000);

javaMailProperties.put("mail.smtp.connectiontimeout", connectionTimeout);
javaMailProperties.put("mail.smtp.timeout", timeout);
javaMailProperties.put("mail.smtp.writetimeout", writeTimeout);

mailSender.setJavaMailProperties(javaMailProperties);
return mailSender;
}
}
