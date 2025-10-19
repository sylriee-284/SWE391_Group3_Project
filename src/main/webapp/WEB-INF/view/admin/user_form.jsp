<%@ page contentType="text/html; charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8" />
                <title>${user.id == null ? 'Tạo tài khoản' : 'Chỉnh sửa tài khoản'} - MMO Market System</title>
                <jsp:include page="/WEB-INF/view/common/head.jsp" />
                <style>
                    #pageWrap {
                        padding-top: calc(var(--nav-h, 64px) + 16px);
                        padding-bottom: 24px;
                    }
                </style>
            </head>

            <body>
                <jsp:include page="/WEB-INF/view/common/navbar.jsp" />
                <jsp:include page="/WEB-INF/view/common/sidebar.jsp" />
                <div class="sidebar-overlay" id="sidebarOverlay" onclick="toggleSidebar()"></div>

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

                                    <div class="col-12">
                                        <label class="form-label">Mật khẩu <small class="text-muted">(Để trống nếu không
                                                đổi)</small></label>
                                        <input class="form-control" type="password" name="passwordPlain"
                                            autocomplete="new-password" />
                                    </div>

                                    <div class="col-md-6">
                                        <label class="form-label">Họ tên</label>
                                        <input class="form-control" name="fullName" value="${user.fullName}" />
                                    </div>

                                    <div class="col-md-6">
                                        <label class="form-label">Trạng thái</label>
                                        <select class="form-select" name="status">
                                            <option value="ACTIVE" ${user.status=='ACTIVE' ?'selected':''}>ACTIVE
                                            </option>
                                            <option value="INACTIVE" ${user.status=='INACTIVE' ?'selected':''}>INACTIVE
                                            </option>
                                        </select>
                                    </div>

                                    <div class="col-12">
                                        <label class="form-label">Số dư (VND)</label>
                                        <input class="form-control" name="balance" value="${user.balance}" />
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
                                        <div class="text-muted small mt-1">Không chọn thì mặc định sẽ là
                                            <strong>USER</strong>.</div>
                                    </div>
                                </div>

                                <div class="d-flex gap-2 mt-4">
                                    <button class="btn btn-primary" type="submit">${user.id == null ? 'Tạo mới' : 'Cập
                                        nhật'}</button>
                                    <a class="btn btn-secondary" href="<c:url value='/admin/users'/>">Hủy</a>
                                </div>
                            </form>
                        </div>

                    </div>
                </div>

                <jsp:include page="/WEB-INF/view/common/footer.jsp" />
                <script>
                    (function () {
                        const wrap = document.getElementById('pageWrap');
                        const nav = document.querySelector('.navbar');
                        const overlay = document.getElementById('sidebarOverlay');
                        function applyOffsets() {
                            if (nav) document.documentElement.style.setProperty('--nav-h', nav.getBoundingClientRect().height + 'px');
                        }
                        window.toggleSidebar = function () {
                            const s = document.getElementById('sidebar');
                            if (s) s.classList.toggle('collapsed');
                            if (wrap) wrap.classList.toggle('expanded');
                            if (overlay) overlay.classList.toggle('show');
                        };
                        window.addEventListener('load', applyOffsets);
                        window.addEventListener('resize', applyOffsets);
                    })();
                </script>
            </body>

            </html>