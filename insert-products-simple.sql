USE mmo_market_system;

-- Product 1: LOL Account
INSERT INTO products (name, product_name, description, price, stock_quantity, stock, category, product_images, sku, is_active, is_deleted, store_id, seller_id, seller_store_id)
VALUES ('LOL Vàng IV', 'Tài khoản LOL Ranked Vàng IV', 'Tài khoản League of Legends rank Vàng IV, có 50+ champions, nhiều skin đẹp. Bảo hành 7 ngày đổi trả.', 1500000, 5, 5, 'GAME_ACCOUNT', 'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=400&h=300&fit=crop', 'LOL-GOLD-001', 1, 0, 2, 2, 2);

-- Product 2: Valorant Account
INSERT INTO products (name, product_name, description, price, stock_quantity, stock, category, product_images, sku, is_active, is_deleted, store_id, seller_id, seller_store_id)
VALUES ('Valorant Immortal', 'Acc Valorant Immortal Full Agents', 'Tài khoản Valorant rank Immortal, full agents, nhiều skin Phantom/Vandal limited edition. Cam kết uy tín 100%.', 3500000, 2, 2, 'GAME_ACCOUNT', 'https://images.unsplash.com/photo-1552820728-8b83bb6b773f?w=400&h=300&fit=crop', 'VAL-IMM-001', 1, 0, 2, 2, 2);

-- Product 3: PUBG Account
INSERT INTO products (name, product_name, description, price, stock_quantity, stock, category, product_images, sku, is_active, is_deleted, store_id, seller_id, seller_store_id)
VALUES ('PUBG Conqueror', 'Tài khoản PUBG Mobile Conqueror', 'Acc PUBG Mobile rank Conqueror mùa 25, có nhiều set đồ legendary, skin súng xịn.', 2200000, 3, 3, 'GAME_ACCOUNT', 'https://images.unsplash.com/photo-1511512578047-dfb367046420?w=400&h=300&fit=crop', 'PUBG-CONQ-001', 1, 0, 2, 2, 2);

-- Product 4: Riot Points
INSERT INTO products (name, product_name, description, price, stock_quantity, stock, category, product_images, sku, is_active, is_deleted, store_id, seller_id, seller_store_id)
VALUES ('RP 1000', 'Riot Points 1000 RP', 'Mã Riot Points 1000 RP cho LMHT/Valorant. Hỗ trợ nạp tự động 24/7, giao mã ngay lập tức.', 200000, 50, 50, 'GAME_CURRENCY', 'https://images.unsplash.com/photo-1556656793-08538906a9f8?w=400&h=300&fit=crop', 'RP-1000-001', 1, 0, 2, 2, 2);

-- Product 5: Liên Quân Gold
INSERT INTO products (name, product_name, description, price, stock_quantity, stock, category, product_images, sku, is_active, is_deleted, store_id, seller_id, seller_store_id)
VALUES ('LQM 2000 xu', 'Vàng Liên Quân 2000 xu', 'Vàng Liên Quân Mobile 2000 xu. Nạp nhanh trong 5 phút, hỗ trợ 24/7.', 180000, 100, 100, 'GAME_CURRENCY', 'https://images.unsplash.com/photo-1550745165-9bc0b252726f?w=400&h=300&fit=crop', 'LQM-GOLD-2000', 1, 0, 2, 2, 2);

-- Product 6: Facebook
INSERT INTO products (name, product_name, description, price, stock_quantity, stock, category, product_images, sku, is_active, is_deleted, store_id, seller_id, seller_store_id)
VALUES ('FB 5K Friends', 'Facebook 5000 Friends Verified', 'Tài khoản Facebook cá nhân có 5000 bạn bè, tích xanh, hoạt động tốt, không checkpoint.', 800000, 3, 3, 'SOCIAL_ACCOUNT', 'https://images.unsplash.com/photo-1611162617474-5b21e879e113?w=400&h=300&fit=crop', 'FB-5K-001', 1, 0, 2, 2, 2);

-- Product 7: Instagram
INSERT INTO products (name, product_name, description, price, stock_quantity, stock, category, product_images, sku, is_active, is_deleted, store_id, seller_id, seller_store_id)
VALUES ('IG 10K', 'Instagram 10K Followers Real', 'Tài khoản Instagram 10,000 followers thật 100%, engagement rate cao, niche du lịch & lifestyle.', 1200000, 2, 2, 'SOCIAL_ACCOUNT', 'https://images.unsplash.com/photo-1611162616305-c69b3fa7fbe0?w=400&h=300&fit=crop', 'IG-10K-001', 1, 0, 2, 2, 2);

-- Product 8: Windows 11
INSERT INTO products (name, product_name, description, price, stock_quantity, stock, category, product_images, sku, is_active, is_deleted, store_id, seller_id, seller_store_id)
VALUES ('Win11 Pro', 'Windows 11 Pro License Key', 'Key bản quyền Windows 11 Professional, kích hoạt vĩnh viễn, hỗ trợ kỹ thuật miễn phí.', 350000, 20, 20, 'SOFTWARE_LICENSE', 'https://images.unsplash.com/photo-1633419461186-7d40a38105ec?w=400&h=300&fit=crop', 'WIN11-PRO-001', 1, 0, 2, 2, 2);

-- Product 9: Office 365
INSERT INTO products (name, product_name, description, price, stock_quantity, stock, category, product_images, sku, is_active, is_deleted, store_id, seller_id, seller_store_id)
VALUES ('Office 365', 'Office 365 Personal 1 Năm', 'Tài khoản Office 365 Personal bản quyền 1 năm, 1TB OneDrive, cập nhật liên tục.', 450000, 15, 15, 'SOFTWARE_LICENSE', 'https://images.unsplash.com/photo-1587614382346-4ec70e388b28?w=400&h=300&fit=crop', 'O365-PER-001', 1, 0, 2, 2, 2);

-- Product 10: Steam
INSERT INTO products (name, product_name, description, price, stock_quantity, stock, category, product_images, sku, is_active, is_deleted, store_id, seller_id, seller_store_id)
VALUES ('Steam $20', 'Steam Wallet Code $20 USD', 'Mã nạp Steam Wallet $20 USD, giao mã tự động qua email trong 1 phút sau khi thanh toán.', 500000, 30, 30, 'GIFT_CARD', 'https://images.unsplash.com/photo-1606144042614-b2417e99c4e3?w=400&h=300&fit=crop', 'STEAM-20-001', 1, 0, 2, 2, 2);

-- Product 11: Google Play
INSERT INTO products (name, product_name, description, price, stock_quantity, stock, category, product_images, sku, is_active, is_deleted, store_id, seller_id, seller_store_id)
VALUES ('GP 500K', 'Google Play Gift Card 500K', 'Thẻ Google Play 500,000 VND, sử dụng được ngay, áp dụng tất cả tài khoản Việt Nam.', 500000, 25, 25, 'GIFT_CARD', 'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=400&h=300&fit=crop', 'GP-500K-001', 1, 0, 2, 2, 2);

-- Product 12: NordVPN
INSERT INTO products (name, product_name, description, price, stock_quantity, stock, category, product_images, sku, is_active, is_deleted, store_id, seller_id, seller_store_id)
VALUES ('NordVPN 1Y', 'NordVPN Premium 1 Năm', 'Tài khoản NordVPN Premium 1 năm, hỗ trợ 6 thiết bị cùng lúc, tốc độ cao, server toàn cầu.', 600000, 10, 10, 'VPN_PROXY', 'https://images.unsplash.com/photo-1614064641938-3bbee52942c7?w=400&h=300&fit=crop', 'NORD-1Y-001', 1, 0, 2, 2, 2);

-- Verify
SELECT id, name, product_name, category, price, stock_quantity, is_active FROM products WHERE is_deleted = 0;
