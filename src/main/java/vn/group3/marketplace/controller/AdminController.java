package vn.group3.marketplace.controller;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import vn.group3.marketplace.domain.entity.SystemSetting;
import vn.group3.marketplace.service.SystemSettingService;

@Controller
@RequestMapping("/admin")
@RequiredArgsConstructor
@Slf4j
public class AdminController {

    private final SystemSettingService systemSettingService;

    private static final String SUCCESS_MESSAGE = "successMessage";
    private static final String ERROR_MESSAGE = "errorMessage";
    private static final String MODEL_SYSTEM_SETTINGS = "systemSettings";
    private static final String REDIRECT_SYSTEM_CONFIG = "redirect:/admin/system-config";
    private static final int DEFAULT_PAGE_SIZE = 10;

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
    public String systemConfig(@RequestParam(defaultValue = "0") int page,
            @RequestParam(required = false) Integer size,
            Model model) {
        if (page < 0)
            page = 0;
        int pageSize = (size == null || size <= 0) ? DEFAULT_PAGE_SIZE : size;

        Pageable pageable = PageRequest.of(page, pageSize, Sort.by(Sort.Direction.DESC, "createdAt"));
        Page<SystemSetting> pageResult = systemSettingService.getSettings(pageable);

        // Paging helpers
        int totalPages = pageResult.getTotalPages();
        int currentPage = page;
        int window = 2;
        int start = Math.max(0, currentPage - window);
        int end = Math.min(Math.max(0, totalPages - 1), currentPage + window);
        java.util.List<Integer> pages = new java.util.ArrayList<>();
        for (int i = start; i <= end; i++) {
            pages.add(i);
        }

        model.addAttribute(MODEL_SYSTEM_SETTINGS, pageResult.getContent());
        model.addAttribute("currentPage", currentPage);
        model.addAttribute("totalPages", totalPages);
        model.addAttribute("totalElements", pageResult.getTotalElements());
        model.addAttribute("size", pageSize);
        model.addAttribute("pages", pages);
        model.addAttribute("hasPrev", currentPage > 0);
        model.addAttribute("hasNext", currentPage < totalPages - 1);

        return "admin/system-config";
    }

    // filter system settings
    @PostMapping("/system-config/filter")
    public String filterSystemSettings(
            @RequestParam(required = false) String id,
            @RequestParam(required = false) String settingKey,
            @RequestParam(required = false) String settingValue,
            @RequestParam(required = false, name = "createdFrom") String createdFrom,
            @RequestParam(required = false, name = "createdTo") String createdTo,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(required = false) Integer size,
            Model model) {

        Long parsedId = null;
        try {
            if (id != null && !id.isBlank()) {
                parsedId = Long.parseLong(id.trim());
            }
        } catch (NumberFormatException ex) {
        }

        java.time.LocalDate from = null;
        java.time.LocalDate to = null;
        try {
            if (createdFrom != null && !createdFrom.isBlank()) {
                from = java.time.LocalDate.parse(createdFrom);
            }
            if (createdTo != null && !createdTo.isBlank()) {
                to = java.time.LocalDate.parse(createdTo);
            }
        } catch (Exception ex) {
        }

        if (page < 0)
            page = 0;
        int pageSize = (size == null || size <= 0) ? DEFAULT_PAGE_SIZE : size;
        Pageable pageable = PageRequest.of(page, pageSize, Sort.by(Sort.Direction.DESC, "createdAt"));

        Page<SystemSetting> filtered = systemSettingService.filterSettings(
                parsedId,
                settingKey,
                settingValue,
                from,
                to,
                pageable);

        // Paging helpers
        int totalPages = filtered.getTotalPages();
        int currentPage = page;
        int window = 2;
        int start = Math.max(0, currentPage - window);
        int end = Math.min(Math.max(0, totalPages - 1), currentPage + window);
        java.util.List<Integer> pages = new java.util.ArrayList<>();
        for (int i = start; i <= end; i++) {
            pages.add(i);
        }

        model.addAttribute(MODEL_SYSTEM_SETTINGS, filtered.getContent());
        model.addAttribute("currentPage", currentPage);
        model.addAttribute("totalPages", totalPages);
        model.addAttribute("totalElements", filtered.getTotalElements());
        model.addAttribute("size", pageSize);
        model.addAttribute("pages", pages);
        model.addAttribute("hasPrev", currentPage > 0);
        model.addAttribute("hasNext", currentPage < totalPages - 1);
        model.addAttribute("filtered", true);
        model.addAttribute("filterId", id);
        model.addAttribute("filterSettingKey", settingKey);
        model.addAttribute("filterSettingValue", settingValue);
        model.addAttribute("filterCreatedFrom", createdFrom);
        model.addAttribute("filterCreatedTo", createdTo);

        return "admin/system-config";
    }

    // Handle pagination for filtered results
    @GetMapping("/system-config/filter")
    public String filterSystemSettingsGet(
            @RequestParam(required = false) String id,
            @RequestParam(required = false) String settingKey,
            @RequestParam(required = false) String settingValue,
            @RequestParam(required = false, name = "createdFrom") String createdFrom,
            @RequestParam(required = false, name = "createdTo") String createdTo,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(required = false) Integer size,
            Model model) {

        Long parsedId = null;
        try {
            if (id != null && !id.isBlank()) {
                parsedId = Long.parseLong(id.trim());
            }
        } catch (NumberFormatException ex) {
        }

        java.time.LocalDate from = null;
        java.time.LocalDate to = null;
        try {
            if (createdFrom != null && !createdFrom.isBlank()) {
                from = java.time.LocalDate.parse(createdFrom);
            }
            if (createdTo != null && !createdTo.isBlank()) {
                to = java.time.LocalDate.parse(createdTo);
            }
        } catch (Exception ex) {
        }

        if (page < 0)
            page = 0;
        int pageSize = (size == null || size <= 0) ? DEFAULT_PAGE_SIZE : size;
        Pageable pageable = PageRequest.of(page, pageSize, Sort.by(Sort.Direction.DESC, "createdAt"));

        Page<SystemSetting> filtered = systemSettingService.filterSettings(
                parsedId,
                settingKey,
                settingValue,
                from,
                to,
                pageable);

        // Paging helpers
        int totalPages = filtered.getTotalPages();
        int currentPage = page;
        int window = 2;
        int start = Math.max(0, currentPage - window);
        int end = Math.min(Math.max(0, totalPages - 1), currentPage + window);
        java.util.List<Integer> pages = new java.util.ArrayList<>();
        for (int i = start; i <= end; i++) {
            pages.add(i);
        }

        model.addAttribute(MODEL_SYSTEM_SETTINGS, filtered.getContent());
        model.addAttribute("currentPage", currentPage);
        model.addAttribute("totalPages", totalPages);
        model.addAttribute("totalElements", filtered.getTotalElements());
        model.addAttribute("size", pageSize);
        model.addAttribute("pages", pages);
        model.addAttribute("hasPrev", currentPage > 0);
        model.addAttribute("hasNext", currentPage < totalPages - 1);
        model.addAttribute("filtered", true);
        model.addAttribute("filterId", id);
        model.addAttribute("filterSettingKey", settingKey);
        model.addAttribute("filterSettingValue", settingValue);
        model.addAttribute("filterCreatedFrom", createdFrom);
        model.addAttribute("filterCreatedTo", createdTo);

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
