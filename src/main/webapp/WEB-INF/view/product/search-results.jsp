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

                            <!-- Search Section -->
                            <div class="container my-4">
                                <div class="row justify-content-center">
                                    <div class="col-md-8">
                                        <form method="get" action="<c:url value='/products/search'/>"
                                            class="d-flex align-items-center">
                                            <input type="text" class="form-control me-2 rounded-pill" id="keyword"
                                                name="keyword" value="${keyword}" placeholder="Tìm kiếm sản phẩm..."
                                                required style="height: 45px;">
                                            <button type="submit" class="btn btn-success rounded-pill px-4"
                                                style="height: 45px; white-space: nowrap;">
                                                <i class="fas fa-search"></i> Tìm kiếm
                                            </button>
                                        </form>
                                    </div>
                                </div>
                            </div>

                            <!-- Sort Filter Section -->
                            <div class="filter-section mb-4">
                                <div class="row align-items-center">
                                    <div class="col-md-2">
                                        <label class="filter-label mb-0">Sắp xếp theo:</label>
                                    </div>
                                    <div class="col-md-10">
                                        <form method="get" action="<c:url value='/products/search'/>" id="sortForm">
                                            <input type="hidden" name="keyword" value="${keyword}">
                                            <div class="d-flex flex-wrap gap-3">
                                                <div class="form-check">
                                                    <input class="form-check-input" type="radio" name="sort"
                                                        value="soldQuantity" id="sortPopular" ${empty originalSort ||
                                                        originalSort=='soldQuantity' ? 'checked' : '' }
                                                        onchange="document.getElementById('sortForm').submit();">
                                                    <label class="form-check-label" for="sortPopular">
                                                        <i class="fas fa-fire text-danger me-1"></i>Sản phẩm nổi bật
                                                    </label>
                                                </div>
                                                <div class="form-check">
                                                    <input class="form-check-input" type="radio" name="sort"
                                                        value="price" id="sortPriceAsc" ${originalSort=='price'
                                                        ? 'checked' : '' }
                                                        onchange="document.getElementById('sortForm').submit();">
                                                    <label class="form-check-label" for="sortPriceAsc">
                                                        <i class="fas fa-sort-amount-up text-success me-1"></i>Giá từ
                                                        thấp đến cao
                                                    </label>
                                                </div>
                                                <div class="form-check">
                                                    <input class="form-check-input" type="radio" name="sort"
                                                        value="priceDesc" id="sortPriceDesc" ${originalSort=='priceDesc'
                                                        ? 'checked' : '' }
                                                        onchange="document.getElementById('sortForm').submit();">
                                                    <label class="form-check-label" for="sortPriceDesc">
                                                        <i class="fas fa-sort-amount-down text-info me-1"></i>Giá từ cao
                                                        đến thấp
                                                    </label>
                                                </div>
                                            </div>
                                        </form>
                                    </div>
                                </div>
                            </div>

                            <!-- Products Grid -->
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
                                                                Kho: ${dynamicStockMap[product.id]}
                                                            </small>
                                                        </div>
                                                        <div
                                                            class="mt-2 d-flex justify-content-between align-items-center flex-nowrap">
                                                            <small
                                                                class="text-success d-inline-flex align-items-center text-truncate me-2"
                                                                style="max-width: 50%; white-space: nowrap;">
                                                                <i class="fas fa-tag me-1"></i>
                                                                <span
                                                                    class="text-truncate">${product.category.name}</span>
                                                            </small>
                                                            <small
                                                                class="text-muted d-inline-flex align-items-center text-truncate text-end"
                                                                style="max-width: 50%; white-space: nowrap;">
                                                                <i class="fas fa-store me-1"></i>
                                                                <a href="<c:url value='/store/${product.sellerStore.id}'/>"
                                                                    class="text-decoration-none text-muted text-truncate">
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
                                                                <br>
                                                                <span class="text-muted">
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
                                                            <c:if test="${not empty originalSort}">
                                                                <c:param name="sort" value="${originalSort}" />
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
                                                            <c:if test="${not empty originalSort}">
                                                                <c:param name="sort" value="${originalSort}" />
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
                                                            <c:if test="${not empty originalSort}">
                                                                <c:param name="sort" value="${originalSort}" />
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
                                                            <c:if test="${not empty originalSort}">
                                                                <c:param name="sort" value="${originalSort}" />
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
                                                            <c:if test="${not empty originalSort}">
                                                                <c:param name="sort" value="${originalSort}" />
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