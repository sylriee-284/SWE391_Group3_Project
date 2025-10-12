<%@ page contentType="text/html; charset=UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

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
                <div class="container mt-4">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h4>Danh sách sản phẩm</h4>

                        <c:url var="newUrl" value="/seller/products/new">
                            <c:param name="storeId" value="${storeId}" />
                        </c:url>
                        <a class="btn btn-primary" href="${newUrl}">➕ Thêm sản phẩm</a>
                    </div>

                    <!-- Flash message -->
                    <c:if test="${not empty success}">
                        <div class="alert alert-success alert-dismissible fade show" role="alert">
                            ${success}
                            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                        </div>
                    </c:if>
                    <c:if test="${not empty error}">
                        <div class="alert alert-danger alert-dismissible fade show" role="alert">
                            ${error}
                            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                        </div>
                    </c:if>

                    <!-- FILTER -->
                    <form class="row g-2 mb-3" method="get" action="<c:url value='/seller/products'/>">
                        <input type="hidden" name="storeId" value="${storeId}" />
                        <input type="hidden" name="size" value="${page.size}" />

                        <div class="col-md-3">
                            <input class="form-control" name="q" value="${q}" placeholder="Từ khoá tên/slug..." />
                        </div>

                        <div class="col-md-2">
                            <select class="form-select" name="status">
                                <option value="">-- Trạng thái --</option>
                                <c:forEach var="st" items="${ProductStatus}">
                                    <option value="${st}" <c:if test="${status == st}">selected</c:if>>${st}</option>
                                </c:forEach>
                            </select>
                        </div>

                        <div class="col-md-3">
                            <select class="form-select" name="parentCategoryId" onchange="this.form.submit()">
                                <option value="">-- Tùy chọn danh mục --</option>
                                <c:forEach var="pc" items="${parentCategories}">
                                    <option value="${pc.id}" <c:if test="${parentCategoryId == pc.id}">selected</c:if>
                                        >${pc.name}</option>
                                </c:forEach>
                            </select>
                        </div>

                        <div class="col-md-2">
                            <select class="form-select" name="categoryId">
                                <option value="">-- danh mục --</option>
                                <c:forEach var="c" items="${subCategories}">
                                    <option value="${c.id}" <c:if test="${categoryId == c.id}">selected</c:if>>${c.name}
                                    </option>
                                </c:forEach>
                            </select>
                        </div>

                        <div class="col-md-2">
                            <input type="date" class="form-control" name="fromDate" value="${fromDate}"
                                placeholder="Từ ngày" />
                        </div>
                        <div class="col-md-2">
                            <input type="date" class="form-control" name="toDate" value="${toDate}"
                                placeholder="Đến ngày" />
                        </div>

                        <div class="col-md-2">
                            <button class="btn btn-outline-secondary w-100">Lọc</button>
                        </div>
                    </form>

                    <div class="table-responsive">
                        <table class="table table-striped align-middle">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Tên</th>
                                    <th>Danh mục</th>
                                    <th>Giá</th>
                                    <th>Trạng thái</th>
                                    <th>Tồn khả dụng</th>
                                    <th class="text-end">Hành động</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="p" items="${page.content}">
                                    <tr>
                                        <td>#${p.id}</td>
                                        <td>
                                            <div class="fw-semibold">${p.name}</div>
                                            <div class="text-muted small">${p.slug}</div>
                                        </td>
                                        <td>${p.category != null ? p.category.name : '-'}</td>
                                        <td>
                                            <fmt:formatNumber value="${p.price}" type="currency" currencySymbol="₫" />
                                        </td>
                                        <td><span
                                                class="badge ${p.status=='ACTIVE'?'bg-success':'bg-secondary'}">${p.status}</span>
                                        </td>
                                        <td>${p.stock}</td>
                                        <td class="text-end">
                                            <c:url var="toggleUrl" value="/seller/products/${p.id}/toggle">
                                                <c:param name="storeId" value="${storeId}" />
                                            </c:url>
                                            <form class="d-inline" method="post" action="${toggleUrl}">
                                                <input type="hidden" name="to"
                                                    value="${p.status=='ACTIVE'?'INACTIVE':'ACTIVE'}" />
                                                <c:if test="${not empty _csrf}">
                                                    <input type="hidden" name="${_csrf.parameterName}"
                                                        value="${_csrf.token}" />
                                                </c:if>
                                                <button
                                                    class="btn btn-sm ${p.status=='ACTIVE'?'btn-outline-warning':'btn-outline-success'}">
                                                    ${p.status=='ACTIVE'?'Tắt':'Bật'}
                                                </button>
                                            </form>

                                            <c:url var="editUrl" value="/seller/products/${p.id}/edit">
                                                <c:param name="storeId" value="${storeId}" />
                                            </c:url>
                                            <a class="btn btn-sm btn-outline-primary" href="${editUrl}">Sửa</a>

                                            <c:url var="deleteUrl" value="/seller/products/${p.id}/delete">
                                                <c:param name="storeId" value="${storeId}" />
                                            </c:url>
                                            <form class="d-inline" method="post" action="${deleteUrl}"
                                                onsubmit="return confirm('Ẩn sản phẩm này?');">
                                                <c:if test="${not empty _csrf}">
                                                    <input type="hidden" name="${_csrf.parameterName}"
                                                        value="${_csrf.token}" />
                                                </c:if>
                                                <!-- <button class="btn btn-sm btn-outline-danger">Ẩn sản phẩm</button> -->
                                            </form>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>

                    <c:if test="${page.totalPages > 1}">
                        <nav>
                            <ul class="pagination">
                                <c:if test="${!page.first}">
                                    <c:url var="prevUrl" value="/seller/products">
                                        <c:param name="storeId" value="${storeId}" />
                                        <c:param name="q" value="${q}" />
                                        <c:param name="status" value="${status}" />
                                        <c:param name="parentCategoryId" value="${parentCategoryId}" />
                                        <c:param name="categoryId" value="${categoryId}" />
                                        <c:param name="fromDate" value="${fromDate}" />
                                        <c:param name="toDate" value="${toDate}" />
                                        <c:param name="size" value="${page.size}" />
                                        <c:param name="page" value="${page.number - 1}" />
                                    </c:url>
                                    <li class="page-item"><a class="page-link" href="${prevUrl}">&laquo;</a></li>
                                </c:if>

                                <c:forEach begin="0" end="${page.totalPages-1}" var="i">
                                    <c:url var="pageUrl" value="/seller/products">
                                        <c:param name="storeId" value="${storeId}" />
                                        <c:param name="q" value="${q}" />
                                        <c:param name="status" value="${status}" />
                                        <c:param name="parentCategoryId" value="${parentCategoryId}" />
                                        <c:param name="categoryId" value="${categoryId}" />
                                        <c:param name="fromDate" value="${fromDate}" />
                                        <c:param name="toDate" value="${toDate}" />
                                        <c:param name="size" value="${page.size}" />
                                        <c:param name="page" value="${i}" />
                                    </c:url>
                                    <li class="page-item ${i==page.number?'active':''}">
                                        <a class="page-link" href="${pageUrl}">${i+1}</a>
                                    </li>
                                </c:forEach>

                                <c:if test="${!page.last}">
                                    <c:url var="nextUrl" value="/seller/products">
                                        <c:param name="storeId" value="${storeId}" />
                                        <c:param name="q" value="${q}" />
                                        <c:param name="status" value="${status}" />
                                        <c:param name="parentCategoryId" value="${parentCategoryId}" />
                                        <c:param name="categoryId" value="${categoryId}" />
                                        <c:param name="fromDate" value="${fromDate}" />
                                        <c:param name="toDate" value="${toDate}" />
                                        <c:param name="size" value="${page.size}" />
                                        <c:param name="page" value="${page.number + 1}" />
                                    </c:url>
                                    <li class="page-item"><a class="page-link" href="${nextUrl}">&raquo;</a></li>
                                </c:if>
                            </ul>
                        </nav>
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