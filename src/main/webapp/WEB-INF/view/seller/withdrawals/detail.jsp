<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
            <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

                <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <c:if test="${not empty _csrf}">
                    <meta name="_csrf" content="${_csrf.token}" />
                    <meta name="_csrf_header" content="${_csrf.headerName}" />
                </c:if>
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Chi tiết yêu cầu rút tiền - MMO Market System</title>

                <!-- Include common head -->
                <jsp:include page="../../common/head.jsp" />
                
            </head>

            <body>
                <!-- Include Navbar -->
                <jsp:include page="../../common/navbar.jsp" />

                <!-- Include Sidebar -->
                <jsp:include page="../../common/sidebar.jsp" />

                <!-- Sidebar Overlay for Mobile -->
                <div class="sidebar-overlay" id="sidebarOverlay" onclick="toggleSidebar()" role="button"
                    tabindex="0" onKeyPress="if(event.key === 'Enter') toggleSidebar()"></div>

                <!-- Main Content Area -->
                <div class="content" id="content">
                    <div class="container-fluid mt-4">
                        <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center mb-3">
                                <h1 class="h2">
                                    <i class="bi bi-file-text me-2"></i>Chi tiết yêu cầu rút tiền
                                </h1>
                                <div>
                                    <a href="/seller/withdrawals" class="btn btn-outline-secondary">
                                        <i class="bi bi-arrow-left me-2"></i>Quay lại
                                    </a>
                                </div>
                            </div>

                            <!-- Detail Card -->
                            <div class="row justify-content-center">
                                <div class="col-md-10">
                                    <div class="card detail-card">
                                        <div class="card-body p-4">
                                            <!-- Header with Status -->
                                            <div class="d-flex justify-content-between align-items-center mb-4">
                                                <div>
                                                    <h3>Yêu cầu #${withdrawal.id}</h3>
                                                    <p class="text-muted mb-0">
                                                        Mã giao dịch: <strong>${withdrawal.paymentRef}</strong>
                                                    </p>
                                                </div>
                                                <div>
                                                    <span class="status-badge status-${withdrawal.paymentStatus}">
                                                        <c:choose>
                                                            <c:when test="${withdrawal.paymentStatus == 'PENDING'}">
                                                                <i class="bi bi-clock-history me-1"></i>Chờ duyệt
                                                            </c:when>
                                                            <c:when test="${withdrawal.paymentStatus == 'SUCCESS'}">
                                                                <i class="bi bi-check-circle me-1"></i>Đã duyệt
                                                            </c:when>
                                                            <c:when test="${withdrawal.paymentStatus == 'FAILED'}">
                                                                <i class="bi bi-x-circle me-1"></i>Từ chối
                                                            </c:when>
                                                            <c:when test="${withdrawal.paymentStatus == 'CANCELLED'}">
                                                                <i class="bi bi-slash-circle me-1"></i>Đã hủy
                                                            </c:when>
                                                        </c:choose>
                                                    </span>
                                                </div>
                                            </div>

                                            <!-- Amount -->
                                            <div class="text-center mb-4 py-4 bg-light rounded">
                                                <p class="text-muted mb-2">Số tiền rút</p>
                                                <div class="amount-display">
                                                    -<fmt:formatNumber value="${withdrawal.amount}" type="currency"
                                                        currencySymbol="" /> ₫
                                                </div>
                                            </div>

                                            <!-- Bank Information -->
                                            <h5 class="mb-3">
                                                <i class="bi bi-bank me-2"></i>Thông tin ngân hàng
                                            </h5>

                                            <c:set var="bankInfo" value="${withdrawal.note.split(' - ')}" />

                                            <div class="info-row row">
                                                <div class="col-md-4 info-label">Ngân hàng</div>
                                                <div class="col-md-8">
                                                    <c:if test="${fn:length(bankInfo) >= 2}">
                                                        <strong>${bankInfo[1]}</strong>
                                                    </c:if>
                                                </div>
                                            </div>

                                            <div class="info-row row">
                                                <div class="col-md-4 info-label">Số tài khoản</div>
                                                <div class="col-md-8">
                                                    <c:if test="${fn:length(bankInfo) >= 3}">
                                                        <strong>${bankInfo[2]}</strong>
                                                    </c:if>
                                                </div>
                                            </div>

                                            <div class="info-row row">
                                                <div class="col-md-4 info-label">Tên chủ tài khoản</div>
                                                <div class="col-md-8">
                                                    <c:if test="${fn:length(bankInfo) >= 4}">
                                                        <strong>${bankInfo[3]}</strong>
                                                    </c:if>
                                                </div>
                                            </div>

                                            <!-- Transaction Information -->
                                            <h5 class="mb-3 mt-4">
                                                <i class="bi bi-info-circle me-2"></i>Thông tin giao dịch
                                            </h5>

                                            <div class="info-row row">
                                                <div class="col-md-4 info-label">Ngày tạo</div>
                                                <div class="col-md-8">
                                                    ${withdrawal.createdAt.toString().replace('T', ' ')}
                                                </div>
                                            </div>

                                            <div class="info-row row">
                                                <div class="col-md-4 info-label">Cập nhật lần cuối</div>
                                                <div class="col-md-8">
                                                    ${withdrawal.updatedAt.toString().replace('T', ' ')}
                                                </div>
                                            </div>

                                            <!-- Admin Response (if rejected) -->
                                            <c:if test="${withdrawal.paymentStatus == 'REJECTED'}">
                                                <div class="alert alert-danger mt-4">
                                                    <h6 class="alert-heading">
                                                        <i class="bi bi-exclamation-triangle me-2"></i>Lý do từ chối
                                                    </h6>
                                                    <p class="mb-0">
                                                        ${not empty withdrawal.note ? withdrawal.note : 'Không có lý do cụ thể'}
                                                    </p>
                                                </div>
                                            </c:if>

                                            <!-- Actions for Pending Status -->
                                            <c:if test="${withdrawal.paymentStatus == 'PENDING'}">
                                                <div class="mt-4 pt-4 border-top">
                                                    <div class="d-grid gap-2 d-md-flex justify-content-md-end">
                                                        <button type="button" class="btn btn-outline-danger btn-lg"
                                                            onclick="cancelWithdrawal()">
                                                            <i class="bi bi-x-lg me-2"></i>Hủy yêu cầu
                                                        </button>
                                                        <a href="/seller/withdrawals/${withdrawal.id}/edit"
                                                            class="btn btn-primary btn-lg">
                                                            <i class="bi bi-pencil me-2"></i>Sửa yêu cầu
                                                        </a>
                                                    </div>
                                                </div>
                                            </c:if>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </main>
                    </div> <!-- End container-fluid -->
                </div> <!-- End content -->

                <!-- Include Footer -->
                <jsp:include page="../../common/footer.jsp" />

                <!-- Cancel Confirmation Form (Hidden) -->
                <form id="cancelForm" method="POST" action="/seller/withdrawals/${withdrawal.id}/cancel"
                    style="display: none;">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                </form>

                <script>
                    function cancelWithdrawal() {
                        if (confirm('Bạn có chắc chắn muốn hủy yêu cầu rút tiền này?')) {
                            document.getElementById('cancelForm').submit();
                        }
                    }

                    // Show flash messages
                    <c:if test="${not empty success}">
                        iziToast.success({
                            title: 'Thành công',
                            message: '${success}',
                            position: 'topRight'
                        });
                    </c:if>

                    <c:if test="${not empty error}">
                        iziToast.error({
                            title: 'Lỗi',
                            message: '${error}',
                            position: 'topRight'
                        });
                    </c:if>

                    // Toggle sidebar function
                    function toggleSidebar() {
                        var sidebar = document.getElementById('sidebar');
                        var content = document.getElementById('content');
                        var overlay = document.getElementById('sidebarOverlay');

                        if (sidebar) {
                            sidebar.classList.toggle('active');
                        }

                        // Toggle content shift
                        if (content) {
                            content.classList.toggle('shifted');
                        }

                        // Toggle overlay for mobile
                        if (overlay) {
                            overlay.classList.toggle('active');
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
                    </div> <!-- End container-fluid -->
                </div> <!-- End content -->
            </body>

            </html>
