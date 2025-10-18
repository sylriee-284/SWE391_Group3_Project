package vn.group3.marketplace.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class HomeController {
    @GetMapping("/")
    public String root() {
        return "homepage";
    }

    @GetMapping("/homepage")
    public String home(@RequestParam(required = false) String successMessage,
            @RequestParam(required = false) String errorMessage,
            @RequestParam(required = false) boolean showOrderModal,
            Model model) {
        if (successMessage != null) {
            model.addAttribute("successMessage", successMessage);
        }
        if (errorMessage != null) {
            model.addAttribute("errorMessage", errorMessage);
        }
        if (showOrderModal) {
            model.addAttribute("showOrderModal", true);
        }
        return "homepage";
    }

    @GetMapping("/layout")
    public String layout() {
        return "layout";
    }

}
