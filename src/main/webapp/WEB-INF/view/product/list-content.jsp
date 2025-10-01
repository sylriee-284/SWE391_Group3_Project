<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!-- Product List Content (No HTML/HEAD/BODY wrapper) -->

<style>
    /* Table Styles - Admin Design Rules */
    .table {
        background-color: white;
        margin-bottom: 0;
    }

    .table th {
        background-color: #f8f9fa;
        border: none;
        font-weight: 600;
        color: #2c3e50;
        white-space: nowrap;
        padding: 1rem 0.75rem;
    }

    .table td {
        border: none;
        vertical-align: middle;
        padding: 0.75rem;
    }

    .table tbody tr {
        border-bottom: 1px solid #dee2e6;
        transition: background-color 0.2s ease;
    }

    .table tbody tr:hover {
        background-color: #f8f9fa;
    }

    .product-thumbnail {
        width: 50px;
        height: 50px;
        object-fit: cover;
        border-radius: 5px;
        border: 1px solid #dee2e6;
    }

    .product-thumbnail-placeholder {
        width: 50px;
        height: 50px;
        background-color: #f8f9fa;
        border-radius: 5px;
        border: 1px solid #dee2e6;
        display: flex;
        align-items: center;
        justify-content: center;
        color: #adb5bd;
    }

    .product-name-link {
        color: #2c3e50;
        text-decoration: none;
        font-weight: 500;
        transition: color 0.2s ease;
    }

    .product-name-link:hover {
        color: #3498db;
    }

    .store-link {
        color: #6c757d;
        text-decoration: none;
        font-size: 0.875rem;
        transition: color 0.2s ease;
    }

    .store-link:hover {
        color: #3498db;
    }

    .action-btn {
        padding: 0.375rem 0.5rem;
        font-size: 0.875rem;
        margin: 0 2px;
    }

    .table-card {
        border-radius: 10px;
        box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        border: none;
        overflow: hidden;
    }

    /* Responsive */
    @media (max-width: 1200px) {
        .hide-lg {
            display: none;
        }
    }

    @media (max-width: 768px) {
        .hide-md {
            display: none;
        }

        .table-responsive {
            overflow-x: auto;
        }
    }
</style>

<div class="container my-4">
    <!-- Page Header -->
    <div class="row mb-4">
        <div class="col">
            <h2><i class="fas fa-boxes"></i> Danh sách Sản phẩm</h2>
            <p class="text-muted">Khám phá các sản phẩm MMO chất lượng cao</p>
        </div>
    </div>

    <!-- Search & Filter Section -->
    <div class="search-filters">
        <form method="get" action="/products">
            <div class="row g-3">
                <div class="col-md-5">
                    <div class="input-group">
                        <span class="input-group-text"><i class="fas fa-search"></i></span>
                        <input type="text" class="form-control" name="search"
                               placeholder="Tìm kiếm sản phẩm..." value="${search}">
                    </div>
                </div>
                <div class="col-md-4">
                    <select class="form-select" name="category">
                        <option value="">-- Tất cả danh mục --</option>
                        <c:forEach items="${categories}" var="cat">
                            <option value="${cat}" ${category == cat ? 'selected' : ''}>
                                ${cat.displayName}
                            </option>
                        </c:forEach>
                    </select>
                </div>
                <div class="col-md-3">
                    <button type="submit" class="btn btn-primary w-100">
                        <i class="fas fa-filter"></i> Lọc
                    </button>
                </div>
            </div>
        </form>
    </div>

    <!-- Products Grid -->
    <c:choose>
        <c:when test="${empty products.content}">
            <div class="alert alert-info text-center">
                <i class="fas fa-info-circle fa-3x mb-3"></i>
                <h4>Không tìm thấy sản phẩm nào</h4>
                <p>Vui lòng thử tìm kiếm với từ khóa khác hoặc xem tất cả sản phẩm</p>
                <a href="/products" class="btn btn-primary">Xem tất cả sản phẩm</a>
            </div>
        </c:when>
        <c:otherwise>
            <!-- Result Info -->
            <div class="row mb-3">
                <div class="col">
                    <p class="text-muted">
                        Tìm thấy <strong>${totalElements}</strong> sản phẩm
                    </p>
                </div>
            </div>

            <!-- Products Table -->
            <div class="card table-card">
                <div class="card-header">
                    <h5 class="mb-0"><i class="fas fa-boxes me-2"></i>Danh sách Sản phẩm</h5>
                </div>
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover mb-0">
                            <thead>
                                <tr>
                                    <th style="width: 50px;">#</th>
                                    <th style="width: 70px;">Hình ảnh</th>
                                    <th>Tên sản phẩm</th>
                                    <th class="hide-lg" style="width: 120px;">SKU</th>
                                    <th style="width: 150px;">Danh mục</th>
                                    <th style="width: 150px;">Cửa hàng</th>
                                    <th style="width: 130px;">Giá</th>
                                    <th style="width: 100px;">Số lượng</th>
                                    <th style="width: 100px;">Trạng thái</th>
                                    <th class="hide-lg" style="width: 140px;">Ngày tạo</th>
                                    <th style="width: 150px;">Thao tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach items="${products.content}" var="product" varStatus="status">
                                    <tr>
                                        <!-- STT -->
                                        <td class="text-center">
                                            ${currentPage * 12 + status.index + 1}
                                        </td>

                                        <!-- Hình ảnh -->
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty product.productImages}">
                                                    <c:set var="firstImage" value="${fn:split(product.productImages, ',')[0]}" />
                                                    <img src="${firstImage}" class="product-thumbnail" alt="${product.productName}">
                                                </c:when>
                                                <c:otherwise>
                                                    <div class="product-thumbnail-placeholder">
                                                        <i class="fas fa-image"></i>
                                                    </div>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>

                                        <!-- Tên sản phẩm -->
                                        <td>
                                            <a href="/products/${product.id}" class="product-name-link">
                                                ${product.productName}
                                            </a>
                                        </td>

                                        <!-- SKU -->
                                        <td class="hide-lg">
                                            <span class="text-muted">${product.sku != null ? product.sku : '-'}</span>
                                        </td>

                                        <!-- Danh mục -->
                                        <td>
                                            <span class="badge bg-info">
                                                ${product.categoryDisplayName}
                                            </span>
                                        </td>

                                        <!-- Cửa hàng -->
                                        <td>
                                            <a href="/stores/${product.storeId}" class="store-link">
                                                <i class="fas fa-store me-1"></i>${product.storeName}
                                            </a>
                                        </td>

                                        <!-- Giá -->
                                        <td>
                                            <strong class="text-danger">${product.formattedPrice}</strong>
                                        </td>

                                        <!-- Số lượng -->
                                        <td>
                                            <c:choose>
                                                <c:when test="${product.stockQuantity == 0}">
                                                    <span class="badge bg-danger">Hết hàng</span>
                                                </c:when>
                                                <c:when test="${product.stockQuantity <= 5}">
                                                    <span class="badge bg-warning text-dark">Còn ${product.stockQuantity}</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-success">Còn ${product.stockQuantity}</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>

                                        <!-- Trạng thái -->
                                        <td>
                                            <c:choose>
                                                <c:when test="${product.isActive}">
                                                    <span class="badge bg-success">Active</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-secondary">Inactive</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>

                                        <!-- Ngày tạo -->
                                        <td class="hide-lg">
                                            <c:if test="${not empty product.createdAt}">
                                                <fmt:formatDate value="${product.createdAt}" pattern="dd/MM/yyyy HH:mm" />
                                            </c:if>
                                        </td>

                                        <!-- Thao tác -->
                                        <td>
                                            <a href="/products/${product.id}" class="btn btn-sm btn-primary action-btn" title="Xem chi tiết">
                                                <i class="fas fa-eye"></i>
                                            </a>
                                            <c:if test="${not empty sessionScope.currentUser and (sessionScope.currentUser.role == 'ADMIN' or product.sellerId == sessionScope.currentUser.id)}">
                                                <a href="/products/${product.id}/edit" class="btn btn-sm btn-warning action-btn" title="Chỉnh sửa">
                                                    <i class="fas fa-edit"></i>
                                                </a>
                                                <button class="btn btn-sm btn-danger action-btn"
                                                        onclick="confirmDelete(${product.id}, '${product.productName}')"
                                                        title="Xóa">
                                                    <i class="fas fa-trash"></i>
                                                </button>
                                            </c:if>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- Pagination -->
            <c:if test="${totalPages > 1}">
                <nav aria-label="Product pagination" class="mt-4">
                    <ul class="pagination justify-content-center">
                        <!-- Previous -->
                        <li class="page-item ${currentPage == 0 ? 'disabled' : ''}">
                            <a class="page-link" href="?page=${currentPage - 1}&size=12&search=${search}&category=${category}">
                                Trước
                            </a>
                        </li>

                        <!-- Page Numbers -->
                        <c:forEach begin="0" end="${totalPages - 1}" var="i">
                            <c:if test="${i >= currentPage - 2 && i <= currentPage + 2}">
                                <li class="page-item ${currentPage == i ? 'active' : ''}">
                                    <a class="page-link" href="?page=${i}&size=12&search=${search}&category=${category}">
                                        ${i + 1}
                                    </a>
                                </li>
                            </c:if>
                        </c:forEach>

                        <!-- Next -->
                        <li class="page-item ${currentPage == totalPages - 1 ? 'disabled' : ''}">
                            <a class="page-link" href="?page=${currentPage + 1}&size=12&search=${search}&category=${category}">
                                Sau
                            </a>
                        </li>
                    </ul>
                </nav>
            </c:if>
        </c:otherwise>
    </c:choose>
</div>

<script>
    function confirmDelete(productId, productName) {
        if (confirm('Bạn có chắc chắn muốn xóa sản phẩm "' + productName + '"?\n\nHành động này không thể hoàn tác.')) {
            // Create form to submit DELETE request
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = '/products/' + productId + '/delete';

            // Add CSRF token if needed
            const csrfInput = document.createElement('input');
            csrfInput.type = 'hidden';
            csrfInput.name = '_method';
            csrfInput.value = 'DELETE';
            form.appendChild(csrfInput);

            document.body.appendChild(form);
            form.submit();
        }
    }
</script>
