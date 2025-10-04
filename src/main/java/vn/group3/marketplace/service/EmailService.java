package vn.group3.marketplace.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.MailException;
import org.springframework.mail.javamail.*;
import org.springframework.stereotype.Service;

import jakarta.mail.MessagingException;

@Service
public class EmailService {

    @Autowired
    private JavaMailSender javaMailSender;

    public void sendEmail(String to, String subject, String body) throws MessagingException {
        // Use MimeMessagePreparator to prepare email
        MimeMessagePreparator preparator = mimeMessage -> {
            MimeMessageHelper helper = new MimeMessageHelper(mimeMessage, true);
            helper.setFrom("noreply@mmomarketsystem.com");
            helper.setTo(to);
            helper.setSubject(subject);
            helper.setText(body, true); // true to send HTML email
        };

        try {
            // Send email through JavaMailSender and MimeMessagePreparator
            javaMailSender.send(preparator);
            System.out.println("Email sent successfully!");
        } catch (MailException e) {
            // Handle email sending error
            System.err.println("Error sending email: " + e.getMessage());
            throw new MessagingException("Error sending email: " + e.getMessage());
        }
    }
}
