<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
            <%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>

                <!DOCTYPE html>
                <html lang="vi">

                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>Bảng điều khiển Người bán - MMO Marketplace</title>

                    <!-- Include common head with all CSS and JS -->
                    <jsp:include page="../common/head.jsp" />

                    <!-- Chart.js -->
                    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
                    <!-- Custom Dashboard CSS -->
                    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/resources/css/dashboard.css">

                    <!-- Custom Alerts Style -->
                    <style>
                        /* Alerts list scrollbar */
                        .alerts-list {
                            scrollbar-width: thin;
                            scrollbar-color: #ccc #f8f9fa;
                        }

                        .alerts-list::-webkit-scrollbar {
                            width: 6px;
                        }

                        .alerts-list::-webkit-scrollbar-track {
                            background: #f8f9fa;
                        }

                        .alerts-list::-webkit-scrollbar-thumb {
                            background: #ccc;
                            border-radius: 3px;
                        }

                        .alerts-list::-webkit-scrollbar-thumb:hover {
                            background: #aaa;
                        }

                        /* Alert item hover */
                        .alert-item {
                            transition: background-color 0.15s ease;
                            cursor: pointer;
                        }

                        .alert-item:hover {
                            background-color: #e9ecef;
                        }

                        /* Alert link styling */
                        .alerts-list a:hover .alert-item {
                            background-color: #e9ecef;
                        }

                        /* Header hover */
                        .card-header[data-bs-toggle="collapse"] {
                            user-select: none;
                            transition: opacity 0.15s ease;
                        }

                        .card-header[data-bs-toggle="collapse"]:hover {
                            opacity: 0.9;
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
                        <div class="container-fluid">
                            <h2 class="mb-4">
                                <i class="fas fa-tachometer-alt"></i> Tổng quan Bảng điều khiển
                            </h2>

                            <!-- Navigation Tabs -->
                            <ul class="nav nav-tabs mb-4">
                                <li class="nav-item">
                                    <a class="nav-link active"
                                        href="${pageContext.request.contextPath}/seller/dashboard">
                                        <i class="fas fa-chart-line"></i> Tổng quan
                                    </a>
                                </li>
                                <li class="nav-item">
                                    <a class="nav-link"
                                        href="${pageContext.request.contextPath}/seller/dashboard/sales">
                                        <i class="fas fa-shopping-cart"></i> Bán hàng & Ký quỹ
                                    </a>
                                </li>
                                <li class="nav-item">
                                    <a class="nav-link"
                                        href="${pageContext.request.contextPath}/seller/dashboard/products">
                                        <i class="fas fa-box"></i> Sản phẩm & Kho hàng
                                    </a>
                                </li>
                            </ul>

                            <!-- Filters Section -->
                            <div class="card mb-4">
                                <div class="card-header bg-light">
                                    <h5 class="mb-0"><i class="fas fa-filter"></i> Bộ lọc</h5>
                                </div>
                                <div class="card-body">
                                    <form method="get" action="${pageContext.request.contextPath}/seller/dashboard"
                                        id="filterForm">
                                        <div class="d-flex flex-wrap align-items-end gap-3">
                                            <!-- Time Filter -->
                                            <div class="form-group mb-0" style="min-width:200px;">
                                                <label class="form-label">Thời gian</label>
                                                <select class="form-select" name="timeFilter" id="timeFilter">
                                                    <option value="today" ${dashboard.timeFilter=='today' ? 'selected'
                                                        : '' }>Hôm nay</option>
                                                    <option value="7days" ${dashboard.timeFilter=='7days' ? 'selected'
                                                        : '' }>7 ngày qua</option>
                                                    <option value="30days" ${dashboard.timeFilter=='30days' ? 'selected'
                                                        : '' }>30 ngày qua</option>
                                                    <option value="custom" ${dashboard.timeFilter=='custom' ? 'selected'
                                                        : '' }>Tùy chỉnh</option>
                                                </select>
                                            </div>

                                            <!-- Custom Date Range -->
                                            <div class="form-group mb-0" id="customDateRange" <c:if
                                                test="${dashboard.timeFilter == 'custom'}">style="display: block;
                                                min-width:180px;"</c:if>
                                                <c:if test="${dashboard.timeFilter != 'custom'}">style="display: none;
                                                    min-width:180px;"</c:if>>
                                                <label class="form-label">Từ ngày</label>
                                                <input type="date" class="form-control" name="startDate"
                                                    value="${dashboard.startDate}">
                                            </div>
                                            <div class="form-group mb-0" id="customDateRangeEnd" <c:if
                                                test="${dashboard.timeFilter == 'custom'}">style="display: block;
                                                min-width:180px;"</c:if>
                                                <c:if test="${dashboard.timeFilter != 'custom'}">style="display: none;
                                                    min-width:180px;"</c:if>>
                                                <label class="form-label">Đến ngày</label>
                                                <input type="date" class="form-control" name="endDate"
                                                    value="${dashboard.endDate}">
                                            </div>

                                            <!-- Action buttons aligned to the right -->
                                            <div class="ms-auto d-flex gap-2">
                                                <button type="submit" class="btn btn-primary">
                                                    <i class="fas fa-search"></i> Áp dụng
                                                </button>
                                                <a href="${pageContext.request.contextPath}/seller/dashboard"
                                                    class="btn btn-secondary">
                                                    <i class="fas fa-redo"></i> Đặt lại
                                                </a>
                                            </div>
                                        </div>
                                    </form>
                                </div>
                            </div>

                            <!-- KPI Cards Row -->
                            <div class="row mb-4">
                                <!-- Revenue Card -->
                                <div class="col-xl-3 col-md-6 mb-3">
                                    <div class="card kpi-card border-left-primary">
                                        <div class="card-body">
                                            <div class="row no-gutters align-items-center">
                                                <div class="col mr-2">
                                                    <div class="kpi-title">${dashboard.revenue.title}</div>
                                                    <div class="kpi-value">
                                                        <fmt:formatNumber value="${dashboard.revenue.value}"
                                                            type="number" groupingUsed="true" /> VND
                                                    </div>
                                                    <div class="kpi-change ${dashboard.revenue.changeDirection}">
                                                        <i
                                                            class="fas fa-arrow-${dashboard.revenue.changeDirection == 'up' ? 'up' : 'down'}"></i>
                                                        <fmt:formatNumber value="${dashboard.revenue.changePercent}"
                                                            pattern="0.00" />%
                                                    </div>
                                                    <small class="text-muted">${dashboard.revenue.description}</small>
                                                </div>
                                                <div class="col-auto">
                                                    <i class="fas fa-dollar-sign fa-2x text-gray-300"></i>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <!-- Orders Card -->
                                <div class="col-xl-3 col-md-6 mb-3">
                                    <div class="card kpi-card border-left-success">
                                        <div class="card-body">
                                            <div class="row no-gutters align-items-center">
                                                <div class="col mr-2">
                                                    <div class="kpi-title">${dashboard.orderCount.title}</div>
                                                    <div class="kpi-value">
                                                        <fmt:formatNumber value="${dashboard.orderCount.value}"
                                                            type="number" />
                                                    </div>
                                                    <div class="kpi-change ${dashboard.orderCount.changeDirection}">
                                                        <i
                                                            class="fas fa-arrow-${dashboard.orderCount.changeDirection == 'up' ? 'up' : 'down'}"></i>
                                                        <fmt:formatNumber value="${dashboard.orderCount.changePercent}"
                                                            pattern="0.00" />%
                                                    </div>
                                                    <small
                                                        class="text-muted">${dashboard.orderCount.description}</small>
                                                </div>
                                                <div class="col-auto">
                                                    <i class="fas fa-shopping-cart fa-2x text-gray-300"></i>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <!-- AOV Card -->
                                <div class="col-xl-3 col-md-6 mb-3">
                                    <div class="card kpi-card border-left-info">
                                        <div class="card-body">
                                            <div class="row no-gutters align-items-center">
                                                <div class="col mr-2">
                                                    <div class="kpi-title">${dashboard.averageOrderValue.title}</div>
                                                    <div class="kpi-value">
                                                        <fmt:formatNumber value="${dashboard.averageOrderValue.value}"
                                                            type="number" groupingUsed="true" /> VND
                                                    </div>
                                                    <div
                                                        class="kpi-change ${dashboard.averageOrderValue.changeDirection}">
                                                        <i
                                                            class="fas fa-arrow-${dashboard.averageOrderValue.changeDirection == 'up' ? 'up' : 'down'}"></i>
                                                        <fmt:formatNumber
                                                            value="${dashboard.averageOrderValue.changePercent}"
                                                            pattern="0.00" />%
                                                    </div>
                                                    <small
                                                        class="text-muted">${dashboard.averageOrderValue.description}</small>
                                                </div>
                                                <div class="col-auto">
                                                    <i class="fas fa-chart-bar fa-2x text-gray-300"></i>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Charts Row -->
                            <div class="row mb-4">
                                <!-- Revenue Chart -->
                                <div class="col-xl-8 col-lg-7">
                                    <div class="card">
                                        <div class="card-header">
                                            <h5 class="mb-0"><i class="fas fa-chart-line"></i> Xu hướng doanh thu</h5>
                                        </div>
                                        <div class="card-body">
                                            <canvas id="revenueChart" height="100"></canvas>
                                        </div>
                                    </div>
                                </div>

                                <!-- Top Products Chart -->
                                <div class="col-xl-4 col-lg-5">
                                    <div class="card">
                                        <div class="card-header">
                                            <h5 class="mb-0"><i class="fas fa-trophy"></i> Sản phẩm bán chạy</h5>
                                        </div>
                                        <div class="card-body">
                                            <canvas id="topProductsChart" height="200"></canvas>
                                        </div>
                                    </div>
                                </div>
                            </div>

                        </div>
                    </div>

                    </div><!-- End container-fluid -->
                    </div><!-- End content -->

                    <!-- Include common footer scripts -->
                    <jsp:include page="../common/footer.jsp" />

                    <!-- Dashboard Script -->
                    <script>
                        document.addEventListener('DOMContentLoaded', function () {
                            // ========== Time Filter Handler ==========
                            const timeFilter = document.getElementById('timeFilter');
                            if (timeFilter) {
                                timeFilter.addEventListener('change', function () {
                                    const customDateRange = document.getElementById('customDateRange');
                                    const customDateRangeEnd = document.getElementById('customDateRangeEnd');
                                    if (this.value === 'custom') {
                                        customDateRange.style.display = 'block';
                                        customDateRangeEnd.style.display = 'block';
                                    } else {
                                        customDateRange.style.display = 'none';
                                        customDateRangeEnd.style.display = 'none';
                                    }
                                });
                            }

                            // Parent/child category JS removed (category filters not needed)
                        });                        // Prepare chart data from server
                        const revenueChartData = {
                            labels: [<c:forEach var="label" items="${dashboard.revenueChart.labels}" varStatus="status">'${label}'${!status.last ? ',' : ''}</c:forEach>],
                            values: [<c:forEach var="value" items="${dashboard.revenueChart.datasets[0].data}" varStatus="status">${value}${!status.last ? ',' : ''}</c:forEach>]
                        };

                        const topProductsChartData = {
                            labels: [<c:forEach var="label" items="${dashboard.topProductsChart.labels}" varStatus="status">'${label}'${!status.last ? ',' : ''}</c:forEach>],
                            values: [<c:forEach var="value" items="${dashboard.topProductsChart.datasets[0].data}" varStatus="status">${value}${!status.last ? ',' : ''}</c:forEach>]
                        };

                        // Revenue Chart
                        const revenueCtx = document.getElementById('revenueChart').getContext('2d');
                        const revenueChart = new Chart(revenueCtx, {
                            type: 'line',
                            data: {
                                labels: revenueChartData.labels,
                                datasets: [{
                                    label: 'Doanh thu',
                                    data: revenueChartData.values,
                                    backgroundColor: 'rgba(54, 162, 235, 0.5)',
                                    borderColor: 'rgba(54, 162, 235, 1)',
                                    borderWidth: 2,
                                    tension: 0.4,
                                    fill: true
                                }]
                            },
                            options: {
                                responsive: true,
                                maintainAspectRatio: false,
                                plugins: {
                                    legend: {
                                        display: true,
                                        position: 'top',
                                    }
                                },
                                scales: {
                                    y: {
                                        beginAtZero: true,
                                        ticks: {
                                            callback: function (value) {
                                                return value.toLocaleString('vi-VN') + ' VND';
                                            }
                                        }
                                    }
                                }
                            }
                        });

                        // Top Products Chart
                        const topProductsCtx = document.getElementById('topProductsChart').getContext('2d');
                        const topProductsChart = new Chart(topProductsCtx, {
                            type: 'bar',
                            data: {
                                labels: topProductsChartData.labels,
                                datasets: [{
                                    label: 'Doanh thu (VND)',
                                    data: topProductsChartData.values,
                                    backgroundColor: 'rgba(75, 192, 192, 0.5)',
                                    borderColor: 'rgba(75, 192, 192, 1)',
                                    borderWidth: 2
                                }]
                            },
                            options: {
                                responsive: true,
                                maintainAspectRatio: false,
                                indexAxis: 'y',
                                plugins: {
                                    legend: {
                                        display: false
                                    }
                                },
                                scales: {
                                    x: {
                                        beginAtZero: true,
                                        ticks: {
                                            callback: function (value) {
                                                return value.toLocaleString('vi-VN');
                                            }
                                        }
                                    }
                                }
                            }
                        });
                    </script>

                    <!-- Common JavaScript for Sidebar Toggle -->
                    <script>
                        // Toggle sidebar function
                        function toggleSidebar() {
                            var sidebar = document.getElementById('sidebar');
                            var content = document.getElementById('content');
                            var overlay = document.getElementById('sidebarOverlay');

                            if (sidebar && content) {
                                sidebar.classList.toggle('active');
                                content.classList.toggle('shifted');

                                // Toggle overlay for mobile
                                if (overlay) {
                                    overlay.classList.toggle('active');
                                }
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
                    </script>

                </body>

                </html>