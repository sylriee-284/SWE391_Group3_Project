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
                            <c:when test="${category.id == null}">
                                ${category.parent == null ? 'Thêm danh mục CHA' : 'Thêm danh mục con'}
                            </c:when>
                            <c:otherwise>
                                ${category.parent == null ? 'Sửa danh mục CHA' : 'Sửa danh mục con'}
                            </c:otherwise>
                        </c:choose> - MMO Market System
                    </title>

                    <jsp:include page="/WEB-INF/view/common/head.jsp" />
                    <!-- CSS dành riêng cho form validation và bảng -->
                    <link rel="stylesheet" href="<c:url value='/resources/css/products.css'/>">
                    <meta name="_csrf_header" content="${_csrf.headerName}" />
                    <meta name="_csrf" content="${_csrf.token}" />

                    <style>
                        body.has-fixed-navbar {
                            padding-top: 56px;
                        }

                        /* desktop */
                        @media (max-width: 991.98px) {
                            body.has-fixed-navbar {
                                padding-top: 48px;
                            }

                            /* mobile/tablet */
                        }
                    </style>

                </head>

                <body class="has-fixed-navbar">
                    <jsp:include page="/WEB-INF/view/common/navbar.jsp" />
                    <jsp:include page="/WEB-INF/view/common/sidebar.jsp" />

                    <div class="container mt-5 mb-5">
                        <!-- Header -->
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <h4>
                                <c:choose>
                                    <c:when test="${category.id == null}">
                                        ${category.parent == null ? 'Thêm danh mục CHA' : 'Thêm danh mục con'}
                                    </c:when>
                                    <c:otherwise>
                                        ${category.parent == null ? 'Sửa danh mục CHA' : 'Sửa danh mục con'}
                                    </c:otherwise>
                                </c:choose>
                            </h4>

                            <c:choose>
                                <c:when test="${category.parent != null && category.parent.id != null}">
                                    <c:url var="backUrl"
                                        value="/admin/categories/${category.parent.id}/subcategories" />
                                </c:when>
                                <c:otherwise>
                                    <c:url var="backUrl" value="/admin/categories" />
                                </c:otherwise>
                            </c:choose>
                            <a class="btn btn-outline-secondary" href="${backUrl}">← Quay lại</a>
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

                        <!-- Form Action -->
                        <c:choose>
                            <c:when test="${category.id != null}">
                                <c:set var="formAction" value="/admin/categories/save" />
                            </c:when>
                            <c:when test="${category.parent != null && category.parent.id != null}">
                                <c:set var="formAction"
                                    value="/admin/categories/${category.parent.id}/subcategories/create" />
                            </c:when>
                            <c:otherwise>
                                <c:set var="formAction" value="/admin/categories/save" />
                            </c:otherwise>
                        </c:choose>

                        <!-- Form Card -->
                        <div class="card p-4 mb-4">
                            <form id="categoryForm" method="post" action="<c:url value='${formAction}'/>"
                                class="needs-validation" novalidate>
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                                <c:if test="${category.id != null}">
                                    <input type="hidden" name="id" value="${category.id}" />
                                </c:if>
                                <c:if test="${category.parent != null && category.parent.id != null}">
                                    <input type="hidden" name="parent.id" value="${category.parent.id}" />
                                </c:if>

                                <div class="row g-3">
                                    <div class="col-12">
                                        <label class="form-label">Tên danh mục <span
                                                class="text-danger">*</span></label>

                                        <input type="text" name="name" value="${fn:escapeXml(category.name)}"
                                            class="form-control ${nameError != null ? 'is-invalid' : ''}">

                                        <c:if test="${nameError != null}">
                                            <div class="invalid-feedback d-block">
                                                ${nameError}
                                            </div>
                                        </c:if>
                                    </div>
                                    <div class="col-12">
                                        <label class="form-label">Mô tả</label>

                                        <textarea name="description"
                                            class="form-control ${descriptionError != null ? 'is-invalid' : ''}"
                                            rows="4" maxlength="500">${category.description}</textarea>

                                        <c:if test="${descriptionError != null}">
                                            <div class="invalid-feedback d-block">
                                                ${descriptionError}
                                            </div>
                                        </c:if>

                                        <div class="form-text">Tối đa 500 ký tự.</div>
                                    </div>
                                    <c:if test="${category.id != null}">
                                        <div class="col-12">
                                            <label class="form-label me-2">Trạng thái:</label>
                                            <span class="badge ${!category.isDeleted?'bg-success':'bg-secondary'}">
                                                ${!category.isDeleted?'ACTIVE':'INACTIVE'}
                                            </span>
                                        </div>
                                    </c:if>
                                </div>

                                <div class="d-flex gap-2 mt-4">
                                    <button type="submit" class="btn btn-primary" id="submitBtn">
                                        ${category.id == null ? 'Tạo mới' : 'Cập nhật'}
                                    </button>
                                    <a class="btn btn-secondary" href="${backUrl}">Hủy</a>
                                </div>
                            </form>
                        </div>

                        <!-- Children Table (when editing parent category) -->
                        <c:if test="${category.id != null && category.parent == null && not empty children}">
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <h5>Danh mục con của: <strong>
                                        <c:out value="${category.name}" />
                                    </strong></h5>
                                <a href="<c:url value='/admin/categories/${category.id}/subcategories/add'/>"
                                    class="btn btn-primary">+ Thêm danh mục con</a>
                            </div>

                            <div class="table-container">
                                <table class="resizable-table table table-hover align-middle" id="childrenTable">
                                    <thead class="table-light">
                                        <tr>
                                            <th class="sortable" style="width:80px" data-column="0" data-type="number">
                                                ID<div class="resizer"></div>
                                            </th>
                                            <th class="sortable" style="width:320px" data-column="1" data-type="text">
                                                Tên<div class="resizer"></div>
                                            </th>
                                            <th class="sortable" style="width:420px" data-column="2" data-type="text">
                                                Mô tả<div class="resizer"></div>
                                            </th>
                                            <th class="sortable" style="width:140px" data-column="3" data-type="text">
                                                Trạng thái<div class="resizer"></div>
                                            </th>
                                            <th style="width:240px">Thao tác</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="c" items="${children}">
                                            <tr>
                                                <td>#${c.id}</td>
                                                <td>
                                                    <c:out value="${c.name}" />
                                                </td>
                                                <td>
                                                    <c:out value="${c.description}" />
                                                </td>
                                                <td>
                                                    <span class="badge ${!c.isDeleted?'bg-success':'bg-secondary'}">
                                                        ${!c.isDeleted?'ACTIVE':'INACTIVE'}
                                                    </span>
                                                </td>
                                                <td class="text-end">
                                                    <!-- Edit button -->
                                                    <a class="btn-icon btn-action-edit" title="Chỉnh sửa"
                                                        href="<c:url value='/admin/categories/edit/${c.id}'/>">
                                                        <i class="bi bi-pencil-square"></i>
                                                    </a>

                                                    <!-- Toggle form -->
                                                    <form method="post"
                                                        action="<c:url value='/admin/categories/toggle/${c.id}'/>"
                                                        class="d-inline">
                                                        <input type="hidden" name="${_csrf.parameterName}"
                                                            value="${_csrf.token}" />
                                                        <button
                                                            class="btn btn-sm ${!c.isDeleted?'btn-outline-warning':'btn-outline-success'}"
                                                            type="submit">
                                                            ${!c.isDeleted?'Tắt':'Bật'}
                                                        </button>
                                                    </form>

                                                    <!-- Delete form -->
                                                    <form method="post"
                                                        action="<c:url value='/admin/categories/delete/${c.id}'/>"
                                                        class="d-inline"
                                                        onsubmit="return confirm('Xoá ${fn:escapeXml(c.name)}?');">
                                                        <input type="hidden" name="${_csrf.parameterName}"
                                                            value="${_csrf.token}" />
                                                        <button type="submit" class="btn-icon btn-action-delete"
                                                            title="Xoá">
                                                            <i class="bi bi-trash"></i>
                                                        </button>
                                                    </form>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </c:if>
                    </div>

                    <jsp:include page="/WEB-INF/view/common/footer.jsp" />

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
                            const form = document.getElementById('categoryForm');
                            if (!form) return;

                            form.addEventListener('submit', function (e) {
                                if (!form.checkValidity()) {
                                    e.preventDefault();
                                    e.stopPropagation();
                                }
                                form.classList.add('was-validated');

                                // Double submit prevention
                                const submitBtn = document.getElementById('submitBtn');
                                if (submitBtn && form.checkValidity()) {
                                    submitBtn.disabled = true;
                                    const originalText = submitBtn.innerHTML;
                                    submitBtn.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>Đang xử lý...';

                                    setTimeout(() => {
                                        submitBtn.disabled = false;
                                        submitBtn.innerHTML = originalText;
                                    }, 3000);
                                }
                            });

                            // Double submit prevention for inline forms (toggle, delete)
                            document.querySelectorAll('form.d-inline[method="post"]').forEach(f => {
                                f.addEventListener('submit', function () {
                                    const btn = f.querySelector('button[type="submit"],button:not([type])');
                                    if (btn) {
                                        btn.disabled = true;
                                        const t = btn.innerHTML;
                                        btn.dataset.originalText = t;
                                        btn.innerHTML = 'Đang xử lý...';
                                        setTimeout(() => {
                                            btn.disabled = false;
                                            btn.innerHTML = btn.dataset.originalText;
                                        }, 3000);
                                    }
                                });
                            });
                        })();
                    </script>

                    <script>
                        // Sidebar compatibility for category_form.jsp
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

                            try { const v = localStorage.getItem('sb-open'); syncState(v === '1'); } catch (e) { }

                            if (btn) {
                                btn.addEventListener('click', function (e) {
                                    e.preventDefault();
                                    const nowOpen = !document.body.classList.contains('sidebar-open');
                                    syncState(nowOpen);
                                    try { localStorage.setItem('sb-open', nowOpen ? '1' : '0'); } catch (e) { }
                                });
                            }
                        })();

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
                            } catch (err) { console.error('toggleSidebar error:', err); }
                        }
                    </script>

                    <!-- Table features: sort + resize (for children table if exists) -->
                    <script>
                        (function initTableFeatures() {
                            const table = document.getElementById('childrenTable');
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

                    <script>
                        (function () {
                            var CP = '${pageContext.request.contextPath}';
                            function isAbs(u) { return /^[a-zA-Z][a-zA-Z0-9+.-]*:/.test(u); } // http:, https:, mailto:, ...

                            function fixHref(a) {
                                var href = a.getAttribute('href');
                                if (!href || href.startsWith('#') || href.startsWith('javascript:')) return;
                                if (isAbs(href)) return;                    // link tuyệt đối thì bỏ qua
                                if (href.startsWith(CP + '/')) return;      // đã có contextPath thì bỏ qua
                                var abs = href.startsWith('/') ? (CP + href) : (CP + '/' + href.replace(/^(\.\/)+/, ''));
                                a.setAttribute('href', abs);
                            }
                            function fixAction(f) {
                                var act = f.getAttribute('action');
                                if (!act || isAbs(act)) return;
                                if (act.startsWith(CP + '/')) return;
                                var abs = act.startsWith('/') ? (CP + act) : (CP + '/' + act.replace(/^(\.\/)+/, ''));
                                f.setAttribute('action', abs);
                            }

                            // Chỉ sửa link trong navbar & sidebar (không đụng nội dung trang)
                            document.querySelectorAll('.navbar a[href], .sidebar a[href]').forEach(fixHref);
                            document.querySelectorAll('.navbar form[action], .sidebar form[action]').forEach(fixAction);
                        })();
                    </script>


                </body>

                </html>