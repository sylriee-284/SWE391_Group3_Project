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
                <div class="content" id="content">
                    <div class="container mt-4">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <h4>
                                <c:choose>
                                    <c:when test="${formMode=='CREATE'}">➕ Thêm sản phẩm</c:when>
                                    <c:otherwise>✏️ Cập nhật sản phẩm #${form.id}</c:otherwise>
                                </c:choose>
                            </h4>

                            <c:url var="backUrl" value="/seller/products">
                                <c:param name="storeId" value="${storeId}" />
                            </c:url>
                            <a class="btn btn-outline-secondary" href="${backUrl}">← Danh sách</a>
                        </div>

                        <c:if test="${not empty error}">
                            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                                ${error}
                                <button type="button" class="btn-close" data-bs-dismiss="alert"
                                    aria-label="Close"></button>
                            </div>
                        </c:if>

                        <%-- Build form action trước, không để JSTL trong thuộc tính --%>
                            <c:choose>
                                <c:when test="${formMode=='CREATE'}">
                                    <c:url var="formAction" value="/seller/products">
                                        <c:param name="storeId" value="${storeId}" />
                                    </c:url>
                                </c:when>
                                <c:otherwise>
                                    <c:url var="formAction" value="/seller/products/${form.id}">
                                        <c:param name="storeId" value="${storeId}" />
                                    </c:url>
                                </c:otherwise>
                            </c:choose>

                            <form method="post" action="${formAction}">
                                <c:if test="${not empty _csrf}">
                                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                                </c:if>

                                <div class="card">
                                    <div class="card-body row g-3">

                                        <div class="col-md-6">
                                            <label class="form-label">Tên sản phẩm</label>
                                            <input class="form-control" name="name" value="${form.name}" required />
                                        </div>

                                        <div class="col-md-6">
                                            <label class="form-label">Slug (duy nhất trong store)</label>
                                            <input class="form-control" name="slug" value="${form.slug}" />
                                        </div>

                                        <div class="col-md-6">
                                            <label class="form-label">Danh mục</label>
                                            <select class="form-select" name="category.id" required>
                                                <option value="">-- Chọn danh mục --</option>
                                                <c:forEach var="c" items="${categories}">
                                                    <option value="${c.id}" <c:if
                                                        test="${form.category != null && form.category.id == c.id}">
                                                        selected
                                                        </c:if>>
                                                        ${c.name}
                                                    </option>
                                                </c:forEach>
                                            </select>
                                        </div>

                                        <div class="col-md-6">
                                            <label class="form-label">Giá</label>
                                            <input class="form-control" type="number" step="1000" min="0" name="price"
                                                value="${form.price}" required />
                                        </div>

                                        <div class="col-md-12">
                                            <label class="form-label">Đường dẫn tham khảo (product_url)</label>
                                            <input class="form-control" name="productUrl" value="${form.productUrl}" />
                                        </div>

                                        <div class="col-md-12">
                                            <label class="form-label">Mô tả</label>
                                            <textarea class="form-control" rows="4"
                                                name="description">${form.description}</textarea>
                                        </div>

                                        <div class="col-md-4">
                                            <label class="form-label">Trạng thái</label>
                                            <select class="form-select" name="status">
                                                <option value="ACTIVE" ${form.status=='ACTIVE' ? 'selected' : '' }>
                                                    ACTIVE
                                                </option>
                                                <option value="INACTIVE" ${form.status=='INACTIVE' ? 'selected' : '' }>
                                                    INACTIVE
                                                </option>
                                            </select>
                                        </div>

                                        <div class="col-md-4">
                                            <label class="form-label">Tồn hiển thị (stock)</label>
                                            <input class="form-control" type="number" min="0" name="stock"
                                                value="${form.stock}" />
                                        </div>

                                        <div class="col-md-4 d-flex align-items-end justify-content-end">
                                            <button class="btn btn-primary px-4">
                                                <c:choose>
                                                    <c:when test="${formMode=='CREATE'}">Lưu mới</c:when>
                                                    <c:otherwise>Lưu thay đổi</c:otherwise>
                                                </c:choose>
                                            </button>
                                        </div>

                                    </div>
                                </div>
                            </form>
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