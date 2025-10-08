<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <html>

        <head>
            <title>Login Page</title>
            <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css"
                rel="stylesheet">

            <!-- iziToast CSS -->
            <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/izitoast/1.4.0/css/iziToast.min.css" />


            <style>
                .divider:after,
                .divider:before {
                    content: "";
                    flex: 1;
                    height: 1px;
                    background: #eee;
                }

                .h-custom {
                    height: calc(100% - 73px);
                }

                @media (max-width: 450px) {
                    .h-custom {
                        height: 100%;
                    }
                }
            </style>
        </head>

        <body>
            <section class="vh-100">
                <div class="container-fluid h-custom">
                    <div class="row d-flex justify-content-center align-items-center h-100">
                        <div class="col-md-9 col-lg-6 col-xl-5">
                            <img src="https://mdbcdn.b-cdn.net/img/Photos/new-templates/bootstrap-login-form/draw2.webp"
                                class="img-fluid" alt="Sample image">
                        </div>
                        <div class="col-md-8 col-lg-6 col-xl-4 offset-xl-1">
                            <form action="/login" method="post">
                                <div
                                    class="d-flex flex-row align-items-center justify-content-center justify-content-lg-start">
                                    <p class="lead fw-normal mb-0 me-3">Sign in with</p>
                                    <button type="button" data-mdb-button-init data-mdb-ripple-init
                                        class="btn btn-primary btn-floating mx-1">
                                        <i class="fab fa-facebook-f"></i>
                                    </button>

                                    <button type="button" data-mdb-button-init data-mdb-ripple-init
                                        class="btn btn-primary btn-floating mx-1">
                                        <i class="fab fa-twitter"></i>
                                    </button>

                                    <button type="button" data-mdb-button-init data-mdb-ripple-init
                                        class="btn btn-primary btn-floating mx-1">
                                        <i class="fab fa-linkedin-in"></i>
                                    </button>
                                </div>

                                <div class="divider d-flex align-items-center my-4">
                                    <p class="text-center fw-bold mx-3 mb-0">Or</p>
                                </div>

                                <!-- Notifications will be displayed using iziToast -->

                                <!-- Username input -->
                                <div data-mdb-input-init class="form-outline mb-4">
                                    <label class="form-label" for="username">Username</label>
                                    <input type="text" id="username" name="username"
                                        class="form-control form-control-lg" placeholder="Enter a valid username"
                                        pattern="^[A-Za-z0-9_]{4,20}$"
                                        title="Username: 4-20 ký tự, chỉ chữ cái, số và _, không bắt đầu/kết thúc bằng _"
                                        required />
                                    <div class="invalid-feedback" id="usernameError">
                                        Username: 4-20 ký tự, chỉ chữ cái, số và _, không bắt đầu/kết thúc bằng _
                                    </div>
                                </div>

                                <!-- Password input -->
                                <div data-mdb-input-init class="form-outline mb-3">
                                    <label class="form-label" for="password">Password</label>
                                    <input type="password" id="password" name="password"
                                        class="form-control form-control-lg" placeholder="Enter password"
                                        pattern="^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[A-Z][a-zA-Z\d]{7,}$"
                                        title="Password: ít nhất 8 ký tự, bắt đầu bằng chữ hoa, có ít nhất 1 chữ hoa, 1 chữ thường, 1 số"
                                        required />
                                    <div class="invalid-feedback" id="passwordError">
                                        Password: ít nhất 8 ký tự, bắt đầu bằng chữ hoa, có ít nhất 1 chữ hoa, 1 chữ
                                        thường, 1 số
                                    </div>
                                </div>

                                <!-- Captcha input -->
                                <div class="form-outline mb-3">
                                    <div class="d-flex align-items-center mb-2">
                                        <img id="captchaImage" src="/login/captcha" alt="CAPTCHA"
                                            style="height:40px; border:1px solid #ccc; cursor:pointer;"
                                            onclick="refreshCaptcha()" />
                                        <button type="button" class="btn btn-outline-secondary btn-sm ms-2"
                                            onclick="refreshCaptcha()">Làm mới</button>
                                    </div>
                                    <label class="form-label" for="captchaInput">Mã xác thực (4 số)</label>
                                    <input type="text" id="captchaInput" name="captcha"
                                        class="form-control form-control-lg" placeholder="Nhập 4 số trong hình"
                                        maxlength="4" required />
                                </div>

                                <script>
                                    function refreshCaptcha() {
                                        var img = document.getElementById('captchaImage');
                                        img.src = '/login/captcha?' + new Date().getTime();
                                        document.getElementById('captchaInput').value = '';
                                    }

                                    // Validation functions
                                    function validateUsername(username) {
                                        // Kiểm tra độ dài 4-20 ký tự
                                        if (username.length < 4 || username.length > 20) {
                                            return false;
                                        }

                                        // Kiểm tra chỉ chứa chữ cái, số và _
                                        if (!/^[A-Za-z0-9_]+$/.test(username)) {
                                            return false;
                                        }

                                        // Kiểm tra không bắt đầu hoặc kết thúc bằng _
                                        if (username.startsWith('_') || username.endsWith('_')) {
                                            return false;
                                        }

                                        return true;
                                    }

                                    function validatePassword(password) {
                                        // Kiểm tra độ dài ít nhất 8 ký tự
                                        if (password.length < 8) {
                                            return false;
                                        }

                                        // Kiểm tra bắt đầu bằng chữ hoa
                                        if (!/^[A-Z]/.test(password)) {
                                            return false;
                                        }

                                        // Kiểm tra có ít nhất 1 chữ hoa
                                        if (!/[A-Z]/.test(password)) {
                                            return false;
                                        }

                                        // Kiểm tra có ít nhất 1 chữ thường
                                        if (!/[a-z]/.test(password)) {
                                            return false;
                                        }

                                        // Kiểm tra có ít nhất 1 số
                                        if (!/\d/.test(password)) {
                                            return false;
                                        }

                                        return true;
                                    }

                                    // Real-time validation
                                    document.getElementById('username').addEventListener('input', function () {
                                        var username = this.value;
                                        var isValid = validateUsername(username);

                                        if (username.length > 0 && !isValid) {
                                            this.setCustomValidity('Username không hợp lệ');
                                            this.classList.add('is-invalid');
                                        } else {
                                            this.setCustomValidity('');
                                            this.classList.remove('is-invalid');
                                        }
                                    });

                                    document.getElementById('password').addEventListener('input', function () {
                                        var password = this.value;
                                        var isValid = validatePassword(password);

                                        if (password.length > 0 && !isValid) {
                                            this.setCustomValidity('Password không hợp lệ');
                                            this.classList.add('is-invalid');
                                        } else {
                                            this.setCustomValidity('');
                                            this.classList.remove('is-invalid');
                                        }
                                    });

                                    // Form submission validation
                                    document.querySelector('form').addEventListener('submit', function (e) {
                                        var username = document.getElementById('username').value;
                                        var password = document.getElementById('password').value;

                                        if (!validateUsername(username)) {
                                            e.preventDefault();
                                            iziToast.error({
                                                title: 'Lỗi!',
                                                message: 'Username: 4-20 ký tự, chỉ chữ cái, số và _, không bắt đầu/kết thúc bằng _',
                                                position: 'topRight',
                                                timeout: 5000
                                            });
                                            return false;
                                        }

                                        if (!validatePassword(password)) {
                                            e.preventDefault();
                                            iziToast.error({
                                                title: 'Lỗi!',
                                                message: 'Password: ít nhất 8 ký tự, bắt đầu bằng chữ hoa, có ít nhất 1 chữ hoa, 1 chữ thường, 1 số',
                                                position: 'topRight',
                                                timeout: 5000
                                            });
                                            return false;
                                        }
                                    });
                                </script>

                                <div class="d-flex justify-content-between align-items-center">
                                    <a href="/forgot-password" class="text-body">Forgot password?</a>
                                </div>

                                <div class="text-center text-lg-start mt-4 pt-2">
                                    <button type="submit" data-mdb-button-init data-mdb-ripple-init
                                        class="btn btn-primary btn-lg"
                                        style="padding-left: 2.5rem; padding-right: 2.5rem;">Login</button>
                                    <p class="small fw-bold mt-2 pt-1 mb-0">Don't have an account? <a href="/register"
                                            class="link-danger">Register</a></p>
                                </div>

                            </form>
                        </div>
                    </div>
                </div>
                <div
                    class="d-flex flex-column flex-md-row text-center text-md-start justify-content-between py-4 px-4 px-xl-5 bg-primary">
                    <!-- Copyright -->
                    <div class="text-white mb-3 mb-md-0">
                        Copyright © 2020. All rights reserved.
                    </div>
                    <!-- Copyright -->

                    <!-- Right -->
                    <div>
                        <a href="#!" class="text-white me-4">
                            <i class="fab fa-facebook-f"></i>
                        </a>
                        <a href="#!" class="text-white me-4">
                            <i class="fab fa-twitter"></i>
                        </a>
                        <a href="#!" class="text-white me-4">
                            <i class="fab fa-google"></i>
                        </a>
                        <a href="#!" class="text-white">
                            <i class="fab fa-linkedin-in"></i>
                        </a>
                    </div>
                    <!-- Right -->
                </div>
            </section>

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