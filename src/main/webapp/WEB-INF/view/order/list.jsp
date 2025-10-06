<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
            <%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>

                <!DOCTYPE html>
                <html lang="en">

                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>Order List</title>
                    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css"
                        rel="stylesheet">
                    <link rel="stylesheet"
                        href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
                    <style>
                        /* CSS cho hiệu ứng sidebar toggle */
                        .content {
                            margin-left: 0;
                            margin-top: 80px;
                            transition: margin-left 0.3s ease;
                            /* Căn giữa nội dung */
                            display: flex;
                            justify-content: center;
                            align-items: flex-start;
                            min-height: calc(100vh - 80px);
                            padding: 20px;
                        }

                        .content.shifted {
                            margin-left: 250px;
                        }

                        /* Container chính căn giữa */
                        .main-container {
                            max-width: 1200px;
                            width: 100%;
                            margin: 0 auto;
                        }

                        /* Card order list căn giữa */
                        .order-card {
                            margin: 0 auto;
                            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
                            border-radius: 10px;
                            overflow: hidden;
                        }

                        /* Responsive Design */
                        @media (max-width: 768px) {
                            .content.shifted {
                                margin-left: 200px;
                            }

                            .content {
                                padding: 10px;
                            }

                            .main-container {
                                max-width: 100%;
                            }
                        }

                        /* Style cho toggle button */
                        .sidebar-toggle-btn {
                            position: fixed;
                            top: 20px;
                            left: 20px;
                            z-index: 1001;
                            background-color: #2c3e50;
                            color: white;
                            border: none;
                            padding: 10px;
                            border-radius: 5px;
                            cursor: pointer;
                            transition: background-color 0.3s ease;
                        }

                        .sidebar-toggle-btn:hover {
                            background-color: #34495e;
                        }

                        /* Animation cho sidebar */
                        .sidebar {
                            transition: left 0.3s ease;
                        }
                    </style>
                </head>

                <body class="bg-light">
                    <!-- Nút toggle sidebar -->
                    <button onclick="toggleSidebar()" class="sidebar-toggle-btn">
                        <i class="bi bi-list"></i>
                    </button>

                    <!-- Import navbar và sidebar -->
                    <jsp:include page="../common/navbar.jsp" />
                    <jsp:include page="../common/sidebar.jsp" />

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

                                            <!-- Filter theo trạng thái -->
                                            <form class="d-flex gap-2" method="get">
                                                <input type="hidden" name="size" value="${size}">
                                                <select name="status" class="form-select form-select-sm"
                                                    style="width: auto;" onchange="this.form.submit()">
                                                    <option value="">All Status</option>
                                                    <c:forEach items="${orderStatuses}" var="status">
                                                        <option value="${status}" ${status==selectedStatus ? 'selected'
                                                            : '' }>
                                                            <c:choose>
                                                                <c:when test="${status == 'PENDING'}">Pending</c:when>
                                                                <c:when test="${status == 'PAID'}">Paid</c:when>
                                                                <c:when test="${status == 'SHIPPED'}">Shipped</c:when>
                                                                <c:when test="${status == 'PROCESSING'}">Processing
                                                                </c:when>
                                                                <c:when test="${status == 'COMPLETED'}">Completed
                                                                </c:when>
                                                                <c:when test="${status == 'CANCELLED'}">Cancelled
                                                                </c:when>
                                                                <c:when test="${status == 'REFUNDED'}">Refunded</c:when>
                                                                <c:otherwise>${status}</c:otherwise>
                                                            </c:choose>
                                                        </option>
                                                    </c:forEach>
                                                </select>
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
                                                            order.status == 'PAID' ? 'bg-info' :
                                                            order.status == 'PROCESSING' ? 'bg-primary' :
                                                            order.status == 'COMPLETED' ? 'bg-success' :
                                                            order.status == 'CANCELLED' ? 'bg-danger' :
                                                            order.status == 'REFUNDED' ? 'bg-secondary' :
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
                                                                            <c:if test="${order.sellerStore != null}">
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
                                                                            <c:when test="${order.status == 'PENDING'}">
                                                                                Pending</c:when>
                                                                            <c:when test="${order.status == 'PAID'}">
                                                                                Paid
                                                                            </c:when>
                                                                            <c:when
                                                                                test="${order.status == 'PROCESSING'}">
                                                                                Processing</c:when>
                                                                            <c:when
                                                                                test="${order.status == 'COMPLETED'}">
                                                                                Completed</c:when>
                                                                            <c:when
                                                                                test="${order.status == 'CANCELLED'}">
                                                                                Cancelled</c:when>
                                                                            <c:when
                                                                                test="${order.status == 'REFUNDED'}">
                                                                                Refunded</c:when>
                                                                            <c:otherwise>${order.status}</c:otherwise>
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
                                                            ${((currentPage + 1) * size > totalElements) ? totalElements
                                                            :
                                                            ((currentPage + 1) * size)}
                                                            of ${totalElements} orders
                                                        </div>

                                                        <!-- Kích thước trang nhanh -->
                                                        <form method="get" class="d-flex align-items-center gap-2">
                                                            <input type="hidden" name="status"
                                                                value="${selectedStatus}">
                                                            <input type="hidden" name="page" value="${currentPage}">
                                                            <label for="size" class="text-muted">Per page:</label>
                                                            <select id="size" name="size"
                                                                class="form-select form-select-sm" style="width:auto;"
                                                                onchange="this.form.submit()">
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

                                                        <ul class="pagination mb-0">
                                                            <!-- Nút Previous -->
                                                            <li class="page-item ${!hasPrev ? 'disabled' : ''}">
                                                                <a class="page-link"
                                                                    href="?page=${currentPage - 1}${sizeParam}${statusParam}"
                                                                    aria-label="Previous">
                                                                    <span aria-hidden="true">&laquo;</span>
                                                                </a>
                                                            </li>

                                                            <!-- Các trang -->
                                                            <c:forEach var="i" items="${pages}">
                                                                <li
                                                                    class="page-item ${currentPage == i ? 'active' : ''}">
                                                                    <a class="page-link"
                                                                        href="?page=${i}${sizeParam}${statusParam}">
                                                                        ${i + 1}
                                                                    </a>
                                                                </li>
                                                            </c:forEach>

                                                            <!-- Nút Next -->
                                                            <li class="page-item ${!hasNext ? 'disabled' : ''}">
                                                                <a class="page-link"
                                                                    href="?page=${currentPage + 1}${sizeParam}${statusParam}"
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

                    <jsp:include page="../common/footer.jsp" />

                    <script>
                        // Toggle sidebar function với tính năng bổ sung
                        function toggleSidebar() {
                            var sidebar = document.getElementById('sidebar');
                            var content = document.getElementById('content');

                            if (sidebar && content) {
                                // Toggle class 'active' cho sidebar
                                sidebar.classList.toggle('active');
                                // Toggle margin-left cho nội dung chính khi sidebar thay đổi trạng thái
                                content.classList.toggle('shifted');
                            }
                        }

                        // Khởi tạo khi trang load
                        document.addEventListener('DOMContentLoaded', function () {
                            // Thêm event listener cho phím ESC để đóng sidebar
                            document.addEventListener('keydown', function (event) {
                                if (event.key === 'Escape') {
                                    var sidebar = document.getElementById('sidebar');
                                    var content = document.getElementById('content');

                                    if (sidebar && content && sidebar.classList.contains('active')) {
                                        sidebar.classList.remove('active');
                                        content.classList.remove('shifted');
                                    }
                                }
                            });

                            // Auto-hide sidebar khi click bên ngoài
                            document.addEventListener('click', function (event) {
                                var sidebar = document.getElementById('sidebar');
                                var content = document.getElementById('content');
                                var toggleBtn = document.querySelector('.sidebar-toggle-btn');

                                // Nếu click bên ngoài sidebar và không phải toggle button
                                if (sidebar && content &&
                                    !sidebar.contains(event.target) &&
                                    (!toggleBtn || !toggleBtn.contains(event.target))) {

                                    // Nếu sidebar đang hiển thị thì ẩn đi
                                    if (sidebar.classList.contains('active')) {
                                        sidebar.classList.remove('active');
                                        content.classList.remove('shifted');
                                    }
                                }
                            });
                        });
                    </script>

                    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
                </body>

                </html>