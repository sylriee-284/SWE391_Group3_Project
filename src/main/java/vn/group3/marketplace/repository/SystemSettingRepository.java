package vn.group3.marketplace.repository;

import java.util.List;
import java.util.Optional;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import vn.group3.marketplace.domain.entity.SystemSetting;

@Repository
public interface SystemSettingRepository extends JpaRepository<SystemSetting, Long> {

    Optional<SystemSetting> findBySettingKey(String settingKey);

    // Tìm setting theo key và chưa bị xóa
    Optional<SystemSetting> findBySettingKeyAndIsDeletedFalse(String settingKey);

    // Lấy tất cả settings chưa bị xóa
    List<SystemSetting> findByIsDeletedFalse();

    // Lấy tất cả settings chưa bị xóa theo phân trang
    Page<SystemSetting> findByIsDeletedFalse(Pageable pageable);

}
