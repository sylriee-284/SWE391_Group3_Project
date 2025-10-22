<%@ page contentType="text/html; charset=UTF-8" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <title>Đăng ký thành công - Cửa hàng</title>
                <jsp:include page="../common/head.jsp" />
                <style>
                    .success-container {
                        max-width: 800px;
                        margin: 3rem auto;
                        padding: 2rem;
                    }

                    .success-icon {
                        font-size: 4rem;
                        color: #28a745;
                        margin-bottom: 1rem;
                    }

                    .info-card {
                        background: #f8f9fa;
                        border-left: 4px solid #28a745;
                        padding: 1.5rem;
                        margin-bottom: 1.5rem;
                    }

                    .info-row {
                        display: flex;
                        justify-content: space-between;
                        padding: 0.5rem 0;
                        border-bottom: 1px solid #dee2e6;
                    }

                    .info-row:last-child {
                        border-bottom: none;
                    }

                    .info-label {
                        font-weight: 600;
                        color: #495057;
                    }

                    .info-value {
                        color: #212529;
                    }
                </style>
            </head>

            <body>
                <jsp:include page="../common/navbar.jsp" />

                <!-- Include Sidebar -->
                <jsp:include page="../common/sidebar.jsp" />

                <!-- Sidebar Overlay for Mobile -->
                <div class="sidebar-overlay" id="sidebarOverlay" onclick="toggleSidebar()" role="button" tabindex="0"
                    onKeyPress="if(event.key === 'Enter') toggleSidebar()"></div>

                <!-- Main Content Area -->
                <div class="content" id="content">
                    <div class="container">
                        <div class="success-container">
                            <div class="text-center">
                                <i class="fas fa-check-circle success-icon"></i>
                                <h2 class="mb-3">Đăng ký cửa hàng thành công!</h2>
                                <p class="text-muted mb-4">Chúc mừng bạn đã trở thành người bán hàng trên nền tảng của
                                    chúng
                                    tôi</p>
                            </div>

                            <!-- Alert Success -->
                            <c:if test="${not empty success}">
                                <div class="alert alert-success alert-dismissible fade show" role="alert">
                                    <i class="fas fa-check-circle"></i> ${success}
                                    <button type="button" class="btn-close" data-bs-dismiss="alert"
                                        aria-label="Close"></button>
                                </div>
                            </c:if>

                            <!-- Alert Error -->
                            <c:if test="${not empty error}">
                                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                                    <i class="fas fa-exclamation-circle"></i> ${error}
                                    <button type="button" class="btn-close" data-bs-dismiss="alert"
                                        aria-label="Close"></button>
                                </div>
                            </c:if>

                            <!-- Alert Info -->
                            <c:if test="${not empty info}">
                                <div class="alert alert-info alert-dismissible fade show" role="alert">
                                    <i class="fas fa-info-circle"></i> ${info}
                                    <button type="button" class="btn-close" data-bs-dismiss="alert"
                                        aria-label="Close"></button>
                                </div>
                            </c:if>

                            <!-- Thông tin tài khoản -->
                            <div class="card mb-4">
                                <div class="card-header bg-primary text-white">
                                    <h5 class="mb-0"><i class="fas fa-user"></i> Thông tin tài khoản</h5>
                                </div>
                                <div class="card-body">
                                    <div class="info-row">
                                        <span class="info-label">ID tài khoản:</span>
                                        <span class="info-value">#${user.id}</span>
                                    </div>
                                    <div class="info-row">
                                        <span class="info-label">Username:</span>
                                        <span class="info-value">${user.username}</span>
                                    </div>
                                    <div class="info-row">
                                        <span class="info-label">Email:</span>
                                        <span class="info-value">${user.email}</span>
                                    </div>
                                    <div class="info-row">
                                        <span class="info-label">Số dư hiện tại:</span>
                                        <span class="info-value">
                                            <fmt:formatNumber value="${user.balance}" type="number" pattern="#,###" />
                                            VNĐ
                                        </span>
                                    </div>
                                </div>
                            </div>

                            <!-- Thông tin cửa hàng -->
                            <div class="card mb-4">
                                <div class="card-header bg-success text-white">
                                    <h5 class="mb-0"><i class="fas fa-store"></i> Thông tin cửa hàng</h5>
                                </div>
                                <div class="card-body">
                                    <div class="info-row">
                                        <span class="info-label">Mã cửa hàng:</span>
                                        <span class="info-value">#${store.id}</span>
                                    </div>
                                    <div class="info-row">
                                        <span class="info-label">Tên cửa hàng:</span>
                                        <span class="info-value">${store.storeName}</span>
                                    </div>
                                    <c:if test="${not empty store.description}">
                                        <div class="info-row">
                                            <span class="info-label">Mô tả:</span>
                                            <span class="info-value">${store.description}</span>
                                        </div>
                                    </c:if>
                                    <div class="info-row">
                                        <span class="info-label">Số tiền ký quỹ:</span>
                                        <span class="info-value text-success fw-bold">
                                            <fmt:formatNumber value="${store.depositAmount}" type="number"
                                                pattern="#,###" /> VNĐ
                                        </span>
                                    </div>
                                    <div class="info-row">
                                        <span class="info-label">Giá tối đa có thể niêm yết:</span>
                                        <span class="info-value">
                                            <fmt:formatNumber value="${store.maxListingPrice}" type="number"
                                                pattern="#,###" /> VNĐ
                                        </span>
                                    </div>
                                    <div class="info-row">
                                        <span class="info-label">Trạng thái:</span>
                                        <span class="info-value">
                                            <span class="badge bg-${store.status == 'ACTIVE' ? 'success' : 'warning'}">
                                                ${store.status == 'ACTIVE' ? 'Đã kích hoạt' : 'Chờ xử lý'}
                                            </span>
                                        </span>
                                    </div>

                                    <!-- Payment error message and activation button -->
                                    <c:if test="${not empty paymentError}">
                                        <div class="alert alert-danger mt-3">
                                            <i class="fas fa-exclamation-circle"></i> ${paymentError}
                                            <div class="mt-3">
                                                <a href="${pageContext.request.contextPath}/wallet/deposit" class="btn btn-primary">
                                                    <i class="fas fa-wallet"></i> Nạp tiền qua VNPay
                                                </a>
                                            </div>
                                        </div>
                                    </c:if>
                                    
                                    <!-- Only show activation button if there was a previous payment error -->
                                    <c:if test="${store.status == 'INACTIVE' && not empty paymentError}">
                                        <div class="mt-3">
                                            <form action="${pageContext.request.contextPath}/seller/retry-deposit/${store.id}" method="post" style="display: inline;">
                                                <button type="submit" class="btn btn-success">
                                                    <i class="fas fa-check-circle"></i> Kích hoạt cửa hàng
                                                </button>
                                            </form>
                                        </div>
                                    </c:if>
                                        </span>
                                    </div>
                                </div>
                            </div>

                            <!-- Status notification -->
                            <c:if test="${store.status != 'ACTIVE'}">
                                <div class="alert alert-info mt-4" role="alert">
                                    <i class="fas fa-info-circle"></i>
                                    <strong>Đang xử lý thanh toán...</strong>
                                    <p class="mb-0">Cửa hàng của bạn đang được kích hoạt. Trang sẽ tự động cập nhật sau
                                        vài giây.</p>
                                </div>
                            </c:if>

                            <!-- Action buttons - Only show when ACTIVE -->
                            <c:if test="${store.status == 'ACTIVE'}">
                                <div class="d-grid gap-2 d-md-flex justify-content-md-center mt-4">
                                    <a href="/seller/dashboard" class="btn btn-primary btn-lg">
                                        <i class="fas fa-tachometer-alt"></i> Đi tới trang quản lý
                                    </a>
                                    <a href="/wallet/transactions" class="btn btn-outline-secondary btn-lg">
                                        <i class="fas fa-history"></i> Xem lịch sử giao dịch
                                    </a>
                                </div>
                            </c:if>
                        </div>
                    </div>
                </div>
                <!-- End Content -->

                <jsp:include page="../common/footer.jsp" />

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
                            menuToggle && !menuToggle.contains(event.target)) {
                            toggleSidebar();
                        }
                    });

                    // Auto reload page after 10 seconds
                    setTimeout(function () {
                        location.reload();
                    }, 10000);
                </script>
            </body>

            </html>