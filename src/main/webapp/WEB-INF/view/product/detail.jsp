<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
            <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

                <!DOCTYPE html>
                <html lang="en">

                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>
                        Product detail
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
                        <!-- Page Content will be inserted here -->

                        <!-- Main Content -->
                        <div class="content" id="content">
                            <br />

                            <div class="container-fluid">
                                <!-- Breadcrumb -->
                                <nav aria-label="breadcrumb">
                                    <ol class="breadcrumb">
                                        <li class="breadcrumb-item"><a href="<c:url value='/'/>"
                                                class="text-decoration-none">Trang chủ</a></li>
                                        <li class="breadcrumb-item">
                                            <a href="<c:url value='/category/${product.category.parent.name.toLowerCase()}'/>"
                                                class="text-decoration-none">${product.category.parent.name}</a>
                                        </li>
                                        <li class="breadcrumb-item">
                                            <a href="<c:url value='/category/${product.category.parent.name.toLowerCase()}?childCategory=${product.category.id}'/>"
                                                class="text-decoration-none">${product.category.name}</a>
                                        </li>
                                        <li class="breadcrumb-item active" aria-current="page">${product.name}</li>
                                    </ol>
                                </nav>

                                <div class="row">
                                    <!-- Product Image -->
                                    <div class="col-lg-6 mb-4">
                                        <div class="text-center">
                                            <c:choose>
                                                <c:when test="${not empty product.productUrl}">
                                                    <img src="${product.productUrl}" alt="${product.name}"
                                                        class="product-image">
                                                </c:when>
                                                <c:otherwise>
                                                    <div class="product-placeholder">
                                                        <div class="text-center">
                                                            <i class="fas fa-image fa-4x text-muted mb-3"></i>
                                                            <p class="text-muted">Chưa có hình ảnh</p>
                                                        </div>
                                                    </div>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </div>

                                    <!-- Product Info -->
                                    <div class="col-lg-6">
                                        <div class="info-card">
                                            <!-- Product Name -->
                                            <h1 class="mb-3">${product.name}</h1>

                                            <!-- Rating Stars -->
                                            <div class="mb-3">
                                                <div class="rating">
                                                    <c:forEach begin="1" end="5" var="star">
                                                        <i
                                                            class="fas fa-star ${star <= product.rating ? 'text-warning' : 'text-muted'}"></i>
                                                    </c:forEach>
                                                    <span class="ms-2">${product.rating}/5</span>
                                                </div>
                                            </div>

                                            <!-- Category Badge -->
                                            <div class="mb-3">
                                                <span class="badge bg-success fs-6">
                                                    <i class="fas fa-tag"></i> ${product.category.name}
                                                </span>
                                            </div>

                                            <!-- Price -->
                                            <div class="mb-4">
                                                <div class="price">
                                                    <fmt:formatNumber value="${product.price}" type="currency"
                                                        currencySymbol="" maxFractionDigits="0" />đ
                                                </div>
                                            </div>

                                            <!-- Shop Information -->
                                            <div class="mb-4 shop-info">

                                                <div class="d-flex align-items-center">

                                                    <div class="flex-grow-1">

                                                        <h6 class="mb-1 text-dark">Người bán: ${shop.storeName}</h6>


                                                        <div>
                                                            <span
                                                                class="badge ${shop.status == 'ACTIVE' ? 'bg-success' : 'bg-warning'}">
                                                                <i class="fas fa-circle me-1"></i>${shop.status ==
                                                                'ACTIVE' ? 'Đang hoạt động' : 'Tạm ngưng'}
                                                            </span>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>



                                            <!-- Stock Status -->
                                            <div class="mb-4">
                                                <span
                                                    class="stock-indicator ${product.stock > 10 ? 'stock-available' : (product.stock > 0 ? 'stock-low' : 'stock-out')}">
                                                    <i class="fas fa-boxes"></i>
                                                    <c:choose>
                                                        <c:when test="${product.stock > 10}">
                                                            Còn hàng (${product.stock} sản phẩm)
                                                        </c:when>
                                                        <c:when test="${product.stock > 0}">
                                                            Sắp hết hàng (${product.stock} sản phẩm)
                                                        </c:when>
                                                        <c:otherwise>
                                                            Hết hàng
                                                        </c:otherwise>
                                                    </c:choose>
                                                </span>
                                            </div>

                                            <!-- Product Status -->
                                            <div class="mb-4">
                                                <span
                                                    class="badge ${product.status == 'ACTIVE' ? 'bg-success' : 'bg-warning'} fs-6">
                                                    <i class="fas fa-circle"></i>
                                                    ${product.status == 'ACTIVE' ? 'Đang bán' : 'Tạm ngưng'}
                                                </span>
                                            </div>

                                            <!-- Quantity and Action Buttons -->
                                            <c:if test="${product.status == 'ACTIVE' && product.stock > 0}">
                                                <div class="action-buttons">
                                                    <form id="productForm" method="post">
                                                        <!-- Quantity Selection -->
                                                        <div class="row mb-4">
                                                            <div class="col-md-6">
                                                                <label class="form-label fw-bold">Số lượng:</label>
                                                                <input type="number" id="quantity" name="quantity"
                                                                    class="form-control quantity-input" value="1"
                                                                    min="1" max="${product.stock}"
                                                                    style="width: 100px;">
                                                            </div>
                                                        </div>

                                                        <!-- Action Button -->
                                                        <div class="d-grid">
                                                            <button type="button" class="btn btn-buy-now btn-lg"
                                                                onclick="buyNow()">
                                                                <i class="fas fa-bolt"></i> Mua ngay
                                                            </button>
                                                        </div>
                                                    </form>
                                                </div>
                                            </c:if>

                                            <c:if test="${product.status != 'ACTIVE' || product.stock <= 0}">
                                                <div class="alert alert-warning text-center">
                                                    <i class="fas fa-exclamation-triangle"></i>
                                                    Sản phẩm hiện tại không thể mua
                                                </div>
                                            </c:if>
                                        </div>
                                    </div>
                                </div>

                                <!-- Product Description -->
                                <div class="row mt-4">
                                    <div class="col-12">
                                        <div class="info-card">
                                            <h3 class="mb-3">
                                                <i class="fas fa-info-circle text-success"></i> Mô tả sản phẩm
                                            </h3>
                                            <c:choose>
                                                <c:when test="${not empty product.description}">
                                                    <div class="product-description">
                                                        <p>
                                                            ${product.description}</p>
                                                    </div>
                                                </c:when>
                                                <c:otherwise>
                                                    <p class="text-muted fst-italic">Chưa có mô tả cho sản phẩm này.
                                                    </p>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </div>
                                </div>




                            </div>
                        </div>

                        <script>
                            // Toggle sidebar function
                            function toggleSidebar() {
                                var sidebar = document.getElementById('sidebar');
                                var content = document.getElementById('content');
                                sidebar.classList.toggle('active');
                                content.classList.toggle('shifted');
                            }



                            // Buy now function
                            function buyNow() {
                                var form = document.getElementById('productForm');
                                form.action = '<c:url value="/product/${product.id}/buy-now"/>';
                                form.submit();
                            }

                            // Validate quantity input
                            document.getElementById('quantity').addEventListener('input', function () {
                                var value = parseInt(this.value);
                                var min = parseInt(this.min);
                                var max = parseInt(this.max);

                                if (value < min) this.value = min;
                                if (value > max) this.value = max;
                            });
                        </script>

                        <!-- iziToast JS -->
                        <script src="https://cdnjs.cloudflare.com/ajax/libs/izitoast/1.4.0/js/iziToast.min.js"></script>

                        <!-- Script to display notifications using iziToast -->
                        <c:if test="${not empty successMessage}">
                            <script>
                                iziToast.success({
                                    title: 'Thành công!',
                                    message: '${successMessage}',
                                    position: 'topRight',
                                    timeout: 5000
                                });
                            </script>
                        </c:if>

                        <c:if test="${not empty errorMessage}">
                            <script>
                                iziToast.error({
                                    title: 'Lỗi!',
                                    message: '${errorMessage}',
                                    position: 'topRight',
                                    timeout: 5000
                                });
                            </script>
                        </c:if>


                        <!-- Include Footer -->
                        <jsp:include page="../common/footer.jsp" />





                    </div>



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