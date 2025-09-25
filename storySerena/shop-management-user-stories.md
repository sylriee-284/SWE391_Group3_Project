# User Stories - Quản lý Shop TaphoaMMO

## 🏪 Epic: Shop Management System

### 📋 Story Overview
Hệ thống quản lý shop cho phép người dùng tạo và vận hành cửa hàng trực tuyến để bán các sản phẩm số (tài khoản game, social media, tools MMO) với hệ thống deposit và escrow bảo vệ.

---

## 🎯 User Stories

### **US-SM-001: Tạo Seller Store**
**As a** người dùng đã đăng ký  
**I want** tạo một cửa hàng seller với deposit bắt buộc  
**So that** tôi có thể bắt đầu bán sản phẩm số trên marketplace

#### **Acceptance Criteria:**
- [ ] User có thể tạo store với tên và mô tả
- [ ] Yêu cầu deposit tối thiểu 5,000,000 VND để active
- [ ] Giá listing tối đa = deposit_amount / 10 (tự động tính)
- [ ] Store status mặc định 'active' khi đủ deposit
- [ ] Chỉ cho phép 1 store per user
- [ ] Tạo store yêu cầu đủ số dư trong wallet
- [ ] Tự động assign SELLER role cho user
- [ ] Hiển thị thông báo thành công/thất bại

#### **Business Rules:**
- Minimum deposit: 5,000,000 VND
- Max listing price = deposit / 10
- Deposit được trừ từ user wallet
- Store cần verification để hoạt động đầy đủ

#### **Affected Files:**
- SellerStoreController.java
- SellerStoreService.java
- WalletService.java (deposit processing)
- User entity (seller store relationship)

---

### **US-SM-002: Quản lý thông tin Store**
**As a** store owner  
**I want** cập nhật thông tin cửa hàng của tôi  
**So that** khách hàng có thể tìm hiểu và liên hệ với shop

#### **Acceptance Criteria:**
- [ ] Cập nhật tên store (required, max 100 chars)
- [ ] Cập nhật mô tả store (optional, TEXT)
- [ ] Upload/thay đổi logo store
- [ ] Cập nhật thông tin liên hệ (email, phone)
- [ ] Thêm/cập nhật business license
- [ ] Xem trạng thái verification
- [ ] Lưu thay đổi với validation
- [ ] Preview store như khách hàng thấy

#### **Business Rules:**
- Store name phải unique trong hệ thống
- Email phải valid format
- Phone number phải valid format
- Logo file size ≤ 2MB, format: JPG/PNG
- Business license optional nhưng cần cho verification

#### **Affected Files:**
- SellerStoreController.java (update endpoints)
- SellerStore entity validation
- File upload service
- Store profile JSP pages

---

### **US-SM-003: Dashboard tổng quan Store**
**As a** store owner  
**I want** xem dashboard tổng quan về cửa hàng  
**So that** tôi có thể theo dõi hiệu suất kinh doanh

#### **Acceptance Criteria:**
- [ ] Hiển thị thông tin store cơ bản
- [ ] Số liệu bán hàng (orders, revenue, profit)
- [ ] Trạng thái deposit và max listing price
- [ ] Số lượng products đang active
- [ ] Đánh giá trung bình và số reviews
- [ ] Thống kê theo thời gian (7 ngày, 30 ngày)
- [ ] Biểu đồ doanh thu theo ngày
- [ ] Top selling products
- [ ] Recent orders và activities

#### **Business Rules:**
- Chỉ hiển thị data của store owner
- Real-time hoặc cache 5 phút
- Số liệu tính theo múi giờ VN
- Profit = revenue - platform fees

#### **Affected Files:**
- StoreDashboardController.java
- StoreAnalyticsService.java
- Dashboard JSP templates
- Chart.js integration

---

### **US-SM-004: Quản lý Products trong Store**
**As a** store owner  
**I want** quản lý sản phẩm trong cửa hàng  
**So that** tôi có thể bán các sản phẩm số với giá phù hợp

#### **Acceptance Criteria:**
- [ ] Xem danh sách tất cả products của store
- [ ] Tạo product mới với thông tin đầy đủ
- [ ] Cập nhật thông tin product
- [ ] Xóa/ẩn product (soft delete)
- [ ] Set giá product ≤ maxListingPrice
- [ ] Quản lý inventory (product_storage)
- [ ] Bulk operations (enable/disable multiple)
- [ ] Search và filter products
- [ ] Preview product như buyer thấy

#### **Business Rules:**
- Product price ≤ store.maxListingPrice
- Product phải có ít nhất 1 inventory item
- Không thể xóa product có orders pending
- Product slug phải unique trong store
- Category selection từ system categories

#### **Affected Files:**
- StoreProductController.java
- ProductService.java (store-specific)
- Product entity validation
- Product management JSP pages

---

### **US-SM-005: Quản lý Inventory (Product Storage)**
**As a** store owner  
**I want** quản lý kho hàng số của sản phẩm  
**So that** hệ thống có thể tự động giao hàng cho khách

#### **Acceptance Criteria:**
- [ ] Xem inventory của từng product
- [ ] Thêm mới inventory items (JSON payload)
- [ ] Cập nhật inventory status
- [ ] Xóa inventory items chưa bán
- [ ] Bulk upload inventory (CSV/JSON)
- [ ] Preview payload data (masked)
- [ ] Set reservation timeout
- [ ] Track inventory usage history

#### **Business Rules:**
- JSON payload được encrypt/mask khi hiển thị
- Status: available, reserved, sold, expired
- Reserved items có timeout (default 30 phút)
- Sold items không thể edit/delete
- Payload validation theo product type

#### **Affected Files:**
- ProductStorageController.java
- ProductStorageService.java
- JSON encryption/masking utility
- Inventory management JSP pages

---

### **US-SM-006: Quản lý Orders của Store**
**As a** store owner  
**I want** xem và xử lý đơn hàng của cửa hàng  
**So that** tôi có thể theo dõi và hỗ trợ khách hàng

#### **Acceptance Criteria:**
- [ ] Xem danh sách orders của store
- [ ] Filter orders theo status, date, product
- [ ] Xem chi tiết order và buyer info
- [ ] Xử lý orders có vấn đề (manual fulfillment)
- [ ] Gửi message cho buyer
- [ ] Export orders data
- [ ] Xem order timeline và history
- [ ] Notifications cho orders mới

#### **Business Rules:**
- Chỉ hiển thị orders của store owner
- Auto-fulfillment cho digital products
- Manual intervention cho failed orders
- Order data retention theo policy
- Privacy protection cho buyer info

#### **Affected Files:**
- StoreOrderController.java
- OrderService.java (store view)
- Order management JSP pages
- Notification service integration

---

### **US-SM-007: Quản lý tài chính Store**
**As a** store owner  
**I want** theo dõi tình hình tài chính của cửa hàng  
**So that** tôi có thể quản lý doanh thu và chi phí

#### **Acceptance Criteria:**
- [ ] Xem tổng quan tài chính (revenue, profit, fees)
- [ ] Lịch sử transactions liên quan store
- [ ] Báo cáo doanh thu theo thời gian
- [ ] Chi tiết platform fees và commissions
- [ ] Deposit status và history
- [ ] Withdrawal requests và history
- [ ] Tax reporting data
- [ ] Financial analytics và trends

#### **Business Rules:**
- Revenue = total sales amount
- Profit = revenue - platform fees - refunds
- Platform fee: 5% per transaction
- Minimum withdrawal: 100,000 VND
- Withdrawal processing: 1-3 business days

#### **Affected Files:**
- StoreFinanceController.java
- FinancialReportService.java
- WalletTransaction queries
- Financial reports JSP pages

---

### **US-SM-008: Store Reviews và Ratings**
**As a** store owner  
**I want** xem đánh giá và phản hồi của khách hàng  
**So that** tôi có thể cải thiện chất lượng dịch vụ

#### **Acceptance Criteria:**
- [ ] Xem tất cả reviews cho store
- [ ] Filter reviews theo rating, date
- [ ] Phản hồi (reply) reviews của khách
- [ ] Xem rating trung bình và distribution
- [ ] Report inappropriate reviews
- [ ] Export reviews data
- [ ] Review analytics và insights
- [ ] Notifications cho reviews mới

#### **Business Rules:**
- Chỉ buyer đã mua mới có thể review
- Store owner có thể reply 1 lần per review
- Review không thể edit sau 7 ngày
- Rating scale: 1-5 stars
- Review moderation cho inappropriate content

#### **Affected Files:**
- StoreReviewController.java
- SellerReviewService.java
- Review management JSP pages
- Review analytics service

---

### **US-SM-009: Store Settings và Configuration**
**As a** store owner  
**I want** cấu hình các thiết lập cho cửa hàng  
**So that** tôi có thể tùy chỉnh hoạt động theo nhu cầu

#### **Acceptance Criteria:**
- [ ] Cấu hình store policies (return, refund)
- [ ] Set business hours và timezone
- [ ] Configure auto-responses
- [ ] Notification preferences
- [ ] Privacy settings
- [ ] Integration settings (APIs)
- [ ] Backup và restore settings
- [ ] Store closure/suspension options

#### **Business Rules:**
- Policies phải tuân thủ platform rules
- Business hours ảnh hưởng customer support
- Auto-responses cho common questions
- Privacy settings không ảnh hưởng orders
- Store closure cần admin approval

#### **Affected Files:**
- StoreSettingsController.java
- StoreConfigService.java
- Settings management JSP pages
- Configuration validation

---

### **US-SM-010: Store Analytics và Reports**
**As a** store owner  
**I want** xem báo cáo chi tiết về hiệu suất cửa hàng  
**So that** tôi có thể đưa ra quyết định kinh doanh đúng đắn

#### **Acceptance Criteria:**
- [ ] Sales performance reports
- [ ] Customer behavior analytics
- [ ] Product performance analysis
- [ ] Traffic và conversion metrics
- [ ] Competitor analysis
- [ ] Seasonal trends analysis
- [ ] Custom report builder
- [ ] Scheduled report delivery
- [ ] Data export capabilities

#### **Business Rules:**
- Data retention: 2 years minimum
- Real-time data với 5-minute delay
- Custom reports limited to 10 per store
- Export formats: PDF, Excel, CSV
- Scheduled reports: daily/weekly/monthly

#### **Affected Files:**
- StoreAnalyticsController.java
- ReportGeneratorService.java
- Analytics dashboard JSP
- Chart.js và data visualization

---

## 📊 Technical Requirements

### **Database Tables Involved:**
- `seller_stores` - Core store information
- `products` - Store products
- `product_storage` - Digital inventory
- `orders` - Store orders
- `seller_reviews` - Store reviews
- `wallet_transactions` - Financial transactions

### **Key Services:**
- `SellerStoreService` - Core store operations
- `ProductService` - Product management
- `ProductStorageService` - Inventory management
- `WalletService` - Financial operations
- `NotificationService` - Alerts và notifications

### **Security Considerations:**
- Store owner authorization
- Data privacy protection
- Financial transaction security
- Audit logging
- Rate limiting

### **Performance Requirements:**
- Dashboard load time < 2 seconds
- Real-time notifications
- Efficient pagination for large datasets
- Caching for frequently accessed data
- Database query optimization

---

## 🔗 Reference Links
- [Database Schema](../marketplace.sql)
- [SellerStore Entity](../src/main/java/vn/group3/marketplace/domain/entity/SellerStore.java)
- [Business Requirements](./taphoammo-summary.md)
- [Implementation Status](../.serena/memories/implementation_status.md)
