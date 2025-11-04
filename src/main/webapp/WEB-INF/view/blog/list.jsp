<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
            <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
                <!DOCTYPE html>
                <html lang="vi">

                <head>
                    <meta charset="UTF-8">
                    <title>
                        <c:if test="${not empty pageTitle}">${pageTitle} - </c:if>MMO Market System
                    </title>
                    <jsp:include page="../common/head.jsp" />
                </head>

                <body>
                    <!-- Navbar + Sidebar -->
                    <jsp:include page="../common/navbar.jsp" />
                    <jsp:include page="../common/sidebar.jsp" />

                    <!-- Overlay để đóng/mở sidebar giống system-config -->
                    <div class="sidebar-overlay" id="sidebarOverlay" onclick="toggleSidebar()"></div>

                    <!-- Nội dung chính -->
                    <div class="content" id="content">
                        <div class="container-fluid">
                            <h1 class="mb-3">Blog</h1>

                            <!-- Search / filter -->
                            <form method="get" action="/blog/list" class="row g-2 mb-3">
                                <div class="col-md-4">
                                    <input type="text" name="q" value="${q}" class="form-control"
                                        placeholder="Tìm tiêu đề / tóm tắt...">
                                </div>

                                <!-- Giữ lại category/author nếu đang lọc qua URL (ẩn) -->
                                <c:if test="${not empty category}">
                                    <input type="hidden" name="category" value="${category}">
                                </c:if>
                                <c:if test="${not empty author}">
                                    <input type="hidden" name="author" value="${author}">
                                </c:if>

                                <div class="col-md-2">
                                    <button type="submit" class="btn btn-outline-secondary">
                                        <i class="bi bi-filter"></i> Lọc
                                    </button>
                                    <a class="btn btn-outline-secondary" href="/blog/list">
                                        <i class="bi bi-x-circle"></i> Reset
                                    </a>
                                </div>
                            </form>

                            <!-- Grid danh sách -->
                            <c:choose>
                                <c:when test="${empty posts or posts.totalElements == 0}">
                                    <div class="alert alert-info">Chưa có bài viết nào.</div>
                                </c:when>
                                <c:otherwise>
                                    <div class="row g-3">
                                        <c:forEach var="p" items="${posts.content}">
                                            <div class="col-sm-6 col-lg-4">
                                                <article class="card h-100">
                                                    <c:if test="${not empty p.thumbnailUrl}">
                                                        <img class="card-img-top"
                                                            style="height:220px; width:100%; object-fit:cover"
                                                            src="${p.thumbnailUrl}" alt="${p.title}">
                                                    </c:if>
                                                    <div class="card-body d-flex flex-column">
                                                        <h5 class="card-title">
                                                            <a href="/blog/${p.slug}">${p.title}</a>
                                                        </h5>
                                                        <p class="text-muted mb-1">
                                                            <c:if test="${not empty p.publishedAt}">
                                                                <fmt:formatDate value="${p.publishedAt}"
                                                                    pattern="dd/MM/yyyy HH:mm" />
                                                            </c:if>
                                                            <c:if test="${not empty p.categories}">
                                                                ·
                                                                <c:forEach var="cn" items="${p.categories}"
                                                                    varStatus="st">
                                                                    ${cn}<c:if test="${!st.last}">, </c:if>
                                                                </c:forEach>
                                                            </c:if>
                                                        </p>
                                                        <p class="card-text flex-grow-1">
                                                            <c:out value="${p.summary}" />
                                                        </p>
                                                        <a class="btn btn-sm btn-primary mt-auto"
                                                            href="/blog/${p.slug}">Đọc tiếp →</a>
                                                    </div>
                                                </article>
                                            </div>
                                        </c:forEach>
                                    </div>

                                    <!-- Pagination -->
                                    <c:set var="current" value="${posts.number}" />
                                    <c:set var="totalPages" value="${posts.totalPages}" />
                                    <c:if test="${totalPages > 1}">
                                        <nav class="mt-4 d-flex justify-content-center">
                                            <ul class="pagination mb-0">
                                                <!-- First -->
                                                <li class="page-item ${posts.first ? 'disabled' : ''}">
                                                    <c:url var="firstUrl" value="/blog/list">
                                                        <c:param name="page" value="0" />
                                                        <c:param name="size" value="${posts.size}" />
                                                        <c:if test="${not empty q}">
                                                            <c:param name="q" value="${q}" />
                                                        </c:if>
                                                        <c:if test="${not empty category}">
                                                            <c:param name="category" value="${category}" />
                                                        </c:if>
                                                        <c:if test="${not empty author}">
                                                            <c:param name="author" value="${author}" />
                                                        </c:if>
                                                    </c:url>
                                                    <a class="page-link" href="${firstUrl}"
                                                        aria-label="First">&laquo;&laquo;</a>
                                                </li>

                                                <!-- Prev -->
                                                <li class="page-item ${posts.first ? 'disabled' : ''}">
                                                    <c:url var="prevUrl" value="/blog/list">
                                                        <c:param name="page" value="${current-1}" />
                                                        <c:param name="size" value="${posts.size}" />
                                                        <c:if test="${not empty q}">
                                                            <c:param name="q" value="${q}" />
                                                        </c:if>
                                                        <c:if test="${not empty category}">
                                                            <c:param name="category" value="${category}" />
                                                        </c:if>
                                                        <c:if test="${not empty author}">
                                                            <c:param name="author" value="${author}" />
                                                        </c:if>
                                                    </c:url>
                                                    <a class="page-link" href="${prevUrl}"
                                                        aria-label="Previous">&laquo;</a>
                                                </li>

                                                <!-- Pages -->
                                                <c:forEach var="i" begin="0" end="${totalPages-1}">
                                                    <li class="page-item ${i == current ? 'active' : ''}">
                                                        <c:url var="pageUrl" value="/blog/list">
                                                            <c:param name="page" value="${i}" />
                                                            <c:param name="size" value="${posts.size}" />
                                                            <c:if test="${not empty q}">
                                                                <c:param name="q" value="${q}" />
                                                            </c:if>
                                                            <c:if test="${not empty category}">
                                                                <c:param name="category" value="${category}" />
                                                            </c:if>
                                                            <c:if test="${not empty author}">
                                                                <c:param name="author" value="${author}" />
                                                            </c:if>
                                                        </c:url>
                                                        <a class="page-link" href="${pageUrl}">${i+1}</a>
                                                    </li>
                                                </c:forEach>

                                                <!-- Next -->
                                                <li class="page-item ${posts.last ? 'disabled' : ''}">
                                                    <c:url var="nextUrl" value="/blog/list">
                                                        <c:param name="page" value="${current+1}" />
                                                        <c:param name="size" value="${posts.size}" />
                                                        <c:if test="${not empty q}">
                                                            <c:param name="q" value="${q}" />
                                                        </c:if>
                                                        <c:if test="${not empty category}">
                                                            <c:param name="category" value="${category}" />
                                                        </c:if>
                                                        <c:if test="${not empty author}">
                                                            <c:param name="author" value="${author}" />
                                                        </c:if>
                                                    </c:url>
                                                    <a class="page-link" href="${nextUrl}" aria-label="Next">&raquo;</a>
                                                </li>

                                                <!-- Last -->
                                                <li class="page-item ${posts.last ? 'disabled' : ''}">
                                                    <c:url var="lastUrl" value="/blog/list">
                                                        <c:param name="page" value="${totalPages-1}" />
                                                        <c:param name="size" value="${posts.size}" />
                                                        <c:if test="${not empty q}">
                                                            <c:param name="q" value="${q}" />
                                                        </c:if>
                                                        <c:if test="${not empty category}">
                                                            <c:param name="category" value="${category}" />
                                                        </c:if>
                                                        <c:if test="${not empty author}">
                                                            <c:param name="author" value="${author}" />
                                                        </c:if>
                                                    </c:url>
                                                    <a class="page-link" href="${lastUrl}"
                                                        aria-label="Last">&raquo;&raquo;</a>
                                                </li>
                                            </ul>
                                        </nav>
                                    </c:if>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                    <jsp:include page="../common/footer.jsp" />

                    <!-- Toast -->
                    <c:if test="${not empty successMessage}">
                        <script>iziToast.success({ title: 'Success!', message: '${successMessage}', position: 'topRight', timeout: 5000 });</script>
                    </c:if>
                    <c:if test="${not empty errorMessage}">
                        <script>iziToast.error({ title: 'Error!', message: '${errorMessage}', position: 'topRight', timeout: 5000 });</script>
                    </c:if>

                    <!-- Script toggle sidebar + auto-hide alert -->
                    <script>
                        function toggleSidebar() {
                            var sidebar = document.getElementById('sidebar');
                            var content = document.getElementById('content');
                            var overlay = document.getElementById('sidebarOverlay');
                            if (sidebar && content) {
                                sidebar.classList.toggle('active');
                                content.classList.toggle('shifted');
                                if (overlay) overlay.classList.toggle('active');
                            }
                        }
                        document.addEventListener('click', function (e) {
                            var sidebar = document.getElementById('sidebar');
                            var overlay = document.getElementById('sidebarOverlay');
                            var menuToggle = document.querySelector('.menu-toggle');
                            if (!sidebar) return;
                            var outside = !sidebar.contains(e.target) && (!menuToggle || !menuToggle.contains(e.target));
                            if (sidebar.classList.contains('active') && outside) toggleSidebar();
                        });
                        document.addEventListener('DOMContentLoaded', function () {
                            document.querySelectorAll('.alert').forEach(function (a) {
                                setTimeout(function () { a.style.opacity = '0'; setTimeout(function () { a.remove(); }, 300); }, 5000);
                            });
                        });
                    </script>
                </body>

                </html>