<%@ page contentType="text/html; charset=UTF-8" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
        <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <title>Đăng ký thành công - Cửa hàng</title>
                <jsp:include page="../common/head.jsp" />
                <!-- External stylesheet for register-success page -->
                <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/register-success.css" />

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
                    <div class="container-fluid px-5">
                        <div class="success-container">
                            <!-- Alternate Design: Hero + Progress + Collapsible Contract + Compact Info -->
                            <div class="d-flex align-items-center justify-content-between mb-3 gap-3 flex-column flex-md-row success-hero">
                                <div class="d-flex align-items-center gap-3">
                                    <div class="rounded-circle bg-primary text-white d-flex align-items-center justify-content-center" style="width:72px;height:72px;">
                                        <i class="fas fa-store fa-lg"></i>
                                    </div>
                                    <div>
                                        <h2 class="h5 mb-1">Đăng ký cửa hàng đã ghi nhận</h2>
                                        <p class="mb-0 text-muted small">Chúng tôi đã nhận yêu cầu của bạn. Trạng thái thanh toán bên dưới.</p>
                                    </div>
                                </div>
                                <div class="w-100">
                                    <div class="rounded-progress progress" style="height:12px;">
                                        <c:choose>
                                            <c:when test="${store.status == 'ACTIVE'}">
                                                <div class="progress-bar bg-success" role="progressbar" style="width:100%"></div>
                                            </c:when>
                                            <c:otherwise>
                                                <div class="progress-bar bg-info" role="progressbar" style="width:55%"></div>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                    <div class="d-flex justify-content-between small text-muted mt-1">
                                        <span>Đã gửi yêu cầu</span>
                                        <span>${store.status == 'ACTIVE' ? 'Hoàn tất' : 'Đang xử lý'}</span>
                                    </div>
                                </div>
                            </div>

                            <!-- Server messages for toasts (keep hidden elements) -->
                            <c:if test="${not empty success}"><div id="serverSuccess" data-success="${fn:escapeXml(success)}"></div></c:if>
                            <c:if test="${not empty error}"><div id="serverError" data-error="${fn:escapeXml(error)}"></div></c:if>
                            <c:if test="${not empty info}"><div id="serverInfo" data-info="${fn:escapeXml(info)}"></div></c:if>

                            <div class="row">
                                <div class="col-lg-9">
                                    <div class="card mb-3 shadow-sm highlight-card">
                                        <div class="card-body">
                                            <div class="d-flex justify-content-between align-items-center">
                                                <h5 class="mb-0">Chi tiết thanh toán ký quỹ</h5>
                                            </div>
                                            <div class="mt-3">
                                                <p class="mb-1">Số tiền ký quỹ: <strong class="text-success"><fmt:formatNumber value="${store.depositAmount}" type="number" pattern="#,###" /> VNĐ</strong></p>
                                                <p class="mb-0">Giá niêm yết tối đa: <strong><fmt:formatNumber value="${store.maxListingPrice}" type="number" pattern="#,###" /> VNĐ</strong></p>
                                            </div>

                                            <!-- Contract Information - Always Visible -->
                                            <div class="mt-3">
                                                <div class="card border-0 shadow-sm">
                                                    <div class="card-header bg-primary bg-gradient text-white">
                                                        <h6 class="mb-0"><i class="fas fa-file-contract me-2"></i>Điều khoản hợp đồng</h6>
                                                    </div>
                                                    <div class="card-body">
                                                        <c:choose>
                                                            <c:when test="${store.feeModel == 'PERCENTAGE'}">
                                                                <!-- Percentage Fee Model Contract -->
                                                                <div class="mb-3">
                                                                    <h6 class="text-primary">
                                                                        <i class="fas fa-percent me-2"></i>Phí theo phần trăm
                                                                        <span class="badge bg-info ms-2">Khuyến nghị</span>
                                                                    </h6>
                                                                </div>
                                                                
                                                                <div class="mb-3">
                                                                    <p class="mb-2"><strong>Hệ thống sẽ áp dụng mức phí giao dịch dựa trên giá trị đơn hàng như sau:</strong></p>
                                                                    <ul class="list-unstyled ms-3">
                                                                        <li class="mb-2">
                                                                            <i class="fas fa-arrow-right text-success me-2"></i>
                                                                            Đơn hàng dưới <strong>100.000 VNĐ</strong> → Phí cố định: <strong class="text-danger"><fmt:formatNumber value="${fixedFee}" type="number" pattern="#,###" /> VNĐ</strong>
                                                                        </li>
                                                                        <li class="mb-2">
                                                                            <i class="fas fa-arrow-right text-primary me-2"></i>
                                                                            Đơn hàng từ <strong>100.000 VNĐ</strong> trở lên → Phí theo tỷ lệ: <strong class="text-danger"><fmt:formatNumber value="${percentageFee}" type="number" maxFractionDigits="2" />%</strong> trên tổng giá trị đơn hàng
                                                                        </li>
                                                                    </ul>
                                                                </div>

                                                                <div class="alert alert-success border-0 mb-0">
                                                                    <h6 class="alert-heading mb-2"><i class="fas fa-money-bill-wave me-2"></i>Chính sách hoàn phí ký quỹ:</h6>
                                                                    <ul class="mb-2 small">
                                                                        <li>Nếu cửa hàng đóng <strong>sau ${maxRefundRateMinDuration} tháng</strong> kể từ ngày kích hoạt → hoàn <strong class="text-success"><fmt:formatNumber value="${percentageMaxRefundRate}" type="number" maxFractionDigits="0" />% phí ký quỹ</strong>.</li>
                                                                        <li>Nếu cửa hàng đóng <strong>trước ${maxRefundRateMinDuration} tháng</strong> → hoàn <strong class="text-warning"><fmt:formatNumber value="${percentageMinRefundRate}" type="number" maxFractionDigits="0" />% phí ký quỹ</strong>.</li>
                                                                    </ul>
                                                                    <p class="mb-0 small fst-italic">
                                                                        <i class="fas fa-lightbulb text-warning me-1"></i>
                                                                        💡 Chính sách này đảm bảo tính công bằng, khuyến khích hoạt động lâu dài và bảo vệ quyền lợi của cả người mua và người bán.
                                                                    </p>
                                                                </div>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <!-- No Fee Model Contract -->
                                                                <div class="mb-3">
                                                                    <h6 class="text-muted">
                                                                        <i class="fas fa-circle me-2"></i> Không tính phí
                                                                    </h6>
                                                                </div>
                                                                
                                                                <div class="mb-3">
                                                                    <ul class="list-unstyled ms-3">
                                                                        <li class="mb-2">
                                                                            <i class="fas fa-check-circle text-success me-2"></i>
                                                                            Người bán <strong>không phải trả bất kỳ khoản phí giao dịch nào</strong> cho các đơn hàng.
                                                                        </li>
                                                                        <li class="mb-2">
                                                                            <i class="fas fa-check-circle text-success me-2"></i>
                                                                            Toàn bộ doanh thu sẽ được chuyển <strong>100%</strong> vào ví hệ thống của người bán.
                                                                        </li>
                                                                    </ul>
                                                                </div>

                                                                <div class="alert alert-warning border-0 mb-0">
                                                                    <h6 class="alert-heading mb-2"><i class="fas fa-exclamation-triangle me-2"></i>Chính sách hoàn phí ký quỹ:</h6>
                                                                    <ul class="mb-2 small">
                                                                        <li>Đóng cửa hàng → hoàn <strong class="text-warning"><fmt:formatNumber value="${noFeeRefundRate}" type="number" maxFractionDigits="0" />% phí ký quỹ</strong> (không kể thời gian).</li>
                                                                    </ul>
                                                                    <p class="mb-0 small fst-italic">
                                                                        <i class="fas fa-lightbulb text-warning me-1"></i>
                                                                        💡 Phù hợp với các cửa hàng nhỏ, thử nghiệm hoặc hoạt động ngắn hạn, ưu tiên đơn giản và không phát sinh phí giao dịch.
                                                                    </p>
                                                                </div>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                </div>
                                            </div>

                                            <!-- Show activation prompt for PENDING stores -->
                                            <c:if test="${store.status == 'PENDING'}">
                                                <div class="alert alert-info mt-3" id="pendingAlert">
                                                    <i class="fas fa-info-circle"></i>
                                                    <strong>Cửa hàng đang chờ kích hoạt.</strong> Vui lòng bấm nút bên dưới để thanh toán ký quỹ và kích hoạt cửa hàng.
                                                </div>
                                                <div class="mt-3 d-grid gap-2" id="pendingActionButtons">
                                                    <form action="${pageContext.request.contextPath}/seller/retry-deposit/${store.id}" method="post">
                                                        <button type="submit" class="btn btn-success btn-lg w-100">
                                                            <i class="fas fa-check-circle"></i> Kích hoạt cửa hàng (Thanh toán ký quỹ)
                                                        </button>
                                                    </form>
                                                    <a href="${pageContext.request.contextPath}/wallet/deposit" class="btn btn-outline-primary">
                                                        <i class="fas fa-wallet"></i> Nạp tiền trước
                                                    </a>
                                                </div>
                                            </c:if>

                                            <c:if test="${not empty paymentError}">
                                                <div class="error-box mt-3">
                                                    <div class="d-flex align-items-start">
                                                        <i class="fas fa-exclamation-circle text-danger fa-lg"></i>
                                                        <div class="ms-3">
                                                            <div class="fw-bold">Thanh toán thất bại</div>
                                                            <div class="mt-1">${paymentError}</div>
                                                            <div class="mt-3">
                                                                <a href="${pageContext.request.contextPath}/wallet/deposit" class="btn btn-sm btn-primary">
                                                                    <i class="fas fa-wallet"></i> Nạp tiền qua VNPay
                                                                </a>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </c:if>
                                        </div>
                                    </div>
                                </div>

                                <div class="col-lg-3">
                                    <div class="card shadow-sm mb-3 highlight-card">
                                        <div class="card-body">
                                            <h6 class="card-title">Thông tin cửa hàng</h6>
                                            <ul class="list-unstyled small mb-0">
                                                <li><strong>#${store.id}</strong> — ${store.storeName}</li>
                                                <c:if test="${not empty store.description}"><li>${store.description}</li></c:if>
                                                <li class="mt-2">Trạng thái: 
                                                    <c:choose>
                                                        <c:when test="${store.status == 'ACTIVE'}">
                                                            <span class="badge bg-success">Đã kích hoạt</span>
                                                        </c:when>
                                                        <c:when test="${store.status == 'PENDING'}">
                                                            <span class="badge bg-info">Chờ kích hoạt</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge bg-warning">Đang xử lý</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </li>
                                            </ul>
                                            
                                            <!-- Show activate button for PENDING stores -->
                                            <c:if test="${store.status == 'PENDING'}">
                                                <div class="mt-3 d-grid" id="activateButtonContainer">
                                                    <form action="${pageContext.request.contextPath}/seller/retry-deposit/${store.id}" method="post">
                                                        <button type="submit" class="btn btn-success btn-sm"><i class="fas fa-check-circle"></i> Kích hoạt</button>
                                                    </form>
                                                </div>
                                            </c:if>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                            <!-- Status notification removed per design request -->

                            <!-- Action buttons - Only show when ACTIVE -->
                            <c:if test="${store.status == 'ACTIVE'}">
                                <div class="text-center mt-4">
                                    <a href="/seller/dashboard" class="btn btn-primary btn-lg me-2">
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

                <!-- iziToast -->
                <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/izitoast@1.4.0/dist/css/iziToast.min.css">
                <script src="https://cdn.jsdelivr.net/npm/izitoast@1.4.0/dist/js/iziToast.min.js"></script>

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

                    // Auto-reload removed: polling handles status updates now

                    // Show server-side toasts (success/info/error)
                    (function () {
                        try {
                            const s = document.getElementById('serverSuccess');
                            const e = document.getElementById('serverError');
                            const i = document.getElementById('serverInfo');
                            if (s) {
                                const msg = s.getAttribute('data-success');
                                if (msg) {
                                    iziToast.success({ title: 'Thành công', message: msg, position: 'topRight', timeout: 8000 });
                                }
                            }
                            if (i) {
                                const msg = i.getAttribute('data-info');
                                if (msg) {
                                    iziToast.info({ title: 'Thông tin', message: msg, position: 'topRight', timeout: 8000 });
                                }
                            }
                            if (e) {
                                const msg = e.getAttribute('data-error');
                                if (msg) {
                                    iziToast.error({ title: 'Lỗi', message: msg, position: 'topRight', timeout: 10000 });
                                }
                            }
                        } catch (err) {
                            console.error('iziToast show failed', err);
                        }
                    })();

                    // Polling to pick up store status changes without reload
                    (function () {
                        try {
                            const storeId = '${store.id}';
                            const initialStatus = '${store.status}';
                            
                            // Only run polling if store is not already ACTIVE
                            if (!storeId || initialStatus === 'ACTIVE') {
                                console.log('Polling skipped: storeId=' + storeId + ', status=' + initialStatus);
                                return;
                            }

                            const progressBar = document.querySelector('.rounded-progress .progress-bar');
                            const statusSpan = document.querySelector('.d-flex.justify-content-between.small span:last-child');
                            const badge = document.querySelector('.col-lg-3 .badge');
                            const activateButtonContainer = document.getElementById('activateButtonContainer');
                            const retryButtonContainer = document.getElementById('retryButtonContainer');
                            const pendingAlert = document.getElementById('pendingAlert');
                            const pendingActionButtons = document.getElementById('pendingActionButtons');

                            let stopped = false;
                            let reloadScheduled = false; // Prevent multiple reload schedules

                            async function poll() {
                                if (stopped || reloadScheduled) return;
                                try {
                                    const ctx = '${pageContext.request.contextPath}';
                                    const res = await fetch(ctx + '/seller/status/' + storeId, { credentials: 'same-origin' });
                                    if (!res.ok) return;
                                    const json = await res.json();
                                    if (!json) return;

                                    const status = json.status;
                                    const paymentError = json.paymentError;

                                    if (status === 'ACTIVE') {
                                        // Prevent multiple executions
                                        if (reloadScheduled) return;
                                        reloadScheduled = true;
                                        stopped = true;
                                        
                                        // Update UI
                                        if (progressBar) { progressBar.style.width = '100%'; progressBar.classList.remove('bg-info'); progressBar.classList.add('bg-success'); }
                                        if (statusSpan) statusSpan.textContent = 'Hoàn tất';
                                        if (badge) { badge.classList.remove('bg-warning', 'bg-info'); badge.classList.add('bg-success'); badge.textContent = 'Đã kích hoạt'; }
                                        
                                        // Hide all activation-related elements
                                        if (activateButtonContainer) activateButtonContainer.style.display = 'none';
                                        if (retryButtonContainer) retryButtonContainer.style.display = 'none';
                                        if (pendingAlert) pendingAlert.style.display = 'none';
                                        if (pendingActionButtons) pendingActionButtons.style.display = 'none';
                                        
                                        // Show success toast
                                        iziToast.success({ 
                                            title: 'Cửa hàng đã kích hoạt', 
                                            message: 'Cửa hàng của bạn đã được kích hoạt. Trang sẽ tự động tải lại sau 3 giây...', 
                                            position: 'topRight', 
                                            timeout: 3000
                                        });
                                        
                                        // Reload page ONCE after 3 seconds to update sidebar (SELLER role)
                                        setTimeout(function() { 
                                            window.location.reload(); 
                                        }, 3200);
                                        return;
                                    }

                                    if (paymentError) {
                                        iziToast.error({ title: 'Thanh toán thất bại', message: paymentError, position: 'topRight', timeout: 10000 });
                                        stopped = true;
                                        return;
                                    }

                                } catch (err) {
                                    console.error('Polling error', err);
                                }
                                if (!stopped && !reloadScheduled) setTimeout(poll, 3000);
                            }

                            // start after a short delay so page finishes rendering
                            setTimeout(poll, 1000);
                        } catch (err) {
                            console.error('Setup polling failed', err);
                        }
                    })();
                </script>
            </body>

            </html>