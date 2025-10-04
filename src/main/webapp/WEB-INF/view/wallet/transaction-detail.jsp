<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
            <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
                <!DOCTYPE html>
                <html lang="en">

                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>Transaction Detail - Marketplace</title>
                    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css"
                        rel="stylesheet">
                    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css"
                        rel="stylesheet">
                    <style>
                        .transaction-header {
                            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                            color: white;
                            border-radius: 10px;
                            padding: 30px;
                            margin-bottom: 30px;
                        }

                        .detail-card {
                            border: none;
                            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
                            border-radius: 10px;
                        }

                        .status-success {
                            background-color: #d4edda;
                            color: #155724;
                            padding: 8px 16px;
                            border-radius: 20px;
                            font-weight: bold;
                        }

                        .status-pending {
                            background-color: #fff3cd;
                            color: #856404;
                            padding: 8px 16px;
                            border-radius: 20px;
                            font-weight: bold;
                        }

                        .status-failed {
                            background-color: #f8d7da;
                            color: #721c24;
                            padding: 8px 16px;
                            border-radius: 20px;
                            font-weight: bold;
                        }

                        .amount-display {
                            font-size: 2.5rem;
                            font-weight: bold;
                        }

                        .amount-positive {
                            color: #28a745;
                        }

                        .amount-negative {
                            color: #dc3545;
                        }

                        .info-row {
                            border-bottom: 1px solid #eee;
                            padding: 15px 0;
                        }

                        .info-row:last-child {
                            border-bottom: none;
                        }

                        .info-label {
                            font-weight: 600;
                            color: #6c757d;
                        }
                    </style>
                </head>

                <body>
                    <div class="container mt-4">
                        <!-- 🔙 Back button -->
                        <div class="row mb-3">
                            <div class="col-12">
                                <a href="/wallet/transactions" class="btn btn-outline-secondary">
                                    <i class="fas fa-arrow-left"></i> Back to List
                                </a>
                            </div>
                        </div>

                        <!-- 🎯 Transaction Header -->
                        <div class="transaction-header text-center">
                            <div class="row align-items-center">
                                <div class="col-md-2">
                                    <c:choose>
                                        <c:when test='${transaction.type == "DEPOSIT"}'>
                                            <i class="fas fa-plus-circle fa-4x"></i>
                                        </c:when>
                                        <c:when test='${transaction.type == "WITHDRAWAL"}'>
                                            <i class="fas fa-minus-circle fa-4x"></i>
                                        </c:when>
                                        <c:when test='${transaction.type == "PAYMENT"}'>
                                            <i class="fas fa-shopping-cart fa-4x"></i>
                                        </c:when>
                                        <c:when test='${transaction.type == "REFUND"}'>
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
                                            <c:when test='${transaction.type == "DEPOSIT"}'>Deposit Transaction</c:when>
                                            <c:when test='${transaction.type == "WITHDRAWAL"}'>Withdrawal Transaction
                                            </c:when>
                                            <c:when test='${transaction.type == "PAYMENT"}'>Payment Transaction</c:when>
                                            <c:when test='${transaction.type == "REFUND"}'>Refund Transaction</c:when>
                                            <c:otherwise>Transfer Transaction</c:otherwise>
                                        </c:choose>
                                    </h2>
                                    <p class="mb-0 opacity-75">
                                        <i class="fas fa-clock"></i>
                                        ${fn:replace(fn:substring(transaction.createdAt, 0, 19), 'T', ' ')}
                                    </p>
                                </div>
                                <div class="col-md-2">
                                    <span class="
                        <c:choose>
                            <c:when test='${transaction.paymentStatus == " SUCCESS"}'>status-success</c:when>
                                        <c:when test='${transaction.paymentStatus == "PENDING"}'>status-pending</c:when>
                                        <c:otherwise>status-failed</c:otherwise>
                                        </c:choose>">

                                        <c:choose>
                                            <c:when test='${transaction.paymentStatus == "SUCCESS"}'>
                                                <i class="fas fa-check-circle"></i> Success
                                            </c:when>
                                            <c:when test='${transaction.paymentStatus == "PENDING"}'>
                                                <i class="fas fa-clock"></i> Pending
                                            </c:when>
                                            <c:when test='${transaction.paymentStatus == "FAILED"}'>
                                                <i class="fas fa-times-circle"></i> Failed
                                            </c:when>
                                            <c:when test='${transaction.paymentStatus == "CANCELLED"}'>
                                                <i class="fas fa-ban"></i> Cancelled
                                            </c:when>
                                            <c:otherwise>${transaction.paymentStatus}</c:otherwise>
                                        </c:choose>
                                    </span>
                                </div>
                            </div>
                        </div>

                        <div class="row">
                            <!-- 💰 Amount Card -->
                            <div class="col-md-6 mb-4">
                                <div class="card detail-card">
                                    <div class="card-body text-center">
                                        <h5 class="card-title text-muted mb-3">
                                            <i class="fas fa-money-bill-wave"></i> Số tiền
                                        </h5>
                                        <div class="amount-display 
                            <c:choose>
                                <c:when test='${transaction.type == " DEPOSIT" || transaction.type=="REFUND" }'>
                                            amount-positive</c:when>
                                            <c:otherwise>amount-negative</c:otherwise>
                                            </c:choose>">

                                            <c:choose>
                                                <c:when
                                                    test='${transaction.type == "DEPOSIT" || transaction.type == "REFUND"}'>
                                                    +</c:when>
                                                <c:otherwise>-</c:otherwise>
                                            </c:choose>

                                            <fmt:formatNumber value="${transaction.amount}" type="number"
                                                pattern="#,###" />
                                            <small class="fs-4">VNĐ</small>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- 📋 Transaction Info -->
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
                                                            <c:otherwise>Transfer</c:otherwise>
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
                                                    ${fn:replace(fn:substring(transaction.createdAt, 0, 19), 'T', ' ')}
                                                </div>
                                            </div>
                                        </div>

                                        <c:if
                                            test="${transaction.updatedAt != null && transaction.updatedAt != transaction.createdAt}">
                                            <div class="info-row">
                                                <div class="row">
                                                    <div class="col-5 info-label">Cập nhật cuối:</div>
                                                    <div class="col-7">
                                                        ${fn:replace(fn:substring(transaction.updatedAt, 0, 19), 'T', '
                                                        ')}
                                                    </div>
                                                </div>
                                            </div>
                                        </c:if>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- 📝 Note Section -->
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

                        <!-- 🔗 Related Order (if exists) -->
                        <c:if test="${transaction.order != null}">
                            <div class="row mt-4">
                                <div class="col-12">
                                    <div class="card detail-card">
                                        <div class="card-body">
                                            <h5 class="card-title text-muted mb-3">
                                                <i class="fas fa-shopping-bag"></i> Đơn hàng liên quan
                                            </h5>
                                            <div class="d-flex justify-content-between align-items-center">
                                                <div>
                                                    <p class="mb-1"><strong>Order ID:</strong> #${transaction.order.id}
                                                    </p>
                                                    <p class="mb-0 text-muted">
                                                        Created at: ${fn:substring(transaction.order.createdAt, 0, 10)}
                                                    </p>
                                                </div>
                                                <a href="/orders/${transaction.order.id}"
                                                    class="btn btn-outline-primary">
                                                    <i class="fas fa-eye"></i> Xem đơn hàng
                                                </a>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </c:if>

                        <!-- 🎯 Action Buttons -->
                        <div class="row mt-4">
                            <div class="col-12 text-center">
                                <a href="/wallet/transactions" class="btn btn-secondary me-2">
                                    <i class="fas fa-list"></i> Transaction List
                                </a>
                                <a href="/wallet" class="btn btn-primary me-2">
                                    <i class="fas fa-wallet"></i> My Wallet
                                </a>
                                <c:if test='${transaction.paymentStatus == "SUCCESS" && transaction.type == "DEPOSIT"}'>
                                    <a href="/wallet/deposit" class="btn btn-success">
                                        <i class="fas fa-plus"></i> Add More Funds
                                    </a>
                                </c:if>
                            </div>
                        </div>
                    </div>

                    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
                </body>

                </html>