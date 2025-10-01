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
        <!-- Common Links -->
        <li>
            <a href="/">
                <i class="fas fa-home"></i>
                <span>Trang chủ</span>
            </a>
        </li>
        <li>
            <a href="/products">
                <i class="fas fa-boxes"></i>
                <span>Sản phẩm</span>
            </a>
        </li>
        <li>
            <a href="/stores">
                <i class="fas fa-store"></i>
                <span>Cửa hàng</span>
            </a>
        </li>

        <!-- Seller Section -->
        <c:if test="${not empty sessionScope.currentUser and (sessionScope.currentUser.role == 'SELLER' or sessionScope.currentUser.role == 'ADMIN')}">
            <li class="menu-section">
                <div class="menu-title">Quản lý cửa hàng</div>
            </li>
            <li>
                <a href="/stores/my-store">
                    <i class="fas fa-tachometer-alt"></i>
                    <span>Dashboard</span>
                </a>
            </li>
            <li>
                <a href="/products/my-products">
                    <i class="fas fa-box"></i>
                    <span>Sản phẩm của tôi</span>
                </a>
            </li>
            <li>
                <a href="/products/create">
                    <i class="fas fa-plus-circle"></i>
                    <span>Thêm sản phẩm</span>
                </a>
            </li>
            <li>
                <a href="/stores/my-store/orders">
                    <i class="fas fa-shopping-cart"></i>
                    <span>Đơn hàng</span>
                </a>
            </li>
            <li>
                <a href="/stores/my-store/inventory">
                    <i class="fas fa-boxes"></i>
                    <span>Kho hàng</span>
                </a>
            </li>
            <li>
                <a href="/stores/my-store/settings">
                    <i class="fas fa-cog"></i>
                    <span>Cài đặt cửa hàng</span>
                </a>
            </li>
        </c:if>

        <!-- User without store -->
        <c:if test="${not empty sessionScope.currentUser and sessionScope.currentUser.role == 'USER'}">
            <li class="menu-section">
                <div class="menu-title">Bán hàng</div>
            </li>
            <li>
                <a href="/stores/create">
                    <i class="fas fa-plus-circle"></i>
                    <span>Tạo cửa hàng</span>
                </a>
            </li>
        </c:if>

        <!-- Admin Section -->
        <c:if test="${not empty sessionScope.currentUser and sessionScope.currentUser.role == 'ADMIN'}">
            <li class="menu-section">
                <div class="menu-title">Quản trị</div>
            </li>
            <li>
                <a href="/admin/users">
                    <i class="fas fa-users"></i>
                    <span>Người dùng</span>
                </a>
            </li>
            <li>
                <a href="/admin/stores">
                    <i class="fas fa-store-alt"></i>
                    <span>Cửa hàng</span>
                </a>
            </li>
            <li>
                <a href="/admin/products">
                    <i class="fas fa-box"></i>
                    <span>Sản phẩm</span>
                </a>
            </li>
            <li>
                <a href="/admin/orders">
                    <i class="fas fa-shopping-cart"></i>
                    <span>Đơn hàng</span>
                </a>
            </li>
            <li>
                <a href="/admin/wallets">
                    <i class="fas fa-wallet"></i>
                    <span>Ví điện tử</span>
                </a>
            </li>
            <li>
                <a href="/admin/reports">
                    <i class="fas fa-chart-bar"></i>
                    <span>Báo cáo</span>
                </a>
            </li>
        </c:if>

        <!-- User Account Section -->
        <c:if test="${not empty sessionScope.currentUser}">
            <li class="menu-section">
                <div class="menu-title">Tài khoản</div>
            </li>
            <li>
                <a href="/users/profile">
                    <i class="fas fa-user-circle"></i>
                    <span>Hồ sơ</span>
                </a>
            </li>
            <li>
                <a href="/wallets/my-wallet">
                    <i class="fas fa-wallet"></i>
                    <span>Ví của tôi</span>
                </a>
            </li>
            <li>
                <a href="/orders/my-orders">
                    <i class="fas fa-list"></i>
                    <span>Đơn hàng của tôi</span>
                </a>
            </li>
            <li>
                <a href="/users/change-password">
                    <i class="fas fa-key"></i>
                    <span>Đổi mật khẩu</span>
                </a>
            </li>
        </c:if>
    </ul>
</div>
