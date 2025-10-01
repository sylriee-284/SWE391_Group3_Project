<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý người dùng - TaphoaMMO</title>

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
            padding-top: 60px;
        }

        /* Navbar Styles */
        .navbar-custom {
            background-color: var(--primary-color);
            border-bottom: 3px solid var(--accent-color);
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
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

        /* Sidebar Styles */
        .sidebar {
            position: fixed;
            top: 60px;
            left: -var(--sidebar-width);
            width: var(--sidebar-width);
            height: calc(100vh - 60px);
            background-color: var(--secondary-color);
            transition: left 0.3s ease;
            z-index: 999;
            overflow-y: auto;
            padding: 20px 0;
        }

        .sidebar.active {
            left: 0;
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
            padding: 0 20px;
            display: block;
            margin-bottom: 10px;
        }

        .sidebar .menu li a {
            color: #bdc3c7;
            text-decoration: none;
            font-size: 14px;
            display: block;
            padding: 12px 20px;
            transition: all 0.3s ease;
        }

        .sidebar .menu li a i {
            width: 20px;
            margin-right: 10px;
            text-align: center;
        }

        .sidebar .menu li a:hover {
            background-color: #34495e;
            color: white;
            padding-left: 30px;
        }

        .sidebar .menu li a.active {
            background-color: var(--accent-color);
            color: white;
            border-left: 4px solid white;
        }

        .sidebar::-webkit-scrollbar {
            width: 6px;
        }

        .sidebar::-webkit-scrollbar-thumb {
            background-color: #7f8c8d;
            border-radius: 10px;
        }

        .sidebar::-webkit-scrollbar-track {
            background-color: transparent;
        }

        /* Main Content Styles */
        .main-content {
            margin-left: 0;
            padding: 20px;
            transition: margin-left 0.3s ease;
            min-height: calc(100vh - 60px);
        }

        .main-content.shifted {
            margin-left: var(--sidebar-width);
        }

        /* Page Header */
        .page-header {
            background: linear-gradient(135deg, #2c3e50, #3498db);
            color: white;
            padding: 2rem 0;
            margin-bottom: 2rem;
            border-radius: 15px;
        }

        /* Stats Cards */
        .stats-card {
            background: white;
            border-radius: 10px;
            padding: 1.5rem;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            border-left: 4px solid #3498db;
            margin-bottom: 1rem;
        }

        .stats-number {
            font-size: 2rem;
            font-weight: bold;
            color: #2c3e50;
        }

        /* Search Card */
        .search-card {
            background: white;
            border-radius: 10px;
            padding: 1.5rem;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            margin-bottom: 2rem;
        }

        /* Table Styles */
        .table-card {
            background: white;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            overflow: hidden;
        }

        .table th {
            background-color: #f8f9fa;
            border: none;
            font-weight: 600;
            color: #2c3e50;
        }

        .table td {
            border: none;
            vertical-align: middle;
        }

        .table tbody tr {
            border-bottom: 1px solid #dee2e6;
        }

        .table tbody tr:hover {
            background-color: #f8f9fa;
        }

        .avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            object-fit: cover;
        }

        .user-actions {
            display: flex;
            gap: 0.25rem;
        }

        .badge {
            font-size: 0.75em;
            padding: 0.5em 0.75em;
        }

        .pagination {
            justify-content: center;
        }

        .page-link {
            color: #3498db;
        }

        .page-item.active .page-link {
            background-color: #3498db;
            border-color: #3498db;
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

    <!-- Sidebar -->
    <div class="sidebar" id="sidebar">
        <div class="logo">
            MMO Market System
        </div>
        <ul class="menu">
            <!-- Dashboard -->
            <li><a href="/"><i class="fas fa-tachometer-alt"></i> Trang chủ</a></li>

            <!-- User Management -->
            <li class="menu-section">
                <span class="menu-title">Quản lý người dùng</span>
            </li>
            <li><a href="/users" class="active"><i class="fas fa-users"></i> Danh sách người dùng</a></li>
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

    <!-- Main Content Area -->
    <div class="main-content" id="mainContent">
        <!-- Page Header -->
        <div class="page-header">
            <div class="row align-items-center">
                <div class="col-md-6">
                    <h1 class="mb-0">
                        <i class="fas fa-users me-3"></i>Quản lý người dùng
                    </h1>
                    <p class="mb-0 mt-2">Quản lý tài khoản người dùng trong hệ thống</p>
                </div>
                <div class="col-md-6 text-md-end">
                    <a href="/users/register" class="btn btn-light btn-lg">
                        <i class="fas fa-plus me-2"></i>Thêm người dùng
                    </a>
                </div>
            </div>
        </div>

        <!-- Statistics Cards -->
        <div class="row mb-4">
            <div class="col-md-3">
                <div class="stats-card">
                    <div class="d-flex align-items-center">
                        <div class="flex-grow-1">
                            <div class="stats-number">${userStats.total != null ? userStats.total : 0}</div>
                            <div class="text-muted">Tổng người dùng</div>
                        </div>
                        <div class="text-primary">
                            <i class="fas fa-users fa-2x"></i>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stats-card">
                    <div class="d-flex align-items-center">
                        <div class="flex-grow-1">
                            <div class="stats-number text-success">${userStats.active != null ? userStats.active : 0}</div>
                            <div class="text-muted">Đang hoạt động</div>
                        </div>
                        <div class="text-success">
                            <i class="fas fa-user-check fa-2x"></i>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stats-card">
                    <div class="d-flex align-items-center">
                        <div class="flex-grow-1">
                            <div class="stats-number text-warning">${userStats.inactive != null ? userStats.inactive : 0}</div>
                            <div class="text-muted">Không hoạt động</div>
                        </div>
                        <div class="text-warning">
                            <i class="fas fa-user-clock fa-2x"></i>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stats-card">
                    <div class="d-flex align-items-center">
                        <div class="flex-grow-1">
                            <div class="stats-number text-danger">${userStats.suspended != null ? userStats.suspended : 0}</div>
                            <div class="text-muted">Bị khóa</div>
                        </div>
                        <div class="text-danger">
                            <i class="fas fa-user-slash fa-2x"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Search and Filter -->
        <div class="search-card">
            <form method="get" action="/users" class="row g-3">
                <div class="col-md-4">
                    <label for="search" class="form-label">Tìm kiếm</label>
                    <input type="text" class="form-control" id="search" name="search"
                           value="${search}" placeholder="Tên đăng nhập, email, họ tên...">
                </div>
                <div class="col-md-3">
                    <label for="status" class="form-label">Trạng thái</label>
                    <select class="form-select" id="status" name="status">
                        <option value="">Tất cả trạng thái</option>
                        <option value="active" ${status == 'active' ? 'selected' : ''}>Hoạt động</option>
                        <option value="inactive" ${status == 'inactive' ? 'selected' : ''}>Không hoạt động</option>
                        <option value="suspended" ${status == 'suspended' ? 'selected' : ''}>Bị khóa</option>
                    </select>
                </div>
                <div class="col-md-3">
                    <label for="role" class="form-label">Vai trò</label>
                    <select class="form-select" id="role" name="role">
                        <option value="">Tất cả vai trò</option>
                        <option value="BUYER" ${role == 'BUYER' ? 'selected' : ''}>Người mua</option>
                        <option value="SELLER" ${role == 'SELLER' ? 'selected' : ''}>Người bán</option>
                        <option value="ADMIN" ${role == 'ADMIN' ? 'selected' : ''}>Quản trị viên</option>
                        <option value="MODERATOR" ${role == 'MODERATOR' ? 'selected' : ''}>Điều hành viên</option>
                    </select>
                </div>
                <div class="col-md-2">
                    <label class="form-label">&nbsp;</label>
                    <div class="d-grid">
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-search me-1"></i>Tìm kiếm
                        </button>
                    </div>
                </div>
            </form>
        </div>

        <!-- Users Table -->
        <div class="table-card">
            <div class="table-responsive">
                <table class="table table-hover mb-0">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Người dùng</th>
                            <th>Email</th>
                            <th>Vai trò</th>
                            <th>Trạng thái</th>
                            <th>Số dư ví</th>
                            <th>Ngày tạo</th>
                            <th>Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty users.content}">
                                <c:forEach var="user" items="${users.content}">
                                    <tr>
                                        <td>${user.id}</td>
                                        <td>
                                            <div class="d-flex align-items-center">
                                                <c:choose>
                                                    <c:when test="${not empty user.avatarUrl}">
                                                        <img src="${user.avatarUrl}" alt="${user.displayName}" class="avatar me-2">
                                                    </c:when>
                                                    <c:otherwise>
                                                        <div class="avatar me-2 bg-secondary d-flex align-items-center justify-content-center text-white">
                                                            ${fn:substring(user.displayName, 0, 1)}
                                                        </div>
                                                    </c:otherwise>
                                                </c:choose>
                                                <div>
                                                    <div class="fw-bold">${user.displayName}</div>
                                                    <small class="text-muted">@${user.username}</small>
                                                </div>
                                            </div>
                                        </td>
                                        <td>${user.email}</td>
                                        <td>
                                            <c:forEach var="role" items="${user.roles}">
                                                <span class="badge bg-info me-1">${role.name}</span>
                                            </c:forEach>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${user.status == 'active'}">
                                                    <span class="badge bg-success">Hoạt động</span>
                                                </c:when>
                                                <c:when test="${user.status == 'inactive'}">
                                                    <span class="badge bg-warning">Không hoạt động</span>
                                                </c:when>
                                                <c:when test="${user.status == 'suspended'}">
                                                    <span class="badge bg-danger">Bị khóa</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-secondary">${user.status}</span>
                                                </c:otherwise>
                                            </c:choose>
                                            <c:if test="${not user.enabled}">
                                                <span class="badge bg-dark ms-1">Vô hiệu hóa</span>
                                            </c:if>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty user.wallet}">
                                                    <fmt:formatNumber value="${user.wallet.balance}" pattern="#,##0"/> VNĐ
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="text-muted">Chưa có ví</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty user.createdAt}">
                                                    ${user.createdAt.toString().substring(0, 10).replaceAll("-", "/")}
                                                </c:when>
                                                <c:otherwise>
                                                    N/A
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <div class="user-actions">
                                                <a href="/users/${user.id}" class="btn btn-sm btn-info" title="Xem chi tiết">
                                                    <i class="fas fa-eye"></i>
                                                </a>
                                                <c:if test="${user.enabled}">
                                                    <button onclick="toggleUserStatus(${user.id}, false)" class="btn btn-sm btn-warning" title="Vô hiệu hóa">
                                                        <i class="fas fa-ban"></i>
                                                    </button>
                                                </c:if>
                                                <c:if test="${not user.enabled}">
                                                    <button onclick="toggleUserStatus(${user.id}, true)" class="btn btn-sm btn-success" title="Kích hoạt">
                                                        <i class="fas fa-check"></i>
                                                    </button>
                                                </c:if>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="8" class="text-center py-4">
                                        <i class="fas fa-users fa-3x text-muted mb-3 d-block"></i>
                                        <p class="text-muted">Chưa có dữ liệu người dùng</p>
                                        <a href="/users/register" class="btn btn-primary">
                                            <i class="fas fa-plus me-2"></i>Thêm người dùng đầu tiên
                                        </a>
                                    </td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Pagination -->
        <c:if test="${users.totalPages > 1}">
            <div class="d-flex justify-content-center mt-4">
                <nav aria-label="User pagination">
                    <ul class="pagination">
                        <!-- Previous Button -->
                        <li class="page-item ${users.first ? 'disabled' : ''}">
                            <a class="page-link" href="/users?page=${currentPage - 1}&size=${pageSize}&sort=${sortField}&direction=${sortDirection}${not empty search ? '&search='.concat(search) : ''}${not empty status ? '&status='.concat(status) : ''}${not empty role ? '&role='.concat(role) : ''}" tabindex="-1">Trước</a>
                        </li>

                        <!-- Page Numbers -->
                        <c:forEach var="i" begin="0" end="${users.totalPages - 1}">
                            <c:if test="${i < 5 or (i >= currentPage - 2 and i <= currentPage + 2) or i >= users.totalPages - 2}">
                                <li class="page-item ${i == currentPage ? 'active' : ''}">
                                    <a class="page-link" href="/users?page=${i}&size=${pageSize}&sort=${sortField}&direction=${sortDirection}${not empty search ? '&search='.concat(search) : ''}${not empty status ? '&status='.concat(status) : ''}${not empty role ? '&role='.concat(role) : ''}">${i + 1}</a>
                                </li>
                            </c:if>
                        </c:forEach>

                        <!-- Next Button -->
                        <li class="page-item ${users.last ? 'disabled' : ''}">
                            <a class="page-link" href="/users?page=${currentPage + 1}&size=${pageSize}&sort=${sortField}&direction=${sortDirection}${not empty search ? '&search='.concat(search) : ''}${not empty status ? '&status='.concat(status) : ''}${not empty role ? '&role='.concat(role) : ''}">Sau</a>
                        </li>
                    </ul>
                </nav>
            </div>
        </c:if>
    </div>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>

    <!-- Custom JavaScript -->
    <script>
        // Toggle Sidebar
        function toggleSidebar() {
            const sidebar = document.getElementById('sidebar');
            const mainContent = document.getElementById('mainContent');

            sidebar.classList.toggle('active');
            mainContent.classList.toggle('shifted');

            // Store sidebar state
            localStorage.setItem('sidebarOpen', sidebar.classList.contains('active'));
        }

        // Restore sidebar state
        document.addEventListener('DOMContentLoaded', function() {
            const sidebarOpen = localStorage.getItem('sidebarOpen') === 'true';
            if (sidebarOpen) {
                document.getElementById('sidebar').classList.add('active');
                document.getElementById('mainContent').classList.add('shifted');
            }

            // Set active nav link
            const currentPath = window.location.pathname;
            document.querySelectorAll('.sidebar .menu li a').forEach(link => {
                if (link.getAttribute('href') === currentPath) {
                    link.classList.add('active');
                }
            });
        });

        // Toggle user status
        function toggleUserStatus(userId, enabled) {
            const action = enabled ? 'kích hoạt' : 'vô hiệu hóa';

            if (confirm(`Bạn có chắc chắn muốn ${action} người dùng này?`)) {
                const formData = new URLSearchParams();
                formData.append('enabled', enabled);

                fetch(`/users/${userId}/toggle-status`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    },
                    body: formData
                })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        alert(data.message);
                        location.reload();
                    } else {
                        alert('Có lỗi xảy ra: ' + data.message);
                    }
                })
                .catch(error => {
                    alert('Có lỗi xảy ra. Vui lòng thử lại.');
                    console.error('Error:', error);
                });
            }
        }
    </script>
</body>
</html>
