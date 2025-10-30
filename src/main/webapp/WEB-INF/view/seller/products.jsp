<%@ page contentType="text/html; charset=UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

                <!DOCTYPE html>
                <html lang="vi">

                <head>
                    <meta charset="UTF-8">
                    <c:if test="${not empty _csrf}">
                        <meta name="_csrf" content="${_csrf.token}" />
                        <meta name="_csrf_header" content="${_csrf.headerName}" />
                    </c:if>
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>
                        <c:if test="${not empty pageTitle}">${pageTitle} - </c:if>MMO Market System
                    </title>

                    <jsp:include page="../common/head.jsp" />
                    <!-- CSS dành riêng cho trang sản phẩm -->
                    <link rel="stylesheet" href="<c:url value='/css/products.css'/>">
                </head>

                <body>
                    <jsp:include page="../common/navbar.jsp" />
                    <jsp:include page="../common/sidebar.jsp" />

                    <!-- Sidebar Overlay for Mobile -->
                    <div class="sidebar-overlay" id="sidebarOverlay" onclick="toggleSidebar()" role="button"
                        tabindex="0" onKeyPress="if(event.key === 'Enter') toggleSidebar()"></div>

                    <div class="content" id="content">
                        <div class="container mt-4">
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <h4>Danh sách sản phẩm</h4>
                                <c:url var="newUrl" value="/seller/products/new">
                                    <c:param name="storeId" value="${storeId}" />
                                </c:url>
                                <a class="btn btn-primary" href="${newUrl}">Thêm sản phẩm</a>
                            </div>

                            <!-- Filter form -->
                            <form id="filterForm" method="get" action="<c:url value='/seller/products'/>"
                                class="row g-2 mb-3">
                                <input type="hidden" name="storeId" value="${storeId}" />

                                <div class="col-md-3">
                                    <input class="form-control" name="q" value="${fn:escapeXml(q)}"
                                        placeholder="Từ khoá tên/slug..." maxlength="100" aria-describedby="qHelp" />
                                    <div id="qHelp" class="form-text">Tối đa 100 ký tự.</div>
                                    <div class="invalid-feedback">Từ khoá quá dài hoặc không hợp lệ.</div>
                                </div>

                                <!-- CHỈ ACTIVE / INACTIVE -->
                                <div class="col-md-2">
                                    <select class="form-select" name="status" aria-label="Trạng thái">
                                        <option value="">-- Trạng thái --</option>
                                        <option value="ACTIVE" <c:if test="${status == 'ACTIVE'}">selected</c:if>>ACTIVE
                                        </option>
                                        <option value="INACTIVE" <c:if test="${status == 'INACTIVE'}">selected</c:if>
                                            >INACTIVE</option>
                                    </select>
                                    <div class="invalid-feedback">Giá trị trạng thái không hợp lệ.</div>
                                </div>

                                <div class="col-md-3">
                                    <select class="form-select" name="parentCategoryId" onchange="this.form.submit()"
                                        aria-label="Danh mục cha">
                                        <option value="">-- Tùy chọn danh mục --</option>
                                        <c:forEach var="pc" items="${parentCategories}">
                                            <option value="${pc.id}" <c:if test="${parentCategoryId == pc.id}">selected
                                                </c:if>>${pc.name}</option>
                                        </c:forEach>
                                    </select>
                                    <div class="invalid-feedback">Danh mục cha không hợp lệ.</div>
                                </div>

                                <div class="col-md-2">
                                    <select class="form-select" name="categoryId" aria-label="Danh mục">
                                        <option value="">-- Danh mục --</option>
                                        <c:forEach var="c" items="${subCategories}">
                                            <option value="${c.id}" <c:if test="${categoryId == c.id}">selected</c:if>
                                                >${c.name}</option>
                                        </c:forEach>
                                    </select>
                                    <div class="invalid-feedback">Danh mục không hợp lệ.</div>
                                </div>

                                <div class="col-md-2">
                                    <input type="date" class="form-control" name="fromDate" value="${fromDate}"
                                        placeholder="Từ ngày" aria-label="Từ ngày" />
                                    <div class="invalid-feedback">Ngày bắt đầu không hợp lệ.</div>
                                </div>
                                <div class="col-md-2">
                                    <input type="date" class="form-control" name="toDate" value="${toDate}"
                                        placeholder="Đến ngày" aria-label="Đến ngày" />
                                    <div class="invalid-feedback">Ngày kết thúc phải ≥ ngày bắt đầu.</div>
                                </div>

                                <div class="col-md-2">
                                    <input type="number" name="minPrice" id="minPrice" class="form-control" step="10000"
                                        min="0" placeholder="Giá từ (₫)" onchange="checkPriceRange()" />
                                    <div id="minError" class="error-text"></div>
                                </div>

                                <!-- Giá đến -->
                                <div class="col-md-2">
                                    <input type="number" name="maxPrice" id="maxPrice" class="form-control" step="10000"
                                        min="10000" placeholder="Giá đến (₫)" onchange="checkPriceRange()" />
                                    <div id="maxError" class="error-text"></div>
                                </div>
                                <script>
                                    function checkPriceRange() {
                                        const minEl = document.getElementById('minPrice');
                                        const maxEl = document.getElementById('maxPrice');
                                        const minErr = document.getElementById('minError');
                                        const maxErr = document.getElementById('maxError');

                                        // Xoá lỗi cũ
                                        minErr.textContent = '';
                                        maxErr.textContent = '';

                                        // Đọc số an toàn (valueAsNumber -> NaN nếu nhập sai)
                                        const hasMin = minEl.value.trim() !== '';
                                        const hasMax = maxEl.value.trim() !== '';
                                        const minVal = hasMin ? minEl.valueAsNumber : null;
                                        const maxVal = hasMax ? maxEl.valueAsNumber : null;

                                        // Sai định dạng số
                                        if (hasMin && Number.isNaN(minVal)) {
                                            minErr.textContent = 'Giá tối thiểu không hợp lệ';
                                            return;
                                        }
                                        if (hasMax && Number.isNaN(maxVal)) {
                                            maxErr.textContent = 'Giá tối đa không hợp lệ';
                                            return;
                                        }

                                        // max < min
                                        if (hasMin && hasMax && maxVal < minVal) {
                                            maxErr.textContent = '⚠ Giá tối đa phải lớn hơn hoặc bằng giá tối thiểu';
                                            return;
                                        }
                                    }
                                </script>

                                <div class="col-md-2">
                                    <button class="btn btn-outline-secondary w-100" type="submit">Lọc</button>
                                </div>
                            </form>

                            <!-- TABLE -->
                            <div class="table-container">
                                <table class="resizable-table table align-middle" id="resizableTable">
                                    <thead>
                                        <tr>
                                            <th class="sortable" style="width:90px;" data-column="0" data-type="number">
                                                ID
                                                <div class="resizer"></div>
                                            </th>
                                            <th class="sortable" style="width:320px;" data-column="1" data-type="text">
                                                Tên
                                                sản phẩm<div class="resizer"></div>
                                            </th>
                                            <th class="sortable" style="width:180px;" data-column="2" data-type="text">
                                                Danh
                                                mục<div class="resizer"></div>
                                            </th>
                                            <th class="sortable" style="width:140px;" data-column="3"
                                                data-type="number">Giá
                                                bán<div class="resizer"></div>
                                            </th>
                                            <th class="sortable" style="width:140px;" data-column="4" data-type="text">
                                                Trạng
                                                thái<div class="resizer"></div>
                                            </th>
                                            <th class="sortable" style="width:160px;" data-column="5"
                                                data-type="number">Số
                                                lượng mã khả dụng<div class="resizer"></div>
                                            </th>
                                            <th style="width:260px;">Hành động</th>
                                        </tr>
                                    </thead>

                                    <tbody>
                                        <c:if test="${empty page.content}">
                                            <tr>
                                                <td colspan="7" class="text-center text-muted py-4">Không có sản phẩm
                                                    nào
                                                    khớp bộ lọc.</td>
                                            </tr>
                                        </c:if>

                                        <c:forEach var="p" items="${page.content}">
                                            <tr>
                                                <td>#${p.id}</td>
                                                <td>
                                                    <div class="d-flex gap-2 align-items-center">
                                                        <c:choose>
                                                            <c:when test="${not empty p.productUrl}">
                                                                <img src="<c:url value='/images/products/${p.id}.png'/>"
                                                                    data-fallback-url="${fn:escapeXml(p.productUrl)}"
                                                                    onerror="handleThumbError(this)" alt="img"
                                                                    style="height:40px;width:40px;object-fit:cover;border-radius:6px;border:1px solid #eee" />
                                                            </c:when>
                                                            <c:otherwise>
                                                                <div style="height:40px;width:40px;border:1px dashed #ccc;border-radius:6px"
                                                                    class="d-flex align-items-center justify-content-center text-muted small">
                                                                    —</div>
                                                            </c:otherwise>
                                                        </c:choose>
                                                        <div>
                                                            <div class="fw-semibold">${p.name}</div>
                                                            <div class="text-muted small">${p.slug}</div>
                                                        </div>
                                                    </div>
                                                </td>
                                                <td>${p.category != null ? p.category.name : '-'}</td>
                                                <td>
                                                    <fmt:formatNumber value="${p.price}" type="currency"
                                                        currencySymbol="₫" />
                                                </td>
                                                <td><span
                                                        class="badge ${p.status=='ACTIVE'?'bg-success':'bg-secondary'}">${p.status}</span>
                                                </td>
                                                <td>${p.stock}</td>

                                                <td class="text-end">
                                                    <!-- Toggle -->
                                                    <c:url var="toggleUrl" value="/seller/products/${p.id}/toggle">
                                                        <c:param name="storeId" value="${storeId}" />
                                                    </c:url>
                                                    <form class="d-inline" method="post" action="${toggleUrl}"
                                                        data-stock="${p.stock}"
                                                        data-toggle-to="${p.status=='ACTIVE'?'INACTIVE':'ACTIVE'}">
                                                        <input type="hidden" name="to"
                                                            value="${p.status=='ACTIVE'?'INACTIVE':'ACTIVE'}" />
                                                        <c:if test="${not empty _csrf}">
                                                            <input type="hidden" name="${_csrf.parameterName}"
                                                                value="${_csrf.token}" />
                                                        </c:if>
                                                        <c:choose>
                                                            <c:when test="${p.status=='ACTIVE'}">
                                                                <button
                                                                    class="btn btn-sm btn-outline-warning">Tắt</button>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <c:choose>
                                                                    <c:when test="${p.stock != null && p.stock > 0}">
                                                                        <button
                                                                            class="btn btn-sm btn-outline-success">Bật</button>
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <button class="btn btn-sm btn-outline-success"
                                                                            disabled
                                                                            title="Vui lòng nhập hàng">Bật</button>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </form>

                                                    <!-- Chi tiết -->
                                                    <button type="button" class="btn btn-sm btn-outline-info me-1"
                                                        title="Xem chi tiết" data-bs-toggle="modal"
                                                        data-bs-target="#productDetailModal" data-id="${p.id}"
                                                        data-name="${fn:escapeXml(p.name)}"
                                                        data-slug="${fn:escapeXml(p.slug)}"
                                                        data-category="${p.category != null ? fn:escapeXml(p.category.name) : '-'}"
                                                        data-price="${p.price}" data-status="${p.status}"
                                                        data-stock="${p.stock}" data-img="${fn:escapeXml(p.productUrl)}"
                                                        data-desc="${fn:escapeXml(p.description)}">
                                                        <i class="bi bi-info-circle-fill"></i>
                                                        <span class="ms-1">Chi tiết</span>
                                                    </button>

                                                    <!-- Sửa -->
                                                    <button type="button" class="btn btn-sm btn-outline-primary me-1"
                                                        title="Chỉnh sửa" data-bs-toggle="modal"
                                                        data-bs-target="#productEditModal"
                                                        data-edit-url="<c:url value='/seller/products/${p.id}/edit'><c:param name='storeId' value='${storeId}'/></c:url>"
                                                        data-id="${p.id}" data-name="${fn:escapeXml(p.name)}"
                                                        data-slug="${fn:escapeXml(p.slug)}"
                                                        data-category="${p.category != null ? fn:escapeXml(p.category.name) : '-'}"
                                                        data-category-id="${p.category != null ? p.category.id : ''}"
                                                        data-parent-category-id="${p.category != null && p.category.parent != null ? p.category.parent.id : ''}"
                                                        data-price="${p.price}" data-status="${p.status}"
                                                        data-stock="${p.stock}" data-img="${fn:escapeXml(p.productUrl)}"
                                                        data-desc="${fn:escapeXml(p.description)}">
                                                        <i class="bi bi-pencil-fill"></i>
                                                        <span class="ms-1">Sửa</span>
                                                    </button>

                                                    <!-- Xóa mềm (để sẵn) -->
                                                    <c:url var="deleteUrl" value="/seller/products/${p.id}/delete">
                                                        <c:param name="storeId" value="${storeId}" />
                                                    </c:url>
                                                    <form class="d-inline" method="post" action="${deleteUrl}"
                                                        onsubmit="return confirm('Ẩn sản phẩm này?');">
                                                        <c:if test="${not empty _csrf}">
                                                            <input type="hidden" name="${_csrf.parameterName}"
                                                                value="${_csrf.token}" />
                                                        </c:if>
                                                    </form>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>

                            <!-- Pagination -->
                            <c:if test="${page.totalPages > 1}">
                                <div class="pagination-container">
                                    <nav>
                                        <ul class="pagination">
                                            <c:if test="${!page.first}">
                                                <c:url var="prevUrl" value="/seller/products">
                                                    <c:param name="storeId" value="${storeId}" />
                                                    <c:param name="q" value="${q}" />
                                                    <c:param name="status" value="${status}" />
                                                    <c:param name="parentCategoryId" value="${parentCategoryId}" />
                                                    <c:param name="categoryId" value="${categoryId}" />
                                                    <c:param name="fromDate" value="${fromDate}" />
                                                    <c:param name="toDate" value="${toDate}" />
                                                    <c:param name="size" value="${page.size}" />
                                                    <c:param name="page" value="${page.number - 1}" />
                                                </c:url>
                                                <li class="page-item"><a class="page-link" href="${prevUrl}">&laquo;</a>
                                                </li>
                                            </c:if>

                                            <c:forEach begin="0" end="${page.totalPages-1}" var="i">
                                                <c:url var="pageUrl" value="/seller/products">
                                                    <c:param name="storeId" value="${storeId}" />
                                                    <c:param name="q" value="${q}" />
                                                    <c:param name="status" value="${status}" />
                                                    <c:param name="parentCategoryId" value="${parentCategoryId}" />
                                                    <c:param name="categoryId" value="${categoryId}" />
                                                    <c:param name="fromDate" value="${fromDate}" />
                                                    <c:param name="toDate" value="${toDate}" />
                                                    <c:param name="size" value="${page.size}" />
                                                    <c:param name="page" value="${i}" />
                                                </c:url>
                                                <li class="page-item ${i==page.number?'active':''}">
                                                    <a class="page-link" href="${pageUrl}">${i+1}</a>
                                                </li>
                                            </c:forEach>

                                            <c:if test="${!page.last}">
                                                <c:url var="nextUrl" value="/seller/products">
                                                    <c:param name="storeId" value="${storeId}" />
                                                    <c:param name="q" value="${q}" />
                                                    <c:param name="status" value="${status}" />
                                                    <c:param name="parentCategoryId" value="${parentCategoryId}" />
                                                    <c:param name="categoryId" value="${categoryId}" />
                                                    <c:param name="fromDate" value="${fromDate}" />
                                                    <c:param name="toDate" value="${toDate}" />
                                                    <c:param name="size" value="${page.size}" />
                                                    <c:param name="page" value="${page.number + 1}" />
                                                </c:url>
                                                <li class="page-item"><a class="page-link" href="${nextUrl}">&raquo;</a>
                                                </li>
                                            </c:if>
                                        </ul>
                                    </nav>
                                </div>
                            </c:if>
                        </div>
                    </div>

                    <jsp:include page="../common/footer.jsp" />

                    <!-- DETAIL MODAL -->
                    <div class="modal fade" id="productDetailModal" tabindex="-1" aria-labelledby="productDetailLabel"
                        aria-hidden="true">
                        <div class="modal-dialog modal-lg modal-dialog-centered">
                            <div class="modal-content">
                                <div class="modal-header bg-info text-white">
                                    <h5 class="modal-title" id="productDetailLabel"><i
                                            class="bi bi-info-circle-fill"></i> Chi tiết sản phẩm</h5>
                                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"
                                        aria-label="Close"></button>
                                </div>
                                <div class="modal-body">
                                    <div class="container-fluid">
                                        <div class="row mb-3">
                                            <div class="col-md-8">
                                                <div class="detail-item">
                                                    <label class="detail-label">Tên sản phẩm:</label>
                                                    <div class="detail-value" id="d-name"></div>
                                                </div>
                                            </div>
                                            <div class="col-md-4">
                                                <div class="detail-item">
                                                    <label class="detail-label">Mã (#ID):</label>
                                                    <div class="detail-value" id="d-id"></div>
                                                </div>
                                            </div>
                                        </div>

                                        <div class="row mb-3">
                                            <div class="col-md-6">
                                                <div class="detail-item">
                                                    <label class="detail-label">Slug:</label>
                                                    <div class="detail-value" id="d-slug"></div>
                                                </div>
                                            </div>
                                            <div class="col-md-6">
                                                <div class="detail-item">
                                                    <label class="detail-label">Danh mục:</label>
                                                    <div class="detail-value" id="d-category"></div>
                                                </div>
                                            </div>
                                        </div>

                                        <div class="row mb-3">
                                            <div class="col-md-4">
                                                <div class="detail-item">
                                                    <label class="detail-label">Giá bán:</label>
                                                    <div class="detail-value text-success fw-bold" id="d-price"></div>
                                                </div>
                                            </div>
                                            <div class="col-md-4">
                                                <div class="detail-item">
                                                    <label class="detail-label">Số lượng hiện tại:</label>
                                                    <div class="detail-value" id="d-stock"></div>
                                                </div>
                                            </div>
                                            <div class="col-md-4">
                                                <div class="detail-item">
                                                    <label class="detail-label">Trạng thái:</label>
                                                    <div class="detail-value" id="d-status"></div>
                                                </div>
                                            </div>
                                        </div>

                                        <div class="row mb-2">
                                            <div class="col-12">
                                                <img id="d-img" src="" alt="image"
                                                    style="max-height:160px;border-radius:10px;border:1px solid #eee;display:none">
                                            </div>
                                        </div>

                                        <div class="row mt-3">
                                            <div class="col-12">
                                                <div class="detail-item">
                                                    <label class="detail-label">Mô tả:</label>
                                                    <div class="detail-value" id="d-desc"></div>
                                                </div>
                                            </div>
                                        </div>

                                    </div>
                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                                        <i class="bi bi-x-circle"></i> Đóng
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- EDIT MODAL -->
                    <div class="modal fade" id="productEditModal" tabindex="-1" aria-labelledby="productEditLabel"
                        aria-hidden="true">
                        <div class="modal-dialog modal-lg modal-dialog-centered">
                            <div class="modal-content">
                                <div class="modal-header bg-warning text-dark">
                                    <h5 class="modal-title" id="productEditLabel"><i class="bi bi-pencil-fill"></i>
                                        Chỉnh sửa sản phẩm</h5>
                                    <button type="button" class="btn-close" data-bs-dismiss="modal"
                                        aria-label="Close"></button>
                                </div>
                                <div class="modal-body">
                                    <form id="editForm" enctype="multipart/form-data">
                                        <input type="hidden" id="e-id" name="id">
                                        <div class="product-form-grid">
                                            <div class="product-form-group">
                                                <label class="product-form-label">Tên sản phẩm</label>
                                                <input type="text" class="product-form-control form-control" id="e-name"
                                                    name="name" required maxlength="120">
                                            </div>

                                            <div class="product-form-group">
                                                <label class="product-form-label">Slug</label>
                                                <input type="text" class="product-form-control form-control" id="e-slug"
                                                    name="slug" required maxlength="120">
                                                <div class="product-form-text">Chỉ a-z, 0-9, dấu gạch ngang (-), 2–120
                                                    ký tự.</div>
                                            </div>

                                            <div class="product-form-group">
                                                <label class="product-form-label">Tùy chọn danh mục</label>
                                                <select class="product-form-select form-select" id="e-parentCategory">
                                                    <option value="">-- Tùy chọn danh mục --</option>
                                                    <c:forEach var="pc" items="${parentCategories}">
                                                        <option value="${pc.id}">${pc.name}</option>
                                                    </c:forEach>
                                                </select>
                                            </div>

                                            <div class="product-form-group">
                                                <label class="product-form-label">Danh mục</label>
                                                <select class="product-form-select form-select" id="e-categoryId"
                                                    name="category.id" required>
                                                    <option value="">-- Chọn danh mục --</option>
                                                    <c:forEach var="c" items="${subCategories}">
                                                        <option value="${c.id}">${c.name}</option>
                                                    </c:forEach>
                                                </select>
                                            </div>

                                            <div class="product-form-group">
                                                <label class="product-form-label">Giá</label>
                                                <input type="number" class="product-form-control form-control"
                                                    id="e-price" name="price" step="10000" min="0" required>
                                            </div>

                                            <div class="product-form-group">
                                                <label class="product-form-label">Trạng thái</label>
                                                <select class="product-form-select form-select" id="e-status"
                                                    name="status">
                                                    <option value="ACTIVE">ACTIVE</option>
                                                    <option value="INACTIVE">INACTIVE</option>
                                                </select>
                                            </div>

                                            <div class="product-form-group product-form-full-width">
                                                <label class="product-form-label">Ảnh đại diện sản phẩm</label>
                                                <input class="product-form-control form-control" type="file"
                                                    id="e-imageFile" name="imageFile" accept="image/jpeg,image/png" />
                                                <div id="e-currentImage" class="mt-2"></div>
                                                <div class="product-form-text">Chỉ JPG/PNG, tối đa 10MB.</div>
                                            </div>

                                            <div class="product-form-group product-form-full-width">
                                                <label class="product-form-label">Mô tả</label>
                                                <textarea class="product-form-control form-control" id="e-description"
                                                    name="description" rows="4" maxlength="200"></textarea>
                                            </div>

                                            <div class="product-form-group">
                                                <label class="product-form-label">Số lượng hiện tại:</label>
                                                <div id="e-stock" class="product-form-plaintext">0</div>
                                                <input type="hidden" id="e-stock-hidden" name="stock" value="0" />
                                            </div>

                                        </div>
                                    </form>
                                </div>

                                <!-- FOOTER có thêm nút "Nhập sản phẩm" KHÔNG điều hướng -->
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                                        <i class="bi bi-x-circle"></i> Hủy
                                    </button>

                                    <button type="button" class="btn btn-outline-dark" id="btnImportProductModal"
                                        data-product-id="">
                                        <i class="bi bi-box-arrow-in-down"></i>
                                        <span class="ms-1">Nhập sản phẩm</span>
                                    </button>

                                    <button type="button" class="btn btn-success" id="ajaxSaveBtn">
                                        <i class="bi bi-save"></i> Lưu
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- JS to populate modals + import button -->
                    <script>
                        (function () {
                            const money = (v) => new Intl.NumberFormat('vi-VN').format(Number(v || 0));

                            // Detail modal
                            const detailModal = document.getElementById('productDetailModal');
                            detailModal?.addEventListener('show.bs.modal', function (event) {
                                const btn = event.relatedTarget;
                                if (!btn) return;
                                const get = (name) => btn.getAttribute('data-' + name) || '';

                                document.getElementById('d-id').textContent = '#' + get('id');
                                document.getElementById('d-name').textContent = get('name');
                                document.getElementById('d-desc').textContent = get('desc') || '';
                                document.getElementById('d-slug').textContent = get('slug');
                                document.getElementById('d-category').textContent = get('category');
                                document.getElementById('d-price').textContent = money(get('price')) + ' ₫';
                                document.getElementById('d-stock').textContent = get('stock');
                                document.getElementById('d-status').textContent = get('status');

                                const imgEl = document.getElementById('d-img');
                                const img = get('img');
                                if (img) { imgEl.src = img; imgEl.style.display = 'block'; }
                                else { imgEl.style.display = 'none'; imgEl.src = ''; }
                            });

                            // Function to load subcategories
                            async function loadSubcategories(parentId, selectedCategoryId = null) {
                                const catSelect = document.getElementById('e-categoryId');
                                if (!catSelect) return;

                                // Clear current options
                                catSelect.innerHTML = '<option value="">-- Chọn danh mục --</option>';

                                if (!parentId) return;

                                try {
                                    const res = await fetch(window.location.origin + '/seller/products/categories?parentId=' + parentId);
                                    const data = await res.json();

                                    data.forEach(cat => {
                                        const opt = document.createElement('option');
                                        opt.value = cat.id;
                                        opt.textContent = cat.name;
                                        if (selectedCategoryId && cat.id == selectedCategoryId) {
                                            opt.selected = true;
                                        }
                                        catSelect.appendChild(opt);
                                    });
                                } catch (e) {
                                    console.error('Error loading subcategories:', e);
                                }
                            }

                            // Edit modal
                            const editModal = document.getElementById('productEditModal');
                            let editUrl = null;

                            // Add event listener for parent category change
                            const parentSelect = document.getElementById('e-parentCategory');
                            if (parentSelect) {
                                parentSelect.addEventListener('change', function () {
                                    const parentId = this.value;
                                    loadSubcategories(parentId);
                                });
                            }

                            editModal?.addEventListener('show.bs.modal', async function (event) {
                                const btn = event.relatedTarget;
                                if (!btn) return;
                                const get = (name) => btn.getAttribute('data-' + name) || '';

                                editUrl = get('edit-url');
                                const idVal = get('id');

                                document.getElementById('e-id').value = idVal;
                                document.getElementById('e-name').value = get('name');
                                document.getElementById('e-slug').value = get('slug');
                                document.getElementById('e-price').value = get('price');

                                const stockVal = get('stock');
                                const eStockView = document.getElementById('e-stock');
                                const eStockHidden = document.getElementById('e-stock-hidden');
                                if (eStockView) eStockView.textContent = stockVal;
                                if (eStockHidden) eStockHidden.value = stockVal;

                                document.getElementById('e-status').value = get('status') === 'ACTIVE' ? 'ACTIVE' : 'INACTIVE';

                                // Get category information from data attributes
                                const categoryId = get('category-id');
                                const parentCategoryId = get('parent-category-id');

                                const parentSelect = document.getElementById('e-parentCategory');

                                // Set parent category if available
                                if (parentSelect && parentCategoryId) {
                                    parentSelect.value = parentCategoryId;
                                    // Load subcategories for this parent
                                    await loadSubcategories(parentCategoryId, categoryId);
                                } else if (parentSelect) {
                                    parentSelect.value = '';
                                    // Clear subcategories
                                    const catSelect = document.getElementById('e-categoryId');
                                    if (catSelect) {
                                        catSelect.innerHTML = '<option value="">-- Chọn danh mục --</option>';
                                    }
                                }

                                const desc = get('desc');
                                const descEl = document.getElementById('e-description');
                                if (descEl) descEl.value = desc || '';

                                const img = get('img');
                                const imgWrap = document.getElementById('e-currentImage');
                                if (img && imgWrap) {
                                    imgWrap.innerHTML = '<img src="' + img + '" alt="img" style="max-height:80px;border-radius:6px;border:1px solid #eee" id="e-preview-img">';
                                } else if (imgWrap) { imgWrap.innerHTML = ''; }

                                // Reset file input
                                const imageFileInput = document.getElementById('e-imageFile');
                                if (imageFileInput) {
                                    imageFileInput.value = '';
                                }

                                // GẮN ID cho nút "Nhập sản phẩm"
                                const importBtn = document.getElementById('btnImportProductModal');
                                if (importBtn) {
                                    importBtn.dataset.productId = idVal || '';
                                }
                            });

                            // Preview image when file is selected
                            const imageFileInput = document.getElementById('e-imageFile');
                            if (imageFileInput) {
                                imageFileInput.addEventListener('change', function (e) {
                                    const file = e.target.files[0];
                                    if (file) {
                                        // Validate file type
                                        if (!file.type.match('image/jpeg') && !file.type.match('image/png')) {
                                            if (window.iziToast) {
                                                iziToast.warning({ title: 'Cảnh báo', message: 'Chỉ chấp nhận file JPG hoặc PNG', position: 'topRight' });
                                            } else {
                                                alert('Chỉ chấp nhận file JPG hoặc PNG');
                                            }
                                            e.target.value = '';
                                            return;
                                        }

                                        if (file.size > 10 * 1024 * 1024) {
                                            if (window.iziToast) {
                                                iziToast.warning({ title: 'Cảnh báo', message: 'File ảnh không được vượt quá 10MB', position: 'topRight' });
                                            } else {
                                                alert('File ảnh không được vượt quá 10MB');
                                            }
                                            e.target.value = '';
                                            return;
                                        }

                                        const reader = new FileReader();
                                        reader.onload = function (event) {
                                            const imgWrap = document.getElementById('e-currentImage');
                                            if (imgWrap) {
                                                imgWrap.innerHTML = '<div class="mb-2"><small class="text-muted">Ảnh mới (chưa lưu):</small></div>' +
                                                    '<img src="' + event.target.result + '" alt="preview" style="max-height:80px;border-radius:6px;border:1px solid #eee" id="e-preview-img">';
                                            }
                                        };
                                        reader.readAsDataURL(file);
                                    }
                                });
                            }

                            // AJAX save in modal
                            document.getElementById('ajaxSaveBtn')?.addEventListener('click', async function () {
                                const id = document.getElementById('e-id').value;
                                const imageFileInput = document.getElementById('e-imageFile');
                                const hasNewImage = imageFileInput && imageFileInput.files && imageFileInput.files.length > 0;

                                const tokenMeta = document.querySelector('meta[name="_csrf"]');
                                const headerMeta = document.querySelector('meta[name="_csrf_header"]');

                                try {
                                    if (hasNewImage) {
                                        const imageFile = imageFileInput.files[0];
                                        const formData = new FormData();
                                        formData.append('imageFile', imageFile);

                                        const imageHeaders = {};
                                        if (tokenMeta && headerMeta) imageHeaders[headerMeta.content] = tokenMeta.content;

                                        const imageRes = await fetch(window.location.origin + '/seller/products/' + id + '/upload-image?storeId=' + encodeURIComponent('${storeId}'), {
                                            method: 'POST',
                                            headers: imageHeaders,
                                            body: formData
                                        });

                                        const imageData = await imageRes.json();
                                        if (!imageData.ok) {
                                            if (window.iziToast) iziToast.error({ title: 'Lỗi', message: imageData.message || 'Lỗi upload ảnh', position: 'topRight' });
                                            else alert(imageData.message || 'Lỗi upload ảnh');
                                            return;
                                        }
                                    }

                                    const payload = {
                                        id: id,
                                        name: document.getElementById('e-name').value,
                                        slug: document.getElementById('e-slug').value,
                                        price: document.getElementById('e-price').value,
                                        stock: (document.getElementById('e-stock-hidden') ? document.getElementById('e-stock-hidden').value : (document.getElementById('e-stock') ? document.getElementById('e-stock').textContent : '')),
                                        status: document.getElementById('e-status').value,
                                        description: document.getElementById('e-description') ? document.getElementById('e-description').value : '',
                                        categoryId: document.getElementById('e-categoryId') ? document.getElementById('e-categoryId').value : ''
                                    };

                                    const headers = { 'Content-Type': 'application/json' };
                                    if (tokenMeta && headerMeta) headers[headerMeta.content] = tokenMeta.content;

                                    const res = await fetch(window.location.origin + '/seller/products/' + id + '/ajax-update?storeId=' + encodeURIComponent('${storeId}'), {
                                        method: 'POST', headers: headers, body: JSON.stringify(payload)
                                    });
                                    const data = await res.json();
                                    if (data.ok) {
                                        if (window.iziToast) iziToast.success({ title: 'OK', message: data.message, position: 'topRight' });
                                        const modalEl = document.getElementById('productEditModal');
                                        const bs = bootstrap.Modal.getInstance(modalEl);
                                        bs?.hide();
                                        setTimeout(() => location.reload(), 700);
                                    } else {
                                        if (window.iziToast) iziToast.error({ title: 'Lỗi', message: data.message || 'Lỗi', position: 'topRight' });
                                        else alert(data.message || 'Lỗi');
                                    }
                                } catch (e) {
                                    console.error(e);
                                    if (window.iziToast) iziToast.error({ title: 'Lỗi', message: 'Không thể kết nối', position: 'topRight' });
                                    else alert('Không thể kết nối');
                                }
                            });

                            // Click handler cho nút "Nhập sản phẩm" - điều hướng đến trang import
                            document.getElementById('btnImportProductModal')?.addEventListener('click', function () {
                                const pid = this.dataset.productId;
                                if (pid) {
                                    window.location.href = window.location.origin + '/seller/import/' + pid;
                                } else {
                                    if (window.iziToast) {
                                        iziToast.warning({
                                            title: 'Cảnh báo',
                                            message: 'Không tìm thấy ID sản phẩm',
                                            position: 'topRight'
                                        });
                                    } else {
                                        alert('Không tìm thấy ID sản phẩm');
                                    }
                                }
                            });
                        })();
                    </script>

                    <!-- Toast (global) -->
                    <c:if test="${not empty successMessage}">
                        <script>iziToast.success({ title: 'Success!', message: '${successMessage}', position: 'topRight', timeout: 5000 });</script>
                    </c:if>
                    <c:if test="${not empty errorMessage}">
                        <script>iziToast.error({ title: 'Error!', message: '${errorMessage}', position: 'topRight', timeout: 5000 });</script>
                    </c:if>

                    <!-- Validate filter + chống double submit -->
                    <script>
                        (function () {
                            const form = document.getElementById('filterForm');
                            if (!form) return;

                            const qInput = form.querySelector('input[name="q"]');
                            const fromIn = form.querySelector('input[name="fromDate"]');
                            const toIn = form.querySelector('input[name="toDate"]');

                            function vKeyword() {
                                if (!qInput) return true;
                                const raw = qInput.value || ''; const v = raw.trim();
                                if (raw.length && v.length === 0) { qInput.setCustomValidity('only-spaces'); return false; }
                                if (v.length > 100) { qInput.setCustomValidity('too-long'); return false; }
                                qInput.setCustomValidity(''); return true;
                            }
                            function iso(d) { return d ? new Date(d + 'T00:00:00') : null; }




                            function vIdRange() {
                                const fromEl = form.querySelector('[name="idFrom"]');
                                const toEl = form.querySelector('[name="idTo"]');
                                const fromVal = fromEl && fromEl.value !== '' ? Number(fromEl.value) : null;
                                const toVal = toEl && toEl.value !== '' ? Number(toEl.value) : null;
                                if (fromVal != null && isNaN(fromVal)) { fromEl.setCustomValidity('invalid'); return false; }
                                if (toVal != null && isNaN(toVal)) { toEl.setCustomValidity('invalid'); return false; }
                                if (fromVal != null && toVal != null && toVal < fromVal) { toEl.setCustomValidity('end-before-start'); return false; }
                                fromEl && fromEl.setCustomValidity(''); toEl && toEl.setCustomValidity(''); return true;
                            }

                            qInput?.addEventListener('input', vKeyword);
                            fromIn?.addEventListener('change', vDateRange);
                            toIn?.addEventListener('change', vDateRange);

                            form.addEventListener('submit', function (e) {
                                const ok = vKeyword() & vDateRange() & vPriceRange() & vIdRange();
                                if (!form.checkValidity() || !ok) { e.preventDefault(); e.stopPropagation(); }
                                form.classList.add('was-validated');
                            });

                            // chống double submit cho form POST (toggle/delete)
                            document.querySelectorAll('form.d-inline[method="post"]').forEach(f => {
                                f.addEventListener('submit', function (evt) {
                                    const to = f.dataset.toggleTo;
                                    const stockRaw = f.dataset.stock;
                                    const stock = stockRaw == null || stockRaw === '' ? null : Number(stockRaw);
                                    if (to === 'ACTIVE') {
                                        if (stock == null || isNaN(stock) || stock <= 0) {
                                            evt.preventDefault(); evt.stopPropagation();
                                            if (window.iziToast) {
                                                iziToast.error({ title: 'Lỗi', message: 'Vui lòng nhập hàng', position: 'topRight', timeout: 5000 });
                                            } else { alert('Vui lòng nhập hàng'); }
                                            return;
                                        }
                                    }
                                    const btn = f.querySelector('button[type="submit"],button:not([type])');
                                    if (btn) {
                                        btn.disabled = true; const t = btn.innerHTML; btn.dataset.t = t; btn.innerHTML = 'Đang xử lý...';
                                        setTimeout(() => { btn.disabled = false; btn.innerHTML = btn.dataset.t; }, 3000);
                                    }
                                });
                            });
                        })();
                    </script>

                    <!-- Table features: sort + resize -->
                    <script>
                        (function initTableFeatures() {
                            const table = document.getElementById('resizableTable'); if (!table) return;

                            // Sorting
                            const headers = table.querySelectorAll('th.sortable');
                            headers.forEach((header, idx) => {
                                header.addEventListener('click', function (e) {
                                    if (e.target.classList.contains('resizer')) return;
                                    const tbody = table.querySelector('tbody');
                                    const rows = Array.from(tbody.querySelectorAll('tr'));
                                    const isAsc = !header.classList.contains('sort-asc');
                                    headers.forEach(h => h.classList.remove('sort-asc', 'sort-desc'));
                                    header.classList.add(isAsc ? 'sort-asc' : 'sort-desc');

                                    const type = header.dataset.type || 'text';
                                    const getVal = (row) => (row.cells[idx]?.textContent || '').trim();

                                    rows.sort((a, b) => {
                                        let A = getVal(a), B = getVal(b);
                                        if (type === 'number') { A = Number(A.replace(/[^\d.-]/g, '')) || 0; B = Number(B.replace(/[^\d.-]/g, '')) || 0; }
                                        else if (type === 'date') { A = new Date(A).getTime() || 0; B = new Date(B).getTime() || 0; }
                                        else { A = A.toLowerCase(); B = B.toLowerCase(); }
                                        return isAsc ? (A > B ? 1 : (A < B ? -1 : 0)) : (A < B ? 1 : (A > B ? -1 : 0));
                                    });
                                    rows.forEach(r => tbody.appendChild(r));
                                });
                            });

                            // Resizing
                            const resizers = table.querySelectorAll('.resizer');
                            resizers.forEach(resizer => {
                                resizer.addEventListener('mousedown', function (e) {
                                    e.preventDefault();
                                    const th = resizer.parentElement;
                                    const startX = e.clientX; const startW = th.offsetWidth;
                                    resizer.classList.add('resizing');
                                    function onMove(ev) { th.style.width = Math.max(60, startW + ev.clientX - startX) + 'px'; }
                                    function onUp() { resizer.classList.remove('resizing'); document.removeEventListener('mousemove', onMove); document.removeEventListener('mouseup', onUp); }
                                    document.addEventListener('mousemove', onMove);
                                    document.addEventListener('mouseup', onUp);
                                });
                            });
                        })();

                        // Thumbnail fallback handler used by seller/products list
                        function handleThumbError(img) {
                            try {
                                if (!img) return;
                                var tried = img.getAttribute('data-tried') || '0';
                                tried = parseInt(tried);
                                if (tried >= 1) {
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