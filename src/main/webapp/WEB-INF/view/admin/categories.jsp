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

                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h3 class="mb-0">
                            <c:choose>
                                <c:when test="${not empty parentCategory}">
                                    Danh mục con của: <strong>${parentCategory.name}</strong>
                                </c:when>
                                <c:otherwise>
                                    Quản lý danh mục (CHA)
                                </c:otherwise>
                            </c:choose>
                        </h3>

                        <div>
                            <c:if test="${not empty parentCategory}">
                                <a class="btn btn-primary"
                                    href="${pageContext.request.contextPath}/admin/categories/${parentCategory.id}/subcategories/add">
                                    + Thêm danh mục con
                                </a>
                                <a class="btn btn-outline-secondary ms-2"
                                    href="${pageContext.request.contextPath}/admin/categories">← Quay về danh mục
                                    CHA</a>
                            </c:if>
                        </div>
                    </div>

                    <table class="table table-hover align-middle">
                        <thead>
                            <tr>
                                <th style="width:60px">ID</th>
                                <th>Tên</th>
                                <th>Mô tả</th>
                                <th style="width:140px" class="text-center">Trạng thái</th>
                                <th style="width:220px" class="text-end">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="c" items="${categories}">
                                <tr>
                                    <td>${c.id}</td>
                                    <td>${c.name}</td>
                                    <td>${c.description}</td>
                                    <td class="text-center">
                                        <span class="badge bg-success">ACTIVE</span>
                                    </td>
                                    <td class="text-end">
                                        <c:choose>
                                            <c:when test="${empty parentCategory}">
                                                <!-- ✳️ CHẾ ĐỘ CHA: Sửa + Chi tiết -->
                                                <a class="btn btn-sm btn-outline-primary"
                                                    href="${pageContext.request.contextPath}/admin/categories/edit/${c.id}">Sửa</a>
                                                <a class="btn btn-sm btn-success ms-1"
                                                    href="${pageContext.request.contextPath}/admin/categories/${c.id}/subcategories">
                                                    Chi tiết
                                                </a>
                                            </c:when>
                                            <c:otherwise>
                                                <!-- ✳️ CHẾ ĐỘ CON: CRUD đầy đủ -->
                                                <a class="btn btn-sm btn-outline-primary"
                                                    href="${pageContext.request.contextPath}/admin/categories/edit/${c.id}">Sửa</a>

                                                <form class="d-inline" method="post"
                                                    action="${pageContext.request.contextPath}/admin/categories/delete/${c.id}"
                                                    onsubmit="return confirm('Xoá danh mục con này?');">
                                                    <button class="btn btn-sm btn-outline-danger ms-1"
                                                        type="submit">Xoá</button>
                                                </form>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>

                    <c:if test="${not empty parentCategory && not empty pageData}">
                        <div class="d-flex justify-content-between align-items-center mt-3">
                            <div>Trang ${pageData.number + 1} / ${pageData.totalPages}</div>
                            <div>
                                <c:if test="${pageData.hasPrevious()}">
                                    <a class="btn btn-sm btn-outline-secondary"
                                        href="${pageContext.request.contextPath}/admin/categories/${parentCategory.id}/subcategories?page=${pageData.number - 1}&size=${pageData.size}">
                                        ← Trước
                                    </a>
                                </c:if>
                                <c:if test="${pageData.hasNext()}">
                                    <a class="btn btn-sm btn-outline-secondary ms-2"
                                        href="${pageContext.request.contextPath}/admin/categories/${parentCategory.id}/subcategories?page=${pageData.number + 1}&size=${pageData.size}">
                                        Sau →
                                    </a>
                                </c:if>
                            </div>
                        </div>
                    </c:if>


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