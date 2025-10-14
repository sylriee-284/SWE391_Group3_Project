<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>

            <!DOCTYPE html>
            <html lang="en">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>
                    <c:if test="${not empty pageTitle}">${pageTitle} - </c:if>MMO Market System
                </title>

                <!-- Include common head with all CSS and JS -->
                <jsp:include page="../common/head.jsp" />
            </head>

            <body>
                <!-- Include Navbar -->
                <jsp:include page="../common/navbar.jsp" />

                <!-- Include Sidebar -->
                <jsp:include page="../common/sidebar.jsp" />

                <!-- Main Content Area -->
                <div class="content" id="content">

                    <%--=================START: QUẢN LÝ TÀI KHOẢN=================--%>

                        <div class="d-flex justify-content-between align-items-center mt-4 mb-3">
                            <h3 class="m-0">Quản lý tài khoản</h3>

                            <div class="d-flex gap-2">
                                <form method="get" action="<c:url value='/admin/users'/>" class="d-flex gap-2">
                                    <select name="status" class="form-select form-select-sm w-auto"
                                        onchange="this.form.submit()">
                                        <option value="" ${empty statusFilter ? 'selected' : '' }>Tất cả</option>
                                        <option value="ACTIVE" ${statusFilter=='ACTIVE' ? 'selected' : '' }>ACTIVE
                                        </option>
                                        <option value="INACTIVE" ${statusFilter=='INACTIVE' ? 'selected' : '' }>INACTIVE
                                        </option>
                                    </select>
                                    <input type="hidden" name="page" value="${currentPage}" />
                                    <input type="hidden" name="size" value="${pageSize}" />
                                </form>

                                <a class="btn btn-primary btn-sm" href="<c:url value='/admin/users/create'/>">+ Thêm tài
                                    khoản</a>
                            </div>
                        </div>

                        <c:if test="${not empty success}">
                            <div class="alert alert-success">${success}</div>
                        </c:if>

                        <div class="card shadow-sm">
                            <div class="card-body p-0">
                                <div class="table-responsive">
                                    <table class="table table-hover align-middle mb-0">
                                        <thead class="table-light">
                                            <tr>
                                                <th style="width:80px;">ID</th>
                                                <th>Username</th>
                                                <th>Email</th>
                                                <th>Họ tên</th>

                                                <!-- [PATCH] THÊM CỘT VAI TRÒ -->
                                                <th style="width:150px;">Role</th>

                                                <th class="text-end" style="width:180px;">
                                                    <!-- [PATCH] ĐỔI NHÃN (CÓ ẨN/HIỆN) -->
                                                    Số dư (VND)
                                                </th>

                                                <th style="width:130px;">Trạng thái</th>
                                                <th style="width:120px;" class="text-center">Thao tác</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="u" items="${users}">
                                                <tr data-user-id="${u.id}">
                                                    <td>${u.id}</td>
                                                    <td>${u.username}</td>
                                                    <td>${u.email}</td>
                                                    <td>${u.fullName}</td>

                                                    <!-- [PATCH] HIỂN THỊ ROLE: ghép danh sách role code (bỏ ADMIN nếu có) -->
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${empty u.roles}">
                                                                <span class="text-muted">—</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <c:forEach var="r" items="${u.roles}" varStatus="st">
                                                                    <c:if test="${r.code ne 'ADMIN'}">
                                                                        <span
                                                                            class="badge bg-info-subtle text-dark border">${r.code}</span>
                                                                        <c:if test="${!st.last}"></c:if>
                                                                    </c:if>
                                                                </c:forEach>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>

                                                    <!-- [PATCH] ẨN/HIỆN SỐ DƯ: mặc định ẩn, có nút Hiện -->
                                                    <td class="text-end">
                                                        <span class="balance-text me-2"
                                                            data-state="hidden">••••••</span>
                                                        <button type="button"
                                                            class="btn btn-sm btn-outline-secondary balance-toggle"
                                                            data-id="${u.id}">
                                                            Hiện
                                                        </button>
                                                    </td>

                                                    <td>
                                                        <span
                                                            class="badge ${u.status == 'ACTIVE' ? 'bg-success' : 'bg-secondary'} status-toggle"
                                                            style="cursor:pointer" data-id="${u.id}"
                                                            title="Bấm để đổi trạng thái">
                                                            ${u.status}
                                                        </span>
                                                    </td>
                                                    <td class="text-center">
                                                        <a class="btn btn-sm btn-outline-primary"
                                                            href="<c:url value='/admin/users/edit/${u.id}'/>">Sửa</a>
                                                    </td>
                                                </tr>
                                            </c:forEach>

                                            <c:if test="${empty users}">
                                                <tr>
                                                    <td colspan="8" class="text-center py-4 text-muted">Chưa có người
                                                        dùng.</td>
                                                </tr>
                                            </c:if>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>

                        <%-- Phân trang --%>
                            <c:if test="${totalPages gt 1}">
                                <nav aria-label="pagination">
                                    <ul class="pagination justify-content-center mt-3">
                                        <c:forEach var="i" begin="1" end="${totalPages}">
                                            <li class="page-item ${i == currentPage ? 'active' : ''}">
                                                <a class="page-link"
                                                    href="?page=${i}&size=${pageSize}&status=${statusFilter}">${i}</a>
                                            </li>
                                        </c:forEach>
                                    </ul>
                                </nav>
                            </c:if>

                            <!-- [PATCH] JS: Toggle trạng thái & Ẩn/Hiện số dư -->
                            <script>
                                // Toggle trạng thái (POST + CSRF) — giữ lại logic cũ, gom 1 khối
                                document.querySelectorAll('.status-toggle').forEach(function (el) {
                                    el.addEventListener('click', async function () {
                                        const id = this.dataset.id;
                                        const wasActive = this.textContent.trim() === 'ACTIVE';

                                        const resp = await fetch('<c:url value="/admin/users/toggle/" />' + id, {
                                            method: 'POST',
                                            headers: { 'X-CSRF-TOKEN': '${_csrf.token}' }
                                        });

                                        if (resp.ok) {
                                            this.textContent = wasActive ? 'INACTIVE' : 'ACTIVE';
                                            this.classList.toggle('bg-success', !wasActive);
                                            this.classList.toggle('bg-secondary', wasActive);
                                        }
                                    });
                                });

                                // [PATCH] Ẩn/Hiện số dư mỗi hàng
                                function formatVND(n) {
                                    try {
                                        // nếu server trả BigDecimal -> chuỗi số; ép về Number an toàn
                                        const num = Number(n);
                                        if (!isNaN(num)) return num.toLocaleString('vi-VN');
                                        // fallback chuỗi
                                        return ('' + n);
                                    } catch (e) {
                                        return ('' + n);
                                    }
                                }

                                document.querySelectorAll('.balance-toggle').forEach(function (btn) {
                                    btn.addEventListener('click', async function () {
                                        const id = this.dataset.id;
                                        const row = this.closest('tr');
                                        const span = row.querySelector('.balance-text');
                                        const state = span.getAttribute('data-state');

                                        if (state === 'hidden') {
                                            // gọi API lấy số dư (GET)
                                            try {
                                                const resp = await fetch('<c:url value="/admin/users/balance/" />' + id, {
                                                    method: 'GET',
                                                    headers: { 'Accept': 'application/json' }
                                                });
                                                if (!resp.ok) throw new Error('HTTP ' + resp.status);
                                                const data = await resp.json();
                                                span.textContent = formatVND(data.balance);
                                                span.setAttribute('data-state', 'shown');
                                                this.textContent = 'Ẩn';
                                            } catch (e) {
                                                if (window.iziToast) {
                                                    iziToast.error({ title: 'Lỗi', message: 'Không lấy được số dư.', position: 'topRight' });
                                                } else {
                                                    alert('Không lấy được số dư.');
                                                }
                                            }
                                        } else {
                                            // chuyển về ẩn
                                            span.textContent = '••••••';
                                            span.setAttribute('data-state', 'hidden');
                                            this.textContent = 'Hiện';
                                        }
                                    });
                                });
                            </script>

                            <%--=================END: QUẢN LÝ TÀI KHOẢN=================--%>

                </div>


                <!-- Include Footer -->
                <jsp:include page="../common/footer.jsp" />

                <!-- Script to display notifications using iziToast -->
                <c:if test="${not empty successMessage}">
                    <script>
                        iziToast.success({
                            title: 'Success!',
                            message: '${successMessage}',
                            position: 'topRight',
                            timeout: 5000
                        });
                    </script>
                </c:if>

                <c:if test="${not empty errorMessage}">
                    <script>
                        iziToast.error({
                            title: 'Error!',
                            message: '${errorMessage}',
                            position: 'topRight',
                            timeout: 5000
                        });
                    </script>
                </c:if>

                <!-- Page-specific JavaScript -->
                <c:if test="${not empty pageJS}">
                    <c:forEach var="js" items="${pageJS}">
                        <script src="${pageContext.request.contextPath}${js}"></script>
                    </c:forEach>
                </c:if>

                <!-- Common JavaScript -->
                <script>
                    // Toggle sidebar function
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
                            !menuToggle.contains(event.target)) {
                            toggleSidebar();
                        }
                    });

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