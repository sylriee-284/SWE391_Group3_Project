<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <c:if test="${not empty _csrf}">
                    <meta name="_csrf" content="${_csrf.token}" />
                    <meta name="_csrf_header" content="${_csrf.headerName}" />
                </c:if>
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Tạo yêu cầu rút tiền - MMO Market System</title>

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
                                <i class="bi bi-plus-circle me-2"></i>Tạo yêu cầu rút tiền
                            </h1>
                            <a href="/seller/withdrawals" class="btn btn-outline-secondary">
                                <i class="bi bi-arrow-left me-2"></i>Quay lại
                            </a>
                        </div>

                        <!-- Two columns with equal width -->
                        <div class="row">
                            <!-- Left Column - Balance Info -->
                            <div class="col-md-6">
                                <div class="balance-card">
                                    <div class="d-flex justify-content-between align-items-center">
                                        <div>
                                            <p class="mb-1">Số dư khả dụng</p>
                                            <div class="balance-amount">
                                                <fmt:formatNumber value="${currentUser.balance}" type="currency"
                                                    currencySymbol="" /> ₫
                                            </div>
                                        </div>
                                        <div>
                                            <i class="bi bi-wallet2" style="font-size: 3rem; opacity: 0.3;"></i>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Right Column - Create Form -->
                            <div class="col-md-6">
                                <div class="card form-card">
                                    <div class="card-body p-4">
                                        <h4 class="card-title mb-3">Thông tin yêu cầu rút tiền</h4>

                                        <form method="POST" action="/seller/withdrawals/create" id="createForm">
                                            <input type="hidden" name="${_csrf.parameterName}"
                                                value="${_csrf.token}" />

                                            <div class="row">
                                                <!-- Amount -->
                                                <div class="col-md-6 mb-3">
                                                    <label for="amount" class="form-label fw-bold">
                                                        Số tiền rút <span class="text-danger">*</span>
                                                    </label>
                                                    <input type="number" class="form-control" id="amount" 
                                                        name="amount" placeholder="Nhập số tiền muốn rút" 
                                                        min="100000" required>
                                                    <div class="form-text">Số tiền tối thiểu: 100,000₫</div>
                                                </div>

                                                <!-- Bank Name -->
                                                <div class="col-md-6 mb-3">
                                                    <label for="bankName" class="form-label fw-bold">
                                                        Ngân hàng <span class="text-danger">*</span>
                                                    </label>
                                                    <select class="form-select" id="bankName"
                                                        name="bankName" required>
                                                    <option value="">-- Chọn ngân hàng --</option>
                                                    <option value="Vietcombank">Vietcombank</option>
                                                    <option value="BIDV">BIDV</option>
                                                    <option value="VietinBank">VietinBank</option>
                                                    <option value="Agribank">Agribank</option>
                                                    <option value="Techcombank">Techcombank</option>
                                                    <option value="ACB">ACB</option>
                                                    <option value="MB Bank">MB Bank</option>
                                                    <option value="VPBank">VPBank</option>
                                                    <option value="Sacombank">Sacombank</option>
                                                    <option value="TPBank">TPBank</option>
                                            </select>
                                        </div>
                                    </div>

                                    <!-- Account Number -->
                                    <div class="mb-4">
                                        <label for="bankAccountNumber" class="form-label fw-bold">
                                            Số tài khoản <span class="text-danger">*</span>
                                        </label>
                                        <input type="text" class="form-control form-control-lg"
                                            id="bankAccountNumber" name="bankAccountNumber"
                                            placeholder="Nhập số tài khoản" required>
                                    </div>

                                    <!-- Account Name -->
                                    <div class="mb-4">
                                        <label for="bankAccountName" class="form-label fw-bold">
                                            Tên chủ tài khoản <span class="text-danger">*</span>
                                        </label>
                                        <input type="text" class="form-control form-control-lg"
                                            id="bankAccountName" name="bankAccountName"
                                            placeholder="Nhập tên chủ tài khoản" required>
                                        <div class="form-text">
                                            Tên chủ tài khoản phải khớp với tài khoản ngân hàng
                                        </div>
                                    </div>

                                    <!-- Submit Buttons -->
                                    <div class="d-grid gap-2 d-md-flex justify-content-md-end">
                                        <a href="/seller/withdrawals" class="btn btn-outline-secondary btn-lg">
                                            Hủy bỏ
                                        </a>
                                        <button type="submit" class="btn btn-primary btn-lg">
                                            <i class="bi bi-send me-2"></i>Gửi yêu cầu
                                        </button>
                                    </div>
                                </form>
                        </div>
                    </div>
                </div> <!-- End col-md-6 -->
            </div> <!-- End row -->
        </div> <!-- End container-fluid -->
    </div> <!-- End content -->

    <!-- Include Footer -->
    <jsp:include page="../../common/footer.jsp" />
                <script>
                    $(document).ready(function () {
                        // No frontend validation - backend will handle everything
                    });

                    // Show flash messages
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
