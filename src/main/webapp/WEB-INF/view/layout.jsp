<%@ page contentType="text/html; charset=UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

                <!DOCTYPE html>
                <html lang="vi">

                <head>
                    <meta charset="UTF-8">
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

                    <div class="container mt-4">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <h4>Danh sách sản phẩm</h4>
                            <c:url var="newUrl" value="/seller/products/new">
                                <c:param name="storeId" value="${storeId}" />
                            </c:url>
                            <a class="btn btn-primary" href="${newUrl}">Thêm sản phẩm</a>
                        </div>

                        <!-- Flash -->
                        <c:if test="${not empty success}">
                            <div class="alert alert-success alert-dismissible fade show" role="alert">
                                ${success}
                                <button type="button" class="btn-close" data-bs-dismiss="alert"
                                    aria-label="Close"></button>
                            </div>
                        </c:if>
                        <c:if test="${not empty error}">
                            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                                ${error}
                                <button type="button" class="btn-close" data-bs-dismiss="alert"
                                    aria-label="Close"></button>
                            </div>
                        </c:if>

                        <!-- FILTER -->
                        <form id="filterForm" class="row g-2 mb-3 needs-validation" method="get"
                            action="<c:url value='/seller/products'/>" novalidate>
                            <input type="hidden" name="storeId" value="${storeId}" />
                            <input type="hidden" name="size" value="${page.size}" />

                            <div class="col-md-3">
                                <input class="form-control" name="q" value="${fn:escapeXml(q)}"
                                    placeholder="Từ khoá tên/slug..." maxlength="100" aria-describedby="qHelp" />
                                <div id="qHelp" class="form-text">Tối đa 100 ký tự.</div>
                                <div class="invalid-feedback">Từ khoá quá dài hoặc không hợp lệ.</div>
                            </div>

                            <div class="col-md-2">
                                <select class="form-select" name="status" aria-label="Trạng thái">
                                    <option value="">-- Trạng thái --</option>
                                    <c:forEach var="st" items="${ProductStatus}">
                                        <option value="${st}" <c:if test="${status == st}">selected</c:if>>${st}
                                        </option>
                                    </c:forEach>
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

                            <!-- Price range -->
                            <div class="col-md-2">
                                <input type="number" class="form-control" name="minPrice" value="${minPrice}"
                                    step="0.01" min="0" placeholder="Giá từ (₫)" />
                                <div class="form-text">Lọc theo giá: từ</div>
                            </div>
                            <div class="col-md-2">
                                <input type="number" class="form-control" name="maxPrice" value="${maxPrice}"
                                    step="0.01" min="0" placeholder="Giá đến (₫)" />
                                <div class="form-text">Lọc theo giá: đến</div>
                            </div>

                            <!-- ID range -->
                            <div class="col-md-2">
                                <input type="number" class="form-control" name="idFrom" value="${idFrom}" min="1"
                                    placeholder="ID từ" />
                                <div class="form-text">Lọc theo ID: từ</div>
                            </div>
                            <div class="col-md-2">
                                <input type="number" class="form-control" name="idTo" value="${idTo}" min="1"
                                    placeholder="ID đến" />
                                <div class="form-text">Lọc theo ID: đến</div>
                            </div>

                            <div class="col-md-2">
                                <button class="btn btn-outline-secondary w-100" type="submit">Lọc</button>
                            </div>
                        </form>

                        <!-- TABLE -->
                        <div class="table-container">
                            <table class="resizable-table table align-middle" id="resizableTable">
                                <thead>
                                    <tr>
                                        <th class="sortable" style="width:90px;" data-column="0" data-type="number">ID
                                            <div class="resizer"></div>
                                        </th>
                                        <th class="sortable" style="width:320px;" data-column="1" data-type="text">Tên
                                            sản phẩm<div class="resizer"></div>
                                        </th>
                                        <th class="sortable" style="width:180px;" data-column="2" data-type="text">Danh
                                            mục<div class="resizer"></div>
                                        </th>
                                        <th class="sortable" style="width:140px;" data-column="3" data-type="number">Giá
                                            bán<div class="resizer"></div>
                                        </th>
                                        <th class="sortable" style="width:140px;" data-column="4" data-type="text">Trạng
                                            thái<div class="resizer"></div>
                                        </th>
                                        <th class="sortable" style="width:160px;" data-column="5" data-type="number">Tồn
                                            mã khả dụng<div class="resizer"></div>
                                        </th>
                                        <th style="width:240px;">Hành động</th>
                                    </tr>
                                </thead>

                                <tbody>
                                    <c:if test="${empty page.content}">
                                        <tr>
                                            <td colspan="7" class="text-center text-muted py-4">Không có sản phẩm nào
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
                                                            <img src="${p.productUrl}" alt="img"
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

                                                <!-- Toggle giữ nguyên -->
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
                                                            <button class="btn btn-sm btn-outline-warning">Tắt</button>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <c:choose>
                                                                <c:when test="${p.stock != null && p.stock > 0}">
                                                                    <button
                                                                        class="btn btn-sm btn-outline-success">Bật</button>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <button class="btn btn-sm btn-outline-success"
                                                                        disabled title="Vui lòng nhập hàng">Bật</button>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </form>

                                                <!-- Chi tiết: mở modal -->
                                                <button type="button" class="btn-icon btn-action-info" title="Chi tiết"
                                                    data-bs-toggle="modal" data-bs-target="#productDetailModal"
                                                    data-id="${p.id}" data-name="${fn:escapeXml(p.name)}"
                                                    data-slug="${fn:escapeXml(p.slug)}"
                                                    data-category="${p.category != null ? fn:escapeXml(p.category.name) : '-'}"
                                                    data-price="<fmt:formatNumber value='${p.price}'/>"
                                                    data-status="${p.status}" data-stock="${p.stock}"
                                                    data-img="${p.productUrl}">
                                                    <i class="bi bi-info-circle"></i>
                                                </button>

                                                <!-- Sửa: mở modal -->
                                                <button type="button" class="btn-icon btn-action-edit" title="Chỉnh sửa"
                                                    data-bs-toggle="modal" data-bs-target="#productEditModal"
                                                    data-edit-url="<c:url value='/seller/products/${p.id}/edit'><c:param name='storeId' value='${storeId}'/></c:url>"
                                                    data-id="${p.id}" data-name="${fn:escapeXml(p.name)}"
                                                    data-slug="${fn:escapeXml(p.slug)}"
                                                    data-category="${p.category != null ? fn:escapeXml(p.category.name) : '-'}"
                                                    data-price="${p.price}" data-status="${p.status}"
                                                    data-stock="${p.stock}">
                                                    <i class="bi bi-pencil-square"></i>
                                                </button>

                                                <!-- Soft delete để sẵn nếu cần -->
                                                <c:url var="deleteUrl" value="/seller/products/${p.id}/delete">
                                                    <c:param name="storeId" value="${storeId}" />
                                                </c:url>
                                                <form class="d-inline" method="post" action="${deleteUrl}"
                                                    onsubmit="return confirm('Ẩn sản phẩm này?');">
                                                    <c:if test="${not empty _csrf}">
                                                        <input type="hidden" name="${_csrf.parameterName}"
                                                            value="${_csrf.token}" />
                                                    </c:if>
                                                    <!-- bạn có thể thêm nút xoá icon nếu muốn:
                            <button type="submit" class="btn-icon btn-action-delete" title="Xoá"><i class="bi bi-trash"></i></button>
                            -->
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

                    <jsp:include page="../common/footer.jsp" />

                    <!-- ====== MODALS giống layout ====== -->

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
                                                    <label class="detail-label">Tồn:</label>
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
                                    </div>
                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal"><i
                                            class="bi bi-x-circle"></i> Đóng</button>
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
                                    <form id="editForm">
                                        <input type="hidden" id="e-id">
                                        <div class="row mb-3">
                                            <div class="col-md-6">
                                                <label class="form-label">Tên sản phẩm</label>
                                                <input type="text" class="form-control" id="e-name" required>
                                            </div>
                                            <div class="col-md-6">
                                                <label class="form-label">Slug</label>
                                                <input type="text" class="form-control" id="e-slug" required>
                                            </div>
                                        </div>

                                        <div class="row mb-3">
                                            <div class="col-md-4">
                                                <label class="form-label">Giá bán (₫)</label>
                                                <input type="number" class="form-control" id="e-price" min="0"
                                                    step="0.01" required>
                                            </div>
                                            <div class="col-md-4">
                                                <label class="form-label">Tồn</label>
                                                <input type="number" class="form-control" id="e-stock" min="0">
                                            </div>
                                            <div class="col-md-4">
                                                <label class="form-label">Trạng thái</label>
                                                <select class="form-select" id="e-status">
                                                    <option value="ACTIVE">ACTIVE</option>
                                                    <option value="INACTIVE">INACTIVE</option>
                                                </select>
                                            </div>
                                        </div>

                                        <div class="mb-3">
                                            <label class="form-label">Danh mục</label>
                                            <input type="text" class="form-control" id="e-category" disabled>
                                        </div>
                                    </form>
                                    <small class="text-muted">* Nút “Cập nhật” dưới đây chỉ minh họa UI. Nếu bạn muốn
                                        chỉnh sửa thật, mình chuyển sang trang chỉnh sửa đầy đủ.</small>
                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal"><i
                                            class="bi bi-x-circle"></i> Hủy</button>
                                    <button type="button" class="btn btn-warning" id="goEditPageBtn"><i
                                            class="bi bi-check-circle"></i> Tới trang chỉnh sửa</button>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Toast -->
                    <c:if test="${not empty successMessage}">
                        <script>iziToast.success({ title: 'Success!', message: '${successMessage}', position: 'topRight', timeout: 5000 });</script>
                    </c:if>
                    <c:if test="${not empty errorMessage}">
                        <script>iziToast.error({ title: 'Error!', message: '${errorMessage}', position: 'topRight', timeout: 5000 });</script>
                    </c:if>

                    <!-- Validate filter + chống double submit -->
                    <script>
                        /* giữ nguyên đoạn validate như bạn đã có */
                        (function () {
                            const form = document.getElementById('filterForm');
                            if (!form) return;
                            const qInput = form.querySelector('input[name="q"]');
                            const fromIn = form.querySelector('input[name="fromDate"]');
                            const toIn = form.querySelector('input[name="toDate"]');
                            function vKeyword() { if (!qInput) return true; const raw = qInput.value || '', v = raw.trim(); if (raw.length && v.length === 0) { qInput.setCustomValidity('only-spaces'); return false; } if (v.length > 100) { qInput.setCustomValidity('too-long'); return false; } qInput.setCustomValidity(''); return true; }
                            function iso(d) { return d ? new Date(d + 'T00:00:00') : null; }
                            function vDateRange() { const f = fromIn?.value, t = toIn?.value; if (!f || !t) { fromIn?.setCustomValidity(''); toIn?.setCustomValidity(''); return true; } const fd = iso(f), td = iso(t); if (isNaN(fd) || isNaN(td)) { fromIn?.setCustomValidity(isNaN(fd) ? 'invalid' : ''); toIn?.setCustomValidity(isNaN(td) ? 'invalid' : ''); return false; } if (td < fd) { toIn.setCustomValidity('end-before-start'); return false; } fromIn.setCustomValidity(''); toIn.setCustomValidity(''); return true; }
                            function vPriceRange() { const minEl = form.querySelector('[name="minPrice"]'); const maxEl = form.querySelector('[name="maxPrice"]'); const minVal = minEl && minEl.value !== '' ? Number(minEl.value) : null; const maxVal = maxEl && maxEl.value !== '' ? Number(maxEl.value) : null; if (minVal != null && isNaN(minVal)) { minEl.setCustomValidity('invalid'); return false; } if (maxVal != null && isNaN(maxVal)) { maxEl.setCustomValidity('invalid'); return false; } if (minVal != null && maxVal != null && maxVal < minVal) { maxEl.setCustomValidity('max-less-than-min'); return false; } minEl && minEl.setCustomValidity(''); maxEl && maxEl.setCustomValidity(''); return true; }
                            function vIdRange() { const fromEl = form.querySelector('[name="idFrom"]'); const toEl = form.querySelector('[name="idTo"]'); const fromVal = fromEl && fromEl.value !== '' ? Number(fromEl.value) : null; const toVal = toEl && toEl.value !== '' ? Number(toEl.value) : null; if (fromVal != null && isNaN(fromVal)) { fromEl.setCustomValidity('invalid'); return false; } if (toVal != null && isNaN(toVal)) { toEl.setCustomValidity('invalid'); return false; } if (fromVal != null && toVal != null && toVal < fromVal) { toEl.setCustomValidity('end-before-start'); return false; } fromEl && fromEl.setCustomValidity(''); toEl && toEl.setCustomValidity(''); return true; }
                            qInput?.addEventListener('input', vKeyword);
                            fromIn?.addEventListener('change', vDateRange);
                            toIn?.addEventListener('change', vDateRange);
                            form.addEventListener('submit', function (e) { const ok = vKeyword() & vDateRange() & vPriceRange() & vIdRange(); if (!form.checkValidity() || !ok) { e.preventDefault(); e.stopPropagation(); } form.classList.add('was-validated'); });
                            document.querySelectorAll('form.d-inline[method="post"]').forEach(f => {
                                f.addEventListener('submit', function (evt) {
                                    const to = f.dataset.toggleTo; const stockRaw = f.dataset.stock; const stock = stockRaw == null || stockRaw === '' ? null : Number(stockRaw);
                                    if (to === 'ACTIVE') { if (stock == null || isNaN(stock) || stock <= 0) { evt.preventDefault(); evt.stopPropagation(); if (window.iziToast) { iziToast.error({ title: 'Lỗi', message: 'Vui lòng nhập hàng', position: 'topRight', timeout: 5000 }); } else { alert('Vui lòng nhập hàng'); } return; } }
                                    const btn = f.querySelector('button[type="submit"],button:not([type])'); if (btn) { btn.disabled = true; const t = btn.innerHTML; btn.dataset.t = t; btn.innerHTML = 'Đang xử lý...'; setTimeout(() => { btn.disabled = false; btn.innerHTML = btn.dataset.t; }, 3000); }
                                });
                            });
                        })();
                    </script>

                    <!-- Table features: sort + resize -->
                    <script>
                        (function initTableFeatures() {
                            const table = document.getElementById('resizableTable'); if (!table) return;
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
                    </script>

                    <!-- ==== JS đổ dữ liệu vào MODAL chi tiết & sửa ==== -->
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
                                document.getElementById('d-slug').textContent = get('slug');
                                document.getElementById('d-category').textContent = get('category');
                                document.getElementById('d-price').textContent = money(get('price')) + ' ₫';
                                document.getElementById('d-stock').textContent = get('stock');
                                document.getElementById('d-status').textContent = get('status');

                                const imgEl = document.getElementById('d-img');
                                const img = get('img');
                                if (img) { imgEl.src = img; imgEl.style.display = 'block'; }
                                else { imgEl.style.display = 'none'; }
                            });

                            // Edit modal
                            const editModal = document.getElementById('productEditModal');
                            let editUrl = null;
                            editModal?.addEventListener('show.bs.modal', function (event) {
                                const btn = event.relatedTarget;
                                if (!btn) return;
                                const get = (name) => btn.getAttribute('data-' + name) || '';

                                editUrl = get('edit-url');            // để điều hướng tới trang edit đầy đủ
                                document.getElementById('e-id').value = get('id');
                                document.getElementById('e-name').value = get('name');
                                document.getElementById('e-slug').value = get('slug');
                                document.getElementById('e-price').value = get('price');
                                document.getElementById('e-stock').value = get('stock');
                                document.getElementById('e-status').value = get('status') === 'ACTIVE' ? 'ACTIVE' : 'INACTIVE';
                                document.getElementById('e-category').value = get('category');
                            });

                            // Nút "Tới trang chỉnh sửa"
                            document.getElementById('goEditPageBtn')?.addEventListener('click', function () {
                                if (editUrl) window.location.href = editUrl;
                            });
                        })();
                    </script>

                </body>

                </html>