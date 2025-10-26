<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
            <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

                <!DOCTYPE html>
                <html lang="en">

                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>
                        <c:choose>
                            <c:when test="${not empty keyword}">
                                Kết quả tìm kiếm: "${keyword}" - MMO Market System
                            </c:when>
                            <c:otherwise>
                                Kết quả tìm kiếm - MMO Market System
                            </c:otherwise>
                        </c:choose>
                    </title>

                    <!-- Include common head with all CSS and JS -->
                    <jsp:include page="../common/head.jsp" />

                    <!-- Custom Product List CSS -->
                    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/productlist.css">

                    <style>
                        .filter-section {
                            background-color: #f8f9fa;
                            border-radius: 10px;
                            padding: 20px;
                            margin-bottom: 20px;
                            border: 1px solid #e9ecef;
                        }

                        .filter-label {
                            font-weight: 600;
                            color: #495057;
                            margin-bottom: 8px;
                            font-size: 0.9rem;
                        }

                        .btn-collapse {
                            background-color: #6c757d;
                            border-color: #6c757d;
                            color: white;
                            font-size: 0.875rem;
                            padding: 0.375rem 0.75rem;
                        }

                        .btn-collapse:hover {
                            background-color: #5a6268;
                            border-color: #545b62;
                            color: white;
                        }

                        .badge.bg-secondary {
                            background-color: #6c757d !important;
                        }

                        .form-select:focus,
                        .form-control:focus {
                            border-color: #28a745;
                            box-shadow: 0 0 0 0.2rem rgba(40, 167, 69, 0.25);
                        }
                    </style>
                </head>

                <body>
                    <!-- Include Navbar -->
                    <jsp:include page="../common/navbar.jsp" />

                    <!-- Include Sidebar -->
                    <jsp:include page="../common/sidebar.jsp" />

                    <!-- Sidebar Overlay for Mobile -->
                    <div class="sidebar-overlay" id="sidebarOverlay" onclick="toggleSidebar()"></div>

                    <!-- Main Content Area -->
                    <div class="content" id="content">
                        <!-- Page Content will be inserted here -->
                        <div class="container-fluid">
                            <!-- Breadcrumb -->
                            <nav aria-label="breadcrumb">
                                <ol class="breadcrumb">
                                    <li class="breadcrumb-item">
                                        <a href="<c:url value='/'/>" class="text-decoration-none">Trang chủ</a>
                                    </li>
                                    <li class="breadcrumb-item">
                                        <a href="<c:url value='/products'/>" class="text-decoration-none">Sản phẩm</a>
                                    </li>
                                    <li class="breadcrumb-item active" aria-current="page">
                                        <c:choose>
                                            <c:when test="${not empty keyword}">
                                                Kết quả tìm kiếm: "${keyword}"
                                            </c:when>
                                            <c:otherwise>
                                                Kết quả tìm kiếm
                                            </c:otherwise>
                                        </c:choose>
                                    </li>
                                </ol>
                            </nav>

                            <!-- Search Results Header -->
                            <div class="mb-4">
                                <h1 class="h3 mb-2">
                                    <i class="fas fa-search text-primary me-2"></i>
                                    <c:choose>
                                        <c:when test="${not empty keyword}">
                                            Kết quả tìm kiếm cho: "<span class="text-primary">${keyword}</span>"
                                        </c:when>
                                        <c:otherwise>
                                            Kết quả tìm kiếm
                                        </c:otherwise>
                                    </c:choose>
                                </h1>
                                <c:if test="${totalElements > 0}">
                                    <p class="text-muted mb-0">
                                        Tìm thấy <strong>${totalElements}</strong> sản phẩm
                                        <c:if test="${not empty keyword}"> cho từ khóa "<strong>${keyword}</strong>"
                                        </c:if>
                                    </p>
                                </c:if>
                            </div>

                            <!-- Filter and Search Section -->
                            <div class="filter-section">
                                <form method="get" action="<c:url value='/products/search'/>" id="filterForm">
                                    <!-- Row 1: Main Filters -->
                                    <div class="row filter-row">
                                        <!-- Search Box -->
                                        <div class="col-md-3 mb-3">
                                            <div class="filter-label">Tìm kiếm sản phẩm</div>
                                            <input type="text" class="form-control" id="keyword" name="keyword"
                                                value="${keyword}" placeholder="Nhập từ khóa...">
                                        </div>

                                        <!-- Parent Category Filter -->
                                        <div class="col-md-2 mb-3">
                                            <div class="filter-label">Danh mục chính</div>
                                            <select class="form-select" id="parentCategory" name="parentCategory"
                                                onchange="loadChildCategories()">
                                                <option value="">Tất cả danh mục</option>
                                                <c:forEach var="parentCat" items="${parentCategories}">
                                                    <option value="${parentCat.id}" <c:if
                                                        test="${selectedParentCategory == parentCat.id}">selected</c:if>
                                                        >
                                                        ${parentCat.name}
                                                    </option>
                                                </c:forEach>
                                            </select>
                                        </div>

                                        <!-- Child Category Filter -->
                                        <div class="col-md-2 mb-3">
                                            <div class="filter-label">Danh mục con</div>
                                            <select class="form-select" id="childCategory" name="childCategory">
                                                <option value="">Tất cả danh mục con</option>
                                                <c:forEach var="childCat" items="${childCategories}">
                                                    <option value="${childCat.id}" <c:if
                                                        test="${selectedChildCategory == childCat.id}">selected</c:if>>
                                                        ${childCat.name}
                                                    </option>
                                                </c:forEach>
                                            </select>
                                        </div>

                                        <!-- Sort Options -->
                                        <div class="col-md-2 mb-3">
                                            <div class="filter-label">Sắp xếp theo</div>
                                            <select class="form-select" id="sort" name="sort">
                                                <option value="soldQuantity" <c:if
                                                    test="${sortBy == 'soldQuantity' || empty sortBy}">selected</c:if>
                                                    >Sản phẩm nổi bật</option>
                                                <option value="createdAt" <c:if test="${sortBy == 'createdAt'}">selected
                                                    </c:if>>Sản phẩm mới</option>
                                                <option value="rating" <c:if test="${sortBy == 'rating'}">selected
                                                    </c:if>>Đánh giá cao</option>
                                                <option value="price" <c:if test="${sortBy == 'price'}">selected</c:if>
                                                    >Giá</option>
                                            </select>
                                        </div>

                                        <!-- Sort Direction -->
                                        <div class="col-md-2 mb-3">
                                            <div class="filter-label">Thứ tự</div>
                                            <select class="form-select" id="direction" name="direction">
                                                <option value="desc" <c:if
                                                    test="${sortDirection == 'desc' || empty sortDirection}">selected
                                                    </c:if>>Giảm dần</option>
                                                <option value="asc" <c:if test="${sortDirection == 'asc'}">selected
                                                    </c:if>>Tăng dần</option>
                                            </select>
                                        </div>

                                        <!-- Filter Button -->
                                        <div class="col-md-1 mb-3 d-flex align-items-end">
                                            <button type="submit" class="btn btn-success w-100" title="Tìm kiếm">
                                                <i class="fas fa-search"></i>
                                            </button>
                                        </div>
                                    </div>

                                    <!-- Row 2: Action Buttons -->
                                    <div class="row mt-2">
                                        <div class="col-md-12 d-flex justify-content-between">
                                            <div>
                                                <c:if
                                                    test="${not empty keyword || selectedParentCategory != null || selectedChildCategory != null || sortBy != 'soldQuantity' || sortDirection != 'desc'}">
                                                    <span class="badge bg-secondary me-2">
                                                        <i class="fas fa-filter"></i> Đang lọc
                                                    </span>
                                                </c:if>
                                            </div>
                                            <div>
                                                <c:if
                                                    test="${not empty keyword || selectedParentCategory != null || selectedChildCategory != null}">
                                                    <a href="<c:url value='/products/search?keyword=${keyword}'/>"
                                                        class="btn btn-collapse me-2">
                                                        <i class="fas fa-times-circle"></i> BỎ LỌC
                                                    </a>
                                                </c:if>
                                                <button type="button" class="btn btn-outline-secondary"
                                                    onclick="toggleFilterSection()">
                                                    <span id="filterToggleText">THU GỌN</span>
                                                    <i class="fas fa-chevron-up" id="filterToggleIcon"></i>
                                                </button>
                                            </div>
                                        </div>
                                    </div>
                                </form>
                            </div> <!-- Products Grid -->
                            <div class="row">
                                <c:choose>
                                    <c:when test="${not empty products.content}">
                                        <c:forEach var="product" items="${products.content}">
                                            <div class="col-lg-3 col-md-4 col-sm-6 mb-4">
                                                <div class="card product-card border-0 shadow-sm">
                                                    <div class="card-body">
                                                        <div class="text-center mb-3">
                                                            <a href="<c:url value='/product/${product.slug}'/>"
                                                                class="text-decoration-none text-dark">
                                                                <img src="<c:url value='/images/products/${product.id}.png'/>"
                                                                    data-fallback-url="<c:out value='${product.productUrl}'/>"
                                                                    alt="${product.name}" class="product-image rounded"
                                                                    onerror="handleImgError(this)" />
                                                            </a>
                                                        </div>
                                                        <h6 class="card-title">
                                                            <a href="<c:url value='/product/${product.slug}'/>"
                                                                class="text-decoration-none text-dark">
                                                                ${product.name}
                                                            </a>
                                                        </h6>
                                                        <p class="card-text text-muted small">
                                                            <c:choose>
                                                                <c:when test="${product.description.length() > 80}">
                                                                    ${product.description.substring(0, 80)}...
                                                                </c:when>
                                                                <c:otherwise>
                                                                    ${product.description}
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </p>
                                                        <div class="d-flex justify-content-between align-items-center">
                                                            <span class="price">
                                                                <fmt:formatNumber value="${product.price}"
                                                                    type="currency" currencySymbol=""
                                                                    maxFractionDigits="0" />đ
                                                            </span>
                                                            <small class="text-muted">
                                                                Kho: ${product.stock}
                                                            </small>
                                                        </div>
                                                        <div
                                                            class="mt-2 d-flex justify-content-between align-items-center">
                                                            <small class="text-success">
                                                                <i class="fas fa-tag"></i>
                                                                ${product.category.name}
                                                            </small>
                                                            <small class="text-muted">
                                                                <a href="<c:url value='/store/${product.sellerStore.id}/infor'/>"
                                                                    class="text-decoration-none text-muted">
                                                                    <i class="fas fa-store"></i>
                                                                    ${product.sellerStore.storeName}
                                                                </a>
                                                            </small>
                                                        </div>
                                                        <div class="mt-2">
                                                            <div class="rating">
                                                                <c:forEach begin="1" end="5" var="star">
                                                                    <i class="fas fa-star ${star <= product.rating ? 'text-warning' : 'text-muted'}"
                                                                        style="font-size: 0.8em;"></i>
                                                                </c:forEach>
                                                                <small class="ms-1 text-muted">
                                                                    ${product.rating}/5
                                                                    <span class="text-muted"> Total review:
                                                                        ${product.ratingCount}</span>
                                                                </small>
                                                                <span class="ms-1 text-muted">
                                                                    Đã bán: ${product.soldQuantity != null ?
                                                                    product.soldQuantity : 0}
                                                                </span>
                                                            </div>
                                                        </div>
                                                        <div class="mt-3">
                                                            <a href="<c:url value='/product/${product.slug}'/>"
                                                                class="btn btn-success btn-sm w-100">
                                                                <i class="fas fa-eye"></i> Xem chi tiết
                                                            </a>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="col-12">
                                            <div class="alert alert-info text-center" role="alert">
                                                <h4><i class="fas fa-search"></i> Không tìm thấy sản phẩm nào</h4>
                                                <p>
                                                    <c:choose>
                                                        <c:when test="${not empty keyword}">
                                                            Không có sản phẩm nào khớp với từ khóa
                                                            "<strong>${keyword}</strong>".
                                                            <br>Hãy thử tìm kiếm với từ khóa khác hoặc kiểm tra lỗi
                                                            chính tả.
                                                        </c:when>
                                                        <c:otherwise>
                                                            Vui lòng nhập từ khóa để tìm kiếm sản phẩm.
                                                        </c:otherwise>
                                                    </c:choose>
                                                </p>
                                                <div class="mt-3">
                                                    <a href="<c:url value='/products'/>" class="btn btn-primary me-2">
                                                        <i class="fas fa-list"></i> Xem tất cả sản phẩm
                                                    </a>
                                                    <a href="<c:url value='/'/>" class="btn btn-outline-primary">
                                                        <i class="fas fa-home"></i> Về trang chủ
                                                    </a>
                                                </div>
                                            </div>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>

                            <!-- Pagination - Always show when there are products -->
                            <c:if test="${totalElements > 0}">
                                <div class="pagination-container">
                                    <nav>
                                        <ul class="pagination mb-0">
                                            <!-- First page -->
                                            <li class="page-item ${currentPage == 0 ? 'disabled' : ''}">
                                                <c:choose>
                                                    <c:when test="${currentPage == 0}">
                                                        <a class="page-link" href="#" aria-label="First">
                                                            <span aria-hidden="true">&laquo;&laquo;</span>
                                                        </a>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <c:url var="firstUrl" value="/products/search">
                                                            <c:param name="keyword" value="${keyword}" />
                                                            <c:param name="page" value="0" />
                                                            <c:param name="size" value="${size}" />
                                                            <c:param name="sort" value="${sortBy}" />
                                                            <c:param name="direction" value="${sortDirection}" />
                                                            <c:if test="${selectedParentCategory != null}">
                                                                <c:param name="parentCategory"
                                                                    value="${selectedParentCategory}" />
                                                            </c:if>
                                                            <c:if test="${selectedChildCategory != null}">
                                                                <c:param name="childCategory"
                                                                    value="${selectedChildCategory}" />
                                                            </c:if>
                                                        </c:url>
                                                        <a class="page-link" href="${firstUrl}" aria-label="First">
                                                            <span aria-hidden="true">&laquo;&laquo;</span>
                                                        </a>
                                                    </c:otherwise>
                                                </c:choose>
                                            </li>

                                            <!-- Previous page -->
                                            <li class="page-item ${!hasPrevious ? 'disabled' : ''}">
                                                <c:choose>
                                                    <c:when test="${!hasPrevious}">
                                                        <a class="page-link" href="#" aria-label="Previous">
                                                            <span aria-hidden="true">&laquo;</span>
                                                        </a>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <c:url var="prevUrl" value="/products/search">
                                                            <c:param name="keyword" value="${keyword}" />
                                                            <c:param name="page" value="${previousPage}" />
                                                            <c:param name="size" value="${size}" />
                                                            <c:param name="sort" value="${sortBy}" />
                                                            <c:param name="direction" value="${sortDirection}" />
                                                            <c:if test="${selectedParentCategory != null}">
                                                                <c:param name="parentCategory"
                                                                    value="${selectedParentCategory}" />
                                                            </c:if>
                                                            <c:if test="${selectedChildCategory != null}">
                                                                <c:param name="childCategory"
                                                                    value="${selectedChildCategory}" />
                                                            </c:if>
                                                        </c:url>
                                                        <a class="page-link" href="${prevUrl}" aria-label="Previous">
                                                            <span aria-hidden="true">&laquo;</span>
                                                        </a>
                                                    </c:otherwise>
                                                </c:choose>
                                            </li>

                                            <!-- Page numbers -->
                                            <c:forEach begin="0" end="${totalPages - 1}" var="pageNum">
                                                <c:choose>
                                                    <c:when
                                                        test="${pageNum < 5 || (pageNum >= currentPage - 2 && pageNum <= currentPage + 2) || pageNum >= totalPages - 1}">
                                                        <c:url var="pageUrl" value="/products/search">
                                                            <c:param name="keyword" value="${keyword}" />
                                                            <c:param name="page" value="${pageNum}" />
                                                            <c:param name="size" value="${size}" />
                                                            <c:param name="sort" value="${sortBy}" />
                                                            <c:param name="direction" value="${sortDirection}" />
                                                            <c:if test="${selectedParentCategory != null}">
                                                                <c:param name="parentCategory"
                                                                    value="${selectedParentCategory}" />
                                                            </c:if>
                                                            <c:if test="${selectedChildCategory != null}">
                                                                <c:param name="childCategory"
                                                                    value="${selectedChildCategory}" />
                                                            </c:if>
                                                        </c:url>
                                                        <li class="page-item ${pageNum == currentPage ? 'active' : ''}">
                                                            <a class="page-link" href="${pageUrl}">${pageNum + 1}</a>
                                                        </li>
                                                    </c:when>
                                                    <c:when test="${pageNum == 5 && currentPage > 7}">
                                                        <li class="page-item disabled">
                                                            <span class="page-link">...</span>
                                                        </li>
                                                    </c:when>
                                                    <c:when
                                                        test="${pageNum == totalPages - 2 && currentPage < totalPages - 8}">
                                                        <li class="page-item disabled">
                                                            <span class="page-link">...</span>
                                                        </li>
                                                    </c:when>
                                                </c:choose>
                                            </c:forEach>

                                            <!-- Next page -->
                                            <li class="page-item ${!hasNext ? 'disabled' : ''}">
                                                <c:choose>
                                                    <c:when test="${!hasNext}">
                                                        <a class="page-link" href="#" aria-label="Next">
                                                            <span aria-hidden="true">&raquo;</span>
                                                        </a>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <c:url var="nextUrl" value="/products/search">
                                                            <c:param name="keyword" value="${keyword}" />
                                                            <c:param name="page" value="${nextPage}" />
                                                            <c:param name="size" value="${size}" />
                                                            <c:param name="sort" value="${sortBy}" />
                                                            <c:param name="direction" value="${sortDirection}" />
                                                            <c:if test="${selectedParentCategory != null}">
                                                                <c:param name="parentCategory"
                                                                    value="${selectedParentCategory}" />
                                                            </c:if>
                                                            <c:if test="${selectedChildCategory != null}">
                                                                <c:param name="childCategory"
                                                                    value="${selectedChildCategory}" />
                                                            </c:if>
                                                        </c:url>
                                                        <a class="page-link" href="${nextUrl}" aria-label="Next">
                                                            <span aria-hidden="true">&raquo;</span>
                                                        </a>
                                                    </c:otherwise>
                                                </c:choose>
                                            </li>

                                            <!-- Last page -->
                                            <li class="page-item ${currentPage == totalPages - 1 ? 'disabled' : ''}">
                                                <c:choose>
                                                    <c:when test="${currentPage == totalPages - 1}">
                                                        <a class="page-link" href="#" aria-label="Last">
                                                            <span aria-hidden="true">&raquo;&raquo;</span>
                                                        </a>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <c:url var="lastUrl" value="/products/search">
                                                            <c:param name="keyword" value="${keyword}" />
                                                            <c:param name="page" value="${totalPages - 1}" />
                                                            <c:param name="size" value="${size}" />
                                                            <c:param name="sort" value="${sortBy}" />
                                                            <c:param name="direction" value="${sortDirection}" />
                                                            <c:if test="${selectedParentCategory != null}">
                                                                <c:param name="parentCategory"
                                                                    value="${selectedParentCategory}" />
                                                            </c:if>
                                                            <c:if test="${selectedChildCategory != null}">
                                                                <c:param name="childCategory"
                                                                    value="${selectedChildCategory}" />
                                                            </c:if>
                                                        </c:url>
                                                        <a class="page-link" href="${lastUrl}" aria-label="Last">
                                                            <span aria-hidden="true">&raquo;&raquo;</span>
                                                        </a>
                                                    </c:otherwise>
                                                </c:choose>
                                            </li>
                                        </ul>
                                    </nav>
                                </div>
                            </c:if>
                        </div>
                    </div>

                    <!-- Include Footer -->
                    <jsp:include page="../common/footer.jsp" />

                    <!-- Common JavaScript -->
                    <script>
                        // Image fallback: try .png, then productUrl, then placeholder
                        function handleImgError(img) {
                            try {
                                const src = img.getAttribute('src') || '';
                                const fallback = (img.dataset && img.dataset.fallbackUrl) ? img.dataset.fallbackUrl : '';
                                if (/\.jpg$/i.test(src)) {
                                    img.onerror = function () { handleImgError(img); };
                                    img.src = src.replace(/\.jpg$/i, '.png');
                                    return;
                                }
                                if (fallback && src !== fallback) {
                                    img.onerror = function () { setPlaceholder(img); };
                                    img.src = fallback;
                                    return;
                                }
                                setPlaceholder(img);
                            } catch (e) {
                                setPlaceholder(img);
                            }
                        }

                        function setPlaceholder(img) {
                            img.onerror = null;
                            img.src = '<c:url value="/images/others.png"/>';
                        }

                        // Toggle sidebar function
                        function toggleSidebar() {
                            var sidebar = document.getElementById('sidebar');
                            var content = document.getElementById('content');
                            var overlay = document.getElementById('sidebarOverlay');

                            if (sidebar && content) {
                                sidebar.classList.toggle('active');
                                content.classList.toggle('shifted');

                                if (overlay) {
                                    overlay.classList.toggle('active');
                                }
                            }
                        }

                        // Close sidebar when clicking outside on mobile
                        document.addEventListener('click', function (event) {
                            var sidebar = document.getElementById('sidebar');
                            var overlay = document.getElementById('sidebarOverlay');
                            var menuToggle = document.querySelector('.menu-toggle');

                            if (sidebar && sidebar.classList.contains('active') &&
                                !sidebar.contains(event.target) &&
                                !menuToggle.contains(event.target)) {
                                toggleSidebar();
                            }
                        });

                        // Toggle filter section
                        function toggleFilterSection() {
                            var filterSection = document.querySelector('.filter-section .filter-row');
                            var toggleText = document.getElementById('filterToggleText');
                            var toggleIcon = document.getElementById('filterToggleIcon');

                            if (filterSection.style.display === 'none') {
                                filterSection.style.display = 'flex';
                                toggleText.textContent = 'THU GỌN';
                                toggleIcon.classList.remove('fa-chevron-down');
                                toggleIcon.classList.add('fa-chevron-up');
                            } else {
                                filterSection.style.display = 'none';
                                toggleText.textContent = 'MỞ RỘNG';
                                toggleIcon.classList.remove('fa-chevron-up');
                                toggleIcon.classList.add('fa-chevron-down');
                            }
                        }

                        // Load child categories when parent category changes
                        function loadChildCategories() {
                            const parentCategoryId = document.getElementById('parentCategory').value;
                            const childCategorySelect = document.getElementById('childCategory');

                            // Clear current options except the first one
                            childCategorySelect.innerHTML = '<option value="">Tất cả danh mục con</option>';

                            if (parentCategoryId) {
                                // Make AJAX call to get child categories
                                const baseUrl = '<c:url value="/api/categories/" />';
                                fetch(baseUrl + parentCategoryId + '/children')
                                    .then(response => {
                                        if (!response.ok) {
                                            throw new Error('Network response was not ok');
                                        }
                                        return response.json();
                                    })
                                    .then(data => {
                                        data.forEach(category => {
                                            const option = document.createElement('option');
                                            option.value = category.id;
                                            option.textContent = category.name;
                                            childCategorySelect.appendChild(option);
                                        });
                                    })
                                    .catch(error => {
                                        console.error('Error loading child categories:', error);
                                        // Show a fallback message or keep empty
                                    });
                            }
                        }


                        // Auto-hide alerts after 5 seconds
                        document.addEventListener('DOMContentLoaded', function () {
                            var alerts = document.querySelectorAll('.alert');
                            alerts.forEach(function (alert) {
                                setTimeout(function () {
                                    alert.style.opacity = '0';
                                    setTimeout(function () {
                                        alert.remove();
                                    }, 300);
                                }, 5000);
                            });
                        });
                    </script>

                </body>

                </html>