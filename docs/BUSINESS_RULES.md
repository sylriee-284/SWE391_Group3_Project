# Business Rules Documentation

## Table of Contents
1. [Overview](#overview)
2. [User Management Rules](#user-management-rules)
3. [Seller Store Rules](#seller-store-rules)
4. [Wallet & Financial Rules](#wallet--financial-rules)
5. [Product Listing Rules](#product-listing-rules)
6. [Order & Purchase Rules](#order--purchase-rules)
7. [Escrow System Rules](#escrow-system-rules)
8. [Review System Rules](#review-system-rules)
9. [Dispute Resolution Rules](#dispute-resolution-rules)
10. [Role & Permission Rules](#role--permission-rules)

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

### PL-001: Price Limit Enforcement

**Rule:** Product price cannot exceed store's max_listing_price.

**Validation:** Service layer check before creating/updating product

**Implementation:** `SellerStoreService.canListProduct(storeId, productPrice)`

**Error:** Return validation error if price exceeds limit

**Formula:** `product.price <= store.max_listing_price`

---

### PL-002: Product Slug Uniqueness

**Rule:** Product slug must be unique within the same store.

**Constraint:** Unique constraint on `products(seller_store_id, slug)`

**Auto-generation:** Generate slug from product name (recommended)

**Example:**
- Name: "Level 80 WoW Account"
- Slug: "level-80-wow-account"

---

### PL-003: Stock Management

**Rule:** Product stock must match available ProductStorage entries.

**Calculation:**
```sql
stock = COUNT(*) FROM product_storage
WHERE product_id = ? AND status = 'AVAILABLE'
```

**Auto-update:** Stock decremented when ProductStorage reserved for order

**Out of Stock:** Product status set to OUT_OF_STOCK when stock = 0

---

### PL-004: Product Status

**Rule:** Only ACTIVE products are visible to buyers.

**Status Values:**
- DRAFT: Not published, visible to seller only
- ACTIVE: Published and available for purchase
- INACTIVE: Temporarily hidden
- OUT_OF_STOCK: No inventory available

**Transition Rules:**
- DRAFT → ACTIVE: Manual publish by seller
- ACTIVE → OUT_OF_STOCK: Automatic when stock = 0
- OUT_OF_STOCK → ACTIVE: Automatic when stock > 0
- Any → INACTIVE: Manual by seller or admin

---

### PL-005: Digital Product Storage

**Rule:** Each digital product must have ProductStorage entries with credentials/keys.

**Structure:**
```json
{
  "username": "account_username",
  "password": "account_password",
  "email": "linked_email@example.com",
  "additionalData": "any relevant info"
}
```

**Security:**
- `payload_json`: Full credentials (encrypted recommended)
- `payload_mask`: Masked preview for buyers (e.g., "user***@gm***.com")

**Status Flow:**
- AVAILABLE → RESERVED (during purchase) → DELIVERED (after order completion)

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

### CR-002: File Upload Limits

**Rule:** File uploads are limited by size and type.

**Constraints:**
- Max file size: 10MB
- Max request size: 10MB
- Allowed types: Images (JPG, PNG, GIF) for logos

**Configuration:**
```properties
spring.servlet.multipart.max-file-size=10MB
spring.servlet.multipart.max-request-size=10MB
```

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
