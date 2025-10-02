# Database Documentation

## Table of Contents
1. [Database Overview](#database-overview)
2. [Entity Relationship Diagram](#entity-relationship-diagram)
3. [Table Specifications](#table-specifications)
4. [Indexes and Constraints](#indexes-and-constraints)
5. [Data Types](#data-types)
6. [Sample Data](#sample-data)

---

## Database Overview

### Database Information
- **Name:** `mmo_market_system`
- **DBMS:** MySQL 8.0+
- **Storage Engine:** InnoDB
- **Character Set:** utf8mb4
- **Collation:** utf8mb4_unicode_ci
- **Total Tables:** 17

### Design Principles
- **Referential Integrity:** All foreign keys enforced
- **Soft Delete:** All tables support logical deletion (is_deleted flag)
- **Audit Trail:** Created/updated timestamps and user tracking
- **Normalization:** 3NF (Third Normal Form)
- **Generated Columns:** Calculated fields for performance

---

## Entity Relationship Diagram

### Core Relationships

```
┌─────────────────────────────────────────────────────────────────┐
│                     AUTHENTICATION & AUTHORIZATION               │
└─────────────────────────────────────────────────────────────────┘

    ┌──────────────┐
    │    users     │
    │ PK: id       │
    └──────┬───────┘
           │
           │ M:M (user_roles)
           │
    ┌──────▼───────┐              ┌──────────────┐
    │    roles     │──────────────│ permissions  │
    │ PK: id       │  M:M         │ PK: id       │
    │ UK: code     │ (role_perm.) │ UK: code     │
    └──────────────┘              └──────────────┘


┌─────────────────────────────────────────────────────────────────┐
│                        FINANCIAL SYSTEM                          │
└─────────────────────────────────────────────────────────────────┘

    ┌──────────────┐              ┌─────────────────────┐
    │    users     │              │ wallet_transactions │
    │ PK: id       │              │ PK: id              │
    └──────┬───────┘              │ FK: wallet_id       │
           │ 1:1                  │ FK: ref_order_id    │
           │                      └─────────────────────┘
    ┌──────▼───────┐                      ▲
    │   wallets    │──────────────────────┘
    │ PK: id       │ 1:M
    │ UK: user_id  │
    │    balance   │
    └──────────────┘


┌─────────────────────────────────────────────────────────────────┐
│                       MARKETPLACE CORE                           │
└─────────────────────────────────────────────────────────────────┘

    ┌──────────────┐
    │    users     │
    │ PK: id       │
    └──────┬───────┘
           │ 1:1 (owner)
           │
    ┌──────▼───────────┐              ┌──────────────┐
    │ seller_stores    │──────────────│ categories   │
    │ PK: id           │              │ PK: id       │
    │ UK: owner_id     │              │ UK: slug     │
    │ UK: store_name   │              └──────┬───────┘
    │    deposit       │                     │
    │  max_list_price  │ (GENERATED)         │
    └──────┬───────────┘                     │
           │ 1:M                             │
           │                                 │
    ┌──────▼───────┐                        │
    │   products   │◄───────────────────────┘
    │ PK: id       │ M:1
    │ FK: store_id │
    │ FK: category │
    │ UK: store+slug│
    │    price     │
    └──────┬───────┘
           │ 1:M
           │
    ┌──────▼───────────┐
    │ product_storage  │
    │ PK: id           │
    │ FK: product_id   │
    │    payload_json  │
    │    status        │
    └──────────────────┘


┌─────────────────────────────────────────────────────────────────┐
│                      ORDER & PAYMENT FLOW                        │
└─────────────────────────────────────────────────────────────────┘

    ┌──────────────┐
    │    users     │ (buyer)
    │ PK: id       │
    └──────┬───────┘
           │ 1:M
           │
    ┌──────▼────────────┐              ┌───────────────────┐
    │     orders        │──────────────│ escrow_trans...   │
    │ PK: id            │ 1:1          │ PK: id            │
    │ FK: buyer_id      │              │ FK: order_id      │
    │ FK: store_id      │              │    amount         │
    │ FK: product_id    │              │    hold_until (G) │
    │ FK: storage_id    │              └───────────────────┘
    │    product_data   │ (JSON)
    └───────────────────┘


┌─────────────────────────────────────────────────────────────────┐
│                      ENGAGEMENT & TRUST                          │
└─────────────────────────────────────────────────────────────────┘

    ┌──────────────┐              ┌──────────────────┐
    │    orders    │──────────────│ product_reviews  │
    │ PK: id       │ 1:1          │ PK: id           │
    └──────────────┘              │ FK: order_id     │
                                  │    rating        │
                                  │    content       │
                                  └──────────────────┘

    ┌──────────────┐              ┌──────────────────┐
    │    orders    │──────────────│ seller_reviews   │
    │ PK: id       │ 1:1          │ PK: id           │
    └──────────────┘              │ FK: order_id     │
                                  │    rating        │
                                  │    content       │
                                  └──────────────────┘


┌─────────────────────────────────────────────────────────────────┐
│                    COMMUNICATION & DISPUTES                      │
└─────────────────────────────────────────────────────────────────┘

    ┌──────────────┐
    │    users     │ (buyer/seller)
    │ PK: id       │
    └──────┬───────┘
           │ M:M (via conversations)
           │
    ┌──────▼─────────────┐              ┌──────────────┐
    │  conversations     │──────────────│  messages    │
    │ PK: id             │ 1:M          │ PK: id       │
    │ FK: buyer_user_id  │              │ FK: conv_id  │
    │ FK: seller_user_id │              │ FK: sender   │
    │ FK: product_id     │              │    content   │
    └────────────────────┘              └──────────────┘

    ┌──────────────┐              ┌──────────────┐
    │    orders    │──────────────│  disputes    │
    │ PK: id       │ 1:1          │ PK: id       │
    └──────────────┘              │ FK: order_id │
                                  │ FK: opened_by│
                                  │    status    │
                                  └──────────────┘


┌─────────────────────────────────────────────────────────────────┐
│                     SYSTEM & CONFIGURATION                       │
└─────────────────────────────────────────────────────────────────┘

    ┌──────────────────┐         ┌──────────────────┐
    │ payment_gateways │         │ system_settings  │
    │ PK: id           │         │ PK: id           │
    │ UK: code         │         │ UK: setting_key  │
    │    config (JSON) │         │    value         │
    └──────────────────┘         └──────────────────┘

    ┌──────────────────┐
    │  notifications   │
    │ PK: id           │
    │ FK: user_id      │
    │    type          │
    │    content       │
    └──────────────────┘
```

---

## Table Specifications

### 1. users

**Purpose:** Store user account information and authentication credentials

```sql
CREATE TABLE users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    full_name VARCHAR(100),
    avatar_url VARCHAR(500),
    date_of_birth DATE,
    gender ENUM('MALE', 'FEMALE', 'OTHER'),
    status VARCHAR(20) DEFAULT 'ACTIVE',

    -- Spring Security UserDetails fields
    enabled TINYINT(1) DEFAULT 1,
    account_non_locked TINYINT(1) DEFAULT 1,
    account_non_expired TINYINT(1) DEFAULT 1,
    credentials_non_expired TINYINT(1) DEFAULT 1,

    -- Audit fields
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_by BIGINT,
    is_deleted TINYINT(1) DEFAULT 0,

    INDEX idx_username (username),
    INDEX idx_email (email),
    INDEX idx_status (status),
    INDEX idx_is_deleted (is_deleted)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

**Key Columns:**
- `password_hash`: BCrypt encoded password (strength 10)
- `status`: ACTIVE, INACTIVE
- `enabled`: Spring Security account enabled flag

---

### 2. roles

**Purpose:** Define system roles for RBAC

```sql
CREATE TABLE roles (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    description TEXT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_by BIGINT,
    is_deleted TINYINT(1) DEFAULT 0,

    INDEX idx_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

**Predefined Roles:**
- `ROLE_ADMIN` - Full system access
- `ROLE_MODERATOR` - Content moderation
- `ROLE_SELLER` - Store and product management
- `ROLE_BUYER` - Purchase products
- `ROLE_USER` - Basic user

---

### 3. permissions

**Purpose:** Granular permission definitions

```sql
CREATE TABLE permissions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    category VARCHAR(50),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_by BIGINT,
    is_deleted TINYINT(1) DEFAULT 0,

    INDEX idx_code (code),
    INDEX idx_category (category)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

**Permission Categories:**
- User Management (4 permissions)
- Store Management (4 permissions)
- Product Management (4 permissions)
- Order Management (4 permissions)
- Wallet Management (3 permissions)
- Review Management (3 permissions)
- Dispute Management (3 permissions)
- System Management (2 permissions)

**Total:** 27 permissions

---

### 4. user_roles

**Purpose:** Many-to-many relationship between users and roles

```sql
CREATE TABLE user_roles (
    user_id BIGINT NOT NULL,
    role_id BIGINT NOT NULL,

    PRIMARY KEY (user_id, role_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE,

    INDEX idx_user_id (user_id),
    INDEX idx_role_id (role_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

### 5. role_permissions

**Purpose:** Many-to-many relationship between roles and permissions

```sql
CREATE TABLE role_permissions (
    role_id BIGINT NOT NULL,
    permission_id BIGINT NOT NULL,

    PRIMARY KEY (role_id, permission_id),
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE,
    FOREIGN KEY (permission_id) REFERENCES permissions(id) ON DELETE CASCADE,

    INDEX idx_role_id (role_id),
    INDEX idx_permission_id (permission_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

### 6. wallets

**Purpose:** User wallet for financial transactions

```sql
CREATE TABLE wallets (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE,
    balance DECIMAL(18, 2) DEFAULT 0.00 NOT NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_by BIGINT,
    is_deleted TINYINT(1) DEFAULT 0,

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,

    INDEX idx_user_id (user_id),
    CONSTRAINT chk_balance_non_negative CHECK (balance >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

**Key Constraints:**
- `user_id` UNIQUE - One wallet per user
- `balance` CHECK - Cannot be negative
- Currency: VND (Vietnamese Dong)

---

### 7. wallet_transactions

**Purpose:** Track all wallet balance changes

```sql
CREATE TABLE wallet_transactions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    wallet_id BIGINT NOT NULL,
    type VARCHAR(20) NOT NULL,
    amount DECIMAL(18, 2) NOT NULL,
    ref_order_id BIGINT,
    note TEXT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_by BIGINT,
    is_deleted TINYINT(1) DEFAULT 0,

    FOREIGN KEY (wallet_id) REFERENCES wallets(id) ON DELETE CASCADE,
    FOREIGN KEY (ref_order_id) REFERENCES orders(id) ON DELETE SET NULL,

    INDEX idx_wallet_id (wallet_id),
    INDEX idx_type (type),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

**Transaction Types:**
- DEPOSIT - Add funds
- WITHDRAWAL - Remove funds
- PURCHASE - Buy product
- SALE - Sell product
- REFUND - Return funds
- STORE_DEPOSIT - Store creation deposit
- STORE_REFUND - Store closure refund

---

### 8. seller_stores

**Purpose:** Seller merchant stores

```sql
CREATE TABLE seller_stores (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    owner_user_id BIGINT NOT NULL UNIQUE,
    store_name VARCHAR(100) NOT NULL UNIQUE,
    store_description TEXT,
    store_logo_url VARCHAR(500),

    deposit_amount DECIMAL(18, 2) DEFAULT 0.00,
    max_listing_price DECIMAL(18, 2)
        GENERATED ALWAYS AS (ROUND(deposit_amount / 10, 2)) STORED,

    contact_email VARCHAR(100),
    contact_phone VARCHAR(20),
    business_license VARCHAR(100),

    status VARCHAR(20) DEFAULT 'PENDING',
    is_verified TINYINT(1) DEFAULT 0,
    is_active TINYINT(1) DEFAULT 1,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_by BIGINT,
    is_deleted TINYINT(1) DEFAULT 0,

    FOREIGN KEY (owner_user_id) REFERENCES users(id) ON DELETE CASCADE,

    INDEX idx_owner_user_id (owner_user_id),
    INDEX idx_store_name (store_name),
    INDEX idx_status (status),
    INDEX idx_is_verified (is_verified),
    INDEX idx_is_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

**Key Features:**
- `max_listing_price` - Generated column (deposit_amount / 10)
- `owner_user_id` - UNIQUE constraint (one store per user)
- `store_name` - UNIQUE constraint

**Status Values:**
- PENDING - Awaiting verification
- ACTIVE - Operational
- SUSPENDED - Temporarily disabled
- CLOSED - Permanently closed

---

### 9. categories

**Purpose:** Product categorization

```sql
CREATE TABLE categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    icon_class VARCHAR(50),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_by BIGINT,
    is_deleted TINYINT(1) DEFAULT 0,

    INDEX idx_slug (slug)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

**Predefined Categories:**
1. Game Accounts
2. Social Media Accounts
3. Game Items & Currency
4. Premium Subscriptions
5. Software Licenses
6. Digital Assets
7. VPN & Proxy Services
8. Streaming Accounts
9. Gift Cards & Vouchers
10. Other Services

---

### 10. products

**Purpose:** Product listings

```sql
CREATE TABLE products (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    seller_store_id BIGINT NOT NULL,
    category_id BIGINT NOT NULL,
    name VARCHAR(200) NOT NULL,
    slug VARCHAR(200) NOT NULL,
    description TEXT,
    price DECIMAL(18, 2) NOT NULL,
    stock INT DEFAULT 0,
    status VARCHAR(20) DEFAULT 'DRAFT',

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_by BIGINT,
    is_deleted TINYINT(1) DEFAULT 0,

    FOREIGN KEY (seller_store_id) REFERENCES seller_stores(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE RESTRICT,

    UNIQUE KEY uk_store_slug (seller_store_id, slug),
    INDEX idx_category_id (category_id),
    INDEX idx_status (status),
    INDEX idx_price (price)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

**Status Values:**
- DRAFT - Not published
- ACTIVE - Available for purchase
- INACTIVE - Temporarily hidden
- OUT_OF_STOCK - No inventory

---

### 11. product_storage

**Purpose:** Digital product inventory (accounts, keys, etc.)

```sql
CREATE TABLE product_storage (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_id BIGINT NOT NULL,
    status VARCHAR(20) DEFAULT 'AVAILABLE',
    payload_json JSON,
    payload_mask VARCHAR(100),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_by BIGINT,
    is_deleted TINYINT(1) DEFAULT 0,

    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,

    INDEX idx_product_id (product_id),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

**Example payload_json:**
```json
{
  "username": "player123",
  "password": "SecurePass456",
  "email": "player@example.com",
  "level": 80,
  "server": "NA"
}
```

**Status Values:**
- AVAILABLE - Ready for purchase
- RESERVED - Held for order
- DELIVERED - Sent to buyer

---

### 12. orders

**Purpose:** Purchase transactions

```sql
CREATE TABLE orders (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    buyer_user_id BIGINT NOT NULL,
    seller_store_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    product_storage_id BIGINT,

    product_name VARCHAR(200) NOT NULL,
    product_price DECIMAL(18, 2) NOT NULL,
    quantity INT DEFAULT 1,
    total_amount DECIMAL(18, 2) NOT NULL,
    product_data JSON,

    status VARCHAR(20) DEFAULT 'PENDING',

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_by BIGINT,
    is_deleted TINYINT(1) DEFAULT 0,

    FOREIGN KEY (buyer_user_id) REFERENCES users(id) ON DELETE RESTRICT,
    FOREIGN KEY (seller_store_id) REFERENCES seller_stores(id) ON DELETE RESTRICT,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT,
    FOREIGN KEY (product_storage_id) REFERENCES product_storage(id) ON DELETE SET NULL,

    INDEX idx_buyer_user_id (buyer_user_id),
    INDEX idx_seller_store_id (seller_store_id),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

**Status Values:**
- PENDING - Payment processing
- CONFIRMED - Payment received
- DELIVERED - Product sent
- COMPLETED - Transaction finished
- CANCELLED - Order cancelled
- REFUNDED - Money returned

---

### 13. escrow_transactions

**Purpose:** Hold payments for buyer protection

```sql
CREATE TABLE escrow_transactions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT NOT NULL UNIQUE,
    amount DECIMAL(18, 2) NOT NULL,
    status VARCHAR(20) DEFAULT 'HOLDING',
    hold_until DATETIME
        GENERATED ALWAYS AS (DATE_ADD(created_at, INTERVAL 3 DAY)) STORED,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_by BIGINT,
    is_deleted TINYINT(1) DEFAULT 0,

    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,

    INDEX idx_order_id (order_id),
    INDEX idx_status (status),
    INDEX idx_hold_until (hold_until)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

**Status Values:**
- HOLDING - Funds held
- RELEASED - Paid to seller
- REFUNDED - Returned to buyer

**hold_until:** Auto-calculated as created_at + 3 days (configurable)

---

### 14. product_reviews & seller_reviews

**Purpose:** Buyer feedback system

```sql
CREATE TABLE product_reviews (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT NOT NULL UNIQUE,
    rating TINYINT NOT NULL,
    content TEXT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_by BIGINT,
    is_deleted TINYINT(1) DEFAULT 0,

    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,

    INDEX idx_order_id (order_id),
    INDEX idx_rating (rating),
    CONSTRAINT chk_rating CHECK (rating BETWEEN 1 AND 5)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE seller_reviews (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT NOT NULL UNIQUE,
    rating TINYINT NOT NULL,
    content TEXT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_by BIGINT,
    is_deleted TINYINT(1) DEFAULT 0,

    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,

    INDEX idx_order_id (order_id),
    INDEX idx_rating (rating),
    CONSTRAINT chk_rating CHECK (rating BETWEEN 1 AND 5)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

**Rating Scale:** 1-5 stars

---

### 15. conversations & messages

**Purpose:** Buyer-seller communication

```sql
CREATE TABLE conversations (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    buyer_user_id BIGINT NOT NULL,
    seller_user_id BIGINT NOT NULL,
    product_id BIGINT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_by BIGINT,
    is_deleted TINYINT(1) DEFAULT 0,

    FOREIGN KEY (buyer_user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (seller_user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE SET NULL,

    INDEX idx_buyer_user_id (buyer_user_id),
    INDEX idx_seller_user_id (seller_user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE messages (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    conversation_id BIGINT NOT NULL,
    sender_user_id BIGINT NOT NULL,
    content TEXT NOT NULL,
    type VARCHAR(20) DEFAULT 'TEXT',
    read_at DATETIME,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_by BIGINT,
    is_deleted TINYINT(1) DEFAULT 0,

    FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE CASCADE,
    FOREIGN KEY (sender_user_id) REFERENCES users(id) ON DELETE CASCADE,

    INDEX idx_conversation_id (conversation_id),
    INDEX idx_sender_user_id (sender_user_id),
    INDEX idx_read_at (read_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

### 16. disputes

**Purpose:** Conflict resolution

```sql
CREATE TABLE disputes (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT NOT NULL UNIQUE,
    opened_by_user_id BIGINT NOT NULL,
    status VARCHAR(20) DEFAULT 'OPEN',
    reason TEXT NOT NULL,
    resolution_note TEXT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_by BIGINT,
    is_deleted TINYINT(1) DEFAULT 0,

    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (opened_by_user_id) REFERENCES users(id) ON DELETE RESTRICT,

    INDEX idx_order_id (order_id),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

**Status Values:**
- OPEN - Under review
- RESOLVED_BUYER - Buyer favored
- RESOLVED_SELLER - Seller favored
- CLOSED - Resolved

---

### 17. payment_gateways, system_settings, notifications

**Purpose:** System configuration and notifications

```sql
CREATE TABLE payment_gateways (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    enabled TINYINT(1) DEFAULT 1,
    config JSON,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_by BIGINT,
    is_deleted TINYINT(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE system_settings (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    setting_key VARCHAR(100) NOT NULL UNIQUE,
    setting_value TEXT,
    description TEXT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_by BIGINT,
    is_deleted TINYINT(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE notifications (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    type VARCHAR(50) NOT NULL,
    title VARCHAR(200),
    content TEXT,
    read_at DATETIME,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_by BIGINT,
    is_deleted TINYINT(1) DEFAULT 0,

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,

    INDEX idx_user_id (user_id),
    INDEX idx_read_at (read_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

## Indexes and Constraints

### Primary Keys
All tables have auto-increment BIGINT primary keys.

### Foreign Keys
All foreign key constraints defined with appropriate ON DELETE actions:
- **CASCADE:** Child records deleted when parent deleted
- **RESTRICT:** Prevent parent deletion if children exist
- **SET NULL:** Set FK to NULL when parent deleted

### Unique Constraints
- `users.username`
- `users.email`
- `wallets.user_id`
- `seller_stores.owner_user_id`
- `seller_stores.store_name`
- `categories.slug`
- `products.(seller_store_id, slug)`
- `escrow_transactions.order_id`
- `product_reviews.order_id`
- `seller_reviews.order_id`
- `disputes.order_id`

### Indexes
Strategic indexes on:
- Foreign keys (automatic in InnoDB)
- Frequently queried columns (status, created_at, etc.)
- Unique constraints

### Check Constraints
- `wallets.balance >= 0`
- `product_reviews.rating BETWEEN 1 AND 5`
- `seller_reviews.rating BETWEEN 1 AND 5`

---

## Data Types

### Numeric Types
- **BIGINT:** All IDs and user references
- **DECIMAL(18, 2):** Financial amounts (balance, price, amount)
- **INT:** Quantities, counts
- **TINYINT(1):** Boolean flags

### String Types
- **VARCHAR:** Fixed-length text (usernames, emails, codes)
- **TEXT:** Variable-length content (descriptions, notes)
- **ENUM:** Fixed set of values (gender)

### Date/Time Types
- **TIMESTAMP:** Audit timestamps (auto-managed)
- **DATETIME:** User-defined dates (hold_until, read_at)
- **DATE:** Date only (date_of_birth)

### Special Types
- **JSON:** Flexible data storage (payload_json, config, product_data)

---

## Sample Data

### User Accounts (15 total)
- 1 Admin (ID 1)
- 5 Sellers (IDs 2, 3, 4, 10, 12)
- 6 Buyers (IDs 5, 6, 7, 8, 11, 13)
- 1 Moderator (ID 9)
- 2 Test accounts (IDs 14, 15)

### Roles (5 total)
- ROLE_ADMIN
- ROLE_MODERATOR
- ROLE_SELLER
- ROLE_BUYER
- ROLE_USER

### Permissions (27 total)
See full list in marketplace-sample-data.sql

### Categories (10 total)
- Game Accounts
- Social Media Accounts
- Game Items & Currency
- Premium Subscriptions
- Software Licenses
- Digital Assets
- VPN & Proxy Services
- Streaming Accounts
- Gift Cards & Vouchers
- Other Services

### Wallet Balances
- Total system balance: 261,700,000 VND
- Average balance: ~17.4M VND per user

---

## Database Maintenance

### Backup Strategy
```bash
# Full backup
mysqldump -u root -p mmo_market_system > backup_$(date +%Y%m%d).sql

# Schema only
mysqldump -u root -p --no-data mmo_market_system > schema.sql

# Data only
mysqldump -u root -p --no-create-info mmo_market_system > data.sql
```

### Restore
```bash
mysql -u root -p mmo_market_system < backup_20250102.sql
```

### Soft Delete Cleanup
```sql
-- Permanently delete soft-deleted records older than 90 days
DELETE FROM users
WHERE is_deleted = 1
AND deleted_by IS NOT NULL
AND updated_at < DATE_SUB(NOW(), INTERVAL 90 DAY);
```

---

**Last Updated:** January 2025
**Document Version:** 1.0.0
