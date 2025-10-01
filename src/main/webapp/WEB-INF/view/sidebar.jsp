<%@ page language="java" pageEncoding="UTF-8" %>
<style>
    /* Sidebar */
    .sidebar {
        width: 250px;
        min-width: 250px;
        height: 100vh;
        background-color: #2c3e50;
        color: white;
        padding: 20px;
        display: flex;
        flex-direction: column;
        position: sticky;
        top: 0;
        left: 0;
        transition: width 0.3s ease, min-width 0.3s ease, padding 0.3s ease;
        overflow-y: auto;
        overflow-x: hidden;
        box-shadow: 2px 0 10px rgba(0, 0, 0, 0.3);
    }

    .sidebar.collapsed {
        width: 60px;
        min-width: 60px;
        padding: 20px 10px;
    }

    /* Ẩn text khi sidebar collapse */
    .sidebar.collapsed .logo h2,
    .sidebar.collapsed .menu-title,
    .sidebar.collapsed .menu li a span {
        display: none;
    }

    /* Center icon khi collapse */
    .sidebar.collapsed .menu li a {
        text-align: center;
        padding: 12px 0;
    }

    .sidebar.collapsed .menu li a i {
        margin-right: 0;
    }

    /* Overlay - không cần nữa vì sidebar luôn hiển thị */
    .sidebar-overlay {
        display: none;
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
        display: flex;
        align-items: center;
        padding: 12px 15px;
        border-radius: 5px;
        transition: all 0.3s ease;
        white-space: nowrap;
    }

    .sidebar .menu li a i {
        width: 20px;
        min-width: 20px;
        margin-right: 10px;
        text-align: center;
    }

    .sidebar .menu li a span {
        overflow: hidden;
        transition: opacity 0.3s ease;
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
    }

    .sidebar::-webkit-scrollbar-thumb {
        background-color: #7f8c8d;
        border-radius: 10px;
    }

    .sidebar::-webkit-scrollbar-track {
        background-color: transparent;
    }
</style>

<!-- Sidebar Overlay -->
<div class="sidebar-overlay" id="sidebarOverlay" onclick="toggleSidebar()"></div>

<!-- Sidebar -->
<div class="sidebar" id="sidebar">
    <div class="logo">
        <br></br>
        <h2>MMO Market System</h2>
    </div>
    <ul class="menu">
        <!-- Dashboard -->
        <li><a href="/"><i class="fas fa-tachometer-alt"></i><span>Trang chủ</span></a></li>

        <!-- User Management -->
        <li class="menu-section">
            <span class="menu-title">Quản lý người dùng</span>
        </li>
        <li><a href="/users"><i class="fas fa-users"></i><span>Danh sách người dùng</span></a></li>
        <li><a href="/users/register"><i class="fas fa-user-plus"></i><span>Thêm người dùng</span></a></li>
        <li><a href="/users/profile"><i class="fas fa-user-circle"></i><span>Hồ sơ của tôi</span></a></li>

        <!-- Store Management -->
        <li class="menu-section">
            <span class="menu-title">Quản lý cửa hàng</span>
        </li>
        <li><a href="/stores"><i class="fas fa-store"></i><span>Danh sách cửa hàng</span></a></li>
        <li><a href="/stores/create"><i class="fas fa-plus-circle"></i><span>Tạo cửa hàng</span></a></li>

        <!-- Product Management -->
        <li class="menu-section">
            <span class="menu-title">Quản lý sản phẩm</span>
        </li>
        <li><a href="/products"><i class="fas fa-box"></i><span>Danh sách sản phẩm</span></a></li>
        <li><a href="/products/create"><i class="fas fa-plus"></i><span>Thêm sản phẩm</span></a></li>
        <li><a href="/categories"><i class="fas fa-tags"></i><span>Danh mục</span></a></li>

        <!-- Order Management -->
        <li class="menu-section">
            <span class="menu-title">Quản lý đơn hàng</span>
        </li>
        <li><a href="/orders"><i class="fas fa-shopping-cart"></i><span>Danh sách đơn hàng</span></a></li>
        <li><a href="/orders/pending"><i class="fas fa-clock"></i><span>Đơn hàng chờ</span></a></li>
        <li><a href="/escrow"><i class="fas fa-handshake"></i><span>Giao dịch ký quỹ</span></a></li>

        <!-- Financial Management -->
        <li class="menu-section">
            <span class="menu-title">Quản lý tài chính</span>
        </li>
        <li><a href="/wallets"><i class="fas fa-wallet"></i><span>Quản lý ví</span></a></li>
        <li><a href="/transactions"><i class="fas fa-exchange-alt"></i><span>Giao dịch</span></a></li>
        <li><a href="/deposits"><i class="fas fa-piggy-bank"></i><span>Tiền cọc cửa hàng</span></a></li>

        <!-- Reports & Analytics -->
        <li class="menu-section">
            <span class="menu-title">Báo cáo & Thống kê</span>
        </li>
        <li><a href="/reports/dashboard"><i class="fas fa-chart-bar"></i><span>Tổng quan</span></a></li>
        <li><a href="/reports/sales"><i class="fas fa-chart-line"></i><span>Doanh thu</span></a></li>
        <li><a href="/reports/users"><i class="fas fa-user-chart"></i><span>Người dùng</span></a></li>

        <!-- System Settings -->
        <li class="menu-section">
            <span class="menu-title">Cài đặt hệ thống</span>
        </li>
        <li><a href="/settings"><i class="fas fa-cog"></i><span>Cài đặt chung</span></a></li>
        <li><a href="/roles"><i class="fas fa-user-tag"></i><span>Vai trò & Quyền</span></a></li>
        <li><a href="/notifications"><i class="fas fa-bell"></i><span>Thông báo</span></a></li>
    </ul>
</div>
