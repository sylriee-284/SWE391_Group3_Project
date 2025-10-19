<%@ page contentType="text/html; charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8" />
                <title>${user.id == null ? 'Tạo tài khoản' : 'Chỉnh sửa tài khoản'} - MMO Market System</title>
                <jsp:include page="/WEB-INF/view/common/head.jsp" />
                <meta name="_csrf_header" content="${_csrf.headerName}" />
                <meta name="_csrf" content="${_csrf.token}" />

                <!-- Sidebar thò/thụt: show/expanded + overlay -->
                <style>
                    :root {
                        --nav-h: 64px;
                        --sidebar-w: 260px;
                    }

                    #pageWrap {
                        padding-top: calc(var(--nav-h) + 16px);
                        padding-bottom: 24px;
                        transition: margin-left .25s ease;
                    }

                    #pageWrap.expanded {
                        margin-left: var(--sidebar-w);
                    }

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
                <div class="sidebar-overlay" id="sidebarOverlay"></div>

                <div id="pageWrap">
                    <div class="container-fluid">

                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <h4 class="mb-0">${user.id == null ? 'Tạo tài khoản' : 'Chỉnh sửa tài khoản'}</h4>
                            <a class="btn btn-outline-secondary" href="<c:url value='/admin/users'/>">← Quay lại</a>
                        </div>

                        <c:choose>
                            <c:when test="${user.id == null}">
                                <c:set var="formAction" value="/admin/users" />
                            </c:when>
                            <c:otherwise>
                                <c:set var="formAction" value="/admin/users/update/${user.id}" />
                            </c:otherwise>
                        </c:choose>

                        <div class="card p-3">
                            <form method="post" action="<c:url value='${formAction}'/>">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />

                                <div class="row g-3">
                                    <div class="col-md-6">
                                        <label class="form-label">Username <span class="text-danger">*</span></label>
                                        <input class="form-control" name="username" value="${user.username}" required />
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label">Email <span class="text-danger">*</span></label>
                                        <input class="form-control" type="email" name="email" value="${user.email}"
                                            required />
                                    </div>

                                    <!-- (ĐÃ BỎ HOÀN TOÀN TRƯỜNG MẬT KHẨU) -->

                                    <div class="col-md-6">
                                        <label class="form-label">Họ tên</label>
                                        <input class="form-control" name="fullName" value="${user.fullName}" />
                                    </div>

                                    <div class="col-md-6">
                                        <label class="form-label">Trạng thái</label>
                                        <select class="form-select" name="status">
                                            <option value="ACTIVE" ${user.status=='ACTIVE' ? 'selected' : '' }>ACTIVE
                                            </option>
                                            <option value="INACTIVE" ${user.status=='INACTIVE' ? 'selected' : '' }>
                                                INACTIVE</option>
                                        </select>
                                    </div>

                                    <!-- Số dư: readonly + nút + ở cuối -->
                                    <div class="col-12">
                                        <label class="form-label">Số dư (VND)</label>
                                        <div class="input-group">
                                            <input class="form-control" name="balance" value="${user.balance}"
                                                readonly />
                                            <!-- Nút “+” (đi tới trang nạp tiền chung – có thể chỉnh lại URL tuỳ nghiệp vụ) -->
                                            <a class="btn btn-outline-success" href="<c:url value='/wallet/deposit'/>"
                                                title="Nạp thêm">+</a>
                                        </div>
                                    </div>

                                    <!-- ROLES -->
                                    <div class="col-12">
                                        <label class="form-label d-block">Quyền hạn (Roles)</label>
                                        <c:forEach var="r" items="${allRoles}">
                                            <div class="form-check form-check-inline mb-2">
                                                <input class="form-check-input" type="checkbox" id="role-${r.code}"
                                                    name="roleCodes" value="${r.code}" <c:if
                                                    test="${selectedRoleCodes!=null && selectedRoleCodes.contains(r.code)}">checked
                                                </c:if> />
                                                <label class="form-check-label" for="role-${r.code}">
                                                    <span class="badge text-bg-info">${r.code}</span>
                                                </label>
                                            </div>
                                        </c:forEach>
                                        <!-- (ĐÃ BỎ GHI CHÚ “Không chọn thì mặc định sẽ là USER.”) -->
                                    </div>
                                </div>

                                <div class="d-flex gap-2 mt-4">
                                    <button class="btn btn-primary" type="submit">
                                        ${user.id == null ? 'Tạo mới' : 'Cập nhật'}
                                    </button>
                                    <a class="btn btn-secondary" href="<c:url value='/admin/users'/>">Hủy</a>
                                </div>
                            </form>
                        </div>

                    </div>
                </div>

                <jsp:include page="/WEB-INF/view/common/footer.jsp" />

                <!-- JS toggle sidebar theo mẫu dùng show/expanded + overlay -->
                <script>
                    (function () {
                        const wrap = document.getElementById('pageWrap');
                        const nav = document.querySelector('.navbar');
                        const sb = document.getElementById('sidebar');
                        const ovl = document.getElementById('sidebarOverlay');

                        function applyNavH() {
                            if (nav) document.documentElement.style.setProperty('--nav-h', nav.getBoundingClientRect().height + 'px');
                        }
                        window.toggleSidebar = function () {
                            if (!sb) return;
                            sb.classList.toggle('show');
                            if (wrap) wrap.classList.toggle('expanded');
                            if (ovl) ovl.classList.toggle('show');
                        };

                        document.addEventListener('click', (e) => {
                            const t = e.target;
                            if (t.closest('#sidebarToggle')
                                || t.closest('.sidebar-toggle')
                                || t.closest('[data-toggle="sidebar"]')
                                || t.closest('.navbar .navbar-toggler')
                                || t.closest('.bi-list') || t.closest('.fa-bars')) {
                                e.preventDefault(); toggleSidebar();
                            }
                            if (t.closest('#sidebarOverlay')) toggleSidebar();
                        });

                        document.addEventListener('keydown', (e) => {
                            if (e.key === 'Escape' && sb?.classList.contains('show')) toggleSidebar();
                        });

                        window.addEventListener('load', applyNavH);
                        window.addEventListener('resize', applyNavH);
                    })();
                </script>
            </body>

            </html>