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
                        <c:if test="${not empty pageTitle}">${pageTitle} - </c:if>MMO Market System
                    </title>

                    <!-- Include common head with all CSS and JS -->
                    <jsp:include page="../common/head.jsp" />
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
                                    <li class="breadcrumb-item"><a href="<c:url value='/'/>"
                                            class="text-decoration-none">Trang chủ</a></li>
                                    <li class="breadcrumb-item active" aria-current="page">
                                        ${parentCategory.name}</li>
                                </ol>
                            </nav>

                            <!-- Category Header -->
                            <div class="row mb-4">
                                <div class="col-12">
                                    <div class="card border-success">
                                        <div class="card-body text-center">
                                            <div class="mb-3">
                                                <img src="<c:url value='/images/categories/${parentCategory.name.toLowerCase()}.png'/>"
                                                    alt="${parentCategory.name}" class="img-fluid"
                                                    style="width:80px;height:80px;">
                                            </div>
                                            <h2 class="card-title text-success">${parentCategory.name}</h2>
                                            <p class="card-text">${parentCategory.description}</p>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Filter and Search Section -->
                            <div class="filter-section">
                                <form method="get"
                                    action="<c:url value='/category/${parentCategory.name.toLowerCase()}'/>"
                                    id="filterForm">
                                    <!-- Row 1: Main Filters -->
                                    <div class="row filter-row">
                                        <!-- Search Box -->
                                        <div class="col-md-4 mb-3">
                                            <div class="filter-label">Tìm kiếm sản phẩm</div>
                                            <input type="text" class="form-control" id="keyword" name="keyword"
                                                value="${keyword}" placeholder="Nhập từ khóa...">
                                        </div>

                                        <!-- Category Filter -->
                                        <div class="col-md-3 mb-3">
                                            <div class="filter-label">Danh mục con</div>
                                            <select class="form-select" id="childCategory" name="childCategory">
                                                <option value="">Tất cả danh mục con</option>
                                                <c:forEach var="childCat" items="${childCategories}">
                                                    <option value="${childCat.id}" <c:if
                                                        test="${selectedChildCategory == childCat.id}">selected
                                                        </c:if>>
                                                        ${childCat.name}
                                                    </option>
                                                </c:forEach>
                                            </select>
                                        </div>

                                        <!-- Sort Options -->
                                        <div class="col-md-2 mb-3">
                                            <div class="filter-label">Sắp xếp theo</div>
                                            <select class="form-select" id="sort" name="sort">
                                                <option value="name" <c:if test="${sortBy == 'name'}">selected
                                                    </c:if>>Tên</option>
                                                <option value="price" <c:if test="${sortBy == 'price'}">selected
                                                    </c:if>>Giá</option>
                                                <option value="createdAt" <c:if test="${sortBy == 'createdAt'}">
                                                    selected</c:if>>Ngày tạo</option>
                                            </select>
                                        </div>

                                        <!-- Sort Direction -->
                                        <div class="col-md-2 mb-3">
                                            <div class="filter-label">Thứ tự</div>
                                            <select class="form-select" id="direction" name="direction">
                                                <option value="asc" <c:if test="${sortDirection == 'asc'}">
                                                    selected</c:if>>Tăng dần</option>
                                                <option value="desc" <c:if test="${sortDirection == 'desc'}">
                                                    selected</c:if>>Giảm dần</option>
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
                                                    test="${not empty keyword || selectedChildCategory != null || sortBy != 'name' || sortDirection != 'asc'}">
                                                    <span class="badge bg-secondary me-2">
                                                        <i class="fas fa-filter"></i> Đang lọc
                                                    </span>
                                                </c:if>
                                            </div>
                                            <div>
                                                <c:if test="${not empty keyword || selectedChildCategory != null}">
                                                    <a href="<c:url value='/category/${parentCategory.name.toLowerCase()}'/>"
                                                        class="btn btn-collapse me-2">
                                                        <i class="fas fa-times-circle"></i> BỎ LỌC
                                                    </a>
                                                </c:if>
                                                <button type="button" class="btn btn-outline-secondary"
                                                    onclick="toggleFilterSection()">
                                                    <span id="filterToggleText">THU GỌN</span> <i
                                                        class="fas fa-chevron-up" id="filterToggleIcon"></i>
                                                </button>
                                            </div>
                                        </div>
                                    </div>
                                </form>
                            </div>

                            <!-- Results Info -->
                            <div class="row mb-3">
                                <div class="col-12">
                                    <p class="text-muted">
                                        Hiển thị ${products.numberOfElements} trên tổng
                                        ${totalElements} sản
                                        phẩm
                                        <c:if test="${not empty keyword}">
                                            cho từ khóa "<strong>${keyword}</strong>"
                                        </c:if>
                                        <c:if test="${selectedChildCategory != null}">
                                            trong danh mục con đã chọn
                                        </c:if>
                                    </p>
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
                                                <h4><i class="fas fa-info-circle"></i> Không tìm thấy sản phẩm
                                                </h4>
                                                <p>
                                                    <c:choose>
                                                        <c:when test="${not empty keyword}">
                                                            Không có sản phẩm nào phù hợp với từ khóa
                                                            "<strong>${keyword}</strong>".
                                                        </c:when>
                                                        <c:otherwise>
                                                            Danh mục này hiện tại chưa có sản phẩm nào.
                                                        </c:otherwise>
                                                    </c:choose>
                                                </p>
                                                <a href="<c:url value='/category/${parentCategory.name.toLowerCase()}'/>"
                                                    class="btn btn-primary">Xem tất cả sản phẩm</a>
                                            </div>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>

                            <!-- Pagination -->
                            <c:if test="${totalPages > 1}">
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
                                                        <c:url var="firstUrl"
                                                            value="/category/${parentCategory.name.toLowerCase()}">
                                                            <c:param name="page" value="0" />
                                                            <c:param name="size" value="${size}" />
                                                            <c:param name="sort" value="${sortBy}" />
                                                            <c:param name="direction" value="${sortDirection}" />
                                                            <c:if test="${not empty keyword}">
                                                                <c:param name="keyword" value="${keyword}" />
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
                                                        <c:url var="prevUrl"
                                                            value="/category/${parentCategory.name.toLowerCase()}">
                                                            <c:param name="page" value="${previousPage}" />
                                                            <c:param name="size" value="${size}" />
                                                            <c:param name="sort" value="${sortBy}" />
                                                            <c:param name="direction" value="${sortDirection}" />
                                                            <c:if test="${not empty keyword}">
                                                                <c:param name="keyword" value="${keyword}" />
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
                                                        <c:url var="pageUrl"
                                                            value="/category/${parentCategory.name.toLowerCase()}">
                                                            <c:param name="page" value="${pageNum}" />
                                                            <c:param name="size" value="${size}" />
                                                            <c:param name="sort" value="${sortBy}" />
                                                            <c:param name="direction" value="${sortDirection}" />
                                                            <c:if test="${not empty keyword}">
                                                                <c:param name="keyword" value="${keyword}" />
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
                                                        <c:url var="nextUrl"
                                                            value="/category/${parentCategory.name.toLowerCase()}">
                                                            <c:param name="page" value="${nextPage}" />
                                                            <c:param name="size" value="${size}" />
                                                            <c:param name="sort" value="${sortBy}" />
                                                            <c:param name="direction" value="${sortDirection}" />
                                                            <c:if test="${not empty keyword}">
                                                                <c:param name="keyword" value="${keyword}" />
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
                                                        <c:url var="lastUrl"
                                                            value="/category/${parentCategory.name.toLowerCase()}">
                                                            <c:param name="page" value="${totalPages - 1}" />
                                                            <c:param name="size" value="${size}" />
                                                            <c:param name="sort" value="${sortBy}" />
                                                            <c:param name="direction" value="${sortDirection}" />
                                                            <c:if test="${not empty keyword}">
                                                                <c:param name="keyword" value="${keyword}" />
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
                    <!-- Page-specific JavaScript -->
                    <c:if test="${not empty pageJS}">
                        <c:forEach var="js" items="${pageJS}">
                            <script src="${pageContext.request.contextPath}${js}"></script>
                        </c:forEach>
                    </c:if>
                    <!-- Page-specific JavaScript -->
                    <c:if test="${not empty pageJS}">
                        <c:forEach var="js" items="${pageJS}">
                            <script src="${pageContext.request.contextPath}${js}"></script>
                        </c:forEach>
                    </c:if>

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

                        // Toggle sidebar function
                        function toggleSidebar() {
                            var sidebar = document.getElementById('sidebar');
                            var content = document.getElementById('content');
                            var overlay = document.getElementById('sidebarOverlay');

                            if (sidebar && content) {
                                sidebar.classList.toggle('active');
                                content.classList.toggle('shifted');
                            }

                            if (overlay) {
                                overlay.classList.toggle('active');
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