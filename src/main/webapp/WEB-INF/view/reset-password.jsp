<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <html>

        <head>
            <title>Đặt lại mật khẩu - Marketplace</title>
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

                .reset-container {
                    max-width: 500px;
                    margin: 0 auto;
                    border: 2px solid #e9ecef;
                    border-radius: 15px;
                    padding: 2rem;
                    background-color: #ffffff;
                    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
                }

                .form-control {
                    border: 2px solid #dee2e6;
                    border-radius: 8px;
                    transition: border-color 0.3s ease;
                    padding: 12px 16px;
                }

                .form-control:focus {
                    border-color: #007bff;
                    box-shadow: 0 0 0 0.2rem rgba(0, 123, 255, 0.25);
                }

                .btn-reset {
                    border: 2px solid #007bff;
                    border-radius: 8px;
                    font-weight: 600;
                    transition: all 0.3s ease;
                    padding: 12px 24px;
                }

                .btn-reset:hover {
                    border-color: #0056b3;
                    transform: translateY(-1px);
                    box-shadow: 0 4px 8px rgba(0, 123, 255, 0.3);
                }

                .back-link {
                    display: inline-block;
                    padding: 0.5rem 1rem;
                    border: 1px solid #6c757d;
                    border-radius: 6px;
                    color: #6c757d;
                    text-decoration: none;
                    transition: all 0.3s ease;
                }

                .back-link:hover {
                    border-color: #495057;
                    color: #495057;
                    background-color: #f8f9fa;
                }

                .password-strength {
                    margin-top: 8px;
                    font-size: 12px;
                }

                .strength-bar {
                    height: 4px;
                    border-radius: 2px;
                    margin-top: 4px;
                    transition: all 0.3s ease;
                }

                .strength-weak {
                    background-color: #dc3545;
                    width: 25%;
                }

                .strength-fair {
                    background-color: #ffc107;
                    width: 50%;
                }

                .strength-good {
                    background-color: #17a2b8;
                    width: 75%;
                }

                .strength-strong {
                    background-color: #28a745;
                    width: 100%;
                }

                .password-match {
                    display: flex;
                    align-items: center;
                    margin-top: 8px;
                    font-size: 14px;
                    transition: all 0.3s ease;
                }

                .password-match i {
                    margin-right: 8px;
                    font-size: 16px;
                }

                .password-match.valid {
                    color: #28a745;
                }

                .password-match.invalid {
                    color: #dc3545;
                }

                .requirements {
                    background-color: #f8f9fa;
                    border: 1px solid #e9ecef;
                    border-radius: 8px;
                    padding: 15px;
                    margin-top: 15px;
                    font-size: 13px;
                }

                .requirements h6 {
                    color: #343a40;
                    margin-bottom: 10px;
                    font-weight: 600;
                }

                .requirements ul {
                    margin: 0;
                    padding-left: 20px;
                }

                .requirements li {
                    margin-bottom: 5px;
                    color: #6c757d;
                }

                .requirements li.valid {
                    color: #28a745;
                }

                .requirements li.invalid {
                    color: #dc3545;
                }
            </style>
        </head>

        <body>
            <section class="vh-100">
                <div class="container-fluid h-custom">
                    <div class="row d-flex justify-content-center align-items-center h-100">
                        <div class="col-md-8 col-lg-6 col-xl-4">
                            <div class="reset-container">
                                <div class="text-center mb-4">
                                    <h2 class="fw-bold mb-2">Đặt lại mật khẩu</h2>
                                    <p class="text-muted">Nhập mã OTP từ email và mật khẩu mới để đặt lại mật khẩu của
                                        bạn</p>
                                </div>

                                <form action="/reset-password" method="post" id="passwordForm">
                                    <!-- Email input -->
                                    <div class="form-outline mb-4">
                                        <label class="form-label" for="email">Email của bạn</label>
                                        <input type="email" id="email" name="email" class="form-control form-control-lg"
                                            placeholder="Nhập email của bạn" value="${sessionScope.reset_email}"
                                            required />
                                        <div class="invalid-feedback" id="emailError">
                                            Vui lòng nhập email hợp lệ
                                        </div>
                                    </div>

                                    <!-- OTP input -->
                                    <div class="form-outline mb-4">
                                        <label class="form-label" for="otp">Mã OTP từ email</label>
                                        <input type="text" id="otp" name="otp" class="form-control form-control-lg"
                                            placeholder="Nhập mã OTP" maxlength="6" autocomplete="off" required />
                                        <div class="invalid-feedback" id="otpError">
                                            Vui lòng nhập mã OTP
                                        </div>
                                    </div>

                                    <!-- New Password input -->
                                    <div class="form-outline mb-4">
                                        <label class="form-label" for="newPassword">Mật khẩu mới</label>
                                        <input type="password" id="newPassword" name="newPassword"
                                            class="form-control form-control-lg" placeholder="Nhập mật khẩu mới"
                                            pattern="^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{12,128}$"
                                            title="Password: ít nhất 12 ký tự, có ít nhất 1 chữ hoa, 1 chữ thường, 1 số"
                                            maxlength="128" autocomplete="off" required />
                                        <div class="invalid-feedback" id="passwordError">
                                            Mật khẩu không hợp lệ
                                        </div>

                                        <!-- Password Strength Indicator -->
                                        <div class="password-strength" id="passwordStrength" style="display: none;">
                                            <div class="strength-bar" id="strengthBar"></div>
                                            <small class="text-muted" id="strengthText">Độ mạnh mật khẩu</small>
                                        </div>

                                        <!-- Password Requirements -->
                                        <div class="requirements" id="passwordRequirements" style="display: none;">
                                            <h6>Yêu cầu mật khẩu:</h6>
                                            <ul>
                                                <li id="req-length" class="invalid">
                                                    <i class="fas fa-times me-1"></i>Ít nhất 12 ký tự
                                                </li>
                                                <li id="req-uppercase" class="invalid">
                                                    <i class="fas fa-times me-1"></i>Có ít nhất 1 chữ hoa
                                                </li>
                                                <li id="req-lowercase" class="invalid">
                                                    <i class="fas fa-times me-1"></i>Có ít nhất 1 chữ thường
                                                </li>
                                                <li id="req-number" class="invalid">
                                                    <i class="fas fa-times me-1"></i>Có ít nhất 1 số
                                                </li>
                                            </ul>
                                        </div>
                                    </div>

                                    <!-- Confirm Password input -->
                                    <div class="form-outline mb-4">
                                        <label class="form-label" for="confirmPassword">Xác nhận mật khẩu</label>
                                        <input type="password" id="confirmPassword" name="confirmPassword"
                                            class="form-control form-control-lg" placeholder="Nhập lại mật khẩu mới"
                                            maxlength="128" autocomplete="off" required />
                                        <div class="invalid-feedback" id="confirmPasswordError">
                                            Mật khẩu không khớp
                                        </div>

                                        <!-- Password Match Indicator -->
                                        <div class="password-match" id="passwordMatch" style="display: none;">
                                            <i class="fas fa-times"></i>
                                            <span>Mật khẩu không khớp</span>
                                        </div>
                                    </div>

                                    <div class="text-center mb-3">
                                        <button type="submit" class="btn btn-primary btn-lg w-100 btn-reset">
                                            Đặt lại mật khẩu
                                        </button>
                                    </div>
                                </form>

                                <div class="text-center mt-3">
                                    <a href="/login" class="back-link">
                                        <i class="fas fa-arrow-left me-1"></i>
                                        Quay lại đăng nhập
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <!-- iziToast JS -->
            <script src="https://cdnjs.cloudflare.com/ajax/libs/izitoast/1.4.0/js/iziToast.min.js"></script>

            <script>
                // Validation functions
                function validatePassword(password) {
                    // Check minimum length 12 characters
                    if (password.length < 12) {
                        return false;
                    }

                    // Check maximum length 128 characters
                    if (password.length > 128) {
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
                document.getElementById('newPassword').addEventListener('input', function () {
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
                    var password2 = document.getElementById('confirmPassword').value;
                    if (password2.length > 0) {
                        checkPasswordMatch();
                    }
                });

                // Check password match
                function checkPasswordMatch() {
                    var password1 = document.getElementById('newPassword').value;
                    var password2 = document.getElementById('confirmPassword').value;
                    var matchDiv = document.getElementById('passwordMatch');

                    // Chỉ hiển thị khi có ít nhất một trong hai password có nội dung
                    if (password1.length > 0 || password2.length > 0) {
                        matchDiv.style.display = 'flex';

                        if (password1 === password2 && password1.trim().length > 0) {
                            matchDiv.className = 'password-match valid';
                            matchDiv.innerHTML = '<i class="fas fa-check"></i><span>Mật khẩu khớp</span>';
                            document.getElementById('confirmPassword').setCustomValidity('');
                            document.getElementById('confirmPassword').classList.remove('is-invalid');
                        } else {
                            matchDiv.className = 'password-match invalid';
                            matchDiv.innerHTML = '<i class="fas fa-times"></i><span>Mật khẩu không khớp</span>';
                            if (password2.length > 0) {
                                document.getElementById('confirmPassword').setCustomValidity('Mật khẩu không khớp');
                                document.getElementById('confirmPassword').classList.add('is-invalid');
                            }
                        }
                    } else {
                        // Ẩn container khi cả hai password đều trống
                        matchDiv.style.display = 'none';
                        document.getElementById('confirmPassword').setCustomValidity('');
                        document.getElementById('confirmPassword').classList.remove('is-invalid');
                    }
                }

                document.getElementById('confirmPassword').addEventListener('keyup', checkPasswordMatch);
                document.getElementById('newPassword').addEventListener('keyup', checkPasswordMatch);

                // Form validation before submit
                document.getElementById('passwordForm').addEventListener('submit', function (e) {
                    var password1 = document.getElementById('newPassword').value;
                    var password2 = document.getElementById('confirmPassword').value;
                    var otp = document.getElementById('otp').value;
                    var email = document.getElementById('email').value;

                    // Check password validation
                    if (!validatePassword(password1)) {
                        e.preventDefault();
                        iziToast.error({
                            title: 'Error!',
                            message: 'Password: ít nhất 12 ký tự, có ít nhất 1 chữ hoa, 1 chữ thường, 1 số',
                            position: 'topRight',
                            timeout: 5000
                        });
                        return false;
                    }

                    if (password1 !== password2) {
                        e.preventDefault();
                        iziToast.error({
                            title: 'Error!',
                            message: 'Mật khẩu không khớp!',
                            position: 'topRight',
                            timeout: 3000
                        });
                        return false;
                    }

                    if (password1.trim().length === 0) {
                        e.preventDefault();
                        iziToast.error({
                            title: 'Error!',
                            message: 'Mật khẩu không được để trống!',
                            position: 'topRight',
                            timeout: 3000
                        });
                        return false;
                    }

                    if (otp.length === 0) {
                        e.preventDefault();
                        iziToast.error({
                            title: 'Error!',
                            message: 'Vui lòng nhập mã OTP!',
                            position: 'topRight',
                            timeout: 3000
                        });
                        return false;
                    }

                    if (email.length === 0) {
                        e.preventDefault();
                        iziToast.error({
                            title: 'Error!',
                            message: 'Vui lòng nhập email!',
                            position: 'topRight',
                            timeout: 3000
                        });
                        return false;
                    }
                });

                // Auto-format OTP input (only allow numbers)
                document.getElementById('otp').addEventListener('keypress', function (e) {
                    if (!/[0-9]/.test(e.key) && !['Backspace', 'Delete', 'Tab', 'Enter', 'ArrowLeft', 'ArrowRight'].includes(e.key)) {
                        e.preventDefault();
                    }
                });
            </script>

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