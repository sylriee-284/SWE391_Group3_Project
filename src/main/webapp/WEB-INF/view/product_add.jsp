<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
            <%@ include file="layout/header.jspf" %>

                <div class="card">
                    <div class="card-body">
                        <h4 class="mb-3">Thêm sản phẩm</h4>

                        <c:if test="${not empty errorMessage}">
                            <div class="alert alert-danger">${errorMessage}</div>
                        </c:if>

                        <form:form modelAttribute="product" method="post"
                            action="${pageContext.request.contextPath}/seller/products" class="row g-3">

                            <div class="col-md-6">
                                <label class="form-label">Tên sản phẩm</label>
                                <form:input path="name" cssClass="form-control" required="required" maxlength="200" />
                                <small class="text-muted">Bắt buộc, tối đa 200 ký tự</small>
                            </div>

                            <div class="col-md-3">
                                <label class="form-label">Giá</label>
                                <form:input path="price" type="number" step="0.01" min="0.01" cssClass="form-control"
                                    required="required" />
                            </div>

                            <div class="col-md-3">
                                <label class="form-label">Số lượng</label>
                                <form:input path="quantity" type="number" min="0" cssClass="form-control"
                                    required="required" />
                            </div>

                            <div class="col-md-4">
                                <label class="form-label">Loại</label>
                                <form:select path="type" cssClass="form-select" required="required">
                                    <form:option value="ACCOUNT" label="Account có sẵn" />
                                    <form:option value="KEY" label="Key/Code list" />
                                    <form:option value="SERVICE" label="Dịch vụ thực hiện" />
                                    <form:option value="FILE" label="File số tải về" />
                                </form:select>
                            </div>

                            <div class="col-md-4">
                                <label class="form-label">Trạng thái</label>
                                <form:select path="status" cssClass="form-select" required="required">
                                    <form:option value="ACTIVE" label="ACTIVE" />
                                    <form:option value="INACTIVE" label="INACTIVE" />
                                </form:select>
                            </div>

                            <div class="col-md-4">
                                <label class="form-label">Seller ID (tùy chọn)</label>
                                <form:input path="sellerId" type="number" min="1" cssClass="form-control" />
                                <small class="text-muted">Để trống nếu chưa có; nếu nhập, ID phải tồn tại trong
                                    <code>users</code>.</small>
                            </div>

                            <div class="col-12">
                                <label class="form-label">Mô tả</label>
                                <form:textarea path="description" rows="4" cssClass="form-control" maxlength="2000" />
                            </div>

                            <div class="col-12 d-flex gap-2">
                                <button class="btn btn-primary" type="submit">Lưu</button>
                                <a class="btn btn-secondary"
                                    href="${pageContext.request.contextPath}/seller/products">Về danh sách</a>
                            </div>
                        </form:form>
                    </div>
                </div>

                <%@ include file="layout/footer.jspf" %>