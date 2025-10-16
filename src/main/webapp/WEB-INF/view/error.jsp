<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <!DOCTYPE html>
    <html lang="vi">

    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <title>Đã xảy ra lỗi</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" />
        <style>
            body {
                background: #f8f9fa
            }
        </style>
    </head>

    <body>
        <jsp:include page="common/navbar.jsp" />
        <div class="container py-5" style="margin-top:64px;">
            <div class="text-center">
                <h2 class="mb-3">Đã xảy ra lỗi</h2>
                <p class="text-muted">Vui lòng thử lại sau hoặc quay lại trang chủ.</p>
                <a href="/" class="btn btn-secondary"><i class="bi bi-arrow-left"></i> Quay lại</a>
            </div>
        </div>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    </body>

    </html>