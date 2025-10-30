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
                        <c:choose>
                            <c:when test="${parentCategory == null}">Quản lý danh mục (CHA)</c:when>
                            <c:otherwise>Danh mục con của: ${parentCategory.name}</c:otherwise>
                        </c:choose> - MMO Market System
                    </title>

                    <jsp:include page="/WEB-INF/view/common/head.jsp" />
                    <!-- CSS dành riêng cho bảng với sort/resize -->
                    <link rel="stylesheet" href="<c:url value='/resources/css/products.css'/>">
                    <meta name="_csrf_header" content="${_csrf.headerName}" />
                    <meta name="_csrf" content="${_csrf.token}" />






                </head>

                <body class="has-fixed-navbar">
                    <jsp:include page="/WEB-INF/view/common/navbar.jsp" />
                    <jsp:include page="/WEB-INF/view/common/sidebar.jsp" />

                    <div id="pageContainer" class="container mt-5 mb-5">
                        <!-- Tiêu đề + Add Button -->
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <h4>
                                <c:choose>
                                    <c:when test="${parentCategory == null}">Quản lý danh mục (CHA)</c:when>
                                    <c:otherwise>
                                        Danh mục con của: <strong>
                                            <c:out value="${parentCategory.name}" />
                                        </strong>
                                    </c:otherwise>
                                </c:choose>
                            </h4>

                            <c:choose>
                                <c:when test="${parentCategory == null}">
                                    <a class="btn btn-primary" href="<c:url value='/admin/categories/add'/>">+ Tạo
                                        danh
                                        mục</a>
                                </c:when>
                                <c:otherwise>
                                    <a class="btn btn-primary"
                                        href="<c:url value='/admin/categories/${parentCategory.id}/subcategories/add'/>">+
                                        Thêm danh mục con</a>
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <!-- Flash Messages -->
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

                        <!-- Filter Form -->
                        <form id="filterForm" method="get" action="" class="row g-2 mb-3 needs-validation" novalidate>
                            <div class="col-md-6">
                                <input class="form-control" name="q" value="${fn:escapeXml(param.q)}"
                                    placeholder="Tìm theo tên danh mục..." maxlength="100" />
                                <div class="form-text">Tối đa 100 ký tự.</div>
                                <div class="invalid-feedback">Từ khoá quá dài hoặc chỉ chứa khoảng trắng.</div>
                            </div>
                            <div class="col-md-3">
                                <select class="form-select" name="active">
                                    <option value="">-- Tất cả trạng thái --</option>
                                    <option value="true" <c:if test="${param.active=='true'}">selected</c:if>>Active
                                    </option>
                                    <option value="false" <c:if test="${param.active=='false'}">selected</c:if>
                                        >Inactive
                                    </option>
                                </select>
                            </div>
                            <div class="col-md-3 d-flex align-items-start gap-2">
                                <button class="btn btn-primary" type="submit">Lọc</button>
                                <c:choose>
                                    <c:when test="${parentCategory == null}">
                                        <c:url var="clearUrl" value="/admin/categories" />
                                    </c:when>
                                    <c:otherwise>
                                        <c:url var="clearUrl"
                                            value="/admin/categories/${parentCategory.id}/subcategories" />
                                    </c:otherwise>
                                </c:choose>
                                <a class="btn btn-outline-secondary" href="${clearUrl}">Bỏ lọc</a>
                            </div>
                        </form>

                        <!-- Table -->
                        <div class="card p-4">
                            <div class="table-responsive">
                                <table class="resizable-table table table-hover align-middle" id="resizableTable">
                                    <thead class="table-light">
                                        <tr>
                                            <th class="sortable" style="width:80px" data-column="0" data-type="number">
                                                ID<div class="resizer"></div>
                                            </th>
                                            <th class="sortable" style="width:300px" data-column="1" data-type="text">
                                                Tên danh mục<div class="resizer"></div>
                                            </th>
                                            <th class="sortable" style="width:360px" data-column="2" data-type="text">
                                                Mô tả<div class="resizer"></div>
                                            </th>
                                            <th class="sortable" style="width:140px" data-column="3" data-type="text">
                                                Trạng thái<div class="resizer"></div>
                                            </th>
                                            <th style="width:280px">Hành động</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:if test="${empty categories}">
                                            <tr>
                                                <td colspan="5" class="text-center text-muted py-4">Không có danh
                                                    mục
                                                    nào khớp bộ lọc.</td>
                                            </tr>
                                        </c:if>

                                        <c:forEach var="c" items="${categories}">
                                            <tr>
                                                <td>#${c.id}</td>
                                                <td>
                                                    <c:out value="${c.name}" />
                                                </td>
                                                <td>
                                                    <c:out value="${c.description}" />
                                                </td>
                                                <td>
                                                    <span class="badge ${!c.isDeleted ? 'bg-success' : 'bg-secondary'}">
                                                        ${!c.isDeleted ? 'ACTIVE' : 'INACTIVE'}
                                                    </span>
                                                </td>
                                                <td class="text-end">
                                                    <div class="actions">
                                                        <%-- XANH DƯƠNG: Chi tiết --%>
                                                            <c:choose>
                                                                <%-- Trang CHA: đi tới bảng CON --%>
                                                                    <c:when test="${parentCategory == null}">
                                                                        <a class="btn-chip chip-info"
                                                                            title="Xem danh mục con"
                                                                            href="<c:url value='/admin/categories/${c.id}/subcategories'/>">
                                                                            <i class="bi bi-diagram-3"></i><span>Chi
                                                                                tiết</span>
                                                                        </a>
                                                                    </c:when>

                                                                    <%-- Trang CON: mở modal chi tiết --%>
                                                                        <c:otherwise>
                                                                            <button type="button"
                                                                                class="btn-chip chip-info"
                                                                                title="Chi tiết" data-bs-toggle="modal"
                                                                                data-bs-target="#categoryDetailModal"
                                                                                data-id="${c.id}"
                                                                                data-name="${fn:escapeXml(c.name)}"
                                                                                data-description="${fn:escapeXml(c.description)}"
                                                                                data-status="${!c.isDeleted ? 'ACTIVE' : 'INACTIVE'}"
                                                                                data-parent="${fn:escapeXml(parentCategory.name)}">
                                                                                <i class="bi bi-info-circle"></i><span>Chi
                                                                                    tiết</span>
                                                                            </button>
                                                                        </c:otherwise>
                                                            </c:choose>

                                                            <%-- VÀNG: Sửa --%>
                                                                <button type="button" class="btn-chip chip-edit"
                                                                    title="Chỉnh sửa" data-bs-toggle="modal"
                                                                    data-bs-target="#categoryEditModal"
                                                                    data-edit-url="<c:url value='/admin/categories/edit/${c.id}'/>"
                                                                    data-id="${c.id}"
                                                                    data-name="${fn:escapeXml(c.name)}"
                                                                    data-description="${fn:escapeXml(c.description)}"
                                                                    data-status="${!c.isDeleted ? 'ACTIVE' : 'INACTIVE'}">
                                                                    <i class="bi bi-pencil-square"></i><span>Sửa</span>
                                                                </button>

                                                                <%-- CAM/XANH LÁ: TẮT hoặc BẬT --%>
                                                                    <c:choose>
                                                                        <%-- ĐANG ACTIVE: cho phép TẮT --%>
                                                                            <c:when test="${!c.isDeleted}">
                                                                                <form method="post"
                                                                                    action="<c:url value='/admin/categories/toggle/${c.id}'/>"
                                                                                    class="d-inline">
                                                                                    <input type="hidden"
                                                                                        name="${_csrf.parameterName}"
                                                                                        value="${_csrf.token}" />
                                                                                    <button type="submit"
                                                                                        class="btn-chip chip-toggle"
                                                                                        title="Tắt (đưa về INACTIVE)">
                                                                                        <i
                                                                                            class="bi bi-power"></i><span>Tắt</span>
                                                                                    </button>
                                                                                </form>
                                                                            </c:when>

                                                                            <%-- ĐANG INACTIVE: cho phép BẬT --%>
                                                                                <c:otherwise>
                                                                                    <form method="post"
                                                                                        action="<c:url value='/admin/categories/toggle/${c.id}'/>"
                                                                                        class="d-inline">
                                                                                        <input type="hidden"
                                                                                            name="${_csrf.parameterName}"
                                                                                            value="${_csrf.token}" />
                                                                                        <button type="submit"
                                                                                            class="btn-chip chip-on"
                                                                                            title="Bật (đưa về ACTIVE)">
                                                                                            <i
                                                                                                class="bi bi-power"></i><span>Bật</span>
                                                                                        </button>
                                                                                    </form>
                                                                                </c:otherwise>
                                                                    </c:choose>

                                                                    <%-- KHÔNG có nút XÓA --%>
                                                    </div>
                                                </td>


                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </div>

                        <!-- Pagination -->
                        <c:if test="${totalPages != null && totalPages > 1}">
                            <c:choose>
                                <c:when test="${parentCategory == null}">
                                    <c:set var="baseUrl" value="/admin/categories" />
                                </c:when>
                                <c:otherwise>
                                    <c:set var="baseUrl" value="/admin/categories/${parentCategory.id}/subcategories" />
                                </c:otherwise>
                            </c:choose>

                            <div class="pagination-container">
                                <nav>
                                    <ul class="pagination justify-content-center">
                                        <c:if test="${currentPage > 1}">
                                            <li class="page-item">
                                                <a class="page-link"
                                                    href="${pageContext.request.contextPath}${baseUrl}?page=1&size=${pageSize}">&laquo;</a>
                                            </li>
                                            <li class="page-item">
                                                <a class="page-link"
                                                    href="${pageContext.request.contextPath}${baseUrl}?page=${currentPage-1}&size=${pageSize}">&lsaquo;</a>
                                            </li>
                                        </c:if>

                                        <c:set var="start" value="${currentPage-2 < 1 ? 1 : currentPage-2}" />
                                        <c:set var="end"
                                            value="${currentPage+2 > totalPages ? totalPages : currentPage+2}" />
                                        <c:forEach begin="${start}" end="${end}" var="p">
                                            <li class="page-item ${p == currentPage ? 'active' : ''}">
                                                <a class="page-link"
                                                    href="${pageContext.request.contextPath}${baseUrl}?page=${p}&size=${pageSize}">${p}</a>
                                            </li>
                                        </c:forEach>

                                        <c:if test="${currentPage < totalPages}">
                                            <li class="page-item">
                                                <a class="page-link"
                                                    href="${pageContext.request.contextPath}${baseUrl}?page=${currentPage+1}&size=${pageSize}">&rsaquo;</a>
                                            </li>
                                            <li class="page-item">
                                                <a class="page-link"
                                                    href="${pageContext.request.contextPath}${baseUrl}?page=${totalPages}&size=${pageSize}">&raquo;</a>
                                            </li>
                                        </c:if>
                                    </ul>
                                </nav>
                            </div>
                        </c:if>
                    </div>

                    <jsp:include page="/WEB-INF/view/common/footer.jsp" />

                    <!-- ====== MODALS ====== -->

                    <!-- DETAIL MODAL -->
                    <div class="modal fade" id="categoryDetailModal" tabindex="-1" aria-labelledby="categoryDetailLabel"
                        aria-hidden="true">
                        <div class="modal-dialog modal-lg modal-dialog-centered">
                            <div class="modal-content">
                                <div class="modal-header bg-info text-white">
                                    <h5 class="modal-title" id="categoryDetailLabel">
                                        <i class="bi bi-info-circle-fill"></i> Chi tiết danh mục
                                    </h5>
                                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"
                                        aria-label="Close"></button>
                                </div>
                                <div class="modal-body">
                                    <div class="container-fluid">
                                        <div class="row mb-3">
                                            <div class="col-md-8">
                                                <div class="detail-item">
                                                    <label class="detail-label">Tên danh mục:</label>
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
                                            <div class="col-md-8">
                                                <div class="detail-item">
                                                    <label class="detail-label">Mô tả:</label>
                                                    <div class="detail-value" id="d-description"></div>
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
                                            <div class="col-md-12">
                                                <div class="detail-item">
                                                    <label class="detail-label">Danh mục cha:</label>
                                                    <div class="detail-value" id="d-parent"></div>
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
                    <div class="modal fade" id="categoryEditModal" tabindex="-1" aria-labelledby="categoryEditLabel"
                        aria-hidden="true">
                        <div class="modal-dialog modal-lg modal-dialog-centered">
                            <div class="modal-content">
                                <div class="modal-header bg-warning text-dark">
                                    <h5 class="modal-title" id="categoryEditLabel">
                                        <i class="bi bi-pencil-fill"></i> Chỉnh sửa danh mục
                                    </h5>
                                    <button type="button" class="btn-close" data-bs-dismiss="modal"
                                        aria-label="Close"></button>
                                </div>
                                <div class="modal-body">
                                    <form id="editForm">
                                        <input type="hidden" id="e-id">
                                        <div class="row mb-3">
                                            <div class="col-md-12">
                                                <label class="form-label">Tên danh mục</label>
                                                <input type="text" class="form-control" id="e-name" required>
                                            </div>
                                        </div>
                                        <div class="row mb-3">
                                            <div class="col-md-12">
                                                <label class="form-label">Mô tả</label>
                                                <textarea class="form-control" id="e-description" rows="3"></textarea>
                                            </div>
                                        </div>
                                        <div class="row mb-3">
                                            <div class="col-md-6">
                                                <label class="form-label">Trạng thái</label>
                                                <input type="text" class="form-control" id="e-status" disabled>
                                            </div>
                                        </div>
                                    </form>
                                    <small class="text-muted">* Modal này chỉ preview. Click "Tới trang chỉnh sửa" để
                                        chỉnh sửa thật.</small>
                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                                        <i class="bi bi-x-circle"></i> Hủy
                                    </button>
                                    <button type="button" class="btn btn-warning" id="goEditPageBtn">
                                        <i class="bi bi-check-circle"></i> Tới trang chỉnh sửa
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Toast notifications -->
                    <c:if test="${not empty successMessage}">
                        <script>
                            if (window.iziToast) {
                                iziToast.success({ title: 'Success!', message: '${successMessage}', position: 'topRight', timeout: 5000 });
                            }
                        </script>
                    </c:if>
                    <c:if test="${not empty errorMessage}">
                        <script>
                            if (window.iziToast) {
                                iziToast.error({ title: 'Error!', message: '${errorMessage}', position: 'topRight', timeout: 5000 });
                            }
                        </script>
                    </c:if>

                    <!-- Form validation + Double submit prevention -->
                    <script>
                        (function () {
                            const form = document.getElementById('filterForm');
                            if (!form) return;
                            const qInput = form.querySelector('input[name="q"]');

                            function validateKeyword() {
                                if (!qInput) return true;
                                const raw = qInput.value || '';
                                const v = raw.trim();
                                if (raw.length && v.length === 0) {
                                    qInput.setCustomValidity('only-spaces');
                                    return false;
                                }
                                if (v.length > 100) {
                                    qInput.setCustomValidity('too-long');
                                    return false;
                                }
                                qInput.setCustomValidity('');
                                return true;
                            }

                            qInput?.addEventListener('input', validateKeyword);

                            form.addEventListener('submit', function (e) {
                                const ok = validateKeyword();
                                if (!form.checkValidity() || !ok) {
                                    e.preventDefault();
                                    e.stopPropagation();
                                }
                                form.classList.add('was-validated');
                            });

                            // Double submit prevention for all forms
                            document.querySelectorAll('form.d-inline[method="post"]').forEach(f => {
                                f.addEventListener('submit', function () {
                                    const btn = f.querySelector('button[type="submit"],button:not([type])');
                                    if (btn) {
                                        btn.disabled = true;
                                        const t = btn.innerHTML;
                                        btn.dataset.t = t;
                                        btn.innerHTML = 'Đang xử lý...';
                                        setTimeout(() => {
                                            btn.disabled = false;
                                            btn.innerHTML = btn.dataset.t;
                                        }, 3000);
                                    }
                                });
                            });
                        })();
                    </script>

                    <!-- Table features: sort + resize -->
                    <script>
                        (function initTableFeatures() {
                            const table = document.getElementById('resizableTable');
                            if (!table) return;

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
                                        if (type === 'number') {
                                            A = Number(A.replace(/[^\d.-]/g, '')) || 0;
                                            B = Number(B.replace(/[^\d.-]/g, '')) || 0;
                                        } else if (type === 'date') {
                                            A = new Date(A).getTime() || 0;
                                            B = new Date(B).getTime() || 0;
                                        } else {
                                            A = A.toLowerCase();
                                            B = B.toLowerCase();
                                        }
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
                                    const startX = e.clientX;
                                    const startW = th.offsetWidth;
                                    resizer.classList.add('resizing');

                                    function onMove(ev) {
                                        th.style.width = Math.max(60, startW + ev.clientX - startX) + 'px';
                                    }

                                    function onUp() {
                                        resizer.classList.remove('resizing');
                                        document.removeEventListener('mousemove', onMove);
                                        document.removeEventListener('mouseup', onUp);
                                    }

                                    document.addEventListener('mousemove', onMove);
                                    document.addEventListener('mouseup', onUp);
                                });
                            });
                        })();
                    </script>

                    <!-- Modal data population -->
                    <script>
                        (function () {
                            // Detail modal
                            const detailModal = document.getElementById('categoryDetailModal');
                            detailModal?.addEventListener('show.bs.modal', function (event) {
                                const btn = event.relatedTarget;
                                if (!btn) return;
                                const get = (name) => btn.getAttribute('data-' + name) || '';

                                document.getElementById('d-id').textContent = '#' + get('id');
                                document.getElementById('d-name').textContent = get('name');
                                document.getElementById('d-description').textContent = get('description') || '(Không có mô tả)';
                                document.getElementById('d-status').textContent = get('status');
                                document.getElementById('d-parent').textContent = get('parent');
                            });

                            // Edit modal
                            const editModal = document.getElementById('categoryEditModal');
                            let editUrl = null;
                            editModal?.addEventListener('show.bs.modal', function (event) {
                                const btn = event.relatedTarget;
                                if (!btn) return;
                                const get = (name) => btn.getAttribute('data-' + name) || '';

                                editUrl = get('edit-url');
                                document.getElementById('e-id').value = get('id');
                                document.getElementById('e-name').value = get('name');
                                document.getElementById('e-description').value = get('description');
                                document.getElementById('e-status').value = get('status');
                            });

                            // Go to edit page button
                            document.getElementById('goEditPageBtn')?.addEventListener('click', function () {
                                if (editUrl) window.location.href = editUrl;
                            });
                        })();
                    </script>

                    <!-- ADD: Modal hiển thị danh mục con -->
                    <div class="modal fade" id="childrenModal" tabindex="-1" aria-hidden="true">
                        <div class="modal-dialog modal-xl modal-dialog-centered">
                            <div class="modal-content">
                                <div class="modal-header bg-info text-white">
                                    <h5 class="modal-title">
                                        <i class="bi bi-diagram-3"></i> Danh mục con của:
                                        <span id="childrenModalTitle"></span>
                                    </h5>
                                    <button type="button" class="btn-close btn-close-white"
                                        data-bs-dismiss="modal"></button>
                                </div>
                                <div class="modal-body" id="childrenModalBody">
                                    <!-- Bảng con sẽ được load qua AJAX -->
                                    <div class="text-muted">Đang tải...</div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <script>
                        function openChildrenModal(parentId, parentName) {
                            document.getElementById('childrenModalTitle').textContent = parentName;
                            const body = document.getElementById('childrenModalBody');
                            body.innerHTML = '<div class="text-muted">Đang tải...</div>';
                            const url = `${window.location.origin}${'${pageContext.request.contextPath}'}`
                                + `/admin/categories/${parentId}/subcategories/fragment?page=1&size=10`;
                            fetch(url, { headers: { 'X-Requested-With': 'XMLHttpRequest' } })
                                .then(r => r.text()).then(html => {
                                    body.innerHTML = html;
                                }).catch(() => {
                                    body.innerHTML = '<div class="text-danger">Không tải được dữ liệu.</div>';
                                });

                            const modal = new bootstrap.Modal(document.getElementById('childrenModal'));
                            modal.show();
                        }
                    </script>



                    <script>
                        // Sidebar toggle: keep state in localStorage 'sb-open' but also update
                        // the actual sidebar element (.sidebar.active) and overlay (.sidebar-overlay.active).
                        (function () {
                            const btn =
                                document.getElementById('sidebarToggleBtn') ||
                                document.querySelector('[data-sidebar-toggle]') ||
                                document.querySelector('.navbar .btn.sidebar-toggle') ||
                                (document.querySelector('.navbar .bi-list') ? document.querySelector('.navbar .bi-list').closest('button') : null);

                            const sidebar = document.querySelector('.sidebar');
                            const OVERLAY_ID = 'sidebarOverlay';

                            function ensureOverlay() {
                                let o = document.getElementById(OVERLAY_ID);
                                if (!o) {
                                    o = document.createElement('div');
                                    o.id = OVERLAY_ID;
                                    o.className = 'sidebar-overlay';
                                    o.setAttribute('role', 'button');
                                    o.tabIndex = 0;
                                    o.onclick = toggleSidebar;
                                    o.onkeypress = function (e) { if (e.key === 'Enter') toggleSidebar(); };
                                    document.body.appendChild(o);
                                }
                                return o;
                            }

                            function syncState(open) {
                                if (open) {
                                    document.body.classList.add('sidebar-open');
                                    sidebar?.classList.add('active');
                                    const ov = ensureOverlay();
                                    ov.classList.add('active');
                                } else {
                                    document.body.classList.remove('sidebar-open');
                                    sidebar?.classList.remove('active');
                                    const ov = document.getElementById(OVERLAY_ID);
                                    if (ov) ov.classList.remove('active');
                                }
                            }

                            // Restore saved state
                            try {
                                const v = localStorage.getItem('sb-open');
                                syncState(v === '1');
                            } catch (e) { }

                            if (btn) {
                                btn.addEventListener('click', function (e) {
                                    e.preventDefault();
                                    const nowOpen = !document.body.classList.contains('sidebar-open');
                                    syncState(nowOpen);
                                    try { localStorage.setItem('sb-open', nowOpen ? '1' : '0'); } catch (e) { }
                                });
                            }
                        })();

                        // Compatibility: global function used by navbar inline onclicks
                        function toggleSidebar() {
                            try {
                                const sidebar = document.querySelector('.sidebar');
                                const OVERLAY_ID = 'sidebarOverlay';
                                const isOpen = !document.body.classList.contains('sidebar-open');
                                if (isOpen) {
                                    document.body.classList.add('sidebar-open');
                                    sidebar?.classList.add('active');
                                    let ov = document.getElementById(OVERLAY_ID);
                                    if (!ov) {
                                        ov = document.createElement('div');
                                        ov.id = OVERLAY_ID;
                                        ov.className = 'sidebar-overlay';
                                        ov.setAttribute('role', 'button');
                                        ov.tabIndex = 0;
                                        ov.onclick = toggleSidebar;
                                        ov.onkeypress = function (e) { if (e.key === 'Enter') toggleSidebar(); };
                                        document.body.appendChild(ov);
                                    }
                                    ov.classList.add('active');
                                } else {
                                    document.body.classList.remove('sidebar-open');
                                    sidebar?.classList.remove('active');
                                    const ov = document.getElementById(OVERLAY_ID);
                                    if (ov) ov.classList.remove('active');
                                }
                                try { localStorage.setItem('sb-open', isOpen ? '1' : '0'); } catch (e) { }
                            } catch (err) {
                                console.error('toggleSidebar error:', err);
                            }
                        }
                    </script>



                </body>

                </html>