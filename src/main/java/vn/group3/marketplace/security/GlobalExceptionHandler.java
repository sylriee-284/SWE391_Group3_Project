package vn.group3.marketplace.security;

import org.springframework.http.HttpStatus;
import org.springframework.mail.MailAuthenticationException;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseStatus;

@ControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(MailAuthenticationException.class)
    @ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
    public String handleMailAuthenticationError(MailAuthenticationException ex, Model model) {
        model.addAttribute("error", "Lỗi xác thực email. Vui lòng kiểm tra thông tin tài khoản của bạn.");
        return "error"; // Render một trang lỗi tùy chỉnh
    }
}
