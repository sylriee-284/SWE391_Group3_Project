package vn.group3.marketplace.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class AuthController {

    @GetMapping("/login")
    public String login() {
        // JSP: /WEB-INF/views/common/login.jsp
        return "login";
    }
}
