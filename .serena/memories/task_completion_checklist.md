# TaphoaMMO Marketplace - Task Completion Checklist

## When Completing a Development Task

### 1. Code Quality Checks
- [ ] **Compile Check**: Ensure code compiles without errors
  ```bash
  ./mvnw clean compile
  ```
- [ ] **Code Style**: Follow established naming conventions and patterns
- [ ] **Lombok Usage**: Use @Getter, @Setter appropriately
- [ ] **Annotations**: Proper Spring annotations (@Service, @Repository, @Controller)

### 2. Testing Requirements
- [ ] **Unit Tests**: Write tests for new business logic
  ```bash
  ./mvnw test
  ```
- [ ] **Integration Tests**: Test database interactions and API endpoints
- [ ] **Test Coverage**: Aim for 80%+ coverage on critical business logic
- [ ] **Test Data**: Use appropriate test data and mocking

### 3. Database Considerations
- [ ] **Schema Alignment**: Ensure entities match database schema
- [ ] **Migration Scripts**: Update database if schema changes
- [ ] **Audit Fields**: Include created_at, created_by, updated_at, is_deleted
- [ ] **Soft Delete**: Implement logical deletion pattern

### 4. Security Validation
- [ ] **Authentication**: Verify user authentication requirements
- [ ] **Authorization**: Check role-based access control
- [ ] **Input Validation**: Validate all user inputs
- [ ] **SQL Injection**: Use parameterized queries

### 5. Business Logic Verification
- [ ] **Deposit Validation**: Seller deposit >= 5M VND
- [ ] **Price Limits**: Product price <= store max_listing_price
- [ ] **Escrow Logic**: 3-day hold period implementation
- [ ] **Wallet Balance**: Sufficient balance checks

### 6. API Documentation
- [ ] **Endpoint Documentation**: Document new REST endpoints
- [ ] **Request/Response**: Define DTOs and validation rules
- [ ] **Error Handling**: Implement proper error responses
- [ ] **Status Codes**: Use appropriate HTTP status codes

### 7. Performance Considerations
- [ ] **Database Queries**: Optimize N+1 query problems
- [ ] **Caching**: Implement caching where appropriate
- [ ] **Pagination**: Use pagination for large datasets
- [ ] **Indexing**: Ensure proper database indexes

### 8. Final Verification
- [ ] **Application Startup**: Verify application starts successfully
  ```bash
  ./mvnw spring-boot:run
  ```
- [ ] **Endpoint Testing**: Test new endpoints manually or with Postman
- [ ] **Database Verification**: Check data persistence and retrieval
- [ ] **Log Review**: Check application logs for errors or warnings

### 9. Documentation Updates
- [ ] **README**: Update if new setup steps required
- [ ] **API Docs**: Update API documentation
- [ ] **Comments**: Add meaningful code comments
- [ ] **User Stories**: Mark user stories as complete

### 10. Version Control
- [ ] **Git Status**: Check for uncommitted changes
  ```bash
  git status
  ```
- [ ] **Commit Message**: Write descriptive commit message
- [ ] **Branch Strategy**: Follow branching strategy
- [ ] **Code Review**: Request code review if required

## Critical Business Rules to Verify
1. **Seller Store Creation**: Minimum 5M VND deposit required
2. **Product Pricing**: Cannot exceed store's max_listing_price
3. **Order Processing**: Automatic escrow creation and 3-day hold
4. **Product Delivery**: Automated delivery from product_storage
5. **Wallet Transactions**: Accurate balance calculations
6. **Role Permissions**: Proper access control enforcement

## Common Issues to Check
- Database connection configuration (mmo_market_system vs laptopshop)
- Security configuration (currently disabled for development)
- Entity relationships and foreign key constraints
- JSON payload handling for digital products
- Audit trail implementation in BaseEntity