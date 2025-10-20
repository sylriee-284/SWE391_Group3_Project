# Hướng dẫn Debug Date Filter trong System Config

## 🔍 **Các bước kiểm tra:**

### 1. **Kiểm tra Console Log**
Mở Developer Tools (F12) và xem Console để kiểm tra:
- Có lỗi JavaScript nào không?
- Form có submit đúng không?

### 2. **Kiểm tra Network Tab**
- Mở Network tab trong Developer Tools
- Click Filter button
- Xem request POST có gửi đúng parameters không:
  ```
  id: 
  settingKey: 
  settingValue: 
  createdFrom: 2024-01-01
  createdTo: 2024-01-31
  page: 0
  size: 10
  ```

### 3. **Kiểm tra Server Log**
Xem log của Spring Boot application:
```bash
# Tìm các log debug:
grep "Filter applied" logs/application.log
grep "Filtering settings" logs/application.log
grep "Date filter" logs/application.log
```

### 4. **Kiểm tra Database**
Chạy SQL để kiểm tra dữ liệu:
```sql
-- Xem tất cả system settings
SELECT id, setting_key, setting_value, created_at 
FROM system_settings 
WHERE is_deleted = 0 
ORDER BY created_at DESC;

-- Test filter theo ngày
SELECT id, setting_key, setting_value, created_at 
FROM system_settings 
WHERE is_deleted = 0 
  AND DATE(created_at) >= '2024-01-01'
  AND DATE(created_at) <= '2024-01-31'
ORDER BY created_at;
```

## 🐛 **Các vấn đề có thể gặp:**

### **Vấn đề 1: Date Format**
- Browser có thể gửi date theo format khác
- Kiểm tra format trong Network tab

### **Vấn đề 2: Timezone**
- Server và client có timezone khác nhau
- Kiểm tra `created_at` trong database

### **Vấn đề 3: JavaScript Error**
- Form không submit được
- Kiểm tra Console errors

### **Vấn đề 4: Controller Logic**
- Date parsing bị lỗi
- Kiểm tra server logs

## 🔧 **Cách sửa:**

### **Nếu Date Format sai:**
```javascript
// Trong JSP, thêm format cho date input
<input type="date" class="form-control" name="createdFrom" 
       value="${filterCreatedFrom}" 
       pattern="[0-9]{4}-[0-9]{2}-[0-9]{2}">
```

### **Nếu Timezone sai:**
```java
// Trong Controller, convert timezone
ZoneId systemZone = ZoneId.systemDefault();
LocalDate from = createdFrom != null ? 
    LocalDate.parse(createdFrom).atStartOfDay(systemZone).toLocalDate() : null;
```

### **Nếu JavaScript Error:**
```javascript
// Thêm validation cho form
function validateDateFilter() {
    const from = document.querySelector('input[name="createdFrom"]').value;
    const to = document.querySelector('input[name="createdTo"]').value;
    
    if (from && to && from > to) {
        alert('Ngày bắt đầu phải nhỏ hơn ngày kết thúc');
        return false;
    }
    return true;
}
```

## 📝 **Test Cases:**

1. **Filter từ ngày cụ thể đến ngày cụ thể**
2. **Filter chỉ từ ngày (không có đến ngày)**
3. **Filter chỉ đến ngày (không có từ ngày)**
4. **Filter với ngày không hợp lệ**
5. **Filter với ngày từ > ngày đến**
