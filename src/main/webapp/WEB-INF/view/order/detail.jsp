<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Chi tiết đơn hàng #${order.id}</title>
                <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
                <link rel="stylesheet"
                    href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
            </head>

            <body class="bg-light">
                <jsp:include page="../common/navbar.jsp" />
                <jsp:include page="../common/sidebar.jsp" />
                <div class="container mt-4">
                    <div class="row">
                        <div class="col-12">
                            <nav aria-label="breadcrumb" class="mb-4">
                                <ol class="breadcrumb">
                                    <li class="breadcrumb-item"><a href="/orders" class="text-decoration-none">Đơn
                                            hàng</a></li>
                                    <li class="breadcrumb-item active">Chi tiết đơn hàng #${order.id}</li>
                                </ol>
                            </nav>
                            <div class="card shadow-sm">
                                <div
                                    class="card-header bg-primary text-white d-flex justify-content-between align-items-center">
                                    <h5 class="mb-0"><i class="bi bi-info-circle"></i> Đơn hàng #${order.id}</h5>
                                    <span class="badge
                            ${order.status=='PENDING' ? 'bg-warning' :
                            order.status=='PAID' ? 'bg-info' :
                            order.status=='PROCESSING' ? 'bg-primary' :
                            order.status=='SHIPPED' ? 'bg-secondary' :
                            order.status=='COMPLETED' ? 'bg-success' :
                            order.status=='CANCELLED' ? 'bg-danger' :
                            order.status=='REFUNDED' ? 'bg-dark' : 'bg-light'} fs-6">
                                        <c:choose>
                                            <c:when test="${order.status == 'PENDING'}">Chờ xử lý</c:when>
                                            <c:when test="${order.status == 'PAID'}">Đã thanh toán</c:when>
                                            <c:when test="${order.status == 'PROCESSING'}">Đang xử lý</c:when>
                                            <c:when test="${order.status == 'SHIPPED'}">Đã gửi hàng</c:when>
                                            <c:when test="${order.status == 'COMPLETED'}">Hoàn thành</c:when>
                                            <c:when test="${order.status == 'CANCELLED'}">Đã hủy</c:when>
                                            <c:when test="${order.status == 'REFUNDED'}">Đã hoàn tiền</c:when>
                                            <c:otherwise>${order.status}</c:otherwise>
                                        </c:choose>
                                    </span>
                                </div>
                                <div class="card-body">
                                    <div class="row">
                                        <div class="col-md-6">
                                            <h6 class="border-bottom pb-2">Thông tin đơn hàng</h6>
                                            <table class="table table-borderless">
                                                <tr>
                                                    <td class="text-muted">Mã đơn:</td>
                                                    <td>#${order.id}</td>
                                                </tr>
                                                <tr>
                                                    <td class="text-muted">Ngày tạo:</td>
                                                    <td>
                                                        <c:out value="${order.createdAt}" />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td class="text-muted">Trạng thái:</td>
                                                    <td>
                                                        <span class="badge
                                            ${order.status=='PENDING' ? 'bg-warning' :
                                            order.status=='PAID' ? 'bg-info' :
                                            order.status=='PROCESSING' ? 'bg-primary' :
                                            order.status=='SHIPPED' ? 'bg-secondary' :
                                            order.status=='COMPLETED' ? 'bg-success' :
                                            order.status=='CANCELLED' ? 'bg-danger' :
                                            order.status=='REFUNDED' ? 'bg-dark' : 'bg-light'}">
                                                            <c:choose>
                                                                <c:when test="${order.status == 'PENDING'}">Chờ xử lý
                                                                </c:when>
                                                                <c:when test="${order.status == 'PAID'}">Đã thanh toán
                                                                </c:when>
                                                                <c:when test="${order.status == 'PROCESSING'}">Đang xử
                                                                    lý</c:when>
                                                                <c:when test="${order.status == 'SHIPPED'}">Đã gửi hàng
                                                                </c:when>
                                                                <c:when test="${order.status == 'COMPLETED'}">Hoàn thành
                                                                </c:when>
                                                                <c:when test="${order.status == 'CANCELLED'}">Đã hủy
                                                                </c:when>
                                                                <c:when test="${order.status == 'REFUNDED'}">Đã hoàn
                                                                    tiền</c:when>
                                                                <c:otherwise>${order.status}</c:otherwise>
                                                            </c:choose>
                                                        </span>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td class="text-muted">Tổng tiền:</td>
                                                    <td>
                                                        <fmt:formatNumber value="${order.totalAmount}" type="currency"
                                                            currencySymbol="₫" maxFractionDigits="0" />
                                                    </td>
                                                </tr>
                                            </table>
                                        </div>
                                        <div class="col-md-6">
                                            <h6 class="border-bottom pb-2">Thông tin người mua/bán</h6>
                                            <table class="table table-borderless">
                                                <c:if test="${order.buyer != null}">
                                                    <tr>
                                                        <td class="text-muted">Người mua:</td>
                                                        <td>${order.buyer.fullName} (${order.buyer.username})</td>
                                                    </tr>
                                                    <tr>
                                                        <td class="text-muted">Email:</td>
                                                        <td>${order.buyer.email}</td>
                                                    </tr>
                                                </c:if>
                                                <c:if test="${order.sellerStore != null}">
                                                    <tr>
                                                        <td class="text-muted">Cửa hàng:</td>
                                                        <td>${order.sellerStore.storeName}</td>
                                                    </tr>
                                                </c:if>
                                            </table>
                                        </div>
                                        <div class="col-12 mt-4">
                                            <h6 class="border-bottom pb-2">Chi tiết sản phẩm</h6>
                                            <table class="table table-borderless">
                                                <tr>
                                                    <td class="text-muted">Sản phẩm:</td>
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
                                                    <td class="text-muted">Giá:</td>
                                                    <td>
                                                        <fmt:formatNumber value="${order.productPrice}" type="currency"
                                                            currencySymbol="₫" maxFractionDigits="0" />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td class="text-muted">Số lượng:</td>
                                                    <td>${order.quantity}</td>
                                                </tr>
                                                <tr>
                                                    <td class="text-muted">Kho sản phẩm:</td>
                                                    <td>
                                                        <c:out
                                                            value="${order.productStorage != null ? order.productStorage.id : '---'}" />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td class="text-muted">Dữ liệu sản phẩm:</td>
                                                    <td>
                                                        <c:out value="${order.productData}" />
                                                    </td>
                                                </tr>
                                            </table>
                                        </div>
                                    </div>
                                </div>
                                <div class="card-footer text-end">
                                    <a href="/orders" class="btn btn-secondary"><i class="bi bi-arrow-left"></i> Quay
                                        lại</a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
            </body>

            </html>