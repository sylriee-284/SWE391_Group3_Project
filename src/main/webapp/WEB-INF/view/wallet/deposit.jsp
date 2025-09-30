<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <!DOCTYPE html>
        <html lang="vi">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Nạp tiền vào ví</title>
            <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
            <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
        </head>

        <body>

            <div class="container mt-5">
                <div class="row justify-content-center">
                    <div class="col-md-6">
                        <div class="card">
                            <div class="card-header bg-primary text-white text-center">
                                <h4><i class="fas fa-plus-circle"></i> Nạp tiền vào ví</h4>
                            </div>
                            <div class="card-body">
                                <!-- Thông báo lỗi -->
                                <c:if test="${param.error eq 'invalid_amount'}">
                                    <div class="alert alert-danger alert-dismissible fade show" role="alert">
                                        <i class="fas fa-exclamation-circle"></i> Số tiền tối thiểu là 10,000 VNĐ
                                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                                    </div>
                                </c:if>

                                <c:if test="${param.error eq 'encoding'}">
                                    <div class="alert alert-danger alert-dismissible fade show" role="alert">
                                        <i class="fas fa-exclamation-circle"></i> Có lỗi xảy ra. Vui lòng thử lại!
                                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                                    </div>
                                </c:if>

                                <form action="/wallet/deposit" method="post" id="depositForm">
                                    <div class="mb-3">
                                        <label for="amount" class="form-label">
                                            <i class="fas fa-money-bill-wave"></i> Số tiền (VNĐ)
                                        </label>
                                        <input type="number" class="form-control" id="amount" name="amount"
                                            placeholder="Nhập số tiền muốn nạp" min="10000" step="1000" required>
                                        <div class="form-text">Số tiền tối thiểu: 10,000 VNĐ</div>
                                    </div>

                                    <div class="alert alert-info">
                                        <i class="fas fa-info-circle"></i>
                                        <strong>Lưu ý:</strong> Bạn sẽ được chuyển đến trang thanh toán VNPay để hoàn
                                        tất giao dịch.
                                    </div>

                                    <div class="d-grid">
                                        <button type="submit" class="btn btn-primary btn-lg">
                                            <i class="fas fa-credit-card"></i> Thanh toán bằng VNPay
                                        </button>
                                    </div>
                                </form>

                                <div class="text-center mt-3">
                                    <a href="/wallet" class="btn btn-outline-secondary">
                                        <i class="fas fa-arrow-left"></i> Quay lại ví
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
            <script>
                // Validation form
                document.getElementById('depositForm').addEventListener('submit', function (e) {
                    const amount = document.getElementById('amount').value;
                    if (!amount || amount < 10000) {
                        e.preventDefault();
                        alert('Vui lòng nhập số tiền tối thiểu 10,000 VNĐ');
                    }
                });

                // Format số tiền khi nhập
                document.getElementById('amount').addEventListener('input', function (e) {
                    let value = e.target.value;
                    if (value && !isNaN(value)) {
                        e.target.value = parseInt(value);
                    }
                });
            </script>

        </body>

        </html>