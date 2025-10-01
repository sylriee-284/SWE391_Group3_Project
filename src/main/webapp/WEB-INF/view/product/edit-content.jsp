<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!-- Edit Product Content -->

<div class="row justify-content-center">
    <div class="col-lg-8">
        <div class="card">
            <div class="card-header">
                <h5 class="mb-0"><i class="fas fa-edit"></i> Chỉnh sửa Sản phẩm</h5>
            </div>
            <div class="card-body">
                <form:form method="post" action="/products/${product.id}/edit" modelAttribute="updateRequest">
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
                                    <option value="${cat}" ${cat == updateRequest.category ? 'selected' : ''}>
                                        ${cat.displayName}
                                    </option>
                                </c:forEach>
                            </form:select>
                            <form:errors path="category" class="text-danger small" />
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label">SKU</label>
                            <form:input path="sku" class="form-control" readonly="true" />
                            <small class="text-muted">SKU không thể thay đổi</small>
                        </div>
                    </div>

                    <!-- Active Status -->
                    <div class="mb-3">
                        <div class="form-check">
                            <form:checkbox path="isActive" class="form-check-input" id="isActive" />
                            <label class="form-check-label" for="isActive">
                                Sản phẩm đang hoạt động
                            </label>
                        </div>
                    </div>

                    <!-- Current Images -->
                    <div class="mb-3">
                        <label class="form-label">Ảnh sản phẩm hiện tại</label>
                        <c:choose>
                            <c:when test="${not empty product.productImages}">
                                <div class="d-flex gap-2 flex-wrap mb-2">
                                    <c:forEach items="${fn:split(product.productImages, ',')}" var="image">
                                        <img src="${image}" alt="Product" style="width: 100px; height: 100px; object-fit: cover; border-radius: 5px;">
                                    </c:forEach>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <p class="text-muted">Chưa có ảnh</p>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <!-- Buttons -->
                    <div class="d-flex gap-2">
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-save"></i> Lưu thay đổi
                        </button>
                        <a href="/products/my-products" class="btn btn-secondary">
                            <i class="fas fa-times"></i> Hủy
                        </a>
                        <a href="/products/${product.id}" class="btn btn-info">
                            <i class="fas fa-eye"></i> Xem sản phẩm
                        </a>
                    </div>
                </form:form>

                <!-- Upload Images Form -->
                <hr class="my-4">
                <h5><i class="fas fa-image"></i> Upload ảnh sản phẩm</h5>
                <form method="post" action="/products/${product.id}/upload-images" enctype="multipart/form-data">
                    <div class="mb-3">
                        <input type="file" name="imageFiles" class="form-control" multiple accept="image/*">
                        <small class="text-muted">Chọn nhiều ảnh (tối đa 10MB/ảnh)</small>
                    </div>
                    <button type="submit" class="btn btn-success">
                        <i class="fas fa-upload"></i> Tải lên ảnh
                    </button>
                </form>
            </div>
        </div>
    </div>
</div>
