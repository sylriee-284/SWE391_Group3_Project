<%@ page contentType="text/html; charset=UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>
                    <c:choose>
                        <c:when test="${formMode == 'create'}">Tạo người dùng</c:when>
                        <c:otherwise>Chỉnh sửa người dùng</c:otherwise>
                    </c:choose>
                </title>

                <jsp:include page="/WEB-INF/view/common/head.jsp" />
                <meta name="_csrf_header" content="${_csrf.headerName}" />
                <meta name="_csrf" content="${_csrf.token}" />

                <style>
                    body.has-fixed-navbar {
                        padding-top: 56px
                    }

                    @media (max-width: 991.98px) {
                        body.has-fixed-navbar {
                            padding-top: 48px
                        }
                    }
                </style>
            </head>

            <body class="has-fixed-navbar">
                <jsp:include page="/WEB-INF/view/common/navbar.jsp" />
                <jsp:include page="/WEB-INF/view/common/sidebar.jsp" />

                <div class="container mt-5 mb-5">
                    <div class="card p-4 border-0">
                        <h4 class="mb-3">
                            <c:choose>
                                <c:when test="${formMode == 'create'}">Tạo người dùng</c:when>
                                <c:otherwise>Chỉnh sửa người dùng</c:otherwise>
                            </c:choose>
                        </h4>

                        <form method="post" action="<c:url value='/admin/users/save'/>" class="needs-validation"
                            novalidate>
                            <c:if test="${user.id != null}">
                                <input type="hidden" name="id" value="${user.id}" />
                            </c:if>
                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />

                            <div class="row g-3">
                                <div class="col-md-6">
                                    <label class="form-label">Username</label>
                                    <input name="username"
                                        class="form-control ${not empty usernameError ? 'is-invalid' : ''}"
                                        value="${user.username}" required maxlength="50" />
                                    <div class="invalid-feedback">
                                        <c:out
                                            value="${empty usernameError ? 'Vui lòng nhập username' : usernameError}" />
                                    </div>
                                </div>


                                <div class="col-md-6">
                                    <label class="form-label">Email</label>
                                    <input name="email" type="email"
                                        class="form-control ${not empty emailError ? 'is-invalid' : ''}"
                                        value="${user.email}" required maxlength="255" />
                                    <div class="invalid-feedback">
                                        <c:out
                                            value="${empty emailError ? 'Vui lòng nhập email hợp lệ' : emailError}" />
                                    </div>
                                </div>


                                <div class="col-md-6">
                                    <label class="form-label">Full name</label>
                                    <input name="fullName" class="form-control" value="${user.fullName}"
                                        maxlength="255" />
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label">Phone</label>
                                    <input type="text" name="phone" value="${user.phone}"
                                        class="form-control ${phoneError != null ? 'is-invalid' : ''}" required>

                                    <c:if test="${phoneError != null}">
                                        <div class="invalid-feedback">
                                            ${phoneError}
                                        </div>
                                    </c:if>
                                </div>


                                <!-- Số dư: chỉ hiển thị/đi link nạp nhanh -->
                                <div class="col-md-6">
                                    <label class="form-label">Số dư</label>
                                    <div class="input-group">
                                        <input type="text" class="form-control"
                                            value="<fmt:formatNumber value='${user.balance}'/>" readonly />
                                        <c:url var="depositUrl" value="/wallet/deposit">
                                            <c:if test="${not empty user.id}">
                                                <c:param name="userId" value="${user.id}" />
                                            </c:if>
                                        </c:url>
                                        <a class="btn btn-outline-primary" href="${depositUrl}">+</a>
                                    </div>
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label">Status</label>
                                    <select name="status" class="form-select">
                                        <option value="ACTIVE" <c:if
                                            test="${user.status != null && user.status.name() == 'ACTIVE'}">selected
                                            </c:if>>ACTIVE</option>
                                        <option value="INACTIVE" <c:if
                                            test="${user.status != null && user.status.name() == 'INACTIVE'}">selected
                                            </c:if>>INACTIVE</option>
                                    </select>
                                </div>

                                <!-- ROLES: checkbox đa chọn – KHÔNG dùng 'contains' trong EL -->
                                <div class="mb-3">
                                    <label class="form-label">Roles</label>
                                    <div>

                                        <c:forEach var="r" items="${allRoles}">
                                            <%-- EL không có 'contains' -> so sánh vòng lặp --%>
                                                <c:set var="checked" value="false" />
                                                <c:if test="${not empty selectedRoleIds}">
                                                    <c:forEach var="sid" items="${selectedRoleIds}">
                                                        <c:if test="${sid == r.id}">
                                                            <c:set var="checked" value="true" />
                                                        </c:if>
                                                    </c:forEach>
                                                </c:if>

                                                <input type="checkbox" class="btn-check" id="role-${r.id}"
                                                    name="roleIds" value="${r.id}" <c:if test='${checked}'>checked
                                                </c:if> />
                                                <label class="btn btn-outline-primary me-2 mb-2"
                                                    for="role-${r.id}">${r.code}</label>
                                        </c:forEach>

                                    </div>
                                    <div class="form-text">Có thể chọn nhiều vai trò (ví dụ: USER, SELLER, ADMIN).</div>
                                </div>
                            </div>

                            <div class="mt-3">
                                <button class="btn btn-primary" type="submit">Lưu</button>
                                <a class="btn btn-secondary" href="<c:url value='/admin/users'/>">Hủy</a>
                            </div>
                        </form>
                    </div>
                </div>

                <jsp:include page="/WEB-INF/view/common/footer.jsp" />

                <script>
                    (function () {
                        const form = document.querySelector('form.needs-validation');
                        if (!form) return;
                        form.addEventListener('submit', function (e) {
                            if (!form.checkValidity()) { e.preventDefault(); e.stopPropagation(); }
                            form.classList.add('was-validated');
                        });
                    })();
                </script>
                <script>
                    // Sidebar compatibility for admin pages
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