DROP DATABASE IF EXISTS `mmo_market_system`;
CREATE DATABASE `mmo_market_system`
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE `mmo_market_system`;

CREATE TABLE `users` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
  `username` VARCHAR(50) NOT NULL UNIQUE,
  `email` VARCHAR(255) NOT NULL UNIQUE,
  `password_hash` VARCHAR(255) NOT NULL,
  `phone` VARCHAR(20),
  `full_name` VARCHAR(255),
  `avatar_url` VARCHAR(500),
  `date_of_birth` DATE,
  `gender` VARCHAR(20),
  `status` VARCHAR(20) DEFAULT 'active',
  `enabled` TINYINT(1) NOT NULL DEFAULT 1,
  `account_non_locked` TINYINT(1) NOT NULL DEFAULT 1,
  `account_non_expired` TINYINT(1) NOT NULL DEFAULT 1,
  `credentials_non_expired` TINYINT(1) NOT NULL DEFAULT 1,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` BIGINT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_by` BIGINT NULL,
  `is_deleted` TINYINT(1) NOT NULL DEFAULT 0,
  KEY `idx_users_created_by` (`created_by`),
  KEY `idx_users_deleted_by` (`deleted_by`),
  CONSTRAINT `fk_users_created_by` FOREIGN KEY (`created_by`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_users_deleted_by` FOREIGN KEY (`deleted_by`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE `roles` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
  `code` VARCHAR(80) NOT NULL UNIQUE,
  `name` VARCHAR(255) NOT NULL,
  `description` VARCHAR(500),
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` BIGINT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_by` BIGINT NULL,
  `is_deleted` TINYINT(1) NOT NULL DEFAULT 0,
  KEY `idx_roles_created_by` (`created_by`),
  KEY `idx_roles_deleted_by` (`deleted_by`),
  CONSTRAINT `fk_roles_created_by` FOREIGN KEY (`created_by`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_roles_deleted_by` FOREIGN KEY (`deleted_by`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE `permissions` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
  `code` VARCHAR(100) NOT NULL UNIQUE,
  `name` VARCHAR(255) NOT NULL,
  `description` VARCHAR(500),
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` BIGINT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_by` BIGINT NULL,
  `is_deleted` TINYINT(1) NOT NULL DEFAULT 0,
  KEY `idx_perms_created_by` (`created_by`),
  KEY `idx_perms_deleted_by` (`deleted_by`),
  CONSTRAINT `fk_perms_created_by` FOREIGN KEY (`created_by`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_perms_deleted_by` FOREIGN KEY (`deleted_by`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE `user_roles` (
  `user_id` BIGINT NOT NULL,
  `role_id` BIGINT NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` BIGINT NULL,
  PRIMARY KEY (`user_id`,`role_id`),
  KEY `idx_ur_role` (`role_id`),
  KEY `idx_ur_created_by` (`created_by`),
  CONSTRAINT `fk_ur_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_ur_role` FOREIGN KEY (`role_id`) REFERENCES `roles`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_ur_created_by` FOREIGN KEY (`created_by`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE `role_permissions` (
  `role_id` BIGINT NOT NULL,
  `permission_id` BIGINT NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` BIGINT NULL,
  PRIMARY KEY (`role_id`,`permission_id`),
  KEY `idx_rp_perm` (`permission_id`),
  KEY `idx_rp_created_by` (`created_by`),
  CONSTRAINT `fk_rp_role` FOREIGN KEY (`role_id`) REFERENCES `roles`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_rp_perm` FOREIGN KEY (`permission_id`) REFERENCES `permissions`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_rp_created_by` FOREIGN KEY (`created_by`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE `categories` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` BIGINT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_by` BIGINT NULL,
  `is_deleted` TINYINT(1) NOT NULL DEFAULT 0,
  UNIQUE KEY `uq_categories_name` (`name`),
  KEY `idx_categories_created_by` (`created_by`),
  KEY `idx_categories_deleted_by` (`deleted_by`),
  CONSTRAINT `fk_categories_created_by` FOREIGN KEY (`created_by`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_categories_deleted_by` FOREIGN KEY (`deleted_by`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE `seller_stores` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
  `owner_user_id` BIGINT NOT NULL,
  `store_name` VARCHAR(255) NOT NULL,
  `description` TEXT,
  `status` VARCHAR(20) DEFAULT 'active',
  `deposit_amount` DECIMAL(18,2) NOT NULL DEFAULT 0.00,
  `max_listing_price` DECIMAL(18,2)
      GENERATED ALWAYS AS (ROUND(`deposit_amount` / 10, 2)) STORED,
  `deposit_currency` CHAR(3) NOT NULL DEFAULT 'VND',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` BIGINT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_by` BIGINT NULL,
  `is_deleted` TINYINT(1) NOT NULL DEFAULT 0,
  KEY `idx_seller_stores_owner` (`owner_user_id`),
  KEY `idx_seller_stores_created_by` (`created_by`),
  KEY `idx_seller_stores_deleted_by` (`deleted_by`),
  CONSTRAINT `fk_seller_stores_owner` FOREIGN KEY (`owner_user_id`) REFERENCES `users`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_seller_stores_created_by` FOREIGN KEY (`created_by`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_seller_stores_deleted_by` FOREIGN KEY (`deleted_by`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  CONSTRAINT `chk_store_min_deposit` CHECK ((`status` <> 'active') OR (`deposit_amount` >= 5000000))
) ENGINE=InnoDB;

CREATE TABLE `products` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
  `seller_store_id` BIGINT NOT NULL,
  `category_id` BIGINT NULL,
  `name` VARCHAR(255) NOT NULL,
  `slug` VARCHAR(300),
  `description` TEXT,
  `price` DECIMAL(15,2) NOT NULL,
  `stock` INT NOT NULL DEFAULT 0,
  `status` VARCHAR(20) DEFAULT 'active',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` BIGINT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_by` BIGINT NULL,
  `is_deleted` TINYINT(1) NOT NULL DEFAULT 0,
  UNIQUE KEY `uniq_store_slug` (`seller_store_id`,`slug`),
  KEY `idx_products_store` (`seller_store_id`),
  KEY `idx_products_category` (`category_id`),
  KEY `idx_products_created_by` (`created_by`),
  KEY `idx_products_deleted_by` (`deleted_by`),
  CONSTRAINT `fk_products_store` FOREIGN KEY (`seller_store_id`) REFERENCES `seller_stores`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_products_category` FOREIGN KEY (`category_id`) REFERENCES `categories`(`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_products_created_by` FOREIGN KEY (`created_by`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_products_deleted_by` FOREIGN KEY (`deleted_by`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE `product_storage` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
  `product_id` BIGINT NOT NULL,
  `status` VARCHAR(20) NOT NULL DEFAULT 'available',
  `payload_json` JSON NOT NULL,
  `payload_mask` VARCHAR(255) NULL,
  `reserved_until` DATETIME NULL,
  `delivered_at` DATETIME NULL,
  `note` VARCHAR(255) NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` BIGINT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_by` BIGINT NULL,
  `is_deleted` TINYINT(1) NOT NULL DEFAULT 0,
  KEY `idx_storage_product_status` (`product_id`,`status`),
  KEY `idx_storage_reserved_until` (`reserved_until`),
  KEY `idx_storage_created_by` (`created_by`),
  KEY `idx_storage_deleted_by` (`deleted_by`),
  CONSTRAINT `fk_storage_product` FOREIGN KEY (`product_id`) REFERENCES `products`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_storage_created_by` FOREIGN KEY (`created_by`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_storage_deleted_by` FOREIGN KEY (`deleted_by`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE `orders` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
  `buyer_user_id` BIGINT NOT NULL,
  `seller_store_id` BIGINT NOT NULL,
  `product_id` BIGINT NOT NULL,
  `product_storage_id` BIGINT NULL,
  `product_name` VARCHAR(255) NOT NULL,
  `product_price` DECIMAL(15,2) NOT NULL,
  `quantity` INT NOT NULL DEFAULT 1,
  `product_data` JSON NULL,
  `status` VARCHAR(20) DEFAULT 'pending',
  `total_amount` DECIMAL(18,2) NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` BIGINT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_by` BIGINT NULL,
  `is_deleted` TINYINT(1) NOT NULL DEFAULT 0,
  UNIQUE KEY `uniq_orders_storage` (`product_storage_id`),
  KEY `idx_orders_buyer` (`buyer_user_id`),
  KEY `idx_orders_store` (`seller_store_id`),
  KEY `idx_orders_product` (`product_id`),
  KEY `idx_orders_created_by` (`created_by`),
  KEY `idx_orders_deleted_by` (`deleted_by`),
  CONSTRAINT `fk_orders_buyer` FOREIGN KEY (`buyer_user_id`) REFERENCES `users`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_orders_store` FOREIGN KEY (`seller_store_id`) REFERENCES `seller_stores`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_orders_product` FOREIGN KEY (`product_id`) REFERENCES `products`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_orders_storage` FOREIGN KEY (`product_storage_id`) REFERENCES `product_storage`(`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_orders_created_by` FOREIGN KEY (`created_by`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_orders_deleted_by` FOREIGN KEY (`deleted_by`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE `wallets` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
  `user_id` BIGINT NOT NULL UNIQUE,
  `balance` DECIMAL(18,2) NOT NULL DEFAULT 0.00,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` BIGINT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_by` BIGINT NULL,
  `is_deleted` TINYINT(1) NOT NULL DEFAULT 0,
  KEY `idx_wallets_user` (`user_id`),
  KEY `idx_wallets_created_by` (`created_by`),
  KEY `idx_wallets_deleted_by` (`deleted_by`),
  CONSTRAINT `fk_wallets_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_wallets_created_by` FOREIGN KEY (`created_by`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_wallets_deleted_by` FOREIGN KEY (`deleted_by`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE `wallet_transactions` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
  `wallet_id` BIGINT NOT NULL,
  `type` VARCHAR(20) NOT NULL,
  `amount` DECIMAL(18,2) NOT NULL,
  `ref_order_id` BIGINT NULL,
  `note` VARCHAR(500),
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` BIGINT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_by` BIGINT NULL,
  `is_deleted` TINYINT(1) NOT NULL DEFAULT 0,
  KEY `idx_wallet_tx_wallet` (`wallet_id`),
  KEY `idx_wallet_tx_order` (`ref_order_id`),
  KEY `idx_wallet_tx_created_by` (`created_by`),
  KEY `idx_wallet_tx_deleted_by` (`deleted_by`),
  CONSTRAINT `fk_wallet_tx_wallet` FOREIGN KEY (`wallet_id`) REFERENCES `wallets`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_wallet_tx_order` FOREIGN KEY (`ref_order_id`) REFERENCES `orders`(`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_wallet_tx_created_by` FOREIGN KEY (`created_by`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_wallet_tx_deleted_by` FOREIGN KEY (`deleted_by`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE `escrow_transactions` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
  `order_id` BIGINT NOT NULL,
  `amount` DECIMAL(18,2) NOT NULL,
  `status` VARCHAR(20) NOT NULL DEFAULT 'held',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `hold_until` DATETIME GENERATED ALWAYS AS (DATE_ADD(`created_at`, INTERVAL 3 DAY)) STORED,
  `released_at` DATETIME NULL,
  `created_by` BIGINT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_by` BIGINT NULL,
  `is_deleted` TINYINT(1) NOT NULL DEFAULT 0,
  UNIQUE KEY `uniq_escrow_order` (`order_id`),
  KEY `idx_escrow_created_by` (`created_by`),
  KEY `idx_escrow_deleted_by` (`deleted_by`),
  CONSTRAINT `fk_escrow_order` FOREIGN KEY (`order_id`) REFERENCES `orders`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_escrow_created_by` FOREIGN KEY (`created_by`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_escrow_deleted_by` FOREIGN KEY (`deleted_by`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE `product_reviews` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
  `order_id` BIGINT NOT NULL,
  `product_id` BIGINT NOT NULL,
  `reviewer_user_id` BIGINT NOT NULL,
  `rating` TINYINT NOT NULL,
  `content` TEXT,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` BIGINT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_by` BIGINT NULL,
  `is_deleted` TINYINT(1) NOT NULL DEFAULT 0,
  KEY `idx_pr_order` (`order_id`),
  KEY `idx_pr_product` (`product_id`),
  KEY `idx_pr_reviewer` (`reviewer_user_id`),
  KEY `idx_pr_created_by` (`created_by`),
  KEY `idx_pr_deleted_by` (`deleted_by`),
  CONSTRAINT `fk_pr_order` FOREIGN KEY (`order_id`) REFERENCES `orders`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_pr_product` FOREIGN KEY (`product_id`) REFERENCES `products`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_pr_reviewer` FOREIGN KEY (`reviewer_user_id`) REFERENCES `users`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_pr_created_by` FOREIGN KEY (`created_by`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_pr_deleted_by` FOREIGN KEY (`deleted_by`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE `seller_reviews` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
  `order_id` BIGINT NOT NULL,
  `seller_store_id` BIGINT NOT NULL,
  `reviewer_user_id` BIGINT NOT NULL,
  `rating` TINYINT NOT NULL,
  `content` TEXT,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` BIGINT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_by` BIGINT NULL,
  `is_deleted` TINYINT(1) NOT NULL DEFAULT 0,
  KEY `idx_sr_order` (`order_id`),
  KEY `idx_sr_store` (`seller_store_id`),
  KEY `idx_sr_reviewer` (`reviewer_user_id`),
  KEY `idx_sr_created_by` (`created_by`),
  KEY `idx_sr_deleted_by` (`deleted_by`),
  CONSTRAINT `fk_sr_order` FOREIGN KEY (`order_id`) REFERENCES `orders`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_sr_store` FOREIGN KEY (`seller_store_id`) REFERENCES `seller_stores`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_sr_reviewer` FOREIGN KEY (`reviewer_user_id`) REFERENCES `users`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_sr_created_by` FOREIGN KEY (`created_by`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_sr_deleted_by` FOREIGN KEY (`deleted_by`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE `conversations` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
  `buyer_user_id` BIGINT NOT NULL,
  `seller_user_id` BIGINT NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` BIGINT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_by` BIGINT NULL,
  `is_deleted` TINYINT(1) NOT NULL DEFAULT 0,
  KEY `idx_conv_buyer` (`buyer_user_id`),
  KEY `idx_conv_seller` (`seller_user_id`),
  KEY `idx_conv_created_by` (`created_by`),
  KEY `idx_conv_deleted_by` (`deleted_by`),
  CONSTRAINT `fk_conv_buyer` FOREIGN KEY (`buyer_user_id`) REFERENCES `users`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_conv_seller` FOREIGN KEY (`seller_user_id`) REFERENCES `users`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_conv_created_by` FOREIGN KEY (`created_by`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_conv_deleted_by` FOREIGN KEY (`deleted_by`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE `messages` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
  `conversation_id` BIGINT NOT NULL,
  `sender_user_id` BIGINT NOT NULL,
  `content` TEXT NOT NULL,
  `message_type` VARCHAR(20) DEFAULT 'text',
  `read_at` DATETIME NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` BIGINT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_by` BIGINT NULL,
  `is_deleted` TINYINT(1) NOT NULL DEFAULT 0,
  KEY `idx_msg_conv` (`conversation_id`),
  KEY `idx_msg_sender` (`sender_user_id`),
  KEY `idx_msg_created_by` (`created_by`),
  KEY `idx_msg_deleted_by` (`deleted_by`),
  CONSTRAINT `fk_msg_conv` FOREIGN KEY (`conversation_id`) REFERENCES `conversations`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_msg_sender` FOREIGN KEY (`sender_user_id`) REFERENCES `users`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_msg_created_by` FOREIGN KEY (`created_by`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_msg_deleted_by` FOREIGN KEY (`deleted_by`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE `disputes` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
  `order_id` BIGINT NOT NULL,
  `opened_by_user_id` BIGINT NOT NULL,
  `status` VARCHAR(20) DEFAULT 'open',
  `reason` VARCHAR(500),
  `resolution_note` TEXT,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` BIGINT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_by` BIGINT NULL,
  `is_deleted` TINYINT(1) NOT NULL DEFAULT 0,
  KEY `idx_disputes_order` (`order_id`),
  KEY `idx_disputes_opened_by` (`opened_by_user_id`),
  KEY `idx_disputes_created_by` (`created_by`),
  KEY `idx_disputes_deleted_by` (`deleted_by`),
  CONSTRAINT `fk_disputes_order` FOREIGN KEY (`order_id`) REFERENCES `orders`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_disputes_opened_by` FOREIGN KEY (`opened_by_user_id`) REFERENCES `users`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_disputes_created_by` FOREIGN KEY (`created_by`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_disputes_deleted_by` FOREIGN KEY (`deleted_by`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE `payment_gateways` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
  `code` VARCHAR(80) NOT NULL UNIQUE,
  `name` VARCHAR(255) NOT NULL,
  `enabled` TINYINT(1) NOT NULL DEFAULT 1,
  `config` JSON NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` BIGINT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_by` BIGINT NULL,
  `is_deleted` TINYINT(1) NOT NULL DEFAULT 0,
  KEY `idx_pg_created_by` (`created_by`),
  KEY `idx_pg_deleted_by` (`deleted_by`),
  CONSTRAINT `fk_pg_created_by` FOREIGN KEY (`created_by`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_pg_deleted_by` FOREIGN KEY (`deleted_by`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE `notifications` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
  `user_id` BIGINT NOT NULL,
  `type` VARCHAR(100) NOT NULL,
  `title` VARCHAR(255),
  `content` TEXT,
  `read_at` DATETIME NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` BIGINT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_by` BIGINT NULL,
  `is_deleted` TINYINT(1) NOT NULL DEFAULT 0,
  KEY `idx_notif_user` (`user_id`),
  KEY `idx_notif_created_by` (`created_by`),
  KEY `idx_notif_deleted_by` (`deleted_by`),
  CONSTRAINT `fk_notif_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_notif_created_by` FOREIGN KEY (`created_by`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_notif_deleted_by` FOREIGN KEY (`deleted_by`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE `system_settings` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
  `setting_key` VARCHAR(200) NOT NULL UNIQUE,
  `setting_value` TEXT,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` BIGINT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_by` BIGINT NULL,
  `is_deleted` TINYINT(1) NOT NULL DEFAULT 0,
  KEY `idx_sys_created_by` (`created_by`),
  KEY `idx_sys_deleted_by` (`deleted_by`),
  CONSTRAINT `fk_sys_created_by` FOREIGN KEY (`created_by`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_sys_deleted_by` FOREIGN KEY (`deleted_by`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB;
