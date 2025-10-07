<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
            <!DOCTYPE html>
            <html lang="en">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Order Details #${order.id}</title>
                <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
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

                    /* Card order details căn giữa */
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

                <jsp:include page="../common/navbar.jsp" />
                <jsp:include page="../common/sidebar.jsp" />
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
                                        <h5 class="mb-0"><i class="bi bi-info-circle"></i> Order #${order.id}</h5>
                                        <span class="badge
                            ${order.status=='PENDING' ? 'bg-warning' :
                            order.status=='COMPLETED' ? 'bg-success' :
                            order.status=='CANCELLED' ? 'bg-danger' :
                            'bg-light'} fs-6">
                                            <c:choose>
                                                <c:when test="${order.status == 'PENDING'}">Pending</c:when>
                                                <c:when test="${order.status == 'COMPLETED'}">Completed</c:when>
                                                <c:when test="${order.status == 'CANCELLED'}">Cancelled</c:when>
                                                <c:otherwise>${order.status}</c:otherwise>
                                            </c:choose>
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
                                                            <span class="badge
                                            ${order.status=='PENDING' ? 'bg-warning' :
                                            order.status=='COMPLETED' ? 'bg-success' :
                                            order.status=='CANCELLED' ? 'bg-danger' :
                                            'bg-light'}">
                                                                <c:choose>
                                                                    <c:when test="${order.status == 'PENDING'}">Pending
                                                                    </c:when>
                                                                    <c:when test="${order.status == 'COMPLETED'}">
                                                                        Completed</c:when>
                                                                    <c:when test="${order.status == 'CANCELLED'}">
                                                                        Cancelled</c:when>
                                                                    <c:otherwise>${order.status}</c:otherwise>
                                                                </c:choose>
                                                            </span>
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
                                                            <td>${order.buyer.fullName} (${order.buyer.username})</td>
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
                                                                                <c:out value="${storage.payloadJson}" />
                                                                            </td>
                                                                            <td>${storage.status}</td>
                                                                            <td>
                                                                                <c:out value="${storage.note}" />
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