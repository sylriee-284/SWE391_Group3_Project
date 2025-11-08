<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
            <%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>

                <!DOCTYPE html>
                <html lang="vi">

                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>Bán hàng & Ký quỹ - Bảng điều khiển Người bán</title>

                    <!-- Include common head with all CSS and JS -->
                    <jsp:include page="../common/head.jsp" />

                    <!-- Chart.js - defer loading -->
                    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js" defer></script>
                    <!-- Custom Dashboard CSS -->
                    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/resources/css/dashboard.css">

                    <!-- Performance optimization styles -->
                    <style>
                        /* Optimize table rendering */
                        .table-responsive {
                            overflow-x: auto;
                            -webkit-overflow-scrolling: touch;
                            will-change: scroll-position;
                        }

                        /* Optimize chart containers */
                        canvas {
                            will-change: transform;
                        }

                        /* Reduce reflow on pagination */
                        .pagination {
                            contain: layout;
                        }

                        /* Smooth transitions */
                        .card {
                            backface-visibility: hidden;
                            transform: translateZ(0);
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
                                <i class="fas fa-shopping-cart"></i> Phân tích Bán hàng & Ký quỹ
                            </h2>

                            <!-- Error Message -->
                            <c:if test="${not empty errorMessage}">
                                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                                    <i class="fas fa-exclamation-triangle"></i> <strong>Lỗi!</strong> ${errorMessage}
                                    <button type="button" class="btn-close" data-bs-dismiss="alert"
                                        aria-label="Close"></button>
                                </div>
                            </c:if>

                            <!-- Navigation Tabs -->
                            <ul class="nav nav-tabs mb-4">
                                <li class="nav-item">
                                    <a class="nav-link" href="${pageContext.request.contextPath}/seller/dashboard">
                                        <i class="fas fa-chart-line"></i> Tổng quan
                                    </a>
                                </li>
                                <li class="nav-item">
                                    <a class="nav-link active"
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

                            <!-- Filters -->
                            <div class="card mb-4">
                                <div class="card-header bg-light">
                                    <h5 class="mb-0"><i class="fas fa-filter"></i> Bộ lọc</h5>
                                </div>
                                <div class="card-body">
                                    <form method="get"
                                        action="${pageContext.request.contextPath}/seller/dashboard/sales">
                                        <div class="d-flex flex-wrap align-items-end gap-3">
                                            <!-- Time Filter -->
                                            <div class="form-group mb-0" style="min-width:200px;">
                                                <label class="form-label">Thời gian</label>
                                                <select class="form-select" name="timeFilter" id="timeFilter">
                                                    <option value="today" ${sales.timeFilter=='today' ? 'selected' : ''
                                                        }>Hôm nay</option>
                                                    <option value="7days" ${sales.timeFilter=='7days' ? 'selected' : ''
                                                        }>7 ngày qua</option>
                                                    <option value="30days" ${sales.timeFilter=='30days' ? 'selected'
                                                        : '' }>30 ngày qua</option>
                                                    <option value="custom" ${sales.timeFilter=='custom' ? 'selected'
                                                        : '' }>Tùy chỉnh</option>
                                                </select>
                                            </div>

                                            <!-- Custom Date Range -->
                                            <div class="form-group mb-0" id="customDateRange" <c:if
                                                test="${sales.timeFilter == 'custom'}">style="display: block;
                                                min-width:180px;"</c:if>
                                                <c:if test="${sales.timeFilter != 'custom'}">style="display: none;
                                                    min-width:180px;"</c:if>>
                                                <label class="form-label">Từ ngày</label>
                                                <input type="date" class="form-control" name="startDate"
                                                    value="${sales.startDate}">
                                            </div>
                                            <div class="form-group mb-0" id="customDateRangeEnd" <c:if
                                                test="${sales.timeFilter == 'custom'}">style="display: block;
                                                min-width:180px;"</c:if>
                                                <c:if test="${sales.timeFilter != 'custom'}">style="display: none;
                                                    min-width:180px;"</c:if>>
                                                <label class="form-label">Đến ngày</label>
                                                <input type="date" class="form-control" name="endDate"
                                                    value="${sales.endDate}">
                                            </div>

                                            <!-- Order Status Filter -->
                                            <div class="form-group mb-0" style="min-width:220px;">
                                                <label class="form-label">Trạng thái đơn hàng</label>
                                                <select class="form-select" name="orderStatus">
                                                    <option value="">Tất cả trạng thái</option>
                                                    <option value="PENDING" ${sales.orderStatus=='PENDING' ? 'selected'
                                                        : '' }>Chờ xử lý</option>
                                                    <option value="PAID" ${sales.orderStatus=='PAID' ? 'selected' : ''
                                                        }>Đã thanh toán</option>
                                                    <option value="COMPLETED" ${sales.orderStatus=='COMPLETED'
                                                        ? 'selected' : '' }>Hoàn thành</option>
                                                    <option value="CANCELLED" ${sales.orderStatus=='CANCELLED'
                                                        ? 'selected' : '' }>Đã hủy</option>
                                                    <option value="REFUNDED" ${sales.orderStatus=='REFUNDED'
                                                        ? 'selected' : '' }>Đã hoàn tiền</option>
                                                </select>
                                            </div>

                                            <!-- Action buttons aligned to the right -->
                                            <div class="ms-auto d-flex gap-2">
                                                <button type="submit" class="btn btn-primary">
                                                    <i class="fas fa-search"></i> Áp dụng
                                                </button>
                                                <a href="${pageContext.request.contextPath}/seller/dashboard/sales"
                                                    class="btn btn-secondary">
                                                    <i class="fas fa-redo"></i> Đặt lại
                                                </a>
                                                <a href="${pageContext.request.contextPath}/seller/dashboard/sales/export?timeFilter=${sales.timeFilter}&startDate=${sales.startDate}&endDate=${sales.endDate}&orderStatus=${sales.orderStatus}"
                                                    class="btn btn-danger">
                                                    <i class="fas fa-file-pdf"></i> Xuất PDF
                                                </a>
                                            </div>
                                        </div>
                                    </form>
                                </div>
                            </div>

                            <script>
                                // Toggle custom date range visibility
                                document.addEventListener('DOMContentLoaded', function () {
                                    const timeFilter = document.getElementById('timeFilter');
                                    const customDateRange = document.getElementById('customDateRange');
                                    const customDateRangeEnd = document.getElementById('customDateRangeEnd');

                                    function toggleCustomDateRange() {
                                        if (timeFilter.value === 'custom') {
                                            customDateRange.style.display = 'block';
                                            customDateRangeEnd.style.display = 'block';
                                        } else {
                                            customDateRange.style.display = 'none';
                                            customDateRangeEnd.style.display = 'none';
                                        }
                                    }

                                    // Listen for changes
                                    timeFilter.addEventListener('change', toggleCustomDateRange);

                                    // Initialize on page load
                                    toggleCustomDateRange();
                                });
                            </script>

                            <!-- Escrow Summary Cards -->
                            <div class="row mb-4">
                                <div class="col-md-6">
                                    <div class="card border-left-warning">
                                        <div class="card-body">
                                            <h6 class="text-warning">Đang giữ ký quỹ</h6>
                                            <h3>
                                                <c:choose>
                                                    <c:when test="${not empty sales.escrowSummary}">
                                                        <fmt:formatNumber value="${sales.escrowSummary.totalHeld}"
                                                            type="number" groupingUsed="true" /> VND
                                                    </c:when>
                                                    <c:otherwise>0 VND</c:otherwise>
                                                </c:choose>
                                            </h3>
                                            <small class="text-muted">
                                                <c:choose>
                                                    <c:when test="${not empty sales.escrowSummary}">
                                                        ${sales.escrowSummary.heldCount}</c:when>
                                                    <c:otherwise>0</c:otherwise>
                                                </c:choose> đơn hàng
                                            </small>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="card border-left-success">
                                        <div class="card-body">
                                            <h6 class="text-success">Đã giải ngân</h6>
                                            <h3>
                                                <c:choose>
                                                    <c:when test="${not empty sales.escrowSummary}">
                                                        <fmt:formatNumber value="${sales.escrowSummary.totalReleased}"
                                                            type="number" groupingUsed="true" /> VND
                                                    </c:when>
                                                    <c:otherwise>0 VND</c:otherwise>
                                                </c:choose>
                                            </h3>
                                            <small class="text-muted">
                                                <c:choose>
                                                    <c:when test="${not empty sales.escrowSummary}">
                                                        ${sales.escrowSummary.releasedCount}</c:when>
                                                    <c:otherwise>0</c:otherwise>
                                                </c:choose> đơn hàng
                                            </small>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Upcoming Release Schedule -->
                            <div class="row mb-4">
                                <div class="col-12">
                                    <div class="card">
                                        <div class="card-header">
                                            <h5 class="mb-0"><i class="fas fa-calendar-alt"></i> Lịch giải ngân sắp tới
                                            </h5>
                                        </div>
                                        <div class="card-body">
                                            <c:if test="${empty sales.escrowSummary.upcomingReleases}">
                                                <p class="text-muted">Không có lịch giải ngân trong 30 ngày tới.</p>
                                            </c:if>
                                            <c:if test="${not empty sales.escrowSummary.upcomingReleases}">
                                                <div class="table-responsive">
                                                    <table class="table table-sm">
                                                        <thead>
                                                            <tr>
                                                                <th>Ngày giải ngân</th>
                                                                <th>Số tiền</th>
                                                                <th>Đơn hàng</th>
                                                            </tr>
                                                        </thead>
                                                        <tbody>
                                                            <c:forEach var="release"
                                                                items="${sales.escrowSummary.upcomingReleases}">
                                                                <tr>
                                                                    <td>
                                                                        <c:if test="${not empty release.releaseDate}">
                                                                            ${release.releaseDate.toString().substring(0,
                                                                            10).replace('-', '/')}
                                                                        </c:if>
                                                                    </td>
                                                                    <td>
                                                                        <fmt:formatNumber value="${release.amount}"
                                                                            type="number" groupingUsed="true" /> VND
                                                                    </td>
                                                                    <td>${release.orderCount}</td>
                                                                </tr>
                                                            </c:forEach>
                                                        </tbody>
                                                    </table>
                                                </div>
                                            </c:if>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Charts Row -->
                            <div class="row mb-4">
                                <div class="col-md-6">
                                    <div class="card">
                                        <div class="card-header">
                                            <h5 class="mb-0"><i class="fas fa-chart-pie"></i> Doanh thu theo trạng thái
                                            </h5>
                                        </div>
                                        <div class="card-body position-relative">
                                            <div class="chart-loading text-center py-5" id="revenueChartLoading">
                                                <div class="spinner-border text-primary" role="status">
                                                    <span class="visually-hidden">Đang tải...</span>
                                                </div>
                                            </div>
                                            <canvas id="revenueByStatusChart" height="200"
                                                style="display:none;"></canvas>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="card">
                                        <div class="card-header">
                                            <h5 class="mb-0"><i class="fas fa-chart-area"></i> Tiến độ ký quỹ</h5>
                                        </div>
                                        <div class="card-body position-relative">
                                            <div class="chart-loading text-center py-5" id="escrowChartLoading">
                                                <div class="spinner-border text-primary" role="status">
                                                    <span class="visually-hidden">Đang tải...</span>
                                                </div>
                                            </div>
                                            <canvas id="escrowTimelineChart" height="200"
                                                style="display:none;"></canvas>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Orders Table -->
                            <div class="card">
                                <div class="card-header">
                                    <h5 class="mb-0"><i class="fas fa-list"></i> Đơn hàng</h5>
                                </div>
                                <div class="card-body">
                                    <div class="table-responsive">
                                        <table class="table table-striped table-hover">
                                            <thead>
                                                <tr>
                                                    <th>Mã đơn</th>
                                                    <th>Ngày</th>
                                                    <th>Sản phẩm</th>
                                                    <th>SL</th>
                                                    <th>Tổng tiền ước tính</th>
                                                    <th>Trạng thái</th>
                                                    <th>Đang giữ ký quỹ</th>
                                                    <th>Đã quyết toán</th>
                                                    <th>Phí hoa hồng</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:if test="${empty sales.orders.content}">
                                                    <tr>
                                                        <td colspan="9" class="text-center text-muted py-4">
                                                            <i class="fas fa-inbox fa-3x mb-3 d-block"></i>
                                                            Không tìm thấy đơn hàng nào
                                                        </td>
                                                    </tr>
                                                </c:if>
                                                <c:forEach var="order" items="${sales.orders.content}">
                                                    <tr>
                                                        <td>${order.orderCode}</td>
                                                        <td>
                                                            <c:if test="${not empty order.orderDate}">
                                                                ${order.orderDate.toString().substring(0,
                                                                10).replace('-', '/')}
                                                                ${order.orderDate.toString().substring(11, 16)}
                                                            </c:if>
                                                        </td>
                                                        <td>${order.productName}</td>
                                                        <td>${order.quantity}</td>
                                                        <td>
                                                            <fmt:formatNumber value="${order.totalAmount}" type="number"
                                                                groupingUsed="true" /> VND
                                                        </td>
                                                        <td>
                                                            <c:choose>
                                                                <c:when test="${order.escrowHeld > 0}">
                                                                    <!-- Tiền đang giữ ký quỹ, chưa giải ngân -->
                                                                    <span class="badge bg-warning">
                                                                        Chờ xử lý
                                                                    </span>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <!-- Hiển thị trạng thái thực tế của đơn hàng -->
                                                                    <span
                                                                        class="badge bg-${order.status == 'COMPLETED' ? 'success' : (order.status == 'CANCELLED' || order.status == 'REFUNDED' ? 'danger' : 'warning')}">
                                                                        ${order.statusText}
                                                                    </span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </td>
                                                        <td>
                                                            <fmt:formatNumber value="${order.escrowHeld}" type="number"
                                                                groupingUsed="true" />
                                                        </td>
                                                        <td>
                                                            <c:choose>
                                                                <c:when test="${order.isReleased}">
                                                                    <fmt:formatNumber value="${order.sellerAmount}"
                                                                        type="number" groupingUsed="true" />
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="text-muted">-</span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </td>
                                                        <td>
                                                            <c:choose>
                                                                <c:when test="${order.isReleased}">
                                                                    <!-- Check fee model -->
                                                                    <c:choose>
                                                                        <c:when test="${order.feeModel == 'NO_FEE'}">
                                                                            <span class="badge bg-success">0% (Miễn
                                                                                phí)</span>
                                                                        </c:when>
                                                                        <c:otherwise>
                                                                            <!-- Calculate commission percentage from actual amounts -->
                                                                            <c:if test="${order.totalAmount > 0}">
                                                                                <fmt:formatNumber
                                                                                    value="${order.commissionRate}"
                                                                                    type="number" maxFractionDigits="2"
                                                                                    minFractionDigits="2" />%
                                                                            </c:if>
                                                                        </c:otherwise>
                                                                    </c:choose>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="text-muted">-</span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </td>
                                                    </tr>
                                                </c:forEach>
                                            </tbody>
                                        </table>
                                    </div>

                                    <!-- Pagination -->
                                    <c:if test="${sales.orders.totalPages > 1}">
                                        <nav>
                                            <ul class="pagination justify-content-center">
                                                <!-- Previous Button -->
                                                <li class="page-item ${sales.orders.number == 0 ? 'disabled' : ''}">
                                                    <a class="page-link"
                                                        href="?page=${sales.orders.number - 1}&timeFilter=${sales.timeFilter}&orderStatus=${sales.orderStatus}">
                                                        <i class="fas fa-chevron-left"></i>
                                                    </a>
                                                </li>

                                                <!-- Page Numbers (max 5 visible) -->
                                                <c:set var="currentPage" value="${sales.orders.number}" />
                                                <c:set var="totalPages" value="${sales.orders.totalPages}" />
                                                <c:set var="startPage"
                                                    value="${currentPage - 2 < 0 ? 0 : currentPage - 2}" />
                                                <c:set var="endPage"
                                                    value="${startPage + 4 >= totalPages ? totalPages - 1 : startPage + 4}" />
                                                <c:set var="startPage"
                                                    value="${endPage - startPage < 4 ? (endPage - 4 < 0 ? 0 : endPage - 4) : startPage}" />

                                                <!-- First page if not in range -->
                                                <c:if test="${startPage > 0}">
                                                    <li class="page-item">
                                                        <a class="page-link"
                                                            href="?page=0&timeFilter=${sales.timeFilter}&orderStatus=${sales.orderStatus}">1</a>
                                                    </li>
                                                    <c:if test="${startPage > 1}">
                                                        <li class="page-item disabled"><span
                                                                class="page-link">...</span></li>
                                                    </c:if>
                                                </c:if>

                                                <!-- Page range -->
                                                <c:forEach begin="${startPage}" end="${endPage}" var="i">
                                                    <li class="page-item ${i == currentPage ? 'active' : ''}">
                                                        <a class="page-link"
                                                            href="?page=${i}&timeFilter=${sales.timeFilter}&orderStatus=${sales.orderStatus}">
                                                            ${i + 1}
                                                        </a>
                                                    </li>
                                                </c:forEach>

                                                <!-- Last page if not in range -->
                                                <c:if test="${endPage < totalPages - 1}">
                                                    <c:if test="${endPage < totalPages - 2}">
                                                        <li class="page-item disabled"><span
                                                                class="page-link">...</span></li>
                                                    </c:if>
                                                    <li class="page-item">
                                                        <a class="page-link"
                                                            href="?page=${totalPages - 1}&timeFilter=${sales.timeFilter}&orderStatus=${sales.orderStatus}">${totalPages}</a>
                                                    </li>
                                                </c:if>

                                                <!-- Next Button -->
                                                <li
                                                    class="page-item ${sales.orders.number == totalPages - 1 ? 'disabled' : ''}">
                                                    <a class="page-link"
                                                        href="?page=${sales.orders.number + 1}&timeFilter=${sales.timeFilter}&orderStatus=${sales.orderStatus}">
                                                        <i class="fas fa-chevron-right"></i>
                                                    </a>
                                                </li>
                                            </ul>
                                        </nav>
                                    </c:if>
                                </div>
                            </div>

                        </div><!-- End container-fluid -->
                    </div><!-- End content -->

                    <!-- Include common footer scripts -->
                    <jsp:include page="../common/footer.jsp" />

                    <!-- Prepare data for charts -->
                    <script type="application/json" id="revenueByStatusData">
    {
        "labels": [<c:forEach var="label" items="${sales.revenueByStatusChart.labels}" varStatus="status">"<c:out value="${label}"/>"<c:if test="${!status.last}">,</c:if></c:forEach>],
        "values": [<c:forEach var="value" items="${sales.revenueByStatusChart.datasets[0].data}" varStatus="status"><c:out value="${value}"/><c:if test="${!status.last}">,</c:if></c:forEach>]
    }
    </script>

                    <script type="application/json" id="escrowTimelineData">
    {
        "labels": [<c:forEach var="label" items="${sales.escrowTimelineChart.labels}" varStatus="status">"<c:out value="${label}"/>"<c:if test="${!status.last}">,</c:if></c:forEach>],
        "datasets": [
        <c:forEach var="dataset" items="${sales.escrowTimelineChart.datasets}" varStatus="dStatus">
        {
            "label": "<c:out value="${dataset.label}"/>",
            "data": [<c:forEach var="value" items="${dataset.data}" varStatus="vStatus"><c:out value="${value}"/><c:if test="${!vStatus.last}">,</c:if></c:forEach>],
            "backgroundColor": "<c:out value="${dataset.backgroundColor}"/>",
            "borderColor": "<c:out value="${dataset.borderColor}"/>",
            "borderWidth": 2,
            "tension": 0.4,
            "fill": false
        }<c:if test="${!dStatus.last}">,</c:if>
        </c:forEach>
        ]
    }
    </script>

                    <script>
                        // ========== Sidebar Toggle Function (Global Scope) ==========
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

                        // Defer chart loading to improve page load speed
                        document.addEventListener('DOMContentLoaded', function () {
                            // Use setTimeout to defer chart rendering
                            setTimeout(function () {
                                try {
                                    // Load chart data from JSON
                                    const revenueByStatusData = JSON.parse(document.getElementById('revenueByStatusData').textContent);
                                    const escrowTimelineData = JSON.parse(document.getElementById('escrowTimelineData').textContent);

                                    // Revenue by Status Chart
                                    const revenueByStatusCtx = document.getElementById('revenueByStatusChart');
                                    const revenueLoading = document.getElementById('revenueChartLoading');
                                    if (revenueByStatusCtx) {
                                        new Chart(revenueByStatusCtx.getContext('2d'), {
                                            type: 'doughnut',
                                            data: {
                                                labels: revenueByStatusData.labels,
                                                datasets: [{
                                                    data: revenueByStatusData.values,
                                                    backgroundColor: [
                                                        'rgba(54, 162, 235, 0.7)',
                                                        'rgba(75, 192, 192, 0.7)',
                                                        'rgba(255, 206, 86, 0.7)',
                                                        'rgba(255, 99, 132, 0.7)',
                                                        'rgba(153, 102, 255, 0.7)'
                                                    ],
                                                    borderWidth: 2
                                                }]
                                            },
                                            options: {
                                                responsive: true,
                                                maintainAspectRatio: false,
                                                plugins: {
                                                    legend: {
                                                        position: 'right'
                                                    }
                                                }
                                            }
                                        });
                                        // Hide loading, show chart
                                        revenueLoading.style.display = 'none';
                                        revenueByStatusCtx.style.display = 'block';
                                    }

                                    // Escrow Timeline Chart
                                    const escrowTimelineCtx = document.getElementById('escrowTimelineChart');
                                    const escrowLoading = document.getElementById('escrowChartLoading');
                                    if (escrowTimelineCtx) {
                                        new Chart(escrowTimelineCtx.getContext('2d'), {
                                            type: 'line',
                                            data: {
                                                labels: escrowTimelineData.labels,
                                                datasets: escrowTimelineData.datasets
                                            },
                                            options: {
                                                responsive: true,
                                                maintainAspectRatio: false,
                                                plugins: {
                                                    legend: {
                                                        display: true,
                                                        position: 'top'
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
                                        // Hide loading, show chart
                                        escrowLoading.style.display = 'none';
                                        escrowTimelineCtx.style.display = 'block';
                                    }
                                } catch (error) {
                                    console.error('Error loading charts:', error);
                                    // Hide loading on error
                                    const loadings = document.querySelectorAll('.chart-loading');
                                    loadings.forEach(el => el.innerHTML = '<p class="text-danger">Lỗi tải biểu đồ</p>');
                                }
                            }, 100); // Delay 100ms to let page render first
                        });

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