# TaphoaMMO Marketplace - Business Requirements

## Core Business Model
TaphoaMMO is a Vietnamese digital marketplace for MMO (Make Money Online) services, modeled after the real taphoammo.net platform. The platform facilitates automated trading of digital products and services with built-in fraud protection.

## Key Business Rules

### Seller Requirements
- **Minimum Deposit**: 5,000,000 VND required for active seller status
- **Maximum Listing Price**: Calculated as deposit_amount / 10
- **Store Ownership**: One store per user maximum
- **Deposit Validation**: Must have sufficient wallet balance before store creation

### Product Management
- **Digital Products**: JSON-based storage for accounts, keys, files
- **Inventory Tracking**: Automated stock management via product_storage
- **Price Limits**: Product price cannot exceed store's max_listing_price
- **Categories**: Organized product categorization system

### Transaction System
- **Escrow Protection**: All payments held for 3 days
- **Automated Release**: Funds released automatically after 72 hours
- **Manual Release**: Early release possible for completed transactions
- **Dispute Mechanism**: Available during escrow period

### Digital Product Delivery
- **Automated Delivery**: Instant delivery upon payment confirmation
- **Secure Storage**: JSON payload with sensitive data masking
- **Inventory Updates**: Automatic stock reduction upon delivery
- **Delivery Confirmation**: Notification system for buyers

### Financial System
- **Wallet Management**: Internal balance system for all users
- **Transaction History**: Complete audit trail for all financial operations
- **Payment Gateways**: Multiple payment method support
- **Fee Structure**: Platform fees and transaction costs

## User Roles and Permissions

### Buyer Role
- Browse and search products
- Place orders and make payments
- Communicate with sellers
- Leave product and seller reviews
- Manage wallet and transaction history

### Seller Role
- Create and manage store (with deposit)
- Add and manage products
- Upload digital product inventory
- Process orders and communicate with buyers
- Manage earnings and withdrawals

### Admin Role
- Manage users and roles
- Configure system settings
- Handle disputes and moderation
- Monitor platform analytics
- Manage payment gateways

### Moderator Role
- Review and moderate content
- Handle customer support
- Assist with dispute resolution
- Monitor platform activity

## Product Categories
Based on taphoammo.net research:
- **Social Media Accounts**: Facebook, Instagram, Twitter, etc.
- **Email Services**: Educational emails, business emails
- **Proxy Services**: Vietnam, US, Europe proxies
- **Digital Marketing Tools**: SEO tools, automation software
- **Gaming Services**: Game accounts, in-game currency
- **Software Licenses**: Various software and tools

## Quality Assurance
- **Review System**: Separate reviews for products and sellers
- **Rating Aggregation**: Overall ratings for reputation building
- **Dispute Resolution**: Structured conflict resolution process
- **Fraud Prevention**: Escrow system and deposit requirements

## Communication Features
- **Direct Messaging**: Buyer-seller communication channels
- **Real-time Notifications**: Order updates, messages, system alerts
- **Email Integration**: Important notifications via email
- **Conversation History**: Persistent message storage

## Compliance and Security
- **Data Protection**: Secure handling of sensitive digital products
- **Audit Trails**: Complete tracking of all system operations
- **Role-Based Access**: Granular permission system
- **Financial Compliance**: Proper transaction recording and reporting

## Performance Requirements
- **Automated Processing**: Minimal manual intervention
- **Real-time Updates**: Instant inventory and status updates
- **Scalability**: Support for growing user base
- **Reliability**: High uptime for marketplace operations

## Success Metrics
- **Transaction Volume**: Total value of completed transactions
- **User Retention**: Active buyer and seller engagement
- **Dispute Rate**: Low percentage of disputed transactions
- **Delivery Success**: High rate of successful automated deliveries
- **Platform Revenue**: Commission and fee generation