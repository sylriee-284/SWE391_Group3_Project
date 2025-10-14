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


                    <div class="d-flex justify-content-between align-items-center mt-4 mb-3">
                        <h3 class="m-0">${formTitle}</h3>
                        <a class="btn btn-outline-secondary" href="<c:url value='/admin/users'/>">← Quay lại</a>
                    </div>

                    <div class="card shadow-sm">
                        <div class="card-body">
                            <c:set var="isEdit" value="${not empty user.id}" />

                            <%-- build action cho create/update --%>
                                <c:set var="formAction" value="/admin/users" />
                                <c:if test="${isEdit}">
                                    <c:set var="formAction" value="/admin/users/update/${user.id}" />
                                </c:if>

                                <form method="post" action="${pageContext.request.contextPath}${formAction}">
                                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />

                                    <div class="row g-3">
                                        <div class="col-md-6">
                                            <label class="form-label">Username</label>
                                            <input name="username" class="form-control" value="${user.username}"
                                                required />
                                        </div>

                                        <div class="col-md-6">
                                            <label class="form-label">Email</label>
                                            <input type="email" name="email" class="form-control" value="${user.email}"
                                                required />
                                        </div>

                                        <div class="col-md-6">
                                            <label class="form-label">Mật khẩu</label>
                                            <input type="password" name="passwordPlain" class="form-control"
                                                placeholder="${isEdit ? 'Để trống nếu không đổi' : 'Nhập mật khẩu'}" />
                                        </div>

                                        <div class="col-md-6">
                                            <label class="form-label">Họ tên</label>
                                            <input name="fullName" class="form-control" value="${user.fullName}" />
                                        </div>

                                        <div class="col-md-3">
                                            <label class="form-label">Trạng thái</label>
                                            <select name="status" class="form-select">
                                                <option value="ACTIVE" ${user.status=='ACTIVE' ? 'selected' : '' }>
                                                    ACTIVE</option>
                                                <option value="INACTIVE" ${user.status=='INACTIVE' ? 'selected' : '' }>
                                                    INACTIVE</option>
                                            </select>
                                        </div>

                                        <div class="col-md-3">
                                            <label class="form-label">Số dư (VND)</label>
                                            <input type="number" min="0" step="1" name="balance" class="form-control"
                                                value="${user.balance}" />
                                        </div>

                                        <div class="col-md-6">
                                            <label class="form-label">Quyền hạn (Roles)</label>
                                            <div class="form-check">
                                                <input class="form-check-input" type="checkbox" name="roles"
                                                    value="USER" <c:if test="${user.hasRole('USER')}">checked</c:if>>
                                                <label class="form-check-label">USER</label>
                                            </div>
                                            <div class="form-check">
                                                <input class="form-check-input" type="checkbox" name="roles"
                                                    value="SELLER" <c:if test="${user.hasRole('SELLER')}">checked</c:if>
                                                >
                                                <label class="form-check-label">SELLER</label>
                                            </div>
                                            <div class="form-check">
                                                <input class="form-check-input" type="checkbox" name="roles"
                                                    value="ADMIN" <c:if test="${user.hasRole('ADMIN')}">checked</c:if>>
                                                <label class="form-check-label">ADMIN</label>
                                            </div>
                                        </div>

                                    </div>

                                    <div class="mt-4">
                                        <button class="btn btn-primary" type="submit">
                                            <c:out value="${isEdit ? 'Cập nhật' : 'Tạo mới'}" />
                                        </button>
                                        <a class="btn btn-light ms-2" href="<c:url value='/admin/users'/>">Hủy</a>
                                    </div>
                                </form>
                        </div>
                    </div>






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