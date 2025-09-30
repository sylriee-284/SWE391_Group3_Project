<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <!DOCTYPE html>
        <html lang="vi">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Nạp tiền thành công</title>
            <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
            <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
        </head>

        <body>

            <div class="container mt-5">
                <div class="row justify-content-center">
                    <div class="col-md-6">
                        <div class="card border-success">
                            <div class="card-header bg-success text-white text-center">
                                <h4><i class="fas fa-check-circle"></i> Nạp tiền thành công!</h4>
                            </div>
                            <div class="card-body text-center">
                                <div class="mb-4">
                                    <i class="fas fa-check-circle text-success" style="font-size: 4rem;"></i>
                                </div>
                                <h5 class="text-success">Giao dịch đã được xử lý thành công</h5>
                                <p class="text-muted">Số tiền đã được nạp vào ví của bạn.</p>

                                <div class="d-grid gap-2 mt-4">
                                    <a href="/wallet" class="btn btn-success">
                                        <i class="fas fa-wallet"></i> Xem ví của tôi
                                    </a>
                                    <a href="/" class="btn btn-outline-secondary">
                                        <i class="fas fa-home"></i> Về trang chủ
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
        </body>

        </html>