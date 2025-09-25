# Phân tích Quản lý Shop - TaphoaMMO Marketplace

## 📋 Tổng quan hệ thống Shop Management

### 🏪 Kiến trúc Shop Management
TaphoaMMO marketplace sử dụng mô hình **Seller Store** để quản lý các cửa hàng của người bán, với các đặc điểm chính:

#### 🔑 Đặc điểm chính:
- **One-to-One Relationship**: Mỗi user chỉ có thể tạo 1 seller store
- **Deposit-based System**: Yêu cầu deposit tối thiểu 5,000,000 VND
- **Max Listing Price**: Tự động tính = deposit_amount / 10
- **Status Management**: active/inactive với business rules
- **Verification System**: Store cần được verify để hoạt động

### 🗄️ Database Schema Analysis

#### **seller_stores Table:**
```sql
CREATE TABLE `seller_stores` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
  `owner_user_id` BIGINT NOT NULL,           -- FK to users
  `store_name` VARCHAR(255) NOT NULL,        -- Tên cửa hàng
  `description` TEXT,                        -- Mô tả cửa hàng
  `status` VARCHAR(20) DEFAULT 'active',     -- Trạng thái
  `deposit_amount` DECIMAL(18,2) NOT NULL,   -- Số tiền deposit
  `max_listing_price` DECIMAL(18,2)          -- Giá tối đa = deposit/10
      GENERATED ALWAYS AS (ROUND(`deposit_amount` / 10, 2)) STORED,
  `deposit_currency` CHAR(3) DEFAULT 'VND',  -- Đơn vị tiền tệ
  -- Audit fields: created_at, updated_at, created_by, deleted_by, is_deleted
  CONSTRAINT `chk_store_min_deposit` CHECK ((`status` <> 'active') OR (`deposit_amount` >= 5000000))
);
```

#### **Relationships:**
- **seller_stores** ← **products** (1:N) - Một store có nhiều products
- **seller_stores** ← **orders** (1:N) - Một store có nhiều orders
- **seller_stores** ← **seller_reviews** (1:N) - Một store có nhiều reviews
- **users** → **seller_stores** (1:1) - Một user có một store

### 🏗️ Entity Architecture

#### **SellerStore Entity:**
```java
@Entity
@Table(name = "seller_stores")
public class SellerStore extends BaseEntity {
    @Id
    private Long id;
    
    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "owner_user_id")
    private User ownerUser;
    
    @NotBlank @Size(max = 100)
    private String storeName;
    
    @Column(columnDefinition = "TEXT")
    private String storeDescription;
    
    @NotNull @DecimalMin("5000000")
    private BigDecimal depositAmount;
    
    private BigDecimal maxListingPrice;  // Calculated field
    
    private String storeLogoUrl;
    private String contactEmail;
    private String contactPhone;
    private String businessLicense;
    
    @Builder.Default
    private Boolean isVerified = false;
    
    @Builder.Default
    private Boolean isActive = true;
}
```

## 🎯 Business Rules Analysis

### 💰 Deposit System
1. **Minimum Deposit**: 5,000,000 VND bắt buộc
2. **Max Listing Price**: Tự động = deposit_amount / 10
3. **Deposit Source**: Từ wallet của user
4. **Refund Policy**: Có thể hoàn lại khi đóng store

### 📊 Store Status Management
- **active**: Store hoạt động bình thường
- **inactive**: Store tạm ngưng hoạt động
- **pending**: Store chờ verification
- **suspended**: Store bị khóa do vi phạm

### ✅ Verification Process
- **isVerified = false**: Store mới tạo, chưa verify
- **isVerified = true**: Store đã được admin verify
- **Business License**: Có thể yêu cầu giấy phép kinh doanh

## 🔄 Core Workflows

### 1. Store Creation Workflow
```
User Request → Check Eligibility → Validate Deposit → Create Store → Process Payment → Assign Role
```

### 2. Product Management Workflow
```
Store Owner → Create Product → Set Price (≤ maxListingPrice) → Add Inventory → Publish
```

### 3. Order Processing Workflow
```
Buyer Order → Escrow Hold → Seller Fulfill → Auto Delivery → Escrow Release
```

## 🛠️ Technical Implementation Status

### ✅ Implemented Components:
- **SellerStore Entity**: Complete with business methods
- **Deposit Validation**: WalletService integration
- **Role Assignment**: Auto SELLER role assignment
- **Business Rules**: Deposit constraints and calculations

### ❌ Missing Components:
- **Store Management Controller**: CRUD operations
- **Store Dashboard**: Seller interface
- **Product Management**: Store-specific product CRUD
- **Store Analytics**: Sales, revenue, performance metrics
- **Store Settings**: Configuration and preferences

## 📱 User Interface Requirements

### 🏪 Store Management Dashboard
- **Store Overview**: Basic info, status, statistics
- **Store Settings**: Name, description, contact info
- **Financial Summary**: Deposit, earnings, withdrawals
- **Performance Metrics**: Sales, reviews, ratings

### 📦 Product Management
- **Product Catalog**: List all store products
- **Add/Edit Products**: Product creation and editing
- **Inventory Management**: Stock levels, availability
- **Price Management**: Pricing within max limits

### 📊 Analytics & Reports
- **Sales Dashboard**: Revenue, orders, trends
- **Customer Analytics**: Buyer behavior, demographics
- **Product Performance**: Best sellers, low performers
- **Financial Reports**: Earnings, fees, taxes

## 🔐 Security & Permissions

### 🎭 Role-based Access
- **SELLER Role**: Required for store operations
- **Store Owner**: Full control over own store
- **ADMIN**: Can manage all stores
- **MODERATOR**: Can review and moderate stores

### 🛡️ Security Measures
- **Deposit Protection**: Funds held in escrow system
- **Transaction Logging**: All financial activities tracked
- **Audit Trail**: Complete change history
- **Fraud Detection**: Suspicious activity monitoring

## 📈 Business Intelligence

### 💹 Key Metrics
- **Store Performance**: Revenue, order volume, conversion rate
- **Customer Satisfaction**: Review ratings, repeat customers
- **Financial Health**: Profit margins, fee structure
- **Market Position**: Competitive analysis, market share

### 📊 Reporting Features
- **Daily/Weekly/Monthly Reports**: Automated reporting
- **Custom Dashboards**: Configurable metrics
- **Export Capabilities**: CSV, PDF, Excel formats
- **Real-time Notifications**: Important events and alerts

## 🚀 Future Enhancements

### 🌟 Advanced Features
- **Multi-store Support**: Allow multiple stores per user
- **Store Templates**: Pre-designed store layouts
- **Advanced Analytics**: AI-powered insights
- **Mobile App**: Dedicated seller mobile application
- **API Integration**: Third-party service connections

### 🔧 Technical Improvements
- **Microservices Architecture**: Separate store service
- **Caching Strategy**: Redis for performance
- **Search Optimization**: Elasticsearch integration
- **CDN Integration**: Fast content delivery
- **Auto-scaling**: Cloud-native deployment
