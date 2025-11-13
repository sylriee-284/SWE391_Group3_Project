<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
            <%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>

                <!DOCTYPE html>
                <html lang="en">

                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>Đã Đóng Cửa Hàng - Hệ Thống MMO Market</title>

                    <!-- Include common head with all CSS and JS -->
                    <jsp:include page="../common/head.jsp" />

                    <!-- Close Store Result specific CSS -->
                    <link rel="stylesheet" href="<c:url value='/resources/css/close-store-result.css' />">
                </head>

                <body>
                    <!-- Navbar -->
                    <jsp:include page="../common/navbar.jsp" />

                    <!-- Sidebar -->
                    <jsp:include page="../common/sidebar.jsp" />

                    <!-- Sidebar Overlay for Mobile -->
                    <div class="sidebar-overlay" id="sidebarOverlay" onclick="toggleSidebar()"></div>

                    <!-- Main Content Area -->
                    <div class="content" id="content">
                        <!-- DEBUG: Check if data exists -->
                        <c:if test="${empty store}">
                            <div class="alert alert-danger">ERROR: Store data is empty!</div>
                        </c:if>
                        <c:if test="${empty result}">
                            <div class="alert alert-danger">ERROR: Result data is empty!</div>
                        </c:if>

                        <div class="container">
                            <div class="result-card">
                                <div class="result-icon">
                                    <i class="fas fa-store-slash"></i>
                                </div>

                                <div class="result-badge">
                                    ${result.status}
                                </div>

                                <h1 class="result-title">Cửa Hàng Đã Đóng Thành Công</h1>
                                <p class="result-description">
                                    Cửa hàng "<strong>${store.storeName}</strong>" của bạn đã được đóng. Tất cả sản phẩm
                                    hiện đã ẩn khỏi khách hàng.
                                </p>

                                <div class="info-box">
                                    <div class="info-item">
                                        <span class="info-label">
                                            <i class="fas fa-store"></i> Tên Cửa Hàng:
                                        </span>
                                        <span class="info-value">${store.storeName}</span>
                                    </div>

                                    <div class="info-item">
                                        <span class="info-label">
                                            <i class="fas fa-calendar-plus"></i> Ngày Mở Cửa:
                                        </span>
                                        <span class="info-value">
                                            ${createdAtFormatted}
                                        </span>
                                    </div>

                                    <div class="info-item">
                                        <span class="info-label">
                                            <i class="fas fa-calendar-times"></i> Ngày Đóng Cửa:
                                        </span>
                                        <span class="info-value">
                                            ${updatedAtFormatted}
                                        </span>
                                    </div>

                                    <div class="info-item">
                                        <span class="info-label">
                                            <i class="fas fa-hourglass-half"></i> Thời Gian Hoạt Động:
                                        </span>
                                        <span class="info-value">
                                            <c:choose>
                                                <c:when test="${operatingMonths > 0}">
                                                    ${operatingMonths} tháng ${operatingDays % 30} ngày
                                                </c:when>
                                                <c:otherwise>
                                                    ${operatingDays} ngày
                                                </c:otherwise>
                                            </c:choose>
                                        </span>
                                    </div>

                                    <div class="info-item">
                                        <span class="info-label">
                                            <i class="fas fa-tag"></i> Mô Hình Phí:
                                        </span>
                                        <span class="info-value">
                                            <c:choose>
                                                <c:when
                                                    test="${store.feeModel != null && store.feeModel.name() == 'NO_FEE'}">
                                                    <span class="badge bg-success">Không Phí</span>
                                                </c:when>
                                                <c:when
                                                    test="${store.feeModel != null && store.feeModel.name() == 'PERCENTAGE'}">
                                                    <span class="badge bg-info">Phí ${store.feePercentageRate}%</span>
                                                </c:when>
                                                <c:otherwise>
                                                    ${store.feeModel}
                                                </c:otherwise>
                                            </c:choose>
                                        </span>
                                    </div>

                                    <div class="info-item">
                                        <span class="info-label">
                                            <i class="fas fa-hand-holding-usd"></i> Tiền Cọc :
                                        </span>
                                        <span class="info-value">
                                            <fmt:formatNumber value="${store.depositAmount}" type="number"
                                                maxFractionDigits="0" /> VND
                                        </span>
                                    </div>

                                    <!-- Wallet balance removed per request -->

                                    <div class="info-item">
                                        <span class="info-label">
                                            <i class="fas fa-info-circle"></i> Trạng Thái:
                                        </span>
                                        <span class="info-value">
                                            <span class="badge bg-secondary">${store.status}</span>
                                        </span>
                                    </div>
                                </div>

                                <div class="alert-info-custom">
                                    <i class="fas fa-info-circle"></i>
                                    <strong>Điều gì sẽ xảy ra tiếp theo?</strong>
                                    <ul style="text-align: left; margin-top: 10px;">
                                        <li>Cửa hàng của bạn hiện đã KHÔNG HOẠT ĐỘNG và ẩn khỏi tất cả khách hàng</li>
                                        <li>Bạn không thể thêm sản phẩm mới hoặc nhận đơn hàng mới</li>
                                        <li>Tiền cọc hoàn trả đã được thêm vào ví của bạn</li>
                                        <li>Bạn vẫn có thể truy cập lịch sử đơn hàng và các giao dịch đã hoàn tất</li>
                                    </ul>
                                </div>

                                <div class="action-buttons">
                                    <a href="/seller/store/settings" class="btn btn-primary">
                                        <i class="fas fa-cogs"></i> Quay Lại Cài Đặt Cửa Hàng
                                    </a>
                                    <a href="/wallet/transactions" class="btn btn-success">
                                        <i class="fas fa-wallet"></i> Xem Lịch Sử Ví
                                    </a>
                                </div>

                                <div style="margin-top: 30px; color: #6c757d;">
                                    <small>Cảm ơn bạn đã là một phần của marketplace. Chúng tôi rất tiếc khi phải chia
                                        tay.</small>
                                </div>
                            </div>
                        </div><!-- End container -->
                    </div><!-- End content -->

                    <!-- Footer -->
                    <jsp:include page="../common/footer.jsp" />

                    <!-- Sidebar Toggle Script -->
                    <script>
                        // ========== Sidebar Toggle Function (Global Scope) ==========
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
                    </script>
                </body>

                </html>