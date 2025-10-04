<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
            <%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>

                <!DOCTYPE html>
                <html lang="vi">

                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>Danh sách đơn hàng</title>
                    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css"
                        rel="stylesheet">
                    <link rel="stylesheet"
                        href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
                </head>

                <body class="bg-light">
                    <!-- Import navbar và sidebar -->
                    <jsp:include page="../common/navbar.jsp" />
                    <jsp:include page="../common/sidebar.jsp" />

                    <div class="container" style="margin-top: 80px;">
                        <div class="row">
                            <div class="col-12">
                                <div class="card shadow-sm">
                                    <div
                                        class="card-header bg-primary text-white d-flex justify-content-between align-items-center">
                                        <h5 class="mb-0">
                                            <c:choose>
                                                <c:when test="${isSeller}">
                                                    <i class="bi bi-shop"></i> Đơn hàng của cửa hàng
                                                </c:when>
                                                <c:otherwise>
                                                    <i class="bi bi-cart"></i> Đơn hàng của tôi
                                                </c:otherwise>
                                            </c:choose>
                                        </h5>

                                        <!-- Filter theo trạng thái -->
                                        <form class="d-flex gap-2" method="get">
                                            <input type="hidden" name="size" value="${size}">
                                            <select name="status" class="form-select form-select-sm"
                                                style="width: auto;" onchange="this.form.submit()">
                                                <option value="">Tất cả trạng thái</option>
                                                <c:forEach items="${orderStatuses}" var="status">
                                                    <option value="${status}" ${status==selectedStatus ? 'selected' : ''
                                                        }>
                                                        <c:choose>
                                                            <c:when test="${status == 'PENDING'}">Chờ xử lý</c:when>
                                                            <c:when test="${status == 'PAID'}">Đã thanh toán</c:when>
                                                            <c:when test="${status == 'SHIPPED'}">Đã gửi hàng</c:when>
                                                            <c:when test="${status == 'PROCESSING'}">Đang xử lý</c:when>
                                                            <c:when test="${status == 'COMPLETED'}">Hoàn thành</c:when>
                                                            <c:when test="${status == 'CANCELLED'}">Đã hủy</c:when>
                                                            <c:when test="${status == 'REFUNDED'}">Đã hoàn tiền</c:when>
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
                                                        <th scope="col">Mã đơn</th>
                                                        <th scope="col">Sản phẩm</th>
                                                        <th scope="col">
                                                            <c:choose>
                                                                <c:when test="${isSeller}">Người mua</c:when>
                                                                <c:otherwise>Cửa hàng</c:otherwise>
                                                            </c:choose>
                                                        </th>
                                                        <th scope="col">Số lượng</th>
                                                        <th scope="col">Tổng tiền</th>
                                                        <th scope="col">Trạng thái</th>
                                                        <th scope="col">Ngày tạo</th>
                                                        <th scope="col">Thao tác</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <c:if test="${empty orders}">
                                                        <tr>
                                                            <td colspan="8" class="text-center">Không có đơn hàng nào
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
                                                                        <c:when test="${order.status == 'PENDING'}">Chờ
                                                                            xử lý</c:when>
                                                                        <c:when test="${order.status == 'PAID'}">Đã
                                                                            thanh toán</c:when>
                                                                        <c:when test="${order.status == 'PROCESSING'}">
                                                                            Đang xử lý</c:when>
                                                                        <c:when test="${order.status == 'COMPLETED'}">
                                                                            Hoàn thành</c:when>
                                                                        <c:when test="${order.status == 'CANCELLED'}">Đã
                                                                            hủy</c:when>
                                                                        <c:when test="${order.status == 'REFUNDED'}">Đã
                                                                            hoàn tiền</c:when>
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
                                                                    <i class="bi bi-info-circle"></i> Chi tiết
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
                                                        Hiển thị ${(currentPage * size) + 1}
                                                        -
                                                        ${((currentPage + 1) * size > totalElements) ? totalElements :
                                                        ((currentPage + 1) * size)}
                                                        trên tổng số ${totalElements} đơn hàng
                                                    </div>

                                                    <!-- Kích thước trang nhanh -->
                                                    <form method="get" class="d-flex align-items-center gap-2">
                                                        <input type="hidden" name="status" value="${selectedStatus}">
                                                        <input type="hidden" name="page" value="${currentPage}">
                                                        <label for="size" class="text-muted">Mỗi trang:</label>
                                                        <select id="size" name="size" class="form-select form-select-sm"
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
                                                            <li class="page-item ${currentPage == i ? 'active' : ''}">
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

                    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
                </body>

                </html>