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
                    <!-- Page-specific styles to enlarge product images and modal -->
                    <style>
                        /* Main product image: fill its column, keep aspect ratio, limit height */
                        .product-image {
                            width: 100%;
                            height: auto;
                            object-fit: contain;
                            max-height: 700px;
                            /* allow larger display on wide screens */
                            display: inline-block;
                        }

                        /* Make the product/info row stretch so image height matches info card */
                        .product-detail-row {
                            display: flex;
                            align-items: stretch;
                        }

                        .product-detail-row>[class*="col-"] {
                            display: flex;
                            flex-direction: column;
                        }

                        /* Ensure the left column centers the image and lets it grow */
                        .product-detail-row .col-lg-7 {
                            justify-content: center;
                        }

                        /* Let the image take full column height (keeps aspect via object-fit) */
                        .product-detail-row .product-image {
                            height: 100%;
                            max-height: none;
                            object-fit: contain;
                        }

                        /* Modal product image */
                        #product-modal-image {
                            width: 100%;
                            height: auto;
                            object-fit: contain;
                            max-height: 480px;
                        }

                        /* Make modal dialog wider on larger screens */
                        @media (min-width: 768px) {
                            .modal-dialog.modal-dialog-centered {
                                max-width: 900px;
                                width: 90%;
                            }
                        }
                    </style>
                </head>

                <body>
                    <!-- Include Navbar -->
                    <jsp:include page="../common/navbar.jsp" />

                    <!-- Include Sidebar -->
                    <jsp:include page="../common/sidebar.jsp" />

                    <!-- Sidebar Overlay for Mobile -->
                    <div class="sidebar-overlay" id="sidebarOverlay" onclick="toggleSidebar()"></div>

                    <!-- Main Content Area -->
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

                            <div class="row product-detail-row">
                                <!-- Product Image -->
                                <div class="col-lg-7 mb-4">
                                    <div class="text-center">
                                        <img id="product-main-image"
                                            src="<c:url value='/images/products/${product.id}.png'/>"
                                            data-fallback-url="<c:out value='${product.productUrl}'/>"
                                            alt="${product.name}" class="product-image"
                                            onerror="handleImgError(this)" />
                                    </div>
                                </div>

                                <!-- Product Info -->
                                <div class="col-lg-5">
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
                                                <small class="ms-1 text-muted">
                                                    ${product.rating}/5
                                                    <span class="text-muted"> Total review:
                                                        ${product.ratingCount}</span>
                                                </small>
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
                                                    <h6 class="mb-1 text-dark">Người bán:
                                                        <a href="<c:url value='/store/${shop.id}'/>"
                                                            class="text-decoration-none text-dark">${shop.storeName}</a>
                                                    </h6>
                                                </div>
                                            </div>
                                        </div>



                                        <!-- Stock Status -->
                                        <div class="mb-4">
                                            <span
                                                class="stock-indicator ${dynamicStock > 10 ? 'stock-available' : (dynamicStock > 0 ? 'stock-low' : 'stock-out')}">
                                                <i class="fas fa-boxes"></i>
                                                <c:choose>
                                                    <c:when test="${dynamicStock > 10}">
                                                        Còn hàng (${dynamicStock} sản phẩm)
                                                    </c:when>
                                                    <c:when test="${dynamicStock > 0}">
                                                        Sắp hết hàng (${dynamicStock} sản phẩm)
                                                    </c:when>
                                                    <c:otherwise>
                                                        Hết hàng
                                                    </c:otherwise>
                                                </c:choose>
                                            </span>
                                        </div>

                                        <!-- Quantity and Action Buttons -->
                                        <c:if test="${product.status == 'ACTIVE' && dynamicStock > 0}">
                                            <div class="action-buttons">
                                                <!-- Quantity Selection -->
                                                <div class="row mb-4">
                                                    <div class="col-md-6">
                                                        <label class="form-label fw-bold">Số lượng:</label>
                                                        <input type="number" id="quantity" name="quantity"
                                                            class="form-control quantity-input" value="1" min="1"
                                                            max="${dynamicStock}" style="width: 100px;">
                                                    </div>
                                                </div>

                                                <!-- Action Button -->
                                                <div class="d-grid">
                                                    <button type="button" class="btn btn-buy-now btn-lg"
                                                        onclick="buyNow()">
                                                        <i class="fas fa-bolt"></i> Mua ngay
                                                    </button>
                                                </div>
                                            </div>
                                        </c:if>

                                        <c:if test="${product.status != 'ACTIVE' || dynamicStock <= 0}">
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

                        // Check authentication status
                        var isAuthenticated = <c:choose><c:when test="${pageContext.request.userPrincipal != null}">true</c:when><c:otherwise>false</c:otherwise></c:choose>;

                        // Get user balance (snapshot when page loads)
                        var userBalance = <c:choose><c:when test="${userBalance != null}">${userBalance}</c:when><c:otherwise>0</c:otherwise></c:choose>;

                        // Buy now function - Show modal
                        function buyNow() {
                            // Check if user is authenticated
                            if (!isAuthenticated) {
                                // User not logged in - redirect to login with error message
                                window.location.href = '<c:url value="/login"/>?errorMessage=' + encodeURIComponent('Bạn cần đăng nhập để thực hiện chức năng này');
                                return;
                            }

                            // User is logged in - proceed with buy now
                            var quantity = document.getElementById('quantity').value;
                            document.getElementById('modalQuantity').value = quantity;

                            // Reset button to default state
                            var confirmButton = document.querySelector('#buyNowModal .modal-footer .btn:last-child');
                            if (confirmButton) {
                                confirmButton.disabled = false;
                                confirmButton.innerHTML = '<i class="fas fa-check"></i> Xác nhận mua';
                                confirmButton.classList.remove('btn-warning');
                                confirmButton.classList.remove('btn-secondary');
                                confirmButton.classList.add('btn-success');
                            }

                            // Hide any existing balance status message
                            var existingMessage = document.getElementById('balanceStatus');
                            if (existingMessage) {
                                existingMessage.remove();
                            }

                            updateTotalPrice();

                            // Show modal
                            var modal = new bootstrap.Modal(document.getElementById('buyNowModal'));
                            modal.show();
                        }

                        // Update total price in modal
                        function updateTotalPrice() {
                            var quantity = parseInt(document.getElementById('modalQuantity').value) || 1;
                            var price = parseFloat('${product.price}');
                            var total = quantity * price;

                            document.getElementById('totalPrice').textContent =
                                new Intl.NumberFormat('vi-VN').format(total) + 'đ';

                            // Check balance and update button state
                            updateConfirmButtonState(total);
                        }

                        // Update confirm button state based on balance
                        function updateConfirmButtonState(totalAmount) {
                            var confirmButton = document.querySelector('#buyNowModal .modal-footer .btn:last-child');
                            var balanceMessage = document.getElementById('balanceStatus');

                            if (userBalance < totalAmount) {
                                // Insufficient balance - disable button
                                if (confirmButton) {
                                    confirmButton.disabled = true;
                                    confirmButton.classList.remove('btn-success');
                                    confirmButton.classList.remove('btn-warning');
                                    confirmButton.classList.add('btn-secondary');
                                }

                                // Show balance status message
                                var messageContainer = document.getElementById('balanceStatusContainer');
                                if (!balanceMessage && messageContainer) {
                                    // Create the message element
                                    var messageDiv = document.createElement('div');
                                    messageDiv.id = 'balanceStatus';
                                    messageDiv.className = 'alert alert-warning mt-2';
                                    messageDiv.innerHTML =
                                        '<i class="fas fa-wallet"></i> <strong>Số dư không đủ!</strong>';
                                    messageContainer.appendChild(messageDiv);
                                } else if (balanceMessage) {
                                    // Update existing message
                                    balanceMessage.innerHTML =
                                        '<i class="fas fa-wallet"></i> <strong>Số dư không đủ!</strong>';
                                }
                            } else {
                                // Sufficient balance - enable button
                                if (confirmButton) {
                                    confirmButton.disabled = false;
                                    confirmButton.classList.remove('btn-secondary');
                                    confirmButton.classList.remove('btn-warning');
                                    confirmButton.classList.add('btn-success');
                                }

                                // Hide balance status message
                                if (balanceMessage) {
                                    balanceMessage.remove();
                                }
                            }
                        }

                        // Confirm buy now
                        function confirmBuyNow() {
                            var quantity = document.getElementById('modalQuantity').value;
                            var productName = '${product.name}';
                            var price = parseFloat('${product.price}');
                            var total = quantity * price;

                            // Check if user has sufficient balance
                            if (userBalance < total) {
                                alert('Số dư không đủ!');
                                return;
                            }

                            // Show confirmation popup
                            if (confirm('Bạn có chắc chắn muốn mua sản phẩm "' + productName + '" với số lượng ' + quantity + ' và tổng tiền ' + new Intl.NumberFormat('vi-VN').format(total) + 'đ?')) {
                                // Update form with current quantity
                                document.getElementById('formQuantity').value = quantity;

                                // Close modal first
                                var modal = bootstrap.Modal.getInstance(document.getElementById('buyNowModal'));
                                modal.hide();

                                // Submit form - let the server handle redirect
                                document.getElementById('orderForm').submit();
                            }
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


                    <!-- Buy Now Modal -->
                    <div class="modal fade" id="buyNowModal" tabindex="-1" aria-labelledby="buyNowModalLabel"
                        aria-hidden="true">
                        <div class="modal-dialog modal-dialog-centered"
                            style="min-width: 650px; max-width: 900px; min-height: 400px;">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <h5 class="modal-title" id="buyNowModalLabel">
                                        <i class="fas fa-shopping-cart text-success"></i> Mua ngay
                                    </h5>
                                    <button type="button" class="btn-close" data-bs-dismiss="modal"
                                        aria-label="Close"></button>
                                </div>
                                <div class="modal-body" style="min-height: 280px;">
                                    <div class="row">
                                        <div class="col-md-5">
                                            <img id="product-modal-image"
                                                src="<c:url value='/images/products/${product.id}.jpg'/>"
                                                data-fallback-url="<c:out value='${product.productUrl}'/>"
                                                alt="${product.name}" class="img-fluid rounded"
                                                onerror="handleImgError(this)" />
                                        </div>
                                        <div class="col-md-7">
                                            <h6 class="fw-bold">${product.name}</h6>
                                            <p class="text-muted small">${product.category.name}</p>
                                            <div class="d-flex justify-content-between align-items-center">
                                                <span class="h5 text-success mb-0">
                                                    <fmt:formatNumber value="${product.price}" type="currency"
                                                        currencySymbol="" maxFractionDigits="0" />đ
                                                </span>
                                                <span class="text-muted">Kho: ${dynamicStock}</span>
                                            </div>
                                            <hr>
                                            <div class="mb-3">
                                                <label class="form-label fw-bold">Số lượng:</label>
                                                <input type="number" id="modalQuantity" class="form-control" value="1"
                                                    min="1" max="${dynamicStock}" style="width: 100px;">
                                            </div>
                                            <div class="d-flex justify-content-between">
                                                <span class="fw-bold">Tổng cộng:</span>
                                                <span class="h6 text-success" id="totalPrice">
                                                    <fmt:formatNumber value="${product.price}" type="currency"
                                                        currencySymbol="" maxFractionDigits="0" />đ
                                                </span>
                                            </div>
                                            <c:if test="${pageContext.request.userPrincipal != null}">
                                                <div class="d-flex justify-content-between mt-2">
                                                    <span class="text-muted">Số dư:</span>
                                                    <span class="text-info" id="currentBalance">
                                                        <fmt:formatNumber value="${userBalance}" type="currency"
                                                            currencySymbol="" maxFractionDigits="0" />đ
                                                    </span>
                                                </div>
                                            </c:if>
                                        </div>
                                    </div>
                                    <!-- Reserved space for balance status message -->
                                    <div id="balanceStatusContainer" style="min-height: 80px;"></div>

                                    <!-- Form for order processing -->
                                    <form id="orderForm" method="post" action="<c:url value='/order-process/buy-now'/>"
                                        style="display: none;">
                                        <input type="hidden" name="productId" value="${product.id}">
                                        <input type="hidden" name="quantity" id="formQuantity" value="1">
                                    </form>
                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                                    <button type="button" class="btn btn-success" onclick="confirmBuyNow()">
                                        <i class="fas fa-check"></i> Xác nhận mua
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Include Footer -->
                    <jsp:include page="../common/footer.jsp" />

                    </div>
                    <!-- Page-specific JavaScript -->
                    <c:if test="${not empty pageJS}">
                        <c:forEach var="js" items="${pageJS}">
                            <script src="${pageContext.request.contextPath}${js}"></script>
                        </c:forEach>
                    </c:if>

                    <!-- Common JavaScript -->
                    <script>
                        // Image fallback: try .png, then productUrl, then placeholder
                        function handleImgError(img) {
                            try {
                                const src = img.getAttribute('src') || '';
                                const fallback = (img.dataset && img.dataset.fallbackUrl) ? img.dataset.fallbackUrl : '';
                                // If currently .jpg, try .png
                                if (/\.jpg$/i.test(src)) {
                                    img.onerror = function () { handleImgError(img); };
                                    img.src = src.replace(/\.jpg$/i, '.png');
                                    return;
                                }
                                // If we haven't tried fallback URL yet
                                if (fallback && src !== fallback) {
                                    img.onerror = function () { setPlaceholder(img); };
                                    img.src = fallback;
                                    return;
                                }
                                // Otherwise, set placeholder
                                setPlaceholder(img);
                            } catch (e) {
                                setPlaceholder(img);
                            }
                        }

                        function setPlaceholder(img) {
                            img.onerror = null;
                            img.src = '<c:url value="/images/others.png"/>';
                        }

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

                            // Add event listener for modal quantity change
                            var modalQuantity = document.getElementById('modalQuantity');
                            if (modalQuantity) {
                                modalQuantity.addEventListener('input', updateTotalPrice);
                            }

                            // Reset modal state when modal is hidden
                            var buyNowModal = document.getElementById('buyNowModal');
                            if (buyNowModal) {
                                buyNowModal.addEventListener('hidden.bs.modal', function () {
                                    // Reset button to default state
                                    var confirmButton = document.querySelector('#buyNowModal .modal-footer .btn:last-child');
                                    if (confirmButton) {
                                        confirmButton.disabled = false;
                                        confirmButton.innerHTML = '<i class="fas fa-check"></i> Xác nhận mua';
                                        confirmButton.classList.remove('btn-warning');
                                        confirmButton.classList.remove('btn-secondary');
                                        confirmButton.classList.add('btn-success');
                                    }

                                    // Remove any balance status message
                                    var balanceMessage = document.getElementById('balanceStatus');
                                    if (balanceMessage) {
                                        balanceMessage.remove();
                                    }
                                });
                            }
                        });
                    </script>
                </body>

                </html>