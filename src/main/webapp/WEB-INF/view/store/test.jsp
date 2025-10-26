<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
            <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
                <!DOCTYPE html>
                <html lang="vi">

                <head>
                    <meta charset="UTF-8">
                    <title>
                        <c:choose>
                            <c:when test="${formMode=='CREATE'}">Thêm sản phẩm</c:when>
                            <c:otherwise>Cập nhật sản phẩm #${form.id}</c:otherwise>
                        </c:choose>
                    </title>
                    <jsp:include page="../common/head.jsp" />
                    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/store.css">
                </head>

                <body>
                    <jsp:include page="../common/navbar.jsp" />
                    <jsp:include page="../common/sidebar.jsp" />

                    <!-- Prefill ids từ Controller -->
                    <span id="prefill" data-parent="${selectedParentId}" data-child="${selectedChildId}"></span>

                    <div class="content" id="content">
                        <div class="container-fluid mt-3">
                            <div class="row">
                                <div class="col-md-4">
                                    <div class="info-card p-3">
                                        <h3>${store.storeName}</h3>
                                        <p class="text-muted">${store.description}</p>
                                        <p>Trạng thái: <strong>${store.status}</strong></p>
                                        <p>Rating: <strong>${store.rating}</strong></p>
                                        <p>Deposit: <strong>
                                                <fmt:formatNumber value="${store.depositAmount}" type="currency"
                                                    currencySymbol="" maxFractionDigits="0" />đ
                                            </strong></p>
                                        <!-- removed Max listing price from public view -->
                                        <hr />
                                        <h6>KPI nhanh</h6>
                                        <p>Tổng sản phẩm ACTIVE: <strong>${totalActiveProducts}</strong></p>
                                        <p>Tổng đã bán: <strong>${totalSold}</strong></p>
                                        <p>Tổng AVAILABLE: <strong>${totalAvailable}</strong></p>
                                        <p>Khoảng giá: <strong>
                                                <fmt:formatNumber value="${minPrice}" type="currency" currencySymbol=""
                                                    maxFractionDigits="0" />đ -
                                                <fmt:formatNumber value="${maxPrice}" type="currency" currencySymbol=""
                                                    maxFractionDigits="0" />đ
                                            </strong></p>
                                        <a href="/chat?sellerId=${store.owner.id}" class="btn btn-primary">Chat người
                                            bán</a>
                                    </div>
                                    <div class="info-card mt-3 p-3">
                                        <h6>Danh mục</h6>
                                        <form method="get" action="">
                                            <select name="categoryId" class="form-select mb-2"
                                                onchange="this.form.submit()">
                                                <option value="">-- Tất cả danh mục --</option>
                                                <c:forEach var="c" items="${categories}">
                                                    <option value="${c.id}" ${param.categoryId==c.id ? 'selected' : ''
                                                        }>
                                                        ${c.name}</option>
                                                </c:forEach>
                                            </select>
                                        </form>
                                    </div>
                                </div>

                                <div class="col-md-8">
                                    <div class="mb-3">
                                        <form class="row g-2" method="get" action="">
                                            <div class="col-md-4">
                                                <input type="text" name="q" class="form-control" placeholder="Từ khóa"
                                                    value="${param.q}" />
                                            </div>
                                            <div class="col-md-2">
                                                <input type="number" name="minPrice" class="form-control"
                                                    placeholder="Giá từ" value="${param.minPrice}" />
                                            </div>
                                            <div class="col-md-2">
                                                <input type="number" name="maxPrice" class="form-control"
                                                    placeholder="Giá đến" value="${param.maxPrice}" />
                                            </div>
                                            <div class="col-md-2">
                                                <select name="sort" class="form-select">
                                                    <option value="newest" ${currentSort=='newest' ? 'selected' : '' }>
                                                        Mới
                                                        nhất</option>
                                                    <option value="sold" ${currentSort=='sold' ? 'selected' : '' }>Bán
                                                        chạy
                                                    </option>
                                                    <option value="price_asc" ${currentSort=='price_asc' ? 'selected'
                                                        : '' }>Giá tăng</option>
                                                    <option value="price_desc" ${currentSort=='price_desc' ? 'selected'
                                                        : '' }>Giá giảm</option>
                                                </select>
                                            </div>
                                            <div class="col-md-2 d-grid">
                                                <button class="btn btn-primary" type="submit">Lọc</button>
                                            </div>
                                        </form>
                                    </div>

                                    <div class="row">
                                        <c:forEach var="p" items="${productsPage.content}">
                                            <div class="col-6 col-lg-4 mb-3">
                                                <div class="card h-100">
                                                    <div class="d-flex align-items-center p-2">
                                                        <img src="<c:url value='/images/products/${p.id}.jpg'/>"
                                                            data-fallback-url="${p.productUrl}"
                                                            onerror="handleThumbError(this)" loading="lazy"
                                                            alt="${p.name}"
                                                            style="width:80px;height:80px;object-fit:cover;border-radius:6px;" />
                                                        <div class="ms-2 flex-grow-1">
                                                            <h6 class="card-title mb-1">${p.name}</h6>
                                                            <p class="card-text text-success fw-bold mb-1">
                                                                <fmt:formatNumber value="${p.price}" type="currency"
                                                                    currencySymbol="" maxFractionDigits="0" />đ
                                                            </p>
                                                            <p class="small text-muted mb-1">Kho: ${p.stock}</p>
                                                            <a href="/product/${p.slug}"
                                                                class="btn btn-sm btn-primary">Chi
                                                                tiết</a>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </c:forEach>
                                    </div>

                                    <nav>
                                        <ul class="pagination">
                                            <c:forEach var="i" begin="0" end="${productsPage.totalPages - 1}">
                                                <li class="page-item ${i == productsPage.number ? 'active' : ''}"><a
                                                        class="page-link" href="?page=${i}">${i+1}</a></li>
                                            </c:forEach>
                                        </ul>
                                    </nav>

                                    <!-- Hot products from other shops -->
                                    <div class="mt-4 p-3 suggested-block">
                                        <div class="d-flex justify-content-between align-items-center mb-2">
                                            <h5 class="mb-0">Sản phẩm hot</h5>
                                            <form class="row g-2" method="get" action="">
                                                <!-- preserve main page filters -->
                                                <input type="hidden" name="categoryId" value="${param.categoryId}" />
                                                <input type="hidden" name="q" value="${param.q}" />
                                                <input type="hidden" name="minPrice" value="${param.minPrice}" />
                                                <input type="hidden" name="maxPrice" value="${param.maxPrice}" />

                                                <div class="col-auto">
                                                    <input type="text" name="suggestOther_q"
                                                        class="form-control form-control-sm" placeholder="Từ khóa"
                                                        value="${suggestOther_q}" />
                                                </div>
                                                <div class="col-auto">
                                                    <select name="suggestOther_categoryId"
                                                        class="form-select form-select-sm">
                                                        <option value="">-- Tất cả danh mục --</option>
                                                        <c:forEach var="c" items="${categories}">
                                                            <option value="${c.id}"
                                                                ${suggestOther_categoryId==c.id? 'selected' : '' }>
                                                                ${c.name}</option>
                                                        </c:forEach>
                                                    </select>
                                                </div>
                                                <div class="col-auto">
                                                    <input type="number" name="suggestOther_minPrice"
                                                        class="form-control form-control-sm" placeholder="Giá từ"
                                                        value="${suggestOther_minPrice}" />
                                                </div>
                                                <div class="col-auto">
                                                    <input type="number" name="suggestOther_maxPrice"
                                                        class="form-control form-control-sm" placeholder="Giá đến"
                                                        value="${suggestOther_maxPrice}" />
                                                </div>
                                                <div class="col-auto">
                                                    <select name="suggestOther_sort" class="form-select form-select-sm">
                                                        <option value="sold" ${suggestOther_sort=='sold' ? 'selected'
                                                            : '' }>Bán chạy</option>
                                                        <option value="newest" ${suggestOther_sort=='newest'
                                                            ? 'selected' : '' }>Mới</option>
                                                        <option value="price_asc" ${suggestOther_sort=='price_asc'
                                                            ? 'selected' : '' }>Giá tăng</option>
                                                        <option value="price_desc" ${suggestOther_sort=='price_desc'
                                                            ? 'selected' : '' }>Giá giảm</option>
                                                    </select>
                                                </div>
                                                <div class="col-auto d-grid">
                                                    <button class="btn btn-sm btn-outline-primary" type="submit">Áp
                                                        dụng</button>
                                                </div>
                                            </form>
                                        </div>

                                        <div class="row">
                                            <c:forEach var="osp" items="${suggestedOtherProductsPage.content}">
                                                <div class="col-6 col-md-3 mb-3">
                                                    <div class="card h-100">
                                                        <div class="d-flex align-items-center p-2">
                                                            <img src="<c:url value='/images/products/${osp.id}.jpg'/>"
                                                                data-fallback-url="${osp.productUrl}"
                                                                onerror="handleThumbError(this)" loading="lazy"
                                                                alt="${osp.name}"
                                                                style="width:80px;height:80px;object-fit:cover;border-radius:6px;" />
                                                            <div class="ms-2 flex-grow-1">
                                                                <h6 class="card-title mb-1">${osp.name}</h6>
                                                                <p class="card-text text-success fw-bold mb-1">
                                                                    <fmt:formatNumber value="${osp.price}"
                                                                        type="currency" currencySymbol=""
                                                                        maxFractionDigits="0" />đ
                                                                </p>
                                                                <p class="small text-muted mb-1">Cửa hàng:
                                                                    ${osp.sellerStore.storeName}</p>
                                                                <a href="/product/${osp.slug}"
                                                                    class="btn btn-sm btn-primary">Chi tiết</a>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </c:forEach>
                                            <c:if test="${empty suggestedOtherProductsPage.content}">
                                                <div class="col-12">
                                                    <p class="text-muted">Không có sản phẩm hot từ shop khác.</p>
                                                </div>
                                            </c:if>
                                        </div>
                                        <nav>
                                            <ul class="pagination mt-2">
                                                <c:forEach var="i" begin="0"
                                                    end="${suggestedOtherProductsPage.totalPages - 1}">
                                                    <li
                                                        class="page-item ${i == suggestedOtherProductsPage.number ? 'active' : ''}">
                                                        <a class="page-link"
                                                            href="?suggestOtherPage=${i}&suggestOtherSize=${suggestOtherSize}&suggestOther_q=${fn:escapeXml(suggestOther_q)}&suggestOther_categoryId=${suggestOther_categoryId}&suggestOther_minPrice=${suggestOther_minPrice}&suggestOther_maxPrice=${suggestOther_maxPrice}&suggestOther_sort=${suggestOther_sort}">${i+1}</a>
                                                    </li>
                                                </c:forEach>
                                            </ul>
                                        </nav>
                                    </div>

                                    <!-- 'Sản phẩm gợi ý (shop khác)' đã bị loại bỏ theo yêu cầu -->
                                </div>
                            </div>
                        </div>
                    </div>

                    <jsp:include page="../common/footer.jsp" />

                    <!-- API load danh mục con -->
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
                </body>

                </html>