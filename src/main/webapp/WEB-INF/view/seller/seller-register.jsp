<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
            <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

                <!DOCTYPE html>
                <html lang="en">

                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>Đăng ký Cửa hàng - MMO Market System</title>

                    <!-- Include common head with all CSS and JS -->
                    <jsp:include page="../common/head.jsp" />
                </head>

                <body>
                    <!-- Include Navbar -->
                    <jsp:include page="../common/navbar.jsp" />

                    <!-- Include Sidebar -->
                    <jsp:include page="../common/sidebar.jsp" />

                    <!-- Sidebar Overlay for Mobile -->
                    <div class="sidebar-overlay" id="sidebarOverlay" onclick="toggleSidebar()"></div>

                    <!-- Sidebar Overlay for Mobile -->
                    <div class="sidebar-overlay" id="sidebarOverlay" onclick="toggleSidebar()"></div>

                    <!-- Main Content Area -->
                    <div class="content" id="content">
                        <div class="container-fluid">
                            <div class="row justify-content-center">
                                <div class="col-lg-8">
                                    <!-- Seller Registration Card -->
                                    <div class="profile-card">
                                        <div class="profile-header">
                                            <div class="profile-avatar">
                                                <i class="fas fa-store"></i>
                                            </div>
                                            <h2>Đăng ký Cửa hàng</h2>
                                        </div>

                                        <!-- Deposit Information Alert -->
                                        <div class="alert alert-info mb-4">
                                            <h5><i class="fas fa-info-circle"></i> Thông tin quan trọng:</h5>
                                            <ul class="mb-0">
                                                <li>Số tiền ký quỹ tối thiểu: <strong>5.000.000 VNĐ</strong></li>
                                                <li>Giá niêm yết sản phẩm: <strong>10%</strong> số tiền ký quỹ</li>
                                            </ul>
                                        </div>

                                        <!-- Current Balance Information -->
                                        <div class="alert alert-secondary mb-4">
                                            <i class="fas fa-wallet me-2"></i>
                                            Số dư hiện tại: <strong>
                                                <fmt:formatNumber value="${userBalance}" type="currency"
                                                    currencyCode="VND" />
                                            </strong>
                                        </div>

                                        <!-- Registration Form -->
                                        <form action="${pageContext.request.contextPath}/seller/register" method="POST"
                                            id="sellerRegistrationForm" class="mt-4">
                                            <!-- Owner Information Section -->
                                            <div class="form-section">
                                                <h4><i class="fas fa-user text-primary"></i> Thông tin chủ cửa hàng</h4>
                                                <div class="row">
                                                    <div class="col-md-6 mb-3">
                                                        <label class="form-label">ID người dùng</label>
                                                        <div class="input-group">
                                                            <span class="input-group-text"><i
                                                                    class="fas fa-id-card"></i></span>
                                                            <input type="text" class="form-control" value="#${user.id}"
                                                                readonly>
                                                        </div>
                                                    </div>
                                                    <div class="col-md-6 mb-3">
                                                        <label class="form-label">Tên đăng nhập</label>
                                                        <div class="input-group">
                                                            <span class="input-group-text"><i
                                                                    class="fas fa-user"></i></span>
                                                            <input type="text" class="form-control"
                                                                value="${user.username}" readonly>
                                                            <input type="hidden" name="ownerName"
                                                                value="${user.username}">
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>

                                            <!-- Store Information Section -->
                                            <div class="form-section mt-4">
                                                <h4><i class="fas fa-store text-primary"></i> Thông tin cửa hàng</h4>
                                                <div class="row">
                                                    <div class="col-md-12 mb-3">
                                                        <label class="form-label" for="storeName">Tên cửa hàng <span
                                                                class="text-danger">*</span></label>
                                                        <div class="input-group">
                                                            <span class="input-group-text"><i
                                                                    class="fas fa-store"></i></span>
                                                            <input type="text" class="form-control" id="storeName"
                                                                name="storeName" required minlength="3" maxlength="100"
                                                                data-store-check-url="${pageContext.request.contextPath}/seller/check-store-name">
                                                        </div>
                                                        <small class="text-muted">Tên cửa hàng phải là duy nhất</small>
                                                        <div id="storeNameFeedback" class="invalid-feedback"></div>
                                                    </div>
                                                </div>
                                                <div class="row">
                                                    <div class="col-md-12 mb-3">
                                                        <label class="form-label" for="storeDescription">Mô tả cửa
                                                            hàng</label>
                                                        <div class="input-group">
                                                            <span class="input-group-text"><i
                                                                    class="fas fa-info-circle"></i></span>
                                                            <textarea class="form-control" id="storeDescription"
                                                                name="storeDescription" rows="3"
                                                                maxlength="500"></textarea>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>

                                            <!-- Deposit Information Section -->
                                            <div class="form-section mt-4">
                                                <h4><i class="fas fa-money-check-alt text-success"></i> Thông tin ký quỹ
                                                </h4>
                                                <div class="row">
                                                    <div class="col-md-12 mb-3">
                                                        <label class="form-label" for="depositAmount">Số tiền ký quỹ
                                                            (VNĐ) <span class="text-danger">*</span></label>
                                                        <div class="input-group">
                                                            <span class="input-group-text"><i
                                                                    class="fas fa-money-bill-wave"></i></span>
                                                            <input type="text" class="form-control text-end"
                                                                id="depositAmount" name="depositAmount" required>
                                                            <span class="input-group-text">VNĐ</span>
                                                        </div>
                                                        <div id="depositAmountHelp" class="form-text">
                                                            <i class="fas fa-info-circle"></i>
                                                            Số tiền ký quỹ tối thiểu là 5.000.000 VNĐ, tăng theo bước
                                                            100.000 VNĐ
                                                        </div>
                                                        <div id="depositAmountError" class="invalid-feedback">
                                                            Số tiền không hợp lệ
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>

                                            <!-- Error Message Display -->
                                            <c:if test="${not empty error}">
                                                <div class="alert alert-danger mt-3">
                                                    <i class="fas fa-exclamation-circle"></i> ${error}
                                                </div>
                                            </c:if>

                                            <!-- Submit Button -->
                                            <div class="form-section mt-4">
                                                <button type="submit" class="btn btn-primary btn-lg w-100"
                                                    id="submitBtn">
                                                    <i class="fas fa-check-circle me-2"></i> Đăng ký Cửa hàng
                                                </button>
                                            </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    </div>

                    <!-- Include Footer -->
                    <jsp:include page="../common/footer.jsp" />

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
                            var alerts = document.querySelectorAll('.alert:not(.alert-info):not(.alert-secondary)');
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

                    <!-- Custom Scripts -->
                    <script>
                        $(document).ready(function () {
                            let storeNameTimer;
                            const $storeName = $('#storeName');
                            const $storeNameFeedback = $('#storeNameFeedback');
                            const $depositAmount = $('#depositAmount');
                            const checkUrl = $storeName.data('store-check-url');

                            // Hàm format số thành tiền VNĐ
                            function formatCurrency(number) {
                                return new Intl.NumberFormat('vi-VN').format(number);
                            }

                            // Hàm chuyển chuỗi tiền thành số
                            function parseCurrency(string) {
                                if (!string) return 0;
                                return parseInt(string.replace(/\D/g, ''));
                            }

                            // Kiểm tra tên cửa hàng khi nhập
                            $storeName.on('input', function () {
                                clearTimeout(storeNameTimer);
                                const value = $(this).val().trim();

                                if (value.length < 3) {
                                    $storeName.removeClass('is-valid is-invalid');
                                    return;
                                }

                                storeNameTimer = setTimeout(function () {
                                    $.get(checkUrl, { storeName: value })
                                        .done(function (response) {
                                            if (response.exists) {
                                                $storeName.removeClass('is-valid').addClass('is-invalid');
                                                $storeNameFeedback.text(response.message);
                                            } else {
                                                $storeName.removeClass('is-invalid').addClass('is-valid');
                                                $storeNameFeedback.text('');
                                            }
                                        });
                                }, 500);
                            });

                            // Xử lý input số tiền
                            // Format số tiền khi nhập
                            $depositAmount.on('input', function (e) {
                                let value = parseCurrency($(this).val());
                                if (!isNaN(value)) {
                                    $(this).val(formatCurrency(value));
                                }
                            });

                            // Validate số tiền khi nhập xong
                            $depositAmount.on('blur', function () {
                                let value = parseCurrency($(this).val());

                                if (value > 0) {
                                    // Kiểm tra giá trị tối thiểu
                                    if (value < 5000000) {
                                        value = 5000000;
                                        toastr.info('Số tiền đã được điều chỉnh lên mức tối thiểu 5.000.000 VNĐ');
                                    }
                                    // Làm tròn đến 100.000 VNĐ
                                    const roundedValue = Math.round(value / 100000) * 100000;
                                    if (roundedValue !== value) {
                                        value = roundedValue;
                                        toastr.info('Số tiền đã được làm tròn đến 100.000 VNĐ gần nhất');
                                    }
                                    // Cập nhật giá trị và hiển thị
                                    $(this).val(formatCurrency(value));
                                    $(this).removeClass('is-invalid').addClass('is-valid');
                                } else {
                                    $(this).addClass('is-invalid');
                                    $('#depositAmountError').text('Vui lòng nhập số tiền từ 5.000.000 VNĐ');
                                }
                            });

                            // Form validation
                            $('#sellerRegistrationForm').on('submit', function (e) {
                                const $form = $(this);
                                const depositAmount = parseCurrency($depositAmount.val());

                                // Kiểm tra số tiền ký quỹ
                                if (isNaN(depositAmount) || depositAmount < 5000000 || depositAmount % 100000 !== 0) {
                                    e.preventDefault();
                                    $depositAmount.addClass('is-invalid');
                                    $('#depositAmountError').text('Số tiền phải từ 5.000.000 VNĐ và chia hết cho 100.000 VNĐ');
                                    toastr.error('Vui lòng kiểm tra lại số tiền ký quỹ!');
                                    return false;
                                }

                                // Kiểm tra tên cửa hàng hợp lệ
                                if ($storeName.hasClass('is-invalid')) {
                                    e.preventDefault();
                                    toastr.error('Vui lòng chọn tên cửa hàng khác!');
                                    return false;
                                }

                                // Gửi giá trị số (không có dấu phân cách) lên server
                                $form.find('input[name="depositAmount"]').val(depositAmount);
                                return true;
                            });
                        });
                    </script>
                </body>

                </html>