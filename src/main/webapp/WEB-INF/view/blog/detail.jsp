<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8" />
                <!-- Dùng các trường chắc chắn có -->
                <title>
                    <c:out value="${post.title}" /> - MMO Market System
                </title>
                <meta name="description" content="${post.summary}" />
                <meta property="og:title" content="${post.title}" />
                <meta property="og:description" content="${post.summary}" />
                <meta property="og:image" content="${post.thumbnailUrl}" />
                <meta property="twitter:card" content="summary_large_image" />
                <link rel="canonical" href="${pageContext.request.requestURL}" />

                <jsp:include page="../common/head.jsp" />
                <style>
                    .post-meta small {
                        color: #6c757d
                    }

                    .post-hero {
                        border-radius: .5rem;
                        overflow: hidden;
                        margin-bottom: 1rem
                    }

                    .post-hero img {
                        width: 100%;
                        height: 420px;
                        object-fit: cover
                    }

                    .post-layout {
                        display: grid;
                        grid-template-columns: 1fr;
                        gap: 1rem
                    }

                    @media (min-width:992px) {
                        .post-layout {
                            grid-template-columns: 1fr 300px;
                        }
                    }

                    .toc {
                        position: sticky;
                        top: 90px;
                        max-height: 70vh;
                        overflow: auto
                    }

                    .toc h6 {
                        font-size: .9rem;
                        text-transform: uppercase;
                        letter-spacing: .04em;
                        color: #6c757d
                    }

                    .toc a {
                        display: block;
                        font-size: .95rem;
                        padding: .15rem 0;
                        text-decoration: none
                    }

                    .toc .toc-h3 {
                        padding-left: .75rem
                    }

                    .share a {
                        margin-right: .5rem
                    }

                    .post-content img {
                        max-width: 100%;
                        height: auto;
                        border-radius: .25rem
                    }

                    .post-content h2 {
                        margin-top: 1.25rem
                    }

                    .badge+.badge {
                        margin-left: .25rem
                    }
                </style>
            </head>

            <body>
                <jsp:include page="../common/navbar.jsp" />
                <jsp:include page="../common/sidebar.jsp" />
                <div class="sidebar-overlay" id="sidebarOverlay" onclick="toggleSidebar()"></div>

                <div class="content" id="content">
                    <div class="container-fluid">
                        <a class="btn btn-sm btn-outline-secondary mb-3" href="/blog/list">← Về danh sách</a>

                        <h1 class="mb-2">
                            <c:out value="${post.title}" />
                        </h1>

                        <div class="post-meta mb-2">
                            <small>
                                <c:if test="${not empty post.publishedAt}">
                                    <fmt:formatDate value="${post.publishedAt}" pattern="dd/MM/yyyy HH:mm" />
                                </c:if>
                                <!-- phút đọc sẽ được thêm bằng JS: -->
                                <span id="rt-badge" class="badge bg-light text-dark d-none">0 phút đọc</span>
                                <c:if test="${not empty post.authorName}">
                                    · Tác giả: ${post.authorName}
                                </c:if>
                                <c:if test="${not empty post.categories}">
                                    ·
                                    <c:forEach var="cn" items="${post.categories}">
                                        <span class="badge bg-secondary">${cn}</span>
                                    </c:forEach>
                                </c:if>
                            </small>
                        </div>

                        <c:if test="${not empty post.thumbnailUrl}">
                            <div class="post-hero">
                                <img loading="lazy" src="${post.thumbnailUrl}" alt="${post.title}">
                            </div>
                        </c:if>

                        <div class="post-layout">
                            <article class="card">
                                <div class="card-body post-content" id="post-content">
                                    <c:choose>
                                        <c:when test="${not empty post.content}">
                                            <c:out value="${post.content}" escapeXml="false" />
                                        </c:when>
                                        <c:otherwise>
                                            <p>
                                                <c:out value="${post.summary}" />
                                            </p>
                                        </c:otherwise>
                                    </c:choose>
                                </div>

                                <div class="card-body pt-0">
                                    <div class="share">
                                        <a class="btn btn-sm btn-outline-primary" id="share-fb"><i
                                                class="bi bi-facebook"></i> Chia sẻ</a>
                                        <a class="btn btn-sm btn-outline-secondary" id="copy-link"><i
                                                class="bi bi-link-45deg"></i> Copy link</a>
                                    </div>
                                </div>
                            </article>

                            <aside class="toc d-none d-lg-block">
                                <h6>Mục lục</h6>
                                <nav id="toc"></nav>
                            </aside>
                        </div>

                        <c:if test="${not empty related}">
                            <h4 class="mt-4 mb-3">Bài liên quan</h4>
                            <div class="row g-3">
                                <c:forEach var="rp" items="${related}">
                                    <div class="col-sm-6 col-lg-4">
                                        <div class="card h-100">
                                            <div class="card-body">
                                                <h6 class="card-title"><a href="/blog/${rp.slug}">${rp.title}</a></h6>
                                                <p class="text-muted mb-0">
                                                    <c:if test="${not empty rp.publishedAt}">
                                                        <fmt:formatDate value="${rp.publishedAt}"
                                                            pattern="dd/MM/yyyy" />
                                                    </c:if>
                                                </p>
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </c:if>
                    </div>
                </div>

                <jsp:include page="../common/footer.jsp" />

                <c:if test="${not empty successMessage}">
                    <script>iziToast.success({ title: 'Success!', message: '${successMessage}', position: 'topRight', timeout: 5000 });</script>
                </c:if>
                <c:if test="${not empty errorMessage}">
                    <script>iziToast.error({ title: 'Error!', message: '${errorMessage}', position: 'topRight', timeout: 5000 });</script>
                </c:if>

                <script>
                    function toggleSidebar() {
                        var s = document.getElementById('sidebar'),
                            c = document.getElementById('content'),
                            o = document.getElementById('sidebarOverlay');
                        if (s && c) { s.classList.toggle('active'); c.classList.toggle('shifted'); if (o) o.classList.toggle('active'); }
                    }

                    (function () {
                        var content = document.getElementById('post-content');
                        if (!content) return;

                        // 1) Mục lục (TOC)
                        var toc = document.getElementById('toc');
                        var headings = content.querySelectorAll('h2, h3');
                        function slugify(t) {
                            return t.toLowerCase().trim()
                                .replace(/[^\u0100-\uFFFF\w\s-]/g, '')
                                .replace(/\s+/g, '-').replace(/-+/g, '-');
                        }
                        var html = '';
                        headings.forEach(function (h) {
                            if (!h.id) h.id = slugify(h.textContent);
                            var lvl = (h.tagName === 'H3') ? 'toc-h3' : 'toc-h2';
                            html += '<a class="' + lvl + '" href="#' + h.id + '">' + h.textContent + '</a>';
                        });
                        toc.innerHTML = html || '<span class="text-muted">Không có mục lục</span>';

                        // 2) Ảnh trong content
                        content.querySelectorAll('img').forEach(function (img) {
                            if (!img.hasAttribute('loading')) img.setAttribute('loading', 'lazy');
                            img.classList.add('img-fluid', 'rounded');
                        });

                        // 3) Phút đọc (client-side)
                        var text = content.innerText || '';
                        var words = text.trim().split(/\s+/).filter(Boolean).length;
                        var minutes = Math.max(1, Math.ceil(words / 200));
                        var badge = document.getElementById('rt-badge');
                        if (badge) { badge.textContent = minutes + ' phút đọc'; badge.classList.remove('d-none'); }

                        // 4) Share / copy link (không dùng template literal)
                        var url = window.location.href;
                        var btnShare = document.getElementById('share-fb');
                        if (btnShare) {
                            btnShare.addEventListener('click', function () {
                                window.open('https://www.facebook.com/sharer/sharer.php?u=' + encodeURIComponent(url), '_blank');
                            });
                        }
                        var btnCopy = document.getElementById('copy-link');
                        if (btnCopy) {
                            btnCopy.addEventListener('click', function () {
                                navigator.clipboard.writeText(url).then(function () {
                                    if (window.iziToast) {
                                        iziToast.success({ title: 'Copied', message: 'Đã copy link bài viết.', position: 'topRight', timeout: 2500 });
                                    }
                                });
                            });
                        }
                    })();
                </script>


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
                    document.addEventListener('click', function (event) {
                        var sidebar = document.getElementById('sidebar');
                        var overlay = document.getElementById('sidebarOverlay');
                        var menuToggle = document.querySelector('.menu-toggle');
                        if (!sidebar) return;
                        var outside = !sidebar.contains(event.target) && (!menuToggle || !menuToggle.contains(event.target));
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