# TaphoaMMO Marketplace - Technology Stack

## Core Technologies
- **Java 17**: Long-term support version
- **Spring Boot 3.5.5**: Latest stable version with comprehensive ecosystem
- **Spring Framework**: Web MVC, Data JPA, Security (currently disabled), Actuator
- **Maven**: Build and dependency management
- **MySQL**: Primary database with comprehensive schema (15 tables)
- **Hibernate/JPA**: ORM for database operations

## Frontend Technologies
- **JSP (JavaServer Pages)**: Server-side rendering
- **JSTL 3.0**: JSP Standard Tag Library
- **HTML/CSS/JavaScript**: Standard web technologies
- **Bootstrap-style UI**: Custom CSS framework for responsive design

## Development Tools
- **Lombok 1.18.32**: Reduces boilerplate code with annotations
- **Spring Boot DevTools**: Hot reload and development utilities
- **Maven Wrapper**: Ensures consistent Maven version across environments
- **Tomcat Embedded**: Application server (via Spring Boot)

## Database Schema
Comprehensive MySQL schema with 15 core tables:
- User management (users, roles, permissions, user_roles, role_permissions)
- Marketplace core (seller_stores, products, product_storage, categories)
- Transaction system (orders, wallets, wallet_transactions, escrow_transactions)
- Communication (conversations, messages, notifications)
- Review system (product_reviews, seller_reviews)
- Support (disputes, payment_gateways, system_settings)

## Architecture Pattern
- **MVC Pattern**: Model-View-Controller architecture
- **Repository Pattern**: Data access abstraction
- **Service Layer**: Business logic encapsulation
- **Entity-Based Design**: JPA entities with audit trails
- **Soft Delete Pattern**: Logical deletion with is_deleted flag