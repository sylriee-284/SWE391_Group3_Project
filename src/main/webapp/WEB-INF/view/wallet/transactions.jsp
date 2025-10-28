<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

                <!DOCTYPE html>
                <html lang="en">

                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>Transaction History - MMO Market</title>
                    <jsp:include page="../common/head.jsp" />
                </head>

                <body>
                    <!-- Include Navbar -->
                    <jsp:include page="../common/navbar.jsp" />

                    <!-- Include Sidebar -->
                    <jsp:include page="../common/sidebar.jsp" />

                    <!-- Sidebar Overlay for Mobile -->
                    <div class="sidebar-overlay" id="sidebarOverlay" onclick="toggleSidebar()" role="button"
                        tabindex="0" onKeyPress="if(event.key === 'Enter') toggleSidebar()"></div>

                    <!-- Main Content Area -->
                    <div class="content" id="content">
                        <div class="container-fluid">
                            <!--  Header và thống kê -->
                            <div class="row mb-4">
                                <div class="col-12">
                                    <div class="d-flex justify-content-between align-items-center">
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

                            <!-- Filter Section -->
                            <div class="filter-section">
                                <form method="get" action="/wallet/transactions" id="filterForm">
                                    <!-- Row 1: Basic Filters -->
                                    <div class="row filter-row align-items-end">
                                        <div class="col-md-3">
                                            <div class="filter-label">Transaction Type</div>
                                            <select class="form-select" id="type" name="type"
                                                onchange="this.form.submit()">
                                                <option value="">All</option>
                                                <c:forEach var="transactionType" items="${transactionTypes}">
                                                    <option value="${transactionType}" ${selectedType==transactionType
                                                        ? 'selected' : '' }>
                                                        ${transactionType}
                                                    </option>
                                                </c:forEach>
                                            </select>
                                        </div>

                                        <div class="col-md-3">
                                            <div class="filter-label">Status</div>
                                            <select class="form-select" id="status" name="status"
                                                onchange="this.form.submit()">
                                                <option value="">All</option>
                                                <c:forEach var="paymentStatus" items="${paymentStatuses}">
                                                    <option value="${paymentStatus}" ${selectedStatus==paymentStatus
                                                        ? 'selected' : '' }>
                                                        ${paymentStatus}
                                                    </option>
                                                </c:forEach>
                                            </select>
                                        </div>

                                        <div class="col-md-3">
                                            <a href="/wallet/transactions" class="btn btn-outline-secondary">
                                                <i class="fas fa-refresh"></i> Reset Filters
                                            </a>
                                        </div>
                                    </div>

                            </div>
                            </form>

                            <!-- Danh sách giao dịch -->
                            <div class="row mt-4">
                                <div class="col-12">
                                    <c:choose>
                                        <c:when test="${transactions.content.size() > 0}">
                                            <div class="table-responsive-xl">
                                                <table id="resizableTable"
                                                    class="table table-striped table-hover resizable-table align-middle">
                                                    <thead class="table-light text-nowrap">
                                                        <tr>
                                                            <th class="sortable" data-column="0" data-type="text">
                                                                Type
                                                                <div class="resizer"></div>
                                                            </th>
                                                            <th class="sortable" data-column="1" data-type="date">
                                                                Date
                                                                <div class="resizer"></div>
                                                            </th>
                                                            <th class="sortable" data-column="2" data-type="text">
                                                                Payment Method
                                                                <div class="resizer"></div>
                                                            </th>
                                                            <th class="sortable" data-column="3" data-type="text">
                                                                Reference ID
                                                                <div class="resizer"></div>
                                                            </th>
                                                            <th class="sortable" data-column="4" data-type="number">
                                                                Amount
                                                                <div class="resizer"></div>
                                                            </th>
                                                            <th class="sortable" data-column="5" data-type="text">
                                                                Status
                                                                <div class="resizer"></div>
                                                            </th>
                                                            <th>Actions <div class="resizer"></div>
                                                            </th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>
                                                        <c:forEach var="transaction" items="${transactions.content}">
                                                            <tr>
                                                                <td>
                                                                    <c:choose>
                                                                        <c:when
                                                                            test='${transaction.type.name() eq "DEPOSIT"}'>
                                                                            <i
                                                                                class="fas fa-plus-circle text-success"></i>
                                                                        </c:when>
                                                                        <c:when
                                                                            test='${transaction.type.name() eq "WITHDRAWAL"}'>
                                                                            <i
                                                                                class="fas fa-minus-circle text-danger"></i>
                                                                        </c:when>
                                                                        <c:when
                                                                            test='${transaction.type.name() eq "PAYMENT"}'>
                                                                            <i
                                                                                class="fas fa-shopping-cart text-warning"></i>
                                                                        </c:when>
                                                                        <c:when
                                                                            test='${transaction.type.name() eq "REFUND"}'>
                                                                            <i class="fas fa-undo text-info"></i>
                                                                        </c:when>
                                                                        <c:otherwise>
                                                                            <i
                                                                                class="fas fa-exchange-alt text-primary"></i>
                                                                        </c:otherwise>
                                                                    </c:choose>
                                                                    ${transaction.type}
                                                                </td>
                                                                <td>${fn:substring(transaction.createdAt, 0,
                                                                    19)}</td>
                                                                <td>${transaction.paymentMethod}</td>
                                                                <td>
                                                                    <c:choose>
                                                                        <c:when
                                                                            test='${transaction.type.name() eq "DEPOSIT"}'>
                                                                            ${transaction.paymentRef}
                                                                        </c:when>
                                                                        <c:when
                                                                            test='${transaction.type.name() eq "PAYMENT"}'>
                                                                            <c:choose>
                                                                                <c:when
                                                                                    test="${not empty transaction.orderId}">
                                                                                    <a href="/orders/${transaction.orderId}"
                                                                                        class="text-decoration-none">#${transaction.orderId}</a>
                                                                                </c:when>
                                                                                <c:otherwise>
                                                                                    ${transaction.paymentRef}
                                                                                </c:otherwise>
                                                                            </c:choose>
                                                                        </c:when>
                                                                        <c:otherwise>
                                                                            -
                                                                        </c:otherwise>
                                                                    </c:choose>
                                                                </td>
                                                                <td class="text-end">
                                                                    <c:choose>
                                                                        <c:when
                                                                            test='${transaction.type.name() eq "DEPOSIT" || transaction.type.name() eq "REFUND" || transaction.type.name() eq "SELLER_PAYOUT"}'>
                                                                            <span class="text-success">+
                                                                                <fmt:formatNumber
                                                                                    value="${transaction.amount}"
                                                                                    type="number" pattern="#,###" />
                                                                            </span>
                                                                        </c:when>
                                                                        <c:otherwise>
                                                                            <span class="text-danger">-
                                                                                <fmt:formatNumber
                                                                                    value="${transaction.amount}"
                                                                                    type="number" pattern="#,###" />
                                                                            </span>
                                                                        </c:otherwise>
                                                                    </c:choose>
                                                                    VNĐ
                                                                </td>
                                                                <td class="text-center">
                                                                    <span
                                                                        class="badge bg-${transaction.paymentStatus == 'SUCCESS' ? 'success' : transaction.paymentStatus == 'PENDING' ? 'warning' : 'danger'}">
                                                                        ${transaction.paymentStatus}
                                                                    </span>
                                                                </td>
                                                                <td class="text-center">
                                                                    <a href="/wallet/transactions/${transaction.id}"
                                                                        class="btn btn-sm btn-primary">
                                                                        <i class="fas fa-eye"></i> View
                                                                    </a>
                                                                </td>
                                                            </tr>
                                                        </c:forEach>
                                                    </tbody>
                                                </table>
                                            </div>
                                </div>

                                <!-- Pagination -->
                                <c:if test="${totalPages > 1}">
                                    <div class="card-footer">
                                        <div class="d-flex justify-content-center align-items-center">
                                            <ul class="pagination pagination-sm mb-0">
                                                <li class="page-item ${currentPage == 0 ? 'disabled' : ''}">
                                                    <a class="page-link"
                                                        href="?page=0&size=${transactions.size}&type=${selectedType}&status=${selectedStatus}">
                                                        <i class="fas fa-angle-double-left"></i>
                                                    </a>
                                                </li>
                                                <li class="page-item ${currentPage == 0 ? 'disabled' : ''}">
                                                    <a class="page-link"
                                                        href="?page=${currentPage - 1}&size=${transactions.size}&type=${selectedType}&status=${selectedStatus}">
                                                        <i class="fas fa-angle-left"></i>
                                                    </a>
                                                </li>
                                                <c:forEach begin="0" end="${totalPages - 1}" var="pageNum">
                                                    <c:if
                                                        test="${pageNum >= currentPage - 1 && pageNum <= currentPage + 1}">
                                                        <li class="page-item ${pageNum == currentPage ? 'active' : ''}">
                                                            <a class="page-link"
                                                                href="?page=${pageNum}&size=${transactions.size}&type=${selectedType}&status=${selectedStatus}">
                                                                ${pageNum + 1}
                                                            </a>
                                                        </li>
                                                    </c:if>
                                                </c:forEach>
                                                <li
                                                    class="page-item ${currentPage == totalPages - 1 ? 'disabled' : ''}">
                                                    <a class="page-link"
                                                        href="?page=${currentPage + 1}&size=${transactions.size}&type=${selectedType}&status=${selectedStatus}">
                                                        <i class="fas fa-angle-right"></i>
                                                    </a>
                                                </li>
                                                <li
                                                    class="page-item ${currentPage == totalPages - 1 ? 'disabled' : ''}">
                                                    <a class="page-link"
                                                        href="?page=${totalPages - 1}&size=${transactions.size}&type=${selectedType}&status=${selectedStatus}">
                                                        <i class="fas fa-angle-double-right"></i>
                                                    </a>
                                                </li>
                                            </ul>
                                        </div>
                                    </div>
                                </c:if>
                                </c:when>
                                <c:otherwise>
                                    <!-- 📭 Empty state -->
                                    <div class="text-center py-5">
                                        <i class="fas fa-inbox fa-4x text-muted mb-3"></i>
                                        <h4 class="text-muted">No transactions yet</h4>
                                        <p class="text-muted">You haven't made any transactions or no
                                            matching
                                            transactions were
                                            found for the current filters.</p>
                                        <a href="/wallet/deposit" class="btn btn-primary">
                                            <i class="fas fa-plus"></i> Deposit now
                                        </a>
                                    </div>
                                </c:otherwise>
                                </c:choose>
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

                        // Table functionality
                        document.addEventListener('DOMContentLoaded', function () {
                            // Initialize table sorting and resizing if table exists
                            var table = document.getElementById('resizableTable');
                            if (table) {
                                initializeTableFeatures();
                            }
                        });

                        function initializeTableFeatures() {
                            // Add sorting functionality
                            var headers = document.querySelectorAll('.resizable-table th.sortable');
                            headers.forEach(function (header) {
                                header.addEventListener('click', function () {
                                    const column = this.dataset.column;
                                    const dataType = this.dataset.type;
                                    const table = document.getElementById('resizableTable');

                                    // Toggle sort direction
                                    const isAsc = !this.classList.contains('sort-asc');

                                    // Remove sort classes from all headers
                                    headers.forEach(h => {
                                        h.classList.remove('sort-asc', 'sort-desc');
                                    });

                                    // Add sort class to current header
                                    this.classList.add(isAsc ? 'sort-asc' : 'sort-desc');

                                    // Sort table
                                    sortTable(table, column, dataType, isAsc ? 'asc' : 'desc');
                                });
                            });

                            // Add resizing functionality
                            var resizers = document.querySelectorAll('.resizer');
                            resizers.forEach(function (resizer) {
                                resizer.addEventListener('mousedown', function (e) {
                                    startResize(e, this);
                                });
                            });
                        }

                        function sortTable(table, columnIndex, dataType, direction) {
                            const tbody = table.querySelector('tbody');
                            const rows = Array.from(tbody.querySelectorAll('tr'));

                            rows.sort((a, b) => {
                                const aValue = a.cells[columnIndex].textContent.trim();
                                const bValue = b.cells[columnIndex].textContent.trim();

                                let comparison = 0;

                                if (dataType === 'number') {
                                    // Remove currency symbols and commas, then convert to number
                                    const aNum = parseFloat(aValue.replace(/[^0-9.-]+/g, '')) || 0;
                                    const bNum = parseFloat(bValue.replace(/[^0-9.-]+/g, '')) || 0;
                                    comparison = aNum - bNum;
                                } else if (dataType === 'date') {
                                    // Parse date
                                    const aDate = new Date(aValue);
                                    const bDate = new Date(bValue);
                                    comparison = aDate - bDate;
                                } else {
                                    // Text comparison
                                    comparison = aValue.localeCompare(bValue, 'vi');
                                }

                                return direction === 'asc' ? comparison : -comparison;
                            });

                            // Re-append sorted rows
                            rows.forEach(row => tbody.appendChild(row));
                        }

                        function startResize(e, resizer) {
                            e.preventDefault();
                            resizer.classList.add('resizing');

                            var startX = e.clientX;
                            var startWidth = resizer.parentElement.offsetWidth;

                            function doResize(e) {
                                var newWidth = startWidth + e.clientX - startX;
                                resizer.parentElement.style.width = newWidth + 'px';
                            }

                            function stopResize() {
                                resizer.classList.remove('resizing');
                                document.removeEventListener('mousemove', doResize);
                                document.removeEventListener('mouseup', stopResize);
                            }

                            document.addEventListener('mousemove', doResize);
                            document.addEventListener('mouseup', stopResize);
                        }
                    </script>
                </body>

                </html>