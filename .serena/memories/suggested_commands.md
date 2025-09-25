# TaphoaMMO Marketplace - Suggested Commands

## Development Commands

### Build and Run
```bash
# Build the project
./mvnw clean compile

# Run the application
./mvnw spring-boot:run

# Build and run tests
./mvnw clean test

# Package the application
./mvnw clean package

# Run with specific profile
./mvnw spring-boot:run -Dspring-boot.run.profiles=dev
```

### Testing Commands
```bash
# Run all tests
./mvnw test

# Run specific test class
./mvnw test -Dtest=MarketplaceApplicationTests

# Run tests with coverage
./mvnw test jacoco:report

# Integration tests
./mvnw verify
```

### Database Commands
```bash
# Connect to MySQL (update credentials as needed)
mysql -u root -p -h localhost -P 3306

# Create database
mysql -u root -p < marketplace.sql

# Check database connection
./mvnw spring-boot:run -Dspring.datasource.url=jdbc:mysql://localhost:3306/mmo_market_system
```

### Development Utilities
```bash
# Clean target directory
./mvnw clean

# Dependency tree
./mvnw dependency:tree

# Check for updates
./mvnw versions:display-dependency-updates

# Format code (if formatter plugin added)
./mvnw spring-javaformat:apply
```

## Windows-Specific Commands

### File Operations
```cmd
# List files
dir
dir /s *.java

# Find files
where /r . *.properties
findstr /s /i "spring" *.xml

# Navigate directories
cd src\main\java
cd ..\..\..\

# Copy files
copy src\main\resources\application.properties application.backup.properties
```

### Git Commands
```bash
# Check status
git status

# Add changes
git add .
git add src/main/java/

# Commit changes
git commit -m "Add user entity implementation"

# Push changes
git push origin main

# Pull latest changes
git pull origin main

# Check branches
git branch -a
```

### Process Management
```cmd
# Find Java processes
tasklist | findstr java

# Kill process by PID
taskkill /PID <process_id> /F

# Check port usage
netstat -ano | findstr :8080
```

## IDE Integration Commands

### Maven in IDE
- Import as Maven project
- Refresh Maven dependencies
- Run configurations for Spring Boot
- Debug configurations with breakpoints

### Database Tools
- Connect to MySQL using IDE database tools
- Run SQL scripts from marketplace.sql
- View table structures and relationships
- Execute queries for testing

## Application URLs
- **Main Application**: http://localhost:8080
- **Actuator Health**: http://localhost:8080/actuator/health
- **Actuator Info**: http://localhost:8080/actuator/info