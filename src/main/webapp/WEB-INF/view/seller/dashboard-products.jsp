<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
            <%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>

                <!DOCTYPE html>
                <html lang="vi">

                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>Sản phẩm & Kho hàng - Bảng điều khiển Người bán</title>

                    <!-- Include common head with all CSS and JS -->
                    <jsp:include page="../common/head.jsp" />

                    <!-- Chart.js -->
                    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
                    <!-- Custom Dashboard CSS -->
                    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/resources/css/dashboard.css">
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
                                <i class="fas fa-box"></i> Hiệu suất Sản phẩm & Kho hàng
                            </h2>

                            <!-- Navigation Tabs -->
                            <ul class="nav nav-tabs mb-4">
                                <li class="nav-item">
                                    <a class="nav-link" href="${pageContext.request.contextPath}/seller/dashboard">
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
                                    <a class="nav-link active"
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
                                        action="${pageContext.request.contextPath}/seller/dashboard/products">
                                        <div class="row g-3">
                                            <div class="col-md-3">
                                                <label class="form-label">Thời gian</label>
                                                <select class="form-select" name="timeFilter">
                                                    <option value="today" ${products.timeFilter=='today' ? 'selected'
                                                        : '' }>Hôm nay</option>
                                                    <option value="7days" ${products.timeFilter=='7days' ? 'selected'
                                                        : '' }>7 ngày qua</option>
                                                    <option value="30days" ${products.timeFilter=='30days' ? 'selected'
                                                        : '' }>30 ngày qua</option>
                                                    <option value="custom" ${products.timeFilter=='custom' ? 'selected'
                                                        : '' }>Tùy chỉnh</option>
                                                </select>
                                            </div>
                                            <div class="col-md-3">
                                                <label class="form-label">Danh mục</label>
                                                <select class="form-select" name="categoryId">
                                                    <option value="">Tất cả danh mục</option>
                                                    <!-- Categories populated from backend -->
                                                </select>
                                            </div>
                                            <div class="col-md-3">
                                                <label class="form-label">Sắp xếp theo</label>
                                                <select class="form-select" name="sortBy">
                                                    <option value="revenue" ${products.sortBy=='revenue' ? 'selected'
                                                        : '' }>Doanh thu (Cao đến thấp)</option>
                                                    <option value="sold" ${products.sortBy=='sold' ? 'selected' : '' }>
                                                        Số lượng bán (Cao đến thấp)</option>
                                                    <option value="rating" ${products.sortBy=='rating' ? 'selected' : ''
                                                        }>Đánh giá (Cao đến thấp)</option>
                                                </select>
                                            </div>
                                            <div class="col-md-12">
                                                <button type="submit" class="btn btn-primary">
                                                    <i class="fas fa-search"></i> Áp dụng
                                                </button>
                                                <a href="${pageContext.request.contextPath}/seller/dashboard/products"
                                                    class="btn btn-secondary">
                                                    <i class="fas fa-redo"></i> Đặt lại
                                                </a>
                                                <a href="${pageContext.request.contextPath}/seller/dashboard/products/export?timeFilter=${products.timeFilter}&categoryId=${products.categoryId}&sortBy=${products.sortBy}"
                                                    class="btn btn-danger float-end">
                                                    <i class="fas fa-file-pdf"></i> Xuất PDF
                                                </a>
                                            </div>
                                        </div>
                                    </form>
                                </div>
                            </div>

                            <!-- Charts Row -->
                            <div class="row mb-4">
                                <div class="col-md-8">
                                    <div class="card">
                                        <div class="card-header">
                                            <h5 class="mb-0"><i class="fas fa-chart-bar"></i> Doanh thu theo sản phẩm
                                            </h5>
                                        </div>
                                        <div class="card-body">
                                            <canvas id="revenueByProductChart" height="100"></canvas>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="card">
                                        <div class="card-header">
                                            <h5 class="mb-0"><i class="fas fa-warehouse"></i> Tình trạng kho hàng</h5>
                                        </div>
                                        <div class="card-body">
                                            <canvas id="inventoryStatusChart" height="200"></canvas>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Product Performance Table -->
                            <div class="card">
                                <div class="card-header">
                                    <h5 class="mb-0"><i class="fas fa-table"></i> Hiệu suất sản phẩm</h5>
                                </div>
                                <div class="card-body">
                                    <div class="table-responsive">
                                        <table class="table table-striped table-hover">
                                            <thead>
                                                <tr>
                                                    <th>Tên sản phẩm</th>
                                                    <th>Danh mục</th>
                                                    <th>Giá</th>
                                                    <th>Đã bán</th>
                                                    <th>Doanh thu</th>
                                                    <th>Tỷ lệ bán</th>
                                                    <th>Còn hàng</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:if test="${empty products.products.content}">
                                                    <tr>
                                                        <td colspan="7" class="text-center text-muted">Không tìm thấy
                                                            sản phẩm nào.</td>
                                                    </tr>
                                                </c:if>
                                                <c:forEach var="product" items="${products.products.content}">
                                                    <tr>
                                                        <td>
                                                            <a
                                                                href="${pageContext.request.contextPath}/seller/products?highlightProduct=${product.productId}&source=dashboard">
                                                                ${product.productName}
                                                            </a>
                                                        </td>
                                                        <td>${product.categoryName}</td>
                                                        <td>
                                                            <fmt:formatNumber value="${product.price}" type="number"
                                                                groupingUsed="true" /> VND
                                                        </td>
                                                        <td>${product.soldQuantity}</td>
                                                        <td>
                                                            <fmt:formatNumber value="${product.revenue}" type="number"
                                                                groupingUsed="true" /> VND
                                                        </td>
                                                        <td>
                                                            <fmt:formatNumber value="${product.sellThroughRate}"
                                                                pattern="0.00" />%
                                                        </td>
                                                        <td>
                                                            <span
                                                                class="badge bg-primary">${product.availableCount}</span>
                                                        </td>
                                                    </tr>
                                                </c:forEach>
                                            </tbody>
                                        </table>
                                    </div>

                                    <!-- Pagination for Product Table -->
                                    <div class="product-pagination mt-3">
                                        <!-- Pagination will be generated by JavaScript -->
                                    </div>
                                </div>
                            </div>

                        </div><!-- End container-fluid -->
                    </div><!-- End content -->

                    <!-- Include common footer scripts -->
                    <jsp:include page="../common/footer.jsp" />

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

                        // Prepare chart data from server
                        const revenueByProductData = {
                            labels: [<c:forEach var="label" items="${products.revenueByProductChart.labels}" varStatus="status">'${label}'${!status.last ? ',' : ''}</c:forEach>],
                            values: [<c:forEach var="value" items="${products.revenueByProductChart.datasets[0].data}" varStatus="status">${value}${!status.last ? ',' : ''}</c:forEach>]
                        };

                        const inventoryStatusData = {
                            labels: [<c:forEach var="label" items="${products.inventoryStatusChart.labels}" varStatus="status">'${label}'${!status.last ? ',' : ''}</c:forEach>],
                            values: [<c:forEach var="value" items="${products.inventoryStatusChart.datasets[0].data}" varStatus="status">${value}${!status.last ? ',' : ''}</c:forEach>]
                        };

                        // Revenue by Product Chart
                        const revenueByProductCtx = document.getElementById('revenueByProductChart').getContext('2d');
                        const revenueByProductChart = new Chart(revenueByProductCtx, {
                            type: 'bar',
                            data: {
                                labels: revenueByProductData.labels,
                                datasets: [{
                                    label: 'Doanh thu theo sản phẩm',
                                    data: revenueByProductData.values,
                                    backgroundColor: 'rgba(153, 102, 255, 0.5)',
                                    borderColor: 'rgba(153, 102, 255, 1)',
                                    borderWidth: 2
                                }]
                            },
                            options: {
                                responsive: true,
                                maintainAspectRatio: false,
                                plugins: {
                                    legend: {
                                        display: false
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

                        // Inventory Status Chart
                        const inventoryStatusCtx = document.getElementById('inventoryStatusChart').getContext('2d');
                        const inventoryStatusChart = new Chart(inventoryStatusCtx, {
                            type: 'doughnut',
                            data: {
                                labels: inventoryStatusData.labels,
                                datasets: [{
                                    data: inventoryStatusData.values,
                                    backgroundColor: [
                                        'rgba(54, 162, 235, 0.7)',
                                        'rgba(75, 192, 192, 0.7)',
                                        'rgba(255, 99, 132, 0.7)'
                                    ],
                                    borderWidth: 2
                                }]
                            },
                            options: {
                                responsive: true,
                                maintainAspectRatio: false,
                                plugins: {
                                    legend: {
                                        position: 'bottom'
                                    }
                                }
                            }
                        });

                        // Product Table Pagination (5 items per page)
                        document.addEventListener('DOMContentLoaded', function () {
                            const itemsPerPage = 5;
                            const tableBody = document.querySelector('.table tbody');
                            const rows = Array.from(tableBody.querySelectorAll('tr')).filter(row => !row.querySelector('td[colspan]'));
                            const totalPages = Math.ceil(rows.length / itemsPerPage);
                            let currentPage = 1;

                            function showPage(page) {
                                rows.forEach((row, index) => {
                                    const startIndex = (page - 1) * itemsPerPage;
                                    const endIndex = startIndex + itemsPerPage;
                                    row.style.display = (index >= startIndex && index < endIndex) ? '' : 'none';
                                });

                                // Update pagination buttons
                                updatePaginationButtons(page);
                            }

                            function updatePaginationButtons(page) {
                                const paginationContainer = document.querySelector('.product-pagination');
                                if (!paginationContainer) return;

                                paginationContainer.innerHTML = '';
                                const ul = document.createElement('ul');
                                ul.className = 'pagination justify-content-center';

                                // Previous button
                                const prevLi = document.createElement('li');
                                prevLi.className = 'page-item' + (page === 1 ? ' disabled' : '');
                                prevLi.innerHTML = '<a class="page-link" href="#" data-page="' + (page - 1) + '">Trước</a>';
                                ul.appendChild(prevLi);

                                // Page numbers
                                for (let i = 1; i <= totalPages; i++) {
                                    const li = document.createElement('li');
                                    li.className = 'page-item' + (i === page ? ' active' : '');
                                    li.innerHTML = '<a class="page-link" href="#" data-page="' + i + '">' + i + '</a>';
                                    ul.appendChild(li);
                                }

                                // Next button
                                const nextLi = document.createElement('li');
                                nextLi.className = 'page-item' + (page === totalPages ? ' disabled' : '');
                                nextLi.innerHTML = '<a class="page-link" href="#" data-page="' + (page + 1) + '">Tiếp</a>';
                                ul.appendChild(nextLi);

                                paginationContainer.appendChild(ul);

                                // Add click handlers
                                ul.querySelectorAll('a.page-link').forEach(link => {
                                    link.addEventListener('click', function (e) {
                                        e.preventDefault();
                                        const newPage = parseInt(this.getAttribute('data-page'));
                                        if (newPage >= 1 && newPage <= totalPages) {
                                            currentPage = newPage;
                                            showPage(currentPage);
                                        }
                                    });
                                });
                            }

                            // Initialize pagination if there are rows
                            if (rows.length > 0) {
                                showPage(1);
                            }
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