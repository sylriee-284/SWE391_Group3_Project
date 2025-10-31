package vn.group3.marketplace.service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import vn.group3.marketplace.domain.entity.SystemSetting;
import vn.group3.marketplace.repository.SystemSettingRepository;
import vn.group3.marketplace.security.CustomUserDetails;

@Service
@Slf4j
@RequiredArgsConstructor
public class SystemSettingService {

    private final SystemSettingRepository systemSettingRepository;

    // Lấy giá trị setting theo key (chỉ lấy những cái chưa bị xóa)
    public String getSettingValue(String key) {
        return systemSettingRepository.findBySettingKeyAndIsDeletedFalse(key)
                .map(SystemSetting::getSettingValue)
                .orElse(null);
    }

    // Get admin user ID
    public Long getAdminUserId() {
        String adminUserId = getSettingValue("wallet.admin_default_receive_commission", "1");
        return Long.parseLong(adminUserId);
    }

    // Lấy giá trị setting với giá trị mặc định
    public String getSettingValue(String key, String defaultValue) {
        String value = getSettingValue(key);
        return value != null ? value : defaultValue;
    }

    // Lấy giá trị Integer
    public Integer getIntValue(String key, Integer defaultValue) {
        String value = getSettingValue(key);
        if (value == null) {
            return defaultValue;
        }
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException e) {
            log.warn("Cannot parse setting {} to Integer: {}", key, value);
            return defaultValue;
        }
    }

    // Lấy giá trị Double
    public Double getDoubleValue(String key, Double defaultValue) {
        String value = getSettingValue(key);
        if (value == null) {
            return defaultValue;
        }
        try {
            return Double.parseDouble(value);
        } catch (NumberFormatException e) {
            log.warn("Cannot parse setting {} to Double: {}", key, value);
            return defaultValue;
        }
    }

    // Lấy giá trị Boolean
    public Boolean getBooleanValue(String key, Boolean defaultValue) {
        String value = getSettingValue(key);
        if (value == null) {
            return defaultValue;
        }
        return "TRUE".equalsIgnoreCase(value) || "1".equals(value);
    }

    // Lấy tất cả settings theo prefix
    public Map<String, String> getSettingsByPrefix(String prefix) {
        Map<String, String> result = new HashMap<>();
        systemSettingRepository.findAll().stream()
                .filter(setting -> setting.getSettingKey().startsWith(prefix))
                .forEach(setting -> result.put(setting.getSettingKey(), setting.getSettingValue()));
        return result;
    }

    // Lấy tất cả settings (chỉ lấy những cái chưa bị xóa)
    public List<SystemSetting> getAllSettings() {
        return systemSettingRepository.findByIsDeletedFalse();
    }

    // Lấy settings theo phân trang
    public Page<SystemSetting> getSettings(Pageable pageable) {
        return systemSettingRepository.findByIsDeletedFalse(pageable);
    }

    // Lọc settings theo tiêu chí tùy chọn có phân trang
    public Page<SystemSetting> filterSettings(Long id,
            String settingKey,
            String settingValue,
            LocalDate createdFrom,
            LocalDate createdTo,
            Pageable pageable) {

        log.debug("Filtering settings - ID: {}, Key: {}, Value: {}, From: {}, To: {}",
                id, settingKey, settingValue, createdFrom, createdTo);

        LocalDateTime from = createdFrom != null ? createdFrom.atStartOfDay() : null;
        LocalDateTime to = createdTo != null ? createdTo.atTime(LocalTime.MAX) : null;

        List<SystemSetting> all = systemSettingRepository.findByIsDeletedFalse().stream()
                .filter(s -> id == null || (s.getId() != null && s.getId().equals(id)))
                .filter(s -> settingKey == null || settingKey.isBlank()
                        || (s.getSettingKey() != null
                                && s.getSettingKey().toLowerCase().contains(settingKey.toLowerCase())))
                .filter(s -> settingValue == null || settingValue.isBlank()
                        || (s.getSettingValue() != null
                                && s.getSettingValue().toLowerCase().contains(settingValue.toLowerCase())))
                .filter(s -> {
                    if (from == null)
                        return true;
                    if (s.getCreatedAt() == null)
                        return false;
                    boolean result = !s.getCreatedAt().isBefore(from);
                    log.debug("Date filter FROM: {} >= {} = {}", s.getCreatedAt(), from, result);
                    return result;
                })
                .filter(s -> {
                    if (to == null)
                        return true;
                    if (s.getCreatedAt() == null)
                        return false;
                    boolean result = !s.getCreatedAt().isAfter(to);
                    log.debug("Date filter TO: {} <= {} = {}", s.getCreatedAt(), to, result);
                    return result;
                })
                .toList();

        log.debug("Filtered results count: {}", all.size());

        int total = all.size();
        int start = Math.min((int) pageable.getOffset(), total);
        int end = Math.min(start + pageable.getPageSize(), total);
        List<SystemSetting> content = all.subList(start, end);
        return new PageImpl<>(content, pageable, total);
    }

    // Cập nhật hoặc tạo mới setting
    @PreAuthorize("hasRole('ADMIN')")
    public void updateSetting(String key, String value) {
        Optional<SystemSetting> existingSetting = systemSettingRepository.findBySettingKeyAndIsDeletedFalse(key);

        if (existingSetting.isPresent()) {
            SystemSetting setting = existingSetting.get();
            setting.setSettingValue(value);
            systemSettingRepository.save(setting);
        } else {
            SystemSetting newSetting = SystemSetting.builder()
                    .settingKey(key)
                    .settingValue(value)
                    .build();
            systemSettingRepository.save(newSetting);
        }
    }

    // Soft delete setting theo ID
    @PreAuthorize("hasRole('ADMIN')")
    public void deleteSetting(Long id) {
        Optional<SystemSetting> setting = systemSettingRepository.findById(id);
        if (setting.isPresent()) {
            SystemSetting systemSetting = setting.get();
            systemSetting.setIsDeleted(true);
            // Try to set deleted_by with current user if available in SecurityContext
            try {
                Authentication auth = SecurityContextHolder
                        .getContext().getAuthentication();
                if (auth != null
                        && auth.getPrincipal() instanceof CustomUserDetails cud) {
                    Long currentUserId = cud.getId();
                    systemSetting.setDeletedBy(currentUserId);
                }
            } catch (Exception ignore) {
                // ignore if security context is not available
            }
            systemSettingRepository.save(systemSetting);
        }
    }
}
