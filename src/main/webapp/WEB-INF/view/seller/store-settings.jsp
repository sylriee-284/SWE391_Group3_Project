<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
            <%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>

                <!DOCTYPE html>
                <html lang="en">

                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>Cài Đặt Cửa Hàng - Đóng Cửa Hàng</title>

                    <!-- Include common head with all CSS and JS -->
                    <jsp:include page="../common/head.jsp" />

                    <!-- Store Settings specific CSS -->
                    <link rel="stylesheet" href="<c:url value='/resources/css/store-settings.css' />">
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
                        <div class="container-fluid">
                            <div class="settings-card">
                                <h2 class="mb-4">Cài Đặt Cửa Hàng</h2>

                                <div id="storeInfo">
                                    <div class="info-row">
                                        <span class="info-label">Tên Cửa Hàng:</span>
                                        <span class="info-value" id="storeName">Đang tải...</span>
                                    </div>
                                    <div class="info-row">
                                        <span class="info-label">Trạng Thái:</span>
                                        <span class="info-value">
                                            <span id="storeStatus" class="badge badge-custom bg-success">HOẠT
                                                ĐỘNG</span>
                                        </span>
                                    </div>
                                    <div class="info-row">
                                        <span class="info-label">Ngày Tạo:</span>
                                        <span class="info-value" id="createdAt">-</span>
                                    </div>
                                </div>
                                <div class="info-row">
                                    <span class="info-label">Mô Hình Phí:</span>
                                    <span class="info-value" id="feeModel">-</span>
                                </div>
                                <div class="info-row">
                                    <span class="info-label">Số Tiền Đặt Cọc:</span>
                                    <span class="info-value" id="depositAmount">-</span>
                                </div>
                                <div class="info-row">
                                    <span class="info-label">Số Tháng Hoạt Động:</span>
                                    <span class="info-value" id="openMonths">-</span>
                                </div>
                            </div>

                            <!-- Danger Zone or Already Closed Message -->
                            <c:choose>
                                <c:when test="${store.status == 'INACTIVE'}">
                                    <!-- Store Already Closed -->
                                    <div class="alert alert-info mt-4">
                                        <h4><i class="fas fa-info-circle"></i> Cửa Hàng Đã Đóng</h4>
                                        <p class="mb-3">Cửa hàng của bạn đã được đóng và không còn nhận đơn hàng mới.
                                        </p>
                                        <a href="/seller/store/${store.id}/close/result" class="btn btn-primary">
                                            <i class="fas fa-eye"></i> Xem Chi Tiết Đóng Cửa
                                        </a>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <!-- Danger Zone - Active Store -->
                                    <div class="danger-zone">
                                        <h4><i class="fas fa-exclamation-triangle"></i> Đóng cửa hàng</h4>
                                        <p class="mb-3">Khi đóng cửa hàng, tất cả sản phẩm sẽ bị ẩn khỏi khách hàng. Bạn
                                            có thể kích hoạt lại cửa hàng sau này bằng cách thanh toán lại phí kích
                                            hoạt.</p>
                                        <button id="btnCloseStore" class="btn btn-danger">
                                            <i class="fas fa-times-circle"></i> Đóng Cửa Hàng
                                        </button>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                    </div>
                    </div>

                    <!-- Modal Step 1: Confirm Close -->
                    <div id="modalConfirmClose" class="modal">
                        <div class="modal-content">
                            <span class="close-btn" id="closeModal1">&times;</span>
                            <h3><i class="fas fa-exclamation-triangle text-warning"></i> Xác Nhận Đóng Cửa Hàng</h3>
                            <p class="mt-3">Bạn có chắc chắn muốn đóng cửa hàng? Cửa hàng sẽ bị tạm ngưng và bạn có thể
                                kích hoạt lại sau này.</p>

                            <div class="form-group mt-4">
                                <label for="reasonInput">Lý Do Đóng Cửa <span class="text-danger">*</span></label>
                                <textarea id="reasonInput" class="form-control" rows="3"
                                    placeholder="Vui lòng cho chúng tôi biết lý do bạn đóng cửa..." maxlength="250"
                                    required></textarea>
                                <div class="form-text">
                                    <span id="charCount">0</span>/250 ký tự
                                </div>
                                <div id="reasonError" class="invalid-feedback" style="display: none;"></div>
                            </div>

                            <div class="form-check mt-3">
                                <input type="checkbox" class="form-check-input" id="agreeCheck">
                                <label class="form-check-label" for="agreeCheck">
                                    Tôi hiểu rằng sau khi đóng cửa hàng, tôi cần thanh toán lại phí kích hoạt để mở lại,
                                    và hiện tại tôi không có đơn hàng đang chờ hoặc tiền ký quỹ.
                                </label>
                            </div>

                            <div class="mt-4">
                                <button id="btnConfirm" class="btn btn-warning">
                                    <i class="fas fa-check"></i> Xác Nhận & Tiếp Tục
                                </button>
                                <button class="btn btn-secondary" id="cancelModal1">Hủy</button>
                            </div>
                        </div>
                    </div>

                    <!-- Modal Step 2: Refund Quote -->
                    <div id="modalRefundQuote" class="modal">
                        <div class="modal-content">
                            <span class="close-btn" id="closeModal2">&times;</span>
                            <h3><i class="fas fa-money-bill-wave text-success"></i> Tính Toán Hoàn Tiền Đặt Cọc</h3>

                            <div class="refund-breakdown mt-4">
                                <h5>Chi Tiết Hoàn Tiền</h5>
                                <div class="refund-row">
                                    <span>Quy Tắc Áp Dụng:</span>
                                    <strong id="ruleApplied">-</strong>
                                </div>
                                <div class="refund-row">
                                    <span>Tiền Đặt Cọc Gốc:</span>
                                    <span id="originalDeposit">-</span>
                                </div>
                                <div class="refund-row">
                                    <span>Tỷ Lệ Hoàn Tiền:</span>
                                    <span id="refundRate">-</span>
                                </div>
                                <div class="refund-row refund-total">
                                    <span>Tổng Hoàn Tiền:</span>
                                    <span id="refundAmount">-</span>
                                </div>
                            </div>

                            <div class="alert alert-info mt-3">
                                <i class="fas fa-info-circle"></i> Số tiền hoàn trả sẽ được chuyển vào ví của bạn ngay
                                sau khi xác nhận.
                            </div>

                            <div class="mt-4">
                                <button id="btnFinalConfirm" class="btn btn-success">
                                    <i class="fas fa-check-circle"></i> Xác Nhận & Đóng Cửa Hàng
                                </button>
                                <button class="btn btn-secondary" id="cancelModal2">Hủy</button>
                            </div>
                        </div>
                    </div>

                    <!-- Footer -->
                    <jsp:include page="../common/footer.jsp" />

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

                        // ========== Store Settings Specific Scripts ==========
                        var storeId = <c:out value="${store.id}" default="0" />;
                        var previewData = null;

                        // Load preview data on page load
                        $(document).ready(function () {
                            loadPreviewData();
                            setupReasonValidation();
                        });

                        // Validation cho trường lý do
                        function setupReasonValidation() {
                            const reasonInput = $('#reasonInput');
                            const charCount = $('#charCount');
                            const reasonError = $('#reasonError');

                            // Real-time character count
                            reasonInput.on('input', function () {
                                const length = $(this).val().length;
                                charCount.text(length);

                                // Validate on input
                                validateReason();
                            });

                            // Prevent paste nội dung quá dài
                            reasonInput.on('paste', function (e) {
                                setTimeout(function () {
                                    const currentLength = reasonInput.val().length;
                                    if (currentLength > 250) {
                                        reasonInput.val(reasonInput.val().substring(0, 250));
                                        charCount.text('250');
                                        showReasonError('Nội dung đã được cắt bớt để phù hợp giới hạn 250 ký tự');
                                    }
                                }, 10);
                            });
                        }

                        function validateReason() {
                            const reasonInput = $('#reasonInput');
                            const reasonValue = reasonInput.val();
                            const reasonTrimmed = reasonValue.trim();
                            const reasonError = $('#reasonError');

                            // Clear previous error
                            reasonInput.removeClass('is-invalid');
                            reasonError.hide();

                            // Kiểm tra bắt buộc phải nhập
                            if (reasonValue.length === 0) {
                                showReasonError('Vui lòng nhập lý do đóng cửa hàng');
                                return false;
                            }

                            // Kiểm tra chỉ chứa khoảng trắng
                            if (reasonTrimmed.length === 0) {
                                showReasonError('Lý do không được chỉ chứa khoảng trắng');
                                return false;
                            }

                            // Kiểm tra khoảng trắng đầu/cuối
                            if (reasonValue !== reasonTrimmed) {
                                showReasonError('Lý do không được có khoảng trắng ở đầu hoặc cuối');
                                return false;
                            }

                            // Kiểm tra nhiều khoảng trắng liên tiếp
                            if (/\s{2,}/.test(reasonValue)) {
                                showReasonError('Lý do không được có nhiều khoảng trắng liên tiếp');
                                return false;
                            }

                            // Minimum length nếu có nhập (sau khi trim)
                            if (reasonTrimmed.length < 10) {
                                showReasonError('Lý do phải có ít nhất 10 ký tự (không tính khoảng trắng thừa)');
                                return false;
                            }

                            // Maximum length
                            if (reasonValue.length > 250) {
                                showReasonError('Lý do không được vượt quá 250 ký tự');
                                return false;
                            }

                            // Kiểm tra nội dung spam/lặp lại
                            if (isSpamContent(reasonTrimmed)) {
                                showReasonError('Vui lòng nhập nội dung có ý nghĩa, không lặp lại ký tự');
                                return false;
                            }

                            // Kiểm tra ký tự đặc biệt quá nhiều
                            const specialChars = (reasonTrimmed.match(/[^a-zA-Z0-9\sÀ-ỹ\u0080-\u024F.,!?;:()\-]/g) || []).length;
                            if (specialChars > 20) {
                                showReasonError('Nội dung chứa quá nhiều ký tự đặc biệt không hợp lệ');
                                return false;
                            }

                            return true;
                        }

                        function isSpamContent(text) {
                            // Kiểm tra ký tự lặp liên tiếp (ví dụ: "aaaaaaa", "1111111")
                            const repeatedChars = /(.)\1{6,}/;
                            if (repeatedChars.test(text)) {
                                return true;
                            }

                            // Kiểm tra từ lặp liên tiếp (ví dụ: "abc abc abc abc")
                            const words = text.split(/\s+/);
                            if (words.length >= 4) {
                                const uniqueWords = new Set(words);
                                if (uniqueWords.size < words.length * 0.3) {
                                    return true;
                                }
                            }

                            return false;
                        }

                        function showReasonError(message) {
                            const reasonInput = $('#reasonInput');
                            const reasonError = $('#reasonError');

                            reasonInput.addClass('is-invalid');
                            reasonError.text(message).show();
                        }

                        function loadPreviewData() {
                            $.ajax({
                                url: '/seller/store/' + storeId + '/close/preview',
                                type: 'GET',
                                success: function (data) {
                                    previewData = data;
                                    displayPreviewData(data);
                                },
                                error: function (xhr) {
                                    alert('Failed to load store data: ' + (xhr.responseJSON?.error || 'Unknown error'));
                                }
                            });
                        }

                        function displayPreviewData(data) {
                            $('#storeName').text(data.storeName);
                            $('#storeStatus').text(data.status).removeClass().addClass('badge badge-custom bg-' +
                                (data.status === 'ACTIVE' ? 'success' : 'secondary'));
                            $('#createdAt').text(new Date(data.createdAt).toLocaleDateString());
                            $('#feeModel').text(data.feeModel);
                            $('#depositAmount').text(formatMoney(data.depositAmount) + ' VND');
                            $('#openMonths').text(data.openMonths + ' months');
                        }

                        // Open Modal 1
                        $('#btnCloseStore').click(function () {
                            $('#modalConfirmClose').fadeIn();
                            $('#agreeCheck').prop('checked', false);
                        });

                        // Close modals
                        $('#closeModal1, #cancelModal1').click(function () {
                            $('#modalConfirmClose').fadeOut();
                        });

                        $('#closeModal2, #cancelModal2').click(function () {
                            $('#modalRefundQuote').fadeOut();
                        });

                        // Validate and proceed to Step 2
                        $('#btnConfirm').click(function () {
                            if (!$('#agreeCheck').is(':checked')) {
                                alert('Vui lòng đánh dấu vào ô đồng ý');
                                return;
                            }

                            // Validate reason trước khi submit
                            if (!validateReason()) {
                                return;
                            }

                            $.ajax({
                                url: '/seller/store/' + storeId + '/close/validate',
                                type: 'POST',
                                contentType: 'application/json',
                                data: JSON.stringify({ agree: true }),
                                success: function (resp) {
                                    if (!resp.ok) {
                                        // Check if there are errors and determine the message
                                        let errorMessage = 'Không thể đóng cửa hàng. ';

                                        if (resp.errors && resp.errors.length > 0) {
                                            // Check for specific error types
                                            let hasEscrowError = resp.errors.some(err => err.code === 'ESCROW_HELD');
                                            let hasPendingOrders = resp.errors.some(err => err.code === 'PENDING_ORDERS');

                                            if (hasEscrowError) {
                                                errorMessage = 'Vui lòng chờ hệ thống giải ngân ký quỹ và thử lại sau.';
                                            } else if (hasPendingOrders) {
                                                errorMessage = 'Bạn còn đơn hàng đang chờ xử lý. Vui lòng hoàn thành trước khi đóng cửa hàng.';
                                            } else {
                                                errorMessage += 'Vui lòng kiểm tra lại đơn hàng và ký quỹ.';
                                            }
                                        }

                                        alert(errorMessage);
                                    } else {
                                        // Show refund quote modal
                                        showRefundQuote(resp);
                                    }
                                },
                                error: function (xhr) {
                                    alert('Xác thực thất bại: ' + (xhr.responseJSON?.error || 'Vui lòng kiểm tra lại đơn hàng và ký quỹ'));
                                }
                            });
                        });

                        function showRefundQuote(data) {
                            $('#modalConfirmClose').fadeOut();

                            let rate = '';
                            if (data.ruleApplied === 'NO_FEE') {
                                rate = '50%';
                            } else if (data.ruleApplied === 'GE_12M') {
                                rate = '100%';
                            } else {
                                rate = '70%';
                            }

                            $('#ruleApplied').text(data.ruleApplied);
                            $('#originalDeposit').text(formatMoney(previewData.depositAmount) + ' VND');
                            $('#refundRate').text(rate);
                            $('#refundAmount').text(formatMoney(data.depositRefund) + ' VND');

                            $('#modalRefundQuote').fadeIn();
                        }

                        // Final confirmation
                        $('#btnFinalConfirm').click(function () {
                            let reason = $('#reasonInput').val().trim();

                            // Validate lần cuối trước khi confirm
                            if (!validateReason()) {
                                return;
                            }

                            $(this).prop('disabled', true).html('<i class="fas fa-spinner fa-spin"></i> Đang xử lý...');

                            $.ajax({
                                url: '/seller/store/' + storeId + '/close/confirm',
                                type: 'POST',
                                contentType: 'application/json',
                                data: JSON.stringify({ reason: reason }),
                                success: function (resp) {
                                    if (resp.ok) {
                                        window.location.href = '/seller/store/' + storeId + '/close/result';
                                    } else {
                                        alert('Không thể đóng cửa hàng');
                                        $('#btnFinalConfirm').prop('disabled', false).html('<i class="fas fa-check-circle"></i> Xác Nhận & Đóng Cửa Hàng');
                                    }
                                },
                                error: function (xhr) {
                                    alert('Lỗi: ' + (xhr.responseJSON?.error || 'Vui lòng chờ giải ngân'));
                                    $('#btnFinalConfirm').prop('disabled', false).html('<i class="fas fa-check-circle"></i> Xác Nhận & Đóng Cửa Hàng');
                                }
                            });
                        });

                        function formatMoney(amount) {
                            return parseFloat(amount).toLocaleString('en-US', { minimumFractionDigits: 0, maximumFractionDigits: 2 });
                        }
                    </script>
                </body>

                </html>