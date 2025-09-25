<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - ${store.storeName} - TaphoaMMO</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        .dashboard-card {
            border-radius: 15px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.08);
            transition: transform 0.2s;
        }
        .dashboard-card:hover {
            transform: translateY(-2px);
        }
        .stat-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-radius: 15px;
            padding: 25px;
        }
        .stat-card.success {
            background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%);
        }
        .stat-card.warning {
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
        }
        .stat-card.info {
            background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
        }
        .store-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-radius: 15px;
            padding: 30px;
            margin-bottom: 30px;
        }
        .quick-action-btn {
            border-radius: 10px;
            padding: 15px;
            text-decoration: none;
            display: block;
            transition: all 0.2s;
        }
        .quick-action-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(0,0,0,0.2);
        }
    </style>
</head>
<body class="bg-light">
    <div class="container-fluid py-4">
        
        <!-- Store Header -->
        <div class="store-header">
            <div class="row align-items-center">
                <div class="col-md-8">
                    <h1 class="h2 mb-2">
                        <i class="fas fa-store"></i>
                        ${store.storeName}
                    </h1>
                    <p class="mb-3 opacity-75">${store.storeDescription}</p>
                    <div class="d-flex gap-2">
                        <span class="badge bg-light text-dark">${store.status}</span>
                        <span class="badge bg-light text-dark">${store.isVerified ? 'Đã xác minh' : 'Chưa xác minh'}</span>
                        <span class="badge ${store.isOperational() ? 'bg-success' : 'bg-warning'}">${store.isOperational() ? 'Hoạt động tốt' : 'Cần chú ý'}</span>
                    </div>
                </div>
                <div class="col-md-4 text-end">
                    <div class="mb-2">
                        <div class="h4 mb-0">${store.formattedDeposit}</div>
                        <small class="opacity-75">Deposit hiện tại</small>
                    </div>
                    <div>
                        <div class="h5 mb-0">${store.formattedMaxPrice}</div>
                        <small class="opacity-75">Giá listing tối đa</small>
                    </div>
                </div>
            </div>
        </div>

        <!-- Quick Actions -->
        <div class="row mb-4">
            <div class="col-12">
                <div class="card dashboard-card">
                    <div class="card-body">
                        <h5 class="card-title mb-3">
                            <i class="fas fa-bolt text-warning"></i>
                            Thao tác nhanh
                        </h5>
                        <div class="row">
                            <div class="col-md-3 mb-3">
                                <a href="/products/create" class="quick-action-btn bg-primary text-white">
                                    <i class="fas fa-plus fa-2x mb-2"></i>
                                    <div class="fw-bold">Thêm sản phẩm</div>
                                    <small>Tạo sản phẩm mới</small>
                                </a>
                            </div>
                            <div class="col-md-3 mb-3">
                                <a href="/stores/my-store/orders" class="quick-action-btn bg-success text-white">
                                    <i class="fas fa-shopping-cart fa-2x mb-2"></i>
                                    <div class="fw-bold">Quản lý đơn hàng</div>
                                    <small>${dashboard.pendingOrders} đơn chờ xử lý</small>
                                </a>
                            </div>
                            <div class="col-md-3 mb-3">
                                <a href="/stores/my-store/inventory" class="quick-action-btn bg-info text-white">
                                    <i class="fas fa-boxes fa-2x mb-2"></i>
                                    <div class="fw-bold">Quản lý kho</div>
                                    <small>Cập nhật inventory</small>
                                </a>
                            </div>
                            <div class="col-md-3 mb-3">
                                <a href="/stores/my-store/settings" class="quick-action-btn bg-warning text-white">
                                    <i class="fas fa-cog fa-2x mb-2"></i>
                                    <div class="fw-bold">Cài đặt</div>
                                    <small>Cấu hình cửa hàng</small>
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Statistics Cards -->
        <div class="row mb-4">
            <div class="col-lg-3 col-md-6 mb-3">
                <div class="stat-card">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <div class="h3 mb-0">${dashboard.totalRevenue != null ? dashboard.formattedRevenue : '0 VND'}</div>
                            <div class="opacity-75">Tổng doanh thu</div>
                        </div>
                        <div>
                            <i class="fas fa-chart-line fa-2x opacity-75"></i>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-lg-3 col-md-6 mb-3">
                <div class="stat-card success">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <div class="h3 mb-0">${dashboard.totalOrders != null ? dashboard.totalOrders : 0}</div>
                            <div class="opacity-75">Tổng đơn hàng</div>
                        </div>
                        <div>
                            <i class="fas fa-shopping-cart fa-2x opacity-75"></i>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-lg-3 col-md-6 mb-3">
                <div class="stat-card warning">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <div class="h3 mb-0">${dashboard.totalProducts != null ? dashboard.totalProducts : 0}</div>
                            <div class="opacity-75">Tổng sản phẩm</div>
                        </div>
                        <div>
                            <i class="fas fa-box fa-2x opacity-75"></i>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-lg-3 col-md-6 mb-3">
                <div class="stat-card info">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <div class="h3 mb-0">${dashboard.formattedAverageRating}</div>
                            <div class="opacity-75">Đánh giá trung bình</div>
                        </div>
                        <div>
                            <i class="fas fa-star fa-2x opacity-75"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Charts and Analytics -->
        <div class="row mb-4">
            <div class="col-lg-8 mb-3">
                <div class="card dashboard-card">
                    <div class="card-body">
                        <h5 class="card-title">
                            <i class="fas fa-chart-area text-primary"></i>
                            Doanh thu 7 ngày qua
                        </h5>
                        <canvas id="revenueChart" height="100"></canvas>
                    </div>
                </div>
            </div>
            <div class="col-lg-4 mb-3">
                <div class="card dashboard-card">
                    <div class="card-body">
                        <h5 class="card-title">
                            <i class="fas fa-chart-pie text-success"></i>
                            Trạng thái đơn hàng
                        </h5>
                        <canvas id="orderStatusChart" height="200"></canvas>
                        <div class="mt-3">
                            <div class="d-flex justify-content-between">
                                <span>Hoàn thành:</span>
                                <span class="fw-bold text-success">${dashboard.completedOrders}</span>
                            </div>
                            <div class="d-flex justify-content-between">
                                <span>Đang xử lý:</span>
                                <span class="fw-bold text-warning">${dashboard.pendingOrders}</span>
                            </div>
                            <div class="d-flex justify-content-between">
                                <span>Đã hủy:</span>
                                <span class="fw-bold text-danger">${dashboard.cancelledOrders}</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Performance Metrics -->
        <div class="row mb-4">
            <div class="col-lg-6 mb-3">
                <div class="card dashboard-card">
                    <div class="card-body">
                        <h5 class="card-title">
                            <i class="fas fa-tachometer-alt text-info"></i>
                            Hiệu suất kinh doanh
                        </h5>
                        <div class="row">
                            <div class="col-6">
                                <div class="text-center p-3">
                                    <div class="h4 text-primary">${dashboard.formattedCompletionRate}</div>
                                    <div class="text-muted">Tỷ lệ hoàn thành</div>
                                </div>
                            </div>
                            <div class="col-6">
                                <div class="text-center p-3">
                                    <div class="h4 text-success">${dashboard.formattedAverageOrderValue}</div>
                                    <div class="text-muted">Giá trị đơn TB</div>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-6">
                                <div class="text-center p-3">
                                    <div class="h4 text-warning">${dashboard.formattedConversionRate}</div>
                                    <div class="text-muted">Tỷ lệ chuyển đổi</div>
                                </div>
                            </div>
                            <div class="col-6">
                                <div class="text-center p-3">
                                    <div class="h4 text-info">${dashboard.formattedActivityRate}</div>
                                    <div class="text-muted">Sản phẩm hoạt động</div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-lg-6 mb-3">
                <div class="card dashboard-card">
                    <div class="card-body">
                        <h5 class="card-title">
                            <i class="fas fa-users text-primary"></i>
                            Thông tin khách hàng
                        </h5>
                        <div class="row">
                            <div class="col-6">
                                <div class="text-center p-3">
                                    <div class="h4 text-primary">${dashboard.totalCustomers}</div>
                                    <div class="text-muted">Tổng khách hàng</div>
                                </div>
                            </div>
                            <div class="col-6">
                                <div class="text-center p-3">
                                    <div class="h4 text-success">${dashboard.repeatCustomers}</div>
                                    <div class="text-muted">Khách quay lại</div>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-12">
                                <div class="text-center p-3">
                                    <div class="h4 text-info">${dashboard.formattedRetentionRate}</div>
                                    <div class="text-muted">Tỷ lệ giữ chân khách hàng</div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Recent Activity -->
        <div class="row">
            <div class="col-lg-6 mb-3">
                <div class="card dashboard-card">
                    <div class="card-body">
                        <h5 class="card-title">
                            <i class="fas fa-clock text-warning"></i>
                            Đơn hàng gần đây
                        </h5>
                        <c:choose>
                            <c:when test="${not empty dashboard.recentOrders}">
                                <!-- TODO: Display recent orders when Order entity is implemented -->
                                <div class="text-center py-4">
                                    <i class="fas fa-shopping-cart fa-3x text-muted"></i>
                                    <p class="text-muted mt-2">Đơn hàng sẽ hiển thị ở đây</p>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="text-center py-4">
                                    <i class="fas fa-shopping-cart fa-3x text-muted"></i>
                                    <p class="text-muted mt-2">Chưa có đơn hàng nào</p>
                                    <a href="/products/create" class="btn btn-primary btn-sm">
                                        Tạo sản phẩm đầu tiên
                                    </a>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
            <div class="col-lg-6 mb-3">
                <div class="card dashboard-card">
                    <div class="card-body">
                        <h5 class="card-title">
                            <i class="fas fa-star text-warning"></i>
                            Đánh giá gần đây
                        </h5>
                        <c:choose>
                            <c:when test="${not empty dashboard.recentReviews}">
                                <!-- TODO: Display recent reviews when Review entity is implemented -->
                                <div class="text-center py-4">
                                    <i class="fas fa-star fa-3x text-muted"></i>
                                    <p class="text-muted mt-2">Đánh giá sẽ hiển thị ở đây</p>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="text-center py-4">
                                    <i class="fas fa-star fa-3x text-muted"></i>
                                    <p class="text-muted mt-2">Chưa có đánh giá nào</p>
                                    <small class="text-muted">Đánh giá sẽ xuất hiện sau khi có đơn hàng</small>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Revenue Chart
        const revenueCtx = document.getElementById('revenueChart').getContext('2d');
        new Chart(revenueCtx, {
            type: 'line',
            data: {
                labels: ['6 ngày trước', '5 ngày trước', '4 ngày trước', '3 ngày trước', '2 ngày trước', 'Hôm qua', 'Hôm nay'],
                datasets: [{
                    label: 'Doanh thu (VND)',
                    data: [0, 0, 0, 0, 0, 0, 0], // TODO: Use real data from dashboard.revenueByDay
                    borderColor: '#667eea',
                    backgroundColor: 'rgba(102, 126, 234, 0.1)',
                    tension: 0.4,
                    fill: true
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                scales: {
                    y: {
                        beginAtZero: true,
                        ticks: {
                            callback: function(value) {
                                return new Intl.NumberFormat('vi-VN').format(value) + ' VND';
                            }
                        }
                    }
                },
                plugins: {
                    legend: {
                        display: false
                    }
                }
            }
        });

        // Order Status Chart
        const orderStatusCtx = document.getElementById('orderStatusChart').getContext('2d');
        new Chart(orderStatusCtx, {
            type: 'doughnut',
            data: {
                labels: ['Hoàn thành', 'Đang xử lý', 'Đã hủy'],
                datasets: [{
                    data: [
                        ${dashboard.completedOrders != null ? dashboard.completedOrders : 0},
                        ${dashboard.pendingOrders != null ? dashboard.pendingOrders : 0},
                        ${dashboard.cancelledOrders != null ? dashboard.cancelledOrders : 0}
                    ],
                    backgroundColor: ['#28a745', '#ffc107', '#dc3545'],
                    borderWidth: 0
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        display: false
                    }
                }
            }
        });
    </script>
</body>
</html>
