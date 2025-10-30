<%@ page contentType="text/html; charset=UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

                <!DOCTYPE html>
                <html lang="vi">

                <head>
                    <meta charset="UTF-8" />
                    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
                    <title>Quản lý người dùng</title>

                    <jsp:include page="/WEB-INF/view/common/head.jsp" />
                    <meta name="_csrf_header" content="${_csrf.headerName}" />
                    <meta name="_csrf" content="${_csrf.token}" />

                    <style>
                        body.has-fixed-navbar {
                            padding-top: 56px
                        }

                        @media (max-width:991.98px) {
                            body.has-fixed-navbar {
                                padding-top: 48px
                            }
                        }

                        /* Card giống layout Orders */
                        .card-like {
                            border: 0;
                            border-radius: .75rem;
                            box-shadow: 0 2px 14px rgba(20, 33, 61, .06);
                            background: #fff;
                        }

                        .table-container {
                            overflow-x: auto
                        }

                        table.data-table {
                            table-layout: fixed;
                            width: 100%
                        }

                        table.data-table th,
                        table.data-table td {
                            white-space: nowrap;
                            vertical-align: middle
                        }

                        /* Hover xanh GIỐNG layout Orders (ưu tiên cao) */
                        .data-table.table-hover tbody tr:hover {
                            background-color: rgba(13, 110, 253, .06) !important;
                        }

                        /* SORT indicator giống layout: mũi tên mờ, sáng khi sort */
                        th.sortable {
                            cursor: pointer;
                            user-select: none;
                            position: relative;
                        }

                        th.sortable .sort-ind {
                            display: inline-block;
                            opacity: .35;
                            margin-left: .35rem;
                            font-size: .85em;
                        }

                        th.sortable.active .sort-ind {
                            opacity: 1
                        }

                        /* Tay nắm kéo cột */
                        .th-resizer {
                            position: absolute;
                            top: 0;
                            right: 0;
                            width: 8px;
                            height: 100%;
                            cursor: col-resize;
                            user-select: none;
                        }

                        td.actions {
                            text-align: end
                        }

                        .actions .btn+.btn {
                            margin-left: .5rem
                        }

                        /* Ensure table fits well inside the content area and wraps appropriately */
                        .table-container {
                            width: 100%;
                            overflow-x: auto;
                        }

                        /* Allow cells to ellipsize and not force the layout too wide */
                        table.data-table td,
                        table.data-table th {
                            max-width: 220px;
                            overflow: hidden;
                            text-overflow: ellipsis;
                            white-space: nowrap;
                        }

                        /* Make action column narrower */
                        table.data-table td.actions {
                            width: 160px;
                        }
                    </style>
                </head>

                <body class="has-fixed-navbar">
                    <jsp:include page="/WEB-INF/view/common/navbar.jsp" />
                    <jsp:include page="/WEB-INF/view/common/sidebar.jsp" />

                    <main class="page-main">
                        <div class="content" id="content">
                            <div class="container mt-4">
                                <div class="card-like p-4 mb-4">
                                    <div class="d-flex flex-wrap gap-2 justify-content-between align-items-center mb-3">
                                        <h4 class="m-0">Quản lý người dùng</h4>

                                        <div class="d-flex flex-wrap gap-2 align-items-center">
                                            <form id="clientFilter" class="row g-2">
                                                <!-- Hàng 1: các ô nhập -->
                                                <div class="col-md-2">
                                                    <input name="id" class="form-control form-control-sm"
                                                        value="${fn:escapeXml(param.id)}" placeholder="ID " />
                                                </div>
                                                <div class="col-md-2">
                                                    <input name="username" class="form-control form-control-sm"
                                                        value="${fn:escapeXml(param.username)}"
                                                        placeholder="Username" />
                                                </div>
                                                <div class="col-md-2">
                                                    <input name="email" class="form-control form-control-sm"
                                                        value="${fn:escapeXml(param.email)}" placeholder="Email" />
                                                </div>
                                                <div class="col-md-2">
                                                    <input name="phone" class="form-control form-control-sm"
                                                        value="${fn:escapeXml(param.phone)}" placeholder="Phone" />
                                                </div>
                                                <div class="col-md-2">
                                                    <select name="status" class="form-select form-select-sm">
                                                        <option value="">-- Tất cả trạng thái --</option>
                                                        <option value="ACTIVE" ${param.status=='ACTIVE' ? 'selected'
                                                            : '' }>ACTIVE</option>
                                                        <option value="INACTIVE" ${param.status=='INACTIVE' ? 'selected'
                                                            : '' }>INACTIVE</option>
                                                    </select>
                                                </div>

                                                <!-- sang hàng 2 -->
                                                <div class="w-100"></div>

                                                <!-- Khi lọc, luôn quay về trang 1 -->
                                                <input type="hidden" name="page" value="1" />
                                                <input type="hidden" name="size"
                                                    value="${pageSize != null ? pageSize : 10}" />

                                                <div class="col-12 col-md-6 d-flex gap-2">
                                                    <button type="submit" class="btn btn-sm btn-primary">Lọc</button>
                                                    <a class="btn btn-sm btn-outline-secondary"
                                                        href="<c:url value='/admin/users'/>">Bỏ lọc</a>
                                                </div>
                                                <div class="col-12 col-md-6 text-md-end">
                                                    <a class="btn btn-primary btn-sm"
                                                        href="<c:url value='/admin/users/add'/>">+ Tạo người dùng</a>
                                                </div>
                                            </form>


                                            <!-- Với màn nhỏ, giữ nút tạo ở chỗ cũ -->
                                            <a class="btn btn-primary mt-2 d-md-none"
                                                href="<c:url value='/admin/users/add'/>">+ Tạo người dùng</a>
                                        </div>
                                    </div>

                                    <div class="table-container">
                                        <table id="usersTable" class="table table-hover align-middle data-table">
                                            <thead class="table-light">
                                                <tr>
                                                    <th data-key="id" class="sortable">ID <span
                                                            class="sort-ind">⇵</span>
                                                    </th>
                                                    <th data-key="username" class="sortable">Username <span
                                                            class="sort-ind">⇵</span></th>
                                                    <th data-key="email" class="sortable">Email <span
                                                            class="sort-ind">⇵</span></th>
                                                    <th data-key="full" class="sortable">Full name <span
                                                            class="sort-ind">⇵</span></th>
                                                    <th data-key="phone" class="sortable">Phone <span
                                                            class="sort-ind">⇵</span></th>
                                                    <th>Roles</th>
                                                    <th data-key="status" class="sortable">Trạng thái<span
                                                            class="sort-ind">⇵</span></th>
                                                    <th>Hành động</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:set var="visibleCount" value="0" />
                                                <c:forEach var="u" items="${users}">
                                                    <%-- Ẩn user có role ADMIN --%>
                                                        <c:set var="isAdmin" value="false" />
                                                        <c:forEach var="r" items="${u.roles}">
                                                            <c:if test="${r.code == 'ADMIN'}">
                                                                <c:set var="isAdmin" value="true" />
                                                            </c:if>
                                                        </c:forEach>

                                                        <c:if test="${!isAdmin}">
                                                            <c:set var="visibleCount" value="${visibleCount + 1}" />
                                                            <tr>
                                                                <td data-id="${u.id}">#${u.id}</td>
                                                                <td data-username="${fn:escapeXml(u.username)}">
                                                                    <c:out value="${u.username}" />
                                                                </td>
                                                                <td data-email="${fn:escapeXml(u.email)}">
                                                                    <c:out value="${u.email}" />
                                                                </td>
                                                                <td data-full="${fn:escapeXml(u.fullName)}">
                                                                    <c:out value="${u.fullName}" />
                                                                </td>
                                                                <td data-phone="${fn:escapeXml(u.phone)}">
                                                                    <c:out value="${u.phone}" />
                                                                </td>

                                                                <td>
                                                                    <c:if test="${empty u.roles}">
                                                                        <span class="text-muted">—</span>
                                                                    </c:if>
                                                                    <c:if test="${not empty u.roles}">
                                                                        <c:forEach var="rr" items="${u.roles}"
                                                                            varStatus="st">
                                                                            ${rr.code}<c:if test="${!st.last}">, </c:if>
                                                                        </c:forEach>
                                                                    </c:if>
                                                                </td>

                                                                <td data-status="${u.status.name()}">
                                                                    <span
                                                                        class="badge ${u.status.name()=='ACTIVE'?'bg-success':'bg-secondary'}">
                                                                        ${u.status.name()}
                                                                    </span>
                                                                </td>

                                                                <td class="actions">
                                                                    <a class="btn btn-sm btn-outline-secondary"
                                                                        href="<c:url value='/admin/users/edit/${u.id}'/>">Sửa</a>

                                                                    <form method="post"
                                                                        action="<c:url value='/admin/users/toggle/${u.id}'/>"
                                                                        class="d-inline">
                                                                        <input type="hidden"
                                                                            name="${_csrf.parameterName}"
                                                                            value="${_csrf.token}" />
                                                                        <button type="submit"
                                                                            class="btn btn-sm btn-outline-warning">Đổi
                                                                            trạng
                                                                            thái</button>
                                                                    </form>
                                                                    <%-- KHÔNG có nút Xóa --%>
                                                                </td>
                                                            </tr>
                                                        </c:if>
                                                </c:forEach>

                                                <c:if test="${visibleCount == 0}">
                                                    <tr>
                                                        <td colspan="8" class="text-center text-muted py-4">Không có
                                                            người
                                                            dùng hiển thị.</td>
                                                    </tr>
                                                </c:if>
                                            </tbody>
                                        </table>
                                    </div>

                                    <c:if test="${totalPages != null && totalPages > 1}">
                                        <nav class="mt-3">
                                            <ul class="pagination justify-content-center">
                                                <c:if test="${currentPage > 1}">
                                                    <li class="page-item">
                                                        <a class="page-link"
                                                            href="?page=1&size=${pageSize}&status=${fn:escapeXml(status)}">&laquo;</a>
                                                    </li>
                                                    <li class="page-item">
                                                        <a class="page-link"
                                                            href="?page=${currentPage-1}&size=${pageSize}&status=${fn:escapeXml(status)}">&lsaquo;</a>
                                                    </li>
                                                </c:if>

                                                <c:set var="start" value="${currentPage-2 < 1 ? 1 : currentPage-2}" />
                                                <c:set var="end"
                                                    value="${currentPage+2 > totalPages ? totalPages : currentPage+2}" />
                                                <c:forEach begin="${start}" end="${end}" var="p">
                                                    <li class="page-item ${p == currentPage ? 'active' : ''}">
                                                        <a class="page-link"
                                                            href="?page=${p}&size=${pageSize}&status=${fn:escapeXml(status)}">${p}</a>
                                                    </li>
                                                </c:forEach>

                                                <c:if test="${currentPage < totalPages}">
                                                    <li class="page-item">
                                                        <a class="page-link"
                                                            href="?page=${currentPage+1}&size=${pageSize}&status=${fn:escapeXml(status)}">&rsaquo;</a>
                                                    </li>
                                                    <li class="page-item">
                                                        <a class="page-link"
                                                            href="?page=${totalPages}&size=${pageSize}&status=${fn:escapeXml(status)}">&raquo;</a>
                                                    </li>
                                                </c:if>
                                            </ul>
                                        </nav>
                                    </c:if>

                                </div>
                            </div>
                        </div>

                        <jsp:include page="/WEB-INF/view/common/footer.jsp" />
                    </main>

                    <!-- SORT + RESIZE -->
                    <script>
                        (() => {
                            const table = document.getElementById('usersTable');
                            if (!table) return;

                            // Lấy giá trị cell (ưu tiên data-* để sort chính xác)
                            const getVal = (cell, key) => {
                                if (!cell) return '';
                                if (key) {
                                    const d = cell.getAttribute('data-' + key);
                                    if (d !== null) return d.trim();
                                }
                                return cell.textContent.trim();
                            };

                            // Thực thi sort
                            const doSort = (th, asc) => {
                                const key = th.getAttribute('data-key');
                                const tbody = table.tBodies[0];
                                const idx = Array.from(th.parentNode.children).indexOf(th);
                                const rows = Array.from(tbody.querySelectorAll('tr'));

                                rows.sort((ra, rb) => {
                                    const a = getVal(ra.children[idx], key);
                                    const b = getVal(rb.children[idx], key);

                                    const na = parseFloat((a || '').replace(/[^\d.-]/g, ''));
                                    const nb = parseFloat((b || '').replace(/[^\d.-]/g, ''));
                                    const bothNum = !isNaN(na) && !isNaN(nb);

                                    return bothNum
                                        ? (na - nb) * (asc ? 1 : -1)
                                        : a.localeCompare(b, 'vi', { sensitivity: 'base' }) * (asc ? 1 : -1);
                                });

                                rows.forEach(r => tbody.appendChild(r));

                                // Cập nhật mũi tên giống layout: ⇵ (default), ▴/▾ khi sort
                                table.querySelectorAll('th.sortable').forEach(x => {
                                    x.classList.remove('active');
                                    x.dataset.asc = '';
                                    const i = x.querySelector('.sort-ind');
                                    if (i) i.textContent = '⇵';
                                });
                                th.classList.add('active');
                                th.dataset.asc = asc ? 'true' : 'false';
                                const ind = th.querySelector('.sort-ind');
                                if (ind) ind.textContent = asc ? '▴' : '▾';
                            };

                            // Click sort
                            table.querySelectorAll('th.sortable').forEach(th => {
                                th.addEventListener('click', () => {
                                    const asc = !(th.dataset.asc === 'true');
                                    doSort(th, asc);
                                });
                            });

                            // Cố định width ban đầu (để resize mượt)
                            const fixInitialWidths = () => {
                                table.querySelectorAll('th').forEach(th => {
                                    th.style.width = th.offsetWidth + 'px';
                                });
                            };

                            // Thêm tay nắm kéo cột
                            const addResizers = () => {
                                const ths = table.querySelectorAll('th');
                                ths.forEach((th, i) => {
                                    if (i === ths.length - 1) return; // bỏ cột Hành động
                                    const h = document.createElement('span');
                                    h.className = 'th-resizer';
                                    th.appendChild(h);

                                    let startX, startW;
                                    const onMove = (e) => {
                                        const dx = e.pageX - startX;
                                        const w = Math.max(60, startW + dx);
                                        th.style.width = w + 'px';
                                    };
                                    const onUp = () => {
                                        document.removeEventListener('mousemove', onMove);
                                        document.removeEventListener('mouseup', onUp);
                                    };
                                    h.addEventListener('mousedown', (e) => {
                                        e.preventDefault();
                                        startX = e.pageX;
                                        startW = th.offsetWidth;
                                        document.addEventListener('mousemove', onMove);
                                        document.addEventListener('mouseup', onUp);
                                    });
                                });
                            };

                            fixInitialWidths();
                            addResizers();
                        })();
                    </script>
                    <script>
                        // Sidebar compatibility for admin pages (same as in categories.jsp)
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
                                    const content = document.getElementById('content') || document.querySelector('.content');
                                    if (content) content.classList.add('shifted');
                                    const ov = ensureOverlay();
                                    ov.classList.add('active');
                                } else {
                                    document.body.classList.remove('sidebar-open');
                                    sidebar?.classList.remove('active');
                                    const content = document.getElementById('content') || document.querySelector('.content');
                                    if (content) content.classList.remove('shifted');
                                    const ov = document.getElementById(OVERLAY_ID);
                                    if (ov) ov.classList.remove('active');
                                }
                            }

                            try {
                                // Read last state (for instant UX) but don't persist across navigation:
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

                            // Close sidebar when user navigates via sidebar links (so it doesn't remain open on next page)
                            try {
                                const sidebarLinks = sidebar ? sidebar.querySelectorAll('a[href]') : [];
                                sidebarLinks.forEach(a => {
                                    a.addEventListener('click', () => {
                                        // remove persisted state so next page loads with sidebar closed
                                        try { localStorage.setItem('sb-open', '0'); } catch (e) { }
                                        syncState(false);
                                    });
                                });
                            } catch (e) { }
                        })();

                        function toggleSidebar() {
                            try {
                                const sidebar = document.querySelector('.sidebar');
                                const OVERLAY_ID = 'sidebarOverlay';
                                const isOpen = !document.body.classList.contains('sidebar-open');
                                if (isOpen) {
                                    document.body.classList.add('sidebar-open');
                                    sidebar?.classList.add('active');
                                    const content = document.getElementById('content') || document.querySelector('.content');
                                    if (content) content.classList.add('shifted');
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
                                    const content = document.getElementById('content') || document.querySelector('.content');
                                    if (content) content.classList.remove('shifted');
                                    const ov = document.getElementById(OVERLAY_ID);
                                    if (ov) ov.classList.remove('active');
                                }
                                try { localStorage.setItem('sb-open', isOpen ? '1' : '0'); } catch (e) { }
                            } catch (err) {
                                console.error('toggleSidebar error:', err);
                            }
                        }
                    </script>

                    <c:if test="${not empty success || not empty successMessage}">
                        <script>
                            (function () {
                                var msg = '${fn:escapeXml(success != null ? success : successMessage)}';
                                if (window.iziToast) {
                                    iziToast.success({
                                        title: 'Success!',
                                        message: msg,
                                        position: 'topRight',
                                        timeout: 5000
                                    });
                                } else {
                                    // fallback nếu vì lý do gì đó chưa load iziToast
                                    console.log('Success:', msg);
                                }
                            })();
                        </script>
                    </c:if>

                    <c:if test="${not empty error || not empty errorMessage}">
                        <script>
                            (function () {
                                var msg = '${fn:escapeXml(error != null ? error : errorMessage)}';
                                if (window.iziToast) {
                                    iziToast.error({
                                        title: 'Error!',
                                        message: msg,
                                        position: 'topRight',
                                        timeout: 5000
                                    });
                                } else {
                                    console.error('Error:', msg);
                                }
                            })();
                        </script>
                    </c:if>

                    <script>
                        (function () {
                            const form = document.getElementById('clientFilter');
                            if (!form) return;

                            const tableBody = document.querySelector('#usersTable tbody');
                            if (!tableBody) return;

                            const allRows = Array.from(tableBody.querySelectorAll('tr'));

                            function cellData(tr, sel, attr) {
                                const td = tr.querySelector(sel);
                                if (!td) return '';
                                if (attr) {
                                    const v = td.getAttribute(attr);
                                    return (v || '').trim();
                                }
                                return (td.textContent || '').trim();
                            }

                            function applyFilter() {
                                const id = (form.fid.value || '').trim();
                                const username = (form.fusername.value || '').trim().toLowerCase();
                                const email = (form.femail.value || '').trim().toLowerCase();
                                const phone = (form.fphone.value || '').trim();
                                const status = (form.fstatus.value || '').trim();

                                let visible = 0;

                                allRows.forEach(tr => {
                                    const hasData = !!tr.querySelector('td[data-id]');
                                    if (!hasData) { tr.style.display = ''; return; }

                                    const rid = cellData(tr, 'td[data-id]', 'data-id');                  // số thô
                                    const ruser = cellData(tr, 'td[data-username]', 'data-username').toLowerCase();
                                    const remail = cellData(tr, 'td[data-email]', 'data-email').toLowerCase();
                                    const rphone = cellData(tr, 'td[data-phone]', 'data-phone');
                                    const rstatus = cellData(tr, 'td[data-status]', 'data-status');      // ACTIVE/INACTIVE

                                    const ok =
                                        (!id || (String(rid).includes(id))) &&
                                        (!username || ruser.includes(username)) &&
                                        (!email || remail.includes(email)) &&
                                        (!phone || rphone.includes(phone)) &&
                                        (!status || rstatus === status);

                                    tr.style.display = ok ? '' : 'none';
                                    if (ok) visible++;
                                });

                                // Ẩn/hiện hàng “Không có người dùng hiển thị.” nếu bạn có hàng đó
                                const emptyRow = tableBody.querySelector('tr[data-empty-row]');
                                if (emptyRow) emptyRow.style.display = visible ? 'none' : '';
                            }

                            form.addEventListener('submit', function (e) {
                                // để mặc định submit về server
                            });

                            document.getElementById('btnClearFilter')?.addEventListener('click', function () {
                                form.reset();
                                applyFilter();
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