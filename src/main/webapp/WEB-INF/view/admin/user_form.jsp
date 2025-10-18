<%@ page contentType="text/html; charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8" />
                <title>${formTitle != null ? formTitle : (user.id == null ? 'Tạo tài khoản' : 'Chỉnh sửa tài khoản')} -
                    MMO Market System</title>
                <jsp:include page="/WEB-INF/view/common/head.jsp" />
                <style>
                    .role-chip {
                        padding: .25rem .6rem;
                        border-radius: 999px;
                        font-size: .85rem;
                        background: #e6f5fd;
                    }

                    .form-check-inline .form-check-input {
                        margin-right: .35rem;
                    }
                </style>
            </head>

            <body>
                <jsp:include page="/WEB-INF/view/common/navbar.jsp" />
                <jsp:include page="/WEB-INF/view/common/sidebar.jsp" />
                <div class="sidebar-overlay" id="sidebarOverlay" onclick="toggleSidebar()"></div>

                <div class="main-content" id="mainContent">
                    <div class="container-fluid">

                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <h4 class="mb-0">
                                ${formTitle != null ? formTitle : (user.id == null ? 'Tạo tài khoản' : 'Chỉnh sửa tài
                                khoản')}
                            </h4>
                            <a class="btn btn-outline-secondary" href="<c:url value='/admin/users'/>">← Quay lại</a>
                        </div>

                        <!-- Xác định action -->
                        <c:set var="formAction"
                            value="${user.id == null ? '/admin/users' : '/admin/users/update/' += user.id}" />

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

                                    <div class="col-md-12">
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
                                            <option value="ACTIVE" <c:if test="${user.status == 'ACTIVE'}">selected
                                                </c:if>>ACTIVE</option>
                                            <option value="INACTIVE" <c:if test="${user.status == 'INACTIVE'}">selected
                                                </c:if>>INACTIVE</option>
                                        </select>
                                    </div>

                                    <div class="col-md-12">
                                        <label class="form-label">Số dư (VND)</label>
                                        <input class="form-control" name="balance" value="${user.balance}" />
                                    </div>

                                    <!-- ROLES -->
                                    <div class="col-12">
                                        <label class="form-label d-block">Quyền hạn (Roles)</label>

                                        <!-- allRoles: List<Role> ; selectedRoleCodes: List<String> -->
                                        <c:forEach var="r" items="${allRoles}">
                                            <div class="form-check form-check-inline mb-2">
                                                <input class="form-check-input" type="checkbox" id="role-${r.code}"
                                                    name="roleCodes" value="${r.code}" <c:if
                                                    test="${selectedRoleCodes != null && selectedRoleCodes.contains(r.code)}">checked
                                                </c:if> />
                                                <label class="form-check-label" for="role-${r.code}">
                                                    <span class="role-chip">${r.code}</span>
                                                </label>
                                            </div>
                                        </c:forEach>

                                        <div class="text-muted small mt-1">Không chọn thì mặc định sẽ là
                                            <strong>USER</strong>.
                                        </div>
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
                    function toggleSidebar() { const s = document.getElementById('sidebar'); const m = document.getElementById('mainContent'); if (s) s.classList.toggle('collapsed'); if (m) m.classList.toggle('expanded'); }
                </script>
            </body>

            </html>