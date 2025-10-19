<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
            <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
                <!DOCTYPE html>
                <html lang="vi">

                <head>
                    <meta charset="UTF-8" />
                    <title>Quản lý tài khoản - MMO Market System</title>
                    <jsp:include page="/WEB-INF/view/common/head.jsp" />
                    <meta name="_csrf_header" content="${_csrf.headerName}" />
                    <meta name="_csrf" content="${_csrf.token}" />

                    <!-- FIX: thay block CSS cũ bằng block này để trang con tự đẩy nội dung khi mở sidebar -->
                    <style>
                        :root {
                            --nav-h: 64px;
                            --sidebar-w: 260px;
                        }

                        /* có thể đổi theo sidebar thực tế */

                        /* chừa chỗ cho navbar + hiệu ứng đẩy khi mở sidebar */
                        #pageWrap {
                            padding-top: calc(var(--nav-h) + 16px);
                            padding-bottom: 24px;
                            transition: margin-left .25s ease;
                        }

                        #pageWrap.expanded {
                            margin-left: var(--sidebar-w);
                        }

                        /* khi mở sidebar */

                        /* đảm bảo sidebar luôn nằm trên bảng và không bị navbar đè */
                        #sidebar {
                            position: fixed;
                            top: var(--nav-h);
                            left: 0;
                            width: var(--sidebar-w);
                            height: calc(100vh - var(--nav-h));
                            z-index: 1040;
                            transform: translateX(-100%);
                            transition: transform .25s ease;
                        }

                        #sidebar.show {
                            transform: translateX(0);
                        }

                        /* lớp khi mở */

                        /* lớp phủ */
                        .sidebar-overlay {
                            position: fixed;
                            inset: 0;
                            background: rgba(0, 0, 0, .35);
                            display: none;
                            z-index: 1030;
                        }

                        .sidebar-overlay.show {
                            display: block;
                        }
                    </style>
                </head>

                <body>
                    <jsp:include page="/WEB-INF/view/common/navbar.jsp" />
                    <jsp:include page="/WEB-INF/view/common/sidebar.jsp" />
                    <!-- FIX: overlay để click ra ngoài đóng -->
                    <div class="sidebar-overlay" id="sidebarOverlay"></div>

                    <div id="pageWrap">
                        <div class="container-fluid">

                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <h4 class="mb-0">Quản lý tài khoản</h4>
                                <a class="btn btn-primary" href="<c:url value='/admin/users/create'/>">+ Thêm tài
                                    khoản</a>
                            </div>

                            <!-- Filter -->
                            <form method="get" action="">
                                <div class="row g-3">
                                    <div class="col-md-3">
                                        <label class="form-label">Trạng thái</label>
                                        <select name="status" class="form-select">
                                            <option value="" ${empty param.status ? 'selected' : '' }>Tất cả</option>
                                            <option value="ACTIVE" ${param.status=='ACTIVE' ?'selected':''}>ACTIVE
                                            </option>
                                            <option value="INACTIVE" ${param.status=='INACTIVE' ?'selected':''}>INACTIVE
                                            </option>
                                        </select>
                                    </div>
                                    <div class="col-md-3">
                                        <label class="form-label">Kích thước trang</label>
                                        <select name="size" class="form-select">
                                            <c:forEach var="opt" items="${fn:split('10,20,50,100', ',')}">
                                                <option value="${opt}" ${pageSize==opt?'selected':''}>${opt}</option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                    <div class="col-md-6 d-flex align-items-end gap-2">
                                        <button class="btn btn-primary" type="submit">Lọc</button>
                                        <a class="btn btn-outline-secondary" href="<c:url value='/admin/users'/>">Bỏ
                                            lọc</a>
                                    </div>
                                </div>
                            </form>

                            <!-- Bảng -->
                            <div class="table-container mt-3">
                                <table class="table table-hover align-middle">
                                    <thead class="table-light">
                                        <tr>
                                            <th style="width:80px">ID</th>
                                            <th style="width:200px">Username</th>
                                            <th style="width:280px">Email</th>
                                            <th style="width:200px">Họ tên</th>
                                            <th style="width:180px">Role</th>
                                            <th style="width:140px">Số dư (VND)</th>
                                            <th style="width:120px">Trạng thái</th>
                                            <th style="width:180px">Thao tác</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="u" items="${users}">
                                            <tr>
                                                <td>${u.id}</td>
                                                <td>${u.username}</td>
                                                <td>${u.email}</td>
                                                <td>
                                                    <c:out value="${u.fullName}" />
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${not empty u.roles}">
                                                            <c:forEach var="r" items="${u.roles}">
                                                                <span class="badge text-bg-info me-1">${r.code}</span>
                                                            </c:forEach>
                                                        </c:when>
                                                        <c:otherwise><span class="badge text-bg-secondary">USER</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>
                                                    <span class="text-muted">•••••</span>
                                                    <button type="button"
                                                        class="btn btn-sm btn-light ms-2 btn-show-balance"
                                                        data-id="${u.id}">Hiện</button>
                                                </td>
                                                <td>
                                                    <span
                                                        class="badge ${u.status=='ACTIVE' ? 'bg-success' : 'bg-secondary'}">${u.status}</span>
                                                </td>
                                                <td class="d-flex gap-2">
                                                    <a class="btn btn-sm btn-primary"
                                                        href="<c:url value='/admin/users/edit/${u.id}'/>">Sửa</a>
                                                    <button type="button"
                                                        class="btn btn-sm ${u.status=='ACTIVE'?'btn-warning':'btn-success'} btn-toggle-status"
                                                        data-id="${u.id}">
                                                        ${u.status=='ACTIVE'?'Tắt':'Bật'}
                                                    </button>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>

                            <!-- Phân trang -->
                            <c:if test="${totalPages > 1}">
                                <c:set var="baseUrl">
                                    <c:url value="/admin/users" />
                                </c:set>
                                <nav class="mt-3 mb-3">
                                    <ul class="pagination justify-content-center">
                                        <li class="page-item ${currentPage<=1?'disabled':''}">
                                            <a class="page-link"
                                                href="${baseUrl}?status=${param.status}&size=${pageSize}&page=1">&laquo;</a>
                                        </li>
                                        <li class="page-item ${currentPage<=1?'disabled':''}">
                                            <a class="page-link"
                                                href="${baseUrl}?status=${param.status}&size=${pageSize}&page=${currentPage-1}">&lsaquo;</a>
                                        </li>
                                        <c:forEach var="p" begin="1" end="${totalPages}">
                                            <li class="page-item ${p==currentPage?'active':''}">
                                                <a class="page-link"
                                                    href="${baseUrl}?status=${param.status}&size=${pageSize}&page=${p}">${p}</a>
                                            </li>
                                        </c:forEach>
                                        <li class="page-item ${currentPage>=totalPages?'disabled':''}">
                                            <a class="page-link"
                                                href="${baseUrl}?status=${param.status}&size=${pageSize}&page=${currentPage+1}">&rsaquo;</a>
                                        </li>
                                        <li class="page-item ${currentPage>=totalPages?'disabled':''}">
                                            <a class="page-link"
                                                href="${baseUrl}?status=${param.status}&size=${pageSize}&page=${totalPages}">&raquo;</a>
                                        </li>
                                    </ul>
                                </nav>
                            </c:if>

                        </div>
                    </div>

                    <jsp:include page="/WEB-INF/view/common/footer.jsp" />

                    <!-- FIX: JS “thò/thụt” + giữ nguyên các AJAX toggle/hiện số dư -->
                    <script>
                        (function () {
                            const wrap = document.getElementById('pageWrap');
                            const nav = document.querySelector('.navbar');
                            const sb = document.getElementById('sidebar');
                            const ovl = document.getElementById('sidebarOverlay');

                            function applyNavH() {
                                if (nav) {
                                    document.documentElement.style
                                        .setProperty('--nav-h', nav.getBoundingClientRect().height + 'px');
                                }
                            }

                            window.toggleSidebar = function () {
                                if (!sb) return;
                                sb.classList.toggle('show');              // FIX: dùng lớp 'show' thay vì 'collapsed'
                                if (wrap) wrap.classList.toggle('expanded');
                                if (ovl) ovl.classList.toggle('show');
                            };

                            // Bắt click burger từ navbar mà không cần sửa file common
                            document.addEventListener('click', (e) => {
                                const t = e.target;
                                if (t.closest('#sidebarToggle')
                                    || t.closest('.sidebar-toggle')
                                    || t.closest('[data-toggle="sidebar"]')
                                    || t.closest('.navbar .navbar-toggler')
                                    || t.closest('.bi-list') || t.closest('.fa-bars')) {
                                    e.preventDefault(); toggleSidebar();
                                }
                                if (t.closest('#sidebarOverlay')) toggleSidebar(); // click overlay để đóng
                            });

                            // ESC để đóng
                            document.addEventListener('keydown', (e) => {
                                if (e.key === 'Escape' && sb?.classList.contains('show')) toggleSidebar();
                            });

                            window.addEventListener('load', applyNavH);
                            window.addEventListener('resize', applyNavH);
                        })();

                        // ====== AJAX phần quản lý user (giữ nguyên logic cũ) ======
                        const CSRF_HEADER = document.querySelector('meta[name="_csrf_header"]')?.content || 'X-CSRF-TOKEN';
                        const CSRF_TOKEN = document.querySelector('meta[name="_csrf"]')?.content || '';

                        // Toggle trạng thái (delegation)
                        document.addEventListener('click', async (e) => {
                            const btn = e.target.closest('.btn-toggle-status'); if (!btn) return;
                            const id = btn.dataset.id;
                            try {
                                const res = await fetch('<c:url value="/admin/users/toggle/"/>' + id, {
                                    method: 'POST',
                                    headers: { [CSRF_HEADER]: CSRF_TOKEN }
                                });
                                if (!res.ok && res.status !== 204) throw new Error('HTTP ' + res.status);
                                location.reload();
                            } catch (err) {
                                console.error(err); alert('Đổi trạng thái thất bại!');
                            }
                        });

                        // Hiện số dư (delegation)
                        document.addEventListener('click', async (e) => {
                            const btn = e.target.closest('.btn-show-balance'); if (!btn) return;
                            const id = btn.dataset.id;
                            try {
                                const res = await fetch('<c:url value="/admin/users/balance/"/>' + id);
                                if (!res.ok) throw new Error('HTTP ' + res.status);
                                const data = await res.json();
                                alert('Số dư: ' + (data.balance ?? 0));
                            } catch (err) {
                                console.error(err); alert('Không lấy được số dư!');
                            }
                        });
                    </script>
                </body>

                </html>