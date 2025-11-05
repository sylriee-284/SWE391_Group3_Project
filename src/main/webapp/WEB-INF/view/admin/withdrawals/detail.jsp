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
                    <title>Chi tiết yêu cầu rút tiền - Admin - MMO Market System</title>
                    <jsp:include page="../../common/head.jsp" />

                    <style>
                        .detail-card {
                            border-radius: 0.5rem;
                            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
                        }

                        .status-badge {
                            padding: 0.5rem 1rem;
                            border-radius: 0.25rem;
                            font-size: 1rem;
                            font-weight: 500;
                        }

                        .status-PENDING {
                            background-color: #fff3cd;
                            color: #856404;
                        }

                        .status-SUCCESS {
                            background-color: #d1e7dd;
                            color: #0f5132;
                        }

                        .status-FAILED {
                            background-color: #f8d7da;
                            color: #842029;
                        }

                        .status-CANCELLED {
                            background-color: #e2e3e5;
                            color: #41464b;
                        }

                        .status-REJECTED {
                            background-color: #f8d7da;
                            color: #842029;
                        }

                        .amount-display {
                            font-size: 2.5rem;
                            font-weight: bold;
                            color: #dc3545;
                        }

                        .info-row {
                            padding: 1rem 0;
                            border-bottom: 1px solid #e9ecef;
                        }

                        .info-row:last-child {
                            border-bottom: none;
                        }

                        .info-label {
                            font-weight: 600;
                            color: #6c757d;
                        }

                        .user-info-card {
                            background-color: #f8f9fa;
                            padding: 1.5rem;
                            border-radius: 0.5rem;
                            margin-bottom: 1.5rem;
                        }
                    </style>
                </head>

                <body>
                    <!-- Include Navbar -->
                    <jsp:include page="../../common/navbar.jsp" />

                    <!-- Include Sidebar -->
                    <jsp:include page="../../common/sidebar.jsp" />

                    <!-- Sidebar Overlay for Mobile -->
                    <div class="sidebar-overlay" id="sidebarOverlay" onclick="toggleSidebar()"></div>

                    <!-- Main Content Area -->
                    <div class="content" id="content">
                        <div class="container-fluid mt-4">
                            <div
                                class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center mb-3">
                                <h4>
                                    <i class="bi bi-file-text me-2"></i>Chi tiết yêu cầu rút tiền
                                </h4>
                                <div>
                                    <a href="/admin/withdrawals" class="btn btn-outline-secondary">
                                        <i class="bi bi-arrow-left me-2"></i>Quay lại danh sách
                                    </a>
                                </div>
                            </div>

                            <!-- Detail Card -->
                            <div class="row justify-content-center">
                                <div class="col-lg-10">
                                    <div class="card detail-card">
                                        <div class="card-body p-4">
                                            <!-- Header with Status -->
                                            <div class="d-flex justify-content-between align-items-center mb-4">
                                                <div>
                                                    <h3>Yêu cầu #${withdrawal.id}</h3>
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
                                                            <c:when test="${withdrawal.paymentStatus == 'REJECTED'}">
                                                                <i class="bi bi-x-circle me-1"></i>Từ chối
                                                            </c:when>
                                                            <c:when test="${withdrawal.paymentStatus == 'CANCELLED'}">
                                                                <i class="bi bi-slash-circle me-1"></i>Đã hủy
                                                            </c:when>
                                                        </c:choose>
                                                    </span>
                                                </div>
                                            </div>

                                            <!-- Transaction Information -->
                                            <h5 class="mb-3 mt-4">
                                                <i class="bi bi-info-circle me-2"></i>Thông tin giao dịch
                                            </h5>

                                            <div class="info-row row">
                                                <div class="col-md-4 info-label">Người tạo</div>
                                                <div class="col-md-8">
                                                    <strong>${withdrawal.user.fullName}</strong>
                                                    (${withdrawal.user.username})
                                                </div>
                                            </div>

                                            <div class="info-row row">
                                                <div class="col-md-4 info-label">Số tiền (bằng số)</div>
                                                <div class="col-md-8">
                                                    <strong>
                                                        <fmt:formatNumber value="${withdrawal.amount}" type="currency"
                                                            currencySymbol="" /> ₫
                                                    </strong>
                                                </div>
                                            </div>

                                            <div class="info-row row">
                                                <div class="col-md-4 info-label">Số tiền (bằng chữ)</div>
                                                <div class="col-md-8" id="amountInWords">
                                                    <em class="text-muted">Đang tính toán...</em>
                                                </div>
                                            </div>

                                            <div class="info-row row">
                                                <div class="col-md-4 info-label">Ngày tạo</div>
                                                <div class="col-md-8">
                                                    ${withdrawal.createdAt}
                                                </div>
                                            </div>

                                            <div class="info-row row">
                                                <div class="col-md-4 info-label">Cập nhật lần cuối</div>
                                                <div class="col-md-8">
                                                    ${withdrawal.updatedAt}
                                                </div>
                                            </div>

                                            <div class="info-row row">
                                                <div class="col-md-4 info-label">Ghi chú</div>
                                                <div class="col-md-8">
                                                    ${withdrawal.note}
                                                </div>
                                            </div>

                                            <!-- Bank Information (parsed from note) -->
                                            <c:set var="bankInfo" value="${fn:split(withdrawal.note, '-')}" />
                                            <c:if test="${fn:length(bankInfo) >= 4}">
                                                <h5 class="mb-3 mt-4">
                                                    <i class="bi bi-bank me-2"></i>Thông tin ngân hàng
                                                </h5>

                                                <div class="info-row row">
                                                    <div class="col-md-4 info-label">Ngân hàng</div>
                                                    <div class="col-md-8">
                                                        <strong>${fn:trim(bankInfo[1])}</strong>
                                                    </div>
                                                </div>

                                                <div class="info-row row">
                                                    <div class="col-md-4 info-label">Số tài khoản</div>
                                                    <div class="col-md-8">
                                                        ${fn:trim(bankInfo[2])}
                                                    </div>
                                                </div>

                                                <div class="info-row row">
                                                    <div class="col-md-4 info-label">Tên chủ tài khoản</div>
                                                    <div class="col-md-8">
                                                        ${fn:trim(bankInfo[3])}
                                                    </div>
                                                </div>
                                            </c:if>

                                            <!-- Actions for Pending Status -->
                                            <c:if test="${withdrawal.paymentStatus == 'PENDING'}">
                                                <div class="mt-4 pt-4 border-top">
                                                    <div class="d-grid gap-2 d-md-flex justify-content-md-end">
                                                        <button type="button" class="btn btn-danger btn-lg"
                                                            onclick="showRejectModal()">
                                                            <i class="bi bi-x-lg me-2"></i>Từ chối và hoàn tiền
                                                        </button>
                                                        <button type="button" class="btn btn-success btn-lg"
                                                            onclick="approveWithdrawal()">
                                                            <i class="bi bi-check-lg me-2"></i>Duyệt yêu cầu
                                                        </button>
                                                    </div>
                                                </div>
                                            </c:if>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Include Footer -->
                    <jsp:include page="../../common/footer.jsp" />

                    <!-- Reject Modal -->
                    <div class="modal fade" id="rejectModal" tabindex="-1" aria-labelledby="rejectModalLabel"
                        aria-hidden="true">
                        <div class="modal-dialog">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <h5 class="modal-title" id="rejectModalLabel">Từ chối yêu cầu rút tiền</h5>
                                    <button type="button" class="btn-close" data-bs-dismiss="modal"
                                        aria-label="Close"></button>
                                </div>
                                <form id="rejectForm" method="post" action="/admin/withdrawals/${withdrawal.id}/reject">
                                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                                    <div class="modal-body">
                                        <div class="alert alert-warning">
                                            <i class="bi bi-exclamation-triangle me-2"></i>
                                            Số tiền <strong>
                                                <fmt:formatNumber value="${withdrawal.amount}" type="currency"
                                                    currencySymbol="" /> ₫
                                            </strong>
                                            sẽ được hoàn lại vào tài khoản của người dùng.
                                        </div>
                                        <div class="mb-3">
                                            <label for="rejectReason" class="form-label">Lý do từ chối <span
                                                    class="text-danger">*</span></label>
                                            <textarea class="form-control" id="rejectReason" name="reason" rows="4"
                                                placeholder="Nhập lý do từ chối yêu cầu rút tiền..."
                                                required></textarea>
                                            <small class="text-muted">Lý do này sẽ được hiển thị cho người dùng</small>
                                        </div>
                                    </div>
                                    <div class="modal-footer">
                                        <button type="button" class="btn btn-secondary"
                                            data-bs-dismiss="modal">Hủy</button>
                                        <button type="submit" class="btn btn-danger">
                                            <i class="bi bi-x-lg me-2"></i>Xác nhận từ chối
                                        </button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>

                    <!-- Approve Form (hidden) -->
                    <form id="approveForm" method="post" action="/admin/withdrawals/${withdrawal.id}/approve"
                        style="display: none;">
                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                    </form>

                    <!-- iziToast CDN -->
                    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/izitoast@1.4.0/dist/css/iziToast.min.css">
                    <script src="https://cdn.jsdelivr.net/npm/izitoast@1.4.0/dist/js/iziToast.min.js"></script>

                    <script>
                        // Show success message if exists
                        var successMessage = '${success}';
                        if (successMessage && successMessage.trim() !== '') {
                            iziToast.success({
                                title: 'Thành công',
                                message: successMessage,
                                position: 'topRight'
                            });
                        }

                        // Show error message if exists
                        var errorMessage = '${error}';
                        if (errorMessage && errorMessage.trim() !== '') {
                            iziToast.error({
                                title: 'Lỗi',
                                message: errorMessage,
                                position: 'topRight'
                            });
                        }

                        // Function to convert number to Vietnamese words
                        function numberToVietnameseWords(num) {
                            if (num === 0) return "Không đồng";

                            const ones = ["", "một", "hai", "ba", "bốn", "năm", "sáu", "bảy", "tám", "chín"];
                            const tens = ["", "", "hai mươi", "ba mươi", "bốn mươi", "năm mươi", "sáu mươi", "bảy mươi", "tám mươi", "chín mươi"];
                            const scales = ["", "nghìn", "triệu", "tỷ"];

                            function convertGroup(n) {
                                let result = "";
                                let hundreds = Math.floor(n / 100);
                                let remainder = n % 100;
                                let tensDigit = Math.floor(remainder / 10);
                                let onesDigit = remainder % 10;

                                if (hundreds > 0) {
                                    result += ones[hundreds] + " trăm";
                                    if (remainder > 0) result += " ";
                                }

                                if (tensDigit > 1) {
                                    result += tens[tensDigit];
                                    if (onesDigit > 0) {
                                        if (onesDigit === 1) result += " một";
                                        else if (onesDigit === 5 && tensDigit > 0) result += " lăm";
                                        else result += " " + ones[onesDigit];
                                    }
                                } else if (tensDigit === 1) {
                                    result += "mười";
                                    if (onesDigit > 0) {
                                        if (onesDigit === 5) result += " lăm";
                                        else result += " " + ones[onesDigit];
                                    }
                                } else if (onesDigit > 0) {
                                    if (hundreds > 0) result += "lẻ ";
                                    result += ones[onesDigit];
                                }

                                return result;
                            }

                            let groups = [];
                            while (num > 0) {
                                groups.push(num % 1000);
                                num = Math.floor(num / 1000);
                            }

                            let result = "";
                            for (let i = groups.length - 1; i >= 0; i--) {
                                if (groups[i] > 0) {
                                    if (result !== "") result += " ";
                                    result += convertGroup(groups[i]);
                                    if (i > 0) result += " " + scales[i];
                                }
                            }

                            return result.charAt(0).toUpperCase() + result.slice(1) + " đồng";
                        }

                        // Convert amount to words on page load
                        document.addEventListener('DOMContentLoaded', function () {
                            var withdrawalAmount = <fmt:formatNumber value="${withdrawal.amount}" pattern="#" />;
                            var amountInWords = numberToVietnameseWords(withdrawalAmount);
                            document.getElementById('amountInWords').innerHTML = '<strong>' + amountInWords + '</strong>';
                        });

                        function approveWithdrawal() {
                            if (confirm('Bạn có chắc chắn muốn duyệt yêu cầu rút tiền này?\n\n' +
                                'Số tiền: ${withdrawal.amount} VNĐ\n' +
                                'Người dùng: ${withdrawal.user.fullName}\n\n' +
                                'Tiền sẽ được chuyển cho người dùng theo thông tin ngân hàng đã cung cấp.')) {
                                document.getElementById('approveForm').submit();
                            }
                        }

                        function showRejectModal() {
                            document.getElementById('rejectReason').value = '';
                            const modal = new bootstrap.Modal(document.getElementById('rejectModal'));
                            modal.show();
                        }

                        // Toggle sidebar function
                        function toggleSidebar() {
                            var sidebar = document.getElementById('sidebar');
                            var content = document.getElementById('content');
                            var overlay = document.getElementById('sidebarOverlay');

                            if (sidebar && content) {
                                sidebar.classList.toggle('active');
                                content.classList.toggle('shifted');

                                if (overlay) {
                                    overlay.classList.toggle('active');
                                }
                            }
                        }
                    </script>

                </body>

                </html>