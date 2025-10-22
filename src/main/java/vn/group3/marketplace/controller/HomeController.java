package vn.group3.marketplace.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import vn.group3.marketplace.service.SystemSettingService;

@Controller
public class HomeController {
    private final SystemSettingService systemSettingService;

    public HomeController(SystemSettingService systemSettingService) {
        this.systemSettingService = systemSettingService;
    }

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

        // Set attribute min order with free fee
        model.addAttribute("minOrderWithFreeFee", systemSettingService.getSettingValue("fee.min_order_with_free_fee"));
        model.addAttribute("escrowDefaultHoldMinutes",
                systemSettingService.getSettingValue("escrow.default_hold_minutes"));

        return "homepage";
    }

    @GetMapping("/layout")
    public String layout() {
        return "layout";
    }

}
