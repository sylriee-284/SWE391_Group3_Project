# Business Rules Documentation

## Table of Contents
1. [Overview](#overview)
2. [User Management Rules](#user-management-rules)
3. [Seller Store Rules](#seller-store-rules)
4. [Wallet & Financial Rules](#wallet--financial-rules)
5. [Product Listing Rules](#product-listing-rules)
6. [File Upload Rules](#file-upload-rules)
7. [Order & Purchase Rules](#order--purchase-rules)
8. [Escrow System Rules](#escrow-system-rules)
9. [Review System Rules](#review-system-rules)
10. [Dispute Resolution Rules](#dispute-resolution-rules)
11. [Role & Permission Rules](#role--permission-rules)

---

## Overview

This document defines the business rules and constraints that govern the TaphoaMMO Marketplace platform. These rules ensure fair trading, protect buyers and sellers, and maintain platform integrity.

---

## User Management Rules

### UM-001: User Registration

**Rule:** Users must provide unique username and email to register.

**Constraints:**
- Username: 3-50 characters, alphanumeric and underscore only
- Email: Valid email format, must be unique
- Password: Minimum 6 characters (recommended 8+)
- Password confirmation must match

**Validation Location:** `UserController.registerUser()`, `UserService.registerUser()`

**Enforcement:** Database unique constraints + service layer validation

---

### UM-002: Default User Status

**Rule:** Newly registered users are ACTIVE by default.

**Default Values:**
- `status`: "ACTIVE"
- `enabled`: true
- `accountNonLocked`: true
- `accountNonExpired`: true
- `credentialsNonExpired`: true

**Implementation:** `User` entity default values

---

### UM-003: Default User Role

**Rule:** All new users automatically receive ROLE_USER.

**Additional Roles:**
- ROLE_SELLER: Assigned upon store creation
- ROLE_BUYER: Assigned upon first purchase (planned)
- ROLE_ADMIN: Manual assignment only
- ROLE_MODERATOR: Manual assignment only

**Implementation:** `UserService.registerUser()` (should be explicit)

---

### UM-004: Wallet Creation

**Rule:** Every registered user must have exactly one wallet.

**Timing:** Created automatically upon user registration (should be explicit in service)

**Initial Balance:** 0.00 VND

**Constraint:** One-to-one relationship enforced by unique constraint on `wallets.user_id`

**Implementation:** Should be in `UserService.registerUser()` with transaction management

---

### UM-005: Account Deactivation

**Rule:** Administrators can disable user accounts without deleting them.

**Effects:**
- User cannot log in
- Existing sessions invalidated
- User data preserved
- Can be reactivated later

**Implementation:** `UserService.setUserEnabled(userId, false)`

---

### UM-006: Password Security

**Rule:** Passwords must be encrypted using BCrypt with strength 10.

**Implementation:** `PasswordEncoderConfig.passwordEncoder()`

**Storage:** Only hashed passwords stored in `users.password_hash`

**Change Policy:**
- Must verify current password before changing
- New password cannot be same as current (recommended)

---

### UM-007: Soft Delete

**Rule:** Users are never permanently deleted immediately; they are soft-deleted.

**Implementation:**
- Set `is_deleted = 1`
- Set `deleted_by` to admin user ID
- Update `updated_at` timestamp

**Permanent Deletion:** After 90 days of soft delete (manual process)

---

## Seller Store Rules

### SS-001: One Store Per User

**Rule:** Each user can create and own exactly one seller store.

**Constraint:** Unique constraint on `seller_stores.owner_user_id`

**Validation:** Service layer check before store creation

**Exception:** If store is deleted, user can create a new one (based on soft delete status)

**Implementation:** `SellerStoreService.createStore()`

**Location:** `src/main/java/vn/group3/marketplace/service/impl/SellerStoreServiceImpl.java:48`

---

### SS-002: Minimum Store Deposit

**Rule:** Sellers must deposit minimum 5,000,000 VND to create a store.

**Current Status:** ⚠️ Temporarily disabled for testing

**Configuration:** `marketplace.seller.minimum-deposit=5000000` in `application.properties`

**Purpose:**
- Ensure seller commitment
- Provide buyer protection fund
- Prevent spam store creation

**Re-enable Location:** `SellerStoreServiceImpl.java:54-57` (currently commented)

---

### SS-003: Maximum Listing Price Calculation

**Rule:** Maximum product listing price is calculated as deposit_amount / 10.

**Formula:**
```
max_listing_price = ROUND(deposit_amount / 10, 2)
```

**Implementation:** MySQL generated column in `seller_stores` table

**Example:**
- Deposit: 10,000,000 VND → Max price: 1,000,000 VND
- Deposit: 50,000,000 VND → Max price: 5,000,000 VND

**Rationale:** Prevents sellers from listing products they cannot fulfill

**Current Fallback:** If deposit = 0, max_listing_price = 999,999,999 (testing only)

---

### SS-004: Store Name Uniqueness

**Rule:** Store names must be unique across the platform (case-insensitive).

**Validation:**
- Service layer check: `isStoreNameAvailable(storeName, excludeStoreId)`
- Database unique constraint on `seller_stores.store_name`

**AJAX Check:** `GET /stores/check-name?storeName={name}`

**Implementation:** `SellerStoreServiceImpl.isStoreNameAvailable()`

---

### SS-005: Store Verification

**Rule:** Stores must be verified by an admin to receive a trust badge.

**Process:**
1. Seller creates store (status: PENDING)
2. Admin reviews store information
3. Admin verifies store (is_verified = true)
4. Trust badge displayed on store profile

**Benefits:**
- Increased buyer confidence
- Higher search ranking (planned)
- Featured store eligibility (planned)

**Implementation:** `SellerStoreService.verifyStore(storeId, verifiedBy)`

---

### SS-006: Store Activation/Deactivation

**Rule:** Sellers can temporarily deactivate their stores.

**Effects of Deactivation:**
- Store hidden from public listings
- Existing products hidden
- Cannot create new listings
- Orders in progress continue

**Reactivation:**
- Seller can reactivate anytime
- All products restored to previous status

**Implementation:**
- `SellerStoreService.deactivateStore(storeId, deactivatedBy)`
- `SellerStoreService.activateStore(storeId, activatedBy)`

---

### SS-007: Store Suspension (Admin)

**Rule:** Administrators can suspend stores for policy violations.

**Suspension Reasons:**
- Fraudulent activity
- Multiple buyer complaints
- Policy violations
- Fake/misleading listings

**Effects:**
- Store immediately hidden
- All active listings removed
- Orders in escrow processed normally
- Seller notified with reason

**Duration:** Until admin reinstates or permanently closes store

**Implementation:** `AdminStoreService.suspendStore(storeId, reason)`

---

### SS-008: Store Deposit Lock

**Rule:** Store deposit is locked and cannot be withdrawn while store is active.

**Refund Conditions:**
- Store permanently closed by seller
- No pending orders or disputes
- All escrow transactions completed
- Admin approval (optional)

**Refund Process:**
1. Seller requests store closure
2. System checks for pending obligations
3. If clear, deposit refunded to wallet
4. Store marked as CLOSED

**Implementation:** `SellerStoreService.closeStore(storeId)` (planned)

---

## Wallet & Financial Rules

### WF-001: One Wallet Per User

**Rule:** Each user has exactly one wallet.

**Constraint:** Unique constraint on `wallets.user_id`

**Creation:** Automatic upon user registration

**Currency:** VND (Vietnamese Dong) only

**Deletion:** Cascade delete when user is deleted

---

### WF-002: Non-Negative Balance

**Rule:** Wallet balance cannot be negative.

**Constraint:** Database CHECK constraint: `balance >= 0`

**Validation:** Service layer check before deducting funds

**Implementation:** `WalletService.hasSufficientFunds(userId, amount)`

---

### WF-003: Transaction Recording

**Rule:** All wallet balance changes must be recorded in wallet_transactions.

**Required Fields:**
- wallet_id
- type (DEPOSIT, WITHDRAWAL, PURCHASE, SALE, REFUND, STORE_DEPOSIT, STORE_REFUND)
- amount
- note (description)
- ref_order_id (if applicable)

**Implementation:** `WalletService.addFunds()`, `WalletService.deductFunds()`

---

### WF-004: Deposit Funds

**Rule:** Users can deposit funds via supported payment gateways.

**Current Status:** Not implemented (manual admin credit only)

**Planned Process:**
1. User selects payment gateway
2. Redirects to payment processor
3. Payment confirmation received
4. Funds credited to wallet
5. Transaction recorded

**Minimum Deposit:** 100,000 VND (configurable)

---

### WF-005: Withdraw Funds

**Rule:** Users can withdraw available wallet balance.

**Constraints:**
- Minimum withdrawal: 500,000 VND
- Balance must be sufficient
- No pending escrow holds
- Verified bank account required (planned)

**Processing Time:** 1-3 business days

**Implementation:** `WalletService.processWithdrawal()` (planned)

---

### WF-006: Store Deposit Processing

**Rule:** Store creation deposit must be deducted from user's wallet.

**Current Status:** ⚠️ Temporarily disabled for testing

**Process:**
1. Validate user has sufficient balance
2. Create store entity
3. Deduct deposit from wallet
4. Record STORE_DEPOSIT transaction
5. Assign SELLER role

**Transaction Boundary:** All steps in single database transaction

**Re-enable Location:** `SellerStoreServiceImpl.java:82-88`

---

### WF-007: Currency Format

**Rule:** All financial amounts use DECIMAL(18, 2).

**Precision:** 2 decimal places (hundredths)

**Display Format:** VND currency symbol with thousand separators

**Example:** 5,000,000.00 VND

---

## Product Listing Rules

### PL-001: Price Limit Enforcement ✅

**Rule:** Product price cannot exceed store's max_listing_price.

**Validation:** Service layer check before creating/updating product

**Implementation:** `ProductService.createProduct()` validates `price <= store.maxListingPrice`

**Error:** Returns validation error with message: "Product price exceeds your store's maximum listing price"

**Formula:** `product.price <= store.max_listing_price` (deposit_amount / 10)

**Location:** `ProductServiceImpl.java` in create/update methods

---

### PL-002: SKU Uniqueness and Auto-Generation ✅

**Rule:** Product SKU must be unique across the entire platform.

**Auto-generation Format:** PRD-XXXXXXXX (PRD prefix + 8 random uppercase letters)

**Constraint:** Unique constraint on `products.sku`

**AJAX Check:** `GET /products/check-sku?sku={sku}`

**Implementation:**
- Service: `ProductService.generateSKU()`
- Repository: `ProductRepository.existsBySku(sku)`
- Controller: `ProductController.checkSkuAvailability()`

**Location:** `ProductServiceImpl.java:generateSKU()`, `ProductController.java:checkSkuAvailability()`

---

### PL-003: Stock Quantity Validation ✅

**Rule:** Product stock quantity must be between 0 and 999,999.

**Constraints:**
- Minimum: 0 (out of stock)
- Maximum: 999,999
- Type: Integer
- Required: Yes

**Low Stock Alert:** Products with stock ≤ 10 flagged in seller dashboard

**Validation:**
```java
@Min(value = 0, message = "Stock quantity cannot be negative")
@Max(value = 999999, message = "Stock quantity cannot exceed 999,999")
```

**Location:** `ProductCreateRequest.java`

---

### PL-004: Product Price Range ✅

**Rule:** Product price must be within valid range: 1,000 - 999,999,999 VND.

**Constraints:**
- Minimum: 1,000 VND (prevent free items)
- Maximum: 999,999,999 VND (DECIMAL(15,2) limit)
- Required: Yes
- Must also satisfy PL-001 (≤ max_listing_price)

**Validation:**
```java
@NotNull
@DecimalMin(value = "1000", message = "Price must be at least 1,000 VND")
@DecimalMax(value = "999999999", message = "Price cannot exceed 999,999,999 VND")
```

**Location:** `ProductCreateRequest.java`

---

### PL-005: Product Name Validation ✅

**Rule:** Product name must be between 1 and 200 characters.

**Constraints:**
- Minimum: 1 character
- Maximum: 200 characters
- Required: Yes
- Special characters allowed (for game names with symbols)

**Validation:**
```java
@NotBlank(message = "Product name is required")
@Size(min = 1, max = 200, message = "Product name must be between 1 and 200 characters")
```

**Location:** `ProductCreateRequest.java`, `Product.java`

---

### PL-006: Product Category Validation ✅

**Rule:** Product must belong to one of the 7 predefined categories.

**Valid Categories (ProductCategory enum):**
1. GAME_ACCOUNT - "Tài khoản Game"
2. GAME_CURRENCY - "Vàng/Tiền Game"
3. SOCIAL_ACCOUNT - "Tài khoản MXH"
4. SOFTWARE_LICENSE - "License Phần mềm"
5. GIFT_CARD - "Thẻ quà tặng"
6. VPN_PROXY - "VPN/Proxy"
7. OTHER - "Khác"

**Validation:**
```java
@NotNull(message = "Category is required")
private ProductCategory category;
```

**Location:** `ProductCategory.java`, `ProductCreateRequest.java`

---

### PL-007: Product Description (Optional) ✅

**Rule:** Product description is optional but recommended for better sales.

**Constraints:**
- Type: TEXT (unlimited length)
- Required: No
- HTML/Markdown: Plain text only (XSS prevention)

**Best Practice:** Include detailed information about product features, delivery method, and usage instructions

**Location:** `Product.java`, `ProductCreateRequest.java`

---

### PL-008: Seller Ownership Verification ✅

**Rule:** Products can only be created by users who own an active seller store.

**Validation Checks:**
1. User is authenticated
2. User has ROLE_SELLER
3. User owns exactly one seller store
4. Store is ACTIVE (not suspended/closed)

**Error:** "You must have an active seller store to create products"

**Implementation:** `ProductService.createProduct()` validates store ownership

**Current Workaround:** Test mode endpoints bypass this check (remove before production)

---

### PL-009: Product Active Status ✅

**Rule:** Only active products are visible to buyers in product listings.

**Status Values:**
- `is_active = true`: Product visible in public listings
- `is_active = false`: Product hidden from buyers (seller can still see/edit)

**Default:** true (active) upon creation

**Toggle:** Sellers can activate/deactivate products via dashboard

**Implementation:**
- `ProductService.toggleProductStatus(productId)`
- `POST /products/{id}/toggle-status`

**Location:** `ProductServiceImpl.java:toggleProductStatus()`, `ProductController.java:toggleProductStatus()`

---

### PL-010: Product Image Storage ✅

**Rule:** Product images stored as JSON array in TEXT column.

**Format:**
```json
["url1", "url2", "url3"]
```

**Storage Path:** `/uploads/products/images/{productId}/{filename}`

**Maximum Images:** No hard limit (recommended: 5-10 images)

**Null Handling:** Empty array `[]` if no images uploaded

**Location:** `Product.java` (productImages field), `FileUploadServiceImpl.java`

---

### PL-011: Soft Delete for Products ✅

**Rule:** Products are never hard-deleted; they are soft-deleted.

**Implementation:**
- Set `is_deleted = 1`
- Set `deleted_by` to user ID
- Update `updated_at` timestamp

**Query Filter:** All product queries filter `is_deleted = 0` by default

**Restoration:** Admins can restore soft-deleted products

**Location:** `ProductServiceImpl.java:deleteProduct()`, `ProductRepository.java`

---

### PL-012: Product Filtering and Search ✅

**Rule:** Products support advanced filtering with 6 parameters.

**Filter Parameters:**
1. **search**: Search in product_name and description (case-insensitive)
2. **category**: Filter by ProductCategory enum
3. **minPrice**: Minimum price filter (inclusive)
4. **maxPrice**: Maximum price filter (inclusive)
5. **storeId**: Filter products by specific store
6. **stockStatus**: Filter by stock availability (ALL, IN_STOCK, LOW_STOCK, OUT_OF_STOCK)

**Stock Status Rules:**
- IN_STOCK: stock_quantity > 10
- LOW_STOCK: 1 ≤ stock_quantity ≤ 10
- OUT_OF_STOCK: stock_quantity = 0

**Implementation:** `ProductRepository.findAllWithFilters()` with dynamic WHERE clauses

**Location:** `ProductRepositoryCustom.java`, `ProductController.java:listProducts()`

---

### PL-013: Product Pagination ✅

**Rule:** Product listings are paginated with configurable page size.

**Defaults:**
- Page: 0 (first page, 0-indexed)
- Size: 12 products per page

**Allowed Sizes:** 12, 24, 48, 96

**Sorting Options:**
- price (ascending/descending)
- productName (alphabetical)
- createdAt (newest/oldest)
- stockQuantity (high to low)

**Implementation:** Spring Data Pageable with `PageRequest.of(page, size, sort)`

**Location:** `ProductController.java:listProducts()`

---

### PL-014: Test Mode Product Creation ⚠️

**Rule:** Test mode endpoints exist for development with hardcoded store_id.

**Endpoints:**
- `GET /products/create-test`
- `POST /products/create-test`

**Behavior:**
- Bypasses seller authentication
- Uses hardcoded `store_id = 2`
- No store ownership validation

**⚠️ WARNING:** Must be removed before production deployment

**Location:** `ProductController.java:453-506`

---

### PL-015: Product Store Relationship ✅

**Rule:** Each product must be associated with exactly one seller store.

**Foreign Keys:**
- `seller_store_id`: References seller_stores(id)
- `seller_id`: References users(id) (denormalized for performance)

**Cascade:** Products soft-deleted when store is deleted

**Validation:** Store must exist and be owned by the authenticated user

**Location:** `Product.java` @ManyToOne relationships

---

## File Upload Rules

### FU-001: Maximum File Size ✅

**Rule:** Uploaded files cannot exceed 2MB per file.

**Configuration:**
```properties
spring.servlet.multipart.max-file-size=10MB  # Global limit
```

**Service-Level Validation:** 2MB enforced in FileUploadService

**Error Message:** "File size exceeds the maximum allowed size of 2MB"

**Implementation:** `FileUploadServiceImpl.uploadProductImage()` validates file size before processing

**Location:** `FileUploadServiceImpl.java:uploadProductImage()`

---

### FU-002: Allowed File Types ✅

**Rule:** Only specific image file types are allowed for product images.

**Allowed Extensions:**
- jpg
- jpeg
- png
- gif

**Content-Type Validation:** Validates both file extension AND MIME type

**Allowed MIME Types:**
- image/jpeg
- image/png
- image/gif

**Error Message:** "Invalid file type. Only JPG, JPEG, PNG, and GIF files are allowed"

**Implementation:** `FileUploadServiceImpl.isValidImageFile(file)`

**Location:** `FileUploadServiceImpl.java:isValidImageFile()`

---

### FU-003: File Naming Convention ✅

**Rule:** Uploaded files are renamed using timestamp and UUID to prevent conflicts.

**Format:** `{timestamp}_{uuid}.{original_extension}`

**Example:** `1704067200000_a3f2c8d1-4e5f-6a7b-8c9d-0e1f2a3b4c5d.jpg`

**Benefits:**
- Prevents filename conflicts
- Prevents path traversal attacks
- Maintains original file extension
- Sortable by upload time

**Implementation:** `FileUploadServiceImpl.generateUniqueFileName(originalFilename)`

**Location:** `FileUploadServiceImpl.java:generateUniqueFileName()`

---

### FU-004: File Storage Path Structure ✅

**Rule:** Uploaded files are organized in a structured directory hierarchy.

**Path Structure:**
```
uploads/{type}/{entity_id}/{filename}
```

**Examples:**
- Product images: `uploads/products/images/123/1704067200000_uuid.jpg`
- Store logos: `uploads/stores/logos/5/1704067200000_uuid.png`

**Directory Creation:** Automatically created if not exists

**Permissions:** Upload directory must be writable by application

**Implementation:**
- `FileUploadServiceImpl.uploadProductImage(productId, file)`
- Path: `uploadDir + "/products/images/" + productId + "/"`

**Location:** `FileUploadServiceImpl.java`

---

### FU-005: File Upload Base Directory ✅

**Rule:** All uploads stored in configurable base directory.

**Configuration:**
```properties
file.upload-dir=uploads  # Relative to project root
```

**Default Value:** `uploads/` if not configured

**Absolute Path:** Resolved relative to application working directory

**Access:** Files served via static resource mapping or controller endpoint

**Implementation:**
```java
@Value("${file.upload-dir:uploads}")
private String uploadDir;
```

**Location:** `FileUploadServiceImpl.java:uploadDir` field

---

### FU-006: Image Upload for Products ✅

**Rule:** Product images uploaded after product creation, not during.

**Process:**
1. Create product (without images)
2. Product saved with `productImages = null` or empty array
3. Upload images via separate endpoint
4. Images appended to product's `productImages` JSON array
5. Product updated with new image URLs

**Endpoint:** `POST /products/{id}/upload-images`

**Multiple Uploads:** Supports uploading multiple images sequentially

**Implementation:** `ProductController.uploadProductImages(productId, file)`

**Location:** `ProductController.java:uploadProductImages()`, `ProductServiceImpl.java:addProductImage()`

---

### FU-007: File Upload Error Handling ✅

**Rule:** All file upload errors are handled gracefully with user-friendly messages.

**Error Scenarios:**
1. **File too large:** "File size exceeds the maximum allowed size of 2MB"
2. **Invalid file type:** "Invalid file type. Only JPG, JPEG, PNG, and GIF files are allowed"
3. **Empty file:** "Uploaded file is empty"
4. **IO error:** "Failed to upload file. Please try again"
5. **Storage error:** "Failed to create upload directory"

**HTTP Status Codes:**
- 400 Bad Request: Validation errors (size, type)
- 500 Internal Server Error: IO/storage errors

**Implementation:** Try-catch blocks in `FileUploadServiceImpl` with specific exception handling

**Location:** `FileUploadServiceImpl.java` upload methods

---

### FU-008: File Security Validation ✅

**Rule:** Uploaded files are validated for security threats.

**Validations:**
1. **File size limit:** Prevents DoS attacks
2. **Extension whitelist:** Prevents executable uploads
3. **Content-type verification:** Prevents MIME type spoofing
4. **Filename sanitization:** Prevents path traversal (../, ..\)
5. **UUID naming:** Prevents predictable filenames

**Not Implemented (Recommended):**
- Virus scanning
- Image content validation (check if actually an image)
- File hash verification

**Location:** `FileUploadServiceImpl.java:isValidImageFile()`, `generateUniqueFileName()`

---

## Order & Purchase Rules

### OP-001: Order Creation

**Rule:** Order can only be created if product is in stock.

**Pre-conditions:**
- Product status = ACTIVE
- Product stock > 0
- Available ProductStorage entry exists
- Buyer has sufficient wallet balance

**Process:**
1. Reserve ProductStorage (AVAILABLE → RESERVED)
2. Create Order entity
3. Create EscrowTransaction
4. Deduct funds from buyer's wallet
5. Record wallet transaction

**Atomicity:** All steps in single transaction

---

### OP-002: Product Data Snapshot

**Rule:** Order must capture product details at time of purchase.

**Stored Fields:**
- product_name
- product_price
- quantity
- product_data (JSON snapshot of product + ProductStorage)

**Rationale:** Preserve order details even if product is later modified/deleted

---

### OP-003: Order Status Flow

**Rule:** Orders follow a defined status lifecycle.

**Status Flow:**
```
PENDING → CONFIRMED → DELIVERED → COMPLETED
                           ↓
                       CANCELLED
                           ↓
                       REFUNDED
```

**Transitions:**
- PENDING: Order created, payment processing
- CONFIRMED: Payment received, escrow holding
- DELIVERED: Seller marked digital goods as delivered
- COMPLETED: Escrow released, transaction finished
- CANCELLED: Order cancelled before delivery
- REFUNDED: Funds returned to buyer

---

### OP-004: Order Cancellation

**Rule:** Orders can only be cancelled before delivery.

**Cancellation Allowed:**
- Buyer: Before seller delivers (within 1 hour recommended)
- Seller: If cannot fulfill order
- Admin: Policy violation or dispute resolution

**Refund Process:**
1. Release ProductStorage (RESERVED → AVAILABLE)
2. Refund escrow to buyer's wallet
3. Record REFUND transaction
4. Update order status to CANCELLED

---

## Escrow System Rules

### ES-001: Escrow Hold Period

**Rule:** All order payments are held in escrow for 3 days after delivery.

**Configuration:** `marketplace.escrow.hold-days=3` in `application.properties`

**Calculation:**
```
hold_until = created_at + INTERVAL 3 DAY
```

**Implementation:** MySQL generated column in `escrow_transactions` table

---

### ES-002: Escrow Auto-Release

**Rule:** Escrow funds are automatically released to seller after hold period expires.

**Process:**
1. Scheduled task runs daily
2. Check `escrow_transactions.hold_until <= NOW()`
3. Transfer funds to seller's wallet
4. Record SALE transaction for seller
5. Update escrow status to RELEASED
6. Update order status to COMPLETED

**Implementation:** `EscrowService.releaseExpiredEscrows()` (scheduled job, planned)

---

### ES-003: Early Release

**Rule:** Buyer can manually release escrow early.

**Conditions:**
- Order status = DELIVERED
- Buyer confirms satisfaction
- No disputes opened

**Process:**
1. Buyer clicks "Confirm Receipt"
2. Immediate escrow release to seller
3. Enable review functionality

**Implementation:** `EscrowService.releaseEscrowEarly(orderId, buyerId)` (planned)

---

### ES-004: Escrow Refund

**Rule:** Escrow refunded to buyer if order cancelled or dispute resolved in buyer's favor.

**Triggers:**
- Order cancelled before delivery
- Dispute resolved: RESOLVED_BUYER
- Seller fails to deliver within timeframe

**Process:**
1. Transfer funds from escrow to buyer's wallet
2. Record REFUND transaction
3. Update escrow status to REFUNDED
4. Update order status to REFUNDED

---

## Review System Rules

### RV-001: Review Eligibility

**Rule:** Reviews can only be left after order is completed.

**Conditions:**
- Order status = COMPLETED
- Escrow released (auto or manual)
- Review not yet submitted

**One Review Per Order:** Unique constraint on `product_reviews.order_id` and `seller_reviews.order_id`

---

### RV-002: Rating Scale

**Rule:** Ratings must be between 1 and 5 stars.

**Constraint:** CHECK constraint on `product_reviews.rating` and `seller_reviews.rating`

**Required:** Rating is mandatory, content is optional

---

### RV-003: Dual Review System

**Rule:** Buyers can leave separate reviews for product and seller.

**Product Review:**
- Quality of digital goods
- Accuracy of description
- Value for money

**Seller Review:**
- Communication
- Delivery speed
- Professionalism

**Independence:** Both reviews are independent and optional

---

### RV-004: Review Modification

**Rule:** Reviews can be edited within 7 days of submission.

**After 7 Days:** Reviews become permanent (cannot edit or delete)

**Admin Override:** Admins can remove reviews for policy violations

**Implementation:** `ReviewService.updateReview()` with timestamp check (planned)

---

### RV-005: Review Display

**Rule:** All reviews are publicly visible.

**Aggregation:**
- Average rating displayed on product/store pages
- Total review count shown
- Recent reviews highlighted

**Sorting Options:**
- Most recent
- Highest rated
- Lowest rated
- Most helpful (planned)

---

## Dispute Resolution Rules

### DR-001: Dispute Opening Window

**Rule:** Disputes must be opened within escrow hold period.

**Deadline:** Before escrow auto-releases (3 days after delivery)

**After Deadline:** Contact support for case-by-case review

---

### DR-002: Dispute Reasons

**Rule:** Disputes must specify a valid reason.

**Valid Reasons:**
- Product not as described
- Credentials invalid/incorrect
- Product already used/claimed
- Seller unresponsive
- Other (with description)

---

### DR-003: Escrow Hold During Dispute

**Rule:** Escrow funds remain frozen until dispute is resolved.

**Auto-release Disabled:** hold_until extended indefinitely

**Notification:** Both parties notified of dispute

---

### DR-004: Dispute Resolution

**Rule:** Only moderators/admins can resolve disputes.

**Resolution Options:**
- RESOLVED_BUYER: Full refund to buyer
- RESOLVED_SELLER: Full payment to seller
- PARTIAL_REFUND: Split payment (e.g., 50/50)

**Evidence Required:**
- Chat logs
- Screenshots
- Product data verification
- User history

---

### DR-005: Post-Resolution Actions

**Rule:** Appropriate actions taken based on resolution.

**If RESOLVED_BUYER:**
- Refund escrow to buyer
- ProductStorage returned to available (if applicable)
- Mark seller for review

**If RESOLVED_SELLER:**
- Release escrow to seller
- Mark buyer for review (potential fraud)

---

## Role & Permission Rules

### RP-001: Role Assignment

**Rule:** Users can have multiple roles simultaneously.

**Many-to-Many Relationship:** `user_roles` table

**Cumulative Permissions:** User has all permissions from all assigned roles

**Example:**
- User with ROLE_USER + ROLE_SELLER has permissions from both roles

---

### RP-002: Permission Inheritance

**Rule:** Permissions are derived from roles, not assigned directly to users.

**Authority Resolution:**
```java
user.getAuthorities() =
    user.getRoles()
        .flatMap(role -> role.getPermissions())
        .map(permission -> permission.getCode())
```

**Implementation:** `User.getAuthorities()` in User entity

---

### RP-003: Admin Override

**Rule:** ROLE_ADMIN has all permissions in the system.

**Implementation:** Grant all 27 permissions to ROLE_ADMIN in database seeding

**Special Privileges:**
- Verify/suspend stores
- Resolve disputes
- View all users/orders
- System configuration access

---

### RP-004: Role-Based Access Control

**Rule:** Controllers enforce authorization via `@PreAuthorize` annotations.

**Examples:**
```java
@PreAuthorize("hasRole('SELLER')")  // Seller endpoints
@PreAuthorize("hasRole('ADMIN')")   // Admin endpoints
@PreAuthorize("hasAuthority('STORE_CREATE')")  // Permission-based
```

**Fallback:** Deny access if no matching role/permission

---

### RP-005: Automatic Role Assignment

**Rule:** Certain actions automatically assign roles.

**Assignments:**
- User registration → ROLE_USER
- Store creation → ROLE_SELLER (currently disabled)
- First purchase → ROLE_BUYER (planned)

**Manual Only:**
- ROLE_ADMIN: Admin assignment only
- ROLE_MODERATOR: Admin assignment only

---

### RP-006: Permission Categories

**Rule:** Permissions are organized into logical categories.

**Categories:**
1. User Management (4)
2. Store Management (4)
3. Product Management (4)
4. Order Management (4)
5. Wallet Management (3)
6. Review Management (3)
7. Dispute Management (3)
8. System Management (2)

**Total:** 27 permissions

---

## Configuration Rules

### CR-001: Configurable Business Parameters

**Rule:** Key business values are externalized in application.properties.

**Parameters:**
- `marketplace.seller.minimum-deposit`: 5000000 (VND)
- `marketplace.escrow.hold-days`: 3 (days)
- `marketplace.wallet.currency`: VND

**Changes:** Require application restart

---

### CR-002: File Upload Limits ✅

**Rule:** File uploads are limited by size and type.

**Global Constraints (Spring Boot):**
- Max file size: 10MB (multipart limit)
- Max request size: 10MB

**Service-Level Constraints (Business Logic):**
- Product images: 2MB per file
- Allowed types: JPG, JPEG, PNG, GIF
- Content-type validation: Required

**Configuration:**
```properties
spring.servlet.multipart.max-file-size=10MB
spring.servlet.multipart.max-request-size=10MB
file.upload-dir=uploads
```

**Implementation:** `FileUploadServiceImpl` enforces 2MB limit and file type validation

**Location:** `application.properties`, `FileUploadServiceImpl.java`

---

## Data Integrity Rules

### DI-001: Soft Delete

**Rule:** All entities support soft delete (never hard delete immediately).

**Implementation:**
- Set `is_deleted = 1`
- Set `deleted_by` to deleting user's ID
- Update `updated_at` timestamp

**Queries:** Filter `is_deleted = 0` by default

---

### DI-002: Audit Trail

**Rule:** All entities track creation and modification metadata.

**Fields (BaseEntity):**
- created_at: Timestamp of creation
- created_by: User ID who created
- updated_at: Timestamp of last update
- deleted_by: User ID who deleted
- is_deleted: Soft delete flag

---

### DI-003: Referential Integrity

**Rule:** Foreign key constraints enforce data relationships.

**Delete Actions:**
- CASCADE: Child deleted when parent deleted (e.g., wallet → wallet_transactions)
- RESTRICT: Prevent parent deletion if children exist (e.g., cannot delete user with orders)
- SET NULL: Set FK to NULL when parent deleted (e.g., product deleted, order.product_id = NULL)

---

## Summary

These business rules form the foundation of the TaphoaMMO Marketplace platform. They ensure:

✅ Fair trading practices
✅ Buyer protection through escrow
✅ Seller accountability via deposits
✅ Data integrity and auditability
✅ Flexible permission system
✅ Scalable financial system

**Note:** Rules marked with ⚠️ are temporarily disabled for development/testing and should be re-enabled before production deployment.

---

**Last Updated:** January 2025
**Document Version:** 1.0.0
