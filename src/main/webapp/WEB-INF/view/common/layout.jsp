<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${pageTitle} - TaphoaMMO</title>
    
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
        }

        .sidebar.active {
            left: 0;
        }

        .sidebar .nav-link {
            color: #bdc3c7 !important;
            padding: 12px 20px;
            border-bottom: 1px solid rgba(255,255,255,0.1);
            transition: all 0.3s ease;
        }

        .sidebar .nav-link:hover,
        .sidebar .nav-link.active {
            background-color: var(--accent-color);
            color: white !important;
            padding-left: 30px;
        }

        .sidebar .nav-link i {
            width: 20px;
            margin-right: 10px;
        }

        /* Main Content */
        .main-content {
            margin-left: 0;
            padding: 20px;
            transition: margin-left 0.3s ease;
            min-height: calc(100vh - 60px);
        }

        .main-content.shifted {
            margin-left: var(--sidebar-width);
        }

        /* Card Styles */
        .card {
            border: none;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            margin-bottom: 20px;
        }

        .card-header {
            background-color: var(--primary-color);
            color: white;
            border-radius: 10px 10px 0 0 !important;
            padding: 15px 20px;
        }

        /* Button Styles */
        .btn-primary {
            background-color: var(--accent-color);
            border-color: var(--accent-color);
        }

        .btn-primary:hover {
            background-color: #2980b9;
            border-color: #2980b9;
        }

        /* Table Styles */
        .table {
            background-color: white;
        }

        .table th {
            background-color: #f8f9fa;
            border-top: none;
            font-weight: 600;
        }

        /* Alert Styles */
        .alert {
            border-radius: 8px;
            border: none;
        }

        /* Form Styles */
        .form-control:focus {
            border-color: var(--accent-color);
            box-shadow: 0 0 0 0.2rem rgba(52, 152, 219, 0.25);
        }

        /* Badge Styles */
        .badge {
            font-size: 0.75em;
            padding: 0.5em 0.75em;
        }

        /* Responsive */
        @media (max-width: 768px) {
            .main-content.shifted {
                margin-left: 0;
            }
            
            .sidebar {
                width: 100%;
                left: -100%;
            }
        }

        /* Loading Spinner */
        .spinner-border-sm {
            width: 1rem;
            height: 1rem;
        }

        /* Custom utilities */
        .text-muted-light {
            color: #95a5a6 !important;
        }

        .bg-gradient-primary {
            background: linear-gradient(135deg, var(--primary-color), var(--accent-color));
        }
    </style>
    
    <!-- Additional CSS -->
    <c:if test="${not empty additionalCSS}">
        ${additionalCSS}
    </c:if>
</head>
<body>
    <!-- Navbar -->
    <nav class="navbar navbar-expand-lg navbar-custom">
        <div class="container-fluid">
            <button class="btn btn-link text-white me-3" onclick="toggleSidebar()" id="sidebarToggle">
                <i class="fas fa-bars"></i>
            </button>
            
            <a class="navbar-brand" href="/">
                <i class="fas fa-store me-2"></i>TaphoaMMO
            </a>
            
            <div class="navbar-nav ms-auto">
                <div class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown">
                        <i class="fas fa-user-circle me-1"></i>
                        <c:choose>
                            <c:when test="${not empty currentUser}">
                                ${currentUser.displayName}
                            </c:when>
                            <c:otherwise>
                                Guest
                            </c:otherwise>
                        </c:choose>
                    </a>
                    <ul class="dropdown-menu">
                        <li><a class="dropdown-item" href="/users/profile"><i class="fas fa-user me-2"></i>Hồ sơ</a></li>
                        <li><a class="dropdown-item" href="/users/change-password"><i class="fas fa-key me-2"></i>Đổi mật khẩu</a></li>
                        <li><hr class="dropdown-divider"></li>
                        <li><a class="dropdown-item" href="/auth/logout"><i class="fas fa-sign-out-alt me-2"></i>Đăng xuất</a></li>
                    </ul>
                </div>
            </div>
        </div>
    </nav>

    <!-- Sidebar -->
    <div class="sidebar" id="sidebar">
        <div class="p-3">
            <h5 class="text-white mb-3">
                <i class="fas fa-tachometer-alt me-2"></i>Quản lý
            </h5>
        </div>
        
        <nav class="nav flex-column">
            <a class="nav-link" href="/">
                <i class="fas fa-home"></i>Trang chủ
            </a>
            <a class="nav-link" href="/users">
                <i class="fas fa-users"></i>Quản lý người dùng
            </a>
            <a class="nav-link" href="/stores">
                <i class="fas fa-store"></i>Quản lý cửa hàng
            </a>
            <a class="nav-link" href="/products">
                <i class="fas fa-box"></i>Quản lý sản phẩm
            </a>
            <a class="nav-link" href="/orders">
                <i class="fas fa-shopping-cart"></i>Quản lý đơn hàng
            </a>
            <a class="nav-link" href="/wallets">
                <i class="fas fa-wallet"></i>Quản lý ví
            </a>
            <a class="nav-link" href="/reports">
                <i class="fas fa-chart-bar"></i>Báo cáo
            </a>
            <a class="nav-link" href="/settings">
                <i class="fas fa-cog"></i>Cài đặt
            </a>
        </nav>
    </div>

    <!-- Main Content -->
    <div class="main-content" id="mainContent">
        <!-- Flash Messages -->
        <c:if test="${not empty success}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="fas fa-check-circle me-2"></i>${success}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        
        <c:if test="${not empty error}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="fas fa-exclamation-circle me-2"></i>${error}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        
        <c:if test="${not empty warning}">
            <div class="alert alert-warning alert-dismissible fade show" role="alert">
                <i class="fas fa-exclamation-triangle me-2"></i>${warning}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        
        <c:if test="${not empty info}">
            <div class="alert alert-info alert-dismissible fade show" role="alert">
                <i class="fas fa-info-circle me-2"></i>${info}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <!-- Page Content -->
        <jsp:include page="${contentPage}" />
    </div>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    
    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    
    <!-- Common JavaScript -->
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
            document.querySelectorAll('.sidebar .nav-link').forEach(link => {
                if (link.getAttribute('href') === currentPath) {
                    link.classList.add('active');
                }
            });
        });

        // Auto-hide alerts after 5 seconds
        setTimeout(function() {
            $('.alert').fadeOut('slow');
        }, 5000);
    </script>
    
    <!-- Additional JavaScript -->
    <c:if test="${not empty additionalJS}">
        ${additionalJS}
    </c:if>
</body>
</html>
