<%@ page language="java" pageEncoding="UTF-8" %>
    <!DOCTYPE html>
    <html lang="en">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Sidebar</title>
        <style>
            /* Sidebar */
            .sidebar {
                width: 250px;
                height: 100vh;
                /* Chiều cao sidebar chiếm toàn bộ chiều cao màn hình */
                background-color: #2c3e50;
                color: white;
                padding: 20px;
                display: flex;
                flex-direction: column;
                position: fixed;
                top: 0;
                left: -250px;
                /* Sidebar ẩn ra ngoài */
                transition: left 0.3s ease;
                /* Hiệu ứng trượt sidebar vào/ra */
                overflow-y: scroll;
                /* Bật thanh cuộn dọc trong sidebar */
            }

            /* Khi có class active, sidebar sẽ trượt vào */
            .sidebar.active {
                left: 0;
            }

            /* Logo trong sidebar */
            .sidebar .logo {
                text-align: center;
                font-size: 24px;
                font-weight: bold;
                margin-bottom: 40px;
            }

            /* Menu trong sidebar */
            .sidebar .menu {
                list-style-type: none;
                padding: 0;
                margin: 0;
            }

            /* Các mục trong menu */
            .sidebar .menu li {
                margin-bottom: 5px;
            }

            /* Menu sections */
            .menu-section {
                margin-top: 20px;
                margin-bottom: 10px;
            }

            .menu-title {
                color: #95a5a6;
                font-size: 12px;
                font-weight: 600;
                text-transform: uppercase;
                letter-spacing: 1px;
                padding: 0 15px;
                display: block;
                margin-bottom: 10px;
            }

            /* Các liên kết trong menu */
            .sidebar .menu li a {
                color: #bdc3c7;
                text-decoration: none;
                font-size: 14px;
                display: block;
                padding: 12px 15px;
                border-radius: 5px;
                transition: all 0.3s ease;
            }

            .sidebar .menu li a i {
                width: 20px;
                margin-right: 10px;
                text-align: center;
            }

            /* Khi di chuột vào liên kết trong menu */
            .sidebar .menu li a:hover {
                background-color: #34495e;
                color: white;
                padding-left: 25px;
            }

            /* Mục đang được chọn trong menu */
            .sidebar .menu li a.active {
                background-color: #3498db;
                color: white;
            }

            /* Bỏ màu trắng nền của sidebar khi thanh cuộn xuất hiện */
            .sidebar::-webkit-scrollbar {
                width: 8px;
                /* Độ rộng thanh cuộn */
            }

            .sidebar::-webkit-scrollbar-thumb {
                background-color: #7f8c8d;
                /* Màu sắc của thanh cuộn */
                border-radius: 10px;
            }

            .sidebar::-webkit-scrollbar-track {
                background-color: transparent;
                /* Loại bỏ màu nền của track */
            }
        </style>
    </head>

    <body>

        <!-- Sidebar -->
        <div class="sidebar" id="sidebar">
            <div class="logo">
                <br></br>
                <h2>MMO Market System</h2>
            </div>
            <ul class="menu">
                <!-- Dashboard -->
                <li><a href="/"><i class="fas fa-tachometer-alt"></i> Trang chủ</a></li>

                <!-- User Management -->
                <li class="menu-section">
                    <span class="menu-title">Quản lý người dùng</span>
                </li>
                <li><a href="/users"><i class="fas fa-users"></i> Danh sách người dùng</a></li>
                <li><a href="/users/register"><i class="fas fa-user-plus"></i> Thêm người dùng</a></li>
                <li><a href="/users/profile"><i class="fas fa-user-circle"></i> Hồ sơ của tôi</a></li>

                <!-- Store Management -->
                <li class="menu-section">
                    <span class="menu-title">Quản lý cửa hàng</span>
                </li>
                <li><a href="/stores"><i class="fas fa-store"></i> Danh sách cửa hàng</a></li>
                <li><a href="/stores/create"><i class="fas fa-plus-circle"></i> Tạo cửa hàng</a></li>

                <!-- Product Management -->
                <li class="menu-section">
                    <span class="menu-title">Quản lý sản phẩm</span>
                </li>
                <li><a href="/products"><i class="fas fa-box"></i> Danh sách sản phẩm</a></li>
                <li><a href="/products/create"><i class="fas fa-plus"></i> Thêm sản phẩm</a></li>
                <li><a href="/categories"><i class="fas fa-tags"></i> Danh mục</a></li>

                <!-- Order Management -->
                <li class="menu-section">
                    <span class="menu-title">Quản lý đơn hàng</span>
                </li>
                <li><a href="/orders"><i class="fas fa-shopping-cart"></i> Danh sách đơn hàng</a></li>
                <li><a href="/orders/pending"><i class="fas fa-clock"></i> Đơn hàng chờ</a></li>
                <li><a href="/escrow"><i class="fas fa-handshake"></i> Giao dịch ký quỹ</a></li>

                <!-- Financial Management -->
                <li class="menu-section">
                    <span class="menu-title">Quản lý tài chính</span>
                </li>
                <li><a href="/wallets"><i class="fas fa-wallet"></i> Quản lý ví</a></li>
                <li><a href="/transactions"><i class="fas fa-exchange-alt"></i> Giao dịch</a></li>
                <li><a href="/deposits"><i class="fas fa-piggy-bank"></i> Tiền cọc cửa hàng</a></li>

                <!-- Reports & Analytics -->
                <li class="menu-section">
                    <span class="menu-title">Báo cáo & Thống kê</span>
                </li>
                <li><a href="/reports/dashboard"><i class="fas fa-chart-bar"></i> Tổng quan</a></li>
                <li><a href="/reports/sales"><i class="fas fa-chart-line"></i> Doanh thu</a></li>
                <li><a href="/reports/users"><i class="fas fa-user-chart"></i> Người dùng</a></li>

                <!-- System Settings -->
                <li class="menu-section">
                    <span class="menu-title">Cài đặt hệ thống</span>
                </li>
                <li><a href="/settings"><i class="fas fa-cog"></i> Cài đặt chung</a></li>
                <li><a href="/roles"><i class="fas fa-user-tag"></i> Vai trò & Quyền</a></li>
                <li><a href="/notifications"><i class="fas fa-bell"></i> Thông báo</a></li>
            </ul>
        </div>
    </body>

    </html>