package vn.group3.marketplace.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class HomeController {
    @GetMapping("/")
    public String root() {
        return "homepage";
    }

    @GetMapping("/homepage")
    public String home() {
        return "homepage";
    }

}
