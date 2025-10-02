# Development Guide

## Table of Contents
1. [Development Environment Setup](#development-environment-setup)
2. [Project Structure](#project-structure)
3. [Development Workflow](#development-workflow)
4. [Coding Standards](#coding-standards)
5. [Testing Guidelines](#testing-guidelines)
6. [Debugging](#debugging)
7. [Product Module Development Guide](#product-module-development-guide)
8. [Common Tasks](#common-tasks)
9. [Troubleshooting](#troubleshooting)

---

## Development Environment Setup

### Prerequisites

**Required Software:**
- **JDK 17** or higher ([Download](https://www.oracle.com/java/technologies/downloads/#java17))
- **MySQL 8.0+** ([Download](https://dev.mysql.com/downloads/mysql/))
- **Maven 3.6+** (or use included wrapper)
- **Git** ([Download](https://git-scm.com/downloads))

**Recommended IDE:**
- **IntelliJ IDEA** (Ultimate or Community Edition)
- **Eclipse** with Spring Tools 4
- **VS Code** with Java Extension Pack

**Optional Tools:**
- **MySQL Workbench** - Database management
- **Postman** - API testing
- **Docker** - Container deployment (future)

---

### Initial Setup

#### 1. Clone Repository

```bash
git clone <repository-url>
cd SWE391_Group3_Project
```

#### 2. Database Setup

**Create Database:**
```bash
mysql -u root -p
```

```sql
CREATE DATABASE mmo_market_system CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
EXIT;
```

**Import Schema and Sample Data:**
```bash
mysql -u root -p mmo_market_system < marketplace.sql
mysql -u root -p mmo_market_system < marketplace-sample-data.sql
```

**Verify Setup:**
```sql
USE mmo_market_system;
SHOW TABLES;  -- Should show 18 tables
SELECT COUNT(*) FROM users;  -- Should return 15
SELECT COUNT(*) FROM products;  -- Should return 0 (or load sample products)
```

**Optional - Load Sample Products:**
```bash
mysql -u root -p mmo_market_system < insert-products-simple.sql
```

#### 3. Configure Application

**Edit** `src/main/resources/application.properties`:

```properties
# Database Configuration (Update credentials)
spring.datasource.url=jdbc:mysql://localhost:3306/mmo_market_system
spring.datasource.username=root
spring.datasource.password=YOUR_MYSQL_PASSWORD

# Server Port (change if 8081 is in use)
server.port=8081

# Hibernate DDL (use 'update' for development)
spring.jpa.hibernate.ddl-auto=update

# Show SQL (enable for debugging)
spring.jpa.show-sql=true

# File Upload Configuration
spring.servlet.multipart.max-file-size=10MB
spring.servlet.multipart.max-request-size=10MB
file.upload-dir=uploads
```

#### 4. Build Project

**Using Maven Wrapper (Recommended):**
```bash
# Windows
mvnw.cmd clean install

# Linux/Mac
./mvnw clean install
```

**Using Installed Maven:**
```bash
mvn clean install
```

**Expected Output:**
```
[INFO] BUILD SUCCESS
[INFO] Total time: 45.123 s
```

#### 5. Run Application

**Using Maven:**
```bash
# Windows
mvnw.cmd spring-boot:run

# Linux/Mac
./mvnw spring-boot:run
```

**Using JAR:**
```bash
java -jar target/marketplace-0.0.1-SNAPSHOT.jar
```

**Verify Application Started:**
- Open browser: http://localhost:8081
- Check logs for: `Started MarketplaceApplication in X.XXX seconds`

#### 6. IDE Setup (IntelliJ IDEA)

1. **Import Project:**
   - File → Open → Select `pom.xml`
   - Choose "Open as Project"

2. **Enable Lombok:**
   - Install Lombok plugin
   - Settings → Build, Execution, Deployment → Compiler → Annotation Processors
   - Enable "Enable annotation processing"

3. **Configure Code Style:**
   - Settings → Editor → Code Style → Java
   - Import scheme: `.editorconfig` (if provided)

4. **Set JDK:**
   - File → Project Structure → Project
   - SDK: Java 17

5. **Enable Spring Boot DevTools:**
   - Already included in `pom.xml`
   - Automatic restart on file changes

---

## Project Structure

### Directory Layout

```
SWE391_Group3_Project/
├── .mvn/                           # Maven wrapper files
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── vn/group3/marketplace/
│   │   │       ├── MarketplaceApplication.java    # Main entry point
│   │   │       ├── config/                        # Configuration classes
│   │   │       │   ├── PasswordEncoderConfig.java
│   │   │       │   ├── WebMvcConfig.java
│   │   │       │   ├── JpaConfig.java
│   │   │       │   └── MarketplaceProperties.java
│   │   │       ├── controller/
│   │   │       │   ├── web/                       # Public controllers
│   │   │       │   │   ├── DashboardController.java
│   │   │       │   │   ├── UserController.java
│   │   │       │   │   └── SellerStoreController.java
│   │   │       │   └── admin/                     # Admin controllers
│   │   │       │       └── AdminStoreController.java
│   │   │       ├── domain/
│   │   │       │   ├── BaseEntity.java            # Abstract base for entities
│   │   │       │   ├── entity/                    # JPA entities
│   │   │       │   │   ├── User.java
│   │   │       │   │   ├── Role.java
│   │   │       │   │   ├── Permission.java
│   │   │       │   │   ├── Wallet.java
│   │   │       │   │   ├── WalletTransaction.java
│   │   │       │   │   └── SellerStore.java
│   │   │       │   ├── enums/                     # Enums
│   │   │       │   │   ├── UserStatus.java
│   │   │       │   │   ├── Gender.java
│   │   │       │   │   └── TransactionType.java
│   │   │       │   └── constants/                 # Constants
│   │   │       │       └── StoreStatus.java
│   │   │       ├── dto/
│   │   │       │   ├── request/                   # Request DTOs
│   │   │       │   │   ├── SellerStoreCreateRequest.java
│   │   │       │   │   └── SellerStoreUpdateRequest.java
│   │   │       │   └── response/                  # Response DTOs
│   │   │       │       ├── SellerStoreResponse.java
│   │   │       │       └── StoreDashboardResponse.java
│   │   │       ├── repository/                    # Data access
│   │   │       │   ├── UserRepository.java
│   │   │       │   ├── RoleRepository.java
│   │   │       │   ├── WalletRepository.java
│   │   │       │   └── SellerStoreRepository.java
│   │   │       ├── service/
│   │   │       │   ├── interfaces/                # Service contracts
│   │   │       │   │   ├── UserService.java
│   │   │       │   │   ├── WalletService.java
│   │   │       │   │   └── SellerStoreService.java
│   │   │       │   └── impl/                      # Service implementations
│   │   │       │       ├── UserServiceImpl.java
│   │   │       │       ├── WalletServiceImpl.java
│   │   │       │       └── SellerStoreServiceImpl.java
│   │   │       └── util/                          # Utility classes
│   │   │           └── DevUserCreator.java
│   │   ├── resources/
│   │   │   ├── application.properties             # Main configuration
│   │   │   ├── static/                            # Static resources (CSS, JS, images)
│   │   │   │   ├── css/
│   │   │   │   ├── js/
│   │   │   │   └── images/
│   │   │   └── templates/                         # (Not used - using JSP)
│   │   └── webapp/
│   │       └── WEB-INF/
│   │           └── view/                          # JSP views
│   │               ├── dashboard.jsp
│   │               ├── navbar.jsp
│   │               ├── sidebar.jsp
│   │               ├── user/
│   │               │   ├── list.jsp
│   │               │   ├── profile.jsp
│   │               │   ├── edit.jsp
│   │               │   ├── register.jsp
│   │               │   └── change-password.jsp
│   │               └── store/
│   │                   ├── list.jsp
│   │                   ├── create.jsp
│   │                   ├── dashboard.jsp
│   │                   └── settings.jsp
│   └── test/
│       └── java/                                  # Test classes (TODO)
├── docs/                                          # Documentation
│   ├── README.md
│   ├── ARCHITECTURE.md
│   ├── DATABASE.md
│   ├── API.md
│   ├── BUSINESS_RULES.md
│   ├── DEVELOPMENT.md
│   └── DEPLOYMENT.md
├── marketplace.sql                                # Database schema
├── marketplace-sample-data.sql                   # Sample data
├── pom.xml                                       # Maven dependencies
├── mvnw, mvnw.cmd                               # Maven wrapper
└── README.md                                     # Project readme
```

---

## Development Workflow

### Branch Strategy

**Main Branches:**
- `main` - Production-ready code
- `dev_raw` - Development branch (current working branch)
- `feature/*` - Feature branches
- `bugfix/*` - Bug fix branches
- `hotfix/*` - Production hotfixes

### Feature Development Workflow

1. **Create Feature Branch:**
   ```bash
   git checkout dev_raw
   git pull origin dev_raw
   git checkout -b feature/product-management
   ```

2. **Develop Feature:**
   - Write code
   - Test locally
   - Commit frequently with meaningful messages

3. **Commit Changes:**
   ```bash
   git add .
   git commit -m "feat: implement product CRUD operations"
   ```

4. **Push to Remote:**
   ```bash
   git push origin feature/product-management
   ```

5. **Create Pull Request:**
   - Open PR from `feature/product-management` to `dev_raw`
   - Add description and screenshots
   - Request code review

6. **Merge to Dev:**
   - After approval, merge to `dev_raw`
   - Delete feature branch

7. **Deploy to Production:**
   - When `dev_raw` is stable, merge to `main`
   - Tag release version

---

### Commit Message Convention

**Format:**
```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting)
- `refactor`: Code refactoring
- `test`: Adding tests
- `chore`: Build tasks, dependencies

**Examples:**
```
feat(user): add password reset functionality

Implement password reset flow with email verification.
- Add PasswordResetController
- Create email template
- Add reset token generation

Closes #42
```

```
fix(store): prevent duplicate store creation

Check if user already has a store before allowing creation.

Fixes #38
```

---

## Coding Standards

### Java Code Style

**Naming Conventions:**
- Classes: PascalCase (`UserService`)
- Methods: camelCase (`getUserById`)
- Variables: camelCase (`userId`)
- Constants: UPPER_SNAKE_CASE (`MAX_LISTING_PRICE`)
- Packages: lowercase (`vn.group3.marketplace.service`)

**Best Practices:**
- Use Lombok annotations to reduce boilerplate
- Always use `@Override` annotation
- Declare variables as interfaces when possible
- Use `Optional` for nullable returns
- Avoid nested if statements (max 2 levels)
- Keep methods under 50 lines

**Lombok Usage:**
```java
@Data                    // Getters, setters, toString, equals, hashCode
@Builder                 // Builder pattern
@NoArgsConstructor       // Default constructor
@AllArgsConstructor      // Constructor with all fields
@RequiredArgsConstructor // Constructor for final fields
@Slf4j                   // Logger instance
```

---

### Service Layer

**Interface + Implementation Pattern:**
```java
// Interface
public interface UserService {
    User createUser(User user);
    Optional<User> getUserById(Long id);
}

// Implementation
@Service
@RequiredArgsConstructor
@Transactional
public class UserServiceImpl implements UserService {
    private final UserRepository userRepository;

    @Override
    public User createUser(User user) {
        // Business logic
        return userRepository.save(user);
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<User> getUserById(Long id) {
        return userRepository.findById(id);
    }
}
```

**Transaction Management:**
- `@Transactional` on service class
- `@Transactional(readOnly = true)` for read-only methods
- Explicit transaction boundaries

---

### Controller Layer

**Best Practices:**
```java
@Controller
@RequestMapping("/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @GetMapping
    public String listUsers(
        @RequestParam(defaultValue = "0") int page,
        @RequestParam(defaultValue = "10") int size,
        Model model
    ) {
        Page<User> users = userService.getUsers(PageRequest.of(page, size));
        model.addAttribute("users", users);
        return "user/list";
    }

    @PostMapping("/create")
    public String createUser(
        @Valid @ModelAttribute User user,
        BindingResult result,
        RedirectAttributes redirectAttributes
    ) {
        if (result.hasErrors()) {
            return "user/create";
        }

        userService.createUser(user);
        redirectAttributes.addFlashAttribute("successMessage", "User created");
        return "redirect:/users";
    }
}
```

---

### JSP Views

**Best Practices:**
- Use JSTL tags, avoid Java scriptlets
- Separate concerns (logic in controller, not view)
- Use Bootstrap classes for styling
- Include CSRF token in forms

**Example:**
```jsp
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:if test="${not empty successMessage}">
    <div class="alert alert-success">${successMessage}</div>
</c:if>

<form action="/users/create" method="post">
    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>

    <div class="mb-3">
        <label for="username" class="form-label">Username</label>
        <input type="text" class="form-control" id="username" name="username" required>
    </div>

    <button type="submit" class="btn btn-primary">Submit</button>
</form>
```

---

## Testing Guidelines

### Unit Testing (TODO - Not Yet Implemented)

**Framework:** JUnit 5 + Mockito

**Service Layer Tests:**
```java
@ExtendWith(MockitoExtension.class)
class UserServiceImplTest {

    @Mock
    private UserRepository userRepository;

    @InjectMocks
    private UserServiceImpl userService;

    @Test
    void createUser_ShouldSaveUser() {
        // Given
        User user = User.builder().username("testuser").build();
        when(userRepository.save(any(User.class))).thenReturn(user);

        // When
        User result = userService.createUser(user);

        // Then
        assertNotNull(result);
        assertEquals("testuser", result.getUsername());
        verify(userRepository, times(1)).save(user);
    }
}
```

---

### Integration Testing (TODO)

**Framework:** Spring Boot Test + TestContainers

**Repository Tests:**
```java
@DataJpaTest
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
class UserRepositoryTest {

    @Autowired
    private UserRepository userRepository;

    @Test
    void findByUsername_ShouldReturnUser() {
        // Given
        User user = User.builder().username("testuser").build();
        userRepository.save(user);

        // When
        Optional<User> result = userRepository.findByUsername("testuser");

        // Then
        assertTrue(result.isPresent());
        assertEquals("testuser", result.get().getUsername());
    }
}
```

---

### Controller Tests (TODO)

**Framework:** MockMvc

```java
@WebMvcTest(UserController.class)
class UserControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private UserService userService;

    @Test
    void listUsers_ShouldReturnUserListView() throws Exception {
        // Given
        Page<User> users = new PageImpl<>(Collections.emptyList());
        when(userService.getUsers(any(Pageable.class))).thenReturn(users);

        // When & Then
        mockMvc.perform(get("/users"))
            .andExpect(status().isOk())
            .andExpect(view().name("user/list"))
            .andExpect(model().attributeExists("users"));
    }
}
```

---

## Debugging

### Enable Debug Logging

**application.properties:**
```properties
# Spring Framework
logging.level.org.springframework=DEBUG

# Hibernate SQL
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.format_sql=true
logging.level.org.hibernate.SQL=DEBUG
logging.level.org.hibernate.type.descriptor.sql.BasicBinder=TRACE

# Application
logging.level.vn.group3.marketplace=DEBUG
```

---

### IntelliJ IDEA Debugging

1. **Set Breakpoints:**
   - Click left margin next to line number

2. **Debug Mode:**
   - Right-click `MarketplaceApplication`
   - Select "Debug 'MarketplaceApplication'"

3. **Conditional Breakpoints:**
   - Right-click breakpoint
   - Add condition (e.g., `userId == 2`)

4. **Evaluate Expression:**
   - While debugging, press `Alt + F8`
   - Enter expression to evaluate

---

### Common Debug Scenarios

**Check SQL Queries:**
```properties
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.format_sql=true
```

**Inspect HTTP Requests:**
- Use browser DevTools (F12)
- Network tab to see requests/responses

**Database State:**
```sql
-- Check user's wallet balance
SELECT u.username, w.balance
FROM users u
JOIN wallets w ON u.id = w.user_id
WHERE u.id = 2;

-- Check store details
SELECT * FROM seller_stores WHERE owner_user_id = 2;
```

---

## Product Module Development Guide

### Product Entity and DTOs ✅

The Product module follows the standard layered architecture pattern.

**Product Entity Structure:**
```java
@Entity
@Table(name = "products")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Product extends BaseEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "product_name", nullable = false, length = 200)
    private String productName;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(nullable = false, precision = 15, scale = 2)
    private BigDecimal price;

    @Column(name = "stock_quantity", nullable = false)
    private Integer stockQuantity = 0;

    @Enumerated(EnumType.STRING)
    @Column(length = 50)
    private ProductCategory category;

    @Column(name = "product_images", columnDefinition = "TEXT")
    private String productImages;  // JSON array of image URLs

    @Column(length = 50, unique = true)
    private String sku;

    @Column(name = "is_active", nullable = false)
    private Boolean isActive = true;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "seller_store_id", nullable = false)
    private SellerStore sellerStore;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "seller_id", nullable = false)
    private User seller;
}
```

**ProductCategory Enum:**
```java
public enum ProductCategory {
    GAME_ACCOUNT("Tài khoản Game"),
    GAME_CURRENCY("Vàng/Tiền Game"),
    SOCIAL_ACCOUNT("Tài khoản MXH"),
    SOFTWARE_LICENSE("License Phần mềm"),
    GIFT_CARD("Thẻ quà tặng"),
    VPN_PROXY("VPN/Proxy"),
    OTHER("Khác");

    private final String displayName;

    ProductCategory(String displayName) {
        this.displayName = displayName;
    }

    public String getDisplayName() {
        return displayName;
    }
}
```

---

### Product Service Implementation ✅

**Key Service Methods:**

```java
@Service
@RequiredArgsConstructor
@Transactional
public class ProductServiceImpl implements ProductService {

    private final ProductRepository productRepository;
    private final SellerStoreService sellerStoreService;

    // Create product with validation
    @Override
    public Product createProduct(ProductCreateRequest request, Long userId) {
        // 1. Validate user has active store
        SellerStore store = sellerStoreService.getStoreByUserId(userId)
            .orElseThrow(() -> new IllegalStateException("You must have an active seller store"));

        // 2. Validate price <= max_listing_price
        if (request.getPrice().compareTo(store.getMaxListingPrice()) > 0) {
            throw new IllegalArgumentException("Product price exceeds max listing price");
        }

        // 3. Generate SKU if not provided
        String sku = (request.getSku() != null) ? request.getSku() : generateSKU();

        // 4. Build and save product
        Product product = Product.builder()
            .productName(request.getProductName())
            .description(request.getDescription())
            .price(request.getPrice())
            .stockQuantity(request.getStockQuantity())
            .category(request.getCategory())
            .sku(sku)
            .sellerStore(store)
            .seller(store.getOwner())
            .build();

        return productRepository.save(product);
    }

    // Auto-generate SKU: PRD-XXXXXXXX
    private String generateSKU() {
        String sku;
        do {
            sku = "PRD-" + RandomStringUtils.randomAlphabetic(8).toUpperCase();
        } while (productRepository.existsBySku(sku));
        return sku;
    }

    // Advanced filtering with 6 parameters
    @Override
    @Transactional(readOnly = true)
    public Page<Product> findAllWithFilters(
        String search,
        ProductCategory category,
        BigDecimal minPrice,
        BigDecimal maxPrice,
        Long storeId,
        String stockStatus,
        Pageable pageable
    ) {
        return productRepository.findAllWithFilters(
            search, category, minPrice, maxPrice, storeId, stockStatus, pageable
        );
    }
}
```

---

### Product Repository with Custom Queries ✅

**Custom Query Methods:**

```java
public interface ProductRepository extends JpaRepository<Product, Long> {

    // Check SKU availability
    boolean existsBySku(String sku);

    // Find by seller store
    List<Product> findBySellerStoreIdAndIsDeletedFalse(Long storeId);

    // Custom filtering implementation
    @Query("""
        SELECT p FROM Product p
        WHERE p.isDeleted = false
        AND (:search IS NULL OR LOWER(p.productName) LIKE LOWER(CONCAT('%', :search, '%'))
            OR LOWER(p.description) LIKE LOWER(CONCAT('%', :search, '%')))
        AND (:category IS NULL OR p.category = :category)
        AND (:minPrice IS NULL OR p.price >= :minPrice)
        AND (:maxPrice IS NULL OR p.price <= :maxPrice)
        AND (:storeId IS NULL OR p.sellerStore.id = :storeId)
        AND (
            :stockStatus = 'ALL'
            OR (:stockStatus = 'IN_STOCK' AND p.stockQuantity > 10)
            OR (:stockStatus = 'LOW_STOCK' AND p.stockQuantity BETWEEN 1 AND 10)
            OR (:stockStatus = 'OUT_OF_STOCK' AND p.stockQuantity = 0)
        )
        """)
    Page<Product> findAllWithFilters(
        @Param("search") String search,
        @Param("category") ProductCategory category,
        @Param("minPrice") BigDecimal minPrice,
        @Param("maxPrice") BigDecimal maxPrice,
        @Param("storeId") Long storeId,
        @Param("stockStatus") String stockStatus,
        Pageable pageable
    );
}
```

---

### File Upload Service ✅

**FileUploadService Interface:**

```java
public interface FileUploadService {
    String uploadProductImage(Long productId, MultipartFile file) throws IOException;
}
```

**FileUploadServiceImpl:**

```java
@Service
@Slf4j
public class FileUploadServiceImpl implements FileUploadService {

    @Value("${file.upload-dir:uploads}")
    private String uploadDir;

    private static final long MAX_FILE_SIZE = 2 * 1024 * 1024; // 2MB
    private static final List<String> ALLOWED_EXTENSIONS = Arrays.asList("jpg", "jpeg", "png", "gif");
    private static final List<String> ALLOWED_CONTENT_TYPES = Arrays.asList(
        "image/jpeg", "image/png", "image/gif"
    );

    @Override
    public String uploadProductImage(Long productId, MultipartFile file) throws IOException {
        // 1. Validation
        if (file.isEmpty()) {
            throw new IllegalArgumentException("Uploaded file is empty");
        }

        if (file.getSize() > MAX_FILE_SIZE) {
            throw new IllegalArgumentException("File size exceeds 2MB limit");
        }

        if (!isValidImageFile(file)) {
            throw new IllegalArgumentException("Invalid file type. Only JPG, JPEG, PNG, GIF allowed");
        }

        // 2. Create directory structure
        String productDir = uploadDir + "/products/images/" + productId + "/";
        Files.createDirectories(Paths.get(productDir));

        // 3. Generate unique filename
        String uniqueFilename = generateUniqueFileName(file.getOriginalFilename());
        String filePath = productDir + uniqueFilename;

        // 4. Save file
        file.transferTo(new File(filePath));

        // 5. Return URL
        return "/uploads/products/images/" + productId + "/" + uniqueFilename;
    }

    private boolean isValidImageFile(MultipartFile file) {
        String originalFilename = file.getOriginalFilename();
        if (originalFilename == null) return false;

        String extension = originalFilename.substring(originalFilename.lastIndexOf(".") + 1).toLowerCase();
        String contentType = file.getContentType();

        return ALLOWED_EXTENSIONS.contains(extension) && ALLOWED_CONTENT_TYPES.contains(contentType);
    }

    private String generateUniqueFileName(String originalFilename) {
        String extension = originalFilename.substring(originalFilename.lastIndexOf("."));
        return System.currentTimeMillis() + "_" + UUID.randomUUID().toString() + extension;
    }
}
```

---

### Product Controller Examples ✅

**List Products with Filtering:**

```java
@GetMapping("/products")
public String listProducts(
    @RequestParam(required = false) String search,
    @RequestParam(required = false) ProductCategory category,
    @RequestParam(required = false) BigDecimal minPrice,
    @RequestParam(required = false) BigDecimal maxPrice,
    @RequestParam(required = false) Long storeId,
    @RequestParam(defaultValue = "ALL") String stockStatus,
    @RequestParam(defaultValue = "0") int page,
    @RequestParam(defaultValue = "12") int size,
    @RequestParam(defaultValue = "createdAt") String sort,
    Model model
) {
    Pageable pageable = PageRequest.of(page, size, Sort.by(sort).descending());

    Page<Product> products = productService.findAllWithFilters(
        search, category, minPrice, maxPrice, storeId, stockStatus, pageable
    );

    model.addAttribute("products", products);
    model.addAttribute("categories", ProductCategory.values());
    return "product/list";
}
```

**Upload Product Images:**

```java
@PostMapping("/products/{id}/upload-images")
public String uploadProductImages(
    @PathVariable Long id,
    @RequestParam("file") MultipartFile file,
    RedirectAttributes redirectAttributes
) {
    try {
        String imageUrl = fileUploadService.uploadProductImage(id, file);
        productService.addProductImage(id, imageUrl);
        redirectAttributes.addFlashAttribute("successMessage", "Image uploaded successfully");
    } catch (IOException | IllegalArgumentException e) {
        redirectAttributes.addFlashAttribute("errorMessage", e.getMessage());
    }
    return "redirect:/products/" + id;
}
```

---

### Test Mode Development ⚠️

**Purpose:** Test mode endpoints allow product creation without authentication during development.

**Test Mode Endpoints:**

```java
// Test mode product creation form (bypasses auth)
@GetMapping("/products/create-test")
public String showCreateTestForm(Model model) {
    model.addAttribute("product", new ProductCreateRequest());
    model.addAttribute("categories", ProductCategory.values());
    model.addAttribute("testMode", true);
    return "product/create";
}

// Test mode product creation (hardcoded store_id=2)
@PostMapping("/products/create-test")
public String createTestProduct(
    @Valid @ModelAttribute ProductCreateRequest request,
    BindingResult result,
    RedirectAttributes redirectAttributes
) {
    if (result.hasErrors()) {
        return "product/create";
    }

    // Hardcoded store_id for testing
    Long testStoreId = 2L;
    SellerStore store = sellerStoreService.getStoreById(testStoreId)
        .orElseThrow(() -> new RuntimeException("Test store not found"));

    Product product = productService.createProductForStore(request, store);
    redirectAttributes.addFlashAttribute("successMessage", "Product created successfully (TEST MODE)");
    return "redirect:/products/" + product.getId();
}
```

**⚠️ Important Notes:**
- Test mode endpoints are located at `ProductController.java:453-506`
- They bypass all authentication and authorization checks
- Use hardcoded `store_id = 2` (seller01's store)
- **MUST be removed before production deployment**

**Remove Before Production:**
```java
// Delete these endpoints:
// - GET /products/create-test
// - POST /products/create-test
```

---

### Lazy Loading Best Practices ✅

**Problem:** `LazyInitializationException` when accessing collections outside transaction

**Solution 1: Use @Transactional(readOnly = true)**

```java
@Override
@Transactional(readOnly = true)
public Product getProductById(Long id) {
    return productRepository.findById(id)
        .orElseThrow(() -> new ResourceNotFoundException("Product not found"));
}
```

**Solution 2: Use JOIN FETCH in queries**

```java
@Query("SELECT p FROM Product p LEFT JOIN FETCH p.sellerStore LEFT JOIN FETCH p.seller WHERE p.id = :id")
Optional<Product> findByIdWithDetails(@Param("id") Long id);
```

**Solution 3: Use @EntityGraph (recommended for complex graphs)**

```java
@EntityGraph(attributePaths = {"sellerStore", "seller"})
Optional<Product> findById(Long id);
```

---

## Common Tasks

### Add New Entity

1. **Create Entity Class:**
   ```java
   @Entity
   @Table(name = "products")
   @Data
   @Builder
   @NoArgsConstructor
   @AllArgsConstructor
   public class Product extends BaseEntity {
       @Id
       @GeneratedValue(strategy = GenerationType.IDENTITY)
       private Long id;

       private String name;
       private BigDecimal price;

       @ManyToOne
       @JoinColumn(name = "seller_store_id")
       private SellerStore sellerStore;
   }
   ```

2. **Create Repository:**
   ```java
   public interface ProductRepository extends JpaRepository<Product, Long> {
       List<Product> findBySellerStoreId(Long storeId);
   }
   ```

3. **Create Service Interface & Implementation**

4. **Create Controller**

5. **Create JSP Views**

---

### Add New Endpoint

1. **Controller Method:**
   ```java
   @GetMapping("/products/{id}")
   public String viewProduct(@PathVariable Long id, Model model) {
       Product product = productService.getProductById(id)
           .orElseThrow(() -> new ResourceNotFoundException("Product not found"));
       model.addAttribute("product", product);
       return "product/detail";
   }
   ```

2. **Create JSP View:**
   - `src/main/webapp/WEB-INF/view/product/detail.jsp`

3. **Add Navigation Link:**
   - Update navbar or sidebar

---

### Update Database Schema

**Development (Hibernate Auto-Update):**
```properties
spring.jpa.hibernate.ddl-auto=update
```

**Production (Manual Migration):**
1. Create migration SQL file
2. Review changes
3. Execute on production database
4. Set `spring.jpa.hibernate.ddl-auto=validate`

---

### Add Configuration Property

1. **application.properties:**
   ```properties
   marketplace.feature.enable-reviews=true
   ```

2. **Configuration Class:**
   ```java
   @Configuration
   @ConfigurationProperties(prefix = "marketplace.feature")
   @Data
   public class FeatureProperties {
       private Boolean enableReviews = false;
   }
   ```

3. **Use in Service:**
   ```java
   @RequiredArgsConstructor
   public class ReviewService {
       private final FeatureProperties featureProperties;

       public void createReview() {
           if (!featureProperties.getEnableReviews()) {
               throw new FeatureDisabledException();
           }
           // ...
       }
   }
   ```

---

## Troubleshooting

### Application Won't Start

**Problem:** Port 8081 already in use

**Solution:**
```bash
# Find process using port 8081
netstat -ano | findstr :8081

# Kill process (Windows)
taskkill /PID <PID> /F

# Or change port in application.properties
server.port=8082
```

---

**Problem:** Database connection refused

**Solution:**
1. Check MySQL is running
2. Verify credentials in `application.properties`
3. Check database exists:
   ```sql
   SHOW DATABASES LIKE 'mmo_market_system';
   ```

---

### Build Failures

**Problem:** Lombok not working

**Solution:**
1. Install Lombok plugin in IDE
2. Enable annotation processing
3. Reimport Maven project

---

**Problem:** Test failures

**Solution:**
```bash
# Skip tests temporarily
mvn clean install -DskipTests

# Run specific test
mvn test -Dtest=UserServiceTest
```

---

### Runtime Errors

**Problem:** `LazyInitializationException`

**Solution:**
- Add `@Transactional` to service method
- Use `@EntityGraph` to fetch eagerly
- Use `FetchType.EAGER` (last resort)

---

**Problem:** CSRF token missing

**Solution:**
- Add to form:
  ```jsp
  <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
  ```

---

### Database Issues

**Problem:** Foreign key constraint violation

**Solution:**
- Check referential integrity
- Verify parent record exists
- Use appropriate cascade/delete actions

---

**Problem:** Duplicate entry error

**Solution:**
- Check unique constraints
- Verify data before insert
- Handle exception in service layer

---

### Product Module Issues

**Problem:** Product price exceeds max listing price

**Solution:**
```java
// Check store's max listing price before creating product
if (product.getPrice().compareTo(store.getMaxListingPrice()) > 0) {
    throw new IllegalArgumentException("Product price exceeds max listing price");
}
```

---

**Problem:** SKU already exists

**Solution:**
- Use AJAX check before submission: `GET /products/check-sku?sku={sku}`
- Auto-generate SKU if not provided (recommended)
- Handle `DataIntegrityViolationException` for unique constraint

---

**Problem:** File upload fails (size/type validation)

**Solution:**
```java
// Check file size (max 2MB)
if (file.getSize() > 2 * 1024 * 1024) {
    throw new IllegalArgumentException("File exceeds 2MB limit");
}

// Check file type
String extension = file.getOriginalFilename().substring(file.getOriginalFilename().lastIndexOf(".") + 1);
if (!Arrays.asList("jpg", "jpeg", "png", "gif").contains(extension.toLowerCase())) {
    throw new IllegalArgumentException("Invalid file type");
}
```

---

**Problem:** Uploaded images not displaying

**Solution:**
1. Check upload directory exists and is writable
2. Verify static resource mapping in WebMvcConfig:
   ```java
   registry.addResourceHandler("/uploads/**")
       .addResourceLocations("file:uploads/");
   ```
3. Check image URL format in database: `/uploads/products/images/{productId}/{filename}`
4. Verify file physically exists in `uploads/products/images/{productId}/` directory

---

**Problem:** LazyInitializationException when displaying product with store details

**Solution:**
```java
// Option 1: Add @Transactional(readOnly = true) to controller method
@GetMapping("/products/{id}")
@Transactional(readOnly = true)
public String viewProduct(@PathVariable Long id, Model model) {
    // Can access lazy collections
}

// Option 2: Use JOIN FETCH in repository
@Query("SELECT p FROM Product p LEFT JOIN FETCH p.sellerStore WHERE p.id = :id")
Optional<Product> findByIdWithStore(@Param("id") Long id);
```

---

**Problem:** Test mode endpoints not working

**Solution:**
1. Verify `store_id = 2` exists in database:
   ```sql
   SELECT * FROM seller_stores WHERE id = 2;
   ```
2. Check if seller01 user (id=2) has a store
3. Remember: Test endpoints will be removed in production

---

## Hot Reload / DevTools

**Spring Boot DevTools** is included and provides:
- Automatic restart on file changes
- LiveReload support
- Property defaults for development

**Trigger Restart:**
- Make code change
- Build project (`Ctrl + F9` in IntelliJ)
- Application restarts automatically

**Exclude from Restart:**
```properties
spring.devtools.restart.exclude=static/**,public/**
```

---

## Best Practices Summary

✅ **DO:**
- Use dependency injection
- Write transaction boundaries clearly
- Validate input at controller and service layers
- Use DTOs for API contracts
- Write comprehensive JavaDoc
- Log important business events
- Handle exceptions gracefully

❌ **DON'T:**
- Put business logic in controllers
- Use hard-coded values (use configuration)
- Expose entities directly in API
- Ignore exceptions
- Commit sensitive data (passwords, API keys)
- Skip code reviews

---

**Last Updated:** January 2025
**Document Version:** 1.0.0
