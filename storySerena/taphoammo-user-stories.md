# TaphoaMMO Marketplace User Stories

## Epic 1: User Authentication & Account Management

### US-001: User Registration
**As a** new visitor to TaphoaMMO
**I want** to create an account with username, email, and password
**So that** I can access the marketplace and start buying or selling digital products

**Acceptance Criteria:**
- User can register with unique username and email
- Password must meet security requirements
- Email verification is required before account activation
- User profile includes optional fields: phone, full_name, avatar_url, date_of_birth, gender
- Account status is set to 'active' by default
- System creates a wallet automatically upon registration

**Affected Files:**
- User registration controller
- User entity/model (users table)
- Wallet entity/model (wallets table)
- Email service

### US-002: User Login & Authentication
**As a** registered user
**I want** to log into my account securely
**So that** I can access my dashboard and perform marketplace activities

**Acceptance Criteria:**
- User can login with username/email and password
- System validates credentials against password_hash
- Account status checks: enabled, account_non_locked, account_non_expired, credentials_non_expired
- Failed login attempts are tracked for security
- Session management with appropriate timeout
- Remember me functionality available

**Affected Files:**
- Authentication controller
- Security configuration
- User service (users table)

### US-003: Role-Based Access Control
**As a** system administrator
**I want** to assign roles and permissions to users
**So that** I can control access to different features based on user type

**Acceptance Criteria:**
- Users can be assigned multiple roles (buyer, seller, admin, moderator)
- Roles have specific permissions (create_product, manage_orders, moderate_disputes)
- Permission checks are enforced at API and UI level
- Role assignments are auditable with created_by tracking
- Default role assignment for new users

**Affected Files:**
- Role management controller
- Permission service (roles, permissions, user_roles, role_permissions tables)
- Security interceptors

## Epic 2: Seller Store Management

### US-004: Create Seller Store
**As a** registered user
**I want** to create a seller store with required deposit
**So that** I can start selling digital products on the marketplace

**Acceptance Criteria:**
- User can create store with name and description
- Minimum deposit of 5,000,000 VND required for active status
- Maximum listing price calculated as deposit_amount / 10
- Store status defaults to 'active' when deposit requirement met
- Only one store per user allowed
- Store creation requires sufficient wallet balance

**Affected Files:**
- Seller store controller
- Store entity/model (seller_stores table)
- Wallet transaction service (wallets, wallet_transactions tables)
- Deposit validation service

### US-005: Manage Store Products
**As a** store owner
**I want** to add, edit, and manage my digital products
**So that** I can offer my services to potential buyers

**Acceptance Criteria:**
- Store owner can create products with name, description, price, category
- Product slug auto-generated from name (unique within store)
- Stock management for digital products
- Product status management (active, inactive, out_of_stock)
- Price cannot exceed store's max_listing_price
- Product categorization using predefined categories
- Bulk product operations available

**Affected Files:**
- Product controller
- Product entity/model (products table)
- Category service (categories table)
- File upload service

## Epic 3: Product Storage & Inventory

### US-006: Digital Product Storage
**As a** store owner
**I want** to upload and store digital product data securely
**So that** buyers receive their purchased items automatically

**Acceptance Criteria:**
- Product data stored as JSON payload in product_storage
- Sensitive data masked with payload_mask for security
- Support for various digital product types (accounts, keys, files)
- Automatic inventory tracking based on available storage items
- Reserved items have expiration time (reserved_until)
- Delivered items marked with delivered_at timestamp

**Affected Files:**
- Product storage controller
- Storage entity/model (product_storage table)
- JSON processing service
- Encryption service

### US-007: Automated Product Delivery
**As a** buyer
**I want** to receive my digital products automatically after payment
**So that** I can access my purchased items immediately

**Acceptance Criteria:**
- System automatically assigns available product_storage to orders
- Product data delivered to buyer upon payment confirmation
- Storage item status updated to 'delivered'
- Delivery notification sent to buyer
- Order includes snapshot of delivered product data
- Fallback mechanism for manual delivery if automation fails

**Affected Files:**
- Order processing service
- Product delivery service (orders, product_storage tables)
- Notification service (notifications table)
- Storage management service

## Epic 4: Order Management & Transactions

### US-008: Place Order
**As a** buyer
**I want** to purchase digital products using my wallet balance
**So that** I can acquire the services I need

**Acceptance Criteria:**
- Buyer can add products to cart and checkout
- Order total calculated including any fees
- Sufficient wallet balance required for purchase
- Order captures product details at time of purchase
- Automatic product assignment from available storage
- Order status tracking (pending, confirmed, delivered, completed)

**Affected Files:**
- Order controller
- Cart service
- Order entity/model (orders table)
- Wallet transaction service (wallets, wallet_transactions tables)

### US-009: Escrow System
**As a** marketplace participant
**I want** transactions to be held in escrow for 3 days
**So that** both buyers and sellers are protected from fraud

**Acceptance Criteria:**
- Payment held in escrow upon order creation
- Automatic release after 3 days (hold_until)
- Manual release possible for early completion
- Dispute mechanism during escrow period
- Escrow status tracking (held, released, disputed)
- Automatic seller payment upon release

**Affected Files:**
- Escrow service
- Escrow entity/model (escrow_transactions table)
- Payment processing service
- Scheduled task service

### US-010: Wallet Management
**As a** user
**I want** to manage my wallet balance and view transaction history
**So that** I can track my earnings and spending on the platform

**Acceptance Criteria:**
- Users can view current wallet balance
- Complete transaction history with type and amount
- Transaction types: deposit, withdrawal, purchase, sale, refund
- Reference to related orders where applicable
- Transaction notes for additional context
- Balance calculations are accurate and auditable

**Affected Files:**
- Wallet controller
- Wallet entity/model (wallets table)
- Transaction entity/model (wallet_transactions table)
- Payment gateway integration (payment_gateways table)

## Epic 5: Communication & Support

### US-011: Buyer-Seller Messaging
**As a** buyer or seller
**I want** to communicate with the other party
**So that** I can clarify product details or resolve issues

**Acceptance Criteria:**
- Direct messaging between buyers and sellers
- Conversation threads maintained per buyer-seller pair
- Message types: text, image, file attachments
- Read receipts and timestamps
- Message history preserved
- Notification system for new messages

**Affected Files:**
- Conversation controller
- Message entity/model (conversations, messages tables)
- Real-time messaging service
- File upload service

### US-012: Dispute Resolution
**As a** buyer or seller
**I want** to open disputes for problematic transactions
**So that** I can get help resolving issues with orders

**Acceptance Criteria:**
- Either party can open dispute during escrow period
- Dispute reasons categorized (product not as described, not delivered, etc.)
- Admin/moderator assignment for dispute resolution
- Evidence submission (messages, screenshots)
- Resolution tracking with notes
- Automatic escrow handling based on resolution

**Affected Files:**
- Dispute controller
- Dispute entity/model (disputes table)
- Admin panel integration
- Evidence management service

## Epic 6: Review & Rating System

### US-013: Product Reviews
**As a** buyer
**I want** to leave reviews and ratings for products I purchased
**So that** I can help other buyers make informed decisions

**Acceptance Criteria:**
- Buyers can review products after successful delivery
- Rating scale 1-5 stars with optional text review
- One review per order allowed
- Reviews visible to all users
- Review aggregation for product ratings
- Review moderation capabilities

**Affected Files:**
- Review controller
- Product review entity/model (product_reviews table)
- Rating calculation service
- Moderation service

### US-014: Seller Reviews
**As a** buyer
**I want** to rate sellers based on my experience
**So that** I can help others identify trustworthy sellers

**Acceptance Criteria:**
- Separate rating system for sellers/stores
- Rating based on communication, delivery speed, product quality
- Seller rating aggregation and display
- Review response capability for sellers
- Impact on seller store visibility and ranking

**Affected Files:**
- Seller review controller
- Seller review entity/model (seller_reviews table)
- Store ranking service
- Reputation system

## Epic 7: System Administration

### US-015: System Configuration
**As a** system administrator
**I want** to configure marketplace settings
**So that** I can control platform behavior and policies

**Acceptance Criteria:**
- Configurable settings stored in system_settings table
- Settings categories: payment, security, marketplace rules
- Settings validation and type checking
- Audit trail for setting changes
- Environment-specific configurations
- Hot-reload capability for non-critical settings

**Affected Files:**
- Admin settings controller
- System settings entity/model (system_settings table)
- Configuration service
- Settings validation service

## Epic 8: Notification System

### US-016: Real-time Notifications
**As a** user
**I want** to receive notifications about important events
**So that** I stay informed about my marketplace activities

**Acceptance Criteria:**
- Notifications for order status changes
- New message alerts
- Dispute updates and resolutions
- Payment confirmations and escrow releases
- System announcements and maintenance notices
- Email and in-app notification options
- Notification preferences management

**Affected Files:**
- Notification controller
- Notification entity/model (notifications table)
- Email service
- Real-time notification service
- User preference service

### US-017: Payment Gateway Integration
**As a** user
**I want** to deposit and withdraw funds using various payment methods
**So that** I can manage my wallet balance conveniently

**Acceptance Criteria:**
- Support for multiple payment gateways (bank transfer, e-wallets, cards)
- Secure payment processing with encryption
- Payment gateway configuration management
- Transaction fee calculation and display
- Payment status tracking and confirmation
- Refund processing capabilities

**Affected Files:**
- Payment controller
- Payment gateway service (payment_gateways table)
- Wallet transaction service
- Security service

## Epic 9: Advanced Features

### US-018: Category Management
**As a** system administrator
**I want** to manage product categories
**So that** products are properly organized for buyers

**Acceptance Criteria:**
- Create, edit, and delete product categories
- Category hierarchy support (parent-child relationships)
- Category-based product filtering and search
- Category statistics and analytics
- Bulk category operations
- Category SEO optimization

**Affected Files:**
- Category controller
- Category entity/model (categories table)
- Search service
- Analytics service

### US-019: Search and Filtering
**As a** buyer
**I want** to search and filter products effectively
**So that** I can find exactly what I need quickly

**Acceptance Criteria:**
- Full-text search across product names and descriptions
- Filter by category, price range, seller rating
- Sort by price, popularity, newest, rating
- Search suggestions and autocomplete
- Advanced search with multiple criteria
- Search result pagination and performance optimization

**Affected Files:**
- Search controller
- Search service
- Product indexing service
- Filter service

### US-020: Analytics and Reporting
**As a** store owner or administrator
**I want** to view detailed analytics and reports
**So that** I can make informed business decisions

**Acceptance Criteria:**
- Sales analytics with charts and graphs
- Product performance metrics
- Customer behavior analysis
- Revenue tracking and forecasting
- Export capabilities for reports
- Real-time dashboard updates

**Affected Files:**
- Analytics controller
- Reporting service
- Dashboard service
- Export service

**Reference Links:**
- https://taphoammo.net/ - Main marketplace platform
- https://www.similarweb.com/website/taphoammo.net/ - Traffic analytics
- https://www.scamadviser.com/check-website/taphoammo.net - Security assessment
