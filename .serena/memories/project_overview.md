# TaphoaMMO Marketplace - Project Overview

## Project Purpose
TaphoaMMO is a Vietnamese digital marketplace specializing in MMO (Make Money Online) services and products. The project aims to create a comprehensive marketplace for digital services including:
- Social media accounts (Facebook, Instagram, Twitter)
- Proxy services and VPN
- Email accounts (edu emails)
- Digital marketing tools
- Various MMO-related services

The platform is modeled after the real taphoammo.net website and implements key features like:
- Automated transaction system
- 3-day escrow protection
- Seller deposit requirements (5M VND minimum)
- Digital product storage and automated delivery
- Comprehensive review and rating system
- Real-time buyer-seller communication

## Current Development Status
The project is in **early development phase** (approximately 5% complete) with:
- Basic Spring Boot skeleton implemented
- Comprehensive database schema designed (15 tables)
- Detailed user stories created (20 stories, 238 story points)
- Basic UI framework with JSP templates
- Security temporarily disabled for development

## Key Business Logic
- Minimum seller deposit: 5,000,000 VND
- Maximum listing price = deposit_amount / 10
- 3-day escrow hold period for all transactions
- Automated digital product delivery system
- Role-based access control (buyer, seller, admin, moderator)
- Comprehensive audit trails for all operations