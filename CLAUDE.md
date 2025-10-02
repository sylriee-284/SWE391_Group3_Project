# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## Project Overview

**TaphoaMMO Marketplace** - A Spring Boot 3.5.5 e-commerce platform for trading digital goods (game accounts, subscriptions, etc.) with an escrow-based payment system.

- **Language:** Java 17
- **Framework:** Spring Boot 3.5.5 (MVC + JPA + Security)
- **View Technology:** JSP with JSTL (Jakarta)
- **Database:** MySQL 8.0+ (InnoDB)
- **Build Tool:** Maven (wrapper included)
- **Frontend:** Bootstrap 5.3.2, jQuery 3.7.1

---

## Essential Commands

### Build & Run
```bash
# Build project
./mvnw clean install

# Run application (dev mode with hot reload)
./mvnw spring-boot:run

# Run with specific profile
./mvnw spring-boot:run -Dspring-boot.run.profiles=prod

# Build without tests
./mvnw clean package -DskipTests

# Run JAR directly
java -jar target/marketplace-0.0.1-SNAPSHOT.jar
```

### Database Setup
```bash
# Create and populate database (first time)
mysql -u root -p mmo_market_system < marketplace.sql
mysql -u root -p mmo_market_system < marketplace-sample-data.sql

# Database backup
mysqldump -u root -p mmo_market_system > backup.sql
```

### Testing (when implemented)
```bash
# Run all tests
./mvnw test

# Run specific test class
./mvnw test -Dtest=UserServiceTest

# Run with coverage
./mvnw clean test jacoco:report
```

---

## Architecture Overview

### Layered Architecture Pattern

```
Controllers (Web/Admin) → Services (Interface + Impl) → Repositories (Spring Data JPA) → Database
         ↓                          ↓
    JSP Views                   DTOs (Request/Response)
```

**Key Principle:** Clear separation - no business logic in controllers, no SQL in services.

### Core Domain Model

**Central Entities:**
- **User** → 1:1 Wallet, 1:1 SellerStore (as owner), M:M Roles
- **SellerStore** → 1:M Products, financial deposit system
- **Wallet** → 1:M WalletTransactions, balance in VND
- **Role** → M:M Permissions (RBAC with 27 granular permissions)

**Critical Business Rule:** `max_listing_price = deposit_amount / 10` (MySQL generated column)

### Package Structure

```
vn.group3.marketplace/
├── config/          - Spring configuration (Security, JPA, MVC)
├── controller/
│   ├── web/        - Public MVC controllers (return JSP views)
│   └── admin/      - Admin controllers
├── domain/
│   ├── entity/     - JPA entities (extend BaseEntity for audit fields)
│   ├── enums/      - Enums (UserStatus, Gender, TransactionType)
│   └── constants/  - Constants (StoreStatus)
├── dto/
│   ├── request/    - Form binding DTOs (with @Valid annotations)
│   └── response/   - API response DTOs
├── repository/     - Spring Data JPA repositories
├── service/
│   ├── interfaces/ - Service contracts
│   └── impl/       - Service implementations (@Transactional)
└── util/           - Utility classes
```

---

## Critical Implementation Details

### 1. Security Configuration Status ⚠️

**Current State:** Spring Security is **DISABLED** in `MarketplaceApplication.java`:
```java
@SpringBootApplication(exclude = {
    SecurityAutoConfiguration.class,
    ManagementWebSecurityAutoConfiguration.class
})
```

**Temporary Auth:** Basic HTTP auth via `application.properties`:
```properties
spring.security.user.name=admin
spring.security.user.password=admin123
```

**Action Required:** When implementing security:
- Remove exclusions from `@SpringBootApplication`
- Create `SecurityConfig` with `SecurityFilterChain`
- Implement `UserDetailsService` (User entity already implements `UserDetails`)
- Enable CSRF protection for production

### 2. Temporarily Disabled Features

**Store Creation Flow (SellerStoreServiceImpl.java):**

```java
// Lines 54-57: Deposit validation DISABLED
// UNCOMMENT for production:
if (depositAmount.compareTo(minimumDeposit) < 0) {
    throw new IllegalArgumentException("Minimum deposit required");
}

// Lines 82-88: Wallet deduction DISABLED
// UNCOMMENT for production:
walletService.processStoreDeposit(userId, depositAmount, savedStore.getId());

// Lines 90-95: SELLER role assignment DISABLED
// UNCOMMENT for production:
userService.assignRole(userId, "ROLE_SELLER");
```

**Reason:** Testing without wallet integration. **Must re-enable before production.**

**Workaround in SellerStoreController (line 112, 146):**
```java
Long userId = (currentUser != null && currentUser.getId() != null)
    ? currentUser.getId() : 2L;  // Fallback to user ID 2 for testing
```

### 3. Transaction Management Pattern

**Service Layer:**
- Class-level: `@Transactional` (read-write)
- Method-level: `@Transactional(readOnly = true)` for queries

**Critical:** All store creation logic must be in **single transaction**:
1. Check wallet balance
2. Create SellerStore
3. Deduct deposit from wallet
4. Create WalletTransaction
5. Assign ROLE_SELLER

### 4. Soft Delete Pattern

**All entities** inherit from `BaseEntity`:
```java
private Boolean isDeleted = false;
private Long deletedBy;
```

**Never use** `repository.delete()`. Instead:
```java
entity.setIsDeleted(true);
entity.setDeletedBy(currentUserId);
repository.save(entity);
```

**Queries:** Always filter `isDeleted = false` (add to repository methods if needed).

---

## Database Schema Essentials

### Generated Columns (MySQL)

**SellerStore:**
```sql
max_listing_price = ROUND(deposit_amount / 10, 2) STORED
```

**EscrowTransaction:**
```sql
hold_until = DATE_ADD(created_at, INTERVAL 3 DAY) STORED
```

**Action:** Don't set these in Java - they auto-calculate in MySQL.

### Critical Constraints

- **Unique:** `wallets.user_id`, `seller_stores.owner_user_id`, `seller_stores.store_name`
- **Check:** `wallets.balance >= 0`
- **Foreign Keys:** Cascade on `user_roles`, `role_permissions`; RESTRICT on orders

### Sample Data

- 15 users (IDs 1-15): admin, 5 sellers, 6 buyers, 1 moderator, 2 test users
- All passwords: `password123` (BCrypt hash)
- 5 roles, 27 permissions, 10 categories

---

## JSP View Development

### Location
`src/main/webapp/WEB-INF/view/`

### Key Points

**JSTL Tags (avoid scriptlets):**
```jsp
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:if test="${not empty successMessage}">
    <div class="alert alert-success">${successMessage}</div>
</c:if>
```

**CSRF Token (required for forms):**
```jsp
<form method="post">
    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
    <!-- form fields -->
</form>
```

**Bootstrap Classes:** Already included via CDN (5.3.2)

---

## Configuration Management

### Application Properties

**Dev:** `src/main/resources/application.properties`
```properties
server.port=8081
spring.datasource.url=jdbc:mysql://localhost:3306/mmo_market_system
spring.jpa.hibernate.ddl-auto=update  # DEV ONLY
```

**Prod:** Use `application-prod.properties` with:
```properties
spring.jpa.hibernate.ddl-auto=validate  # NEVER update in prod
spring.jpa.show-sql=false
```

### Business Configuration (MarketplaceProperties)

```properties
marketplace.seller.minimum-deposit=5000000
marketplace.escrow.hold-days=3
marketplace.wallet.currency=VND
```

---

## Common Patterns

### Creating a New Feature Module

**Example: Product Management**

1. **Entity:** `domain/entity/Product.java` (extends BaseEntity)
2. **Repository:** `repository/ProductRepository.java extends JpaRepository<Product, Long>`
3. **DTOs:** `dto/request/ProductCreateRequest.java`, `dto/response/ProductResponse.java`
4. **Service Interface:** `service/interfaces/ProductService.java`
5. **Service Impl:** `service/impl/ProductServiceImpl.java` with `@Service`, `@Transactional`
6. **Controller:** `controller/web/ProductController.java` with `@Controller`, `@RequestMapping`
7. **Views:** `webapp/WEB-INF/view/product/*.jsp`

### Lombok Usage

**Entities:**
```java
@Entity
@Data                    // getters, setters, toString, equals, hashCode
@Builder                 // builder pattern
@NoArgsConstructor       // JPA requires
@AllArgsConstructor      // for builder
```

**Services:**
```java
@Service
@RequiredArgsConstructor // constructor injection for final fields
@Transactional
@Slf4j                   // logger
```

---

## Known Issues & Workarounds

### Issue 1: File Upload Not Implemented
**Location:** `FileUploadServiceImpl` (all methods throw `UnsupportedOperationException`)

**Workaround:** None. Implement when needed:
- Use `MultipartFile` parameter in controller
- Validate file type and size
- Store in `/opt/marketplace/uploads` or cloud storage (S3)

### Issue 2: Security @PreAuthorize Ignored
**Cause:** Security auto-configuration excluded

**Workaround:** Controllers check manually or use fake user ID 2

**Fix:** Re-enable Spring Security, create SecurityConfig

### Issue 3: Navbar Overlapping Content
**Status:** Fixed in commit `a5cf6ea`

**Change:** Navbar positioning from `position: fixed` to `position: sticky`

---

## Git Workflow

### Branches
- `main` - Production-ready
- `dev_raw` - Active development (current)
- `feature/*` - Feature branches

### Commit Convention
```
<type>(<scope>): <subject>

feat(store): add product listing validation
fix(wallet): prevent negative balance
docs(readme): update deployment instructions
```

---

## Testing Strategy (When Implementing)

### Unit Tests
- **Service Layer:** Mock repositories with Mockito
- **Business Logic:** Validate rules (deposit requirements, price limits)

### Integration Tests
- **Repository Layer:** Use `@DataJpaTest` with test database
- **Controller Layer:** Use `@WebMvcTest` with MockMvc

### Coverage Goal
- Service layer: > 80%
- Overall: > 70%

---

## Production Deployment Notes

### Pre-Production Checklist
1. ✅ Re-enable deposit validation (SellerStoreServiceImpl:54-57)
2. ✅ Re-enable wallet deduction (SellerStoreServiceImpl:82-88)
3. ✅ Re-enable SELLER role assignment (SellerStoreServiceImpl:90-95)
4. ✅ Remove fake user ID fallback (SellerStoreController:112, 146)
5. ✅ Enable Spring Security (remove exclusions)
6. ✅ Set `spring.jpa.hibernate.ddl-auto=validate`
7. ✅ Change default admin password
8. ✅ Enable HTTPS and CSRF protection

### Database Migration
**Dev:** Auto-update via Hibernate
**Prod:** Manual SQL scripts (see `docs/DEPLOYMENT.md`)

---

## Key Files to Reference

- **Architecture:** `docs/ARCHITECTURE.md` - Design patterns, data flows
- **Database:** `docs/DATABASE.md` - Complete schema reference
- **API:** `docs/API.md` - All endpoints with examples
- **Business Rules:** `docs/BUSINESS_RULES.md` - Domain logic reference
- **Development:** `docs/DEVELOPMENT.md` - Setup and coding standards
- **Deployment:** `docs/DEPLOYMENT.md` - Production deployment guide

---

## Project Status (~40% Complete)

### Implemented ✅
- User CRUD, authentication foundation
- Seller store management (with temporary workarounds)
- Wallet basic operations
- RBAC infrastructure (5 roles, 27 permissions)
- JSP view templates with Bootstrap

### In Progress ⚙️
- Spring Security configuration
- Transaction integrity (wallet ↔ store deposit)
- File upload service

### Not Started ❌
- Product CRUD
- Order processing with escrow
- Payment gateway integration
- Review & rating system
- Messaging system
- Admin analytics

---

## Important Context for AI Assistants

When working on this codebase:

1. **Always check** if Spring Security is enabled before adding `@PreAuthorize` annotations
2. **Transaction boundaries** are critical - wallet operations must be atomic
3. **Generated columns** (max_listing_price, hold_until) are set by MySQL, not Java
4. **Soft delete** - never hard delete entities
5. **DTOs** - always use for API requests/responses, never expose entities directly
6. **JSP** - this is a JSP project, not Thymeleaf or React
7. **Business rules** - deposit requirement is 5M VND, max price is deposit/10
8. **Current workarounds** are documented - ask before removing them


## Testing Approach

When implementation begins:
- Unit tests for all core services
- Integration tests for API endpoints
- always using `playwright mcp server ` to test again

## Development Rules

### General
- Update existing docs (Markdown files) in `./docs` directory before any code refactoring
- Add new docs (Markdown files) to `./docs` directory after new feature implementation (do not create duplicated docs)
- use `context7` mcp tools for docs of plugins/packages
- because i using mysql from docker, so use command correctly to run mcp server for mysql
- whenever you want to see the whole code base, use this command: `repomix` and read the output summary file.


### Code Quality Guidelines
- Don't be too harsh on code linting and formatting
- Prioritize functionality and readability over strict style enforcement
- Use reasonable code quality standards that enhance developer productivity
- Allow for minor style variations when they improve code clarity

### Pre-commit/Push Rules
- Keep commits focused on the actual code changes
- **DO NOT** commit and push any confidential information (such as dotenv files, API keys, database credentials, etc.) to git repository!
- NEVER automatically add AI attribution signatures like:
  "🤖 Generated with [Claude Code]"
  "Co-Authored-By: Claude noreply@anthropic.com"
  Any AI tool attribution or signature
- Create clean, professional commit messages without AI references. Use conventional commit format.

---

**Last Updated:** January 2025
