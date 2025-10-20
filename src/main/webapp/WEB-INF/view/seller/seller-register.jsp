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
                                                <li>Số tiền ký quỹ tối thiểu: <strong>
                                                        <fmt:formatNumber value="${minDepositAmount}" type="number"
                                                            pattern="#,###" /> VNĐ
                                                    </strong></li>
                                                <li>Giá niêm yết sản phẩm: <strong>
                                                        <fmt:formatNumber value="${maxListingPriceRate * 100}"
                                                            type="number" maxFractionDigits="0" />%
                                                    </strong> số tiền ký quỹ</li>
                                                <li>Phí nền tảng: <strong>
                                                        <fmt:formatNumber value="${platformFeeRate * 100}" type="number"
                                                            maxFractionDigits="0" />%
                                                    </strong> trên mỗi giao dịch</li>
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
                                                                value="${storeName}"
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
                                                                maxlength="500">${storeDescription}</textarea>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>

                                            <!-- Deposit Information Section -->
                                            <div class="form-section mt-4">
                                                <h4><i class="fas fa-money-check-alt text-success"></i> Thông tin ký quỹ
                                                </h4>
                                                <div class="row">
                                                    <div class="col-md-6 mb-3">
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
                                                            Tối thiểu: <fmt:formatNumber value="${minDepositAmount}" type="number"
                                                                pattern="#,###" /> VNĐ, bước nhảy: 100.000 VNĐ
                                                        </div>
                                                        <div id="depositAmountError" class="invalid-feedback">
                                                            Số tiền không hợp lệ
                                                        </div>
                                                    </div>

                                                    <!-- Display Max Listing Price as Input Field -->
                                                    <div class="col-md-6 mb-3" id="maxListingPriceContainer"
                                                        style="display: none;">
                                                        <label class="form-label" for="maxListingPrice">
                                                            <i class="fas fa-tag text-success"></i> Giá niêm yết tối đa
                                                        </label>
                                                        <div class="input-group">
                                                            <span class="input-group-text bg-success text-white">
                                                                <i class="fas fa-money-bill-wave"></i>
                                                            </span>
                                                            <input type="text" class="form-control text-end fw-bold"
                                                                id="maxListingPrice" readonly
                                                                style="background-color: #d1e7dd; cursor: not-allowed;">
                                                            <span
                                                                class="input-group-text bg-success text-white">VNĐ</span>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>

                                            <!-- Fee Model Selection Section -->
                                            <div class="form-section mt-4">
                                                <h4><i class="fas fa-percent text-primary"></i> Mô hình phí</h4>
                                                <div class="row">
                                                    <div class="col-md-12">
                                                        <div class="form-check">
                                                            <input class="form-check-input" type="radio" name="feeModel"
                                                                id="feeModelPercentage" value="PERCENTAGE" <c:if
                                                                test="${empty feeModel || feeModel == 'PERCENTAGE'}">checked
                                                            </c:if>>
                                                            <label class="form-check-label" for="feeModelPercentage">
                                                                <strong>Phí theo phần trăm (Khuyến nghị)</strong>
                                                                <div class="ms-4 text-muted small mt-1">
                                                                    <i class="fas fa-check-circle text-success"></i> Khi xoá cửa hàng, bạn sẽ được <strong class="text-success">hoàn lại tiền ký quỹ</strong>
                                                                </div>
                                                            </label>
                                                        </div>
                                                        <div class="form-check mt-3">
                                                            <input class="form-check-input" type="radio" name="feeModel"
                                                                id="feeModelNoFee" value="NO_FEE" <c:if
                                                                test="${feeModel == 'NO_FEE'}">checked</c:if>>
                                                            <label class="form-check-label" for="feeModelNoFee">
                                                                <strong>Không tính phí</strong>
                                                                <div class="ms-4 text-muted small mt-1">
                                                                    <i class="fas fa-times-circle text-danger"></i> Khi xoá cửa hàng, tiền ký quỹ <strong class="text-danger">KHÔNG được hoàn lại</strong>
                                                                </div>
                                                            </label>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>

                                            <!-- Error Message Display -->
                                            <c:if test="${not empty error}">
                                                <div
                                                    class="alert alert-danger mt-3 d-flex justify-content-between align-items-center">
                                                    <div>
                                                        <i class="fas fa-exclamation-circle"></i> ${error}
                                                    </div>
                                                    <c:if
                                                        test="${error.contains('Số dư không đủ') || error.contains('số dư không đủ')}">
                                                        <a href="${pageContext.request.contextPath}/wallet/deposit"
                                                            class="btn btn-warning btn-sm ms-3">
                                                            <i class="fas fa-wallet me-1"></i> Nạp tiền ngay
                                                        </a>
                                                    </c:if>
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
                            console.log('=== Seller Registration Script Loaded ===');

                            let storeNameTimer;
                            const $storeName = $('#storeName');
                            const $storeNameFeedback = $('#storeNameFeedback');
                            const $depositAmount = $('#depositAmount');
                            const checkUrl = $storeName.data('store-check-url');

                            console.log('Deposit Amount Input Found:', $depositAmount.length > 0);
                            console.log('Max Listing Price Display Found:', $('#maxListingPriceContainer').length > 0);
                            console.log('Max Listing Price Input Found:', $('#maxListingPrice').length > 0);

                            // Get user balance from server
                            const userBalance = parseFloat('${userBalance}') || 0;
                            console.log('User Balance:', userBalance);

                            // Test function - có thể gọi từ console: testMaxPrice()
                            window.testMaxPrice = function () {
                                console.log('=== Testing Max Price Display ===');
                                $('#depositAmount').val('10000000');
                                $('#depositAmount').trigger('input');
                            };

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

                            // Get settings from model
                            const minDepositAmount = parseFloat('${minDepositAmount}') || 5000000;
                            const maxListingPriceRate = parseFloat('${maxListingPriceRate}') || 0.1;

                            console.log('Min Deposit Amount:', minDepositAmount);
                            console.log('Max Listing Price Rate:', maxListingPriceRate);

                            // Function to update max listing price display
                            function updateMaxListingPrice(depositAmount) {
                                console.log('=== updateMaxListingPrice called ===');
                                console.log('Deposit Amount:', depositAmount);
                                console.log('Max Listing Price Rate:', maxListingPriceRate);

                                if (depositAmount > 0 && depositAmount >= minDepositAmount) {
                                    const maxListingPrice = depositAmount * maxListingPriceRate;
                                    console.log('Calculated Max listing price:', maxListingPrice);

                                    const formattedPrice = formatCurrency(maxListingPrice);
                                    console.log('Formatted price:', formattedPrice);

                                    // Update input field value
                                    $('#maxListingPrice').val(formattedPrice);
                                    // Show container
                                    $('#maxListingPriceContainer').show();
                                    console.log('Display should be visible now');
                                } else {
                                    console.log('Hiding display - amount too low or zero');
                                    $('#maxListingPriceContainer').hide();
                                    $('#maxListingPrice').val('');
                                }
                            }

                            // Validate và hiển thị max listing price khi nhập
                            let isUpdating = false;

                            // Sử dụng cả input và keyup để đảm bảo cập nhật
                            $depositAmount.on('input keyup', function (e) {
                                if (isUpdating) return;

                                let inputVal = $(this).val();
                                console.log('Input value:', inputVal);
                                let value = parseCurrency(inputVal);
                                console.log('Parsed value:', value);

                                // Update max listing price ngay khi có giá trị hợp lệ
                                if (!isNaN(value) && value > 0) {
                                    console.log('Calling updateMaxListingPrice with:', value);
                                    updateMaxListingPrice(value);
                                } else {
                                    console.log('Hiding max listing price display');
                                    $('#maxListingPriceContainer').hide();
                                    $('#maxListingPrice').val('');
                                }
                            });

                            // Format số khi blur
                            $depositAmount.on('blur', function () {
                                isUpdating = true;
                                let value = parseCurrency($(this).val());
                                console.log('Blur - Parsed value:', value);

                                if (value > 0) {
                                    // Cập nhật giá trị và hiển thị
                                    $(this).val(formatCurrency(value));
                                    $(this).removeClass('is-invalid');
                                    // Update max listing price
                                    updateMaxListingPrice(value);
                                    $('#depositAmountError').text('');
                                } else {
                                    // Chỉ ẩn display, không hiển thị error
                                    $('#maxListingPriceContainer').hide();
                                    $('#maxListingPrice').val('');
                                }

                                isUpdating = false;
                            });

                            // Form validation
                            $('#sellerRegistrationForm').on('submit', function (e) {
                                const $form = $(this);
                                const depositAmount = parseCurrency($depositAmount.val());

                                // Kiểm tra tên cửa hàng hợp lệ
                                if ($storeName.hasClass('is-invalid')) {
                                    e.preventDefault();
                                    $('#storeNameFeedback').text('Vui lòng chọn tên cửa hàng khác!');
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