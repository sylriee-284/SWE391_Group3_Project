<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Danh sách Cửa hàng - TaphoaMMO</title>

    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- Font Awesome Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <!-- Custom CSS -->
    <style>
        :root {
            --primary-color: #2c3e50;
            --secondary-color: #34495e;
            --accent-color: #3498db;
            --success-color: #27ae60;
            --warning-color: #f39c12;
            --danger-color: #e74c3c;
            --light-bg: #ecf0f1;
            --sidebar-width: 250px;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: var(--light-bg);
            margin: 0;
            padding: 0;
        }

        /* Navbar Styles */
        .navbar-custom {
            background-color: var(--primary-color);
            border-bottom: 3px solid var(--accent-color);
            position: sticky;
            top: 0;
            z-index: 1000;
            height: 60px;
        }

        .navbar-brand {
            color: white !important;
            font-weight: bold;
            font-size: 1.5rem;
        }

        .navbar-nav .nav-link {
            color: white !important;
            transition: color 0.3s ease;
        }

        .navbar-nav .nav-link:hover {
            color: var(--accent-color) !important;
        }

        /* Layout Container */
        .layout-container {
            display: flex;
        }

        /* Sidebar Styles */
        .sidebar {
            width: var(--sidebar-width);
            min-width: var(--sidebar-width);
            height: 100vh;
            background-color: var(--secondary-color);
            transition: width 0.3s ease, min-width 0.3s ease, padding 0.3s ease;
            overflow-y: auto;
            overflow-x: hidden;
            padding: 20px 0;
            box-shadow: 2px 0 5px rgba(0,0,0,0.1);
            position: sticky;
            top: 0;
        }

        .sidebar.collapsed {
            width: 60px;
            min-width: 60px;
            padding: 20px 5px;
        }

        /* Ẩn text khi sidebar collapse */
        .sidebar.collapsed .logo,
        .sidebar.collapsed .menu-title,
        .sidebar.collapsed .menu li a span {
            display: none;
        }

        /* Center icon khi collapse */
        .sidebar.collapsed .menu li a {
            text-align: center;
            padding: 12px 0;
            justify-content: center;
        }

        .sidebar.collapsed .menu li a i {
            margin-right: 0;
        }

        /* Overlay - không cần nữa */
        .sidebar-overlay {
            display: none;
        }

        .sidebar .logo {
            text-align: center;
            font-size: 20px;
            font-weight: bold;
            color: white;
            margin-bottom: 30px;
            padding: 0 20px;
        }

        .sidebar .menu {
            list-style-type: none;
            padding: 0;
            margin: 0;
        }

        .sidebar .menu li {
            margin-bottom: 5px;
        }

        .sidebar .menu a {
            display: flex;
            align-items: center;
            padding: 12px 20px;
            color: #bdc3c7;
            text-decoration: none;
            transition: all 0.3s ease;
            white-space: nowrap;
        }

        .sidebar .menu a:hover {
            background-color: rgba(52, 152, 219, 0.1);
            color: var(--accent-color);
            padding-left: 25px;
        }

        .sidebar .menu a.active {
            background-color: var(--accent-color);
            color: white;
            border-left: 4px solid white;
        }

        .sidebar .menu a i {
            margin-right: 10px;
            width: 20px;
            min-width: 20px;
            text-align: center;
        }

        .sidebar .menu a span {
            overflow: hidden;
            transition: opacity 0.3s ease;
        }

        .sidebar .menu .menu-section {
            padding: 15px 20px 5px;
        }

        .sidebar .menu .menu-title {
            color: #95a5a6;
            font-size: 0.75rem;
            text-transform: uppercase;
            letter-spacing: 1px;
            font-weight: 600;
        }

        /* Main Content */
        .main-content {
            flex: 1;
            padding: 30px;
            min-height: 100vh;
            overflow-x: auto;
        }

        /* Store Card Styles */
        .store-card {
            transition: transform 0.2s, box-shadow 0.2s;
            height: 100%;
            border: 1px solid #dee2e6;
        }

        .store-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 25px rgba(0,0,0,0.15);
        }

        .store-logo {
            width: 80px;
            height: 80px;
            object-fit: cover;
            border-radius: 10px;
        }

        .store-stats {
            font-size: 0.9rem;
        }

        .search-filters {
            background: white;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 30px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }

        /* Toggle Button */
        #sidebarToggle {
            border: none;
            background: none;
            cursor: pointer;
        }

        #sidebarToggle:focus {
            box-shadow: none;
        }

        /* Badge Styles */
        .badge {
            padding: 0.35em 0.65em;
            font-weight: 500;
        }
    </style>
</head>
<body>
    <!-- Navbar -->
    <nav class="navbar navbar-expand-lg navbar-custom">
        <div class="container-fluid">
            <button class="btn btn-link text-white me-3" id="sidebarToggle" onclick="toggleSidebar()">
                <i class="fas fa-bars fa-lg"></i>
            </button>
            <a class="navbar-brand" href="/">TaphoaMMO</a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav ms-auto">
                    <li class="nav-item">
                        <a class="nav-link" href="/users/profile">
                            <i class="fas fa-user"></i> Profile
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="/logout">
                            <i class="fas fa-sign-out-alt"></i> Logout
                        </a>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <!-- Layout Container -->
    <div class="layout-container">
        <!-- Sidebar -->
        <div class="sidebar" id="sidebar">
        <div class="logo">
            MMO Market System
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
            <li><a href="/stores" class="active"><i class="fas fa-store"></i><span>Danh sách cửa hàng</span></a></li>
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

        <!-- Main Content Area -->
        <div class="main-content" id="mainContent">
        <!-- Header -->
        <div class="row mb-4">
            <div class="col-12">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <h1 class="h3 mb-0">
                            <i class="fas fa-store text-primary"></i>
                            Danh sách Cửa hàng
                        </h1>
                        <p class="text-muted mb-0">Khám phá các cửa hàng uy tín trên TaphoaMMO</p>
                    </div>
                    <div>
                        <a href="/stores/create" class="btn btn-primary">
                            <i class="fas fa-plus"></i> Tạo cửa hàng
                        </a>
                    </div>
                </div>
            </div>
        </div>

        <!-- Search and Filters -->
        <div class="search-filters">
            <form method="get" action="/stores">
                <div class="row g-3">
                    <div class="col-md-4">
                        <label class="form-label">Tìm kiếm</label>
                        <div class="input-group">
                            <span class="input-group-text"><i class="fas fa-search"></i></span>
                            <input type="text" class="form-control" name="search"
                                   value="${search}" placeholder="Tên cửa hàng, mô tả...">
                        </div>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Trạng thái</label>
                        <select class="form-select" name="status">
                            <option value="">Tất cả</option>
                            <option value="active" ${status == 'active' ? 'selected' : ''}>Hoạt động</option>
                            <option value="inactive" ${status == 'inactive' ? 'selected' : ''}>Không hoạt động</option>
                            <option value="suspended" ${status == 'suspended' ? 'selected' : ''}>Bị khóa</option>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Sắp xếp</label>
                        <select class="form-select" name="sort">
                            <option value="createdAt" ${sort == 'createdAt' ? 'selected' : ''}>Ngày tạo</option>
                            <option value="storeName" ${sort == 'storeName' ? 'selected' : ''}>Tên cửa hàng</option>
                            <option value="depositAmount" ${sort == 'depositAmount' ? 'selected' : ''}>Deposit</option>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label">Thứ tự</label>
                        <select class="form-select" name="direction">
                            <option value="desc" ${direction == 'desc' ? 'selected' : ''}>Giảm dần</option>
                            <option value="asc" ${direction == 'asc' ? 'selected' : ''}>Tăng dần</option>
                        </select>
                    </div>
                </div>
                <div class="row mt-3">
                    <div class="col-12">
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-search"></i> Tìm kiếm
                        </button>
                        <a href="/stores" class="btn btn-outline-secondary">
                            <i class="fas fa-times"></i> Xóa bộ lọc
                        </a>
                    </div>
                </div>
            </form>
        </div>

        <!-- Results Summary -->
        <div class="row mb-3">
            <div class="col-12">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <span class="text-muted">
                            Hiển thị ${stores.numberOfElements} trong tổng số ${stores.totalElements} cửa hàng
                        </span>
                    </div>
                    <div>
                        <span class="text-muted">Trang ${currentPage + 1} / ${totalPages}</span>
                    </div>
                </div>
            </div>
        </div>

        <!-- Store Grid -->
        <div class="row">
            <c:forEach var="store" items="${stores.content}">
                <div class="col-lg-4 col-md-6 mb-4">
                    <div class="card store-card h-100">
                        <div class="card-body">
                            <!-- Store Header -->
                            <div class="d-flex align-items-start mb-3">
                                <div class="me-3">
                                    <c:choose>
                                        <c:when test="${not empty store.storeLogoUrl}">
                                            <img src="${store.storeLogoUrl}" alt="Logo" class="store-logo">
                                        </c:when>
                                        <c:otherwise>
                                            <div class="store-logo bg-primary d-flex align-items-center justify-content-center text-white">
                                                <i class="fas fa-store fa-2x"></i>
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <div class="flex-grow-1">
                                    <h5 class="card-title mb-1">
                                        <a href="/stores/${store.id}" class="text-decoration-none">
                                            ${store.storeName}
                                        </a>
                                    </h5>
                                    <div class="mb-2">
                                        <span class="badge ${store.statusBadgeClass}">${store.statusDisplayText}</span>
                                        <span class="badge ${store.verificationBadgeClass}">${store.verificationStatus}</span>
                                    </div>
                                    <p class="text-muted small mb-0">
                                        Chủ sở hữu: ${store.ownerFullName}
                                    </p>
                                </div>
                            </div>

                            <!-- Store Description -->
                            <c:if test="${not empty store.storeDescription}">
                                <p class="card-text text-muted small">
                                    <c:choose>
                                        <c:when test="${fn:length(store.storeDescription) > 100}">
                                            ${fn:substring(store.storeDescription, 0, 100)}...
                                        </c:when>
                                        <c:otherwise>
                                            ${store.storeDescription}
                                        </c:otherwise>
                                    </c:choose>
                                </p>
                            </c:if>

                            <!-- Store Stats -->
                            <div class="store-stats">
                                <div class="row text-center">
                                    <div class="col-4">
                                        <div class="text-primary fw-bold">${store.totalProducts != null ? store.totalProducts : 0}</div>
                                        <div class="text-muted small">Sản phẩm</div>
                                    </div>
                                    <div class="col-4">
                                        <div class="text-success fw-bold">${store.totalOrders != null ? store.totalOrders : 0}</div>
                                        <div class="text-muted small">Đơn hàng</div>
                                    </div>
                                    <div class="col-4">
                                        <div class="text-warning fw-bold">
                                            <c:choose>
                                                <c:when test="${store.averageRating != null}">
                                                    ${store.formattedAverageRating} <i class="fas fa-star"></i>
                                                </c:when>
                                                <c:otherwise>
                                                    N/A
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                        <div class="text-muted small">Đánh giá</div>
                                    </div>
                                </div>
                            </div>

                            <!-- Financial Info -->
                            <div class="mt-3 pt-3 border-top">
                                <div class="row">
                                    <div class="col-6">
                                        <div class="text-muted small">Deposit</div>
                                        <div class="fw-bold text-primary">${store.formattedDeposit}</div>
                                    </div>
                                    <div class="col-6">
                                        <div class="text-muted small">Giá tối đa</div>
                                        <div class="fw-bold text-success">${store.formattedMaxListingPrice}</div>
                                    </div>
                                </div>
                            </div>

                            <!-- Contact Info -->
                            <c:if test="${not empty store.contactEmail or not empty store.contactPhone}">
                                <div class="mt-3 pt-3 border-top">
                                    <c:if test="${not empty store.contactEmail}">
                                        <div class="text-muted small">
                                            <i class="fas fa-envelope"></i> ${store.contactEmail}
                                        </div>
                                    </c:if>
                                    <c:if test="${not empty store.contactPhone}">
                                        <div class="text-muted small">
                                            <i class="fas fa-phone"></i> ${store.contactPhone}
                                        </div>
                                    </c:if>
                                </div>
                            </c:if>

                            <!-- Created Date -->
                            <div class="mt-3 pt-3 border-top">
                                <div class="text-muted small">
                                    <i class="fas fa-calendar"></i>
                                    Tạo ngày:
                                    <c:choose>
                                        <c:when test="${not empty store.createdAt}">
                                            ${fn:substring(store.createdAt.toString().replace('T', ' '), 0, 16)}
                                        </c:when>
                                        <c:otherwise>
                                            N/A
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </div>

                        <!-- Card Footer -->
                        <div class="card-footer bg-transparent">
                            <div class="d-grid">
                                <a href="/stores/${store.id}" class="btn btn-outline-primary">
                                    <i class="fas fa-eye"></i> Xem chi tiết
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </div>

        <!-- No Results -->
        <c:if test="${stores.totalElements == 0}">
            <div class="row">
                <div class="col-12">
                    <div class="text-center py-5">
                        <i class="fas fa-store fa-3x text-muted mb-3"></i>
                        <h4 class="text-muted">Không tìm thấy cửa hàng nào</h4>
                        <p class="text-muted">Thử thay đổi bộ lọc hoặc từ khóa tìm kiếm</p>
                        <a href="/stores" class="btn btn-primary">Xem tất cả cửa hàng</a>
                    </div>
                </div>
            </div>
        </c:if>

        <!-- Pagination -->
        <c:if test="${totalPages > 1}">
            <div class="row mt-4">
                <div class="col-12">
                    <nav aria-label="Store pagination">
                        <ul class="pagination justify-content-center">
                            <!-- Previous -->
                            <li class="page-item ${currentPage == 0 ? 'disabled' : ''}">
                                <a class="page-link" href="?page=${currentPage - 1}&size=12&sort=${sort}&direction=${direction}&search=${search}&status=${status}">
                                    <i class="fas fa-chevron-left"></i>
                                </a>
                            </li>

                            <!-- Page Numbers -->
                            <c:forEach begin="0" end="${totalPages - 1}" var="pageNum">
                                <c:if test="${pageNum >= currentPage - 2 && pageNum <= currentPage + 2}">
                                    <li class="page-item ${pageNum == currentPage ? 'active' : ''}">
                                        <a class="page-link" href="?page=${pageNum}&size=12&sort=${sort}&direction=${direction}&search=${search}&status=${status}">
                                            ${pageNum + 1}
                                        </a>
                                    </li>
                                </c:if>
                            </c:forEach>

                            <!-- Next -->
                            <li class="page-item ${currentPage == totalPages - 1 ? 'disabled' : ''}">
                                <a class="page-link" href="?page=${currentPage + 1}&size=12&sort=${sort}&direction=${direction}&search=${search}&status=${status}">
                                    <i class="fas fa-chevron-right"></i>
                                </a>
                            </li>
                        </ul>
                    </nav>
                </div>
            </div>
        </c:if>
        </div>
    </div>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

    <!-- Custom JavaScript -->
    <script>
        function toggleSidebar() {
            const sidebar = document.getElementById('sidebar');
            sidebar.classList.toggle('collapsed');
        }

        // Restore sidebar state on page load
        document.addEventListener('DOMContentLoaded', function() {
            // Highlight active menu item based on current URL
            const currentPath = window.location.pathname;
            const menuLinks = document.querySelectorAll('.sidebar .menu a');
            menuLinks.forEach(link => {
                if (link.getAttribute('href') === currentPath) {
                    link.classList.add('active');
                }
            });
        });
    </script>
</body>
</html>
