<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <title>
                    <c:if test="${not empty pageTitle}">${pageTitle} - </c:if>MMO Market System
                </title>

                <jsp:include page="../common/head.jsp" />
                <link href="${pageContext.request.contextPath}/resources/css/blog.css" rel="stylesheet" />

                <style>
                    /* Layout: footer luôn ở đáy */
                    html,
                    body {
                        height: 100%;
                    }

                    body {
                        min-height: 100vh;
                        display: flex;
                        flex-direction: column;
                    }

                    main.content {
                        flex: 1 0 auto;
                    }

                    .footer {
                        flex-shrink: 0;
                        position: relative;
                        z-index: 1030;
                    }

                    /* Nút menu phụ (nếu dùng) */
                    .menu-toggle {
                        cursor: pointer;
                        padding: 10px;
                        z-index: 1031;
                        transition: transform .3s
                    }

                    .menu-toggle:hover {
                        transform: scale(1.1)
                    }

                    .menu-toggle.active {
                        transform: rotate(90deg)
                    }
                </style>
            </head>

            <body>
                <!-- Navbar + Sidebar -->
                <jsp:include page="../common/navbar.jsp" />
                <jsp:include page="../common/sidebar.jsp" />

                <!-- Overlay -->
                <div class="sidebar-overlay" id="sidebarOverlay" onclick="toggleSidebar()"></div>

                <!-- Main -->
                <main class="content" id="content">
                    <div class="container-fluid">
                        <h1 class="mb-3">Blog</h1>

                        <!-- Search / Filter -->
                        <form method="get" action="/blog/list" class="row g-2 mb-3">
                            <div class="col-md-4">
                                <input type="text" name="q" value="${q}" class="form-control"
                                    placeholder="Tìm tiêu đề / tóm tắt...">
                            </div>

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

                        <div class="row">
                            <!-- Danh sách bài viết -->
                            <div class="col-lg-9">
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
                                                                style="height:220px;object-fit:cover"
                                                                src="${p.thumbnailUrl}" alt="${p.title}">
                                                        </c:if>
                                                        <div class="card-body d-flex flex-column">
                                                            <h5 class="card-title"><a
                                                                    href="/blog/${p.slug}">${p.title}</a></h5>
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

                                        <!-- Phân trang -->
                                        <c:if test="${posts.totalPages > 1}">
                                            <nav class="mt-4 mb-5">
                                                <ul class="pagination justify-content-center mb-0">
                                                    <!-- First -->
                                                    <li class="page-item ${posts.first ? 'disabled' : ''}">
                                                        <c:url var="firstUrl" value="/blog/list">
                                                            <c:param name="page" value="0" />
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
                                                        <a class="page-link" href="${firstUrl}">&laquo;</a>
                                                    </li>

                                                    <!-- Pages -->
                                                    <c:forEach begin="0" end="${posts.totalPages-1}" var="i">
                                                        <li class="page-item ${posts.number == i ? 'active' : ''}">
                                                            <c:url var="pageUrl" value="/blog/list">
                                                                <c:param name="page" value="${i}" />
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

                                                    <!-- Last -->
                                                    <li class="page-item ${posts.last ? 'disabled' : ''}">
                                                        <c:url var="lastUrl" value="/blog/list">
                                                            <c:param name="page" value="${posts.totalPages-1}" />
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
                                                        <a class="page-link" href="${lastUrl}">&raquo;</a>
                                                    </li>
                                                </ul>
                                            </nav>
                                        </c:if>
                                    </c:otherwise>
                                </c:choose>
                            </div>

                            <!-- Sidebar thể loại -->
                            <div class="col-lg-3">
                                <div class="card">
                                    <div class="card-header">
                                        <h5 class="card-title mb-0">Thể loại</h5>
                                    </div>
                                    <div class="card-body p-0">
                                        <div class="list-group list-group-flush">
                                            <div class="list-group-item">
                                                <div class="d-flex justify-content-between align-items-center">
                                                    <a href="${pageContext.request.contextPath}/blog/list?category=Facebook"
                                                        class="text-decoration-none ${category eq 'Facebook' ? 'fw-bold text-primary' : ''}">
                                                        <i class="bi bi-facebook me-2"></i>Facebook
                                                    </a>
                                                    <span
                                                        class="badge bg-primary rounded-pill">${categories['Facebook']}</span>
                                                </div>
                                            </div>

                                            <div class="list-group-item">
                                                <div class="d-flex justify-content-between align-items-center">
                                                    <a href="${pageContext.request.contextPath}/blog/list?category=TikTok"
                                                        class="text-decoration-none ${category eq 'TikTok' ? 'fw-bold text-primary' : ''}">
                                                        <i class="bi bi-tiktok me-2"></i>TikTok
                                                    </a>
                                                    <span
                                                        class="badge bg-dark rounded-pill">${categories['TikTok']}</span>
                                                </div>
                                            </div>

                                            <div class="list-group-item">
                                                <div class="d-flex justify-content-between align-items-center">
                                                    <a href="${pageContext.request.contextPath}/blog/list?category=YouTube"
                                                        class="text-decoration-none ${category eq 'YouTube' ? 'fw-bold text-primary' : ''}">
                                                        <i class="bi bi-youtube me-2"></i>YouTube
                                                    </a>
                                                    <span
                                                        class="badge bg-danger rounded-pill">${categories['YouTube']}</span>
                                                </div>
                                            </div>

                                            <div class="list-group-item">
                                                <div class="d-flex justify-content-between align-items-center">
                                                    <a href="${pageContext.request.contextPath}/blog/list?category=Marketing"
                                                        class="text-decoration-none ${category eq 'Marketing' ? 'fw-bold text-primary' : ''}">
                                                        <i class="bi bi-graph-up me-2"></i>Marketing
                                                    </a>
                                                    <span
                                                        class="badge bg-success rounded-pill">${categories['Marketing']}</span>
                                                </div>
                                            </div>

                                            <div class="list-group-item">
                                                <div class="d-flex justify-content-between align-items-center">
                                                    <a href="${pageContext.request.contextPath}/blog/list?category=Other"
                                                        class="text-decoration-none ${category eq 'Other' ? 'fw-bold text-primary' : ''}">
                                                        <i class="bi bi-three-dots me-2"></i>Khác
                                                    </a>
                                                    <span
                                                        class="badge bg-secondary rounded-pill">${categories['Other']}</span>
                                                </div>
                                            </div>

                                        </div>
                                    </div>
                                </div>
                            </div><!-- /.col-lg-3 -->
                        </div><!-- /.row -->

                    </div><!-- /.container-fluid -->
                </main><!-- /.content -->

                <!-- Footer -->
                <jsp:include page="../common/footer.jsp" />

                <!-- Toast -->
                <c:if test="${not empty successMessage}">
                    <script>iziToast.success({ title: 'Success!', message: '${successMessage}', position: 'topRight', timeout: 5000 });</script>
                </c:if>
                <c:if test="${not empty errorMessage}">
                    <script>iziToast.error({ title: 'Error!', message: '${errorMessage}', position: 'topRight', timeout: 5000 });</script>
                </c:if>

                <!-- Scripts -->
                <script>
                    function toggleSidebar() {
                        var sidebar = document.getElementById('sidebar');
                        var content = document.getElementById('content');
                        var overlay = document.getElementById('sidebarOverlay');
                        var toggle = document.querySelector('.menu-toggle');
                        if (sidebar && content) {
                            sidebar.classList.toggle('active');
                            content.classList.toggle('shifted');
                            if (toggle) toggle.classList.toggle('active');
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