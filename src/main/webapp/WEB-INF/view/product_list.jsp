<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>

        <jsp:directive.include file="layout.jsp" />

        <div class="d-flex justify-content-between align-items-center mb-3">
            <h4>Danh sách sản phẩm</h4>
            <a class="btn btn-primary" href="/seller/products/new">+ Thêm sản phẩm</a>
        </div>

        <c:choose>
            <c:when test="${empty products}">
                <div class="alert alert-info">Chưa có sản phẩm nào. Nhấn “Thêm sản phẩm”.</div>
            </c:when>
            <c:otherwise>
                <div class="table-responsive">
                    <table class="table table-striped align-middle">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Tên</th>
                                <th>Loại</th>
                                <th>Giá</th>
                                <th>Số lượng</th>
                                <th>Trạng thái</th>
                                <th>Seller</th>
                                <th>Tạo lúc</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="p" items="${products}">
                                <tr>
                                    <td>${p.id}</td>
                                    <td>${p.name}</td>
                                    <td>${p.type}</td>
                                    <td>${p.price}</td>
                                    <td>${p.quantity}</td>
                                    <td>${p.status}</td>
                                    <td>
                                        <c:out value="${p.sellerId}" />
                                    </td>
                                    <td>
                                        <c:out value="${p.createdAt}" />
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </c:otherwise>
        </c:choose>