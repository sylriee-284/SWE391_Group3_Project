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
                <title>Sửa yêu cầu rút tiền - MMO Market System</title>

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
                                    <i class="bi bi-pencil me-2"></i>Sửa yêu cầu rút tiền #${withdrawal.id}
                                </h1>
                                <a href="/seller/withdrawals" class="btn btn-outline-secondary">
                                    <i class="bi bi-arrow-left me-2"></i>Quay lại
                                </a>
                            </div>

                            <!-- Warning -->
                            <div class="alert alert-warning" role="alert">
                                <i class="bi bi-exclamation-triangle-fill me-2"></i>
                                <strong>Lưu ý quan trọng:</strong>
                                <ul class="mb-0 mt-2">
                                    <li>Bạn chỉ có thể sửa yêu cầu khi đang ở trạng thái "Chờ duyệt"</li>
                                    <li><strong>Số tiền rút KHÔNG thể thay đổi</strong> sau khi tạo yêu cầu (tiền đã được trừ)</li>
                                    <li>Bạn chỉ có thể cập nhật thông tin ngân hàng nhận tiền</li>
                                </ul>
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

                                <!-- Right Column - Edit Form -->
                                <div class="col-md-6">
                                    <div class="card form-card">
                                        <div class="card-body p-4">
                                            <h4 class="card-title mb-4">Cập nhật thông tin rút tiền</h4>

                                            <form method="POST" action="/seller/withdrawals/${withdrawal.id}/update"
                                                id="editForm">
                                                <input type="hidden" name="${_csrf.parameterName}"
                                                    value="${_csrf.token}" />

                                                <!-- Amount (Readonly - Cannot Edit) -->
                                                <div class="mb-4">
                                                    <label for="amount" class="form-label fw-bold">
                                                        Số tiền rút <span class="text-danger">*</span>
                                                    </label>
                                                    <div class="currency-input">
                                                        <input type="text" class="form-control form-control-lg amount-input"
                                                            id="amountDisplay" 
                                                            value="<fmt:formatNumber value='${withdrawal.amount}' type='currency' currencySymbol='' />₫"
                                                            readonly
                                                            style="background-color: #e9ecef; cursor: not-allowed;">
                                                        <input type="hidden" name="amount" id="amountValue"
                                                            value="${withdrawal.amount}">
                                                    </div>
                                                    <div class="form-text text-warning">
                                                        <i class="bi bi-lock-fill me-1"></i>
                                                        <strong>Lưu ý:</strong> Số tiền rút không thể thay đổi sau khi tạo yêu cầu. 
                                                        Bạn chỉ có thể cập nhật thông tin ngân hàng.
                                                    </div>
                                                </div>

                                                <!-- Bank Name -->
                                                <div class="mb-4">
                                                    <label for="bankName" class="form-label fw-bold">
                                                        Ngân hàng <span class="text-danger">*</span>
                                                    </label>
                                                    <c:set var="bankInfo" value="${withdrawal.note.split(' - ')}" />
                                                    <c:set var="currentBank"
                                                        value="${fn:length(bankInfo) >= 2 ? bankInfo[1] : ''}" />

                                                    <select class="form-select form-select-lg" id="bankName"
                                                        name="bankName" required>
                                                        <option value="">-- Chọn ngân hàng --</option>
                                                        <option value="Vietcombank"
                                                            ${currentBank == 'Vietcombank' ? 'selected' : ''}>
                                                            Vietcombank</option>
                                                        <option value="BIDV" ${currentBank == 'BIDV' ? 'selected' : ''}>
                                                            BIDV</option>
                                                        <option value="VietinBank"
                                                            ${currentBank == 'VietinBank' ? 'selected' : ''}>VietinBank
                                                        </option>
                                                        <option value="Agribank"
                                                            ${currentBank == 'Agribank' ? 'selected' : ''}>Agribank
                                                        </option>
                                                        <option value="Techcombank"
                                                            ${currentBank == 'Techcombank' ? 'selected' : ''}>
                                                            Techcombank</option>
                                                        <option value="ACB" ${currentBank == 'ACB' ? 'selected' : ''}>
                                                            ACB</option>
                                                        <option value="MB Bank"
                                                            ${currentBank == 'MB Bank' ? 'selected' : ''}>MB Bank
                                                        </option>
                                                        <option value="VPBank"
                                                            ${currentBank == 'VPBank' ? 'selected' : ''}>VPBank</option>
                                                        <option value="Sacombank"
                                                            ${currentBank == 'Sacombank' ? 'selected' : ''}>Sacombank
                                                        </option>
                                                        <option value="TPBank"
                                                            ${currentBank == 'TPBank' ? 'selected' : ''}>TPBank</option>
                                                    </select>
                                                </div>

                                                <!-- Account Number -->
                                                <div class="mb-4">
                                                    <label for="bankAccountNumber" class="form-label fw-bold">
                                                        Số tài khoản <span class="text-danger">*</span>
                                                    </label>
                                                    <c:set var="currentAccountNumber"
                                                        value="${fn:length(bankInfo) >= 3 ? bankInfo[2] : ''}" />
                                                    <input type="text" class="form-control form-control-lg"
                                                        id="bankAccountNumber" name="bankAccountNumber"
                                                        value="${currentAccountNumber}" placeholder="Nhập số tài khoản"
                                                        required pattern="[a-zA-Z0-9]+">
                                                    <div class="invalid-feedback">
                                                        Số tài khoản chỉ được chứa chữ cái và số, không có ký tự đặc biệt
                                                    </div>
                                                </div>

                                                <!-- Account Name -->
                                                <div class="mb-4">
                                                    <label for="bankAccountName" class="form-label fw-bold">
                                                        Tên chủ tài khoản <span class="text-danger">*</span>
                                                    </label>
                                                    <c:set var="currentAccountName"
                                                        value="${fn:length(bankInfo) >= 4 ? bankInfo[3] : ''}" />
                                                    <input type="text" class="form-control form-control-lg"
                                                        id="bankAccountName" name="bankAccountName"
                                                        value="${currentAccountName}"
                                                        placeholder="Nhập tên chủ tài khoản" 
                                                        required pattern="[a-zA-Z0-9\s]+">
                                                    <div class="invalid-feedback">
                                                        Tên tài khoản chỉ được chứa chữ cái không dấu, số và khoảng trắng
                                                    </div>
                                                </div>

                                                <!-- Note -->
                                                <div class="mb-4">
                                                    <label for="description" class="form-label fw-bold">
                                                        Ghi chú (không bắt buộc)
                                                    </label>
                                                    <textarea class="form-control" id="description" name="description"
                                                        rows="3" placeholder="Ghi chú thêm (nếu có)"></textarea>
                                                </div>

                                                <!-- Submit Buttons -->
                                                <div class="d-grid gap-2 d-md-flex justify-content-md-end">
                                                    <a href="/seller/withdrawals" class="btn btn-outline-secondary btn-lg">
                                                        Hủy bỏ
                                                    </a>
                                                    <button type="submit" class="btn btn-primary btn-lg">
                                                        <i class="bi bi-check-circle me-2"></i>Cập nhật
                                                    </button>
                                                </div>
                                            </form>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        </main>
                    </div> <!-- End container-fluid -->
                </div> <!-- End content -->

                <!-- Include Footer -->
                <jsp:include page="../../common/footer.jsp" />

                <script>
                    const userBalance = ${currentUser.balance};
                    const originalAmount = ${withdrawal.amount};

                    $(document).ready(function () {
                        // Amount is now readonly, no need to initialize currency input
                        initFormValidation();
                    });

                    function initFormValidation() {
                        $('#editForm').on('submit', function (e) {
                            // Amount cannot be changed, so no validation needed
                            // Just validate bank info fields (browser built-in validation handles this)
                            
                            // Form will submit normally with original amount value
                            return true;
                        });
                    }

                    function formatCurrency(value) {
                        return value.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',');
                    }

                    function showError(fieldId, message) {
                        const field = $('#' + fieldId);
                        field.addClass('is-invalid');
                        $('#amountError').text(message).show();

                        iziToast.error({
                            title: 'Lỗi',
                            message: message,
                            position: 'topRight'
                        });
                    }

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
