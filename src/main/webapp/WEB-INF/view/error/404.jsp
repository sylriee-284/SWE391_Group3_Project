<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <!DOCTYPE html>
    <html lang="vi">

    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <title>Không tìm thấy trang</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" />
        <style>
            body {
                background: #f8f9fa
            }
        </style>
    </head>

    <body>
        <jsp:include page="../common/navbar.jsp" />
        <div class="container py-5" style="margin-top:64px;">
            <div class="text-center">
                <h1 class="display-4">404</h1>
                <p class="lead">Xin lỗi, trang bạn yêu cầu không tồn tại.</p>
                <a href="/" class="btn btn-primary"><i class="bi bi-house"></i> Về trang chủ</a>
            </div>
        </div>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    </body>

    </html>