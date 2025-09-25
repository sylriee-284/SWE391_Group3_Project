# TaphoaMMO Marketplace - Code Style and Conventions

## Package Structure
```
vn.group3.marketplace/
├── config/          # Configuration classes
├── controller/      # REST controllers and web controllers
├── domain/          # Entity classes and domain models
├── service/         # Business logic services
├── repository/      # Data access repositories
└── MarketplaceApplication.java  # Main application class
```

## Naming Conventions
- **Package names**: lowercase with dots (vn.group3.marketplace)
- **Class names**: PascalCase (MarketplaceApplication, BaseEntity)
- **Method names**: camelCase (getMethodName, findByUsernameOrEmail)
- **Variable names**: camelCase (userId, createdAt)
- **Constants**: UPPER_SNAKE_CASE (MINIMUM_DEPOSIT)

## Entity Design Patterns
- **Base Entity**: All entities extend BaseEntity for audit trails
- **Soft Delete**: Uses is_deleted flag instead of physical deletion
- **Audit Fields**: created_at, created_by, updated_at, deleted_by
- **Lombok Annotations**: @Getter, @Setter for reducing boilerplate
- **JPA Annotations**: @Entity, @Table, @Column for database mapping

## Database Conventions
- **Table names**: snake_case (seller_stores, product_storage)
- **Column names**: snake_case (created_at, is_deleted)
- **Foreign keys**: Descriptive names (owner_user_id, seller_store_id)
- **Indexes**: Prefixed with idx_ (idx_users_created_by)
- **Constraints**: Descriptive names (fk_users_created_by, chk_store_min_deposit)

## Spring Annotations
- **@SpringBootApplication**: Main application class
- **@Controller**: Web controllers for JSP views
- **@RestController**: REST API controllers
- **@Service**: Business logic services
- **@Repository**: Data access repositories
- **@Entity**: JPA entities
- **@Configuration**: Configuration classes

## Code Organization
- **Controllers**: Handle HTTP requests and responses
- **Services**: Contain business logic and transaction management
- **Repositories**: Data access layer with custom queries
- **Entities**: Domain models with JPA mappings
- **Config**: Configuration classes for Spring components

## Error Handling
- Use appropriate HTTP status codes
- Implement validation with Bean Validation annotations
- Handle exceptions with @ExceptionHandler
- Provide meaningful error messages