<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
            <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

                <!DOCTYPE html>
                <html lang="vi">

                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>Dashboard - ${store.storeName}</title>

                    <!-- Include common head -->
                    <jsp:include page="../common/head.jsp" />

                    <!-- Dashboard specific CSS -->
                    <link rel="stylesheet" href="/resources/css/dashboard.css">
                    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
                </head>

                <body>
                    <!-- Include Navbar -->
                    <jsp:include page="../common/navbar.jsp" />

                    <!-- Include Sidebar -->
                    <jsp:include page="../common/sidebar.jsp" />

                    <!-- Sidebar Overlay for Mobile -->
                    <div class="sidebar-overlay" id="sidebarOverlay" onclick="toggleSidebar()" role="button"
                        tabindex="0" onKeyPress="if(event.key === 'Enter') toggleSidebar()"></div>

                    <!-- Main Content with proper margin for sidebar -->
                    <div class="content" id="content">
                        <div class="dashboard-container">
                            <!-- Error/Success Messages -->
                            <c:if test="${not empty errorMessage}">
                                <div class="alert-message error-message"
                                    style="margin: 1rem; padding: 1rem; background: #fee; border-left: 4px solid #c33; color: #c33; border-radius: 4px; position: relative;">
                                    <i class="fas fa-exclamation-circle"></i> ${errorMessage}
                                    <button onclick="this.parentElement.style.display='none'"
                                        style="position: absolute; right: 10px; top: 10px; border: none; background: none; font-size: 20px; cursor: pointer; color: #c33;">&times;</button>
                                </div>
                            </c:if>
                            <c:if test="${not empty successMessage}">
                                <div class="alert-message success-message"
                                    style="margin: 1rem; padding: 1rem; background: #efe; border-left: 4px solid #3c3; color: #3c3; border-radius: 4px; position: relative;">
                                    <i class="fas fa-check-circle"></i> ${successMessage}
                                    <button onclick="this.parentElement.style.display='none'"
                                        style="position: absolute; right: 10px; top: 10px; border: none; background: none; font-size: 20px; cursor: pointer; color: #3c3;">&times;</button>
                                </div>
                            </c:if>

                            <!-- Header -->
                            <div class="dashboard-header">
                                <h1><i class="fas fa-chart-line"></i> Dashboard - ${store.storeName}</h1>
                                <div class="header-right">
                                    <span class="store-rating">
                                        <i class="fas fa-star"></i>
                                        <fmt:formatNumber value="${store.rating}" maxFractionDigits="2" />
                                    </span>
                                </div>
                            </div>

                            <!-- Filters -->
                            <div class="filters-section">
                                <form id="filterForm" method="get" action="/seller/dashboard">
                                    <div class="filter-group">
                                        <label>Thời gian:</label>
                                        <select name="timeRange" id="timeRange" onchange="toggleCustomDate()">
                                            <option value="TODAY" ${timeRange=='TODAY' ? 'selected' : '' }>Hôm nay
                                            </option>
                                            <option value="LAST_7_DAYS" ${timeRange=='LAST_7_DAYS' ? 'selected' : '' }>7
                                                ngày qua</option>
                                            <option value="LAST_30_DAYS" ${timeRange=='LAST_30_DAYS' ? 'selected' : ''
                                                }>30
                                                ngày qua</option>
                                            <option value="CUSTOM" ${timeRange=='CUSTOM' ? 'selected' : '' }>Tùy chỉnh
                                            </option>
                                        </select>
                                    </div>

                                    <c:if test="${timeRange == 'CUSTOM'}">
                                        <div class="filter-group custom-date" id="customDateGroup">
                                            <label>Từ ngày:</label>
                                            <input type="date" name="startDate" value="${filter.startDate}">
                                            <label>Đến ngày:</label>
                                            <input type="date" name="endDate" value="${filter.endDate}">
                                        </div>
                                    </c:if>
                                    <c:if test="${timeRange != 'CUSTOM'}">
                                        <div class="filter-group custom-date" id="customDateGroup"
                                            style="display: none;">
                                            <label>Từ ngày:</label>
                                            <input type="date" name="startDate" value="${filter.startDate}">
                                            <label>Đến ngày:</label>
                                            <input type="date" name="endDate" value="${filter.endDate}">
                                        </div>
                                    </c:if>

                                    <button type="submit" class="btn-filter">
                                        <i class="fas fa-filter"></i> Lọc
                                    </button>
                                </form>
                            </div>

                            <!-- KPI Cards -->
                            <div class="kpi-section">
                                <div class="kpi-grid">
                                    <!-- Revenue Card -->
                                    <div class="kpi-card revenue-card">
                                        <div class="kpi-icon">
                                            <i class="fas fa-dollar-sign"></i>
                                        </div>
                                        <div class="kpi-content">
                                            <h3>Doanh thu ròng</h3>
                                            <p class="kpi-value">
                                                <fmt:formatNumber value="${kpis.netSales}" type="currency"
                                                    currencySymbol="₫" maxFractionDigits="0" />
                                            </p>
                                            <small class="kpi-subtitle">
                                                Tổng:
                                                <fmt:formatNumber value="${kpis.grossSales}" type="currency"
                                                    currencySymbol="₫" maxFractionDigits="0" />
                                            </small>
                                        </div>
                                    </div>

                                    <!-- Orders Card -->
                                    <div class="kpi-card orders-card">
                                        <div class="kpi-icon">
                                            <i class="fas fa-shopping-cart"></i>
                                        </div>
                                        <div class="kpi-content">
                                            <h3>Đơn hàng</h3>
                                            <p class="kpi-value">${kpis.totalOrders}</p>
                                            <div class="order-breakdown">
                                                <span class="pending">Pending: ${kpis.pendingOrders}</span>
                                                <span class="completed">Completed: ${kpis.completedOrders}</span>
                                                <span class="cancelled">Cancelled: ${kpis.cancelledOrders}</span>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- AOV Card -->
                                    <div class="kpi-card aov-card">
                                        <div class="kpi-icon">
                                            <i class="fas fa-receipt"></i>
                                        </div>
                                        <div class="kpi-content">
                                            <h3>Giá trị trung bình/Đơn</h3>
                                            <p class="kpi-value">
                                                <fmt:formatNumber value="${kpis.averageOrderValue}" type="currency"
                                                    currencySymbol="₫" maxFractionDigits="0" />
                                            </p>
                                        </div>
                                    </div>

                                    <!-- Stock Alert Card -->
                                    <div class="kpi-card stock-card">
                                        <div class="kpi-icon">
                                            <i class="fas fa-box"></i>
                                        </div>
                                        <div class="kpi-content">
                                            <h3>Cảnh báo kho</h3>
                                            <div class="stock-alerts">
                                                <div class="alert-item low-stock">
                                                    <i class="fas fa-exclamation-triangle"></i>
                                                    <span>Sắp hết: ${kpis.lowStockProducts}</span>
                                                </div>
                                                <div class="alert-item out-stock">
                                                    <i class="fas fa-times-circle"></i>
                                                    <span>Hết hàng: ${kpis.outOfStockProducts}</span>
                                                </div>
                                                <div class="alert-item expiring">
                                                    <i class="fas fa-clock"></i>
                                                    <span>Sắp hết hạn: ${kpis.expiringStockCount}</span>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Rates Card -->
                                    <div class="kpi-card rates-card">
                                        <div class="kpi-icon">
                                            <i class="fas fa-percentage"></i>
                                        </div>
                                        <div class="kpi-content">
                                            <h3>Tỷ lệ</h3>
                                            <div class="rates-breakdown">
                                                <div class="rate-item">
                                                    <small>Hoàn trả:</small>
                                                    <span class="refund-rate">
                                                        <fmt:formatNumber value="${kpis.refundRate}"
                                                            maxFractionDigits="2" />%
                                                    </span>
                                                </div>
                                                <div class="rate-item">
                                                    <small>Hủy:</small>
                                                    <span class="cancel-rate">
                                                        <fmt:formatNumber value="${kpis.cancelRate}"
                                                            maxFractionDigits="2" />%
                                                    </span>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Buyers Card -->
                                    <div class="kpi-card buyers-card">
                                        <div class="kpi-icon">
                                            <i class="fas fa-users"></i>
                                        </div>
                                        <div class="kpi-content">
                                            <h3>Khách hàng</h3>
                                            <div class="buyers-breakdown">
                                                <div class="buyer-item">
                                                    <small>Unique:</small>
                                                    <span>${kpis.uniqueBuyers}</span>
                                                </div>
                                                <div class="buyer-item">
                                                    <small>Repeat:</small>
                                                    <span>${kpis.repeatBuyers}</span>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Charts Section -->
                            <div class="charts-section">
                                <div class="chart-container">
                                    <h2><i class="fas fa-chart-area"></i> Doanh thu theo thời gian</h2>
                                    <canvas id="salesChart"></canvas>
                                </div>

                                <div class="chart-row">
                                    <div class="chart-container half">
                                        <h2><i class="fas fa-chart-bar"></i> Top sản phẩm (Doanh thu)</h2>
                                        <canvas id="topProductsChart"></canvas>
                                    </div>

                                    <div class="chart-container half">
                                        <h2><i class="fas fa-chart-pie"></i> Xu hướng Hoàn/Hủy</h2>
                                        <canvas id="refundCancelChart"></canvas>
                                    </div>
                                </div>
                            </div>

                            <!-- Top Products Table -->
                            <div class="top-products-section">
                                <h2><i class="fas fa-trophy"></i> Top Sản phẩm</h2>
                                <!-- Debug info (remove in production) -->
                                <small class="text-muted">Store ID: ${store.id}</small>

                                <table class="top-products-table">
                                    <thead>
                                        <tr>
                                            <th>#</th>
                                            <th>Tên sản phẩm</th>
                                            <th>Danh mục</th>
                                            <th>Doanh thu</th>
                                            <th>Số lượng bán</th>
                                            <th>Tồn kho</th>
                                            <th>Đánh giá</th>
                                            <th>Thao tác</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach items="${topProducts}" var="product" varStatus="status">
                                            <tr>
                                                <td>${status.index + 1}</td>
                                                <td class="product-name">${product.productName}</td>
                                                <td>${product.categoryName}</td>
                                                <td class="revenue">
                                                    <fmt:formatNumber value="${product.totalRevenue}" type="currency"
                                                        currencySymbol="₫" maxFractionDigits="0" />
                                                </td>
                                                <td>${product.totalUnits}</td>
                                                <td class="stock ${product.currentStock <= 10 ? 'low' : ''}">
                                                    ${product.currentStock}
                                                </td>
                                                <td>
                                                    <span class="rating">
                                                        <i class="fas fa-star"></i>
                                                        <fmt:formatNumber value="${product.productRating}"
                                                            maxFractionDigits="2" />
                                                    </span>
                                                </td>
                                                <td>
                                                    <c:url var="productDetailUrl"
                                                        value="/seller/products/${product.productId}">
                                                        <c:param name="storeId" value="${store.id}" />
                                                    </c:url>
                                                    <a href="${productDetailUrl}" class="btn-view"
                                                        title="Xem chi tiết sản phẩm">
                                                        <i class="fas fa-eye"></i>
                                                    </a>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>

                            <!-- Alerts Section -->
                            <div class="alerts-section">
                                <h2><i class="fas fa-bell"></i> Cảnh báo & Thông báo</h2>
                                <div class="alerts-list">
                                    <c:forEach items="${alerts}" var="alert">
                                        <div class="alert-item ${alert.severity.toLowerCase()}">
                                            <div class="alert-icon">
                                                <c:choose>
                                                    <c:when
                                                        test="${alert.type == 'LOW_STOCK' || alert.type == 'OUT_OF_STOCK'}">
                                                        <i class="fas fa-box"></i>
                                                    </c:when>
                                                    <c:when test="${alert.type == 'EXPIRING'}">
                                                        <i class="fas fa-clock"></i>
                                                    </c:when>
                                                    <c:when test="${alert.type == 'PENDING_ORDER'}">
                                                        <i class="fas fa-shopping-cart"></i>
                                                    </c:when>
                                                    <c:when test="${alert.type == 'REFUNDED_ORDER'}">
                                                        <i class="fas fa-undo"></i>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <i class="fas fa-info-circle"></i>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                            <div class="alert-content">
                                                <h4>${alert.title}</h4>
                                                <p>${alert.message}</p>
                                                <small>
                                                    ${alert.timestamp.dayOfMonth < 10 ? '0' : ''
                                                        }${alert.timestamp.dayOfMonth}/${alert.timestamp.monthValue < 10
                                                        ? '0' : ''
                                                        }${alert.timestamp.monthValue}/${alert.timestamp.year}
                                                        ${alert.timestamp.hour < 10 ? '0' : ''
                                                        }${alert.timestamp.hour}:${alert.timestamp.minute < 10 ? '0'
                                                        : '' }${alert.timestamp.minute} </small>
                                            </div>
                                            <c:if test="${not empty alert.link}">
                                                <a href="${alert.link}" class="alert-action">
                                                    <i class="fas fa-arrow-right"></i>
                                                </a>
                                            </c:if>
                                        </div>
                                    </c:forEach>
                                </div>

                                <!-- Pagination Controls -->
                                <div class="alerts-pagination">
                                    <button class="pagination-btn" id="prevBtn" onclick="changeAlertPage(-1)">
                                        <i class="fas fa-chevron-left"></i> Trước
                                    </button>
                                    <span class="pagination-info">
                                        Trang <span id="currentPage">1</span> / <span id="totalPages">1</span>
                                    </span>
                                    <button class="pagination-btn" id="nextBtn" onclick="changeAlertPage(1)">
                                        Sau <i class="fas fa-chevron-right"></i>
                                    </button>
                                </div>
                            </div>
                        </div>
                        <!-- End of content wrapper -->
                    </div>

                    <!-- Include Footer -->
                    <jsp:include page="../common/footer.jsp" />

                    <script src="/resources/js/dashboard.js"></script>
                    <script>
                        // Pass data to JavaScript
                        const salesChartData = <c:out value="${salesChartJson}" escapeXml="false" />;
                        const topProductsData = <c:out value="${topProductsJson}" escapeXml="false" />;

                        function toggleCustomDate() {
                            const timeRange = document.getElementById('timeRange').value;
                            const customDateGroup = document.getElementById('customDateGroup');
                            customDateGroup.style.display = timeRange === 'CUSTOM' ? 'flex' : 'none';
                        }

                        // === Alerts Pagination ===
                        let currentAlertPage = 1;
                        const alertsPerPage = 5;
                        let totalAlerts = 0;
                        let totalAlertPages = 1;

                        function initializeAlertsPagination() {
                            const allAlerts = document.querySelectorAll('.alerts-list .alert-item');
                            totalAlerts = allAlerts.length;
                            totalAlertPages = Math.ceil(totalAlerts / alertsPerPage);

                            document.getElementById('totalPages').textContent = totalAlertPages;

                            if (totalAlerts > 0) {
                                showAlertPage(1);
                            } else {
                                // Hide pagination if no alerts
                                const pagination = document.querySelector('.alerts-pagination');
                                if (pagination) pagination.style.display = 'none';
                            }
                        }

                        function showAlertPage(pageNum) {
                            const allAlerts = document.querySelectorAll('.alerts-list .alert-item');
                            const startIndex = (pageNum - 1) * alertsPerPage;
                            const endIndex = startIndex + alertsPerPage;

                            // Show/hide alerts based on current page
                            allAlerts.forEach((alert, index) => {
                                if (index >= startIndex && index < endIndex) {
                                    alert.style.display = 'flex';
                                } else {
                                    alert.style.display = 'none';
                                }
                            });

                            // Update current page display
                            currentAlertPage = pageNum;
                            document.getElementById('currentPage').textContent = pageNum;

                            // Update button states
                            const prevBtn = document.getElementById('prevBtn');
                            const nextBtn = document.getElementById('nextBtn');

                            if (prevBtn) prevBtn.disabled = pageNum === 1;
                            if (nextBtn) nextBtn.disabled = pageNum === totalAlertPages;
                        }

                        function changeAlertPage(direction) {
                            const newPage = currentAlertPage + direction;
                            if (newPage >= 1 && newPage <= totalAlertPages) {
                                showAlertPage(newPage);
                            }
                        }

                        // Initialize pagination when page loads
                        document.addEventListener('DOMContentLoaded', function () {
                            initializeAlertsPagination();
                        });

                        // Toggle sidebar functionality (same as other pages)
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