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
                            <div class="warning-box">
                                <i class="bi bi-exclamation-triangle me-2"></i>
                                <strong>Lưu ý:</strong> Bạn chỉ có thể sửa yêu cầu khi đang ở trạng thái "Chờ duyệt"
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

                                                <!-- Amount -->
                                                <div class="mb-4">
                                                    <label for="amount" class="form-label fw-bold">
                                                        Số tiền rút <span class="text-danger">*</span>
                                                    </label>
                                                    <div class="currency-input">
                                                        <input type="text" class="form-control form-control-lg amount-input"
                                                            id="amountDisplay" placeholder="Nhập số tiền muốn rút"
                                                            required>
                                                        <input type="hidden" name="amount" id="amountValue"
                                                            value="${withdrawal.amount}">
                                                    </div>
                                                    <div class="form-text">
                                                        Số tiền tối thiểu: 100,000₫ | Số tiền hiện tại: <strong>
                                                            <fmt:formatNumber value="${withdrawal.amount}"
                                                                type="currency" currencySymbol="" />₫
                                                        </strong>
                                                    </div>
                                                    <div class="invalid-feedback" id="amountError"></div>
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
                                                        required pattern="[0-9]+">
                                                    <div class="invalid-feedback">
                                                        Số tài khoản chỉ được chứa số
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
                                                        placeholder="Nhập tên chủ tài khoản" required>
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
                    </div>

                    <!-- Include Footer -->
                    <jsp:include page="../../common/footer.jsp" />
                </div>

                <script>
                    const userBalance = ${currentUser.balance};
                    const originalAmount = ${withdrawal.amount};
                    const MIN_AMOUNT = 100000;

                    $(document).ready(function () {
                        // Initialize with current amount
                        $('#amountDisplay').val(formatCurrency(originalAmount));
                        initCurrencyInput();
                        initFormValidation();
                    });

                    function initCurrencyInput() {
                        $('#amountDisplay').on('input', function () {
                            let value = $(this).val().replace(/[^0-9]/g, '');
                            $('#amountValue').val(value);

                            if (value) {
                                $(this).val(formatCurrency(value));
                            }
                        });
                    }

                    function initFormValidation() {
                        $('#editForm').on('submit', function (e) {
                            e.preventDefault();

                            const amount = parseFloat($('#amountValue').val()) || 0;

                            // Validate amount
                            if (amount < MIN_AMOUNT) {
                                showError('amountDisplay', 'Số tiền rút tối thiểu là ' + formatCurrency(MIN_AMOUNT) + '₫');
                                return false;
                            }

                            // Calculate available balance (current balance + original withdrawal amount)
                            const maxAllowed = userBalance + originalAmount;
                            if (amount > maxAllowed) {
                                showError('amountDisplay', 'Số tiền rút vượt quá số dư khả dụng');
                                return false;
                            }

                            // If validation passes, submit form
                            this.submit();
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
