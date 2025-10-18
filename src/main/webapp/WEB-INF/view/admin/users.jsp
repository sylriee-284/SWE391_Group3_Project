<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
            <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
                <!DOCTYPE html>
                <html lang="vi">

                <head>
                    <meta charset="UTF-8">
                    <title>Quản lý tài khoản - MMO Market System</title>
                    <jsp:include page="/WEB-INF/view/common/head.jsp" />

                    <!-- CSRF cho fetch -->
                    <meta name="_csrf_header" content="${_csrf.headerName}" />
                    <meta name="_csrf" content="${_csrf.token}" />
                </head>

                <body>
                    <jsp:include page="/WEB-INF/view/common/navbar.jsp" />
                    <jsp:include page="/WEB-INF/view/common/sidebar.jsp" />
                    <div class="sidebar-overlay" id="sidebarOverlay" onclick="toggleSidebar()"></div>

                    <div class="main-content" id="mainContent">
                        <div class="container-fluid">

                            <!-- Tiêu đề + Thêm tài khoản -->
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <h4 class="mb-0">Quản lý tài khoản</h4>
                                <a class="btn btn-primary" href="<c:url value='/admin/users/create'/>">+ Thêm tài
                                    khoản</a>
                            </div>

                            <!-- Bộ lọc -->
                            <div class="filter-section">
                                <form method="get" action="">
                                    <div class="row g-3">
                                        <div class="col-md-3">
                                            <label class="form-label">Trạng thái</label>
                                            <select name="status" class="form-select">
                                                <option value="" ${empty statusFilter ? 'selected' : '' }>Tất cả
                                                </option>
                                                <option value="ACTIVE" ${statusFilter=='ACTIVE' ? 'selected' : '' }>
                                                    ACTIVE</option>
                                                <option value="INACTIVE" ${statusFilter=='INACTIVE' ? 'selected' : '' }>
                                                    INACTIVE</option>
                                            </select>
                                        </div>
                                        <div class="col-md-3">
                                            <label class="form-label">Kích thước trang</label>
                                            <select name="size" class="form-select">
                                                <c:forEach var="opt" items="${fn:split('10,20,50,100', ',')}">
                                                    <option value="${opt}" ${pageSize==opt ? 'selected' : '' }>${opt}
                                                    </option>
                                                </c:forEach>
                                            </select>
                                        </div>
                                        <div class="col-md-6 d-flex align-items-end gap-2">
                                            <button class="btn btn-primary" type="submit">Lọc</button>
                                            <a class="btn btn-outline-secondary" href="<c:url value='/admin/users'/>">Bỏ
                                                lọc</a>
                                            <a class="btn btn-success" href="<c:url value='/admin/users/create'/>">+
                                                Thêm tài khoản</a>
                                        </div>
                                    </div>
                                </form>
                            </div>

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
                                                        <c:otherwise>
                                                            <span class="badge text-bg-secondary">USER</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>

                                                <!-- Balance: ẩn + nút Hiện -->
                                                <td>
                                                    <span class="text-muted">•••••</span>
                                                    <button type="button"
                                                        class="btn btn-sm btn-light ms-2 btn-show-balance"
                                                        data-id="${u.id}">
                                                        Hiện
                                                    </button>
                                                </td>

                                                <td>
                                                    <span
                                                        class="badge ${u.status=='ACTIVE' ? 'bg-success' : 'bg-secondary'}">
                                                        ${u.status}
                                                    </span>
                                                </td>

                                                <td class="d-flex gap-2">
                                                    <a class="btn btn-sm btn-primary"
                                                        href="<c:url value='/admin/users/edit/${u.id}'/>">Sửa</a>

                                                    <button type="button"
                                                        class="btn btn-sm ${u.status=='ACTIVE' ? 'btn-warning' : 'btn-success'} btn-toggle-status"
                                                        data-id="${u.id}">
                                                        ${u.status=='ACTIVE' ? 'Tắt' : 'Bật'}
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
                                <nav class="mt-3">
                                    <ul class="pagination justify-content-center">

                                        <!-- Prev -->
                                        <li class="page-item ${currentPage<=1?'disabled':''}">
                                            <a class="page-link"
                                                href="${baseUrl}?status=${statusFilter}&size=${pageSize}&page=${currentPage-1}">
                                                «
                                            </a>
                                        </li>

                                        <!-- pages -->
                                        <c:forEach var="p" begin="1" end="${totalPages}">
                                            <li class="page-item ${p==currentPage?'active':''}">
                                                <a class="page-link"
                                                    href="${baseUrl}?status=${statusFilter}&size=${pageSize}&page=${p}">${p}</a>
                                            </li>
                                        </c:forEach>

                                        <!-- Next -->
                                        <li class="page-item ${currentPage>=totalPages?'disabled':''}">
                                            <a class="page-link"
                                                href="${baseUrl}?status=${statusFilter}&size=${pageSize}&page=${currentPage+1}">
                                                »
                                            </a>
                                        </li>
                                    </ul>
                                </nav>
                            </c:if>

                        </div>
                    </div>

                    <jsp:include page="/WEB-INF/view/common/footer.jsp" />

                    <script>
                        function toggleSidebar() {
                            const s = document.getElementById('sidebar');
                            const m = document.getElementById('mainContent');
                            if (s) s.classList.toggle('collapsed');
                            if (m) m.classList.toggle('expanded');
                        }

                        // CSRF
                        const CSRF_HEADER = document.querySelector('meta[name="_csrf_header"]')?.content || 'X-CSRF-TOKEN';
                        const CSRF_TOKEN = document.querySelector('meta[name="_csrf"]')?.content || '';

                        // Toggle trạng thái (delegation)
                        document.addEventListener('click', async (e) => {
                            const btn = e.target.closest('.btn-toggle-status');
                            if (!btn) return;

                            const id = btn.dataset.id;
                            try {
                                const res = await fetch('<c:url value="/admin/users/toggle/"/>' + id, {
                                    method: 'POST',
                                    headers: { [CSRF_HEADER]: CSRF_TOKEN }
                                });
                                if (!res.ok && res.status !== 204) throw new Error('HTTP ' + res.status);
                                location.reload();
                            } catch (err) {
                                console.error(err);
                                alert('Đổi trạng thái thất bại!');
                            }
                        });

                        // Hiện số dư (delegation)
                        document.addEventListener('click', async (e) => {
                            const btn = e.target.closest('.btn-show-balance');
                            if (!btn) return;

                            const id = btn.dataset.id;
                            try {
                                const res = await fetch('<c:url value="/admin/users/balance/"/>' + id);
                                if (!res.ok) throw new Error('HTTP ' + res.status);
                                const data = await res.json();
                                alert('Số dư: ' + (data.balance ?? 0));
                            } catch (err) {
                                console.error(err);
                                alert('Không lấy được số dư!');
                            }
                        });
                    </script>
                </body>

                </html>