# TaphoaMMO Marketplace System

## Project Overview

**TaphoaMMO Marketplace** is a comprehensive e-commerce platform designed for trading digital goods and services in the MMO (Massively Multiplayer Online) gaming industry. The platform enables sellers to create stores, list digital products (game accounts, in-game items, subscriptions, etc.), and buyers to purchase these items securely through an escrow-based payment system.

### Version
- **Project Version:** 1.0.0 (v0.0.1-SNAPSHOT)
- **Database:** mmo_market_system (MySQL)
- **Status:** Active Development (~40% complete)

---

## Key Features

### Implemented Features ✓
- **User Management:** Registration, authentication, profile management, password change
- **Seller Store System:** One store per user with deposit-based listing limits
- **Wallet System:** User wallets for deposits, withdrawals, and transaction tracking
- **Role-Based Access Control (RBAC):** 5 roles with 27 granular permissions
- **Dashboard:** System overview with user and financial statistics
- **Responsive UI:** Bootstrap 5.3.2 based JSP templates

### In Development ⚙️
- **Spring Security Configuration:** Basic HTTP auth currently active
- **Store Deposit Processing:** Temporarily disabled for testing
- **File Upload Service:** Interface defined, implementation pending

### Planned Features 📋
- **Product Management:** Create, list, and manage digital product inventory
- **Order Processing:** Complete purchase workflow with escrow protection
- **Review & Rating System:** Product and seller reviews
- **Messaging System:** Buyer-seller communication
- **Dispute Resolution:** Conflict management system
- **Payment Gateway Integration:** Multiple payment methods
- **Admin Analytics:** Comprehensive reports and insights

---

## Technology Stack

### Backend
- **Framework:** Spring Boot 3.5.5
- **Language:** Java 17
- **ORM:** Hibernate (JPA)
- **Database:** MySQL 8.0+
- **Security:** Spring Security
- **Build Tool:** Maven
- **Server:** Embedded Tomcat

### Frontend
- **Template Engine:** JSP (Jakarta Server Pages)
- **CSS Framework:** Bootstrap 5.3.2
- **JavaScript Library:** jQuery 3.7.1
- **Icons:** Font Awesome

### Development Tools
- **Hot Reload:** Spring Boot DevTools
- **Lombok:** Reduce boilerplate code
- **Actuator:** Production monitoring endpoints

---

## Quick Start

### Prerequisites
- **JDK 17** or higher
- **MySQL 8.0+**
- **Maven 3.6+** (or use included wrapper)
- **Git**

### Installation Steps

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd SWE391_Group3_Project
   ```

2. **Set up MySQL database**
   ```bash
   mysql -u root -p
   CREATE DATABASE mmo_market_system;
   USE mmo_market_system;
   SOURCE marketplace.sql;
   SOURCE marketplace-sample-data.sql;
   ```

3. **Configure database connection**

   Edit `src/main/resources/application.properties`:
   ```properties
   spring.datasource.url=jdbc:mysql://localhost:3306/mmo_market_system
   spring.datasource.username=root
   spring.datasource.password=your_password
   ```

4. **Build and run**
   ```bash
   # Using Maven wrapper (recommended)
   ./mvnw clean spring-boot:run

   # Or using installed Maven
   mvn clean spring-boot:run
   ```

5. **Access the application**
   - **URL:** http://localhost:8081
   - **Default Admin Credentials:**
     - Username: `admin`
     - Password: `admin123`

---

## Project Structure

```
SWE391_Group3_Project/
├── src/
│   ├── main/
│   │   ├── java/vn/group3/marketplace/
│   │   │   ├── config/              # Configuration classes
│   │   │   ├── controller/
│   │   │   │   ├── admin/          # Admin controllers
│   │   │   │   └── web/            # Public web controllers
│   │   │   ├── domain/
│   │   │   │   ├── entity/         # JPA entities
│   │   │   │   ├── enums/          # Enum types
│   │   │   │   └── constants/      # Constants
│   │   │   ├── dto/
│   │   │   │   ├── request/        # Request DTOs
│   │   │   │   └── response/       # Response DTOs
│   │   │   ├── repository/         # Data access layer
│   │   │   ├── service/
│   │   │   │   ├── interfaces/     # Service contracts
│   │   │   │   └── impl/           # Service implementations
│   │   │   └── util/               # Utility classes
│   │   ├── resources/
│   │   │   ├── application.properties
│   │   │   └── static/             # Static resources
│   │   └── webapp/WEB-INF/view/    # JSP templates
│   └── test/                        # Test classes (TODO)
├── docs/                            # Project documentation
├── marketplace.sql                  # Database schema
├── marketplace-sample-data.sql     # Sample data
├── pom.xml                         # Maven dependencies
└── README.md                       # This file
```

---

## Core Modules

### 1. User Management
- User registration with validation
- Profile management (update info, change password)
- User listing with pagination, search, and filtering
- Status management (active/inactive)

### 2. Seller Store Management
- Store creation (one per user)
- Deposit-based listing price limits
- Store settings and branding
- Store activation/deactivation

### 3. Wallet System
- One wallet per user
- Balance management (VND currency)
- Transaction history tracking
- Deposit and withdrawal operations

### 4. Role-Based Access Control
- **Roles:** ADMIN, MODERATOR, SELLER, BUYER, USER
- **Permissions:** 27 granular permissions across 9 categories
- Spring Security integration

### 5. Dashboard & Analytics
- User statistics
- Financial overview
- Store metrics (planned)

---

## Business Model

### Seller Store Requirements
- **Minimum Deposit:** 5,000,000 VND (currently disabled for testing)
- **Max Listing Price Formula:** `deposit_amount / 10`
- **Store Limit:** One store per user
- **Verification:** Admin approval required for trust badge

### Transaction Flow
1. Buyer purchases product
2. Payment held in **escrow** for 3 days
3. Digital goods delivered to buyer
4. After hold period, payment released to seller
5. Both parties can leave reviews

### Revenue Streams (Planned)
- Transaction fees
- Premium store features
- Featured product listings
- Verification services

---

## Sample Accounts

### Admin Account
- **Username:** admin
- **Email:** admin@marketplace.com
- **Password:** password123
- **Wallet Balance:** 100,000,000 VND

### Seller Accounts
- **seller01-05** (IDs: 2, 3, 4, 10, 12)
- **Password:** password123
- **Wallet Balance:** 15M - 32M VND

### Buyer Accounts
- **buyer01-06** (IDs: 5, 6, 7, 8, 11, 13)
- **Password:** password123
- **Wallet Balance:** 3.5M - 12M VND

---

## API Endpoints (Summary)

### Public Endpoints
- `GET /` - Main dashboard
- `GET /users` - List users
- `GET /stores` - List active stores
- `GET /users/register` - Registration form
- `POST /users/register` - Submit registration

### Authenticated Endpoints
- `GET /users/profile` - View profile
- `POST /users/edit` - Update profile
- `POST /users/change-password` - Change password

### Seller Endpoints (ROLE_SELLER)
- `GET /stores/my-store` - Store dashboard
- `POST /stores/my-store/settings` - Update store
- `POST /stores/my-store/upload-logo` - Upload logo

### Admin Endpoints (ROLE_ADMIN)
- `POST /admin/stores/{id}/verify` - Verify store
- `POST /admin/stores/{id}/suspend` - Suspend store

For complete API documentation, see [API.md](./API.md).

---

## Configuration

### Application Settings
- **Server Port:** 8081
- **Context Path:** /
- **Max File Upload:** 10MB

### Database Settings
- **JDBC URL:** jdbc:mysql://localhost:3306/mmo_market_system
- **Hibernate DDL:** update (auto-update schema)
- **Show SQL:** false (enable for debugging)

### Business Configuration
- **Minimum Store Deposit:** 5,000,000 VND
- **Escrow Hold Period:** 3 days
- **Wallet Currency:** VND

### Security Settings
- **Password Encoding:** BCrypt
- **Session Management:** HTTP session
- **Current Auth:** Basic HTTP (temporary)

---

## Development Status

### Completed (✓)
- [x] Database schema design (17 tables)
- [x] User CRUD operations
- [x] Seller store management
- [x] Wallet basic operations
- [x] RBAC infrastructure
- [x] JSP view templates
- [x] Sample data seeding

### In Progress (⚙️)
- [ ] Spring Security full configuration
- [ ] File upload implementation
- [ ] Transaction integrity fixes

### Not Started (📋)
- [ ] Product management
- [ ] Order processing
- [ ] Review system
- [ ] Messaging system
- [ ] Payment gateway integration
- [ ] Admin analytics
- [ ] Unit tests
- [ ] API documentation (Swagger)

---

## Contributing

### Development Workflow
1. Create feature branch from `dev_raw`
2. Implement feature with tests
3. Submit pull request to `dev_raw`
4. After review, merge to `main`

### Code Standards
- Follow Spring Boot best practices
- Use Lombok for boilerplate reduction
- Write comprehensive JavaDoc
- Maintain test coverage > 70%
- Follow RESTful conventions

### Commit Message Format
```
<type>: <subject>

<body>

<footer>
```

**Types:** feat, fix, docs, style, refactor, test, chore

---

## Testing

### Running Tests
```bash
mvn test
```

### Test Coverage
```bash
mvn clean test jacoco:report
```

**Current Coverage:** 0% (tests not yet implemented)

---

## Deployment

### Development Environment
```bash
./mvnw spring-boot:run
```

### Production Build
```bash
mvn clean package
java -jar target/marketplace-0.0.1-SNAPSHOT.jar
```

### Docker (Planned)
```bash
docker-compose up
```

For detailed deployment instructions, see [DEPLOYMENT.md](./DEPLOYMENT.md).

---

## Monitoring

### Health Check
- **Endpoint:** http://localhost:8081/actuator/health
- **Response:** `{"status":"UP"}`

### Metrics (Actuator)
- http://localhost:8081/actuator/info
- http://localhost:8081/actuator/metrics

---

## Documentation

- **[README.md](./README.md)** - This file (project overview)
- **[ARCHITECTURE.md](./ARCHITECTURE.md)** - System architecture and design patterns
- **[DATABASE.md](./DATABASE.md)** - Database schema and relationships
- **[API.md](./API.md)** - Complete API endpoint reference
- **[BUSINESS_RULES.md](./BUSINESS_RULES.md)** - Business logic and workflows
- **[DEVELOPMENT.md](./DEVELOPMENT.md)** - Development setup and guidelines
- **[DEPLOYMENT.md](./DEPLOYMENT.md)** - Deployment and production guide

---

## Known Issues

### Current Workarounds
1. **Store deposit validation disabled** (line 54-57 in SellerStoreServiceImpl)
   - Reason: Testing without wallet integration
   - TODO: Re-enable in production

2. **SELLER role assignment disabled** (line 90-95 in SellerStoreServiceImpl)
   - Reason: Prevents transaction rollback
   - TODO: Fix transaction management

3. **Fake user ID for testing** (SellerStoreController)
   - Fallback to user ID = 2 when auth not configured
   - TODO: Complete Spring Security setup

4. **File upload throws exception**
   - Implementation pending
   - TODO: Implement storage service

---

## Roadmap

### Phase 1: Foundation (Current)
- ✓ Database design
- ✓ User management
- ✓ Store management
- ⚙️ Security implementation

### Phase 2: Core Commerce (Next 2 months)
- Product CRUD
- Order processing
- Payment integration
- Escrow automation

### Phase 3: Engagement (Months 3-4)
- Review system
- Messaging
- Notifications
- Analytics dashboard

### Phase 4: Scale & Optimize (Months 5-6)
- Performance optimization
- Advanced search (Elasticsearch)
- Mobile app API
- Fraud detection (ML)

---

## Support & Contact

### Project Team
- **Group:** Group 3
- **Course:** SWP391 / SWE391
- **Institution:** FPT University
- **Semester:** FA25

### Resources
- **Project Repository:** [GitHub Link]
- **Issue Tracker:** [GitHub Issues]
- **Documentation:** `/docs` folder

---

## License

This project is developed as part of the SWP391/SWE391 course curriculum.

---

## Acknowledgments

- **Spring Boot Team** - Excellent framework and documentation
- **Bootstrap Team** - Responsive UI framework
- **FPT University** - Project guidance and support

---

**Last Updated:** January 2025
**Document Version:** 1.0.0
