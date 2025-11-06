<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
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
                        
                <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/order_list.css">
                </head>

                <body>
                    <!-- Include Navbar -->
                    <jsp:include page="../common/navbar.jsp" />

                    <!-- Include Sidebar -->
                    <jsp:include page="../common/sidebar.jsp" />

                    <!-- Sidebar Overlay for Mobile -->
                    <div class="sidebar-overlay" id="sidebarOverlay" onclick="toggleSidebar()"
                        onKeyDown="if(event.key === 'Enter') toggleSidebar()" role="button" tabindex="0"></div>

                    <!-- Main Content Area -->
                    <div class="content" id="content">
                        <div class="container-fluid">
                            <h1>
                                <i class="fas fa-shopping-cart"></i> My Orders
                            </h1>

                            <!-- Filter Section -->
                            <div class="filter-section">
                                <form method="get" class="row filter-row">
                                    <!-- Search by product name -->
                                    <div class="col-md-4">
                                        <div class="filter-label">Search Product</div>
                                        <div class="input-group">
                                            <input type="text" name="key" value="${key}" class="form-control"
                                                placeholder="Enter product name...">
                                            <button type="submit" class="btn btn-primary">
                                                <i class="fas fa-search"></i>
                                            </button>
                                        </div>
                                    </div>

                                    <!-- Order Status Filter -->
                                    <div class="col-md-4">
                                        <div class="filter-label">Order Status</div>
                                        <select name="status" class="form-select" onchange="this.form.submit()">
                                            <option value="">All Orders</option>
                                            <c:forEach items="${orderStatuses}" var="status">
                                                <option value="${status}" ${status==selectedStatus ? 'selected' : '' }>
                                                    ${status}
                                                </option>
                                            </c:forEach>
                                        </select>
                                    </div>

                                    <!-- Clear Filters -->
                                    <div class="col-md-4 d-flex align-items-end">
                                        <a href="/orders" class="btn btn-outline-secondary">
                                            <i class="fas fa-times"></i> Clear Filters
                                        </a>
                                    </div>
                                </form>
                            </div>

                            <div class="card-body">
                                <!-- Bảng danh sách đơn hàng -->
                                <div class="table-responsive">
                                    <table id="resizableTable"
                                        class="table table-hover table-bordered table-striped resizable-table">
                                        <thead class="table-light">
                                            <tr>
                                                <th class="sortable" data-column="0" data-type="text">
                                                    Order ID
                                                    <div class="resizer"></div>
                                                </th>
                                                <th class="sortable" data-column="1" data-type="text">
                                                    Product
                                                    <div class="resizer"></div>
                                                </th>
                                                <th class="sortable" data-column="2" data-type="text">
                                                    Store
                                                    <div class="resizer"></div>
                                                </th>
                                                <th class="sortable" data-column="3" data-type="number">
                                                    Quantity
                                                    <div class="resizer"></div>
                                                </th>
                                                <th class="sortable" data-column="4" data-type="number">
                                                    Total Amount
                                                    <div class="resizer"></div>
                                                </th>
                                                <th class="sortable" data-column="5" data-type="text">
                                                    Status
                                                    <div class="resizer"></div>
                                                </th>
                                                <th class="sortable" data-column="6" data-type="date">
                                                    Created Date
                                                    <div class="resizer"></div>
                                                </th>
                                                <th>
                                                    Action
                                                    <div class="resizer"></div>
                                                </th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:if test="${empty orders}">
                                                <tr>
                                                    <td colspan="8" class="text-center">No orders found
                                                    </td>
                                                </tr>
                                            </c:if>
                                            <c:forEach items="${orders}" var="order">


                                                <tr>
                                                    <td>#${order.id}</td>
                                                    <td>
                                                        <c:if test="${order.product != null}">
                                                            <a href="/product/${order.product.slug}"
                                                                class="text-decoration-none">
                                                                ${order.productName}
                                                            </a>
                                                        </c:if>
                                                        <c:if test="${order.product == null}">
                                                            ${order.productName}
                                                        </c:if>
                                                    </td>
                                                    <td>
                                                        <c:if test="${order.sellerStore != null}">
                                                            ${order.sellerStore.storeName}
                                                        </c:if>
                                                        <c:if test="${order.sellerStore == null}">
                                                            N/A
                                                        </c:if>
                                                    </td>
                                                    <td>${order.quantity}</td>
                                                    <td>
                                                        <fmt:formatNumber value="${order.totalAmount}" type="currency"
                                                            currencySymbol="₫" maxFractionDigits="0" />
                                                    </td>
                                                    <td>
                                                        <span class="badge ${badgeClass}" style="color: black;"></span>
                                                        ${order.status}
                                                        </span>
                                                    </td>

                                                    <td>
                                                        <c:out value="${order.createdAt}" />
                                                    </td>

                                                    <td>
                                                        <a href="/orders/${order.id}"
                                                            class="btn btn-sm btn-info text-white mb-1">
                                                            <i class="bi bi-info-circle"></i> Details
                                                        </a>
                                                        
                                                        <!-- Rate button - chỉ hiện khi order COMPLETED và chưa đánh giá -->
                                                        <c:if test="${order.status == 'COMPLETED'}">
                                                            <c:choose>
                                                                <c:when test="${order.rating != null}">
                                                                    <button type="button" class="btn btn-sm btn-secondary mb-1" disabled>
                                                                        <i class="bi bi-check-circle"></i> Rated (${order.rating}★)
                                                                    </button>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <button type="button" class="btn btn-sm btn-warning text-white mb-1"
                                                                        onclick="openRatingModal(${order.id}, ${order.product.id}, '${order.productName}')">
                                                                        <i class="bi bi-star"></i> Rate
                                                                    </button>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </c:if>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </div>

                                <!-- Pagination -->
                                <c:if test="${totalPages > 0}">


                                    <!-- Pagination controls -->
                                    <div class="pagination-container">
                                        <nav>
                                            <ul class="pagination mb-0">
                                                <!-- First page -->
                                                <li class="page-item ${currentPage == 0 ? 'disabled' : ''}">
                                                    <a class="page-link"
                                                        href="?page=0&status=${selectedStatus}&key=${key}"
                                                        aria-label="First">
                                                        <span aria-hidden="true">&laquo;&laquo;</span>
                                                    </a>
                                                </li>
                                                <!-- Previous page -->
                                                <li class="page-item ${currentPage == 0 ? 'disabled' : ''}">
                                                    <a class="page-link"
                                                        href="?page=${currentPage - 1}&status=${selectedStatus}&key=${key}"
                                                        aria-label="Previous">
                                                        <span aria-hidden="true">&laquo;</span>
                                                    </a>
                                                </li>

                                                <!-- Page numbers -->
                                                <c:forEach begin="0" end="${totalPages - 1}" var="pageNum">
                                                    <c:if
                                                        test="${pageNum >= currentPage - 1 && pageNum <= currentPage + 1}">
                                                        <li class="page-item ${pageNum == currentPage ? 'active' : ''}">
                                                            <a class="page-link"
                                                                href="?page=${pageNum}&status=${selectedStatus}&key=${key}">
                                                                ${pageNum + 1}
                                                            </a>
                                                        </li>
                                                    </c:if>
                                                </c:forEach>

                                                <!-- Next page -->
                                                <li
                                                    class="page-item ${currentPage + 1 >= totalPages ? 'disabled' : ''}">
                                                    <a class="page-link"
                                                        href="?page=${currentPage + 1}&status=${selectedStatus}&key=${key}"
                                                        aria-label="Next">
                                                        <span aria-hidden="true">&raquo;</span>
                                                    </a>
                                                </li>

                                                <!-- Last page button -->
                                                <li
                                                    class="page-item ${currentPage == totalPages - 1 ? 'disabled' : ''}">
                                                    <a class="page-link"
                                                        href="?page=${totalPages - 1}&status=${selectedStatus}&key=${key}"
                                                        aria-label="Last">
                                                        <span aria-hidden="true">&raquo;&raquo;</span>
                                                    </a>
                                                </li>
                                            </ul>
                                        </nav>
                                    </div>
                                </c:if>
                            </div>
                        </div>
                    </div>
                    </div>
                    </div>
                    </div>
                    </div>

                    <!-- Include Footer -->
                    <jsp:include page="../common/footer.jsp" />

                    <!-- Script to display notifications using iziToast -->
                    <c:if test="${not empty successMessage}">
                        <script>
                            iziToast.success({
                                title: 'Success!',
                                message: '${successMessage}',
                                position: 'topRight',
                                timeout: 5000
                            });
                        </script>
                    </c:if>

                    <c:if test="${not empty errorMessage}">
                        <script>
                            iziToast.error({
                                title: 'Error!',
                                message: '${errorMessage}',
                                position: 'topRight',
                                timeout: 5000
                            });
                        </script>
                    </c:if>

                    <!-- Page-specific JavaScript -->
                    <c:if test="${not empty pageJS}">
                        <c:forEach var="js" items="${pageJS}">
                            <script src="${pageContext.request.contextPath}${js}"></script>
                        </c:forEach>
                    </c:if>

                    <!-- Common JavaScript -->
                    <script>
                        document.addEventListener('DOMContentLoaded', function () {
                            // Add sorting functionality
                            var headers = document.querySelectorAll('.resizable-table th.sortable');
                            headers.forEach(function (header) {
                                header.addEventListener('click', function () {
                                    const column = this.dataset.column;
                                    const dataType = this.dataset.type;
                                    const table = document.getElementById('resizableTable');

                                    // Toggle sort direction
                                    const isAsc = !this.classList.contains('sort-asc');

                                    // Remove sort classes from all headers
                                    headers.forEach(h => {
                                        h.classList.remove('sort-asc', 'sort-desc');
                                    });

                                    // Add sort class to current header
                                    this.classList.add(isAsc ? 'sort-asc' : 'sort-desc');

                                    // Sort table
                                    sortTable(table, column, dataType, isAsc ? 'asc' : 'desc');
                                });
                            });

                            // Add resizing functionality
                            var resizers = document.querySelectorAll('.resizer');
                            resizers.forEach(function (resizer) {
                                resizer.addEventListener('mousedown', function (e) {
                                    startResize(e, this);
                                });
                            });
                        });

                        function sortTable(table, columnIndex, dataType, direction) {
                            const tbody = table.querySelector('tbody');
                            const rows = Array.from(tbody.querySelectorAll('tr'));

                            rows.sort((a, b) => {
                                const aValue = a.cells[columnIndex].textContent.trim();
                                const bValue = b.cells[columnIndex].textContent.trim();

                                let comparison = 0;

                                if (dataType === 'number') {
                                    // Remove currency symbols and commas, then convert to number
                                    const aNum = parseFloat(aValue.replace(/[^0-9.-]+/g, '')) || 0;
                                    const bNum = parseFloat(bValue.replace(/[^0-9.-]+/g, '')) || 0;
                                    comparison = aNum - bNum;
                                } else if (dataType === 'date') {
                                    // Parse date
                                    const aDate = new Date(aValue);
                                    const bDate = new Date(bValue);
                                    comparison = aDate - bDate;
                                } else {
                                    // Text comparison
                                    comparison = aValue.localeCompare(bValue, 'vi');
                                }

                                return direction === 'asc' ? comparison : -comparison;
                            });

                            // Re-append sorted rows
                            rows.forEach(row => tbody.appendChild(row));
                        }

                        function startResize(e, resizer) {
                            e.preventDefault();
                            resizer.classList.add('resizing');

                            var startX = e.clientX;
                            var startWidth = resizer.parentElement.offsetWidth;

                            function doResize(e) {
                                var newWidth = startWidth + e.clientX - startX;
                                resizer.parentElement.style.width = newWidth + 'px';
                            }

                            function stopResize() {
                                resizer.classList.remove('resizing');
                                document.removeEventListener('mousemove', doResize);
                                document.removeEventListener('mouseup', stopResize);
                            }

                            document.addEventListener('mousemove', doResize);
                            document.addEventListener('mouseup', stopResize);
                        }

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
                                !menuToggle.contains(event.target)) {
                                toggleSidebar();
                            }
                        });

                        // Flash messages
                        <c:if test="${not empty success}">
                            iziToast.success({
                                title: 'Success',
                                message: '${success}',
                                position: 'topRight'
                            });
                        </c:if>
                        <c:if test="${not empty error}">
                            iziToast.error({
                                title: 'Error',
                                message: '${error}',
                                position: 'topRight'
                            });
                        </c:if>
                    </script>

                    <!-- Rating Modal -->
                    <div class="modal fade" id="ratingModal" tabindex="-1" aria-labelledby="ratingModalLabel"
                        aria-hidden="true">
                        <div class="modal-dialog modal-dialog-centered">
                            <div class="modal-content">
                                <div class="modal-header bg-warning text-dark">
                                    <h5 class="modal-title" id="ratingModalLabel">Rate Product</h5>
                                    <button type="button" class="btn-close" data-bs-dismiss="modal"
                                        aria-label="Close"></button>
                                </div>
                                <div class="modal-body">
                                    <form id="ratingForm" method="POST" action="">
                                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                                        <input type="hidden" id="ratingValue" name="rating" value="0" />

                                        <div class="mb-3">
                                            <label class="form-label fw-bold">Product: <span
                                                    id="productNameDisplay"></span></label>
                                        </div>

                                        <div class="mb-3">
                                            <label class="form-label fw-bold">Rating</label>
                                            <div class="star-rating d-flex gap-2 fs-2">
                                                <i class="bi bi-star-fill star-icon" data-rating="1"></i>
                                                <i class="bi bi-star-fill star-icon" data-rating="2"></i>
                                                <i class="bi bi-star-fill star-icon" data-rating="3"></i>
                                                <i class="bi bi-star-fill star-icon" data-rating="4"></i>
                                                <i class="bi bi-star-fill star-icon" data-rating="5"></i>
                                            </div>
                                        </div>
                                    </form>
                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                                    <button type="submit" form="ratingForm" class="btn btn-warning" id="submitRating">Submit
                                        Rating</button>
                                </div>
                            </div>
                        </div>
                    </div>

                   

                    <script>
                        let selectedRating = 0;

                        function openRatingModal(orderId, productId, productName) {
                            // Set form action URL
                            document.getElementById('ratingForm').action = '/orders/' + orderId + '/rate';
                            document.getElementById('productNameDisplay').textContent = productName;
                            document.getElementById('ratingValue').value = 0;
                            selectedRating = 0;
                            updateStars(0);
                            var modal = new bootstrap.Modal(document.getElementById('ratingModal'));
                            modal.show();
                        }

                        function updateStars(rating) {
                            const stars = document.querySelectorAll('.star-icon');
                            stars.forEach((star, index) => {
                                if (index < rating) {
                                    star.classList.add('active');
                                } else {
                                    star.classList.remove('active');
                                }
                            });
                        }

                        // Star click event
                        document.querySelectorAll('.star-icon').forEach(star => {
                            star.addEventListener('click', function () {
                                selectedRating = parseInt(this.getAttribute('data-rating'));
                                document.getElementById('ratingValue').value = selectedRating;
                                updateStars(selectedRating);
                            });

                            // Hover effect
                            star.addEventListener('mouseenter', function () {
                                const hoverRating = parseInt(this.getAttribute('data-rating'));
                                const stars = document.querySelectorAll('.star-icon');
                                stars.forEach((s, index) => {
                                    if (index < hoverRating) {
                                        s.classList.add('hover');
                                    } else {
                                        s.classList.remove('hover');
                                    }
                                });
                            });

                            star.addEventListener('mouseleave', function () {
                                document.querySelectorAll('.star-icon').forEach(s => s.classList.remove('hover'));
                            });
                        });

                        // Validate form trước khi submit
                        document.getElementById('ratingForm').addEventListener('submit', function (e) {
                            const rating = document.getElementById('ratingValue').value;

                            if (rating === '0') {
                                e.preventDefault();
                                iziToast.warning({
                                    title: 'Warning',
                                    message: 'Please select a rating',
                                    position: 'topRight'
                                });
                                return false;
                            }
                        });
                    </script>
                </body>

                </html>