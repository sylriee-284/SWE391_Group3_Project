# System Architecture Documentation

## Table of Contents
1. [Architecture Overview](#architecture-overview)
2. [Architectural Style](#architectural-style)
3. [Layer Architecture](#layer-architecture)
4. [Design Patterns](#design-patterns)
5. [Component Diagram](#component-diagram)
6. [Data Flow](#data-flow)
7. [Security Architecture](#security-architecture)
8. [Technology Decisions](#technology-decisions)

---

## Architecture Overview

TaphoaMMO Marketplace follows a **Layered Architecture** pattern based on Spring Boot best practices. The system is designed as a monolithic application with clear separation of concerns across presentation, business logic, and data access layers.

### Architectural Goals
- **Maintainability:** Clear separation of concerns with well-defined layers
- **Scalability:** Stateless design for horizontal scaling
- **Security:** Role-based access control with granular permissions
- **Testability:** Dependency injection and interface-based design
- **Performance:** JPA optimization with lazy loading and batch fetching

---

## Architectural Style

### Monolithic Layered Architecture

```
┌─────────────────────────────────────────────────────┐
│              Presentation Layer (Web)               │
│  ┌──────────────┐  ┌──────────────┐  ┌───────────┐ │
│  │ Controllers  │  │  JSP Views   │  │   REST    │ │
│  │   (MVC)      │  │ (Bootstrap)  │  │   APIs    │ │
│  └──────────────┘  └──────────────┘  └───────────┘ │
└─────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────┐
│               Business Logic Layer                  │
│  ┌──────────────┐  ┌──────────────┐  ┌───────────┐ │
│  │   Services   │  │   DTOs       │  │  Mappers  │ │
│  │ (Interfaces) │  │  (Request/   │  │           │ │
│  │              │  │   Response)  │  │           │ │
│  └──────────────┘  └──────────────┘  └───────────┘ │
└─────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────┐
│              Data Access Layer (DAL)                │
│  ┌──────────────┐  ┌──────────────┐  ┌───────────┐ │
│  │ Repositories │  │   Entities   │  │    JPA    │ │
│  │ (Spring Data)│  │   (Domain)   │  │ Hibernate │ │
│  └──────────────┘  └──────────────┘  └───────────┘ │
└─────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────┐
│                  Database Layer                     │
│              MySQL 8.0 (mmo_market_system)          │
└─────────────────────────────────────────────────────┘
```

### Cross-Cutting Concerns

```
┌─────────────────────────────────────────────────────┐
│  Security (Spring Security)                         │
│  - Authentication & Authorization                   │
│  - RBAC with Granular Permissions                   │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│  Transaction Management (@Transactional)            │
│  - Service Layer Transaction Boundaries             │
│  - Optimistic Locking (JPA)                         │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│  Logging & Monitoring                               │
│  - SLF4J + Logback                                  │
│  - Spring Boot Actuator                             │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│  Validation                                          │
│  - Jakarta Bean Validation (JSR-380)                │
│  - Custom Business Validation                       │
└─────────────────────────────────────────────────────┘
```

---

## Layer Architecture

### 1. Presentation Layer

**Responsibility:** Handle HTTP requests, render views, return responses

**Components:**
- **Controllers** (`controller/web/`, `controller/admin/`)
  - `DashboardController` - Main dashboard
  - `UserController` - User management
  - `SellerStoreController` - Store operations
  - `AdminStoreController` - Admin store management

- **Views** (`webapp/WEB-INF/view/`)
  - JSP templates with JSTL
  - Bootstrap 5.3.2 for responsive design
  - jQuery for AJAX interactions

**Technologies:**
- Spring MVC
- Jakarta Servlet JSP
- JSTL 3.0
- Bootstrap 5.3.2

**Key Patterns:**
- MVC (Model-View-Controller)
- Front Controller (DispatcherServlet)
- Data Transfer Object (DTOs)

### 2. Business Logic Layer

**Responsibility:** Implement business rules, coordinate transactions, transform data

**Components:**
- **Service Interfaces** (`service/interfaces/`)
  - `UserService` - User business logic
  - `SellerStoreService` - Store operations
  - `WalletService` - Financial transactions
  - `FileUploadService` - File management

- **Service Implementations** (`service/impl/`)
  - Transaction boundaries defined here
  - Business validation
  - Complex business workflows

- **DTOs** (`dto/`)
  - **Request DTOs:** Validate and bind user input
  - **Response DTOs:** Control API responses
  - Separation from domain entities

**Technologies:**
- Spring Framework
- Jakarta Validation API
- Lombok (@Builder, @Data, etc.)

**Key Patterns:**
- Service Layer Pattern
- DTO Pattern
- Builder Pattern

### 3. Data Access Layer

**Responsibility:** Persist and retrieve data, encapsulate data access logic

**Components:**
- **Repositories** (`repository/`)
  - Extend `JpaRepository<T, ID>`
  - Custom query methods via method naming
  - Example: `UserRepository`, `SellerStoreRepository`, `WalletRepository`

- **Entities** (`domain/entity/`)
  - JPA entities with Hibernate annotations
  - Relationships: `@OneToOne`, `@OneToMany`, `@ManyToMany`
  - Auditing fields via `BaseEntity`

- **Enums & Constants** (`domain/enums/`, `domain/constants/`)
  - `UserStatus`, `Gender`, `TransactionType`
  - `StoreStatus` constants

**Technologies:**
- Spring Data JPA
- Hibernate ORM
- MySQL Connector

**Key Patterns:**
- Repository Pattern
- Active Record (via JPA)
- Template Method (BaseEntity)

### 4. Database Layer

**Responsibility:** Data storage, integrity constraints, indexing

**Schema:**
- 17 tables with foreign key constraints
- Audit fields on all tables
- Soft delete support (is_deleted flag)
- Generated columns for calculated values

**Technologies:**
- MySQL 8.0
- InnoDB storage engine

---

## Design Patterns

### 1. Repository Pattern

**Implementation:** Spring Data JPA repositories

```java
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByUsername(String username);
    Optional<User> findByEmail(String email);
    Page<User> findByIsDeletedFalse(Pageable pageable);
}
```

**Benefits:**
- Abstraction over data access
- Reduces boilerplate code
- Testable with mocks

### 2. Service Layer Pattern

**Implementation:** Interface + Implementation separation

```java
// Interface
public interface SellerStoreService {
    SellerStore createStore(Long userId, SellerStoreCreateRequest request);
    Optional<SellerStore> getStoreById(Long storeId);
}

// Implementation
@Service
@RequiredArgsConstructor
@Transactional
public class SellerStoreServiceImpl implements SellerStoreService {
    private final SellerStoreRepository storeRepository;
    private final WalletService walletService;

    @Override
    public SellerStore createStore(Long userId, SellerStoreCreateRequest request) {
        // Business logic here
    }
}
```

**Benefits:**
- Clear transaction boundaries
- Business logic encapsulation
- Easy to test with mocking

### 3. Data Transfer Object (DTO) Pattern

**Implementation:** Separate request/response objects

```java
// Request DTO
@Data
@Builder
public class SellerStoreCreateRequest {
    @NotBlank(message = "Store name is required")
    private String storeName;

    @Min(value = 5000000, message = "Minimum deposit is 5,000,000 VND")
    private BigDecimal depositAmount;
}

// Response DTO
@Data
@Builder
public class SellerStoreResponse {
    private Long id;
    private String storeName;
    private String formattedDeposit;
    private Boolean isVerified;
}
```

**Benefits:**
- API contract stability
- Input validation
- Prevent over-posting attacks

### 4. Builder Pattern

**Implementation:** Lombok @Builder annotation

```java
@Entity
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SellerStore extends BaseEntity {
    private String storeName;
    private BigDecimal depositAmount;
    // ... other fields
}

// Usage
SellerStore store = SellerStore.builder()
    .storeName("My Store")
    .depositAmount(new BigDecimal("10000000"))
    .build();
```

**Benefits:**
- Readable object construction
- Immutable object support
- Fluent API

### 5. Template Method Pattern

**Implementation:** BaseEntity abstract class

```java
@MappedSuperclass
@Data
public abstract class BaseEntity {
    @Column(name = "created_at")
    private Timestamp createdAt;

    @Column(name = "created_by")
    private Long createdBy;

    @Column(name = "updated_at")
    private Timestamp updatedAt;

    @Column(name = "deleted_by")
    private Long deletedBy;

    @Column(name = "is_deleted")
    private Boolean isDeleted = false;
}
```

**Benefits:**
- Consistent audit fields
- DRY principle
- Automatic soft delete support

### 6. Strategy Pattern (Implicit)

**Implementation:** Permission-based authorization

```java
public class User implements UserDetails {
    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return roles.stream()
            .flatMap(role -> role.getPermissions().stream())
            .map(permission -> new SimpleGrantedAuthority(permission.getCode()))
            .collect(Collectors.toSet());
    }
}
```

**Benefits:**
- Flexible permission system
- Runtime role changes
- Fine-grained access control

### 7. Dependency Injection

**Implementation:** Constructor injection via Lombok

```java
@Service
@RequiredArgsConstructor
public class SellerStoreServiceImpl implements SellerStoreService {
    private final SellerStoreRepository storeRepository;
    private final WalletService walletService;
    private final UserService userService;
    // Dependencies injected automatically
}
```

**Benefits:**
- Loose coupling
- Testability
- Inversion of control

---

## Component Diagram

### Domain Model Relationships

```
┌──────────────┐         ┌──────────────┐         ┌──────────────┐
│     User     │────────>│     Role     │────────>│  Permission  │
│              │  M:M    │              │  M:M    │              │
│ - id         │         │ - id         │         │ - id         │
│ - username   │         │ - code       │         │ - code       │
│ - email      │         │ - name       │         │ - name       │
└──────┬───────┘         └──────────────┘         └──────────────┘
       │ 1:1
       │
       ▼
┌──────────────┐
│    Wallet    │         ┌──────────────────────┐
│              │───────> │ WalletTransaction    │
│ - id         │  1:M    │                      │
│ - user_id    │         │ - id                 │
│ - balance    │         │ - wallet_id          │
└──────────────┘         │ - type               │
                         │ - amount             │
                         └──────────────────────┘

┌──────────────┐
│     User     │
└──────┬───────┘
       │ 1:1 (owner)
       │
       ▼
┌──────────────┐         ┌──────────────┐
│ SellerStore  │────────>│   Product    │
│              │  1:M    │              │
│ - id         │         │ - id         │
│ - owner_id   │         │ - store_id   │
│ - storeName  │         │ - category   │
│ - deposit    │         │ - price      │
└──────────────┘         └──────┬───────┘
                                │ 1:M
                                ▼
                         ┌──────────────┐
                         │ProductStorage│
                         │              │
                         │ - id         │
                         │ - product_id │
                         │ - status     │
                         │ - payload    │
                         └──────────────┘
```

### Service Dependencies

```
┌────────────────────────────────────────────┐
│         SellerStoreController              │
└──────────────┬─────────────────────────────┘
               │ depends on
               ▼
┌────────────────────────────────────────────┐
│       SellerStoreServiceImpl               │
│  ┌──────────────────────────────────────┐  │
│  │ - storeRepository                    │  │
│  │ - walletService ────────┐            │  │
│  │ - userService           │            │  │
│  │ - fileUploadService     │            │  │
│  └──────────────────────────┼───────────┘  │
└───────────────────────────────┼────────────┘
                                │
                ┌───────────────┴───────────────┐
                ▼                               ▼
   ┌────────────────────┐          ┌────────────────────┐
   │  WalletServiceImpl │          │  UserServiceImpl   │
   │                    │          │                    │
   │ - walletRepo       │          │ - userRepo         │
   │                    │          │ - roleRepo         │
   └────────────────────┘          └────────────────────┘
```

---

## Data Flow

### 1. User Registration Flow

```
[Browser]
    │
    │ 1. GET /users/register
    ▼
[UserController]
    │
    │ 2. Return registration form
    ▼
[register.jsp]
    │
    │ 3. User fills form + submits
    │ 4. POST /users/register
    ▼
[UserController.registerUser()]
    │
    │ 5. Validate input (@Valid)
    ▼
[UserService.registerUser()]
    │
    │ 6. Check username/email uniqueness
    │ 7. Encode password (BCrypt)
    │ 8. Save user
    ▼
[UserRepository.save()]
    │
    │ 9. Persist to database
    ▼
[MySQL - users table]
    │
    │ 10. Return saved entity
    ▼
[UserService]
    │
    │ 11. Create wallet (should be explicit)
    │ 12. Return user
    ▼
[UserController]
    │
    │ 13. Redirect to login with success message
    ▼
[Browser - Login Page]
```

### 2. Store Creation Flow (Intended)

```
[Seller's Browser]
    │
    │ 1. GET /stores/create
    ▼
[SellerStoreController]
    │
    │ 2. Check if user already has store
    ▼
[SellerStoreService.getStoreByOwnerId()]
    │
    │ 3. If exists → redirect with error
    │ 4. If not → show form
    ▼
[create.jsp]
    │
    │ 5. Seller fills form (name, deposit amount)
    │ 6. POST /stores/create
    ▼
[SellerStoreController.createStore()]
    │
    │ 7. Validate input
    │ 8. Check store name uniqueness
    ▼
[SellerStoreService.createStore()]
    │
    ├─> 9. Validate deposit amount >= 5M VND
    │
    ├─> 10. Check wallet has sufficient funds
    │   [WalletService.hasSufficientFunds()]
    │
    ├─> 11. Build SellerStore entity
    │   - maxListingPrice = depositAmount / 10
    │
    ├─> 12. Save store
    │   [SellerStoreRepository.save()]
    │
    ├─> 13. Deduct deposit from wallet
    │   [WalletService.processStoreDeposit()]
    │
    └─> 14. Assign SELLER role
        [UserService.assignRole(userId, "ROLE_SELLER")]
    │
    │ 15. Return created store
    ▼
[SellerStoreController]
    │
    │ 16. Redirect to /stores/my-store
    ▼
[Store Dashboard]
```

### 3. Product Purchase Flow (Planned)

```
[Buyer Browser]
    │
    │ 1. Browse products
    │ 2. Add to cart (or direct purchase)
    │ 3. POST /orders/create
    ▼
[OrderController.createOrder()]
    │
    ├─> Validate product availability
    ├─> Check buyer wallet balance
    ├─> Reserve product from ProductStorage
    │
    ├─> Create Order entity
    ├─> Create EscrowTransaction (hold for 3 days)
    ├─> Deduct funds from buyer's wallet
    │
    └─> Send notification to seller
    │
    │ Order created (status: PENDING)
    ▼
[Seller]
    │
    │ Deliver digital goods (update ProductStorage.status)
    ▼
[OrderService.markAsDelivered()]
    │
    │ Order status: DELIVERED
    │ Wait for escrow hold period (3 days)
    ▼
[Scheduled Task - Daily]
    │
    │ Check escrow_transactions.hold_until
    ▼
[EscrowService.releaseExpiredEscrows()]
    │
    ├─> Transfer funds to seller's wallet
    ├─> Update order status: COMPLETED
    └─> Enable review functionality
    │
    ▼
[Buyer & Seller can leave reviews]
```

---

## Security Architecture

### Authentication Flow

```
[User Login Request]
    │
    │ POST /login (username, password)
    ▼
[Spring Security Filter Chain]
    │
    ├─> 1. UsernamePasswordAuthenticationFilter
    │
    ├─> 2. AuthenticationManager
    │   │
    │   ├─> DaoAuthenticationProvider
    │   │   │
    │   │   ├─> UserDetailsService (custom implementation)
    │   │   │   │
    │   │   │   └─> Load User from database
    │   │   │       [UserRepository.findByUsername()]
    │   │   │
    │   │   └─> PasswordEncoder.matches(rawPassword, encodedPassword)
    │   │
    │   └─> Return Authentication object
    │
    ├─> 3. SecurityContextHolder.setAuthentication()
    │
    └─> 4. Create Session
    │
    ▼
[Authenticated User Session]
```

### Authorization Flow

```
[HTTP Request to Protected Endpoint]
    │
    │ GET /stores/my-store
    ▼
[Spring Security Filter Chain]
    │
    ├─> 1. Check if user is authenticated
    │   │
    │   └─> If not → Redirect to login
    │
    ├─> 2. Load Authentication from session
    │
    ├─> 3. Check @PreAuthorize("hasRole('SELLER')")
    │   │
    │   ├─> Get user's authorities
    │   │   [User.getAuthorities()]
    │   │   │
    │   │   └─> roles → permissions → SimpleGrantedAuthority
    │   │
    │   └─> Check if "ROLE_SELLER" in authorities
    │
    ├─> 4. If authorized → Proceed to controller
    │
    └─> 5. If not → AccessDeniedException (403 Forbidden)
    │
    ▼
[Controller Method Execution]
```

### RBAC Model

```
┌─────────────────────────────────────────────────────┐
│                      User                           │
│  - id: 2                                            │
│  - username: "seller01"                             │
└──────────────┬──────────────────────────────────────┘
               │ user_roles (Many-to-Many)
               ▼
┌─────────────────────────────────────────────────────┐
│                     Roles                           │
│  - ROLE_USER                                        │
│  - ROLE_SELLER                                      │
└──────────────┬──────────────────────────────────────┘
               │ role_permissions (Many-to-Many)
               ▼
┌─────────────────────────────────────────────────────┐
│                  Permissions                        │
│  From ROLE_USER:                                    │
│    - USER_VIEW, PRODUCT_VIEW, ORDER_VIEW            │
│  From ROLE_SELLER:                                  │
│    - STORE_CREATE, STORE_UPDATE, PRODUCT_CREATE,    │
│      PRODUCT_UPDATE, ORDER_VIEW, WALLET_VIEW        │
└─────────────────────────────────────────────────────┘
               │
               │ User.getAuthorities()
               ▼
┌─────────────────────────────────────────────────────┐
│         Spring Security Authorities                 │
│  [USER_VIEW, PRODUCT_VIEW, ORDER_VIEW,              │
│   STORE_CREATE, STORE_UPDATE, PRODUCT_CREATE, ...]  │
└─────────────────────────────────────────────────────┘
```

---

## Technology Decisions

### Why Spring Boot 3.5.5?

**Reasons:**
- Latest stable release with modern Jakarta EE support
- Built-in security, data access, web frameworks
- Extensive ecosystem and community
- Production-ready features (Actuator, DevTools)
- Auto-configuration reduces boilerplate

**Trade-offs:**
- ✅ Rapid development
- ✅ Convention over configuration
- ❌ Larger application size vs. microframeworks
- ❌ Learning curve for beginners

### Why MySQL over PostgreSQL?

**Reasons:**
- Team familiarity
- Excellent read performance
- Wide hosting support
- InnoDB storage engine with ACID compliance

**Trade-offs:**
- ✅ Easy setup and deployment
- ✅ Good for e-commerce workloads
- ❌ Less advanced features than PostgreSQL (no JSONB indexing)
- ❌ Weaker support for complex queries

### Why JSP over Thymeleaf/React?

**Reasons:**
- Course requirement (Jakarta EE stack)
- Mature technology with extensive documentation
- Server-side rendering (SEO-friendly)
- JSTL for logic-less templates

**Trade-offs:**
- ✅ Simple to learn
- ✅ No build process required
- ❌ Less modern than SPA frameworks
- ❌ Harder to create dynamic UIs

### Why Monolith over Microservices?

**Reasons:**
- Project scope (MVP phase)
- Team size (small group)
- Deployment simplicity
- No need for distributed system complexity

**Future Migration Path:**
- Extract payment gateway as service
- Extract notification service
- Extract search service (Elasticsearch)

---

## Code Organization Principles

### 1. Separation of Concerns
- Each layer has distinct responsibility
- No business logic in controllers
- No SQL in services (use repositories)

### 2. Dependency Inversion
- Depend on interfaces, not implementations
- Services reference service interfaces
- Easy to swap implementations

### 3. Single Responsibility
- Each class has one reason to change
- `UserService` handles user operations only
- `WalletService` handles wallet operations only

### 4. Open/Closed Principle
- Open for extension (inheritance, interfaces)
- Closed for modification (stable APIs)

### 5. DRY (Don't Repeat Yourself)
- `BaseEntity` for common fields
- Utility classes for common operations
- Service layer for reusable business logic

---

## Performance Considerations

### 1. Database Optimization
- **Indexes:** Foreign keys, unique constraints
- **Lazy Loading:** Avoid N+1 queries
- **Batch Fetching:** `hibernate.default_batch_fetch_size=16`
- **Connection Pooling:** HikariCP (default in Spring Boot)

### 2. Caching Strategy (Planned)
- **Spring Cache:** Method-level caching
- **Redis:** Session storage and distributed cache
- **Static Content:** CDN for images, CSS, JS

### 3. Transaction Management
- **@Transactional:** Service layer boundaries
- **Read-Only Transactions:** Optimize read operations
- **Isolation Levels:** Default READ_COMMITTED

---

## Scalability Considerations

### Current Architecture (Monolith)
- **Vertical Scaling:** Increase server resources
- **Stateless Design:** Session stored externally (future: Redis)
- **Load Balancing Ready:** No server-side state in controllers

### Future Microservices Candidates
1. **Payment Service:** Handle transactions, gateway integrations
2. **Notification Service:** Email, SMS, push notifications
3. **Search Service:** Elasticsearch for advanced product search
4. **File Storage Service:** S3-compatible object storage

---

## Testing Strategy

### Unit Tests
- **Service Layer:** Business logic validation
- **Repository Layer:** Custom queries
- **Utilities:** Helper methods

### Integration Tests
- **Controller Layer:** Full request/response cycle
- **Database Layer:** Repository with test database

### End-to-End Tests
- **User Flows:** Registration → Login → Create Store → List Product → Purchase

**Current Status:** Not yet implemented (0% coverage)

---

## Monitoring & Observability

### Spring Boot Actuator Endpoints
- `/actuator/health` - Application health
- `/actuator/metrics` - JVM and application metrics
- `/actuator/info` - Application information

### Logging Strategy
- **Framework:** SLF4J + Logback
- **Levels:** INFO (production), DEBUG (development)
- **Format:** Structured logging for parsing

### Future Enhancements
- **APM:** Application Performance Monitoring (e.g., New Relic, Datadog)
- **Distributed Tracing:** Spring Cloud Sleuth + Zipkin
- **Error Tracking:** Sentry or Rollbar

---

## Conclusion

The TaphoaMMO Marketplace architecture is designed for maintainability, security, and future growth. The layered approach provides clear separation of concerns, while Spring Boot's conventions reduce boilerplate code. The current monolithic architecture is appropriate for the MVP phase, with clear paths for future microservices extraction as the system scales.

**Key Strengths:**
- Clear layer separation
- Strong domain model
- RBAC security foundation
- Testable design

**Future Improvements:**
- Complete Spring Security configuration
- Implement comprehensive testing
- Add caching layer
- Implement API documentation (Swagger)
- Consider microservices for specific bounded contexts

---

**Last Updated:** January 2025
**Document Version:** 1.0.0
