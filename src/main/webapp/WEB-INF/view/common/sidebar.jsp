<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%--
  Sidebar Component
  Supports 2 modes:
  - mode="overlay": Fixed position sidebar that toggles show/hide
  - mode="sticky": Sticky sidebar that always takes space (can collapse width)

  Usage:
  <c:set var="sidebarMode" value="sticky" scope="request" />
  <jsp:include page="/WEB-INF/view/common/sidebar.jsp" />
--%>

<c:set var="mode" value="${empty sidebarMode ? 'overlay' : sidebarMode}" />

<!-- Sidebar -->
<div class="sidebar mode-${mode}" id="sidebar">
    <!-- Logo (hidden when collapsed) -->
    <div class="logo">
        <h2><i class="fas fa-store"></i> TaphoaMMO</h2>
    </div>

    <!-- Menu -->
    <ul class="menu">
        <!-- Dashboard -->
        <li>
            <a href="/">
                <i class="fas fa-tachometer-alt"></i>
                <span>Trang chủ</span>
            </a>
        </li>

        <!-- User Management -->
        <li class="menu-section">
            <div class="menu-title">Quản lý người dùng</div>
        </li>
        <li>
            <a href="/users">
                <i class="fas fa-users"></i>
                <span>Danh sách người dùng</span>
            </a>
        </li>
        <li>
            <a href="/users/register">
                <i class="fas fa-user-plus"></i>
                <span>Thêm người dùng</span>
            </a>
        </li>
        <li>
            <a href="/users/profile">
                <i class="fas fa-user-circle"></i>
                <span>Hồ sơ của tôi</span>
            </a>
        </li>

        <!-- Store Management -->
        <li class="menu-section">
            <div class="menu-title">Quản lý cửa hàng</div>
        </li>
        <li>
            <a href="/stores">
                <i class="fas fa-store"></i>
                <span>Danh sách cửa hàng</span>
            </a>
        </li>
        <li>
            <a href="/stores/create">
                <i class="fas fa-plus-circle"></i>
                <span>Tạo cửa hàng</span>
            </a>
        </li>

        <!-- Product Management -->
        <li class="menu-section">
            <div class="menu-title">Quản lý sản phẩm</div>
        </li>
        <li>
            <a href="/products">
                <i class="fas fa-box"></i>
                <span>Danh sách sản phẩm</span>
            </a>
        </li>
        <li>
            <a href="/products/create">
                <i class="fas fa-plus"></i>
                <span>Thêm sản phẩm</span>
            </a>
        </li>
        <li>
            <a href="/categories">
                <i class="fas fa-tags"></i>
                <span>Danh mục</span>
            </a>
        </li>

        <!-- Order Management -->
        <li class="menu-section">
            <div class="menu-title">Quản lý đơn hàng</div>
        </li>
        <li>
            <a href="/orders">
                <i class="fas fa-shopping-cart"></i>
                <span>Danh sách đơn hàng</span>
            </a>
        </li>
        <li>
            <a href="/orders/pending">
                <i class="fas fa-clock"></i>
                <span>Đơn hàng chờ</span>
            </a>
        </li>
        <li>
            <a href="/escrow">
                <i class="fas fa-handshake"></i>
                <span>Giao dịch ký quỹ</span>
            </a>
        </li>

        <!-- Financial Management -->
        <li class="menu-section">
            <div class="menu-title">Quản lý tài chính</div>
        </li>
        <li>
            <a href="/wallets">
                <i class="fas fa-wallet"></i>
                <span>Quản lý ví</span>
            </a>
        </li>
        <li>
            <a href="/transactions">
                <i class="fas fa-exchange-alt"></i>
                <span>Giao dịch</span>
            </a>
        </li>
        <li>
            <a href="/deposits">
                <i class="fas fa-piggy-bank"></i>
                <span>Tiền cọc cửa hàng</span>
            </a>
        </li>

        <!-- Reports & Analytics -->
        <li class="menu-section">
            <div class="menu-title">Báo cáo & Thống kê</div>
        </li>
        <li>
            <a href="/reports/dashboard">
                <i class="fas fa-chart-bar"></i>
                <span>Tổng quan</span>
            </a>
        </li>
        <li>
            <a href="/reports/sales">
                <i class="fas fa-chart-line"></i>
                <span>Doanh thu</span>
            </a>
        </li>
        <li>
            <a href="/reports/users">
                <i class="fas fa-user-chart"></i>
                <span>Người dùng</span>
            </a>
        </li>

        <!-- System Settings -->
        <li class="menu-section">
            <div class="menu-title">Cài đặt hệ thống</div>
        </li>
        <li>
            <a href="/settings">
                <i class="fas fa-cog"></i>
                <span>Cài đặt chung</span>
            </a>
        </li>
        <li>
            <a href="/roles">
                <i class="fas fa-user-tag"></i>
                <span>Vai trò & Quyền</span>
            </a>
        </li>
        <li>
            <a href="/notifications">
                <i class="fas fa-bell"></i>
                <span>Thông báo</span>
            </a>
        </li>
    </ul>
</div>
