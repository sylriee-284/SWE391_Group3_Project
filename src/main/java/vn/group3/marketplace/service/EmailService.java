package vn.group3.marketplace.service;

import org.springframework.mail.MailException;
import org.springframework.mail.javamail.*;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import jakarta.mail.MessagingException;
import vn.group3.marketplace.domain.entity.Order;

@Service
public class EmailService {

    private static final Logger logger = LoggerFactory.getLogger(EmailService.class);
    private final JavaMailSender javaMailSender;

    public EmailService(JavaMailSender javaMailSender) {
        this.javaMailSender = javaMailSender;
    }

    // Send email (Async)
    @Async("emailTaskExecutor")
    public void sendEmailAsync(String to, String subject, String body) {
        // Use MimeMessagePreparator to prepare email
        MimeMessagePreparator preparator = mimeMessage -> {
            MimeMessageHelper helper = new MimeMessageHelper(mimeMessage, true, "UTF-8");
            helper.setFrom("noreply@mmomarketsystem.com");
            helper.setTo(to);
            helper.setSubject(subject);
            helper.setText(body, true); // true to send HTML email
        };

        try {
            // Send email through JavaMailSender and MimeMessagePreparator
            javaMailSender.send(preparator);
            logger.info("Email sent successfully to: {}", to);
        } catch (MailException e) {
            // Handle email sending error
            logger.error("Error sending email to {}: {}", to, e.getMessage());
        }
    }

    // Send email to user with reset password OTP
    @Async("emailTaskExecutor")
    public void sendEmailWithResetPasswordOTPAsync(String to, String otp) {
        String subject = "Reset Your Password - MMO Market System";
        String resetLink = "http://localhost:8080/reset-password";
        String body = "<html><body>" +
                "<h2>Password Reset Request</h2>" +
                "<p>Hello,</p>" +
                "<p>You have requested to reset your password. Please use the following information:</p>" +
                "<div style='background-color: #f5f5f5; padding: 15px; border-radius: 5px; margin: 10px 0;'>" +
                "<p><strong>Your OTP:</strong> <span style='font-size: 18px; color: #007bff; font-weight: bold;'>"
                + otp + "</span></p>" +
                "</div>" +
                "<p>Click the link below to reset your password:</p>" +
                "<p><a href='" + resetLink
                + "' style='background-color: #007bff; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px;'>Reset Password</a></p>"
                +
                "<p><strong>Note:</strong> This OTP will expire in 10 minutes for security reasons.</p>" +
                "<p>If you did not request this password reset, please ignore this email.</p>" +
                "<br>" +
                "<p>Best regards,<br>MMO Market System Team</p>" +
                "</body></html>";
        sendEmailAsync(to, subject, body);
    }

    // Send email to user with registration OTP
    @Async("emailTaskExecutor")
    public void sendEmailWithRegistrationOTPAsync(String to, String otp) {
        String subject = "Complete Your Registration - MMO Market System";
        String verifyLink = "http://localhost:8080/verify-otp";
        String body = "<html><body>" +
                "<h2>Complete Your Registration</h2>" +
                "<p>Hello,</p>" +
                "<p>Thank you for registering with MMO Market System! To complete your registration, please verify your email address using the OTP below:</p>"
                +
                "<div style='background-color: #f5f5f5; padding: 20px; border-radius: 8px; margin: 20px 0; text-align: center;'>"
                +
                "<p style='margin: 0; font-size: 16px; color: #333;'>Your verification code is:</p>" +
                "<p style='margin: 10px 0 0 0; font-size: 32px; color: #007bff; font-weight: bold; letter-spacing: 4px;'>"
                + otp + "</p>" +
                "</div>" +
                "<p>Please enter this code on the verification page to activate your account:</p>" +
                "<p style='text-align: center; margin: 20px 0;'>" +
                "<a href='" + verifyLink
                + "' style='background-color: #007bff; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; font-weight: bold; display: inline-block;'>Verify Email Address</a>"
                +
                "</p>" +
                "<div style='background-color: #fff3cd; border: 1px solid #ffeaa7; padding: 15px; border-radius: 6px; margin: 20px 0;'>"
                +
                "<p style='margin: 0; color: #856404;'><strong>Important:</strong> This verification code will expire in 10 minutes for security reasons.</p>"
                +
                "</div>" +
                "<p>If you did not create an account with us, please ignore this email.</p>" +
                "<br>" +
                "<p>Welcome to MMO Market System!</p>" +
                "<p>Best regards,<br>MMO Market System Team</p>" +
                "</body></html>";
        sendEmailAsync(to, subject, body);
    }

    // Send email to user with order confirmation
    @Async("emailTaskExecutor")
    public void sendOrderConfirmationEmailAsync(Order order) {
        String subject = "Order Confirmation - MMO Market System";

        // Format date
        String orderDate = order.getCreatedAt() != null
                ? order.getCreatedAt().format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"))
                : java.time.LocalDateTime.now()
                        .format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));

        String body = "<html><body style='font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;'>" +
                "<div style='background-color: #f8f9fa; padding: 20px; border-radius: 8px;'>" +
                "<h2 style='color: #333; margin-bottom: 20px;'>Cảm ơn bạn đã mua hàng từ MMO Market System.</h2>" +

                "<div style='background-color: white; padding: 20px; border-radius: 5px; margin: 10px 0;'>" +
                "<p style='margin: 10px 0;'><strong>Số đơn hàng:</strong> #" + order.getId() + "</p>" +
                "<p style='margin: 10px 0;'><strong>Ngày đặt hàng:</strong> " + orderDate + "</p>" +
                "<p style='margin: 10px 0;'><strong>Mặt hàng:</strong> " + order.getProductName() + "</p>" +
                "<p style='margin: 10px 0;'><strong>Giá:</strong> " + order.getProductPrice() + " ₫</p>" +
                "<p style='margin: 10px 0;'><strong>Số lượng:</strong> " + order.getQuantity() + "</p>" +
                "<p style='margin: 10px 0;'><strong>Thuế:</strong> 0 ₫</p>" +
                "<hr style='border: 1px solid #eee; margin: 15px 0;'>" +
                "<p style='margin: 10px 0; font-size: 18px; font-weight: bold; color: #28a745;'>" +
                "<strong>Tổng cộng:</strong> " + order.getTotalAmount() + " ₫</p>" +
                "</div>" +

                "<div style='background-color: #e9ecef; padding: 15px; border-radius: 5px; margin: 10px 0;'>" +
                "<p style='margin: 5px 0;'><strong>Phương thức thanh toán:</strong> Wallet</p>" +
                "</div>" +

                "<p style='color: #6c757d; font-size: 14px; margin-top: 20px;'>" +
                "Bạn có thắc mắc? Liên hệ MMO Market System</p>" +
                "</div>" +
                "</body></html>";

        sendEmailAsync(order.getBuyer().getEmail(), subject, body);
    }
}