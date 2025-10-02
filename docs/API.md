# API Endpoint Documentation

## Table of Contents
1. [API Overview](#api-overview)
2. [Authentication](#authentication)
3. [Dashboard Endpoints](#dashboard-endpoints)
4. [User Management Endpoints](#user-management-endpoints)
5. [Seller Store Endpoints](#seller-store-endpoints)
6. [Product Management Endpoints](#product-management-endpoints) ✨ NEW
7. [Admin Store Endpoints](#admin-store-endpoints)
8. [Response Formats](#response-formats)
9. [Error Handling](#error-handling)

---

## API Overview

### Base Information
- **Base URL:** `http://localhost:8081`
- **API Style:** RESTful (with MVC view rendering)
- **Response Format:** HTML (JSP views) and JSON (AJAX endpoints)
- **Authentication:** Spring Security (currently Basic HTTP Auth)

### API Types
1. **Web MVC Endpoints:** Return JSP views (HTML)
2. **AJAX Endpoints:** Return JSON responses
3. **Form Submissions:** Return redirects with flash attributes

---

## Authentication

### Current Authentication (Temporary)
- **Type:** HTTP Basic Authentication
- **Username:** `admin`
- **Password:** `admin123`

### Planned Authentication
- **Type:** Form-based login with session
- **Login Endpoint:** `POST /login`
- **Logout Endpoint:** `POST /logout`
- **Session Management:** HTTP Session + Remember-Me

### Authorization
- **Method:** Spring Security `@PreAuthorize` annotations
- **Roles:** ROLE_ADMIN, ROLE_MODERATOR, ROLE_SELLER, ROLE_BUYER, ROLE_USER
- **Permissions:** 27 granular permissions

---

## Dashboard Endpoints

### 1. Main Dashboard

**GET /** or **GET /dashboard**

Display main dashboard with system statistics.

**Authentication:** No (Public)

**Response:** JSP view (`dashboard.jsp`)

**Model Attributes:**
```java
{
  "currentUser": User,        // Current authenticated user (or null)
  "hasStore": Boolean,        // Whether user has a store
  "totalUsers": Long,
  "totalStores": Long,
  "totalWalletBalance": BigDecimal
}
```

**Controller:** `DashboardController.dashboard()`

**Location:** `src/main/java/vn/group3/marketplace/controller/web/DashboardController.java:29`

---

### 2. Health Check

**GET /health**

Simple health check endpoint.

**Authentication:** No

**Response:** Plain text
```
OK
```

**Controller:** `DashboardController.health()`

**Location:** `src/main/java/vn/group3/marketplace/controller/web/DashboardController.java:56`

---

## User Management Endpoints

### 1. List Users

**GET /users**

List all users with pagination, sorting, search, and filtering.

**Authentication:** No (Public - but should be restricted in production)

**Query Parameters:**
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| page | Integer | 0 | Page number (0-indexed) |
| size | Integer | 10 | Items per page |
| sort | String | "id" | Sort field |
| direction | String | "desc" | Sort direction (asc/desc) |
| search | String | null | Search term (username, email, fullName) |
| status | String | null | Filter by status (ACTIVE, INACTIVE) |
| role | String | null | Filter by role code |

**Response:** JSP view (`user/list.jsp`)

**Model Attributes:**
```java
{
  "users": Page<User>,
  "currentPage": Integer,
  "totalPages": Integer,
  "totalItems": Long,
  "search": String,
  "status": String,
  "role": String,
  "sort": String,
  "direction": String
}
```

**Example:**
```
GET /users?page=0&size=20&search=john&status=ACTIVE&sort=username&direction=asc
```

**Controller:** `UserController.listUsers()`

**Location:** `src/main/java/vn/group3/marketplace/controller/web/UserController.java:45`

---

### 2. View User Profile

**GET /users/profile**

View current authenticated user's profile.

**Authentication:** Required (Principal)

**Response:** JSP view (`user/profile.jsp`)

**Model Attributes:**
```java
{
  "user": User,
  "wallet": Wallet
}
```

**Controller:** `UserController.viewProfile()`

**Location:** `src/main/java/vn/group3/marketplace/controller/web/UserController.java:78`

---

### 3. View User by ID

**GET /users/{id}**

View user details by ID.

**Authentication:** No (Public)

**Path Parameters:**
- `id` (Long) - User ID

**Response:** JSP view (`user/profile.jsp`)

**Model Attributes:**
```java
{
  "user": User,
  "wallet": Wallet
}
```

**Error:** Redirects to `/users` with error message if user not found

**Controller:** `UserController.viewUser()`

**Location:** `src/main/java/vn/group3/marketplace/controller/web/UserController.java:90`

---

### 4. Registration Form

**GET /users/register**

Display user registration form.

**Authentication:** No (Public)

**Response:** JSP view (`user/register.jsp`)

**Model Attributes:**
```java
{
  "user": new User()  // Empty user object for form binding
}
```

**Controller:** `UserController.showRegistrationForm()`

**Location:** `src/main/java/vn/group3/marketplace/controller/web/UserController.java:108`

---

### 5. Submit Registration

**POST /users/register**

Process user registration.

**Authentication:** No (Public)

**Request Body (Form Data):**
```java
{
  "username": String,         // Required, 3-50 chars
  "email": String,            // Required, valid email
  "password": String,         // Required, min 6 chars
  "confirmPassword": String,  // Must match password
  "fullName": String,         // Optional
  "phone": String,            // Optional
  "dateOfBirth": Date,        // Optional
  "gender": String            // Optional (MALE, FEMALE, OTHER)
}
```

**Validation:**
- Username uniqueness
- Email uniqueness
- Password matching
- Jakarta Bean Validation constraints

**Success Response:** Redirect to `/users` with success message

**Error Response:** Return to form with validation errors

**Controller:** `UserController.registerUser()`

**Location:** `src/main/java/vn/group3/marketplace/controller/web/UserController.java:115`

---

### 6. Edit Profile Form

**GET /users/edit**

Display edit profile form for current user.

**Authentication:** Required (Principal)

**Response:** JSP view (`user/edit.jsp`)

**Model Attributes:**
```java
{
  "user": User  // Current user's data
}
```

**Controller:** `UserController.showEditForm()`

**Location:** `src/main/java/vn/group3/marketplace/controller/web/UserController.java:141`

---

### 7. Update Profile

**POST /users/edit**

Update current user's profile.

**Authentication:** Required (Principal)

**Request Body (Form Data):**
```java
{
  "fullName": String,
  "phone": String,
  "dateOfBirth": Date,
  "gender": String,
  "avatarUrl": String
}
```

**Note:** Username and email cannot be changed

**Success Response:** Redirect to `/users/profile` with success message

**Error Response:** Return to form with validation errors

**Controller:** `UserController.updateProfile()`

**Location:** `src/main/java/vn/group3/marketplace/controller/web/UserController.java:150`

---

### 8. Change Password Form

**GET /users/change-password**

Display change password form.

**Authentication:** Required (Principal)

**Response:** JSP view (`user/change-password.jsp`)

**Controller:** `UserController.showChangePasswordForm()`

**Location:** `src/main/java/vn/group3/marketplace/controller/web/UserController.java:170`

---

### 9. Submit Password Change

**POST /users/change-password**

Change user's password.

**Authentication:** Required (Principal)

**Request Body (Form Data):**
```java
{
  "currentPassword": String,    // Required
  "newPassword": String,        // Required, min 6 chars
  "confirmPassword": String     // Must match newPassword
}
```

**Validation:**
- Current password must be correct
- New password must match confirmation
- New password must meet strength requirements

**Success Response:** Redirect to `/users/profile` with success message

**Error Response:** Return to form with error message

**Controller:** `UserController.changePassword()`

**Location:** `src/main/java/vn/group3/marketplace/controller/web/UserController.java:177`

---

### 10. Check Username Availability (AJAX)

**GET /users/check-username**

Check if username is available.

**Authentication:** No

**Query Parameters:**
- `username` (String) - Username to check
- `currentUsername` (String, optional) - Exclude from check (for edit profile)

**Response:** JSON
```json
{
  "available": true
}
```

**Controller:** `UserController.checkUsernameAvailability()`

**Location:** `src/main/java/vn/group3/marketplace/controller/web/UserController.java:201`

---

### 11. Check Email Availability (AJAX)

**GET /users/check-email**

Check if email is available.

**Authentication:** No

**Query Parameters:**
- `email` (String) - Email to check
- `currentEmail` (String, optional) - Exclude from check (for edit profile)

**Response:** JSON
```json
{
  "available": false
}
```

**Controller:** `UserController.checkEmailAvailability()`

**Location:** `src/main/java/vn/group3/marketplace/controller/web/UserController.java:216`

---

### 12. Toggle User Status (AJAX)

**POST /users/{id}/toggle-status**

Enable or disable a user account.

**Authentication:** No (Should be ROLE_ADMIN)

**Path Parameters:**
- `id` (Long) - User ID

**Response:** JSON
```json
{
  "success": true,
  "enabled": false,
  "message": "User disabled successfully"
}
```

**Controller:** `UserController.toggleUserStatus()`

**Location:** `src/main/java/vn/group3/marketplace/controller/web/UserController.java:231`

---

## Seller Store Endpoints

### 1. List Stores

**GET /stores**

List all active stores with pagination, sorting, and search.

**Authentication:** No (Public)

**Query Parameters:**
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| page | Integer | 0 | Page number (0-indexed) |
| size | Integer | 12 | Items per page |
| sort | String | "createdAt" | Sort field |
| direction | String | "desc" | Sort direction |
| search | String | null | Search term (store name, description) |
| status | String | null | Filter by status |

**Response:** JSP view (`store/list.jsp`)

**Model Attributes:**
```java
{
  "stores": Page<SellerStoreResponse>,
  "currentPage": Integer,
  "totalPages": Integer,
  "totalItems": Long,
  "search": String,
  "status": String
}
```

**Controller:** `SellerStoreController.listStores()`

**Location:** `src/main/java/vn/group3/marketplace/controller/web/SellerStoreController.java:56`

---

### 2. View Store Details

**GET /stores/{storeId}**

View public store details.

**Authentication:** No (Public)

**Path Parameters:**
- `storeId` (Long) - Store ID

**Response:** JSP view (`store/details.jsp`)

**Model Attributes:**
```java
{
  "store": SellerStoreResponse,
  "products": List<Product>  // (Planned)
}
```

**Error:** Redirects to `/stores` with error if store not found

**Controller:** `SellerStoreController.viewStore()`

**Location:** `src/main/java/vn/group3/marketplace/controller/web/SellerStoreController.java:89`

---

### 3. Create Store Form

**GET /stores/create**

Display create store form.

**Authentication:** User (temporarily disabled via `@PreAuthorize`)

**Note:** Currently accessible without authentication for testing (uses fallback user ID 2)

**Response:** JSP view (`store/create.jsp`)

**Model Attributes:**
```java
{
  "minimumDeposit": BigDecimal,  // From configuration
  "storeRequest": new SellerStoreCreateRequest()
}
```

**Error:** Redirects to `/?error=already_has_store` if user already has a store

**Controller:** `SellerStoreController.showCreateStoreForm()`

**Location:** `src/main/java/vn/group3/marketplace/controller/web/SellerStoreController.java:106`

---

### 4. Submit Create Store

**POST /stores/create**

Create a new seller store.

**Authentication:** User (temporarily disabled)

**Request Body (Form Data):**
```java
{
  "storeName": String,           // Required, 3-100 chars
  "storeDescription": String,    // Optional
  "contactEmail": String,        // Optional, valid email
  "contactPhone": String,        // Optional
  "depositAmount": BigDecimal,   // Required (min 5,000,000 - currently disabled)
  "businessLicense": String      // Optional
}
```

**Validation:**
- Store name uniqueness (case-insensitive)
- User can only create one store
- Sufficient wallet balance (currently disabled)
- Deposit amount >= minimum (currently disabled)

**Success Response:** Redirect to `/stores/my-store` with success message

**Error Response:** Return to form with validation errors

**Business Logic (Currently Disabled):**
1. ~~Check wallet balance >= depositAmount~~
2. Create store
3. ~~Deduct deposit from wallet~~
4. ~~Assign ROLE_SELLER to user~~
5. Calculate max_listing_price = depositAmount / 10 (or 999999999 if no deposit)

**Controller:** `SellerStoreController.createStore()`

**Location:** `src/main/java/vn/group3/marketplace/controller/web/SellerStoreController.java:140`

---

### 5. My Store Dashboard

**GET /stores/my-store**

View seller's own store dashboard.

**Authentication:** ROLE_SELLER

**Response:** JSP view (`store/dashboard.jsp`)

**Model Attributes:**
```java
{
  "store": SellerStore,
  "dashboard": StoreDashboardResponse,
  "statistics": Map<String, Object>
}
```

**Error:** Redirects to `/stores/create` if seller doesn't have a store

**Controller:** `SellerStoreController.myStoreDashboard()`

**Location:** `src/main/java/vn/group3/marketplace/controller/web/SellerStoreController.java:179`

---

### 6. Store Settings Form

**GET /stores/my-store/settings**

Display store settings form.

**Authentication:** ROLE_SELLER

**Response:** JSP view (`store/settings.jsp`)

**Model Attributes:**
```java
{
  "store": SellerStore
}
```

**Controller:** `SellerStoreController.showStoreSettings()`

**Location:** `src/main/java/vn/group3/marketplace/controller/web/SellerStoreController.java:202`

---

### 7. Update Store Settings

**POST /stores/my-store/settings**

Update store settings.

**Authentication:** ROLE_SELLER

**Request Body (Form Data):**
```java
{
  "storeDescription": String,
  "contactEmail": String,
  "contactPhone": String,
  "businessLicense": String
}
```

**Note:** Store name and deposit cannot be changed here

**Success Response:** Redirect to `/stores/my-store/settings` with success message

**Error Response:** Return to form with validation errors

**Controller:** `SellerStoreController.updateStoreSettings()`

**Location:** `src/main/java/vn/group3/marketplace/controller/web/SellerStoreController.java:218`

---

### 8. Upload Store Logo

**POST /stores/my-store/upload-logo**

Upload store logo image.

**Authentication:** ROLE_SELLER

**Request Body (Multipart Form Data):**
```java
{
  "logoFile": MultipartFile  // Max 10MB, image formats
}
```

**Success Response:** Redirect to `/stores/my-store/settings` with success message

**Error Response:** Redirect with error message

**Note:** Currently throws `UnsupportedOperationException` (not implemented)

**Controller:** `SellerStoreController.uploadStoreLogo()`

**Location:** `src/main/java/vn/group3/marketplace/controller/web/SellerStoreController.java:243`

---

### 9. Remove Store Logo

**POST /stores/my-store/remove-logo**

Remove store logo.

**Authentication:** ROLE_SELLER

**Success Response:** Redirect to `/stores/my-store/settings` with success message

**Error Response:** Redirect with error message

**Note:** Currently throws `UnsupportedOperationException` (not implemented)

**Controller:** `SellerStoreController.removeStoreLogo()`

**Location:** `src/main/java/vn/group3/marketplace/controller/web/SellerStoreController.java:265`

---

### 10. Deactivate Store

**POST /stores/my-store/deactivate**

Deactivate store (temporarily disable).

**Authentication:** ROLE_SELLER

**Success Response:** Redirect to `/stores/my-store` with success message

**Error Response:** Redirect with error message

**Controller:** `SellerStoreController.deactivateStore()`

**Location:** `src/main/java/vn/group3/marketplace/controller/web/SellerStoreController.java:283`

---

### 11. Activate Store

**POST /stores/my-store/activate**

Reactivate store.

**Authentication:** ROLE_SELLER

**Success Response:** Redirect to `/stores/my-store` with success message

**Error Response:** Redirect with error message

**Controller:** `SellerStoreController.activateStore()`

**Location:** `src/main/java/vn/group3/marketplace/controller/web/SellerStoreController.java:301`

---

### 12. Check Store Name Availability (AJAX)

**GET /stores/check-name**

Check if store name is available.

**Authentication:** No

**Query Parameters:**
- `storeName` (String) - Store name to check
- `currentStoreName` (String, optional) - Exclude from check (for edit)

**Response:** JSON
```json
{
  "available": true
}
```

**Controller:** `SellerStoreController.checkStoreNameAvailability()`

**Location:** `src/main/java/vn/group3/marketplace/controller/web/SellerStoreController.java:319`

---

### 13. Calculate Max Price (AJAX)

**GET /stores/calculate-max-price**

Calculate maximum listing price based on deposit amount.

**Authentication:** No

**Query Parameters:**
- `depositAmount` (BigDecimal) - Proposed deposit amount

**Response:** JSON
```json
{
  "maxListingPrice": "500000.00"
}
```

**Formula:** `maxListingPrice = depositAmount / 10`

**Controller:** `SellerStoreController.calculateMaxListingPrice()`

**Location:** `src/main/java/vn/group3/marketplace/controller/web/SellerStoreController.java:334`

---

## Product Management Endpoints

### 1. List Products (Public)

**GET /products**

List all active products with advanced filtering and pagination.

**Authentication:** No (Public)

**Query Parameters:**
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| page | Integer | 0 | Page number (0-indexed) |
| size | Integer | 12 | Items per page (12, 24, 48, 96) |
| sort | String | "createdAt" | Sort field (price, productName, createdAt, stockQuantity) |
| direction | String | "desc" | Sort direction (asc/desc) |
| search | String | null | Search in product name and description |
| category | String | null | Filter by ProductCategory enum |
| minPrice | BigDecimal | null | Minimum price filter |
| maxPrice | BigDecimal | null | Maximum price filter |
| storeId | Long | null | Filter by specific store |
| stockStatus | String | "ALL" | Stock filter (ALL, IN_STOCK, LOW_STOCK, OUT_OF_STOCK) |

**Response:** JSP view (`product/list.jsp`)

**Model Attributes:**
```java
{
  "products": Page<ProductResponse>,
  "currentPage": Integer,
  "totalPages": Integer,
  "totalItems": Long,
  "categories": ProductCategory[],
  "filters": {
    "search": String,
    "category": String,
    "minPrice": BigDecimal,
    "maxPrice": BigDecimal,
    "stockStatus": String
  }
}
```

**Example:**
```
GET /products?page=0&size=24&category=GAME_ACCOUNT&minPrice=100000&maxPrice=1000000&search=level
```

**Controller:** `ProductController.listProducts()`

**Location:** `src/main/java/vn/group3/marketplace/controller/web/ProductController.java:82`

---

### 2. View Product Details

**GET /products/{productId}**

View public product details.

**Authentication:** No (Public)

**Path Parameters:**
- `productId` (Long) - Product ID

**Response:** JSP view (`product/detail.jsp`)

**Model Attributes:**
```java
{
  "product": ProductResponse,
  "store": SellerStore,
  "seller": User,
  "relatedProducts": List<ProductResponse>  // (planned)
}
```

**Error:** Redirects to `/products` with error if product not found or inactive

**Controller:** `ProductController.viewProduct()`

**Location:** `ProductController.java:136`

---

### 3. Seller Product Dashboard

**GET /products/my-products**

View seller's product management dashboard with statistics.

**Authentication:** ROLE_SELLER

**Response:** JSP view (`product/my-products.jsp`)

**Model Attributes:**
```java
{
  "products": Page<Product>,
  "totalProducts": Long,
  "activeProducts": Long,
  "lowStockProducts": List<Product>,
  "outOfStockProducts": List<Product>,
  "totalValue": BigDecimal
}
```

**Controller:** `ProductController.myProducts()`

**Location:** `ProductController.java:182`

---

### 4. Create Product Form

**GET /products/create**

Show product creation form.

**Authentication:** User (temporarily public for testing)

**Response:** JSP view (`product/create.jsp`)

**Model Attributes:**
```java
{
  "categories": ProductCategory[],
  "store": SellerStore,
  "maxListingPrice": BigDecimal,
  "productRequest": new ProductCreateRequest()
}
```

**Error:** Redirects if seller doesn't have a store

**Controller:** `ProductController.showCreateForm()`

**Location:** `ProductController.java:222`

---

### 5. Create Product

**POST /products/create**

Create new product with multi-image upload.

**Authentication:** User (temporarily public)

**Request Body (Multipart Form Data):**
```java
{
  "productName": String,           // Required, max 200 chars
  "description": String,           // Optional
  "price": BigDecimal,             // Required, min 1000, validated ≤ max_listing_price
  "stockQuantity": Integer,        // Required, 0-999999
  "category": String,              // Required, ProductCategory enum
  "sku": String,                   // Optional, auto-generated if not provided
  "imageFiles": MultipartFile[]    // Optional, max 2MB per file, jpg/jpeg/png/gif
}
```

**Validation:**
- Product name: 1-200 characters
- Price: 1,000 - 999,999,999 VND
- Price must be ≤ store's max_listing_price
- Stock: 0 - 999,999 units
- SKU uniqueness (if provided)
- Image validation: type, size, count

**Success Response:** Redirect to `/products/my-products` with success message

**Error Response:** Return to form with validation errors

**Business Logic:**
1. Validate seller has a store
2. Validate store is operational
3. Validate price ≤ store.maxListingPrice
4. Generate SKU if not provided (PRD-XXXXXXXX)
5. Upload images via FileUploadService
6. Store image URLs as JSON array
7. Save product with is_active = true

**Controller:** `ProductController.createProduct()`

**Location:** `ProductController.java:257`

---

### 6. Edit Product Form

**GET /products/{productId}/edit**

Show edit product form.

**Authentication:** ROLE_SELLER

**Path Parameters:**
- `productId` (Long) - Product ID

**Response:** JSP view (`product/edit.jsp`)

**Model Attributes:**
```java
{
  "product": Product,
  "categories": ProductCategory[],
  "maxListingPrice": BigDecimal
}
```

**Error:** Access denied if product doesn't belong to seller

**Controller:** `ProductController.showEditForm()`

**Location:** `ProductController.java:311`

---

### 7. Update Product

**POST /products/{productId}/edit**

Update existing product.

**Authentication:** ROLE_SELLER

**Path Parameters:**
- `productId` (Long) - Product ID

**Request Body (Form Data):**
```java
{
  "productName": String,
  "description": String,
  "price": BigDecimal,
  "stockQuantity": Integer,
  "category": String,
  "sku": String
}
```

**Validation:** Same as create product

**Success Response:** Redirect to `/products/my-products` with success message

**Error Response:** Return to form with validation errors

**Business Logic:**
- Verify ownership (product belongs to seller's store)
- Validate price ≤ max_listing_price
- Validate SKU uniqueness (excluding current product)

**Controller:** `ProductController.updateProduct()`

**Location:** `ProductController.java:345`

---

### 8. Delete Product

**POST /products/{productId}/delete**

Soft delete product.

**Authentication:** ROLE_SELLER

**Path Parameters:**
- `productId` (Long) - Product ID

**Response:** Redirect to `/products/my-products` with success message

**Business Logic:**
- Verify ownership
- Set is_deleted = true
- Preserve product data for audit trail

**Controller:** `ProductController.deleteProduct()`

**Location:** `ProductController.java:385`

---

### 9. Toggle Product Status

**POST /products/{productId}/toggle-status**

Activate or deactivate product (toggle is_active).

**Authentication:** ROLE_SELLER

**Path Parameters:**
- `productId` (Long) - Product ID

**Response:** Redirect to `/products/my-products` with success message

**Business Logic:**
- Verify ownership
- Toggle is_active boolean
- Active products visible in public listings

**Controller:** `ProductController.toggleProductStatus()`

**Location:** `ProductController.java:409`

---

### 10. Upload Product Images

**POST /products/{productId}/upload-images**

Upload additional images for existing product.

**Authentication:** ROLE_SELLER

**Path Parameters:**
- `productId` (Long) - Product ID

**Request Body (Multipart Form Data):**
```java
{
  "imageFiles": MultipartFile[]  // Max 2MB per file
}
```

**Validation:**
- File type: jpg, jpeg, png, gif
- File size: ≤ 2MB per file
- Content-type validation

**Response:** Redirect with success/error message

**Business Logic:**
- Upload via FileUploadService
- Append URLs to existing productImages JSON array

**Controller:** `ProductController.uploadProductImages()`

**Location:** `ProductController.java:433`

---

### 11. Check SKU Availability (AJAX)

**GET /products/check-sku**

Check if SKU is available.

**Authentication:** No

**Query Parameters:**
- `sku` (String) - SKU to check
- `productId` (Long, optional) - Exclude from check (for edit)

**Response:** JSON
```json
{
  "available": true
}
```

**Controller:** `ProductController.checkSkuAvailability()`

**Location:** `ProductController.java:368`

---

### 12. Test Mode: Create Product Form ⚠️

**GET /products/create-test**

**⚠️ TEST MODE ONLY** - Product creation form with hardcoded store_id=2.

**Authentication:** No (bypasses authentication)

**Purpose:** Testing product creation without proper authentication

**Response:** JSP view (`product/create-test.jsp`)

**⚠️ WARNING:** Remove before production deployment

**Controller:** `ProductController.showCreateTestForm()`

**Location:** `ProductController.java:453`

---

### 13. Test Mode: Create Product ⚠️

**POST /products/create-test**

**⚠️ TEST MODE ONLY** - Process product creation with hardcoded store_id=2.

**Authentication:** No (bypasses seller verification)

**Request Body:** Same as regular create product

**Response:** Redirect to `/products` with success message

**⚠️ WARNING:** Remove before production deployment

**Business Logic:**
- Uses hardcoded store_id = 2
- Bypasses seller ownership verification
- For testing purposes only

**Controller:** `ProductController.createProductTest()`

**Location:** `ProductController.java:470`

---

### ProductCreateRequest DTO Schema

```java
{
  "productName": {
    "type": "String",
    "validation": "@NotBlank, @Size(min=1, max=200)",
    "required": true
  },
  "description": {
    "type": "String",
    "validation": "Optional",
    "required": false
  },
  "price": {
    "type": "BigDecimal",
    "validation": "@DecimalMin('1000'), @DecimalMax('999999999')",
    "required": true,
    "note": "Must be ≤ store.maxListingPrice (business rule)"
  },
  "stockQuantity": {
    "type": "Integer",
    "validation": "@Min(0), @Max(999999)",
    "required": true
  },
  "category": {
    "type": "ProductCategory",
    "validation": "@NotNull",
    "required": true,
    "enum": ["GAME_ACCOUNT", "GAME_CURRENCY", "SOCIAL_ACCOUNT", "SOFTWARE_LICENSE", "GIFT_CARD", "VPN_PROXY", "OTHER"]
  },
  "sku": {
    "type": "String",
    "validation": "@Size(max=50)",
    "required": false,
    "note": "Auto-generated as PRD-XXXXXXXX if not provided"
  }
}
```

---

### ProductResponse DTO Schema

```java
{
  "id": Long,
  "productName": String,
  "description": String,
  "price": BigDecimal,
  "formattedPrice": String,  // "1,000,000 VND"
  "stockQuantity": Integer,
  "category": ProductCategory,
  "categoryDisplay": String,  // Localized display name
  "sku": String,
  "productImages": String[],  // Array of image URLs
  "isActive": Boolean,
  "isAvailable": Boolean,     // Calculated: isActive && stockQuantity > 0
  "store": {
    "id": Long,
    "storeName": String,
    "storeLogoUrl": String,
    "isVerified": Boolean
  },
  "seller": {
    "id": Long,
    "username": String,
    "fullName": String
  },
  "createdAt": Timestamp,
  "updatedAt": Timestamp
}
```

---

## Admin Store Endpoints

### 1. Verify Store

**POST /admin/stores/{storeId}/verify**

Admin verifies a store (grant trust badge).

**Authentication:** ROLE_ADMIN

**Path Parameters:**
- `storeId` (Long) - Store ID

**Response:** Redirect to admin store management page

**Controller:** `AdminStoreController.verifyStore()` (assumed, not fully implemented)

---

### 2. Suspend Store

**POST /admin/stores/{storeId}/suspend**

Admin suspends a store.

**Authentication:** ROLE_ADMIN

**Path Parameters:**
- `storeId` (Long) - Store ID

**Request Body (Form Data):**
```java
{
  "reason": String  // Suspension reason
}
```

**Response:** Redirect to admin store management page

**Controller:** `AdminStoreController.suspendStore()` (assumed)

---

## Response Formats

### JSP View Response

Returns rendered HTML page.

**Example:**
```html
<!DOCTYPE html>
<html>
<head>
    <title>Dashboard - TaphoaMMO Marketplace</title>
</head>
<body>
    <!-- Page content -->
</body>
</html>
```

---

### JSON Response (AJAX Endpoints)

**Success Response:**
```json
{
  "success": true,
  "data": {
    "available": true
  },
  "message": "Operation successful"
}
```

**Error Response:**
```json
{
  "success": false,
  "error": "Validation failed",
  "message": "Username already exists"
}
```

---

### Redirect Response

**Success Redirect:**
```
HTTP/1.1 302 Found
Location: /stores/my-store?success=store_created
```

**Error Redirect:**
```
HTTP/1.1 302 Found
Location: /stores/create?error=insufficient_balance
```

**Flash Attributes:**
- `successMessage` - Success notification
- `errorMessage` - Error notification

---

## Error Handling

### Validation Errors

Returned to form with `BindingResult`.

**JSP Display:**
```jsp
<c:if test="${not empty errors}">
    <div class="alert alert-danger">
        <c:forEach items="${errors}" var="error">
            <p>${error.defaultMessage}</p>
        </c:forEach>
    </div>
</c:if>
```

---

### 404 Not Found

Redirects to listing page with error message.

**Example:**
```java
if (store == null) {
    redirectAttributes.addFlashAttribute("errorMessage", "Store not found");
    return "redirect:/stores";
}
```

---

### 403 Forbidden (Access Denied)

Spring Security returns 403 status or redirects to login.

**Future Enhancement:** Custom error page

---

### 500 Internal Server Error

Global exception handler (planned).

**Future Enhancement:**
```java
@ControllerAdvice
public class GlobalExceptionHandler {
    @ExceptionHandler(Exception.class)
    public String handleException(Exception e, Model model) {
        model.addAttribute("error", e.getMessage());
        return "error/500";
    }
}
```

---

## API Usage Examples

### Example 1: Register New User

```bash
curl -X POST http://localhost:8081/users/register \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=newuser" \
  -d "email=newuser@example.com" \
  -d "password=securepass123" \
  -d "confirmPassword=securepass123" \
  -d "fullName=New User"
```

---

### Example 2: Check Username Availability (AJAX)

```javascript
fetch('/users/check-username?username=johndoe')
  .then(response => response.json())
  .then(data => {
    if (data.available) {
      console.log('Username is available');
    } else {
      console.log('Username is taken');
    }
  });
```

---

### Example 3: Create Seller Store

```bash
curl -X POST http://localhost:8081/stores/create \
  -u admin:admin123 \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "storeName=My Gaming Store" \
  -d "storeDescription=Premium game accounts and items" \
  -d "depositAmount=10000000" \
  -d "contactEmail=contact@mystore.com"
```

---

### Example 4: List Stores with Filters

```bash
curl -X GET "http://localhost:8081/stores?page=0&size=20&search=gaming&status=ACTIVE&sort=createdAt&direction=desc"
```

---

## Future API Endpoints (Planned)

### Product Management
- `GET /products` - List products
- `GET /products/{id}` - View product details
- `POST /stores/my-store/products` - Create product
- `PUT /stores/my-store/products/{id}` - Update product
- `DELETE /stores/my-store/products/{id}` - Delete product

### Order Management
- `GET /orders` - List user's orders
- `POST /orders/create` - Create order (purchase)
- `GET /orders/{id}` - View order details
- `POST /orders/{id}/cancel` - Cancel order

### Wallet Operations
- `GET /wallet` - View wallet balance and transactions
- `POST /wallet/deposit` - Deposit funds
- `POST /wallet/withdraw` - Withdraw funds

### Reviews
- `POST /orders/{orderId}/review-product` - Review product
- `POST /orders/{orderId}/review-seller` - Review seller

### Messaging
- `GET /messages` - List conversations
- `GET /messages/{conversationId}` - View conversation
- `POST /messages/{conversationId}` - Send message

---

## API Security Best Practices

### CSRF Protection
Enable CSRF tokens for all state-changing operations:
```jsp
<input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
```

### Input Validation
- Server-side validation (Jakarta Bean Validation)
- Sanitize user input
- SQL injection prevention (JPA parameterized queries)
- XSS prevention (JSTL escaping)

### Rate Limiting (Planned)
Implement rate limiting for sensitive endpoints:
- Login: 5 attempts per 15 minutes
- Registration: 3 per hour per IP
- AJAX checks: 100 per minute

---

**Last Updated:** January 2025
**Document Version:** 1.0.0
