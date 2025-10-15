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

                    <%-- Cờ chế độ --%>
                        <c:set var="isEdit" value="${not empty category.id}" />
                        <c:set var="isChild"
                            value="${not empty parentCategory or (not empty category.parentId and category.parentId != 0)}" />

                        <%-- Tiêu đề + Quay lại --%>
                            <div class="d-flex justify-content-between align-items-center mt-4 mb-3">
                                <h3 class="m-0">
                                    <c:choose>
                                        <c:when test="${isEdit}">
                                            <c:choose>
                                                <c:when test="${isChild}">Sửa danh mục con</c:when>
                                                <c:otherwise>Sửa danh mục CHA</c:otherwise>
                                            </c:choose>
                                        </c:when>
                                        <c:otherwise>
                                            <c:choose>
                                                <c:when test="${isChild}">
                                                    Thêm danh mục con cho:
                                                    <strong>
                                                        <c:out
                                                            value="${(not empty parentCategory) ? parentCategory.name : ''}" />
                                                    </strong>
                                                </c:when>
                                                <c:otherwise>Thêm danh mục CHA</c:otherwise>
                                            </c:choose>
                                        </c:otherwise>
                                    </c:choose>
                                </h3>

                                <div>
                                    <c:choose>
                                        <c:when test="${isChild}">
                                            <a class="btn btn-outline-secondary"
                                                href="${pageContext.request.contextPath}/admin/categories/${isEdit ? category.parentId : parentCategory.id}/subcategories">←
                                                Quay lại</a>
                                        </c:when>
                                        <c:otherwise>
                                            <a class="btn btn-outline-secondary"
                                                href="${pageContext.request.contextPath}/admin/categories">← Quay
                                                lại</a>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>

                            <%-- Xác định action cho form lưu (không chứa toggle) --%>
                                <c:choose>
                                    <c:when test="${isEdit}">
                                        <c:set var="formAction"
                                            value="${pageContext.request.contextPath}/admin/categories/update/${category.id}" />
                                    </c:when>
                                    <c:otherwise>
                                        <c:choose>
                                            <c:when test="${isChild}">
                                                <c:set var="formAction"
                                                    value="${pageContext.request.contextPath}/admin/categories/${(not empty category.parentId) ? category.parentId : parentCategory.id}/subcategories/create" />
                                            </c:when>
                                            <c:otherwise>
                                                <c:set var="formAction"
                                                    value="${pageContext.request.contextPath}/admin/categories/create" />
                                            </c:otherwise>
                                        </c:choose>
                                    </c:otherwise>
                                </c:choose>

                                <div class="card shadow-sm">
                                    <div class="card-body">
                                        <%-- FORM LƯU (create/update). KHÔNG lồng form toggle ở trong --%>
                                            <form method="post" action="${formAction}">
                                                <input type="hidden" name="${_csrf.parameterName}"
                                                    value="${_csrf.token}" />

                                                <c:if test="${isChild}">
                                                    <input type="hidden" name="parentId"
                                                        value="${isEdit ? category.parentId : (not empty parentCategory ? parentCategory.id : category.parentId)}" />
                                                </c:if>

                                                <div class="row g-3">
                                                    <div class="col-md-12">
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

                                                <div class="mt-4">
                                                    <button class="btn btn-primary" type="submit">
                                                        <c:out value="${isEdit ? 'Cập nhật' : 'Tạo mới'}" />
                                                    </button>

                                                    <c:choose>
                                                        <c:when test="${isChild}">
                                                            <a class="btn btn-light ms-2"
                                                                href="${pageContext.request.contextPath}/admin/categories/${isEdit ? category.parentId : parentCategory.id}/subcategories">Hủy</a>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <a class="btn btn-light ms-2"
                                                                href="${pageContext.request.contextPath}/admin/categories">Hủy</a>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </form>

                                            <%-- FORM NHỎ TÁCH RIÊNG: Toggle trạng thái (POST /toggle/{id}) --%>
                                                <c:if test="${isEdit}">
                                                    <div class="mt-3 d-flex align-items-center gap-3">
                                                        <span>Trạng thái:</span>
                                                        <form method="post"
                                                            action="${pageContext.request.contextPath}/admin/categories/toggle/${category.id}"
                                                            class="d-inline">
                                                            <input type="hidden" name="${_csrf.parameterName}"
                                                                value="${_csrf.token}" />
                                                            <button type="submit"
                                                                class="badge ${category.isActive ? 'bg-success' : 'bg-secondary'} border-0"
                                                                style="cursor:pointer" title="Nhấp để đổi trạng thái">
                                                                <c:out
                                                                    value="${category.isActive ? 'ACTIVE' : 'INACTIVE'}" />
                                                            </button>
                                                        </form>
                                                    </div>
                                                </c:if>

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