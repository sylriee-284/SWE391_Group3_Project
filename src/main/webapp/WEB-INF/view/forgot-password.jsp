<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
    <%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

        <!DOCTYPE html>
        <html lang="vi">

        <head>
            <meta charset="UTF-8">
            <meta http-equiv="X-UA-Compatible" content="IE=edge">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Đặt lại mật khẩu</title>
            <!-- Thêm link tới Bootstrap CSS -->
            <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css"
                rel="stylesheet">

            <!-- iziToast CSS -->
            <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/izitoast/1.4.0/css/iziToast.min.css" />

            <!-- Thêm font và style tùy chỉnh -->
            <style>
                body {
                    font-family: Arial, sans-serif;
                }

                .card {
                    max-width: 400px;
                    margin: 0 auto;
                    margin-top: 50px;
                }

                .btn-primary {
                    background-color: #007bff;
                }
            </style>
        </head>

        <body>

            <div class="card text-center" style="width: 100%;">
                <div class="card-header h5 text-white bg-primary">Đặt lại mật khẩu</div>
                <div class="card-body px-5">
                    <p class="card-text py-2">
                        Nhập địa chỉ email của bạn và chúng tôi sẽ gửi hướng dẫn đến email để bạn có thể đặt lại mật
                        khẩu.
                    </p>
                    <!-- Input email với validation -->
                    <form action="/forgot-password" method="POST" class="needs-validation" novalidate>
                        <!-- Notifications will be displayed using iziToast -->

                        <div class="form-outline">
                            <input type="email" id="typeEmail" name="email" class="form-control my-3"
                                placeholder="Nhập email của bạn" required />
                            <div class="invalid-feedback">Vui lòng nhập địa chỉ email hợp lệ.</div>
                        </div>

                        <!-- Nút đặt lại mật khẩu -->
                        <button type="submit" class="btn btn-primary w-100">Đặt lại mật khẩu</button>
                    </form>

                    <!-- Các liên kết thêm -->
                    <div class="d-flex justify-content-between mt-4">
                        <a href="/login">Đăng nhập</a>
                        <a href="/register">Đăng ký</a>
                    </div>
                </div>
            </div>

            <!-- Script để bật chức năng validation của form -->
            <script>
                // Validation của Bootstrap
                (function () {
                    'use strict'
                    var forms = document.querySelectorAll('.needs-validation')
                    Array.prototype.slice.call(forms)
                        .forEach(function (form) {
                            form.addEventListener('submit', function (event) {
                                if (!form.checkValidity()) {
                                    event.preventDefault()
                                    event.stopPropagation()
                                }
                                form.classList.add('was-validated')
                            }, false)
                        })
                })()
            </script>

            <!-- Thêm link tới Bootstrap JS (cần thiết cho tính năng validation) -->
            <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>

            <!-- iziToast JS -->
            <script src="https://cdnjs.cloudflare.com/ajax/libs/izitoast/1.4.0/js/iziToast.min.js"></script>

            <!-- Script to display notifications using iziToast -->
            <c:if test="${not empty successMessage}">
                <script>
                    iziToast.success({
                        title: 'Thành công!',
                        message: '${successMessage}',
                        position: 'topRight',
                        timeout: 5000
                    });
                </script>
            </c:if>

            <c:if test="${not empty errorMessage}">
                <script>
                    iziToast.error({
                        title: 'Lỗi!',
                        message: '${errorMessage}',
                        position: 'topRight',
                        timeout: 5000
                    });
                </script>
            </c:if>

        </body>

        </html>