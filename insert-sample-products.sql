-- Insert Sample Products for TaphoaMMO
-- Store ID = 2, Seller ID = 2 (from existing data)

USE mmo_market_system;

-- Insert 12 sample products
INSERT INTO products (
    name,
    product_name,
    description,
    price,
    stock_quantity,
    category,
    product_images,
    sku,
    is_active,
    is_deleted,
    store_id,
    seller_id,
    seller_store_id,
    stock,
    created_at,
    updated_at
) VALUES
-- GAME_ACCOUNT
(
    'Tài khoản LOL Ranked Vàng IV',
    'Tài khoản LOL Ranked Vàng IV',
    'Tài khoản League of Legends rank Vàng IV, có 50+ champions, nhiều skin đẹp. Bảo hành 7 ngày đổi trả.',
    1500000,
    5,
    'GAME_ACCOUNT',
    'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=400&h=300&fit=crop',
    'LOL-GOLD-001',
    1,
    0,
    2,
    2,
    2,
    5,
    NOW(),
    NOW()
),
(
    'Acc Valorant Immortal Full Agents',
    'Tài khoản Valorant rank Immortal, full agents, nhiều skin Phantom/Vandal limited edition. Cam kết uy tín 100%.',
    3500000,
    2,
    'GAME_ACCOUNT',
    'https://images.unsplash.com/photo-1552820728-8b83bb6b773f?w=400&h=300&fit=crop',
    'VAL-IMM-001',
    1,
    0,
    2,
    2,
    2,
    NOW(),
    NOW()
),
(
    'Tài khoản PUBG Mobile Conqueror',
    'Acc PUBG Mobile rank Conqueror mùa 25, có nhiều set đồ legendary, skin súng xịn.',
    2200000,
    3,
    'GAME_ACCOUNT',
    'https://images.unsplash.com/photo-1511512578047-dfb367046420?w=400&h=300&fit=crop',
    'PUBG-CONQ-001',
    1,
    0,
    2,
    2,
    2,
    NOW(),
    NOW()
),

-- GAME_CURRENCY
(
    'Riot Points 1000 RP',
    'Mã Riot Points 1000 RP cho LMHT/Valorant. Hỗ trợ nạp tự động 24/7, giao mã ngay lập tức.',
    200000,
    50,
    'GAME_CURRENCY',
    'https://images.unsplash.com/photo-1556656793-08538906a9f8?w=400&h=300&fit=crop',
    'RP-1000-001',
    1,
    0,
    2,
    2,
    2,
    NOW(),
    NOW()
),
(
    'Vàng Liên Quân 2000 xu',
    'Vàng Liên Quân Mobile 2000 xu. Nạp nhanh trong 5 phút, hỗ trợ 24/7.',
    180000,
    100,
    'GAME_CURRENCY',
    'https://images.unsplash.com/photo-1550745165-9bc0b252726f?w=400&h=300&fit=crop',
    'LQM-GOLD-2000',
    1,
    0,
    2,
    2,
    2,
    NOW(),
    NOW()
),

-- SOCIAL_ACCOUNT
(
    'Facebook 5000 Friends Verified',
    'Tài khoản Facebook cá nhân có 5000 bạn bè, tích xanh, hoạt động tốt, không checkpoint.',
    800000,
    3,
    'SOCIAL_ACCOUNT',
    'https://images.unsplash.com/photo-1611162617474-5b21e879e113?w=400&h=300&fit=crop',
    'FB-5K-001',
    1,
    0,
    2,
    2,
    2,
    NOW(),
    NOW()
),
(
    'Instagram 10K Followers Real',
    'Tài khoản Instagram 10,000 followers thật 100%, engagement rate cao, niche du lịch & lifestyle.',
    1200000,
    2,
    'SOCIAL_ACCOUNT',
    'https://images.unsplash.com/photo-1611162616305-c69b3fa7fbe0?w=400&h=300&fit=crop',
    'IG-10K-001',
    1,
    0,
    2,
    2,
    2,
    NOW(),
    NOW()
),

-- SOFTWARE_LICENSE
(
    'Windows 11 Pro License Key',
    'Key bản quyền Windows 11 Professional, kích hoạt vĩnh viễn, hỗ trợ kỹ thuật miễn phí.',
    350000,
    20,
    'SOFTWARE_LICENSE',
    'https://images.unsplash.com/photo-1633419461186-7d40a38105ec?w=400&h=300&fit=crop',
    'WIN11-PRO-001',
    1,
    0,
    2,
    2,
    2,
    NOW(),
    NOW()
),
(
    'Office 365 Personal 1 Năm',
    'Tài khoản Office 365 Personal bản quyền 1 năm, 1TB OneDrive, cập nhật liên tục.',
    450000,
    15,
    'SOFTWARE_LICENSE',
    'https://images.unsplash.com/photo-1587614382346-4ec70e388b28?w=400&h=300&fit=crop',
    'O365-PER-001',
    1,
    0,
    2,
    2,
    2,
    NOW(),
    NOW()
),

-- GIFT_CARD
(
    'Steam Wallet Code $20 USD',
    'Mã nạp Steam Wallet $20 USD, giao mã tự động qua email trong 1 phút sau khi thanh toán.',
    500000,
    30,
    'GIFT_CARD',
    'https://images.unsplash.com/photo-1606144042614-b2417e99c4e3?w=400&h=300&fit=crop',
    'STEAM-20-001',
    1,
    0,
    2,
    2,
    2,
    NOW(),
    NOW()
),
(
    'Google Play Gift Card 500K',
    'Thẻ Google Play 500,000 VND, sử dụng được ngay, áp dụng tất cả tài khoản Việt Nam.',
    500000,
    25,
    'GIFT_CARD',
    'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=400&h=300&fit=crop',
    'GP-500K-001',
    1,
    0,
    2,
    2,
    2,
    NOW(),
    NOW()
),

-- VPN_PROXY
(
    'NordVPN Premium 1 Năm',
    'Tài khoản NordVPN Premium 1 năm, hỗ trợ 6 thiết bị cùng lúc, tốc độ cao, server toàn cầu.',
    600000,
    10,
    'VPN_PROXY',
    'https://images.unsplash.com/photo-1614064641938-3bbee52942c7?w=400&h=300&fit=crop',
    'NORD-1Y-001',
    1,
    0,
    2,
    2,
    2,
    NOW(),
    NOW()
);

-- Verify inserted products
SELECT
    id,
    product_name,
    category,
    price,
    stock_quantity,
    is_active,
    is_deleted
FROM products
WHERE is_deleted = 0
ORDER BY created_at DESC;
