<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
            <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
                <!DOCTYPE html>
                <html lang="en">

                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>Transaction History - Marketplace</title>
                    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css"
                        rel="stylesheet">
                    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css"
                        rel="stylesheet">
                    <style>
                        .transaction-card {
                            border-left: 4px solid #007bff;
                            transition: all 0.3s ease;
                        }

                        .transaction-card:hover {
                            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
                            transform: translateY(-2px);
                        }

                        .transaction-deposit {
                            border-left-color: #28a745;
                        }

                        .transaction-withdraw {
                            border-left-color: #dc3545;
                        }

                        .transaction-payment {
                            border-left-color: #ffc107;
                        }

                        .status-success {
                            background-color: #d4edda;
                            color: #155724;
                        }

                        .status-pending {
                            background-color: #fff3cd;
                            color: #856404;
                        }

                        .status-failed {
                            background-color: #f8d7da;
                            color: #721c24;
                        }

                        .amount-positive {
                            color: #28a745;
                            font-weight: bold;
                        }

                        .amount-negative {
                            color: #dc3545;
                            font-weight: bold;
                        }

                        .filter-section {
                            background-color: #f8f9fa;
                            border-radius: 8px;
                            padding: 20px;
                            margin-bottom: 20px;
                        }
                    </style>
                </head>

                <body>
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
                                                        <c:when test="${transactionType == 'DEPOSIT'}">Deposit</c:when>
                                                        <c:when test="${transactionType == 'WITHDRAWAL'}">Withdrawal
                                                        </c:when>
                                                        <c:when test="${transactionType == 'PAYMENT'}">Payment
                                                        </c:when>
                                                        <c:when test="${transactionType == 'REFUND'}">Refund</c:when>
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
                                                        <c:when test="${paymentStatus == 'SUCCESS'}">Success</c:when>
                                                        <c:when test="${paymentStatus == 'PENDING'}">Pending</c:when>
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
                                        <c:choose>
                                            <c:when test='${transaction.type.name() eq "DEPOSIT"}'>Deposit</c:when>
                                            <c:when test='${transaction.type.name() eq "WITHDRAWAL"}'>Withdrawal
                                            </c:when>
                                            <c:when test='${transaction.type.name() eq "PAYMENT"}'>Payment</c:when>
                                            <c:when test='${transaction.type.name() eq "REFUND"}'>Refund</c:when>
                                            <c:otherwise>Transfer</c:otherwise>
                                        </c:choose>

                                        <!-- Payment Method -->
                                        <c:if test="${transaction.paymentMethod != null}">
                                            <span class="badge bg-secondary ms-2">${transaction.paymentMethod}</span>
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

                                        <fmt:formatNumber value="${transaction.amount}" type="number" pattern="#,###" />
                                        VNĐ
                                    </h5>
                                </div>

                                <!-- Status & Action -->
                                <div class="col-md-2 text-end">
                                    <span class="badge 
                                                <c:choose>
                                                    <c:when test='${transaction.paymentStatus == "
                                        SUCCESS"}'>status-success</c:when>
                                        <c:when test='${transaction.paymentStatus == "PENDING"}'>status-pending</c:when>
                                        <c:otherwise>status-failed</c:otherwise>
                                        </c:choose> mb-2">

                                        <c:choose>
                                            <c:when test='${transaction.paymentStatus == "SUCCESS"}'>Success</c:when>
                                            <c:when test='${transaction.paymentStatus == "PENDING"}'>Pending</c:when>
                                            <c:when test='${transaction.paymentStatus == "FAILED"}'>Failed</c:when>
                                            <c:when test='${transaction.paymentStatus == "CANCELLED"}'>Cancelled
                                            </c:when>
                                            <c:otherwise>${transaction.paymentStatus}</c:otherwise>
                                        </c:choose>
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

                    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
                </body>

                </html>