<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>

            <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

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
                            <h3 class="m-0">
                                <c:choose>
                                    <c:when test="${not empty pageTitle}">${pageTitle}</c:when>
                                    <c:when test="${not empty category.id}">Chỉnh sửa danh mục</c:when>
                                    <c:otherwise>Thêm danh mục mới</c:otherwise>
                                </c:choose>
                            </h3>

                            <c:choose>
                                <c:when test="${not empty parentCategory}">
                                    <a class="btn btn-outline-secondary"
                                        href="${pageContext.request.contextPath}/admin/categories/${parentCategory.id}/subcategories">←
                                        Quay lại</a>
                                </c:when>
                                <c:otherwise>
                                    <a class="btn btn-outline-secondary"
                                        href="${pageContext.request.contextPath}/admin/categories">← Quay lại</a>
                                </c:otherwise>
                            </c:choose>
                        </div>


                        <div class="card shadow-sm">
                            <div class="card-body">
                                <%-- Xác định chế độ edit hay create --%>
                                    <c:set var="isEdit" value="${not empty category and not empty category.id}" />

                                    <%-- Xác định action của form --%>
                                        <c:url var="formAction" value="/admin/categories/create" />
                                        <c:if test="${isEdit}">
                                            <c:url var="formAction" value="/admin/categories/update/${category.id}" />
                                        </c:if>

                                        <form method="post" action="${formAction}">
                                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />

                                            <div class="row g-3">
                                                <div class="col-md-6">
                                                    <label class="form-label">Tên danh mục</label>
                                                    <input name="name" class="form-control" value="${category.name}"
                                                        required />
                                                </div>

                                                <div class="col-md-12">
                                                    <label class="form-label">Mô tả</label>
                                                    <textarea name="description" rows="3"
                                                        class="form-control">${category.description}</textarea>
                                                </div>
                                            </div>

                                            <%--=====TRẠNG THÁI + NÚT ĐỔI (chỉ khi EDIT)=====--%>
                                                <c:if test="${isEdit}">
                                                    <div class="mb-4 d-flex align-items-center gap-3 mt-3">
                                                        <span>Trạng thái:</span>
                                                        <span id="statusBadge"
                                                            class="badge ${category.isDeleted ? 'bg-secondary' : 'bg-success'}">
                                                            <c:out
                                                                value="${category.isDeleted ? 'INACTIVE' : 'ACTIVE'}" />
                                                        </span>

                                                        <button type="submit" class="btn btn-warning ms-2"
                                                            formmethod="post"
                                                            formaction="${pageContext.request.contextPath}/admin/categories/toggle/${category.id}"
                                                            onclick="return confirm('Đổi trạng thái danh mục này?');">
                                                            Đổi trạng thái
                                                        </button>
                                                    </div>
                                                </c:if>
                                                <%--=====HẾT TRẠNG THÁI=====--%>

                                                    <div class="mt-4">
                                                        <button class="btn btn-primary" type="submit">
                                                            <c:out value="${isEdit ? 'Cập nhật' : 'Tạo mới'}" />
                                                        </button>
                                                        <a class="btn btn-light ms-2"
                                                            href="<c:url value='/admin/categories'/>">Hủy</a>
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