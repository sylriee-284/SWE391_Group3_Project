<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>

            <jsp:directive.include file="layout.jsp" />

            <div class="card">
                <div class="card-body">
                    <h4 class="mb-3">Thêm sản phẩm</h4>

                    <form:form modelAttribute="product" method="post" action="/seller/products" class="row g-3">

                        <div class="col-md-6">
                            <label class="form-label">Tên sản phẩm</label>
                            <form:input path="name" cssClass="form-control" />
                        </div>

                        <div class="col-md-3">
                            <label class="form-label">Giá</label>
                            <form:input path="price" type="number" step="0.01" min="0.01" cssClass="form-control" />
                        </div>

                        <div class="col-md-3">
                            <label class="form-label">Số lượng</label>
                            <form:input path="quantity" type="number" min="0" cssClass="form-control" />
                        </div>

                        <div class="col-md-4">
                            <label class="form-label">Loại</label>
                            <form:select path="type" cssClass="form-select">
                                <form:option value="ACCOUNT" label="Account có sẵn" />
                                <form:option value="KEY" label="Key/Code list" />
                                <form:option value="SERVICE" label="Dịch vụ thực hiện" />
                                <form:option value="FILE" label="File số tải về" />
                            </form:select>
                        </div>

                        <div class="col-md-4">
                            <label class="form-label">Trạng thái</label>
                            <form:select path="status" cssClass="form-select">
                                <form:option value="ACTIVE" label="ACTIVE" />
                                <form:option value="INACTIVE" label="INACTIVE" />
                            </form:select>
                        </div>

                        <div class="col-md-4">
                            <label class="form-label">Seller ID (tùy chọn)</label>
                            <form:input path="sellerId" type="number" min="1" cssClass="form-control" />
                        </div>

                        <div class="col-12">
                            <label class="form-label">Mô tả</label>
                            <form:textarea path="description" rows="4" cssClass="form-control" maxlength="2000" />
                        </div>

                        <div class="col-12 d-flex gap-2">
                            <button class="btn btn-primary" type="submit">Lưu</button>
                            <a class="btn btn-secondary" href="/seller/products">Về danh sách</a>
                        </div>
                    </form:form>
                </div>
            </div>