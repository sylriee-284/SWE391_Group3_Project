package vn.group3.marketplace.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import lombok.RequiredArgsConstructor;
import vn.group3.marketplace.domain.entity.SystemSetting;
import vn.group3.marketplace.service.SystemSettingService;

import java.util.List;

@Controller
@RequestMapping("/admin")
@RequiredArgsConstructor
public class AdminController {

    private final SystemSettingService systemSettingService;

    private static final String SUCCESS_MESSAGE = "successMessage";
    private static final String ERROR_MESSAGE = "errorMessage";
    private static final String REDIRECT_SYSTEM_CONFIG = "redirect:/admin/system-config";

    @GetMapping("/dashboard")
    public String dashboard(Model model) {
        // Load report data: orders, users, revenue, disputes...
        return "admin/dashboard";
    }

    @GetMapping("/categories")
    public String manageCategories() {
        // Parent categories are automatically loaded by GlobalControllerAdvice
        return "admin/categories";
    }

    @GetMapping("/system-config")
    public String systemConfig(Model model) {
        // Load all system settings
        List<SystemSetting> systemSettings = systemSettingService.getAllSettings();
        model.addAttribute("systemSettings", systemSettings);
        return "admin/system-config";
    }

    @PostMapping("/system-config/add")
    public String addSystemSetting(@RequestParam String settingKey,
            @RequestParam String settingValue,
            RedirectAttributes redirectAttributes) {
        try {
            systemSettingService.updateSetting(settingKey, settingValue);
            redirectAttributes.addFlashAttribute(SUCCESS_MESSAGE, "Đã thêm cài đặt hệ thống thành công!");
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute(ERROR_MESSAGE, "Lỗi khi thêm cài đặt: " + e.getMessage());
        }
        return REDIRECT_SYSTEM_CONFIG;
    }

    @PostMapping("/system-config/update")
    public String updateSystemSetting(@RequestParam Long id,
            @RequestParam String settingKey,
            @RequestParam String settingValue,
            RedirectAttributes redirectAttributes) {
        try {
            systemSettingService.updateSetting(settingKey, settingValue);
            redirectAttributes.addFlashAttribute(SUCCESS_MESSAGE, "Đã cập nhật cài đặt hệ thống thành công!");
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute(ERROR_MESSAGE, "Lỗi khi cập nhật cài đặt: " + e.getMessage());
        }
        return REDIRECT_SYSTEM_CONFIG;
    }

    @PostMapping("/system-config/delete")
    public String deleteSystemSetting(@RequestParam Long id,
            RedirectAttributes redirectAttributes) {
        try {
            systemSettingService.deleteSetting(id);
            redirectAttributes.addFlashAttribute(SUCCESS_MESSAGE, "Đã xóa cài đặt hệ thống thành công!");
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute(ERROR_MESSAGE, "Lỗi khi xóa cài đặt: " + e.getMessage());
        }
        return REDIRECT_SYSTEM_CONFIG;
    }

}
