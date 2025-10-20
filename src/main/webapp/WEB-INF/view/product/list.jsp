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
                        Tất cả sản phẩm - MMO Market System
                    </title>

                    <!-- Include common head with all CSS and JS -->
                    <jsp:include page="../common/head.jsp" />

                    <!-- Custom Product List CSS -->
                    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/productlist.css">
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
                                    <li class="breadcrumb-item active" aria-current="page">
                                        sản phẩm
                                    </li>
                                </ol>
                            </nav>

                            <!-- Filter Section -->
                            <div class="filter-section">
                                <form method="get" action="<c:url value='/products'/>" id="filterForm">
                                    <!-- Main Filters -->
                                    <div class="row filter-row">
                                        <!-- Sort Options with Radio Buttons -->
                                        <div class="col-md-12 mb-3">
                                            <div class="filter-label">Sắp xếp sản phẩm</div>
                                            <div class="d-flex flex-wrap gap-4">
                                                <div class="form-check">
                                                    <input class="form-check-input" type="radio" name="sort"
                                                        id="sortSoldQuantity" value="soldQuantity" <c:if
                                                        test="${sortBy == 'soldQuantity' || empty sortBy}">checked
                                                    </c:if>
                                                    onchange="this.form.submit()">
                                                    <label class="form-check-label" for="sortSoldQuantity">
                                                        Sản phẩm nổi bật
                                                    </label>
                                                </div>
                                                <div class="form-check">
                                                    <input class="form-check-input" type="radio" name="sort"
                                                        id="sortNew" value="createdAt" <c:if
                                                        test="${sortBy == 'createdAt'}">checked</c:if>
                                                    onchange="this.form.submit()">
                                                    <label class="form-check-label" for="sortNew">
                                                        Sản phẩm mới
                                                    </label>
                                                </div>
                                                <div class="form-check">
                                                    <input class="form-check-input" type="radio" name="sort"
                                                        id="sortRating" value="rating" <c:if
                                                        test="${sortBy == 'rating'}">checked</c:if>
                                                    onchange="this.form.submit()">
                                                    <label class="form-check-label" for="sortRating">
                                                        Sản phẩm có lượt đánh giá cao
                                                    </label>
                                                </div>
                                                <div class="form-check">
                                                    <input class="form-check-input" type="radio" name="sort"
                                                        id="sortPrice" value="price" <c:if
                                                        test="${sortBy == 'price'}">checked</c:if>
                                                    onchange="this.form.submit()">
                                                    <label class="form-check-label" for="sortPrice">
                                                        Giá từ thấp đến cao
                                                    </label>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Action Buttons Row -->
                                    <div class="row mt-2">
                                        <div class="col-md-12 d-flex justify-content-end">
                                            <button type="button" class="btn btn-outline-secondary"
                                                onclick="toggleFilterSection()">
                                                <span id="filterToggleText">THU GỌN</span>
                                                <i class="fas fa-chevron-up" id="filterToggleIcon"></i>
                                            </button>
                                        </div>
                                    </div>
                                </form>
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
                                                                    <span class="text-muted"> (${product.ratingCount}
                                                                        đánh giá)</span>
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
                                                <h4><i class="fas fa-info-circle"></i> Không tìm thấy sản phẩm</h4>
                                                <p>
                                                    Không có sản phẩm nào trong hệ thống.
                                                </p>
                                                <a href="<c:url value='/products'/>" class="btn btn-primary">Tải lại
                                                    trang</a>
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
                                                        <c:url var="firstUrl" value="/products">
                                                            <c:param name="page" value="0" />
                                                            <c:param name="size" value="${size}" />
                                                            <c:param name="sort" value="${sortBy}" />
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
                                                        <c:url var="prevUrl" value="/products">
                                                            <c:param name="page" value="${previousPage}" />
                                                            <c:param name="size" value="${size}" />
                                                            <c:param name="sort" value="${sortBy}" />
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
                                                        <c:url var="pageUrl" value="/products">
                                                            <c:param name="page" value="${pageNum}" />
                                                            <c:param name="size" value="${size}" />
                                                            <c:param name="sort" value="${sortBy}" />
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
                                                        <c:url var="nextUrl" value="/products">
                                                            <c:param name="page" value="${nextPage}" />
                                                            <c:param name="size" value="${size}" />
                                                            <c:param name="sort" value="${sortBy}" />
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
                                                        <c:url var="lastUrl" value="/products">
                                                            <c:param name="page" value="${totalPages - 1}" />
                                                            <c:param name="size" value="${size}" />
                                                            <c:param name="sort" value="${sortBy}" />
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