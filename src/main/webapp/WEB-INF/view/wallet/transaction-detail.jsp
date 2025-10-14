<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
            <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

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

                        <div class="container mt-4">
                            <!-- 🔙 Back button -->
                            <div class="row mb-3">
                                <div class="col-12">
                                    <a href="/wallet/transactions" class="btn btn-outline-secondary">
                                        <i class="fas fa-arrow-left"></i> Back to List
                                    </a>
                                </div>
                            </div>

                            <!--  Transaction Header -->
                            <div class="transaction-header text-center">
                                <div class="row align-items-center">
                                    <div class="col-md-2">
                                        <c:choose>
                                            <c:when test='${transaction.type eq "DEPOSIT"}'>
                                                <i class="fas fa-plus-circle fa-4x"></i>
                                            </c:when>
                                            <c:when test='${transaction.type eq "WITHDRAWAL"}'>
                                                <i class="fas fa-minus-circle fa-4x"></i>
                                            </c:when>
                                            <c:when test='${transaction.type eq "PAYMENT"}'>
                                                <i class="fas fa-shopping-cart fa-4x"></i>
                                            </c:when>
                                            <c:when test='${transaction.type eq "REFUND"}'>
                                                <i class="fas fa-undo fa-4x"></i>
                                            </c:when>
                                            <c:otherwise>
                                                <i class="fas fa-exchange-alt fa-4x"></i>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                    <div class="col-md-8">
                                        <h2 class="mb-2">
                                            <c:choose>
                                                <c:when test='${transaction.type eq "DEPOSIT"}'>Deposit Transaction
                                                </c:when>
                                                <c:when test='${transaction.type eq "WITHDRAWAL"}'>Withdrawal
                                                    Transaction
                                                </c:when>
                                                <c:when test='${transaction.type eq "PAYMENT"}'>Payment Transaction
                                                </c:when>
                                                <c:when test='${transaction.type eq "REFUND"}'>Refund Transaction
                                                </c:when>
                                                <c:otherwise>Transfer Transaction</c:otherwise>
                                            </c:choose>
                                        </h2>
                                        <p class="mb-0 opacity-75">
                                            <i class="fas fa-clock"></i>
                                            ${fn:replace(fn:substring(transaction.createdAt, 0, 19), 'T', ' ')}
                                        </p>
                                    </div>
                                    <div class="col-md-2">
                                        <span class="${
                                        (transaction.paymentStatus.name() eq 'SUCCESS') ? 'status-success' : 
                                        (transaction.paymentStatus.name() eq 'PENDING') ? 'status-pending' : 'status-failed'
                                    }">

                                            <c:choose>
                                                <c:when test='${transaction.paymentStatus.name() eq "SUCCESS"}'>
                                                    <i class="fas fa-check-circle"></i> Success
                                                </c:when>
                                                <c:when test='${transaction.paymentStatus.name() eq "PENDING"}'>
                                                    <i class="fas fa-clock"></i> Pending
                                                </c:when>
                                                <c:when test='${transaction.paymentStatus.name() eq "FAILED"}'>
                                                    <i class="fas fa-times-circle"></i> Failed
                                                </c:when>
                                                <c:when test='${transaction.paymentStatus.name() eq "CANCELLED"}'>
                                                    <i class="fas fa-ban"></i> Cancelled
                                                </c:when>
                                                <c:otherwise>${transaction.paymentStatus.name()}</c:otherwise>
                                            </c:choose>
                                        </span>
                                    </div>
                                </div>
                            </div>

                            <div class="row">
                                <!--  Amount Card -->
                                <div class="col-md-6 mb-4">
                                    <div class="card detail-card">
                                        <div class="card-body text-center">
                                            <h5 class="card-title text-muted mb-3">
                                                <i class="fas fa-money-bill-wave"></i> Amount
                                            </h5>
                                            <c:set var="isPositive"
                                                value="${transaction.type.name() eq 'DEPOSIT' or transaction.type.name() eq 'REFUND'}" />

                                            <div
                                                class="amount-display ${isPositive ? 'amount-positive' : 'amount-negative'}">
                                                ${isPositive ? '+' : '-'}

                                                <fmt:formatNumber value="${transaction.amount}" type="number"
                                                    pattern="#,###" />
                                                <small class="fs-4">VNĐ</small>
                                            </div>

                                        </div>
                                    </div>
                                </div>

                                <!--  Transaction Info -->
                                <div class="col-md-6 mb-4">
                                    <div class="card detail-card">
                                        <div class="card-body">
                                            <h5 class="card-title text-muted mb-3">
                                                <i class="fas fa-info-circle"></i> Transaction Information
                                            </h5>

                                            <div class="info-row">
                                                <div class="row">
                                                    <div class="col-5 info-label">Transaction ID:</div>
                                                    <div class="col-7">
                                                        <c:choose>
                                                            <c:when test="${transaction.paymentRef != null}">
                                                                <code>${transaction.paymentRef}</code>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="text-muted">Not available</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                </div>
                                            </div>

                                            <div class="info-row">
                                                <div class="row">
                                                    <div class="col-5 info-label">Transaction Type:</div>
                                                    <div class="col-7">
                                                        <span class="badge bg-primary">
                                                            <c:choose>
                                                                <c:when test='${transaction.type == "DEPOSIT"}'>Deposit
                                                                </c:when>
                                                                <c:when test='${transaction.type == "WITHDRAWAL"}'>
                                                                    Withdrawal</c:when>
                                                                <c:when test='${transaction.type == "PAYMENT"}'>Payment
                                                                </c:when>
                                                                <c:when test='${transaction.type == "REFUND"}'>Refund
                                                                </c:when>
                                                                <c:otherwise><span class="text-muted">Unknown</span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </span>
                                                    </div>
                                                </div>
                                            </div>

                                            <div class="info-row">
                                                <div class="row">
                                                    <div class="col-5 info-label">Phương thức:</div>
                                                    <div class="col-7">
                                                        <c:choose>
                                                            <c:when test="${transaction.paymentMethod != null}">
                                                                <span
                                                                    class="badge bg-secondary">${transaction.paymentMethod}</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="text-muted">Không xác định</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                </div>
                                            </div>

                                            <div class="info-row">
                                                <div class="row">
                                                    <div class="col-5 info-label">Thời gian tạo:</div>
                                                    <div class="col-7">
                                                        ${fn:replace(fn:substring(transaction.createdAt, 0, 19), 'T', '
                                                        ')}
                                                    </div>
                                                </div>
                                            </div>

                                            <c:if
                                                test="${transaction.updatedAt != null && transaction.updatedAt != transaction.createdAt}">
                                                <div class="info-row">
                                                    <div class="row">
                                                        <div class="col-5 info-label">Cập nhật cuối:</div>
                                                        <div class="col-7">
                                                            ${fn:replace(fn:substring(transaction.updatedAt, 0, 19),
                                                            'T', '
                                                            ')}
                                                        </div>
                                                    </div>
                                                </div>
                                            </c:if>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Note Section -->
                            <c:if test="${transaction.note != null && !transaction.note.trim().isEmpty()}">
                                <div class="row">
                                    <div class="col-12">
                                        <div class="card detail-card">
                                            <div class="card-body">
                                                <h5 class="card-title text-muted mb-3">
                                                    <i class="fas fa-sticky-note"></i> Notes
                                                </h5>
                                                <p class="mb-0">${transaction.note}</p>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </c:if>

                            <!-- 🔗 Đơn hàng liên quan (nếu có) -->
                            <c:if test="${transaction.refOrder != null}">
                                <div class="row mt-4">
                                    <div class="col-12">
                                        <div class="card detail-card">
                                            <div class="card-body">
                                                <h5 class="card-title text-muted mb-3">
                                                    <i class="fas fa-shopping-bag"></i> Đơn hàng liên quan
                                                </h5>
                                                <div class="d-flex justify-content-between align-items-center">
                                                    <div>
                                                        <p class="mb-1"><strong>Mã đơn hàng:</strong>
                                                            #${transaction.refOrder.id}
                                                        </p>
                                                        <p class="mb-0 text-muted">
                                                            Ngày tạo: ${fn:substring(transaction.refOrder.createdAt, 0,
                                                            10)}
                                                        </p>
                                                    </div>
                                                    <a href="/orders/${transaction.refOrder.id}"
                                                        class="btn btn-outline-primary">
                                                        <i class="fas fa-eye"></i> Xem đơn hàng
                                                    </a>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </c:if>

                            <!-- Action Buttons -->
                            <div class="row mt-4">
                                <div class="col-12 text-center">
                                    <a href="/wallet/transactions" class="btn btn-secondary me-2">
                                        <i class="fas fa-list"></i> Transaction List
                                    </a>
                                    <a href="/wallet" class="btn btn-primary me-2">
                                        <i class="fas fa-wallet"></i> My Wallet
                                    </a>
                                    <c:if
                                        test='${transaction.paymentStatus.name() == "SUCCESS" && transaction.type.name() == "DEPOSIT"}'>
                                        <a href="/wallet/deposit" class="btn btn-success">
                                            <i class="fas fa-plus"></i> Add More Funds
                                        </a>
                                    </c:if>
                                </div>
                            </div>
                        </div>

                        <script
                            src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>





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
                    </script>
                </body>

                </html>