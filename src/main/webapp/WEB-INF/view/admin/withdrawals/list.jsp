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
                    <title>Quản lý yêu cầu rút tiền - Admin - MMO Market System</title>
                    <jsp:include page="../../common/head.jsp" />

                    <style>
                        .status-badge {
                            padding: 0.375rem 0.75rem;
                            border-radius: 0.25rem;
                            font-size: 0.875rem;
                            font-weight: 500;
                        }

                        .status-pending {
                            background-color: #fff3cd;
                            color: #856404;
                        }

                        .status-success {
                            background-color: #d1e7dd;
                            color: #0f5132;
                        }

                        .status-failed {
                            background-color: #f8d7da;
                            color: #842029;
                        }

                        .status-cancelled {
                            background-color: #e2e3e5;
                            color: #41464b;
                        }

                        .status-rejected {
                            background-color: #f8d7da;
                            color: #842029;
                        }

                        .filter-section {
                            background-color: #f8f9fa;
                            padding: 1.5rem;
                            border-radius: 0.5rem;
                            margin-bottom: 1.5rem;
                        }

                        .withdrawal-card {
                            transition: transform 0.2s;
                        }

                        .withdrawal-card:hover {
                            transform: translateY(-2px);
                            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
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
                                    <i class="bi bi-cash-stack me-2"></i>Quản lý yêu cầu rút tiền
                                </h4>
                            </div>

                            <!-- Filter Section -->
                            <div class="filter-section">
                                <form method="get" action="/admin/withdrawals" class="row g-3" id="filterForm">
                                    <div class="col-md-3">
                                        <label for="keyword" class="form-label">Tìm Payment Ref:</label>
                                        <input type="text" class="form-control" id="keyword" name="keyword"
                                            value="${param.keyword}" placeholder="Nhập payment reference...">
                                    </div>
                                    <div class="col-md-2">
                                        <label for="statusFilter" class="form-label">Trạng thái:</label>
                                        <select class="form-select" id="statusFilter" name="status">
                                            <option value="">Tất cả</option>
                                            <option value="PENDING" ${selectedStatus=='PENDING' ? 'selected' : '' }>Chờ
                                                duyệt</option>
                                            <option value="SUCCESS" ${selectedStatus=='SUCCESS' ? 'selected' : '' }>Đã
                                                duyệt</option>
                                            <option value="REJECTED" ${selectedStatus=='REJECTED' ? 'selected' : '' }>
                                                Từ chối</option>
                                            <option value="CANCELLED" ${selectedStatus=='CANCELLED' ? 'selected' : '' }>
                                                Đã hủy</option>
                                        </select>
                                    </div>
                                    <div class="col-md-2">
                                        <label for="fromDate" class="form-label">Từ ngày:</label>
                                        <input type="date" class="form-control" id="fromDate" name="fromDate"
                                            value="${param.fromDate}">
                                    </div>
                                    <div class="col-md-2">
                                        <label for="toDate" class="form-label">Đến ngày:</label>
                                        <input type="date" class="form-control" id="toDate" name="toDate"
                                            value="${param.toDate}">
                                    </div>
                                    <div class="col-md-3 d-flex align-items-end">
                                        <div class="btn-group w-100">
                                            <button type="submit" class="btn btn-primary">
                                                <i class="bi bi-search me-1"></i>Tìm kiếm
                                            </button>
                                            <button type="button" class="btn btn-outline-secondary"
                                                onclick="clearFilters()">
                                                <i class="bi bi-arrow-clockwise me-1"></i>Xóa
                                            </button>
                                        </div>
                                    </div>
                            </div>
                        </div>
                        </form>
                    </div>

                    <!-- Withdrawals Table -->
                    <div class="card">
                        <div class="card-header bg-white">
                            <h5 class="mb-0">Danh sách yêu cầu rút tiền</h5>
                        </div>
                        <div class="card-body">
                            <c:if test="${empty withdrawals.content}">
                                <div class="text-center py-5">
                                    <i class="bi bi-inbox" style="font-size: 3rem; color: #ccc;"></i>
                                    <p class="text-muted mt-3">Không có yêu cầu rút tiền nào</p>
                                </div>
                            </c:if>

                            <c:if test="${not empty withdrawals.content}">
                                <div class="table-responsive">
                                    <table class="table table-hover">
                                        <thead>
                                            <tr>
                                                <th>ID</th>
                                                <th>Payment Ref</th>
                                                <th>Số tiền</th>
                                                <th>Ngân hàng</th>
                                                <th>Ngày tạo</th>
                                                <th>Trạng thái</th>
                                                <th>Thao tác</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach items="${withdrawals.content}" var="withdrawal">
                                                <tr>
                                                    <td>#${withdrawal.id}</td>
                                                    <td>
                                                        <code class="text-primary">${withdrawal.paymentRef}</code>
                                                    </td>
                                                    <td>
                                                        <strong>
                                                            <fmt:formatNumber value="${withdrawal.amount}"
                                                                type="currency" currencySymbol="" /> ₫
                                                        </strong>
                                                    </td>
                                                    <td>
                                                        <%-- Parse bank info from note field --%>
                                                            <c:set var="bankInfo"
                                                                value="${fn:split(withdrawal.note, '-')}" />
                                                            <c:choose>
                                                                <c:when test="${fn:length(bankInfo) >= 4}">
                                                                    <%-- Trim whitespace from each part --%>
                                                                        <c:set var="bankName"
                                                                            value="${fn:trim(bankInfo[1])}" />
                                                                        <c:set var="accountNumber"
                                                                            value="${fn:trim(bankInfo[2])}" />
                                                                        <c:set var="accountName"
                                                                            value="${fn:trim(bankInfo[3])}" />
                                                                        <div>
                                                                            <strong>${bankName}</strong><br />
                                                                            <small>${accountNumber}</small><br />
                                                                            <small
                                                                                class="text-muted">${accountName}</small>
                                                                        </div>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <%-- Display raw note if format is incorrect --%>
                                                                        <small
                                                                            class="text-muted">${withdrawal.note}</small>
                                                                </c:otherwise>
                                                            </c:choose>
                                                    </td>
                                                    <td>
                                                        ${withdrawal.createdAt}
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${withdrawal.paymentStatus == 'PENDING'}">
                                                                <span class="status-badge status-pending">
                                                                    <i class="bi bi-clock-history me-1"></i>Chờ
                                                                    duyệt
                                                                </span>
                                                            </c:when>
                                                            <c:when test="${withdrawal.paymentStatus == 'SUCCESS'}">
                                                                <span class="status-badge status-success">
                                                                    <i class="bi bi-check-circle me-1"></i>Đã
                                                                    duyệt
                                                                </span>
                                                            </c:when>
                                                            <c:when test="${withdrawal.paymentStatus == 'REJECTED'}">
                                                                <span class="status-badge status-rejected">
                                                                    <i class="bi bi-x-circle me-1"></i>Từ chối
                                                                </span>
                                                            </c:when>
                                                            <c:when test="${withdrawal.paymentStatus == 'CANCELLED'}">
                                                                <span class="status-badge status-cancelled">
                                                                    <i class="bi bi-slash-circle me-1"></i>Đã
                                                                    hủy
                                                                </span>
                                                            </c:when>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <a href="/admin/withdrawals/${withdrawal.id}"
                                                            class="btn btn-sm btn-outline-primary">
                                                            <i class="bi bi-gear"></i> Xử lý
                                                        </a>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </div>

                                <!-- Pagination -->
                                <c:if test="${withdrawals.totalPages > 1}">
                                    <div class="pagination-container mt-4">
                                        <nav aria-label="Phân trang">
                                            <ul class="pagination mb-0 justify-content-center">
                                                <!-- First Page -->
                                                <li class="page-item ${currentPage == 0 ? 'disabled' : ''}">
                                                    <a class="page-link"
                                                        href="?page=0&status=${selectedStatus}&fromDate=${param.fromDate}&toDate=${param.toDate}&keyword=${param.keyword}"
                                                        aria-label="First">
                                                        <span aria-hidden="true">&laquo;&laquo;</span>
                                                    </a>
                                                </li>
                                                <!-- Previous Page -->
                                                <li class="page-item ${currentPage == 0 ? 'disabled' : ''}">
                                                    <a class="page-link"
                                                        href="?page=${currentPage - 1}&status=${selectedStatus}&fromDate=${param.fromDate}&toDate=${param.toDate}&keyword=${param.keyword}"
                                                        aria-label="Previous">
                                                        <span aria-hidden="true">&laquo;</span>
                                                    </a>
                                                </li>

                                                <!-- Page Numbers -->
                                                <c:forEach begin="${currentPage > 2 ? currentPage - 2 : 0}"
                                                    end="${currentPage + 2 < totalPages - 1 ? currentPage + 2 : totalPages - 1}"
                                                    var="i">
                                                    <li class="page-item ${currentPage == i ? 'active' : ''}">
                                                        <a class="page-link"
                                                            href="?page=${i}&status=${selectedStatus}&fromDate=${param.fromDate}&toDate=${param.toDate}&keyword=${param.keyword}">${i
                                                            +
                                                            1}</a>
                                                    </li>
                                                </c:forEach>

                                                <!-- Show dots if there are more pages -->
                                                <c:if test="${currentPage + 2 < totalPages - 1}">
                                                    <li class="page-item disabled">
                                                        <span class="page-link">...</span>
                                                    </li>
                                                </c:if>

                                                <!-- Last page number if not in range -->
                                                <c:if test="${currentPage + 2 < totalPages - 1}">
                                                    <li class="page-item">
                                                        <a class="page-link"
                                                            href="?page=${totalPages - 1}&status=${selectedStatus}&fromDate=${param.fromDate}&toDate=${param.toDate}&keyword=${param.keyword}">${totalPages}</a>
                                                    </li>
                                                </c:if>

                                                <!-- Next Page -->
                                                <li
                                                    class="page-item ${currentPage == totalPages - 1 ? 'disabled' : ''}">
                                                    <a class="page-link"
                                                        href="?page=${currentPage + 1}&status=${selectedStatus}&fromDate=${param.fromDate}&toDate=${param.toDate}&keyword=${param.keyword}"
                                                        aria-label="Next">
                                                        <span aria-hidden="true">&raquo;</span>
                                                    </a>
                                                </li>
                                                <!-- Last Page -->
                                                <li
                                                    class="page-item ${currentPage == totalPages - 1 ? 'disabled' : ''}">
                                                    <a class="page-link"
                                                        href="?page=${totalPages - 1}&status=${selectedStatus}&fromDate=${param.fromDate}&toDate=${param.toDate}&keyword=${param.keyword}"
                                                        aria-label="Last">
                                                        <span aria-hidden="true">&raquo;&raquo;</span>
                                                    </a>
                                                </li>
                                            </ul>
                                        </nav>
                                    </div>
                                </c:if>
                            </c:if>
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
                                <form id="rejectForm" method="post">
                                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                                    <div class="modal-body">
                                        <div class="mb-3">
                                            <label for="rejectReason" class="form-label">Lý do từ chối <span
                                                    class="text-danger">*</span></label>
                                            <textarea class="form-control" id="rejectReason" name="reason" rows="3"
                                                placeholder="Nhập lý do từ chối..." required></textarea>
                                        </div>
                                    </div>
                                    <div class="modal-footer">
                                        <button type="button" class="btn btn-secondary"
                                            data-bs-dismiss="modal">Hủy</button>
                                        <button type="submit" class="btn btn-danger">
                                            <i class="bi bi-x-lg me-2"></i>Từ chối và hoàn tiền
                                        </button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>

                    <!-- Approve Form (hidden) -->
                    <form id="approveForm" method="post" style="display: none;">
                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                    </form>

                    <!-- iziToast CDN -->
                    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/izitoast@1.4.0/dist/css/iziToast.min.css">
                    <script src="https://cdn.jsdelivr.net/npm/izitoast@1.4.0/dist/js/iziToast.min.js"></script>

                    <script>
                        // Show success message if exists
                        var successMessage = '<c:out value="${success}" escapeXml="true"/>';
                        if (successMessage && successMessage.trim() !== '') {
                            iziToast.success({
                                title: 'Thành công',
                                message: successMessage,
                                position: 'topRight'
                            });
                        }

                        // Show warning message if exists
                        var warningMessage = '<c:out value="${warning}" escapeXml="true"/>';
                        if (warningMessage && warningMessage.trim() !== '') {
                            iziToast.warning({
                                title: 'Cảnh báo',
                                message: warningMessage,
                                position: 'topRight'
                            });
                        }

                        // Show error message if exists
                        var errorMessage = '<c:out value="${error}" escapeXml="true"/>';
                        if (errorMessage && errorMessage.trim() !== '') {
                            iziToast.error({
                                title: 'Lỗi',
                                message: errorMessage,
                                position: 'topRight'
                            });
                        }

                        function approveWithdrawal(id) {
                            if (confirm('Bạn có chắc chắn muốn duyệt yêu cầu rút tiền này?\n\nTiền sẽ được chuyển cho người dùng.')) {
                                const form = document.getElementById('approveForm');
                                form.action = '/admin/withdrawals/' + id + '/approve';
                                form.submit();
                            }
                        }

                        function showRejectModal(id) {
                            const form = document.getElementById('rejectForm');
                            form.action = '/admin/withdrawals/' + id + '/reject';
                            document.getElementById('rejectReason').value = '';

                            const modal = new bootstrap.Modal(document.getElementById('rejectModal'));
                            modal.show();
                        }

                        // Clear all filters
                        function clearFilters() {
                            document.getElementById('keyword').value = '';
                            document.getElementById('statusFilter').value = '';
                            document.getElementById('fromDate').value = '';
                            document.getElementById('toDate').value = '';
                            document.getElementById('filterForm').submit();
                        }

                        // Date validation
                        document.addEventListener('DOMContentLoaded', function () {
                            const fromDate = document.getElementById('fromDate');
                            const toDate = document.getElementById('toDate');

                            fromDate.addEventListener('change', function () {
                                if (toDate.value && fromDate.value > toDate.value) {
                                    iziToast.warning({
                                        title: 'Cảnh báo',
                                        message: 'Ngày bắt đầu không thể lớn hơn ngày kết thúc',
                                        position: 'topRight'
                                    });
                                    fromDate.value = '';
                                }
                            });

                            toDate.addEventListener('change', function () {
                                if (fromDate.value && toDate.value < fromDate.value) {
                                    iziToast.warning({
                                        title: 'Cảnh báo',
                                        message: 'Ngày kết thúc không thể nhỏ hơn ngày bắt đầu',
                                        position: 'topRight'
                                    });
                                    toDate.value = '';
                                }
                            });
                        });

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