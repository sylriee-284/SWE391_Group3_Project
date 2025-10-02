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

    /* Pagination Styles - Admin Design Rules */
    .pagination {
        margin: 0;
    }

    .pagination .page-link {
        color: #2c3e50;
        border: 1px solid #dee2e6;
        border-radius: 8px;
        margin: 0 3px;
        padding: 0.5rem 0.75rem;
        font-weight: 500;
        transition: all 0.3s ease;
    }

    .pagination .page-link:hover {
        background-color: #e9ecef;
        border-color: #3498db;
        color: #3498db;
    }

    .pagination .page-item.active .page-link {
        background-color: #3498db;
        border-color: #3498db;
        color: white;
        font-weight: 600;
    }

    .pagination .page-item.disabled .page-link {
        background-color: #f8f9fa;
        border-color: #dee2e6;
        color: #6c757d;
        cursor: not-allowed;
    }

    .pagination-info {
        color: #6c757d;
        font-size: 0.9rem;
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

        .pagination-info {
            font-size: 0.8rem;
        }

        .pagination .page-link {
            padding: 0.4rem 0.6rem;
            font-size: 0.875rem;
            margin: 0 2px;
        }
    }

    @media (max-width: 576px) {
        .pagination-container .d-flex {
            flex-direction: column;
            gap: 1rem;
            text-align: center;
        }

        .pagination {
            justify-content: center !important;
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
    <div class="card mb-4">
        <div class="card-header">
            <h5 class="mb-0"><i class="fas fa-filter me-2"></i>Bộ lọc tìm kiếm</h5>
        </div>
        <div class="card-body">
            <form method="get" action="/products" id="filterForm">
                <div class="row g-3">
                    <!-- Search -->
                    <div class="col-md-6">
                        <label class="form-label">Tìm kiếm</label>
                        <div class="input-group">
                            <span class="input-group-text"><i class="fas fa-search"></i></span>
                            <input type="text" class="form-control" name="search"
                                   placeholder="Tìm kiếm sản phẩm..." value="${search}">
                        </div>
                    </div>

                    <!-- Category -->
                    <div class="col-md-6">
                        <label class="form-label">Danh mục</label>
                        <select class="form-select" name="category">
                            <option value="">-- Tất cả danh mục --</option>
                            <c:forEach items="${categories}" var="cat">
                                <option value="${cat}" ${category == cat.name() ? 'selected' : ''}>
                                    ${cat.displayName}
                                </option>
                            </c:forEach>
                        </select>
                    </div>

                    <!-- Price Range -->
                    <div class="col-md-3">
                        <label class="form-label">Giá tối thiểu (VND)</label>
                        <input type="number" class="form-control" name="minPrice"
                               placeholder="0" value="${minPrice}" min="0" step="1000">
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Giá tối đa (VND)</label>
                        <input type="number" class="form-control" name="maxPrice"
                               placeholder="Không giới hạn" value="${maxPrice}" min="0" step="1000">
                    </div>

                    <!-- Stock Status -->
                    <div class="col-md-3">
                        <label class="form-label">Trạng thái kho</label>
                        <select class="form-select" name="stockStatus">
                            <option value="">-- Tất cả --</option>
                            <option value="IN_STOCK" ${stockStatus == 'IN_STOCK' ? 'selected' : ''}>Còn hàng</option>
                            <option value="LOW_STOCK" ${stockStatus == 'LOW_STOCK' ? 'selected' : ''}>Sắp hết hàng</option>
                            <option value="OUT_OF_STOCK" ${stockStatus == 'OUT_OF_STOCK' ? 'selected' : ''}>Hết hàng</option>
                        </select>
                    </div>

                    <!-- Sort -->
                    <div class="col-md-3">
                        <label class="form-label">Sắp xếp</label>
                        <select class="form-select" name="sortOption" id="sortOption">
                            <option value="createdAt_desc" ${sort == 'createdAt' && direction == 'desc' ? 'selected' : ''}>Mới nhất</option>
                            <option value="createdAt_asc" ${sort == 'createdAt' && direction == 'asc' ? 'selected' : ''}>Cũ nhất</option>
                            <option value="price_asc" ${sort == 'price' && direction == 'asc' ? 'selected' : ''}>Giá: Thấp → Cao</option>
                            <option value="price_desc" ${sort == 'price' && direction == 'desc' ? 'selected' : ''}>Giá: Cao → Thấp</option>
                            <option value="productName_asc" ${sort == 'productName' && direction == 'asc' ? 'selected' : ''}>Tên: A → Z</option>
                            <option value="productName_desc" ${sort == 'productName' && direction == 'desc' ? 'selected' : ''}>Tên: Z → A</option>
                            <option value="stockQuantity_desc" ${sort == 'stockQuantity' && direction == 'desc' ? 'selected' : ''}>Tồn kho: Cao → Thấp</option>
                        </select>
                        <!-- Hidden fields for sort and direction -->
                        <input type="hidden" name="sort" id="sortField" value="${sort}">
                        <input type="hidden" name="direction" id="sortDirection" value="${direction}">
                    </div>

                    <!-- Actions -->
                    <div class="col-md-6">
                        <label class="form-label d-block">&nbsp;</label>
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-filter"></i> Áp dụng bộ lọc
                        </button>
                        <a href="/products" class="btn btn-outline-secondary">
                            <i class="fas fa-times"></i> Xóa bộ lọc
                        </a>
                    </div>

                    <!-- Page Size -->
                    <div class="col-md-6">
                        <label class="form-label">Hiển thị</label>
                        <select class="form-select" name="size" onchange="this.form.submit()">
                            <option value="12" ${pageSize == 12 ? 'selected' : ''}>12 sản phẩm/trang</option>
                            <option value="24" ${pageSize == 24 ? 'selected' : ''}>24 sản phẩm/trang</option>
                            <option value="48" ${pageSize == 48 ? 'selected' : ''}>48 sản phẩm/trang</option>
                            <option value="96" ${pageSize == 96 ? 'selected' : ''}>96 sản phẩm/trang</option>
                        </select>
                    </div>
                </div>
            </form>
        </div>
    </div>

    <!-- Active Filters Display -->
    <c:if test="${not empty search or not empty category or not empty minPrice or not empty maxPrice or not empty stockStatus}">
        <div class="alert alert-info alert-dismissible fade show" role="alert">
            <strong><i class="fas fa-filter me-2"></i>Bộ lọc đang áp dụng:</strong>
            <div class="mt-2">
                <c:if test="${not empty search}">
                    <span class="badge bg-primary me-2">
                        Tìm kiếm: "${search}"
                        <a href="?category=${category}&minPrice=${minPrice}&maxPrice=${maxPrice}&stockStatus=${stockStatus}&sort=${sort}&direction=${direction}&size=${pageSize}"
                           class="text-white ms-1 text-decoration-none">✖</a>
                    </span>
                </c:if>
                <c:if test="${not empty category}">
                    <span class="badge bg-info me-2">
                        Danh mục: ${category}
                        <a href="?search=${search}&minPrice=${minPrice}&maxPrice=${maxPrice}&stockStatus=${stockStatus}&sort=${sort}&direction=${direction}&size=${pageSize}"
                           class="text-white ms-1 text-decoration-none">✖</a>
                    </span>
                </c:if>
                <c:if test="${not empty minPrice or not empty maxPrice}">
                    <span class="badge bg-success me-2">
                        Giá: <fmt:formatNumber value="${minPrice != null ? minPrice : 0}" type="number"/> - <fmt:formatNumber value="${maxPrice != null ? maxPrice : 999999999}" type="number"/> VND
                        <a href="?search=${search}&category=${category}&stockStatus=${stockStatus}&sort=${sort}&direction=${direction}&size=${pageSize}"
                           class="text-white ms-1 text-decoration-none">✖</a>
                    </span>
                </c:if>
                <c:if test="${not empty stockStatus}">
                    <span class="badge bg-warning text-dark me-2">
                        Kho: ${stockStatus == 'IN_STOCK' ? 'Còn hàng' : (stockStatus == 'LOW_STOCK' ? 'Sắp hết' : 'Hết hàng')}
                        <a href="?search=${search}&category=${category}&minPrice=${minPrice}&maxPrice=${maxPrice}&sort=${sort}&direction=${direction}&size=${pageSize}"
                           class="text-dark ms-1 text-decoration-none">✖</a>
                    </span>
                </c:if>
                <a href="/products" class="btn btn-sm btn-outline-danger ms-2">
                    <i class="fas fa-times-circle"></i> Xóa tất cả
                </a>
            </div>
        </div>
    </c:if>

    <script>
        // Handle sort option change
        document.getElementById('sortOption').addEventListener('change', function() {
            const value = this.value;
            const parts = value.split('_');
            document.getElementById('sortField').value = parts[0];
            document.getElementById('sortDirection').value = parts[1];
        });
    </script>

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
                                            ${currentPage * pageSize + status.index + 1}
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
                                            <c:if test="${not empty product.formattedCreatedAt}">
                                                ${product.formattedCreatedAt}
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
            <!-- Build query params string -->
            <c:set var="queryParams" value="size=${pageSize}&sort=${sort}&direction=${direction}" />
            <c:if test="${not empty search}">
                <c:set var="queryParams" value="${queryParams}&search=${search}" />
            </c:if>
            <c:if test="${not empty category}">
                <c:set var="queryParams" value="${queryParams}&category=${category}" />
            </c:if>
            <c:if test="${not empty minPrice}">
                <c:set var="queryParams" value="${queryParams}&minPrice=${minPrice}" />
            </c:if>
            <c:if test="${not empty maxPrice}">
                <c:set var="queryParams" value="${queryParams}&maxPrice=${maxPrice}" />
            </c:if>
            <c:if test="${not empty stockStatus}">
                <c:set var="queryParams" value="${queryParams}&stockStatus=${stockStatus}" />
            </c:if>
            <c:if test="${not empty storeId}">
                <c:set var="queryParams" value="${queryParams}&storeId=${storeId}" />
            </c:if>

            <div class="card mt-3 pagination-container">
                <div class="card-body">
                    <div class="d-flex justify-content-between align-items-center">
                        <!-- Left: Display info -->
                        <div class="pagination-info">
                            Hiển thị <strong>${currentPage * pageSize + 1}</strong> - <strong>${(currentPage + 1) * pageSize > totalElements ? totalElements : (currentPage + 1) * pageSize}</strong>
                            trong tổng số <strong>${totalElements}</strong> sản phẩm
                        </div>

                        <!-- Center: Pagination controls -->
                        <nav aria-label="Product pagination">
                            <ul class="pagination mb-0">
                                <!-- Previous -->
                                <li class="page-item ${currentPage == 0 ? 'disabled' : ''}">
                                    <a class="page-link" href="?page=${currentPage - 1}&${queryParams}">
                                        ‹ Trước
                                    </a>
                                </li>

                                <!-- Calculate page range -->
                                <c:set var="startPage" value="${currentPage - 2 < 0 ? 0 : currentPage - 2}" />
                                <c:set var="endPage" value="${currentPage + 2 >= totalPages ? totalPages - 1 : currentPage + 2}" />

                                <!-- Show first page if not in range -->
                                <c:if test="${startPage > 0}">
                                    <li class="page-item">
                                        <a class="page-link" href="?page=0&${queryParams}">1</a>
                                    </li>
                                    <c:if test="${startPage > 1}">
                                        <li class="page-item disabled">
                                            <span class="page-link">...</span>
                                        </li>
                                    </c:if>
                                </c:if>

                                <!-- Page numbers -->
                                <c:forEach begin="${startPage}" end="${endPage}" var="pageNum">
                                    <li class="page-item ${pageNum == currentPage ? 'active' : ''}">
                                        <a class="page-link" href="?page=${pageNum}&${queryParams}">
                                            ${pageNum + 1}
                                        </a>
                                    </li>
                                </c:forEach>

                                <!-- Show last page if not in range -->
                                <c:if test="${endPage < totalPages - 1}">
                                    <c:if test="${endPage < totalPages - 2}">
                                        <li class="page-item disabled">
                                            <span class="page-link">...</span>
                                        </li>
                                    </c:if>
                                    <li class="page-item">
                                        <a class="page-link" href="?page=${totalPages - 1}&${queryParams}">
                                            ${totalPages}
                                        </a>
                                    </li>
                                </c:if>

                                <!-- Next -->
                                <li class="page-item ${currentPage == totalPages - 1 ? 'disabled' : ''}">
                                    <a class="page-link" href="?page=${currentPage + 1}&${queryParams}">
                                        Sau ›
                                    </a>
                                </li>
                            </ul>
                        </nav>

                        <!-- Right: Current page info -->
                        <div class="pagination-info">
                            Trang <strong>${currentPage + 1}</strong> / <strong>${totalPages}</strong>
                        </div>
                    </div>
                </div>
            </div>
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
