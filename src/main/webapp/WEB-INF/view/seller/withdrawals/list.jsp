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
                    <title>
                        <c:if test="${not empty pageTitle}">${pageTitle} - </c:if>Quản lý rút tiền - MMO Market System
                    </title>
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
                        <h4>
                            <i class="bi bi-cash-stack me-2"></i>Quản lý yêu cầu rút tiền
                        </h4>
                    </div>

                    <!-- Balance Card -->
                    <div class="balance-card">
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <p class="mb-1">Số dư khả dụng</p>
                                <div class="balance-amount">
                                    <fmt:formatNumber value="${currentUser.balance}" type="currency"
                                        currencySymbol="" /> ₫
                                </div>
                        </div>
                        <c:choose>
                            <c:when test="${hasPendingWithdrawal}">
                                <button class="btn btn-light btn-lg" disabled>
                                    <i class="bi bi-clock-history me-2"></i>Đang chờ duyệt
                                </button>
                            </c:when>
                            <c:otherwise>
                                <a href="/seller/withdrawals/create" class="btn btn-light btn-lg">
                                    <i class="bi bi-plus-circle me-2"></i>Tạo yêu cầu rút tiền
                                </a>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <!-- Warning if has pending -->
                <c:if test="${hasPendingWithdrawal}">
                    <div class="alert alert-warning mt-3">
                        <i class="bi bi-exclamation-triangle me-2"></i>
                        <strong>Lưu ý:</strong> Bạn đã có yêu cầu rút tiền đang chờ admin duyệt. 
                        Bạn không thể tạo yêu cầu mới cho đến khi yêu cầu hiện tại được xử lý.
                    </div>
                </c:if>

                <!-- Withdrawals Table -->
                <div class="card">
                    <div class="card-header bg-white">
                        <h5 class="mb-0">Lịch sử yêu cầu rút tiền</h5>
                    </div>
                    <div class="card-body">
                        <c:if test="${empty withdrawals.content}">
                            <div class="text-center py-5">
                                <i class="bi bi-inbox" style="font-size: 3rem; color: #ccc;"></i>
                                <p class="text-muted mt-3">Bạn chưa có yêu cầu rút tiền nào</p>
                                <a href="/seller/withdrawals/create" class="btn btn-primary">
                                    Tạo yêu cầu đầu tiên
                                </a>
                            </div>
                        </c:if>

                        <c:if test="${not empty withdrawals.content}">
                            <div class="table-responsive">
                                <table class="table table-hover">
                                    <thead>
                                        <tr>
                                            <th>Mã GD</th>
                                            <th>Ngày tạo</th>
                                            <th>Số tiền</th>
                                            <th>Ngân hàng</th>
                                            <th>Trạng thái</th>
                                                        <th>Thao tác</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <c:forEach items="${withdrawals.content}" var="withdrawal">
                                                        <tr>
                                                            <td><strong>#${withdrawal.id}</strong></td>
                                                            <td>
                                                                <c:set var="createdAt" value="${withdrawal.createdAt.toString().replace('T', ' ').substring(0, 16)}" />
                                                                ${createdAt}
                                                            </td>
                                                            <td>
                                                                <strong class="text-danger">
                                                                    -<fmt:formatNumber value="${withdrawal.amount}"
                                                                        type="currency" currencySymbol="" /> ₫
                                                                </strong>
                                                            </td>
                                                            <td>
                                                                <c:set var="bankInfo"
                                                                    value="${withdrawal.note.split(' - ')}" />
                                                                <c:if test="${fn:length(bankInfo) >= 2}">
                                                                    ${bankInfo[1]}<br>
                                                                    <small class="text-muted">${bankInfo[2]}</small>
                                                                </c:if>
                                                            </td>
                                                            <td>
                                                                <span
                                                                    class="status-badge status-${withdrawal.paymentStatus}">
                                                                    <c:choose>
                                                                        <c:when
                                                                            test="${withdrawal.paymentStatus == 'PENDING'}">
                                                                            <i class="bi bi-clock-history me-1"></i>Chờ
                                                                            duyệt
                                                                        </c:when>
                                                                        <c:when
                                                                            test="${withdrawal.paymentStatus == 'SUCCESS'}">
                                                                            <i class="bi bi-check-circle me-1"></i>Đã
                                                                            duyệt
                                                                        </c:when>
                                                                        <c:when
                                                                            test="${withdrawal.paymentStatus == 'REJECTED'}">
                                                                            <i class="bi bi-x-circle me-1"></i>Từ chối
                                                                        </c:when>
                                                                        <c:when
                                                                            test="${withdrawal.paymentStatus == 'CANCELLED'}">
                                                                            <i class="bi bi-slash-circle me-1"></i>Đã hủy
                                                                        </c:when>
                                                                    </c:choose>
                                                                </span>
                                                            </td>
                                                            <td>
                                                                <a href="/seller/withdrawals/${withdrawal.id}"
                                                                    class="btn btn-sm btn-outline-primary">
                                                                    <i class="bi bi-eye"></i> Xem
                                                                </a>
                                                                <c:if
                                                                    test="${withdrawal.paymentStatus == 'PENDING'}">
                                                                    <a href="/seller/withdrawals/${withdrawal.id}/edit"
                                                                        class="btn btn-sm btn-outline-secondary">
                                                                        <i class="bi bi-pencil"></i> Sửa
                                                                    </a>
                                                                    <button type="button"
                                                                        class="btn btn-sm btn-outline-danger"
                                                                        onclick="cancelWithdrawal('${withdrawal.id}')">
                                                                        <i class="bi bi-x-lg"></i> Hủy
                                                                    </button>
                                                                </c:if>
                                                            </td>
                                                        </tr>
                                                    </c:forEach>
                                                </tbody>
                                            </table>
                                        </div>

                                        <!-- Enhanced Pagination -->
                                        <c:if test="${withdrawals.totalPages > 1}">
                                            <nav aria-label="Phân trang" class="mt-4">
                                                <ul class="pagination justify-content-center">
                                                    <!-- First Page -->
                                                    <li class="page-item ${currentPage == 0 ? 'disabled' : ''}">
                                                        <a class="page-link" 
                                                           href="${currentPage == 0 ? '#' : '/seller/withdrawals?page=0&size=' += withdrawals.size}"
                                                           aria-label="Trang đầu">
                                                            <i class="bi bi-chevron-double-left"></i>
                                                        </a>
                                                    </li>

                                                    <!-- Previous Page -->
                                                    <li class="page-item ${currentPage == 0 ? 'disabled' : ''}">
                                                        <a class="page-link"
                                                           href="${currentPage == 0 ? '#' : '/seller/withdrawals?page=' += (currentPage - 1) += '&size=' += withdrawals.size}"
                                                           aria-label="Trang trước">
                                                            <i class="bi bi-chevron-left"></i>
                                                        </a>
                                                    </li>

                                                    <!-- Page Numbers -->
                                                    <c:choose>
                                                        <c:when test="${withdrawals.totalPages <= 7}">
                                                            <!-- Show all pages if total <= 7 -->
                                                            <c:forEach begin="0" end="${withdrawals.totalPages - 1}" var="pageNum">
                                                                <li class="page-item ${pageNum == currentPage ? 'active' : ''}">
                                                                    <a class="page-link" 
                                                                       href="/seller/withdrawals?page=${pageNum}&size=${withdrawals.size}">
                                                                        ${pageNum + 1}
                                                                    </a>
                                                                </li>
                                                            </c:forEach>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <!-- Show pages with ellipsis -->
                                                            <c:choose>
                                                                <c:when test="${currentPage < 3}">
                                                                    <!-- Near start: show 1-5 ... last -->
                                                                    <c:forEach begin="0" end="4" var="pageNum">
                                                                        <li class="page-item ${pageNum == currentPage ? 'active' : ''}">
                                                                            <a class="page-link" 
                                                                               href="/seller/withdrawals?page=${pageNum}&size=${withdrawals.size}">
                                                                                ${pageNum + 1}
                                                                            </a>
                                                                        </li>
                                                                    </c:forEach>
                                                                    <li class="page-item disabled">
                                                                        <span class="page-link">...</span>
                                                                    </li>
                                                                    <li class="page-item">
                                                                        <a class="page-link" 
                                                                           href="/seller/withdrawals?page=${withdrawals.totalPages - 1}&size=${withdrawals.size}">
                                                                            ${withdrawals.totalPages}
                                                                        </a>
                                                                    </li>
                                                                </c:when>
                                                                <c:when test="${currentPage > withdrawals.totalPages - 4}">
                                                                    <!-- Near end: show first ... last 5 -->
                                                                    <li class="page-item">
                                                                        <a class="page-link" 
                                                                           href="/seller/withdrawals?page=0&size=${withdrawals.size}">
                                                                            1
                                                                        </a>
                                                                    </li>
                                                                    <li class="page-item disabled">
                                                                        <span class="page-link">...</span>
                                                                    </li>
                                                                    <c:forEach begin="${withdrawals.totalPages - 5}" end="${withdrawals.totalPages - 1}" var="pageNum">
                                                                        <li class="page-item ${pageNum == currentPage ? 'active' : ''}">
                                                                            <a class="page-link" 
                                                                               href="/seller/withdrawals?page=${pageNum}&size=${withdrawals.size}">
                                                                                ${pageNum + 1}
                                                                            </a>
                                                                        </li>
                                                                    </c:forEach>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <!-- Middle: show first ... current-1, current, current+1 ... last -->
                                                                    <li class="page-item">
                                                                        <a class="page-link" 
                                                                           href="/seller/withdrawals?page=0&size=${withdrawals.size}">
                                                                            1
                                                                        </a>
                                                                    </li>
                                                                    <li class="page-item disabled">
                                                                        <span class="page-link">...</span>
                                                                    </li>
                                                                    <c:forEach begin="${currentPage - 1}" end="${currentPage + 1}" var="pageNum">
                                                                        <li class="page-item ${pageNum == currentPage ? 'active' : ''}">
                                                                            <a class="page-link" 
                                                                               href="/seller/withdrawals?page=${pageNum}&size=${withdrawals.size}">
                                                                                ${pageNum + 1}
                                                                            </a>
                                                                        </li>
                                                                    </c:forEach>
                                                                    <li class="page-item disabled">
                                                                        <span class="page-link">...</span>
                                                                    </li>
                                                                    <li class="page-item">
                                                                        <a class="page-link" 
                                                                           href="/seller/withdrawals?page=${withdrawals.totalPages - 1}&size=${withdrawals.size}">
                                                                            ${withdrawals.totalPages}
                                                                        </a>
                                                                    </li>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </c:otherwise>
                                                    </c:choose>

                                                    <!-- Next Page -->
                                                    <li class="page-item ${currentPage >= withdrawals.totalPages - 1 ? 'disabled' : ''}">
                                                        <a class="page-link"
                                                           href="${currentPage >= withdrawals.totalPages - 1 ? '#' : '/seller/withdrawals?page=' += (currentPage + 1) += '&size=' += withdrawals.size}"
                                                           aria-label="Trang sau">
                                                            <i class="bi bi-chevron-right"></i>
                                                        </a>
                                                    </li>

                                                    <!-- Last Page -->
                                                    <li class="page-item ${currentPage >= withdrawals.totalPages - 1 ? 'disabled' : ''}">
                                                        <a class="page-link"
                                                           href="${currentPage >= withdrawals.totalPages - 1 ? '#' : '/seller/withdrawals?page=' += (withdrawals.totalPages - 1) += '&size=' += withdrawals.size}"
                                                           aria-label="Trang cuối">
                                                            <i class="bi bi-chevron-double-right"></i>
                                                        </a>
                                                    </li>
                                                </ul>

                                               
                                        </nav>
                                    </c:if>
                                </c:if>
                            </div>
                        </div>
                    </div>

                    <!-- Cancel Confirmation Form (Hidden) -->
                    <form id="cancelForm" method="POST" style="display: none;">
                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                    </form>
                </div>

                <!-- Include Footer -->
                <jsp:include page="../../common/footer.jsp" />

                <script>
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

                    // Show flash messages
                    var successMessage = '<c:out value="${success}" escapeXml="true" />';
                    var errorMessage = '<c:out value="${error}" escapeXml="true" />';
                    
                    if (successMessage && successMessage.trim() !== '') {
                        iziToast.success({
                            title: 'Thành công',
                            message: successMessage,
                            position: 'topRight'
                        });
                    }
                    
                    if (errorMessage && errorMessage.trim() !== '') {
                        iziToast.error({
                            title: 'Lỗi',
                            message: errorMessage,
                            position: 'topRight'
                        });
                    }

                    function cancelWithdrawal(id) {
                        if (confirm('Bạn có chắc chắn muốn hủy yêu cầu rút tiền này?')) {
                            const form = document.getElementById('cancelForm');
                            form.action = '/seller/withdrawals/' + id + '/cancel';
                            form.submit();
                        }
                    }

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
                            menuToggle && !menuToggle.contains(event.target)) {
                            toggleSidebar();
                        }
                    });

                </script>
                    </div> <!-- End container-fluid -->
                </div> <!-- End content -->
            </body>

            </html>
