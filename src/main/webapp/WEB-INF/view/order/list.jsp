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
                </head>

                <body>
                    <!-- Include Navbar -->
                    <jsp:include page="../common/navbar.jsp" />

                    <!-- Include Sidebar -->
                    <jsp:include page="../common/sidebar.jsp" />

                    <!-- Main Content Area -->
                    <div class="content" id="content">
                        <div class="content" id="content">
                            <div class="main-container">
                                <div class="row justify-content-center">
                                    <div class="col-lg-11 col-xl-10">
                                        <div class="card shadow-sm order-card">
                                            <div
                                                class="card-header bg-primary text-white d-flex justify-content-between align-items-center">
                                                <h5 class="mb-0">
                                                    <c:choose>
                                                        <c:when test="${isSeller}">
                                                            <i class="bi bi-shop"></i> Store Orders
                                                        </c:when>
                                                        <c:otherwise>
                                                            <i class="bi bi-cart"></i> My Orders
                                                        </c:otherwise>
                                                    </c:choose>
                                                </h5>

                                                <!-- Filter + Search -->
                                                <form class="d-flex gap-2 align-items-center" method="get">
                                                    <input type="hidden" name="size" value="${size}">
                                                    <select name="status" class="form-select form-select-sm"
                                                        style="width: auto;" onchange="this.form.submit()">
                                                        <option value="">All Status</option>
                                                        <c:forEach items="${orderStatuses}" var="status">
                                                            <c:if
                                                                test="${status == 'PENDING' || status == 'COMPLETED' || status == 'CANCELLED'}">
                                                                <option value="${status}" ${status==selectedStatus
                                                                    ? 'selected' : '' }>
                                                                    <c:choose>
                                                                        <c:when test="${status == 'PENDING'}">Pending
                                                                        </c:when>
                                                                        <c:when test="${status == 'COMPLETED'}">
                                                                            Completed
                                                                        </c:when>
                                                                        <c:when test="${status == 'CANCELLED'}">
                                                                            Cancelled
                                                                        </c:when>
                                                                    </c:choose>
                                                                </option>
                                                            </c:if>
                                                        </c:forEach>
                                                    </select>

                                                    <!-- Search by product name -->
                                                    <input type="text" name="q" value="${q}"
                                                        placeholder="Search product name..."
                                                        class="form-control form-control-sm" style="width: 240px;">
                                                    <button type="submit" class="btn btn-sm btn-light">
                                                        <i class="bi bi-search"></i>
                                                    </button>
                                                </form>
                                            </div>

                                            <div class="card-body">
                                                <!-- Bảng danh sách đơn hàng -->
                                                <div class="table-responsive">
                                                    <table class="table table-hover">
                                                        <thead>
                                                            <tr>
                                                                <th scope="col">Order ID</th>
                                                                <th scope="col">Product</th>
                                                                <th scope="col">
                                                                    <c:choose>
                                                                        <c:when test="${isSeller}">Buyer</c:when>
                                                                        <c:otherwise>Store</c:otherwise>
                                                                    </c:choose>
                                                                </th>
                                                                <th scope="col">Quantity</th>
                                                                <th scope="col">Total Amount</th>
                                                                <th scope="col">Status</th>
                                                                <th scope="col">Created Date</th>
                                                                <th scope="col">Action</th>
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
                                                                <c:set var="badgeClass" value="${
                                                            order.status == 'PENDING' ? 'bg-warning' :
                                                            order.status == 'COMPLETED' ? 'bg-success' :
                                                            order.status == 'CANCELLED' ? 'bg-danger' :
                                                            'bg-light'
                                                        }" />
                                                                <tr>
                                                                    <td>#${order.id}</td>
                                                                    <td>
                                                                        <c:if test="${order.product != null}">
                                                                            <a href="/products/${order.product.id}"
                                                                                class="text-decoration-none">
                                                                                ${order.productName}
                                                                            </a>
                                                                        </c:if>
                                                                        <c:if test="${order.product == null}">
                                                                            ${order.productName}
                                                                        </c:if>
                                                                    </td>
                                                                    <td>
                                                                        <c:choose>
                                                                            <c:when test="${isSeller}">
                                                                                <c:if test="${order.buyer != null}">
                                                                                    ${order.buyer.username}
                                                                                </c:if>
                                                                            </c:when>
                                                                            <c:otherwise>
                                                                                <c:if
                                                                                    test="${order.sellerStore != null}">
                                                                                    ${order.sellerStore.storeName}
                                                                                </c:if>
                                                                            </c:otherwise>
                                                                        </c:choose>
                                                                    </td>
                                                                    <td>${order.quantity}</td>
                                                                    <td>
                                                                        <fmt:formatNumber value="${order.totalAmount}"
                                                                            type="currency" currencySymbol="₫"
                                                                            maxFractionDigits="0" />
                                                                    </td>
                                                                    <td>
                                                                        <span class="badge ${badgeClass}">
                                                                            <c:choose>
                                                                                <c:when
                                                                                    test="${order.status == 'PENDING'}">
                                                                                    Pending</c:when>
                                                                                <c:when
                                                                                    test="${order.status == 'COMPLETED'}">
                                                                                    Completed</c:when>
                                                                                <c:when
                                                                                    test="${order.status == 'CANCELLED'}">
                                                                                    Cancelled</c:when>
                                                                            </c:choose>
                                                                        </span>
                                                                    </td>
                                                                    <td>
                                                                        <c:out value="${order.createdAt}" />
                                                                    </td>

                                                                    <td>
                                                                        <a href="/orders/${order.id}"
                                                                            class="btn btn-sm btn-info text-white">
                                                                            <i class="bi bi-info-circle"></i> Details
                                                                        </a>
                                                                    </td>
                                                                </tr>
                                                            </c:forEach>
                                                        </tbody>
                                                    </table>
                                                </div>

                                                <!-- Phân trang -->
                                                <c:if test="${totalPages > 0}">
                                                    <nav aria-label="Page navigation" class="mt-4">
                                                        <div
                                                            class="d-flex justify-content-between align-items-center flex-wrap gap-2">
                                                            <div class="text-muted">
                                                                Showing ${(currentPage * size) + 1}
                                                                -
                                                                ${((currentPage + 1) * size > totalElements) ?
                                                                totalElements
                                                                :
                                                                ((currentPage + 1) * size)}
                                                                of ${totalElements} orders
                                                            </div>

                                                            <!-- Kích thước trang nhanh -->
                                                            <form method="get" class="d-flex align-items-center gap-2">
                                                                <input type="hidden" name="status"
                                                                    value="${selectedStatus}">
                                                                <input type="hidden" name="page" value="${currentPage}">
                                                                <input type="hidden" name="q" value="${q}">
                                                                <label for="size" class="text-muted">Per page:</label>
                                                                <select id="size" name="size"
                                                                    class="form-select form-select-sm"
                                                                    style="width:auto;" onchange="this.form.submit()">
                                                                    <option value="1" ${size==1 ? 'selected' : '' }>1
                                                                    </option>
                                                                    <option value="20" ${size==20 ? 'selected' : '' }>20
                                                                    </option>
                                                                    <option value="50" ${size==50 ? 'selected' : '' }>50
                                                                    </option>
                                                                </select>
                                                            </form>

                                                            <c:set var="statusParam"
                                                                value="${not empty selectedStatus ? '&status='.concat(selectedStatus) : ''}" />
                                                            <c:set var="sizeParam" value="${'&size='.concat(size)}" />
                                                            <c:set var="qParam"
                                                                value="${not empty q ? '&q='.concat(q) : ''}" />

                                                            <ul class="pagination mb-0">
                                                                <!-- Nút Previous -->
                                                                <li class="page-item ${!hasPrev ? 'disabled' : ''}">
                                                                    <a class="page-link"
                                                                        href="?page=${currentPage - 1}${sizeParam}${statusParam}${qParam}"
                                                                        aria-label="Previous">
                                                                        <span aria-hidden="true">&laquo;</span>
                                                                    </a>
                                                                </li>

                                                                <!-- Các trang -->
                                                                <c:forEach var="i" items="${pages}">
                                                                    <li
                                                                        class="page-item ${currentPage == i ? 'active' : ''}">
                                                                        <a class="page-link"
                                                                            href="?page=${i}${sizeParam}${statusParam}${qParam}">
                                                                            ${i + 1}
                                                                        </a>
                                                                    </li>
                                                                </c:forEach>

                                                                <!-- Nút Next -->
                                                                <li class="page-item ${!hasNext ? 'disabled' : ''}">
                                                                    <a class="page-link"
                                                                        href="?page=${currentPage + 1}${sizeParam}${statusParam}${qParam}"
                                                                        aria-label="Next">
                                                                        <span aria-hidden="true">&raquo;</span>
                                                                    </a>
                                                                </li>
                                                            </ul>
                                                        </div>
                                                    </nav>
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
                </body>

                </html>