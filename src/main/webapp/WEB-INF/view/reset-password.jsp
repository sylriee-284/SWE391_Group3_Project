<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <!DOCTYPE html>
        <html lang="vi">

        <head>
            <meta charset="UTF-8">
            <meta http-equiv="X-UA-Compatible" content="IE=edge">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Đặt lại mật khẩu</title>
            <!-- Kết nối tới Bootstrap 3 CSS và JS -->
            <link href="https://netdna.bootstrapcdn.com/bootstrap/3.1.0/css/bootstrap.min.css" rel="stylesheet"
                id="bootstrap-css">
            <script src="https://code.jquery.com/jquery-1.11.1.min.js"></script>
            <script src="https://netdna.bootstrapcdn.com/bootstrap/3.1.0/js/bootstrap.min.js"></script>

            <style>
                .container {
                    margin-top: 50px;
                }

                .row {
                    margin-bottom: 20px;
                }

                .btn-primary {
                    background-color: #007bff;
                }
            </style>
        </head>

        <body>

            <div class="container">
                <div class="row">
                    <div class="col-sm-12">
                        <h1 class="text-center">Đặt lại mật khẩu</h1>
                    </div>
                </div>

                <!-- Thông báo -->
                <c:if test="${not empty successMessage}">
                    <div class="alert alert-success" role="alert">
                        ${successMessage}
                    </div>
                </c:if>

                <c:if test="${not empty errorMessage}">
                    <div class="alert alert-danger" role="alert">
                        ${errorMessage}
                    </div>
                </c:if>

                <div class="row">
                    <div class="col-sm-6 col-sm-offset-3">
                        <p class="text-center">Nhập mã OTP từ email và mật khẩu mới để đặt lại mật khẩu của bạn.</p>
                        <form method="post" id="passwordForm" action="/reset-password">
                            <div class="form-group">
                                <input type="email" class="input-lg form-control" name="email" id="email"
                                    placeholder="Email của bạn" value="${sessionScope.reset_email}" required>
                            </div>
                            <div class="form-group">
                                <input type="text" class="input-lg form-control" name="otp" id="otp"
                                    placeholder="Mã OTP từ email" autocomplete="off" required>
                            </div>
                            <div class="form-group">
                                <input type="password" class="input-lg form-control" name="newPassword" id="password1"
                                    placeholder="Mật khẩu mới" autocomplete="off" required>
                            </div>
                            <div class="form-group">
                                <input type="password" class="input-lg form-control" name="confirmPassword"
                                    id="password2" placeholder="Nhập lại mật khẩu mới" autocomplete="off" required>
                            </div>
                            <div class="row">
                                <div class="col-sm-12">
                                    <span id="pwmatch" class="glyphicon glyphicon-remove" style="color:#FF0004;"></span>
                                    Mật
                                    khẩu không khớp
                                </div>
                            </div>
                            <input type="submit" class="col-xs-12 btn btn-primary btn-load btn-lg"
                                data-loading-text="Đang đặt lại mật khẩu..." value="Đặt lại mật khẩu">
                        </form>
                    </div>
                </div>
            </div>

            <!-- Script để bật chức năng validation của form và kiểm tra mật khẩu -->
            <script>
                // Validation của Bootstrap
                (function () {
                    'use strict';
                    var forms = document.querySelectorAll('.needs-validation');
                    Array.prototype.slice.call(forms)
                        .forEach(function (form) {
                            form.addEventListener('submit', function (event) {
                                if (!form.checkValidity()) {
                                    event.preventDefault();
                                    event.stopPropagation();
                                }
                                form.classList.add('was-validated');
                            }, false);
                        })
                })();

                // Kiểm tra sự khớp của mật khẩu
                $('#password1, #password2').on('keyup', function () {
                    var password1 = $('#password1').val();
                    var password2 = $('#password2').val();

                    if (password1 === password2 && password1.trim().length > 0) {
                        $('#pwmatch').removeClass('glyphicon-remove').addClass('glyphicon-ok').css('color', '#28a745');
                        $('#pwmatch').text(' Mật khẩu khớp');
                    } else {
                        $('#pwmatch').removeClass('glyphicon-ok').addClass('glyphicon-remove').css('color', '#FF0004');
                        $('#pwmatch').text(' Mật khẩu không khớp');
                    }
                });

                // Validation form trước khi submit
                $('#passwordForm').on('submit', function (e) {
                    var password1 = $('#password1').val();
                    var password2 = $('#password2').val();
                    var otp = $('#otp').val();
                    var email = $('#email').val();

                    if (password1 !== password2) {
                        e.preventDefault();
                        alert('Mật khẩu không khớp!');
                        return false;
                    }

                    if (password1.trim().length === 0) {
                        e.preventDefault();
                        alert('Mật khẩu không được để trống hoặc chỉ chứa khoảng trắng!');
                        return false;
                    }

                    if (otp.length === 0) {
                        e.preventDefault();
                        alert('Vui lòng nhập mã OTP!');
                        return false;
                    }

                    if (email.length === 0) {
                        e.preventDefault();
                        alert('Vui lòng nhập email!');
                        return false;
                    }
                });
            </script>

        </body>

        </html>