# Copilot Instructions for SWE391_Group3_Project

## Project Overview
This is a Spring Boot 3.5.5 web application for a marketplace system. It uses Java 17, Maven, JSP views, and MySQL for persistence. The codebase is organized by domain, controller, and configuration packages under `src/main/java/vn/group3/marketplace`.

## Architecture & Key Components
- **Spring Boot**: Main entry in `MarketplaceApplication.java`. Security auto-configuration is excluded for custom security setup.
- **MVC Pattern**: Controllers (e.g., `TestController`) map routes to JSP views in `src/main/webapp/WEB-INF/view`.
- **JSP/JSTL**: Views use JSP and JSTL, configured via `WebMvcConfig.java`.
- **Domain Model**: Entities extend `BaseEntity` for auditing and soft-delete (uses Hibernate filters and Spring Data annotations).
- **Persistence**: JPA/Hibernate with MySQL. Connection details in `application.properties`.

## Developer Workflows
- **Build**: Use Maven wrapper (`./mvnw clean package` on Unix, `mvnw.cmd clean package` on Windows).
- **Run**: `mvnw spring-boot:run` or run `MarketplaceApplication` from your IDE.
- **Test**: Run unit tests with `mvnw test`. Main test class: `MarketplaceApplicationTests.java`.
- **Debug**: Standard Spring Boot debugging applies. For JSP issues, check view resolver config in `WebMvcConfig.java`.

## Conventions & Patterns
- **View Mapping**: Controller methods return view names matching JSP files in `/WEB-INF/view/`.
- **Resource Handling**: Static resources (CSS) served from `/resources/css/` via `WebMvcConfig`.
- **Auditing**: All entities should extend `BaseEntity` for created/updated/deleted tracking.
- **Soft Delete**: Use `isDeleted` field and Hibernate filter for entity deletion logic.
- **Security**: Spring Security starter is included, but auto-config is disabled. Custom security must be implemented if needed.
- **Lombok**: Used for getters/setters in domain models.

## Integration Points
- **Database**: MySQL, configured in `application.properties`.
- **JSP/JSTL**: Jakarta dependencies for JSP and JSTL in `pom.xml`.
- **Actuator**: Spring Boot Actuator included for monitoring.

## Key Files & Directories
- `pom.xml`: Dependency management and build plugins.
- `src/main/java/vn/group3/marketplace/MarketplaceApplication.java`: Main entry point.
- `src/main/java/vn/group3/marketplace/config/WebMvcConfig.java`: MVC and view resolver config.
- `src/main/java/vn/group3/marketplace/domain/BaseEntity.java`: Auditing/soft-delete base class.
- `src/main/webapp/WEB-INF/view/`: JSP views.
- `src/main/resources/application.properties`: App configuration.

## Example Patterns
- **Controller to View**:
  ```java
  @GetMapping("/")
  public String getMethodName() {
      return "hello"; // maps to hello.jsp
  }
  ```
- **Entity Auditing**:
  ```java
  public abstract class BaseEntity {
      @CreatedDate
      private LocalDateTime createdAt;
      // ...
  }
  ```

---
_Review and update these instructions as the project evolves. If any conventions or workflows are unclear, provide feedback for improvement._
