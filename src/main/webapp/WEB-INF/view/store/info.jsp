<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
            <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
                <!DOCTYPE html>
                <html lang="vi">

                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <jsp:include page="../common/head.jsp" />
                    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/store.css">
                    <title>${store.storeName} - Cửa hàng</title>
                </head>

                <body>
                    <jsp:include page="../common/navbar.jsp" />
                    <jsp:include page="../common/sidebar.jsp" />

                    <!-- Sidebar Overlay for Mobile -->
                    <div class="sidebar-overlay" id="sidebarOverlay" onclick="toggleSidebar()" role="button"
                        tabindex="0" onKeyPress="if(event.key === 'Enter') toggleSidebar()"></div>

                    <div class="content" id="content">
                        <div class="container-fluid mt-3">

                            <!-- ===== 1) HEADER SHOP ===== -->
                            <div class="store-header mb-4">
                                <div class="row">
                                    <div class="col-md-8">
                                        <div class="store-info-card">
                                            <h1 class="store-name">${store.storeName}</h1>
                                            <p class="store-description text-muted">${store.description}</p>
                                            <div class="store-meta">
                                                <span
                                                    class="badge badge-status badge-${fn:toLowerCase(store.status)}">${store.status}</span>
                                                <span class="meta-divider">|</span>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-4 text-md-right">
                                        <a href="/chat?sellerId=${store.owner.id}" class="btn btn-primary btn-chat">
                                            <i class="fas fa-comment-dots"></i> Chat ngay
                                        </a>
                                    </div>
                                </div>

                                <!-- KPI Cards -->
                                <div class="row mt-3">
                                    <div class="col-6 col-md-3 mb-3">
                                        <div class="kpi-card">
                                            <div class="kpi-icon">
                                                <i class="fas fa-box"></i>
                                            </div>
                                            <div class="kpi-content">
                                                <h3 class="kpi-value">${totalActiveProducts}</h3>
                                                <p class="kpi-label">Sản phẩm</p>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-6 col-md-3 mb-3">
                                        <div class="kpi-card">
                                            <div class="kpi-icon">
                                                <i class="fas fa-shopping-cart"></i>
                                            </div>
                                            <div class="kpi-content">
                                                <h3 class="kpi-value">${totalSold}</h3>
                                                <p class="kpi-label">Đã bán</p>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-6 col-md-3 mb-3">
                                        <div class="kpi-card">
                                            <div class="kpi-icon">
                                                <i class="fas fa-warehouse"></i>
                                            </div>
                                            <div class="kpi-content">
                                                <h3 class="kpi-value">${totalAvailable}</h3>
                                                <p class="kpi-label">Tồn kho</p>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-6 col-md-3 mb-3">
                                        <div class="kpi-card">
                                            <div class="kpi-icon">
                                                <i class="fas fa-coins"></i>
                                            </div>
                                            <div class="kpi-content">
                                                <p class="kpi-value kpi-value-small">
                                                    <fmt:formatNumber value="${minPrice}" type="number"
                                                        maxFractionDigits="0" />đ -
                                                    <fmt:formatNumber value="${maxPrice}" type="number"
                                                        maxFractionDigits="0" />đ
                                                </p>
                                                <p class="kpi-label">Khoảng giá</p>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- ===== 2) THANH CÔNG CỤ (Search + Filter + Sort) - 2 HÀNG ===== -->
                            <div class="filter-toolbar mb-4">
                                <form method="get" action="/store/${store.id}" id="filterForm">
                                    <!-- Hàng 1: Search, Parent Category, Sub Category, Sort, Button -->
                                    <div class="row g-2 align-items-center mb-2">
                                        <!-- Search -->
                                        <div class="col-md-3">
                                            <div class="input-group input-group-sm">
                                                <span class="input-group-text"><i class="fas fa-search"></i></span>
                                                <input type="text" name="q" class="form-control"
                                                    placeholder="Tìm kiếm..." value="${filterQ}" />
                                            </div>
                                        </div>

                                        <!-- Parent Category -->
                                        <div class="col-md-2">
                                            <select name="parentCategoryId" id="parentCategorySelect"
                                                class="form-select form-select-sm">
                                                <option value="">Danh mục</option>
                                                <c:forEach var="parent" items="${parentCategories}">
                                                    <option value="${parent.id}" ${filterParentCategoryId==parent.id
                                                        ? 'selected' : '' }>
                                                        ${parent.name}
                                                    </option>
                                                </c:forEach>
                                            </select>
                                        </div>

                                        <!-- Sub Category -->
                                        <div class="col-md-3">
                                            <select name="categoryId" id="subCategorySelect"
                                                class="form-select form-select-sm">
                                                <option value="">Tùy chọn danh mục</option>
                                                <!-- Subcategories will be loaded dynamically by JavaScript -->
                                            </select>
                                        </div>

                                        <!-- Sort -->
                                        <div class="col-md-3">
                                            <select name="sort" class="form-select form-select-sm">
                                                <option value="newest" ${currentSort=='newest' ? 'selected' : '' }>Mới
                                                    nhất</option>
                                                <option value="best_seller" ${currentSort=='best_seller' ? 'selected'
                                                    : '' }>Bán chạy</option>
                                                <option value="price_asc" ${currentSort=='price_asc' ? 'selected' : ''
                                                    }>Giá tăng</option>
                                                <option value="price_desc" ${currentSort=='price_desc' ? 'selected' : ''
                                                    }>Giá giảm</option>
                                                <option value="rating_desc" ${currentSort=='rating_desc' ? 'selected'
                                                    : '' }>Đánh giá</option>
                                            </select>
                                        </div>

                                        <!-- Search Button -->
                                        <div class="col-md-1">
                                            <button type="submit" class="btn btn-sm btn-outline-primary w-100">
                                                <i class="fas fa-search"></i>
                                            </button>
                                        </div>
                                    </div>

                                    <!-- Hàng 2: Price Range & Rating Filter -->
                                    <div class="row g-2 align-items-center">
                                        <!-- Price Min -->
                                        <div class="col-md-2">
                                            <input type="number" name="priceMin" class="form-control form-control-sm"
                                                placeholder="Giá từ" value="${filterPriceMin}" />
                                        </div>
                                        <!-- Price Max -->
                                        <div class="col-md-2">
                                            <input type="number" name="priceMax" class="form-control form-control-sm"
                                                placeholder="Giá đến" value="${filterPriceMax}" />
                                        </div>

                                        <!-- Rating Filter -->
                                        <div class="col-md-2">
                                            <select name="ratingGte" class="form-select form-select-sm">
                                                <option value="">Đánh giá sản phẩm</option>
                                                <option value="4.5" ${filterRatingGte=='4.5' ? 'selected' : '' }>≥ 4.5
                                                </option>
                                                <option value="4.0" ${filterRatingGte=='4.0' ? 'selected' : '' }>≥ 4.0
                                                </option>
                                                <option value="3.5" ${filterRatingGte=='3.5' ? 'selected' : '' }>≥ 3.5
                                                </option>
                                            </select>
                                        </div>

                                        <!-- Reset Button -->
                                        <div class="col-md-2">
                                            <a href="/store/${store.id}" class="btn btn-sm btn-outline-secondary w-100">
                                                <i class="fas fa-redo"></i> Đặt lại
                                            </a>
                                        </div>
                                    </div>
                                </form>
                            </div>

                            <script>
                                // Dynamic subcategory loading
                                const parentSelect = document.getElementById('parentCategorySelect');
                                const subSelect = document.getElementById('subCategorySelect');
                                const currentParentId = '${filterParentCategoryId}';
                                const currentSubId = '${filterCategoryId}';

                                // Function to load subcategories
                                function loadSubcategories(parentId, selectedSubId) {
                                    // Clear subcategories
                                    subSelect.innerHTML = '<option value="">Tùy chọn danh mục</option>';

                                    if (!parentId) return;

                                    // Fetch subcategories
                                    fetch('/seller/products/categories?parentId=' + parentId)
                                        .then(res => res.json())
                                        .then(data => {
                                            data.forEach(cat => {
                                                const opt = document.createElement('option');
                                                opt.value = cat.id;
                                                opt.textContent = cat.name;
                                                // Set selected if matches current selection
                                                if (selectedSubId && cat.id == selectedSubId) {
                                                    opt.selected = true;
                                                }
                                                subSelect.appendChild(opt);
                                            });
                                        })
                                        .catch(err => console.error('Error loading subcategories:', err));
                                }

                                // Load subcategories on parent change
                                parentSelect.addEventListener('change', function () {
                                    loadSubcategories(this.value, null);
                                });

                                // Load subcategories on page load if parent is already selected
                                if (currentParentId) {
                                    loadSubcategories(currentParentId, currentSubId);
                                }
                            </script>

                            <!-- ===== 3) KHU TRANG TRÍ (Collections) ===== -->
                            <c:if test="${not empty newestProducts or not empty bestSellers}">
                                <div class="collections-section mb-4">
                                    <ul class="nav nav-pills mb-3" id="collectionTabs" role="tablist">
                                        <li class="nav-item" role="presentation">
                                            <button class="nav-link active" id="newest-tab" data-bs-toggle="pill"
                                                data-bs-target="#newest" type="button" role="tab">
                                                <i class="fas fa-sparkles"></i> Mới về
                                            </button>
                                        </li>
                                        <li class="nav-item" role="presentation">
                                            <button class="nav-link" id="bestseller-tab" data-bs-toggle="pill"
                                                data-bs-target="#bestseller" type="button" role="tab">
                                                <i class="fas fa-fire"></i> Bán chạy
                                            </button>
                                        </li>
                                    </ul>

                                    <div class="tab-content" id="collectionTabContent">
                                        <!-- Newest Products -->
                                        <div class="tab-pane fade show active" id="newest" role="tabpanel">
                                            <div class="row">
                                                <c:forEach var="p" items="${newestProducts}">
                                                    <div class="col-6 col-md-3 col-lg-2 mb-3">
                                                        <div class="product-card-mini">
                                                            <a href="/product/${p.slug}">
                                                                <img src="<c:url value='/images/products/${p.id}.png'/>"
                                                                    data-fallback-url="${p.productUrl}"
                                                                    onerror="handleThumbError(this)" alt="${p.name}"
                                                                    class="product-img" />
                                                                <h6 class="product-name">${p.name}</h6>
                                                                <p class="product-price">
                                                                    <fmt:formatNumber value="${p.price}" type="currency"
                                                                        currencySymbol="" maxFractionDigits="0" />đ
                                                                </p>
                                                            </a>
                                                        </div>
                                                    </div>
                                                </c:forEach>
                                            </div>
                                        </div>

                                        <!-- Best Sellers -->
                                        <div class="tab-pane fade" id="bestseller" role="tabpanel">
                                            <div class="row">
                                                <c:forEach var="p" items="${bestSellers}">
                                                    <div class="col-6 col-md-3 col-lg-2 mb-3">
                                                        <div class="product-card-mini">
                                                            <a href="/product/${p.slug}">
                                                                <img src="<c:url value='/images/products/${p.id}.png'/>"
                                                                    data-fallback-url="${p.productUrl}"
                                                                    onerror="handleThumbError(this)" alt="${p.name}"
                                                                    class="product-img" />
                                                                <h6 class="product-name">${p.name}</h6>
                                                                <p class="product-price">
                                                                    <fmt:formatNumber value="${p.price}" type="currency"
                                                                        currencySymbol="" maxFractionDigits="0" />đ
                                                                </p>
                                                                <span class="badge badge-bestseller">
                                                                    <i class="fas fa-fire"></i> Đã bán ${p.soldQuantity}
                                                                </span>
                                                            </a>
                                                        </div>
                                                    </div>
                                                </c:forEach>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </c:if>

                            <!-- ===== 4) LƯỚI SẢN PHẨM SHOP ===== -->
                            <div class="products-section mb-4">
                                <h5 class="section-title mb-3">
                                    <i class="fas fa-box-open"></i> Sản phẩm của shop
                                </h5>

                                <c:if test="${not empty productsPage.content}">
                                    <div class="row">
                                        <c:forEach var="p" items="${productsPage.content}">
                                            <div class="col-6 col-md-4 col-lg-3 mb-3">
                                                <div class="card h-100 product-card">
                                                    <a href="/product/${p.slug}" class="text-decoration-none">
                                                        <div class="p-2">
                                                            <img src="<c:url value='/images/products/${p.id}.png'/>"
                                                                data-fallback-url="${p.productUrl}"
                                                                onerror="handleThumbError(this)" loading="lazy"
                                                                alt="${p.name}" class="img-fluid rounded mb-2"
                                                                style="width:100%;height:140px;object-fit:cover;" />
                                                            <h6 class="card-title mb-1 text-dark small">${p.name}</h6>
                                                            <p class="text-success fw-bold mb-1">
                                                                <fmt:formatNumber value="${p.price}" type="currency"
                                                                    currencySymbol="" maxFractionDigits="0" />đ
                                                            </p>
                                                            <div
                                                                class="d-flex justify-content-between align-items-center">
                                                                <small class="text-muted">Kho: ${p.stock}</small>
                                                                <small class="text-muted">
                                                                    <i class="fas fa-star text-warning"></i> ${p.rating
                                                                    != null ? p.rating : 0}
                                                                </small>
                                                            </div>
                                                        </div>
                                                    </a>
                                                </div>
                                            </div>
                                        </c:forEach>
                                    </div>

                                    <!-- Pagination cho sản phẩm shop -->
                                    <c:if test="${productsPage.totalPages > 1}">
                                        <nav aria-label="Products pagination">
                                            <ul class="pagination justify-content-center">
                                                <!-- Previous Button -->
                                                <c:if test="${productsPage.number > 0}">
                                                    <li class="page-item">
                                                        <a class="page-link"
                                                            href="?page=${productsPage.number - 1}&q=${filterQ}&categoryId=${filterCategoryId}&priceMin=${filterPriceMin}&priceMax=${filterPriceMax}&sort=${currentSort}"
                                                            aria-label="Previous">
                                                            <i class="fas fa-chevron-left"></i>
                                                        </a>
                                                    </li>
                                                </c:if>

                                                <!-- First Page -->
                                                <c:if test="${productsPage.number > 2}">
                                                    <li class="page-item">
                                                        <a class="page-link"
                                                            href="?page=0&q=${filterQ}&categoryId=${filterCategoryId}&priceMin=${filterPriceMin}&priceMax=${filterPriceMax}&sort=${currentSort}">
                                                            1
                                                        </a>
                                                    </li>
                                                    <li class="page-item disabled">
                                                        <span class="page-link">...</span>
                                                    </li>
                                                </c:if>

                                                <!-- Page Numbers (show current page +/- 2) -->
                                                <c:forEach var="i" begin="0" end="${productsPage.totalPages - 1}">
                                                    <c:if
                                                        test="${i == 0 || i == productsPage.totalPages - 1 || (i >= productsPage.number - 1 && i <= productsPage.number + 1)}">
                                                        <c:if
                                                            test="${!(i == 0 && productsPage.number > 2) && !(i == productsPage.totalPages - 1 && productsPage.number < productsPage.totalPages - 3)}">
                                                            <li
                                                                class="page-item ${i == productsPage.number ? 'active' : ''}">
                                                                <a class="page-link"
                                                                    href="?page=${i}&q=${filterQ}&categoryId=${filterCategoryId}&priceMin=${filterPriceMin}&priceMax=${filterPriceMax}&sort=${currentSort}">
                                                                    ${i+1}
                                                                </a>
                                                            </li>
                                                        </c:if>
                                                    </c:if>
                                                </c:forEach>

                                                <!-- Last Page -->
                                                <c:if test="${productsPage.number < productsPage.totalPages - 3}">
                                                    <li class="page-item disabled">
                                                        <span class="page-link">...</span>
                                                    </li>
                                                    <li class="page-item">
                                                        <a class="page-link"
                                                            href="?page=${productsPage.totalPages - 1}&q=${filterQ}&categoryId=${filterCategoryId}&priceMin=${filterPriceMin}&priceMax=${filterPriceMax}&sort=${currentSort}">
                                                            ${productsPage.totalPages}
                                                        </a>
                                                    </li>
                                                </c:if>

                                                <!-- Next Button -->
                                                <c:if test="${productsPage.number < productsPage.totalPages - 1}">
                                                    <li class="page-item">
                                                        <a class="page-link"
                                                            href="?page=${productsPage.number + 1}&q=${filterQ}&categoryId=${filterCategoryId}&priceMin=${filterPriceMin}&priceMax=${filterPriceMax}&sort=${currentSort}"
                                                            aria-label="Next">
                                                            <i class="fas fa-chevron-right"></i>
                                                        </a>
                                                    </li>
                                                </c:if>
                                            </ul>
                                        </nav>
                                    </c:if>
                                </c:if>

                                <c:if test="${empty productsPage.content}">
                                    <div class="empty-state text-center py-5">
                                        <i class="fas fa-box-open fa-4x text-muted mb-3"></i>
                                        <h5 class="text-muted">Không tìm thấy sản phẩm</h5>
                                        <p class="text-muted">Thử thay đổi bộ lọc hoặc tìm kiếm với từ khóa khác</p>
                                    </div>
                                </c:if>
                            </div>

                            <!-- ===== 5) SẢN PHẨM HOT TỪ SHOP KHÁC ===== -->
                            <div class="hot-products-section mt-5 p-4 rounded">
                                <div class="d-flex justify-content-between align-items-center mb-3">
                                    <h5 class="section-title mb-0">
                                        <i class="fas fa-fire text-danger"></i> Sản phẩm hot từ shop khác
                                    </h5>
                                </div> <!-- Filter cho sản phẩm hot -->
                                <form method="get" action="/store/${store.id}" class="mb-3">
                                    <!-- Preserve main filters -->
                                    <input type="hidden" name="page" value="${productsPage.number}" />
                                    <input type="hidden" name="q" value="${filterQ}" />
                                    <input type="hidden" name="categoryId" value="${filterCategoryId}" />
                                    <input type="hidden" name="priceMin" value="${filterPriceMin}" />
                                    <input type="hidden" name="priceMax" value="${filterPriceMax}" />
                                    <input type="hidden" name="sort" value="${currentSort}" />

                                    <div class="row g-2">
                                        <div class="col-md-3">
                                            <input type="text" name="hotQ" class="form-control form-control-sm"
                                                placeholder="Tìm kiếm..." value="${hotQ}" />
                                        </div>
                                        <div class="col-md-2">
                                            <select name="hotCategoryId" class="form-select form-select-sm">
                                                <option value="">Tất cả danh mục</option>
                                                <c:forEach var="cat" items="${categories}">
                                                    <option value="${cat.id}" ${hotCategoryId==cat.id ? 'selected' : ''
                                                        }>
                                                        ${cat.name}
                                                    </option>
                                                </c:forEach>
                                            </select>
                                        </div>
                                        <div class="col-md-2">
                                            <input type="number" name="hotPriceMin" class="form-control form-control-sm"
                                                placeholder="Giá từ" value="${hotPriceMin}" />
                                        </div>
                                        <div class="col-md-2">
                                            <input type="number" name="hotPriceMax" class="form-control form-control-sm"
                                                placeholder="Giá đến" value="${hotPriceMax}" />
                                        </div>
                                        <div class="col-md-2">
                                            <select name="hotSort" class="form-select form-select-sm">
                                                <option value="best_seller" ${hotSort=='best_seller' ? 'selected' : ''
                                                    }>Bán
                                                    chạy</option>
                                                <option value="newest" ${hotSort=='newest' ? 'selected' : '' }>Mới nhất
                                                </option>
                                                <option value="price_asc" ${hotSort=='price_asc' ? 'selected' : '' }>Giá
                                                    tăng</option>
                                                <option value="price_desc" ${hotSort=='price_desc' ? 'selected' : '' }>
                                                    Giá giảm</option>
                                            </select>
                                        </div>
                                        <div class="col-md-1">
                                            <button type="submit" class="btn btn-sm btn-outline-primary w-100">
                                                <i class="fas fa-search"></i> Tìm kiếm
                                            </button>
                                        </div>
                                    </div>
                                </form>

                                <!-- Hot products grid -->
                                <c:if test="${not empty hotProductsPage.content}">
                                    <div class="row">
                                        <c:forEach var="hp" items="${hotProductsPage.content}">
                                            <div class="col-6 col-md-4 col-lg-3 mb-3">
                                                <div class="card h-100 hot-product-card">
                                                    <a href="/product/${hp.slug}" class="text-decoration-none">
                                                        <div class="p-2 position-relative">
                                                            <span
                                                                class="badge bg-danger position-absolute top-0 start-0 m-2">
                                                                <i class="fas fa-fire"></i> Hot
                                                            </span>
                                                            <img src="<c:url value='/images/products/${hp.id}.png'/>"
                                                                data-fallback-url="${hp.productUrl}"
                                                                onerror="handleThumbError(this)" loading="lazy"
                                                                alt="${hp.name}" class="img-fluid rounded mb-2"
                                                                style="width:100%;height:140px;object-fit:cover;" />
                                                            <h6 class="card-title mb-1 text-dark small">${hp.name}</h6>
                                                            <p class="text-success fw-bold mb-1">
                                                                <fmt:formatNumber value="${hp.price}" type="currency"
                                                                    currencySymbol="" maxFractionDigits="0" />đ
                                                            </p>
                                                            <div
                                                                class="d-flex justify-content-between align-items-center">
                                                                <small
                                                                    class="text-muted">${hp.sellerStore.storeName}</small>
                                                                <small class="text-warning">
                                                                    <i class="fas fa-shopping-cart"></i>
                                                                    ${hp.soldQuantity}
                                                                </small>
                                                            </div>
                                                        </div>
                                                    </a>
                                                </div>
                                            </div>
                                        </c:forEach>
                                    </div>

                                    <!-- Pagination cho hot products -->
                                    <c:if test="${hotProductsPage.totalPages > 1}">
                                        <nav aria-label="Hot products pagination">
                                            <ul class="pagination justify-content-center">
                                                <!-- Previous Button -->
                                                <c:if test="${hotProductsPage.number > 0}">
                                                    <li class="page-item">
                                                        <a class="page-link"
                                                            href="?page=${productsPage.number}&q=${filterQ}&categoryId=${filterCategoryId}&priceMin=${filterPriceMin}&priceMax=${filterPriceMax}&sort=${currentSort}&hotPage=${hotProductsPage.number - 1}&hotQ=${hotQ}&hotCategoryId=${hotCategoryId}&hotPriceMin=${hotPriceMin}&hotPriceMax=${hotPriceMax}&hotSort=${hotSort}"
                                                            aria-label="Previous">
                                                            <i class="fas fa-chevron-left"></i>
                                                        </a>
                                                    </li>
                                                </c:if>

                                                <!-- First Page -->
                                                <c:if test="${hotProductsPage.number > 2}">
                                                    <li class="page-item">
                                                        <a class="page-link"
                                                            href="?page=${productsPage.number}&q=${filterQ}&categoryId=${filterCategoryId}&priceMin=${filterPriceMin}&priceMax=${filterPriceMax}&sort=${currentSort}&hotPage=0&hotQ=${hotQ}&hotCategoryId=${hotCategoryId}&hotPriceMin=${hotPriceMin}&hotPriceMax=${hotPriceMax}&hotSort=${hotSort}">
                                                            1
                                                        </a>
                                                    </li>
                                                    <li class="page-item disabled">
                                                        <span class="page-link">...</span>
                                                    </li>
                                                </c:if>

                                                <!-- Page Numbers (show current page +/- 2) -->
                                                <c:forEach var="i" begin="0" end="${hotProductsPage.totalPages - 1}">
                                                    <c:if
                                                        test="${i == 0 || i == hotProductsPage.totalPages - 1 || (i >= hotProductsPage.number - 1 && i <= hotProductsPage.number + 1)}">
                                                        <c:if
                                                            test="${!(i == 0 && hotProductsPage.number > 2) && !(i == hotProductsPage.totalPages - 1 && hotProductsPage.number < hotProductsPage.totalPages - 3)}">
                                                            <li
                                                                class="page-item ${i == hotProductsPage.number ? 'active' : ''}">
                                                                <a class="page-link"
                                                                    href="?page=${productsPage.number}&q=${filterQ}&categoryId=${filterCategoryId}&priceMin=${filterPriceMin}&priceMax=${filterPriceMax}&sort=${currentSort}&hotPage=${i}&hotQ=${hotQ}&hotCategoryId=${hotCategoryId}&hotPriceMin=${hotPriceMin}&hotPriceMax=${hotPriceMax}&hotSort=${hotSort}">
                                                                    ${i+1}
                                                                </a>
                                                            </li>
                                                        </c:if>
                                                    </c:if>
                                                </c:forEach>

                                                <!-- Last Page -->
                                                <c:if test="${hotProductsPage.number < hotProductsPage.totalPages - 3}">
                                                    <li class="page-item disabled">
                                                        <span class="page-link">...</span>
                                                    </li>
                                                    <li class="page-item">
                                                        <a class="page-link"
                                                            href="?page=${productsPage.number}&q=${filterQ}&categoryId=${filterCategoryId}&priceMin=${filterPriceMin}&priceMax=${filterPriceMax}&sort=${currentSort}&hotPage=${hotProductsPage.totalPages - 1}&hotQ=${hotQ}&hotCategoryId=${hotCategoryId}&hotPriceMin=${hotPriceMin}&hotPriceMax=${hotPriceMax}&hotSort=${hotSort}">
                                                            ${hotProductsPage.totalPages}
                                                        </a>
                                                    </li>
                                                </c:if>

                                                <!-- Next Button -->
                                                <c:if test="${hotProductsPage.number < hotProductsPage.totalPages - 1}">
                                                    <li class="page-item">
                                                        <a class="page-link"
                                                            href="?page=${productsPage.number}&q=${filterQ}&categoryId=${filterCategoryId}&priceMin=${filterPriceMin}&priceMax=${filterPriceMax}&sort=${currentSort}&hotPage=${hotProductsPage.number + 1}&hotQ=${hotQ}&hotCategoryId=${hotCategoryId}&hotPriceMin=${hotPriceMin}&hotPriceMax=${hotPriceMax}&hotSort=${hotSort}"
                                                            aria-label="Next">
                                                            <i class="fas fa-chevron-right"></i>
                                                        </a>
                                                    </li>
                                                </c:if>
                                            </ul>
                                        </nav>
                                    </c:if>
                                </c:if>

                                <c:if test="${empty hotProductsPage.content}">
                                    <div class="text-center py-4">
                                        <i class="fas fa-shopping-bag fa-3x text-muted mb-2"></i>
                                        <p class="text-muted">Không có sản phẩm hot từ shop khác</p>
                                    </div>
                                </c:if>
                            </div>

                        </div>
                    </div>

                    <jsp:include page="../common/footer.jsp" /> <!-- API load danh mục con -->
                    <c:url var="childrenApi" value="/seller/products/categories" />

                    <script>
                        // Prevent infinite onerror loops by tracking attempts
                        function handleThumbError(img) {
                            try {
                                if (!img) return;
                                var tried = img.getAttribute('data-tried') || '0';
                                tried = parseInt(tried);
                                if (tried >= 1) {
                                    // set placeholder
                                    img.onerror = null;
                                    img.src = '<c:url value="/images/others.png"/>';
                                    return;
                                }
                                img.setAttribute('data-tried', tried + 1);
                                var fallback = img.getAttribute('data-fallback-url');
                                if (fallback && fallback !== '' && img.src !== fallback) {
                                    img.src = fallback;
                                } else {
                                    img.onerror = null;
                                    img.src = '<c:url value="/images/others.png"/>';
                                }
                            } catch (e) {
                                img.onerror = null;
                                img.src = '<c:url value="/images/others.png"/>';
                            }
                        }
                    </script>

                    <!-- Toast notifications -->
                    <c:if test="${not empty successMessage}">
                        <script>iziToast.success({ title: 'Success!', message: '${successMessage}', position: 'topRight', timeout: 5000 });</script>
                    </c:if>
                    <c:if test="${not empty errorMessage}">
                        <script>iziToast.error({ title: 'Error!', message: '${errorMessage}', position: 'topRight', timeout: 5000 });</script>
                    </c:if>

                    <!-- Client-side validation (có thêm vPriceMax) -->
                    <script>
                        // Toggle sidebar khi nhấn vào nút (same as other pages)
                        function toggleSidebar() {
                            var sidebar = document.getElementById('sidebar');
                            var content = document.getElementById('content');
                            var overlay = document.getElementById('sidebarOverlay');

                            if (sidebar && content) {
                                sidebar.classList.toggle('active');
                                content.classList.toggle('shifted');

                                // Toggle overlay for mobile
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
                                menuToggle && !menuToggle.contains(event.target)) {
                                toggleSidebar();
                            }
                        });
                    </script>
                </body>

                </html>