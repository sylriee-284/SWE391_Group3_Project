-- ============================================
-- FAKE DATA FOR MMO MARKET SYSTEM DATABASE
-- ============================================
USE `mmo_market_system`;

-- Disable foreign key checks for data insertion
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================
-- DELETE EXISTING DATA (in correct order due to foreign keys)
-- ============================================
DELETE FROM `role_permissions`;
DELETE FROM `user_roles`;
DELETE FROM `wallet_transactions`;
DELETE FROM `wallets`;
DELETE FROM `categories`;
DELETE FROM `permissions`;
DELETE FROM `roles`;
DELETE FROM `users`;

-- Reset AUTO_INCREMENT
ALTER TABLE `users` AUTO_INCREMENT = 1;
ALTER TABLE `roles` AUTO_INCREMENT = 1;
ALTER TABLE `permissions` AUTO_INCREMENT = 1;
ALTER TABLE `wallets` AUTO_INCREMENT = 1;
ALTER TABLE `categories` AUTO_INCREMENT = 1;

-- ============================================
-- 1. INSERT USERS
-- ============================================
-- Password hash for 'password123' (bcrypt): $2a$10$xGlLZ3rKPrMEw8DqOhvLleEzd7qYJ.nqVHrQz9QYqk9kGIg6ZPqJG
INSERT INTO `users` (`id`, `username`, `email`, `password_hash`, `phone`, `full_name`, `avatar_url`, `date_of_birth`, `gender`, `status`, `enabled`, `account_non_locked`, `account_non_expired`, `credentials_non_expired`, `created_at`, `is_deleted`) VALUES
(1, 'admin', 'admin@marketplace.com', '$2a$10$xGlLZ3rKPrMEw8DqOhvLleEzd7qYJ.nqVHrQz9QYqk9kGIg6ZPqJG', '0901234567', 'System Administrator', 'https://i.pravatar.cc/150?img=1', '1990-01-01', 'male', 'active', 1, 1, 1, 1, NOW(), 0),
(2, 'seller01', 'seller01@gmail.com', '$2a$10$xGlLZ3rKPrMEw8DqOhvLleEzd7qYJ.nqVHrQz9QYqk9kGIg6ZPqJG', '0901234568', 'Nguyễn Văn A', 'https://i.pravatar.cc/150?img=11', '1995-03-15', 'male', 'active', 1, 1, 1, 1, NOW(), 0),
(3, 'seller02', 'seller02@gmail.com', '$2a$10$xGlLZ3rKPrMEw8DqOhvLleEzd7qYJ.nqVHrQz9QYqk9kGIg6ZPqJG', '0901234569', 'Trần Thị B', 'https://i.pravatar.cc/150?img=25', '1992-07-20', 'female', 'active', 1, 1, 1, 1, NOW(), 0),
(4, 'seller03', 'seller03@gmail.com', '$2a$10$xGlLZ3rKPrMEw8DqOhvLleEzd7qYJ.nqVHrQz9QYqk9kGIg6ZPqJG', '0901234570', 'Lê Văn C', 'https://i.pravatar.cc/150?img=33', '1988-11-30', 'male', 'active', 1, 1, 1, 1, NOW(), 0),
(5, 'buyer01', 'buyer01@gmail.com', '$2a$10$xGlLZ3rKPrMEw8DqOhvLleEzd7qYJ.nqVHrQz9QYqk9kGIg6ZPqJG', '0901234571', 'Phạm Thị D', 'https://i.pravatar.cc/150?img=41', '1998-05-10', 'female', 'active', 1, 1, 1, 1, NOW(), 0),
(6, 'buyer02', 'buyer02@gmail.com', '$2a$10$xGlLZ3rKPrMEw8DqOhvLleEzd7qYJ.nqVHrQz9QYqk9kGIg6ZPqJG', '0901234572', 'Hoàng Văn E', 'https://i.pravatar.cc/150?img=52', '1996-09-25', 'male', 'active', 1, 1, 1, 1, NOW(), 0),
(7, 'buyer03', 'buyer03@gmail.com', '$2a$10$xGlLZ3rKPrMEw8DqOhvLleEzd7qYJ.nqVHrQz9QYqk9kGIg6ZPqJG', '0901234573', 'Vũ Thị F', 'https://i.pravatar.cc/150?img=26', '1999-12-05', 'female', 'active', 1, 1, 1, 1, NOW(), 0),
(8, 'buyer04', 'buyer04@gmail.com', '$2a$10$xGlLZ3rKPrMEw8DqOhvLleEzd7qYJ.nqVHrQz9QYqk9kGIg6ZPqJG', '0901234574', 'Đỗ Văn G', 'https://i.pravatar.cc/150?img=60', '1994-02-14', 'male', 'active', 1, 1, 1, 1, NOW(), 0),
(9, 'moderator01', 'moderator01@marketplace.com', '$2a$10$xGlLZ3rKPrMEw8DqOhvLleEzd7qYJ.nqVHrQz9QYqk9kGIg6ZPqJG', '0901234575', 'Ngô Thị H', 'https://i.pravatar.cc/150?img=28', '1991-06-18', 'female', 'active', 1, 1, 1, 1, NOW(), 0),
(10, 'seller04', 'seller04@gmail.com', '$2a$10$xGlLZ3rKPrMEw8DqOhvLleEzd7qYJ.nqVHrQz9QYqk9kGIg6ZPqJG', '0901234576', 'Bùi Văn I', 'https://i.pravatar.cc/150?img=68', '1993-08-22', 'male', 'active', 1, 1, 1, 1, NOW(), 0),
(11, 'buyer05', 'buyer05@gmail.com', '$2a$10$xGlLZ3rKPrMEw8DqOhvLleEzd7qYJ.nqVHrQz9QYqk9kGIg6ZPqJG', '0901234577', 'Đinh Thị K', 'https://i.pravatar.cc/150?img=32', '1997-04-08', 'female', 'active', 1, 1, 1, 1, NOW(), 0),
(12, 'seller05', 'seller05@gmail.com', '$2a$10$xGlLZ3rKPrMEw8DqOhvLleEzd7qYJ.nqVHrQz9QYqk9kGIg6ZPqJG', '0901234578', 'Dương Văn L', 'https://i.pravatar.cc/150?img=15', '1989-10-12', 'male', 'active', 1, 1, 1, 1, NOW(), 0),
(13, 'buyer06', 'buyer06@gmail.com', '$2a$10$xGlLZ3rKPrMEw8DqOhvLleEzd7qYJ.nqVHrQz9QYqk9kGIg6ZPqJG', '0901234579', 'Lý Thị M', 'https://i.pravatar.cc/150?img=44', '2000-01-28', 'female', 'active', 1, 1, 1, 1, NOW(), 0),
(14, 'inactive_user', 'inactive@gmail.com', '$2a$10$xGlLZ3rKPrMEw8DqOhvLleEzd7qYJ.nqVHrQz9QYqk9kGIg6ZPqJG', '0901234580', 'Inactive User', NULL, '1995-05-05', 'male', 'inactive', 0, 1, 1, 1, NOW(), 0),
(15, 'locked_user', 'locked@gmail.com', '$2a$10$xGlLZ3rKPrMEw8DqOhvLleEzd7qYJ.nqVHrQz9QYqk9kGIg6ZPqJG', '0901234581', 'Locked User', NULL, '1996-06-06', 'female', 'active', 1, 0, 1, 1, NOW(), 0);

-- ============================================
-- 2. INSERT ROLES
-- ============================================
INSERT INTO `roles` (`id`, `code`, `name`, `description`, `created_at`, `created_by`, `is_deleted`) VALUES
(1, 'ROLE_ADMIN', 'Administrator', 'Full system access and management', NOW(), 1, 0),
(2, 'ROLE_MODERATOR', 'Moderator', 'Content moderation and user management', NOW(), 1, 0),
(3, 'ROLE_SELLER', 'Seller', 'Can create stores and sell products', NOW(), 1, 0),
(4, 'ROLE_BUYER', 'Buyer', 'Can purchase products', NOW(), 1, 0),
(5, 'ROLE_USER', 'User', 'Basic user role', NOW(), 1, 0);

-- ============================================
-- 3. INSERT PERMISSIONS
-- ============================================
INSERT INTO `permissions` (`id`, `code`, `name`, `description`, `created_at`, `created_by`, `is_deleted`) VALUES
-- User Management
(1, 'USER_VIEW', 'View Users', 'View user information', NOW(), 1, 0),
(2, 'USER_CREATE', 'Create Users', 'Create new users', NOW(), 1, 0),
(3, 'USER_UPDATE', 'Update Users', 'Update user information', NOW(), 1, 0),
(4, 'USER_DELETE', 'Delete Users', 'Delete users', NOW(), 1, 0),

-- Store Management
(5, 'STORE_VIEW', 'View Stores', 'View store information', NOW(), 1, 0),
(6, 'STORE_CREATE', 'Create Stores', 'Create new stores', NOW(), 1, 0),
(7, 'STORE_UPDATE', 'Update Stores', 'Update store information', NOW(), 1, 0),
(8, 'STORE_DELETE', 'Delete Stores', 'Delete stores', NOW(), 1, 0),

-- Product Management
(9, 'PRODUCT_VIEW', 'View Products', 'View product information', NOW(), 1, 0),
(10, 'PRODUCT_CREATE', 'Create Products', 'Create new products', NOW(), 1, 0),
(11, 'PRODUCT_UPDATE', 'Update Products', 'Update product information', NOW(), 1, 0),
(12, 'PRODUCT_DELETE', 'Delete Products', 'Delete products', NOW(), 1, 0),

-- Order Management
(13, 'ORDER_VIEW', 'View Orders', 'View order information', NOW(), 1, 0),
(14, 'ORDER_CREATE', 'Create Orders', 'Create new orders', NOW(), 1, 0),
(15, 'ORDER_UPDATE', 'Update Orders', 'Update order status', NOW(), 1, 0),
(16, 'ORDER_DELETE', 'Delete Orders', 'Delete orders', NOW(), 1, 0),

-- Wallet Management
(17, 'WALLET_VIEW', 'View Wallet', 'View wallet information', NOW(), 1, 0),
(18, 'WALLET_DEPOSIT', 'Deposit to Wallet', 'Add funds to wallet', NOW(), 1, 0),
(19, 'WALLET_WITHDRAW', 'Withdraw from Wallet', 'Withdraw funds from wallet', NOW(), 1, 0),

-- Review Management
(20, 'REVIEW_VIEW', 'View Reviews', 'View reviews', NOW(), 1, 0),
(21, 'REVIEW_CREATE', 'Create Reviews', 'Create reviews', NOW(), 1, 0),
(22, 'REVIEW_DELETE', 'Delete Reviews', 'Delete reviews', NOW(), 1, 0),

-- Dispute Management
(23, 'DISPUTE_VIEW', 'View Disputes', 'View dispute information', NOW(), 1, 0),
(24, 'DISPUTE_CREATE', 'Create Disputes', 'Create new disputes', NOW(), 1, 0),
(25, 'DISPUTE_RESOLVE', 'Resolve Disputes', 'Resolve disputes', NOW(), 1, 0),

-- System Management
(26, 'SYSTEM_SETTINGS', 'System Settings', 'Manage system settings', NOW(), 1, 0),
(27, 'SYSTEM_REPORTS', 'System Reports', 'View system reports', NOW(), 1, 0);

-- ============================================
-- 4. INSERT USER_ROLES
-- ============================================
INSERT INTO `user_roles` (`user_id`, `role_id`, `created_at`, `created_by`) VALUES
-- Admin
(1, 1, NOW(), 1),
(1, 5, NOW(), 1),

-- Moderator
(9, 2, NOW(), 1),
(9, 5, NOW(), 1),

-- Sellers
(2, 3, NOW(), 1),
(2, 4, NOW(), 1),
(2, 5, NOW(), 1),

(3, 3, NOW(), 1),
(3, 4, NOW(), 1),
(3, 5, NOW(), 1),

(4, 3, NOW(), 1),
(4, 4, NOW(), 1),
(4, 5, NOW(), 1),

(10, 3, NOW(), 1),
(10, 4, NOW(), 1),
(10, 5, NOW(), 1),

(12, 3, NOW(), 1),
(12, 4, NOW(), 1),
(12, 5, NOW(), 1),

-- Buyers
(5, 4, NOW(), 1),
(5, 5, NOW(), 1),

(6, 4, NOW(), 1),
(6, 5, NOW(), 1),

(7, 4, NOW(), 1),
(7, 5, NOW(), 1),

(8, 4, NOW(), 1),
(8, 5, NOW(), 1),

(11, 4, NOW(), 1),
(11, 5, NOW(), 1),

(13, 4, NOW(), 1),
(13, 5, NOW(), 1),

-- Inactive/Locked users
(14, 5, NOW(), 1),
(15, 5, NOW(), 1);

-- ============================================
-- 5. INSERT ROLE_PERMISSIONS
-- ============================================
-- ROLE_ADMIN - All permissions
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`, `created_by`)
SELECT 1, `id`, NOW(), 1 FROM `permissions`;

-- ROLE_MODERATOR
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`, `created_by`) VALUES
(2, 1, NOW(), 1),  -- USER_VIEW
(2, 3, NOW(), 1),  -- USER_UPDATE
(2, 5, NOW(), 1),  -- STORE_VIEW
(2, 7, NOW(), 1),  -- STORE_UPDATE
(2, 9, NOW(), 1),  -- PRODUCT_VIEW
(2, 11, NOW(), 1), -- PRODUCT_UPDATE
(2, 13, NOW(), 1), -- ORDER_VIEW
(2, 20, NOW(), 1), -- REVIEW_VIEW
(2, 22, NOW(), 1), -- REVIEW_DELETE
(2, 23, NOW(), 1), -- DISPUTE_VIEW
(2, 25, NOW(), 1); -- DISPUTE_RESOLVE

-- ROLE_SELLER
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`, `created_by`) VALUES
(3, 5, NOW(), 1),  -- STORE_VIEW
(3, 6, NOW(), 1),  -- STORE_CREATE
(3, 7, NOW(), 1),  -- STORE_UPDATE
(3, 9, NOW(), 1),  -- PRODUCT_VIEW
(3, 10, NOW(), 1), -- PRODUCT_CREATE
(3, 11, NOW(), 1), -- PRODUCT_UPDATE
(3, 12, NOW(), 1), -- PRODUCT_DELETE
(3, 13, NOW(), 1), -- ORDER_VIEW
(3, 15, NOW(), 1), -- ORDER_UPDATE
(3, 17, NOW(), 1), -- WALLET_VIEW
(3, 18, NOW(), 1), -- WALLET_DEPOSIT
(3, 19, NOW(), 1), -- WALLET_WITHDRAW
(3, 20, NOW(), 1), -- REVIEW_VIEW
(3, 23, NOW(), 1); -- DISPUTE_VIEW

-- ROLE_BUYER
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`, `created_by`) VALUES
(4, 5, NOW(), 1),  -- STORE_VIEW
(4, 9, NOW(), 1),  -- PRODUCT_VIEW
(4, 13, NOW(), 1), -- ORDER_VIEW
(4, 14, NOW(), 1), -- ORDER_CREATE
(4, 17, NOW(), 1), -- WALLET_VIEW
(4, 18, NOW(), 1), -- WALLET_DEPOSIT
(4, 19, NOW(), 1), -- WALLET_WITHDRAW
(4, 20, NOW(), 1), -- REVIEW_VIEW
(4, 21, NOW(), 1), -- REVIEW_CREATE
(4, 23, NOW(), 1), -- DISPUTE_VIEW
(4, 24, NOW(), 1); -- DISPUTE_CREATE

-- ROLE_USER (Basic permissions)
INSERT INTO `role_permissions` (`role_id`, `permission_id`, `created_at`, `created_by`) VALUES
(5, 5, NOW(), 1),  -- STORE_VIEW
(5, 9, NOW(), 1),  -- PRODUCT_VIEW
(5, 17, NOW(), 1), -- WALLET_VIEW
(5, 20, NOW(), 1); -- REVIEW_VIEW

-- ============================================
-- 6. INSERT WALLETS
-- ============================================
INSERT INTO `wallets` (`id`, `user_id`, `balance`, `created_at`, `created_by`, `is_deleted`) VALUES
(1, 1, 100000000.00, NOW(), 1, 0),  -- Admin: 100,000,000 VND
(2, 2, 25000000.00, NOW(), 1, 0),   -- Seller01: 25,000,000 VND
(3, 3, 18500000.00, NOW(), 1, 0),   -- Seller02: 18,500,000 VND
(4, 4, 32000000.00, NOW(), 1, 0),   -- Seller03: 32,000,000 VND
(5, 5, 5000000.00, NOW(), 1, 0),    -- Buyer01: 5,000,000 VND
(6, 6, 8200000.00, NOW(), 1, 0),    -- Buyer02: 8,200,000 VND
(7, 7, 3500000.00, NOW(), 1, 0),    -- Buyer03: 3,500,000 VND
(8, 8, 12000000.00, NOW(), 1, 0),   -- Buyer04: 12,000,000 VND
(9, 9, 10000000.00, NOW(), 1, 0),   -- Moderator01: 10,000,000 VND
(10, 10, 15000000.00, NOW(), 1, 0), -- Seller04: 15,000,000 VND
(11, 11, 6500000.00, NOW(), 1, 0),  -- Buyer05: 6,500,000 VND
(12, 12, 22000000.00, NOW(), 1, 0), -- Seller05: 22,000,000 VND
(13, 13, 4000000.00, NOW(), 1, 0),  -- Buyer06: 4,000,000 VND
(14, 14, 0.00, NOW(), 1, 0),        -- Inactive user: 0 VND
(15, 15, 0.00, NOW(), 1, 0);        -- Locked user: 0 VND

-- ============================================
-- 7. INSERT CATEGORIES
-- ============================================
INSERT INTO `categories` (`id`, `name`, `created_at`, `created_by`, `is_deleted`) VALUES
(1, 'Game Accounts', NOW(), 1, 0),
(2, 'Social Media Accounts', NOW(), 1, 0),
(3, 'Game Items & Currency', NOW(), 1, 0),
(4, 'Premium Subscriptions', NOW(), 1, 0),
(5, 'Software Licenses', NOW(), 1, 0),
(6, 'Digital Assets', NOW(), 1, 0),
(7, 'VPN & Proxy Services', NOW(), 1, 0),
(8, 'Streaming Accounts', NOW(), 1, 0),
(9, 'Gift Cards & Vouchers', NOW(), 1, 0),
(10, 'Other Services', NOW(), 1, 0);

-- Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;

-- ============================================
-- VERIFICATION QUERIES
-- ============================================
-- Uncomment to verify data insertion

-- SELECT COUNT(*) as total_users FROM users;
-- SELECT COUNT(*) as total_roles FROM roles;
-- SELECT COUNT(*) as total_permissions FROM permissions;
-- SELECT COUNT(*) as total_user_roles FROM user_roles;
-- SELECT COUNT(*) as total_role_permissions FROM role_permissions;
-- SELECT COUNT(*) as total_wallets FROM wallets;
-- SELECT COUNT(*) as total_categories FROM categories;

-- Show users with their roles
-- SELECT u.username, u.email, u.full_name, GROUP_CONCAT(r.name) as roles
-- FROM users u
-- LEFT JOIN user_roles ur ON u.id = ur.user_id
-- LEFT JOIN roles r ON ur.role_id = r.id
-- GROUP BY u.id;

-- Show wallet balances
-- SELECT u.username, u.full_name, w.balance
-- FROM users u
-- INNER JOIN wallets w ON u.id = w.user_id
-- ORDER BY w.balance DESC;
