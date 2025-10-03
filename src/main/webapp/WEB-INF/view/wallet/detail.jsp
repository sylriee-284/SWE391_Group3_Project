<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Ví của tôi</title>
                <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
                <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
            </head>

            <body>

                <jsp:include page="../common/navbar.jsp" />

                <div class="container mt-4">
                    <div class="row">
                        <div class="col-md-8 mx-auto">
                            <!-- Header -->
                            <div class="d-flex justify-content-between align-items-center mb-4">
                                <h2><i class="fas fa-wallet text-primary"></i> Ví của tôi</h2>
                                <a href="/" class="btn btn-outline-secondary">
                                    <i class="fas fa-home"></i> Về trang chủ
                                </a>
                            </div>

                            <!-- Thông tin ví -->
                            <div class="row mb-4">
                                <div class="col-md-6">
                                    <div class="card bg-primary text-white">
                                        <div class="card-body text-center">
                                            <h5 class="card-title">
                                                <i class="fas fa-coins"></i> Số dư hiện tại
                                            </h5>
                                            <h2 class="card-text">
                                                <c:choose>
                                                    <c:when test="${wallet != null}">
                                                        <fmt:formatNumber value="${wallet.balance}" type="currency"
                                                            currencySymbol="₫" />
                                                    </c:when>
                                                    <c:otherwise>
                                                        0 ₫
                                                    </c:otherwise>
                                                </c:choose>
                                            </h2>
                                        </div>
                                    </div>
                                </div>

                                <div class="col-md-6">
                                    <div class="card">
                                        <div class="card-body text-center">
                                            <h5 class="card-title">
                                                <i class="fas fa-user"></i> Chủ tài khoản
                                            </h5>
                                            <p class="card-text">
                                                <strong>${user.fullName != null ? user.fullName :
                                                    user.username}</strong><br>
                                                <small class="text-muted">${user.email}</small>
                                            </p>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Thao tác -->
                            <div class="row mb-4">
                                <div class="col-12">
                                    <div class="card">
                                        <div class="card-header">
                                            <h5><i class="fas fa-cog"></i> Thao tác</h5>
                                        </div>
                                        <div class="card-body">
                                            <div class="row">
                                                <div class="col-md-4 mb-3">
                                                    <a href="/wallet/deposit" class="btn btn-success w-100">
                                                        <i class="fas fa-plus-circle"></i><br>
                                                        Nạp tiền
                                                    </a>
                                                </div>
                                                <div class="col-md-4 mb-3">
                                                    <button class="btn btn-warning w-100" disabled>
                                                        <i class="fas fa-minus-circle"></i><br>
                                                        Rút tiền<br>
                                                        <small>(Sắp có)</small>
                                                    </button>
                                                </div>
                                                <div class="col-md-4 mb-3">
                                                    <a href="/wallet/transactions" class="btn btn-info w-100">
                                                        <i class="fas fa-history"></i><br>
                                                        Lịch sử giao dịch
                                                    </a>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Thông tin bổ sung -->
                            <div class="alert alert-info">
                                <h6><i class="fas fa-info-circle"></i> Thông tin quan trọng:</h6>
                                <ul class="mb-0">
                                    <li>Số dư ví được cập nhật ngay sau khi thanh toán thành công</li>
                                    <li>Bạn có thể sử dụng số dư để mua hàng trên hệ thống</li>
                                    <li>Mọi giao dịch đều được bảo mật và lưu trữ an toàn</li>
                                </ul>
                            </div>
                        </div>
                    </div>
                </div>

                <jsp:include page="../common/footer.jsp" />

                <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
            </body>

            </html>