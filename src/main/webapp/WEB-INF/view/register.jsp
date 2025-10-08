<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <html>

        <head>
            <title>Login Page</title>
            <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css"
                rel="stylesheet">

            <!-- iziToast CSS -->
            <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/izitoast/1.4.0/css/iziToast.min.css" />


        </head>

        <body>
            <section class="vh-100" style="background-color: #eee;">
                <div class="container h-100">
                    <div class="row d-flex justify-content-center align-items-center h-100">
                        <div class="col-lg-12 col-xl-11">
                            <div class="card text-black" style="border-radius: 25px;">
                                <div class="card-body p-md-5">
                                    <div class="row justify-content-center">
                                        <div class="col-md-10 col-lg-6 col-xl-5 order-2 order-lg-1">

                                            <p class="text-center h1 fw-bold mb-5 mx-1 mx-md-4 mt-4">Sign up</p>

                                            <form class="mx-1 mx-md-4" action="/register" method="post">

                                                <!-- Notifications will be displayed using iziToast -->

                                                <div class="d-flex flex-row align-items-center mb-4">
                                                    <i class="fas fa-user fa-lg me-3 fa-fw"></i>
                                                    <div data-mdb-input-init class="form-outline flex-fill mb-0">
                                                        <label class="form-label" for="username">Username</label>
                                                        <input type="text" id="username" name="username"
                                                            class="form-control"
                                                            value="${username != null ? username : param.username}"
                                                            pattern="^[A-Za-z0-9_]{4,20}$"
                                                            title="Username: 4-20 ký tự, chỉ chữ cái, số và _, không bắt đầu/kết thúc bằng _"
                                                            required />
                                                        <div class="invalid-feedback" id="usernameError">
                                                            Username: 4-20 ký tự, chỉ chữ cái, số và _, không bắt
                                                            đầu/kết thúc bằng _
                                                        </div>
                                                    </div>
                                                </div>

                                                <div class="d-flex flex-row align-items-center mb-4">
                                                    <i class="fas fa-envelope fa-lg me-3 fa-fw"></i>
                                                    <div data-mdb-input-init class="form-outline flex-fill mb-0">
                                                        <label class="form-label" for="email">Your
                                                            Email</label>
                                                        <input type="email" id="email" name="email" class="form-control"
                                                            value="${email != null ? email : param.email}" required />
                                                    </div>
                                                </div>

                                                <div class="d-flex flex-row align-items-center mb-4">
                                                    <i class="fas fa-lock fa-lg me-3 fa-fw"></i>
                                                    <div data-mdb-input-init class="form-outline flex-fill mb-0">
                                                        <label class="form-label" for="password">Password</label>
                                                        <input type="password" id="password" name="password"
                                                            class="form-control"
                                                            pattern="^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[A-Z][a-zA-Z\d]{7,}$"
                                                            title="Password: ít nhất 8 ký tự, bắt đầu bằng chữ hoa, có ít nhất 1 chữ hoa, 1 chữ thường, 1 số"
                                                            required />
                                                        <div class="invalid-feedback" id="passwordError">
                                                            Password: ít nhất 8 ký tự, bắt đầu bằng chữ hoa, có ít nhất
                                                            1 chữ hoa, 1 chữ thường, 1 số
                                                        </div>
                                                    </div>
                                                </div>

                                                <div class="d-flex flex-row align-items-center mb-4">
                                                    <i class="fas fa-key fa-lg me-3 fa-fw"></i>
                                                    <div data-mdb-input-init class="form-outline flex-fill mb-0">
                                                        <label class="form-label" for="repeatPassword">Repeat your
                                                            password</label>
                                                        <input type="password" id="repeatPassword" name="repeatPassword"
                                                            class="form-control" required />
                                                        <div class="invalid-feedback" id="repeatPasswordError">
                                                            Mật khẩu không khớp
                                                        </div>
                                                    </div>
                                                </div>

                                                <div class="d-flex justify-content-center mx-4 mb-3 mb-lg-4">
                                                    <button type="submit" data-mdb-button-init data-mdb-ripple-init
                                                        class="btn btn-primary btn-lg">Register</button>
                                                </div>

                                            </form>

                                        </div>
                                        <div
                                            class="col-md-10 col-lg-6 col-xl-7 d-flex align-items-center order-1 order-lg-2">

                                            <img src="https://mdbcdn.b-cdn.net/img/Photos/new-templates/bootstrap-registration/draw1.webp"
                                                class="img-fluid" alt="Sample image">

                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
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

            <!-- Validation Script -->
            <script>
                // Validation functions
                function validateUsername(username) {
                    // Check length 4-20 characters
                    if (username.length < 4 || username.length > 20) {
                        return false;
                    }

                    // Check only contains letters, numbers and _
                    if (!/^[A-Za-z0-9_]+$/.test(username)) {
                        return false;
                    }

                    // Check cannot start or end with _
                    if (username.startsWith('_') || username.endsWith('_')) {
                        return false;
                    }

                    return true;
                }

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

                function validatePasswordMatch(password, repeatPassword) {
                    return password === repeatPassword;
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

                    // Check password match again when password changes
                    var repeatPassword = document.getElementById('repeatPassword').value;
                    if (repeatPassword.length > 0) {
                        validateRepeatPassword();
                    }
                });

                function validateRepeatPassword() {
                    var password = document.getElementById('password').value;
                    var repeatPassword = document.getElementById('repeatPassword').value;
                    var isValid = validatePasswordMatch(password, repeatPassword);

                    if (repeatPassword.length > 0 && !isValid) {
                        document.getElementById('repeatPassword').setCustomValidity('Mật khẩu không khớp');
                        document.getElementById('repeatPassword').classList.add('is-invalid');
                    } else {
                        document.getElementById('repeatPassword').setCustomValidity('');
                        document.getElementById('repeatPassword').classList.remove('is-invalid');
                    }
                }

                document.getElementById('repeatPassword').addEventListener('input', validateRepeatPassword);

                // Form submission validation
                document.querySelector('form').addEventListener('submit', function (e) {
                    var username = document.getElementById('username').value;
                    var password = document.getElementById('password').value;
                    var repeatPassword = document.getElementById('repeatPassword').value;

                    if (!validateUsername(username)) {
                        e.preventDefault();
                        iziToast.error({
                            title: 'Error!',
                            message: 'Username: 4-20 characters, only letters, numbers and _, cannot start/end with _',
                            position: 'topRight',
                            timeout: 5000
                        });
                        return false;
                    }

                    if (!validatePassword(password)) {
                        e.preventDefault();
                        iziToast.error({
                            title: 'Error!',
                            message: 'Password: at least 8 characters, start with uppercase, must have at least 1 uppercase, 1 lowercase, 1 number',
                            position: 'topRight',
                            timeout: 5000
                        });
                        return false;
                    }

                    if (!validatePasswordMatch(password, repeatPassword)) {
                        e.preventDefault();
                        iziToast.error({
                            title: 'Error!',
                            message: 'Passwords do not match!',
                            position: 'topRight',
                            timeout: 5000
                        });
                        return false;
                    }
                });
            </script>
        </body>

        </html>