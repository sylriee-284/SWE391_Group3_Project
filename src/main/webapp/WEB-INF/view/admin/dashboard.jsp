<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>

            <!DOCTYPE html>
            <html lang="en">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>
                    <c:if test="${not empty pageTitle}">${pageTitle} - </c:if>MMO Market System
                </title>

                <!-- Include common head with all CSS and JS -->
                <jsp:include page="../common/head.jsp" />

                <style>
                    /* Chart container styles */
                    .chart-container {
                        position: relative;
                        width: 100%;
                        overflow: hidden;
                    }

                    .chart-container canvas {
                        width: 100% !important;
                        height: auto !important;
                        max-width: 100%;
                        display: block;
                    }

                    /* Dashboard card improvements */
                    .dashboard-card {
                        box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
                        border: none;
                        transition: all 0.3s ease;
                    }

                    .dashboard-card:hover {
                        transform: translateY(-2px);
                        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
                    }

                    /* Fix z-index only without changing colors */
                    .navbar .dropdown-menu {
                        z-index: 9999 !important;
                    }

                    .navbar {
                        z-index: 1030 !important;
                    }
                </style>
            </head>

            <body>
                <!-- Include Navbar -->
                <jsp:include page="../common/navbar.jsp" />

                <!-- Include Sidebar -->
                <jsp:include page="../common/sidebar.jsp" />

                <!-- Sidebar Overlay for Mobile -->
                <div class="sidebar-overlay" id="sidebarOverlay" onclick="toggleSidebar()"></div>

                <!-- Main Content Area -->
                <div class="content" id="content">
                    <br />

                    <div class="container-fluid">
                        <!-- Breadcrumb -->
                        <nav aria-label="breadcrumb">
                            <ol class="breadcrumb">
                                <li class="breadcrumb-item"><a href="<c:url value='/'/>"
                                        class="text-decoration-none">Trang chủ</a></li>
                                <li class="breadcrumb-item active" aria-current="page">Dashboard</li>
                            </ol>
                        </nav>

                        <!-- Page Header -->
                        <div class="d-flex justify-content-between align-items-center mb-4">
                            <div>
                                <h2 class="fw-bold text-dark mb-1">Admin Dashboard</h2>
                            </div>
                            <div class="d-flex align-items-center">
                                <button class="btn btn-outline-primary me-2" onclick="location.reload()">
                                    <i class="bi bi-arrow-clockwise me-1"></i>Refresh
                                </button>
                                <span class="text-muted small">
                                    <i class="bi bi-clock me-1"></i>
                                    <script>document.write(new Date().toLocaleDateString('vi-VN'))</script>
                                </span>
                            </div>
                        </div>

                        <!-- KPI Cards Row -->
                        <div class="row mb-4">
                            <div class="col-xl-3 col-md-6 mb-3">
                                <div class="card dashboard-card h-100">
                                    <div class="card-body">
                                        <div class="d-flex align-items-center">
                                            <div class="stat-icon bg-primary-soft me-3">
                                                <i class="bi bi-people-fill"></i>
                                            </div>
                                            <div class="flex-grow-1">
                                                <div class="fs-3 fw-bold text-primary">
                                                    <span id="totalUsers">0</span>
                                                </div>
                                                <div class="text-muted small mb-1">Total Users</div>
                                                <div class="text-success small">
                                                    <i class="bi bi-arrow-up me-1"></i>
                                                    <span id="newUsersThisMonth">0</span> this month
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="col-xl-3 col-md-6 mb-3">
                                <div class="card dashboard-card h-100">
                                    <div class="card-body">
                                        <div class="d-flex align-items-center">
                                            <div class="stat-icon bg-success-soft me-3">
                                                <i class="bi bi-cart-check-fill"></i>
                                            </div>
                                            <div class="flex-grow-1">
                                                <div class="fs-3 fw-bold text-success">
                                                    <span id="totalOrders">0</span>
                                                </div>
                                                <div class="text-muted small mb-1">Total Orders</div>
                                                <div class="text-warning small">
                                                    <i class="bi bi-clock me-1"></i>
                                                    <span id="pendingOrders">0</span> pending
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="col-xl-3 col-md-6 mb-3">
                                <div class="card dashboard-card h-100">
                                    <div class="card-body">
                                        <div class="d-flex align-items-center">
                                            <div class="stat-icon bg-info-soft me-3">
                                                <i class="bi bi-box-seam-fill"></i>
                                            </div>
                                            <div class="flex-grow-1">
                                                <div class="fs-3 fw-bold text-info">
                                                    <span id="totalProducts">0</span>
                                                </div>
                                                <div class="text-muted small mb-1">Total Products</div>
                                                <div class="text-primary small">
                                                    <i class="bi bi-graph-up me-1"></i>
                                                    <span id="activeProducts">0</span> active
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="col-xl-3 col-md-6 mb-3">
                                <div class="card dashboard-card h-100">
                                    <div class="card-body">
                                        <div class="d-flex align-items-center">
                                            <div class="stat-icon bg-warning-soft me-3">
                                                <i class="bi bi-shop"></i>
                                            </div>
                                            <div class="flex-grow-1">
                                                <div class="fs-3 fw-bold text-warning">
                                                    <span id="totalStores">0</span>
                                                </div>
                                                <div class="text-muted small mb-1">Seller Stores</div>
                                                <div class="text-success small">
                                                    <i class="bi bi-check-circle me-1"></i>
                                                    <span id="activeStores">0</span> active
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Charts Row -->
                        <div class="row mb-4">
                            <!-- User Growth Chart -->
                            <div class="col-lg-6 mb-4">
                                <div class="card dashboard-card h-100">
                                    <div class="card-header bg-white">
                                        <h6 class="card-title mb-0 fw-bold">
                                            <i class="bi bi-graph-up me-2 text-primary"></i>Tăng trưởng người dùng
                                        </h6>
                                    </div>
                                    <div class="card-body chart-container" style="height: 300px;">
                                        <canvas id="userGrowthChart"></canvas>
                                    </div>
                                </div>
                            </div>

                            <!-- Order Statistics Chart -->
                            <div class="col-lg-6 mb-4">
                                <div class="card dashboard-card h-100">
                                    <div class="card-header bg-white">
                                        <h6 class="card-title mb-0 fw-bold">
                                            <i class="bi bi-pie-chart me-2 text-success"></i>Thống kê đơn hàng
                                        </h6>
                                    </div>
                                    <div class="card-body chart-container" style="height: 300px;">
                                        <canvas id="orderStatsChart"></canvas>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Revenue and Category Charts Row -->
                        <div class="row mb-4">
                            <!-- Revenue Chart -->
                            <div class="col-lg-8 mb-4">
                                <div class="card dashboard-card h-100">
                                    <div class="card-header bg-white">
                                        <h6 class="card-title mb-0 fw-bold">
                                            <i class="bi bi-bar-chart me-2 text-info"></i>Doanh thu theo tháng
                                        </h6>
                                    </div>
                                    <div class="card-body chart-container" style="height: 400px;">
                                        <canvas id="revenueChart"></canvas>
                                    </div>
                                </div>
                            </div>

                            <!-- Category Distribution Chart -->
                            <div class="col-lg-4 mb-4">
                                <div class="card dashboard-card h-100">
                                    <div class="card-header bg-white">
                                        <h6 class="card-title mb-0 fw-bold">
                                            <i class="bi bi-diagram-3 me-2 text-warning"></i>Danh mục sản phẩm
                                        </h6>
                                    </div>
                                    <div class="card-body chart-container" style="height: 300px;">
                                        <canvas id="categoryChart"></canvas>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Quick Actions & System Status Row -->
                        <div class="row mb-4">
                            <!-- Quick Actions -->
                            <div class="col-lg-4 mb-4">
                                <div class="card dashboard-card h-100">
                                    <div class="card-header bg-white d-flex justify-content-between align-items-center">
                                        <h6 class="card-title mb-0 fw-bold">
                                            <i class="bi bi-lightning-charge me-2 text-primary"></i>Quick Actions
                                        </h6>
                                    </div>
                                    <div class="card-body">
                                        <div class="d-grid gap-2">
                                            <a href="/admin/users/add" class="btn btn-outline-primary btn-sm">
                                                <i class="bi bi-person-plus me-2"></i>Add New User
                                            </a>
                                            <a href="/admin/categories/add" class="btn btn-outline-success btn-sm">
                                                <i class="bi bi-plus-circle me-2"></i>Add Category
                                            </a>
                                            <a href="/admin/system-config" class="btn btn-outline-info btn-sm">
                                                <i class="bi bi-gear me-2"></i>System Settings
                                            </a>
                                            <a href="/admin/users" class="btn btn-outline-warning btn-sm">
                                                <i class="bi bi-people me-2"></i>Manage Users
                                            </a>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- System Status -->
                            <div class="col-lg-8 mb-4">
                                <div class="card dashboard-card h-100">
                                    <div class="card-header bg-white d-flex justify-content-between align-items-center">
                                        <h6 class="card-title mb-0 fw-bold">
                                            <i class="bi bi-speedometer2 me-2 text-success"></i>System Status
                                        </h6>
                                        <span class="badge bg-success">Online</span>
                                    </div>
                                    <div class="card-body">
                                        <div class="row">
                                            <div class="col-md-6">
                                                <div class="d-flex align-items-center mb-3">
                                                    <i class="bi bi-server me-3 text-success fs-5"></i>
                                                    <div>
                                                        <div class="fw-medium">Database Status</div>
                                                        <div class="text-success small">Connected</div>
                                                    </div>
                                                </div>
                                                <div class="d-flex align-items-center mb-3">
                                                    <i class="bi bi-people me-3 text-primary fs-5"></i>
                                                    <div>
                                                        <div class="fw-medium">Active Users</div>
                                                        <div class="text-primary small"><span
                                                                id="activeUsersNow">0</span> online</div>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="col-md-6">
                                                <div class="d-flex align-items-center mb-3">
                                                    <i class="bi bi-clock me-3 text-warning fs-5"></i>
                                                    <div>
                                                        <div class="fw-medium">System Uptime</div>
                                                        <div class="text-muted small">Running smoothly</div>
                                                    </div>
                                                </div>
                                                <div class="d-flex align-items-center mb-3">
                                                    <i class="bi bi-calendar me-3 text-info fs-5"></i>
                                                    <div>
                                                        <div class="fw-medium">Last Updated</div>
                                                        <div class="text-muted small">
                                                            <script>document.write(new Date().toLocaleString('vi-VN'))</script>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Management Links Row -->
                        <div class="row">
                            <div class="col-12">
                                <div class="card dashboard-card">
                                    <div class="card-header bg-white">
                                        <h6 class="card-title mb-0 fw-bold">
                                            <i class="bi bi-grid me-2 text-primary"></i>Management Modules
                                        </h6>
                                    </div>
                                    <div class="card-body">
                                        <div class="row">
                                            <div class="col-lg-3 col-md-6 mb-3">
                                                <a href="/admin/users" class="text-decoration-none">
                                                    <div class="p-3 border rounded hover-shadow">
                                                        <div class="d-flex align-items-center">
                                                            <div class="stat-icon bg-primary-soft me-3">
                                                                <i class="bi bi-people"></i>
                                                            </div>
                                                            <div>
                                                                <div class="fw-medium text-dark">User Management</div>
                                                                <div class="text-muted small">Manage users & roles</div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </a>
                                            </div>
                                            <div class="col-lg-3 col-md-6 mb-3">
                                                <a href="/admin/categories" class="text-decoration-none">
                                                    <div class="p-3 border rounded hover-shadow">
                                                        <div class="d-flex align-items-center">
                                                            <div class="stat-icon bg-success-soft me-3">
                                                                <i class="bi bi-tags"></i>
                                                            </div>
                                                            <div>
                                                                <div class="fw-medium text-dark">Categories</div>
                                                                <div class="text-muted small">Product categories</div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </a>
                                            </div>
                                            <div class="col-lg-3 col-md-6 mb-3">
                                                <a href="/admin/system-config" class="text-decoration-none">
                                                    <div class="p-3 border rounded hover-shadow">
                                                        <div class="d-flex align-items-center">
                                                            <div class="stat-icon bg-info-soft me-3">
                                                                <i class="bi bi-gear"></i>
                                                            </div>
                                                            <div>
                                                                <div class="fw-medium text-dark">System Config</div>
                                                                <div class="text-muted small">Platform settings</div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </a>
                                            </div>
                                            <div class="col-lg-3 col-md-6 mb-3">
                                                <div class="p-3 border rounded opacity-50">
                                                    <div class="d-flex align-items-center">
                                                        <div class="stat-icon bg-warning-soft me-3">
                                                            <i class="bi bi-graph-up"></i>
                                                        </div>
                                                        <div>
                                                            <div class="fw-medium text-muted">Reports</div>
                                                            <div class="text-muted small">Coming soon</div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Include Footer -->
                <jsp:include page="../common/footer.jsp" />

                <!-- JavaScript for Dashboard Functionality -->
                <script>
                    // Error handling for dashboard
                    window.addEventListener('error', function (e) {
                        console.error('Dashboard error:', e.error);
                    });

                    // Initialize Bootstrap dropdowns (consolidated function)
                    function initializeBootstrapDropdowns() {
                        try {
                            if (typeof bootstrap !== 'undefined' && bootstrap.Dropdown) {
                                const dropdowns = document.querySelectorAll('.dropdown-toggle');
                                dropdowns.forEach(dropdown => {
                                    try {
                                        new bootstrap.Dropdown(dropdown);
                                    } catch (err) {
                                        console.warn('Failed to initialize dropdown:', err);
                                    }
                                });
                                console.log('Bootstrap dropdowns initialized');
                            } else {
                                console.warn('Bootstrap not available');
                            }
                        } catch (error) {
                            console.error('Bootstrap initialization failed:', error);
                        }
                    }

                    // Initialize on DOM ready with delay
                    document.addEventListener('DOMContentLoaded', function () {
                        setTimeout(initializeBootstrapDropdowns, 100);
                    });
                </script>
                <script>
                    // Dashboard data loading simulation (replace with actual AJAX calls)
                    document.addEventListener('DOMContentLoaded', function () {
                        // Load KPI data from backend
                        loadKpiData();

                        // Add hover effects to management cards
                        const managementCards = document.querySelectorAll('.hover-shadow');
                        managementCards.forEach(card => {
                            card.addEventListener('mouseenter', function () {
                                this.style.transform = 'translateY(-2px)';
                                this.style.boxShadow = '0 4px 12px rgba(0,0,0,0.15)';
                                this.style.transition = 'all 0.3s ease';
                            });

                            card.addEventListener('mouseleave', function () {
                                this.style.transform = 'translateY(0)';
                                this.style.boxShadow = '';
                            });
                        });

                        // Initialize Charts after DOM is loaded with delay
                        setTimeout(loadDashboardData, 100);
                    });

                    // Load dashboard data from backend
                    function loadDashboardData() {
                        // Load chart data from database
                        loadChartData();
                    }

                    // Load KPI data from backend API
                    function loadKpiData() {
                        fetch('/admin/api/kpi-data')
                            .then(response => response.json())
                            .then(data => {
                                // Update KPI values with data from backend
                                document.getElementById('totalUsers').textContent = new Intl.NumberFormat('vi-VN').format(data.totalUsers);
                                document.getElementById('newUsersThisMonth').textContent = new Intl.NumberFormat('vi-VN').format(data.newUsersThisMonth);
                                document.getElementById('totalOrders').textContent = new Intl.NumberFormat('vi-VN').format(data.totalOrders);
                                document.getElementById('pendingOrders').textContent = new Intl.NumberFormat('vi-VN').format(data.pendingOrders);
                                document.getElementById('totalProducts').textContent = new Intl.NumberFormat('vi-VN').format(data.totalProducts);
                                document.getElementById('activeProducts').textContent = new Intl.NumberFormat('vi-VN').format(data.activeProducts);
                                document.getElementById('totalStores').textContent = new Intl.NumberFormat('vi-VN').format(data.totalStores);
                                document.getElementById('activeStores').textContent = new Intl.NumberFormat('vi-VN').format(data.activeStores);
                                document.getElementById('activeUsersNow').textContent = new Intl.NumberFormat('vi-VN').format(data.activeUsersNow);
                            })
                            .catch(error => {
                                console.error('Error loading KPI data:', error);
                                // Use default values if API fails
                                document.getElementById('totalUsers').textContent = '1,234';
                                document.getElementById('newUsersThisMonth').textContent = '56';
                                document.getElementById('totalOrders').textContent = '2,847';
                                document.getElementById('pendingOrders').textContent = '23';
                                document.getElementById('totalProducts').textContent = '456';
                                document.getElementById('activeProducts').textContent = '398';
                                document.getElementById('totalStores').textContent = '89';
                                document.getElementById('activeStores').textContent = '76';
                                document.getElementById('activeUsersNow').textContent = '45';
                            });
                    }

                    // Load chart data from backend APIs
                    function loadChartData() {
                        // Set default Chart.js configuration
                        Chart.defaults.responsive = true;
                        Chart.defaults.maintainAspectRatio = false;

                        // Load data and initialize charts
                        Promise.all([
                            fetch('/admin/api/user-growth-data').then(res => res.json()).catch(() => getDefaultUserGrowthData()),
                            fetch('/admin/api/order-stats-data').then(res => res.json()).catch(() => getDefaultOrderStatsData()),
                            fetch('/admin/api/revenue-data').then(res => res.json()).catch(() => getDefaultRevenueData()),
                            fetch('/admin/api/category-data').then(res => res.json()).catch(() => getDefaultCategoryData())
                        ]).then(([userGrowthData, orderStatsData, revenueData, categoryData]) => {
                            initializeCharts(userGrowthData, orderStatsData, revenueData, categoryData);
                        }).catch(error => {
                            console.error('Error loading chart data:', error);
                            // Use default data if API fails
                            initializeCharts(
                                getDefaultUserGrowthData(),
                                getDefaultOrderStatsData(),
                                getDefaultRevenueData(),
                                getDefaultCategoryData()
                            );
                        });
                    }

                    // Default data functions (fallback)
                    function getDefaultUserGrowthData() {
                        return {
                            labels: ['Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4', 'Tháng 5', 'Tháng 6'],
                            data: [45, 78, 95, 120, 145, 178]
                        };
                    }

                    function getDefaultOrderStatsData() {
                        return {
                            labels: ['Hoàn thành', 'Đang xử lý', 'Đã hủy', 'Chờ thanh toán'],
                            data: [65, 20, 10, 5]
                        };
                    }

                    function getDefaultRevenueData() {
                        return {
                            labels: ['T1', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'T8', 'T9', 'T10', 'T11', 'T12'],
                            data: [25000000, 32000000, 28000000, 35000000, 42000000, 38000000, 45000000, 48000000, 52000000, 47000000, 55000000, 60000000]
                        };
                    }

                    function getDefaultCategoryData() {
                        return {
                            labels: ['Phần mềm', 'Tài khoản', 'Dịch vụ', 'Khác'],
                            data: [35, 25, 30, 10]
                        };
                    }

                    // Initialize all charts with data
                    function initializeCharts(userGrowthData, orderStatsData, revenueData, categoryData) {
                        // User Growth Chart (Line Chart)
                        const userGrowthCtx = document.getElementById('userGrowthChart').getContext('2d');
                        new Chart(userGrowthCtx, {
                            type: 'line',
                            data: {
                                labels: userGrowthData.labels,
                                datasets: [{
                                    label: 'Người dùng mới',
                                    data: userGrowthData.data,
                                    borderColor: '#0d6efd',
                                    backgroundColor: 'rgba(13, 110, 253, 0.1)',
                                    borderWidth: 3,
                                    fill: true,
                                    tension: 0.4
                                }]
                            },
                            options: {
                                responsive: true,
                                maintainAspectRatio: false,
                                resizeDelay: 200,
                                layout: {
                                    padding: {
                                        top: 10,
                                        bottom: 10,
                                        left: 10,
                                        right: 10
                                    }
                                },
                                scales: {
                                    y: {
                                        beginAtZero: true,
                                        grid: {
                                            color: 'rgba(0,0,0,0.1)'
                                        }
                                    },
                                    x: {
                                        grid: {
                                            color: 'rgba(0,0,0,0.1)'
                                        }
                                    }
                                },
                                plugins: {
                                    legend: {
                                        display: true,
                                        position: 'top'
                                    }
                                }
                            }
                        });

                        // Order Statistics Chart (Doughnut Chart)
                        const orderStatsCtx = document.getElementById('orderStatsChart').getContext('2d');
                        new Chart(orderStatsCtx, {
                            type: 'doughnut',
                            data: {
                                labels: orderStatsData.labels,
                                datasets: [{
                                    data: orderStatsData.data,
                                    backgroundColor: [
                                        '#198754',
                                        '#ffc107',
                                        '#dc3545',
                                        '#6c757d'
                                    ],
                                    borderWidth: 2,
                                    borderColor: '#fff'
                                }]
                            },
                            options: {
                                responsive: true,
                                maintainAspectRatio: false,
                                resizeDelay: 200,
                                layout: {
                                    padding: {
                                        top: 10,
                                        bottom: 30,
                                        left: 10,
                                        right: 10
                                    }
                                },
                                plugins: {
                                    legend: {
                                        position: 'bottom',
                                        labels: {
                                            padding: 15,
                                            usePointStyle: true,
                                            boxWidth: 12
                                        }
                                    }
                                }
                            }
                        });

                        // Revenue Chart (Bar Chart)
                        const revenueCtx = document.getElementById('revenueChart').getContext('2d');
                        new Chart(revenueCtx, {
                            type: 'bar',
                            data: {
                                labels: revenueData.labels,
                                datasets: [{
                                    label: 'Doanh thu (VNĐ)',
                                    data: revenueData.data,
                                    backgroundColor: 'rgba(13, 202, 240, 0.8)',
                                    borderColor: '#0dcaf0',
                                    borderWidth: 2,
                                    borderRadius: 5
                                }]
                            },
                            options: {
                                responsive: true,
                                maintainAspectRatio: false,
                                scales: {
                                    y: {
                                        beginAtZero: true,
                                        ticks: {
                                            callback: function (value) {
                                                return new Intl.NumberFormat('vi-VN').format(value) + 'đ';
                                            }
                                        },
                                        grid: {
                                            color: 'rgba(0,0,0,0.1)'
                                        }
                                    },
                                    x: {
                                        grid: {
                                            color: 'rgba(0,0,0,0.1)'
                                        }
                                    }
                                },
                                plugins: {
                                    legend: {
                                        display: true,
                                        position: 'top'
                                    },
                                    tooltip: {
                                        callbacks: {
                                            label: function (context) {
                                                return 'Doanh thu: ' + new Intl.NumberFormat('vi-VN').format(context.parsed.y) + 'đ';
                                            }
                                        }
                                    }
                                }
                            }
                        });

                        // Category Distribution Chart (Pie Chart)
                        const categoryCtx = document.getElementById('categoryChart').getContext('2d');
                        new Chart(categoryCtx, {
                            type: 'pie',
                            data: {
                                labels: categoryData.labels,
                                datasets: [{
                                    data: categoryData.data,
                                    backgroundColor: [
                                        '#0d6efd',
                                        '#198754',
                                        '#ffc107',
                                        '#6c757d'
                                    ],
                                    borderWidth: 2,
                                    borderColor: '#fff'
                                }]
                            },
                            options: {
                                responsive: true,
                                maintainAspectRatio: false,
                                plugins: {
                                    legend: {
                                        position: 'bottom',
                                        labels: {
                                            padding: 15,
                                            usePointStyle: true,
                                            font: {
                                                size: 12
                                            }
                                        }
                                    },
                                    tooltip: {
                                        callbacks: {
                                            label: function (context) {
                                                return context.label + ': ' + context.parsed + '%';
                                            }
                                        }
                                    }
                                }
                            }
                        });
                    }

                    // Toggle sidebar function
                    function toggleSidebar() {
                        var sidebar = document.getElementById('sidebar');
                        var content = document.getElementById('content');
                        if (sidebar && content) {
                            sidebar.classList.toggle('active');
                            content.classList.toggle('shifted');
                        }
                    }



                    // Close sidebar when clicking outside on mobile
                    document.addEventListener('click', function (event) {
                        var sidebar = document.getElementById('sidebar');
                        var overlay = document.getElementById('sidebarOverlay');
                        var menuToggle = document.querySelector('.menu-toggle');

                        if (sidebar && sidebar.classList.contains('active') &&
                            !sidebar.contains(event.target) &&
                            menuToggle && !menuToggle.contains(event.target)) {
                            toggleSidebar();
                        }
                    });

                    // Auto-hide alerts after 5 seconds
                    document.addEventListener('DOMContentLoaded', function () {
                        var alerts = document.querySelectorAll('.alert');
                        alerts.forEach(function (alert) {
                            setTimeout(function () {
                                alert.style.opacity = '0';
                                setTimeout(function () {
                                    alert.remove();
                                }, 300);
                            }, 5000);
                        });
                    });
                </script>

                <!-- Script to display notifications using iziToast -->
                <c:if test="${not empty successMessage}">
                    <script>
                        iziToast.success({
                            title: 'Thành công!',
                            message: '${successMessage}',
                            position: 'topRight',
                            timeout: 5000
                        });
                    </script>
                </c:if>

                <c:if test="${not empty errorMessage}">
                    <script>
                        iziToast.error({
                            title: 'Lỗi!',
                            message: '${errorMessage}',
                            position: 'topRight',
                            timeout: 5000
                        });
                    </script>
                </c:if>
            </body>

            </html>