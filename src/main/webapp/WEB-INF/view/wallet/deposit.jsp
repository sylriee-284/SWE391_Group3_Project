<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>

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
                    <div class="container mt-5">
                        <div class="row justify-content-center">
                            <div class="col-md-6">
                                <div class="card">
                                    <div class="card-header bg-primary text-white text-center">
                                        <h4><i class="fas fa-plus-circle"></i> Add Money to Wallet</h4>
                                    </div>
                                    <div class="card-body">
                                        <!-- Error messages from Model -->
                                        <c:if test="${not empty error}">
                                            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                                                <i class="fas fa-exclamation-circle"></i> ${error}
                                                <button type="button" class="btn-close"
                                                    data-bs-dismiss="alert"></button>
                                            </div>
                                        </c:if>

                                        <!-- Legacy error messages from URL parameters -->
                                        <c:if test="${param.error eq 'invalid_amount'}">
                                            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                                                <i class="fas fa-exclamation-circle"></i> Số tiền tối thiểu là 10.000 VNĐ
                                                <button type="button" class="btn-close"
                                                    data-bs-dismiss="alert"></button>
                                            </div>
                                        </c:if>

                                        <c:if test="${param.error eq 'encoding'}">
                                            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                                                <i class="fas fa-exclamation-circle"></i> Đã xảy ra lỗi. Vui lòng thử
                                                lại!
                                                <button type="button" class="btn-close"
                                                    data-bs-dismiss="alert"></button>
                                            </div>
                                        </c:if>

                                        <form action="/wallet/deposit" method="post" id="depositForm">
                                            <div class="mb-3">
                                                <label for="amount" class="form-label">
                                                    <i class="fas fa-money-bill-wave"></i> Số tiền (VNĐ)
                                                </label>
                                                <input type="text" class="form-control" id="amount" name="amount"
                                                    placeholder="Nhập số tiền muốn nạp (ví dụ: 100000)" required>
                                                <div class="form-text">Số tiền tối thiểu: 10.000 VNĐ</div>
                                                <small class="text-muted">Vui lòng chỉ nhập số. Dấu phẩy sẽ tự động được loại bỏ.</small>
                                                <div id="amountError" class="invalid-feedback" style="display: none;">
                                                    Vui lòng nhập số hợp lệ.
                                                </div>
                                            </div>

                                            <div class="alert alert-info">
                                                <i class="fas fa-info-circle"></i>
                                                <strong>Lưu ý:</strong> Bạn sẽ được chuyển đến trang thanh toán VNPay để
                                                hoàn tất
                                                giao dịch.
                                            </div>

                                            <div class="d-grid">
                                                <button type="submit" class="btn btn-primary btn-lg">
                                                    <i class="fas fa-credit-card"></i> Thanh toán với VNPay
                                                </button>
                                            </div>
                                        </form>

                                        <div class="text-center mt-3">
                                            <a href="/wallet" class="btn btn-outline-secondary">
                                                <i class="fas fa-arrow-left"></i> Quay lại Ví
                                            </a>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
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


                    // Form validation with input sanitization
                    document.getElementById('depositForm').addEventListener('submit', function (e) {
                        const amountInput = document.getElementById('amount');
                        const amountError = document.getElementById('amountError');
                        let amount = amountInput.value.trim();

                        // Remove commas if user added them
                        amount = amount.replace(/,/g, '');

                        // Validate: not empty
                        if (!amount) {
                            e.preventDefault();
                            amountError.style.display = 'block';
                            amountError.textContent = 'Vui lòng nhập số tiền';
                            amountInput.classList.add('is-invalid');
                            return false;
                        }

                        // Validate: only numbers
                        if (!/^\d+(\.\d{1,2})?$/.test(amount)) {
                            e.preventDefault();
                            amountError.style.display = 'block';
                            amountError.textContent = 'Số tiền không hợp lệ. Vui lòng nhập chỉ các chữ số';
                            amountInput.classList.add('is-invalid');
                            return false;
                        }

                        // Validate: minimum amount
                        const amountNum = parseFloat(amount);
                        if (amountNum < 10000) {
                            e.preventDefault();
                            amountError.style.display = 'block';
                            amountError.textContent = 'Số tiền nạp tối thiểu là 10.000 VNĐ';
                            amountInput.classList.add('is-invalid');
                            return false;
                        }

                        // Hide error if validation passes
                        amountError.style.display = 'none';
                        amountInput.classList.remove('is-invalid');

                        // Update hidden input with cleaned amount
                        amountInput.value = amount;

                        // Show loading state
                        const submitBtn = document.querySelector('button[type="submit"]');
                        const originalText = submitBtn.innerHTML;
                        submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Đang xử lý...';
                        submitBtn.disabled = true;

                        // Re-enable button after 3 seconds as fallback
                        setTimeout(() => {
                            submitBtn.innerHTML = originalText;
                            submitBtn.disabled = false;
                        }, 3000);
                    });

                    // Real-time input validation and formatting
                    document.getElementById('amount').addEventListener('input', function (e) {
                        const amountError = document.getElementById('amountError');
                        let value = e.target.value;

                        // Allow any input (removed character restriction)
                        // User can type letters, numbers, symbols - validation happens on submit

                        e.target.value = value;

                        // Clear error when user starts typing
                        if (value) {
                            amountError.style.display = 'none';
                            this.classList.remove('is-invalid');
                        }
                    });

                    // Clear error message when input gets focus
                    document.getElementById('amount').addEventListener('focus', function () {
                        const amountError = document.getElementById('amountError');
                        amountError.style.display = 'none';
                        this.classList.remove('is-invalid');
                    });

                </script>
            </body>

            </html>