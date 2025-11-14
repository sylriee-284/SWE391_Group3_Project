<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>

            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>
                    <c:if test="${not empty pageTitle}">${pageTitle} - </c:if>Bảng Điều Khiển Admin - MMO Market
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
                                <h2 class="fw-bold text-dark mb-1">Bảng Điều Khiển Admin</h2>
                            </div>
                            <div class="d-flex align-items-center">
                                <button class="btn btn-outline-primary me-2" onclick="location.reload()">
                                    <i class="bi bi-arrow-clockwise me-1"></i>Làm mới
                                </button>
                                <span class="text-muted small">
                                    <i class="bi bi-clock me-1"></i>
                                    <script>document.write(new Date().toLocaleDateString('vi-VN'))</script>
                                </span>
                            </div>
                        </div>

                        <!-- KPI Cards Row -->
                        <div class="row mb-4">
                            <div class="col-xl-4 col-md-6 mb-3">
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
                                                <div class="text-muted small mb-1">Tổng Đơn Hàng</div>
                                                <div class="text-warning small">
                                                    <i class="bi bi-clock me-1"></i>
                                                    <span id="pendingOrders">0</span> chờ xử lý
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="col-xl-4 col-md-6 mb-3">
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
                                                <div class="text-muted small mb-1">Tổng Sản Phẩm</div>
                                                <div class="text-primary small">
                                                    <i class="bi bi-graph-up me-1"></i>
                                                    <span id="activeProducts">0</span> hoạt động
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="col-xl-4 col-md-6 mb-3">
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
                                                <div class="text-muted small mb-1">Cửa Hàng</div>
                                                <div class="text-success small">
                                                    <i class="bi bi-check-circle me-1"></i>
                                                    <span id="activeStores">0</span> hoạt động
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Charts Row 1 -->
                        <div class="row mb-4">
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

                            <!-- Wallet Transaction Chart -->
                            <div class="col-lg-6 mb-4">
                                <div class="card dashboard-card h-100">
                                    <div class="card-header bg-white">
                                        <h6 class="card-title mb-0 fw-bold">
                                            <i class="bi bi-wallet2 me-2 text-primary"></i>Giao dịch ví
                                        </h6>
                                    </div>
                                    <div class="card-body chart-container" style="height: 300px;">
                                        <canvas id="walletTransactionChart"></canvas>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Charts Row 2 -->
                        <div class="row mb-4">
                            <!-- Revenue Chart -->
                            <div class="col-lg-12 mb-4">
                                <div class="card dashboard-card h-100">
                                    <div class="card-header bg-white">
                                        <h6 class="card-title mb-0 fw-bold">
                                            <i class="bi bi-graph-up me-2 text-info"></i>Doanh thu theo tháng
                                        </h6>
                                    </div>
                                    <div class="card-body chart-container" style="height: 350px;">
                                        <canvas id="revenueChart"></canvas>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Charts Row 3 -->
                        <div class="row mb-4">
                            <!-- Top Products Chart -->
                            <div class="col-lg-12 mb-4">
                                <div class="card dashboard-card h-100">
                                    <div class="card-header bg-white">
                                        <h6 class="card-title mb-0 fw-bold">
                                            <i class="bi bi-bar-chart me-2 text-danger"></i>Top sản phẩm bán chạy
                                        </h6>
                                    </div>
                                    <div class="card-body chart-container" style="height: 300px;">
                                        <canvas id="topProductsChart"></canvas>
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
                                document.getElementById('totalOrders').textContent = new Intl.NumberFormat('vi-VN').format(data.totalOrders);
                                document.getElementById('pendingOrders').textContent = new Intl.NumberFormat('vi-VN').format(data.pendingOrders);
                                document.getElementById('totalProducts').textContent = new Intl.NumberFormat('vi-VN').format(data.totalProducts);
                                document.getElementById('activeProducts').textContent = new Intl.NumberFormat('vi-VN').format(data.activeProducts);
                                document.getElementById('totalStores').textContent = new Intl.NumberFormat('vi-VN').format(data.totalStores);
                                document.getElementById('activeStores').textContent = new Intl.NumberFormat('vi-VN').format(data.activeStores);
                            })
                            .catch(error => {
                                console.error('Error loading KPI data:', error);
                                // Use default values if API fails
                                document.getElementById('totalOrders').textContent = '2,847';
                                document.getElementById('pendingOrders').textContent = '23';
                                document.getElementById('totalProducts').textContent = '456';
                                document.getElementById('activeProducts').textContent = '398';
                                document.getElementById('totalStores').textContent = '89';
                                document.getElementById('activeStores').textContent = '76';
                            });
                    }

                    // Load chart data from backend APIs
                    function loadChartData() {
                        // Set default Chart.js configuration
                        Chart.defaults.responsive = true;
                        Chart.defaults.maintainAspectRatio = false;

                        // Load data and initialize charts
                        Promise.all([
                            fetch('/admin/api/order-stats-data').then(res => res.json()).catch(() => getDefaultOrderStatsData()),
                            fetch('/admin/api/wallet-transaction-data').then(res => res.json()).catch(() => getDefaultWalletTransactionData()),
                            fetch('/admin/api/revenue-data').then(res => res.json()).catch(() => getDefaultRevenueData()),
                            fetch('/admin/api/top-products-data').then(res => res.json()).catch(() => getDefaultTopProductsData())
                        ]).then(([orderStatsData, walletTransactionData, revenueData, topProductsData]) => {
                            initializeCharts(orderStatsData, walletTransactionData, revenueData, topProductsData);
                        }).catch(error => {
                            console.error('Error loading chart data:', error);
                            // Use default data if API fails
                            initializeCharts(
                                getDefaultOrderStatsData(),
                                getDefaultWalletTransactionData(),
                                getDefaultRevenueData(),
                                getDefaultTopProductsData()
                            );
                        });
                    }

                    // Default data functions (fallback)
                    function getDefaultOrderStatsData() {
                        return {
                            labels: ['Hoàn thành', 'Đang xử lý', 'Đã hủy', 'Chờ thanh toán'],
                            data: [65, 20, 10, 5]
                        };
                    }

                    function getDefaultWalletTransactionData() {
                        return {
                            labels: ['Nạp tiền', 'Rút tiền', 'Thanh toán', 'Hoàn tiền'],
                            data: [45, 25, 20, 10]
                        };
                    }

                    function getDefaultRevenueData() {
                        return {
                            labels: ['T1', 'T2', 'T3', 'T4', 'T5', 'T6'],
                            data: [25000000, 32000000, 28000000, 35000000, 42000000, 38000000]
                        };
                    }

                    function getDefaultTopProductsData() {
                        return {
                            labels: ['Sản phẩm A', 'Sản phẩm B', 'Sản phẩm C', 'Sản phẩm D', 'Sản phẩm E'],
                            data: [120, 95, 78, 65, 52]
                        };
                    }



                    // Initialize charts with data
                    function initializeCharts(orderStatsData, walletTransactionData, revenueData, topProductsData) {
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

                        // Wallet Transaction Chart (Pie Chart)
                        const walletTransactionCtx = document.getElementById('walletTransactionChart').getContext('2d');
                        new Chart(walletTransactionCtx, {
                            type: 'pie',
                            data: {
                                labels: walletTransactionData.labels,
                                datasets: [{
                                    data: walletTransactionData.data,
                                    backgroundColor: [
                                        '#0d6efd',
                                        '#dc3545',
                                        '#ffc107',
                                        '#198754',
                                        '#6610f2',
                                        '#fd7e14'
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
                                                size: 11
                                            }
                                        }
                                    }
                                }
                            }
                        });

                        // Revenue Chart (Line Chart)
                        const revenueCtx = document.getElementById('revenueChart').getContext('2d');
                        new Chart(revenueCtx, {
                            type: 'line',
                            data: {
                                labels: revenueData.labels,
                                datasets: [{
                                    label: 'Doanh thu (VNĐ)',
                                    data: revenueData.data,
                                    borderColor: '#0dcaf0',
                                    backgroundColor: 'rgba(13, 202, 240, 0.1)',
                                    borderWidth: 3,
                                    fill: true,
                                    tension: 0.4
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
                                        }
                                    }
                                },
                                plugins: {
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

                        // Top Products Chart (Horizontal Bar Chart)
                        const topProductsCtx = document.getElementById('topProductsChart').getContext('2d');
                        new Chart(topProductsCtx, {
                            type: 'bar',
                            data: {
                                labels: topProductsData.labels,
                                datasets: [{
                                    label: 'Số lượng bán',
                                    data: topProductsData.data,
                                    backgroundColor: 'rgba(220, 53, 69, 0.8)',
                                    borderColor: '#dc3545',
                                    borderWidth: 1
                                }]
                            },
                            options: {
                                responsive: true,
                                maintainAspectRatio: false,
                                indexAxis: 'y',
                                scales: {
                                    x: {
                                        beginAtZero: true
                                    }
                                },
                                plugins: {
                                    legend: {
                                        display: false
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