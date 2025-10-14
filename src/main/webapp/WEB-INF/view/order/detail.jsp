<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
            <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

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
                        <!-- Page Content will be inserted here -->
                        <div class="content" id="content">
                            <div class="main-container">
                                <div class="row justify-content-center">
                                    <div class="col-lg-10 col-xl-8">
                                        <nav aria-label="breadcrumb" class="mb-4">
                                            <ol class="breadcrumb">
                                                <li class="breadcrumb-item"><a href="/orders"
                                                        class="text-decoration-none">Orders</a></li>
                                                <li class="breadcrumb-item active">Order Details #${order.id}</li>
                                            </ol>
                                        </nav>
                                        <div class="card shadow-sm order-card">
                                            <div
                                                class="card-header bg-primary text-white d-flex justify-content-between align-items-center">
                                                <h5 class="mb-0"><i class="bi bi-info-circle"></i> Order #${order.id}
                                                </h5>
                                                <span class="badge fs-6">
                                                    <c:forEach items="${orderStatuses}" var="status">
                                                        <c:if test="${order.status == status}">
                                                            <span class="badge
                                                                ${status == 'PENDING' ? 'bg-warning' :
                                                                status == 'COMPLETED' ? 'bg-success' :
                                                                status == 'CANCELLED' ? 'bg-danger' :
                                                                'bg-light'}">
                                                                ${status}
                                                            </span>
                                                        </c:if>
                                                    </c:forEach>
                                                </span>
                                            </div>
                                            <div class="card-body">
                                                <div class="row">
                                                    <div class="col-md-6">
                                                        <h6 class="border-bottom pb-2">Order Information</h6>
                                                        <table class="table table-borderless">
                                                            <tr>
                                                                <td class="text-muted">Order ID:</td>
                                                                <td>#${order.id}</td>
                                                            </tr>
                                                            <tr>
                                                                <td class="text-muted">Created Date:</td>
                                                                <td>
                                                                    <c:out value="${order.createdAt}" />
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td class="text-muted">Status:</td>
                                                                <td>
                                                                    <c:forEach items="${orderStatuses}" var="status">
                                                                        <c:if test="${order.status == status}">
                                                                            <span class="badge
                                                                                ${status == 'PENDING' ? 'bg-warning' :
                                                                                status == 'COMPLETED' ? 'bg-success' :
                                                                                status == 'CANCELLED' ? 'bg-danger' :
                                                                                'bg-light'}">
                                                                                ${status}
                                                                            </span>
                                                                        </c:if>
                                                                    </c:forEach>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td class="text-muted">Total Amount:</td>
                                                                <td>
                                                                    <fmt:formatNumber value="${order.totalAmount}"
                                                                        type="currency" currencySymbol="₫"
                                                                        maxFractionDigits="0" />
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </div>
                                                    <div class="col-md-6">
                                                        <h6 class="border-bottom pb-2">Buyer/Seller Information</h6>
                                                        <table class="table table-borderless">
                                                            <c:if
                                                                test="${order.buyer != null && (order.buyer.id == currentUser.id || !isSeller)}">
                                                                <tr>
                                                                    <td class="text-muted">Buyer:</td>
                                                                    <td>${order.buyer.fullName}
                                                                        (${order.buyer.username})
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td class="text-muted">Email:</td>
                                                                    <td>${order.buyer.email}</td>
                                                                </tr>
                                                            </c:if>
                                                            <c:if test="${order.sellerStore != null}">
                                                                <tr>
                                                                    <td class="text-muted">Store:</td>
                                                                    <td>${order.sellerStore.storeName}</td>
                                                                </tr>
                                                            </c:if>
                                                        </table>
                                                    </div>
                                                    <div class="col-12 mt-4">
                                                        <h6 class="border-bottom pb-2">Product Details</h6>
                                                        <table class="table table-borderless">
                                                            <tr>
                                                                <td class="text-muted">Product:</td>
                                                                <td>
                                                                    <c:if test="${order.product != null}">
                                                                        <a href="/products/${order.product.id}"
                                                                            class="fw-bold text-decoration-none">${order.productName}</a>
                                                                    </c:if>
                                                                    <c:if test="${order.product == null}">
                                                                        ${order.productName}
                                                                    </c:if>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td class="text-muted">Price:</td>
                                                                <td>
                                                                    <fmt:formatNumber value="${order.productPrice}"
                                                                        type="currency" currencySymbol="₫"
                                                                        maxFractionDigits="0" />
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td class="text-muted">Quantity:</td>
                                                                <td>${order.quantity}</td>
                                                            </tr>


                                                        </table>
                                                    </div>


                                                    <!-- Hiển thị danh sách các key/account đã mua -->
                                                    <c:if test="${not empty order.productStorages}">
                                                        <div class="col-12 mt-4">
                                                            <h6 class="border-bottom pb-2">
                                                                <i class="bi bi-key-fill text-primary"></i> Danh sách
                                                                Key/Account đã mua
                                                            </h6>
                                                            <div class="card border-primary">
                                                                <div class="card-body">
                                                                    <table class="table table-bordered">
                                                                        <thead>
                                                                            <tr>
                                                                                <th>ID</th>
                                                                                <th>Payload</th>
                                                                                <th>Trạng thái</th>
                                                                                <th>Ghi chú</th>
                                                                            </tr>
                                                                        </thead>
                                                                        <tbody>
                                                                            <c:forEach var="storage"
                                                                                items="${order.productStorages}">
                                                                                <tr>
                                                                                    <td>${storage.id}</td>
                                                                                    <td>
                                                                                        <c:out
                                                                                            value="${storage.payloadJson}" />
                                                                                    </td>
                                                                                    <td>${storage.status}</td>
                                                                                    <td>
                                                                                        <c:out
                                                                                            value="${storage.note}" />
                                                                                    </td>
                                                                                </tr>
                                                                            </c:forEach>
                                                                        </tbody>
                                                                    </table>
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </c:if>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="card-footer text-end">
                                            <a href="/orders" class="btn btn-secondary"><i class="bi bi-arrow-left"></i>
                                                Back</a>
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