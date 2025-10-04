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

            <!-- iziToast CSS -->
            <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/izitoast/1.4.0/css/iziToast.min.css" />


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

                <!-- Notifications will be displayed using iziToast -->

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
                                    placeholder="Mật khẩu mới" autocomplete="off"
                                    pattern="^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[A-Z][a-zA-Z\d]{7,}$"
                                    title="Password: ít nhất 8 ký tự, bắt đầu bằng chữ hoa, có ít nhất 1 chữ hoa, 1 chữ thường, 1 số"
                                    required>
                                <div class="invalid-feedback" id="passwordError">
                                    Password: ít nhất 8 ký tự, bắt đầu bằng chữ hoa, có ít nhất 1 chữ hoa, 1 chữ thường,
                                    1 số
                                </div>
                            </div>
                            <div class="form-group">
                                <input type="password" class="input-lg form-control" name="confirmPassword"
                                    id="password2" placeholder="Mật khẩu mới" autocomplete="off" required>
                                <div class="invalid-feedback" id="confirmPasswordError">
                                    Nhập lại mật khẩu mới
                                </div>
                            </div>
                            <div class="row" id="password-match-container" style="display: none;">
                                <div class="col-sm-12">
                                    <span id="pwmatch" class="glyphicon glyphicon-remove" style="color:#FF0004;"></span>
                                    <span id="pwmatch-text">Mật khẩu không khớp</span>
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

                // Validation functions
                function validatePassword(password) {
                    // Check minimum length 8 characters
                    if (password.length < 8) {
                        return false;
                    }

                    // Check starts with uppercase
                    if (!/^[A-Z]/.test(password)) {
                        return false;
                    }

                    // Check has at least 1 uppercase
                    if (!/[A-Z]/.test(password)) {
                        return false;
                    }

                    // Check has at least 1 lowercase
                    if (!/[a-z]/.test(password)) {
                        return false;
                    }

                    // Check has at least 1 number
                    if (!/\d/.test(password)) {
                        return false;
                    }

                    return true;
                }

                // Real-time password validation
                $('#password1').on('input', function () {
                    var password = this.value;
                    var isValid = validatePassword(password);

                    if (password.length > 0 && !isValid) {
                        this.setCustomValidity('Password không hợp lệ');
                        this.classList.add('is-invalid');
                    } else {
                        this.setCustomValidity('');
                        this.classList.remove('is-invalid');
                    }

                    // Check password match again when password changes
                    var password2 = $('#password2').val();
                    if (password2.length > 0) {
                        checkPasswordMatch();
                    }
                });

                // Check password match
                function checkPasswordMatch() {
                    var password1 = $('#password1').val();
                    var password2 = $('#password2').val();

                    // Chỉ hiển thị khi có ít nhất một trong hai password có nội dung
                    if (password1.length > 0 || password2.length > 0) {
                        $('#password-match-container').show();

                        if (password1 === password2 && password1.trim().length > 0) {
                            $('#pwmatch').removeClass('glyphicon-remove').addClass('glyphicon-ok').css('color', '#28a745');
                            $('#pwmatch-text').text('Mật khẩu khớp').css('color', '#28a745');
                            $('#password2')[0].setCustomValidity('');
                            $('#password2').removeClass('is-invalid');
                        } else {
                            $('#pwmatch').removeClass('glyphicon-ok').addClass('glyphicon-remove').css('color', '#FF0004');
                            $('#pwmatch-text').text('Mật khẩu không khớp').css('color', '#FF0004');
                            if (password2.length > 0) {
                                $('#password2')[0].setCustomValidity('Mật khẩu không khớp');
                                $('#password2').addClass('is-invalid');
                            }
                        }
                    } else {
                        // Ẩn container khi cả hai password đều trống
                        $('#password-match-container').hide();
                        $('#password2')[0].setCustomValidity('');
                        $('#password2').removeClass('is-invalid');
                    }
                }

                $('#password2').on('keyup', checkPasswordMatch);
                $('#password1').on('keyup', checkPasswordMatch);

                // Form validation before submit
                $('#passwordForm').on('submit', function (e) {
                    var password1 = $('#password1').val();
                    var password2 = $('#password2').val();
                    var otp = $('#otp').val();
                    var email = $('#email').val();

                    // Check password validation
                    if (!validatePassword(password1)) {
                        e.preventDefault();
                        iziToast.error({
                            title: 'Error!',
                            message: 'Password: at least 8 characters, start with uppercase, must have at least 1 uppercase, 1 lowercase, 1 number',
                            position: 'topRight',
                            timeout: 5000
                        });
                        return false;
                    }

                    if (password1 !== password2) {
                        e.preventDefault();
                        iziToast.error({
                            title: 'Error!',
                            message: 'Passwords do not match!',
                            position: 'topRight',
                            timeout: 3000
                        });
                        return false;
                    }

                    if (password1.trim().length === 0) {
                        e.preventDefault();
                        iziToast.error({
                            title: 'Error!',
                            message: 'Password cannot be empty or contain only whitespace!',
                            position: 'topRight',
                            timeout: 3000
                        });
                        return false;
                    }

                    if (otp.length === 0) {
                        e.preventDefault();
                        iziToast.error({
                            title: 'Error!',
                            message: 'Please enter OTP code!',
                            position: 'topRight',
                            timeout: 3000
                        });
                        return false;
                    }

                    if (email.length === 0) {
                        e.preventDefault();
                        iziToast.error({
                            title: 'Error!',
                            message: 'Please enter email!',
                            position: 'topRight',
                            timeout: 3000
                        });
                        return false;
                    }
                });
            </script>

            <!-- iziToast JS -->
            <script src="https://cdnjs.cloudflare.com/ajax/libs/izitoast/1.4.0/js/iziToast.min.js"></script>

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

        </body>

        </html>