<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Báo cáo & Thống kê - ${store.storeName} - TaphoaMMO</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        .reports-container {
            max-width: 1200px;
            margin: 0 auto;
        }
        .report-card {
            background: white;
            border-radius: 15px;
            padding: 25px;
            margin-bottom: 25px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.08);
        }
        .metric-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-radius: 15px;
            padding: 20px;
            text-align: center;
        }
        .metric-value {
            font-size: 2rem;
            font-weight: bold;
            margin-bottom: 5px;
        }
        .metric-label {
            opacity: 0.8;
            font-size: 0.9rem;
        }
        .chart-container {
            position: relative;
            height: 400px;
            margin: 20px 0;
        }
    </style>
</head>
<body class="bg-light">
    <div class="container py-5">
        <div class="reports-container">
            
            <!-- Header -->
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h1 class="h2 text-primary">
                        <i class="fas fa-chart-bar"></i>
                        Báo cáo & Thống kê
                    </h1>
                    <p class="text-muted mb-0">Phân tích hiệu suất kinh doanh của cửa hàng ${store.storeName}</p>
                </div>
                <div>
                    <a href="/stores/my-store" class="btn btn-outline-primary">
                        <i class="fas fa-arrow-left"></i> Quay lại Dashboard
                    </a>
                </div>
            </div>

            <!-- Key Metrics -->
            <div class="report-card">
                <h4 class="mb-4">
                    <i class="fas fa-tachometer-alt"></i>
                    Chỉ số chính
                </h4>
                <div class="row">
                    <div class="col-md-3 mb-3">
                        <div class="metric-card">
                            <div class="metric-value">0</div>
                            <div class="metric-label">Tổng đơn hàng</div>
                        </div>
                    </div>
                    <div class="col-md-3 mb-3">
                        <div class="metric-card">
                            <div class="metric-value">0 VND</div>
                            <div class="metric-label">Doanh thu</div>
                        </div>
                    </div>
                    <div class="col-md-3 mb-3">
                        <div class="metric-card">
                            <div class="metric-value">0</div>
                            <div class="metric-label">Sản phẩm</div>
                        </div>
                    </div>
                    <div class="col-md-3 mb-3">
                        <div class="metric-card">
                            <div class="metric-value">0.0</div>
                            <div class="metric-label">Đánh giá TB</div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Revenue Chart -->
            <div class="report-card">
                <h4 class="mb-4">
                    <i class="fas fa-chart-line"></i>
                    Biểu đồ doanh thu
                </h4>
                <div class="chart-container">
                    <canvas id="revenueChart"></canvas>
                </div>
            </div>

            <!-- Orders Chart -->
            <div class="report-card">
                <h4 class="mb-4">
                    <i class="fas fa-shopping-cart"></i>
                    Biểu đồ đơn hàng
                </h4>
                <div class="chart-container">
                    <canvas id="ordersChart"></canvas>
                </div>
            </div>

            <!-- Coming Soon Notice -->
            <div class="report-card">
                <div class="text-center py-5">
                    <i class="fas fa-construction fa-3x text-warning mb-3"></i>
                    <h4 class="text-muted">Tính năng đang phát triển</h4>
                    <p class="text-muted">
                        Báo cáo chi tiết sẽ được triển khai sau khi hoàn thiện hệ thống đơn hàng và sản phẩm.
                    </p>
                    <div class="mt-4">
                        <span class="badge bg-info me-2">Sắp có: Báo cáo doanh thu</span>
                        <span class="badge bg-info me-2">Sắp có: Phân tích khách hàng</span>
                        <span class="badge bg-info me-2">Sắp có: Thống kê sản phẩm</span>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Sample data for charts (will be replaced with real data later)
        const revenueData = {
            labels: ['T1', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'T8', 'T9', 'T10', 'T11', 'T12'],
            datasets: [{
                label: 'Doanh thu (VND)',
                data: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                borderColor: 'rgb(75, 192, 192)',
                backgroundColor: 'rgba(75, 192, 192, 0.2)',
                tension: 0.1
            }]
        };

        const ordersData = {
            labels: ['T1', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'T8', 'T9', 'T10', 'T11', 'T12'],
            datasets: [{
                label: 'Số đơn hàng',
                data: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                backgroundColor: 'rgba(54, 162, 235, 0.8)',
                borderColor: 'rgba(54, 162, 235, 1)',
                borderWidth: 1
            }]
        };

        // Revenue Chart
        const revenueCtx = document.getElementById('revenueChart').getContext('2d');
        new Chart(revenueCtx, {
            type: 'line',
            data: revenueData,
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
                }
            }
        });

        // Orders Chart
        const ordersCtx = document.getElementById('ordersChart').getContext('2d');
        new Chart(ordersCtx, {
            type: 'bar',
            data: ordersData,
            options: {
                responsive: true,
                maintainAspectRatio: false,
                scales: {
                    y: {
                        beginAtZero: true
                    }
                }
            }
        });
    </script>
</body>
</html>
