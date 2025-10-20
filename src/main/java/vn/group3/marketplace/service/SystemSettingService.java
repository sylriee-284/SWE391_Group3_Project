package vn.group3.marketplace.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.springframework.stereotype.Service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import vn.group3.marketplace.domain.entity.SystemSetting;
import vn.group3.marketplace.repository.SystemSettingRepository;

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

    // Cập nhật hoặc tạo mới setting
    public void updateSetting(String key, String value) {
        Optional<SystemSetting> existingSetting = systemSettingRepository.findBySettingKeyAndIsDeletedFalse(key);

        if (existingSetting.isPresent()) {
            SystemSetting setting = existingSetting.get();
            setting.setSettingValue(value);
            systemSettingRepository.save(setting);
            log.info("Updated system setting: {} = {}", key, value);
        } else {
            SystemSetting newSetting = SystemSetting.builder()
                    .settingKey(key)
                    .settingValue(value)
                    .build();
            systemSettingRepository.save(newSetting);
            log.info("Created new system setting: {} = {}", key, value);
        }
    }

    // Soft delete setting theo ID
    public void deleteSetting(Long id) {
        Optional<SystemSetting> setting = systemSettingRepository.findById(id);
        if (setting.isPresent()) {
            SystemSetting systemSetting = setting.get();
            systemSetting.setIsDeleted(true);
            systemSettingRepository.save(systemSetting);
            log.info("Soft deleted system setting with ID: {}", id);
        } else {
            log.warn("System setting with ID {} not found for deletion", id);
        }
    }

    // Soft delete setting theo key
    public void deleteSettingByKey(String key) {
        Optional<SystemSetting> setting = systemSettingRepository.findBySettingKeyAndIsDeletedFalse(key);
        if (setting.isPresent()) {
            SystemSetting systemSetting = setting.get();
            systemSetting.setIsDeleted(true);
            systemSettingRepository.save(systemSetting);
            log.info("Soft deleted system setting: {}", key);
        } else {
            log.warn("System setting with key {} not found for deletion", key);
        }
    }

}
