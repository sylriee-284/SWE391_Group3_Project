<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>

<!-- Create Product Content -->

<div class="row justify-content-center">
    <div class="col-lg-8">
        <div class="card">
            <div class="card-header">
                <h5 class="mb-0"><i class="fas fa-plus-circle"></i> Thêm Sản phẩm mới</h5>
            </div>
            <div class="card-body">
                <form:form method="post" action="/products/create" modelAttribute="createRequest">
                    <!-- Product Name -->
                    <div class="mb-3">
                        <label class="form-label">Tên sản phẩm <span class="text-danger">*</span></label>
                        <form:input path="productName" class="form-control" placeholder="Nhập tên sản phẩm" required="true" />
                        <form:errors path="productName" class="text-danger small" />
                    </div>

                    <!-- Description -->
                    <div class="mb-3">
                        <label class="form-label">Mô tả sản phẩm</label>
                        <form:textarea path="description" class="form-control" rows="5" placeholder="Nhập mô tả chi tiết về sản phẩm" />
                        <form:errors path="description" class="text-danger small" />
                    </div>

                    <!-- Price & Stock -->
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Giá (VND) <span class="text-danger">*</span></label>
                            <form:input path="price" type="number" class="form-control" placeholder="0" min="1000" step="1000" required="true" />
                            <form:errors path="price" class="text-danger small" />
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Số lượng <span class="text-danger">*</span></label>
                            <form:input path="stockQuantity" type="number" class="form-control" placeholder="0" min="0" required="true" />
                            <form:errors path="stockQuantity" class="text-danger small" />
                        </div>
                    </div>

                    <!-- Category & SKU -->
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Danh mục <span class="text-danger">*</span></label>
                            <form:select path="category" class="form-select" required="true">
                                <option value="">-- Chọn danh mục --</option>
                                <c:forEach items="${categories}" var="cat">
                                    <option value="${cat}">${cat.displayName}</option>
                                </c:forEach>
                            </form:select>
                            <form:errors path="category" class="text-danger small" />
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label">SKU</label>
                            <form:input path="sku" class="form-control" placeholder="Để trống để tự động tạo" />
                            <form:errors path="sku" class="text-danger small" />
                            <small class="text-muted">Mã định danh sản phẩm (tùy chọn)</small>
                        </div>
                    </div>

                    <!-- Active Status -->
                    <div class="mb-3">
                        <div class="form-check">
                            <form:checkbox path="isActive" class="form-check-input" id="isActive" />
                            <label class="form-check-label" for="isActive">
                                Kích hoạt sản phẩm ngay
                            </label>
                        </div>
                    </div>

                    <!-- Buttons -->
                    <div class="d-flex gap-2">
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-save"></i> Tạo sản phẩm
                        </button>
                        <a href="/products/my-products" class="btn btn-secondary">
                            <i class="fas fa-times"></i> Hủy
                        </a>
                    </div>
                </form:form>
            </div>
        </div>
    </div>
</div>
