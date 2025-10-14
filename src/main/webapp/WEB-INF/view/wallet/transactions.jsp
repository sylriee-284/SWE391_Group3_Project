<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <%@ taglib prefix="fn" uri="jakarta.tags.functions" %>


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
                            <!--  Header và thống kê -->
                            <div class="row">
                                <div class="col-12">
                                    <div class="d-flex justify-content-between align-items-center mb-4">
                                        <div>
                                            <h2><i class="fas fa-history"></i> Transaction History</h2>
                                            <p class="text-muted">Manage and track your wallet transactions</p>
                                        </div>
                                        <div class="text-end">
                                            <a href="/wallet" class="btn btn-outline-primary">
                                                <i class="fas fa-wallet"></i> Back to Wallet
                                            </a>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Bộ lọc -->
                            <div class="filter-section">
                                <form method="get" action="/wallet/transactions">
                                    <div class="row g-3">
                                        <div class="col-md-4">
                                            <label for="type" class="form-label">Transaction Type</label>
                                            <select class="form-select" id="type" name="type">
                                                <option value="">All</option>
                                                <c:forEach var="transactionType" items="${transactionTypes}">
                                                    <option value="${transactionType}" ${selectedType==transactionType
                                                        ? 'selected' : '' }>
                                                        <c:choose>
                                                            <c:when test="${transactionType == 'DEPOSIT'}">Deposit
                                                            </c:when>
                                                            <c:when test="${transactionType == 'WITHDRAWAL'}">Withdrawal
                                                            </c:when>
                                                            <c:when test="${transactionType == 'PAYMENT'}">Payment
                                                            </c:when>
                                                            <c:when test="${transactionType == 'REFUND'}">Refund
                                                            </c:when>
                                                            <c:otherwise>${transactionType}</c:otherwise>
                                                        </c:choose>
                                                    </option>
                                                </c:forEach>
                                            </select>
                                        </div>
                                        <div class="col-md-4">
                                            <label for="status" class="form-label">Status</label>
                                            <select class="form-select" id="status" name="status">
                                                <option value="">All</option>
                                                <c:forEach var="paymentStatus" items="${paymentStatuses}">
                                                    <option value="${paymentStatus}" ${selectedStatus==paymentStatus
                                                        ? 'selected' : '' }>
                                                        <c:choose>
                                                            <c:when test="${paymentStatus == 'SUCCESS'}">Success
                                                            </c:when>
                                                            <c:when test="${paymentStatus == 'PENDING'}">Pending
                                                            </c:when>
                                                            <c:when test="${paymentStatus == 'FAILED'}">Failed</c:when>
                                                            <c:when test="${paymentStatus == 'CANCELLED'}">Cancelled
                                                            </c:when>
                                                            <c:otherwise>${paymentStatus}</c:otherwise>
                                                        </c:choose>
                                                    </option>
                                                </c:forEach>
                                            </select>
                                        </div>
                                        <div class="col-md-4 d-flex align-items-end">
                                            <button type="submit" class="btn btn-primary me-2">
                                                <i class="fas fa-search"></i> Lọc
                                            </button>
                                            <a href="/wallet/transactions" class="btn btn-outline-secondary">
                                                <i class="fas fa-refresh"></i> Đặt lại
                                            </a>
                                        </div>
                                    </div>
                                </form>
                            </div>

                            <!-- Thông tin tổng quan -->
                            <div class="row mb-4">
                                <div class="col-md-12">
                                    <div class="alert alert-info">
                                        <i class="fas fa-info-circle"></i>
                                        <strong>Total:</strong> ${totalTransactions} transactions
                                        | <strong>Page:</strong> ${currentPage + 1} / ${totalPages}
                                    </div>
                                </div>
                            </div>

                            <!-- Danh sách giao dịch -->
                            <c:choose>
                                <c:when test="${transactions.content.size() > 0}">
                                    <div class="row">
                                        <c:forEach var="transaction" items="${transactions.content}">
                                            <div class="col-12 mb-3">
                                                <div class="card transaction-card 
                                <c:choose>
                                            <c:when test=" ${transaction.type.name() eq 'DEPOSIT' }">
                                                    transaction-deposit
                                </c:when>
                                <c:when test="${transaction.type.name() eq 'WITHDRAWAL'}">transaction-withdraw</c:when>
                                <c:otherwise>transaction-payment</c:otherwise>
                            </c:choose>">

                            <div class="card-body">
                                <div class="row align-items-center">
                                    <!-- Icon & Type -->
                                    <div class="col-md-1 text-center">
                                        <c:choose>
                                            <c:when test='${transaction.type.name() eq "DEPOSIT"}'>
                                                <i class="fas fa-plus-circle text-success fa-2x"></i>
                                            </c:when>
                                            <c:when test='${transaction.type.name() eq "WITHDRAWAL"}'>
                                                <i class="fas fa-minus-circle text-danger fa-2x"></i>
                                            </c:when>
                                            <c:when test='${transaction.type.name() eq "PAYMENT"}'>
                                                <i class="fas fa-shopping-cart text-warning fa-2x"></i>
                                            </c:when>
                                            <c:when test='${transaction.type.name() eq "REFUND"}'>
                                                <i class="fas fa-undo text-info fa-2x"></i>
                                            </c:when>
                                            <c:otherwise>
                                                <i class="fas fa-exchange-alt text-primary fa-2x"></i>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>

                                    <!-- Thông tin giao dịch -->
                                    <div class="col-md-6">
                                        <h6 class="mb-1">
                                            ${transaction.type}

                                            <!-- Payment Method -->
                                            <c:if test="${transaction.paymentMethod != null}">
                                                <span
                                                    class="badge bg-secondary ms-2">${transaction.paymentMethod}</span>
                                            </c:if>
                                        </h6>

                                        <p class="text-muted mb-1">
                                            <i class="fas fa-clock"></i>
                                            ${fn:substring(transaction.createdAt, 0, 19)}
                                        </p>

                                        <c:if test="${transaction.note != null}">
                                            <p class="text-muted mb-0">
                                                <i class="fas fa-sticky-note"></i> ${transaction.note}
                                            </p>
                                        </c:if>

                                        <c:if test="${transaction.paymentRef != null}">
                                            <small class="text-muted">
                                                Payment Ref: ${transaction.paymentRef}
                                            </small>
                                        </c:if>
                                    </div>

                                    <!-- Số tiền -->
                                    <div class="col-md-3 text-center">
                                        <h5 class="mb-0 
                                                <c:choose>
                                                    <c:when test='${transaction.type.name() eq " DEPOSIT" ||
                                            transaction.type.name() eq "REFUND" }'>amount-positive</c:when>
                                            <c:otherwise>amount-negative</c:otherwise>
                                            </c:choose>">

                                            <c:choose>
                                                <c:when
                                                    test='${transaction.type.name() eq "DEPOSIT" || transaction.type.name() eq "REFUND"}'>
                                                    +</c:when>
                                                <c:otherwise>-</c:otherwise>
                                            </c:choose>

                                            <fmt:formatNumber value="${transaction.amount}" type="number"
                                                pattern="#,###" />
                                            VNĐ
                                        </h5>
                                    </div>

                                    <!-- Status & Action -->
                                    <div class="col-md-2 text-end">
                                        <span class="badge ${transaction.paymentStatus == 'SUCCESS' ? 'status-success' : 
                                                 transaction.paymentStatus == 'PENDING' ? 'status-pending' : 
                                                 'status-failed'} mb-2">
                                            ${transaction.paymentStatus}
                                        </span>
                                        <br>
                                        <a href="/wallet/transactions/${transaction.id}"
                                            class="btn btn-sm btn-outline-primary">
                                            <i class="fas fa-eye"></i> Details
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    </c:forEach>
                    </div>

                    <!--  Pagination -->
                    <c:if test="${totalPages > 1}">
                        <nav aria-label="Transaction pagination">
                            <ul class="pagination justify-content-center">
                                <!-- Previous -->
                                <li class="page-item ${currentPage == 0 ? 'disabled' : ''}">
                                    <a class="page-link"
                                        href="?page=${currentPage - 1}&type=${selectedType}&status=${selectedStatus}">
                                        <i class="fas fa-chevron-left"></i> Previous
                                    </a>
                                </li>

                                <!-- Page numbers -->
                                <c:forEach begin="0" end="${totalPages - 1}" var="pageNum">
                                    <c:if test="${pageNum >= currentPage - 2 && pageNum <= currentPage + 2}">
                                        <li class="page-item ${pageNum == currentPage ? 'active' : ''}">
                                            <a class="page-link"
                                                href="?page=${pageNum}&type=${selectedType}&status=${selectedStatus}">
                                                ${pageNum + 1}
                                            </a>
                                        </li>
                                    </c:if>
                                </c:forEach>

                                <!-- Next -->
                                <li class="page-item ${currentPage == totalPages - 1 ? 'disabled' : ''}">
                                    <a class="page-link"
                                        href="?page=${currentPage + 1}&type=${selectedType}&status=${selectedStatus}">
                                        Next <i class="fas fa-chevron-right"></i>
                                    </a>
                                </li>
                            </ul>
                        </nav>
                    </c:if>
                    </c:when>
                    <c:otherwise>
                        <!-- 📭 Empty state -->
                        <div class="text-center py-5">
                            <i class="fas fa-inbox fa-4x text-muted mb-3"></i>
                            <h4 class="text-muted">No transactions yet</h4>
                            <p class="text-muted">You haven't made any transactions or no matching transactions were
                                found for the current filters.</p>
                            <a href="/wallet/deposit" class="btn btn-primary">
                                <i class="fas fa-plus"></i> Deposit now
                            </a>
                        </div>
                    </c:otherwise>
                    </c:choose>
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
                    </script>
                </body>

                </html>