<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>

<!-- TEST MODE: Create Product Content -->

<div class="row justify-content-center">
    <div class="col-lg-8">
        <!-- TEST MODE Alert -->
        <div class="alert alert-warning alert-dismissible fade show" role="alert">
            <h5 class="alert-heading">
                <i class="fas fa-exclamation-triangle"></i> TEST MODE - Development Only
            </h5>
            <p class="mb-0">
                This form is for <strong>testing purposes only</strong>.
                Product will be created with <strong>hard-coded Store ID = 2</strong>.
            </p>
            <hr>
            <p class="mb-0 small">
                <i class="fas fa-info-circle"></i> The seller will be automatically assigned from Store ID 2's owner.
            </p>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>

        <div class="card">
            <div class="card-header bg-warning">
                <h5 class="mb-0">
                    <i class="fas fa-flask"></i> Test - Thêm Sản phẩm mới (Store ID = 2)
                </h5>
            </div>
            <div class="card-body">
                <form:form method="post" action="/products/create-test" modelAttribute="createRequest">
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
                            <form:checkbox path="isActive" class="form-check-input" id="isActive" checked="true" />
                            <label class="form-check-label" for="isActive">
                                Kích hoạt sản phẩm ngay
                            </label>
                        </div>
                    </div>

                    <!-- Test Info Box -->
                    <div class="alert alert-info mb-3">
                        <strong>Test Configuration:</strong>
                        <ul class="mb-0">
                            <li>Store ID: <code>2</code> (hard-coded)</li>
                            <li>Seller ID: <em>Auto-assigned from Store 2's owner</em></li>
                            <li>SKU: <em>Auto-generated if left blank</em></li>
                        </ul>
                    </div>

                    <!-- Buttons -->
                    <div class="d-flex gap-2">
                        <button type="submit" class="btn btn-warning">
                            <i class="fas fa-flask"></i> Tạo Test Product
                        </button>
                        <a href="/products" class="btn btn-secondary">
                            <i class="fas fa-times"></i> Hủy
                        </a>
                    </div>
                </form:form>
            </div>
        </div>
    </div>
</div>
