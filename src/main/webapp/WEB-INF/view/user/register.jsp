<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://springframework.org/tags/form" prefix="form" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng ký tài khoản - TaphoaMMO</title>
    
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <style>
        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        
        .register-container {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 2rem 0;
        }
        
        .register-card {
            background: white;
            border-radius: 20px;
            box-shadow: 0 15px 35px rgba(0,0,0,0.1);
            overflow: hidden;
            max-width: 900px;
            width: 100%;
        }
        
        .register-header {
            background: linear-gradient(135deg, #2c3e50, #3498db);
            color: white;
            padding: 2rem;
            text-align: center;
        }
        
        .register-body {
            padding: 2rem;
        }
        
        .form-floating {
            margin-bottom: 1rem;
        }
        
        .form-control:focus {
            border-color: #3498db;
            box-shadow: 0 0 0 0.2rem rgba(52, 152, 219, 0.25);
        }
        
        .btn-register {
            background: linear-gradient(135deg, #3498db, #2980b9);
            border: none;
            border-radius: 10px;
            padding: 0.75rem 2rem;
            font-weight: 600;
            color: white;
            transition: all 0.3s ease;
        }
        
        .btn-register:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(52, 152, 219, 0.4);
            color: white;
        }
        
        .password-strength {
            height: 5px;
            border-radius: 3px;
            margin-top: 0.5rem;
            transition: all 0.3s ease;
        }
        
        .strength-weak { background-color: #e74c3c; }
        .strength-medium { background-color: #f39c12; }
        .strength-strong { background-color: #27ae60; }
        
        .validation-feedback {
            display: block;
            font-size: 0.875rem;
            margin-top: 0.25rem;
        }
        
        .validation-feedback.valid {
            color: #27ae60;
        }
        
        .validation-feedback.invalid {
            color: #e74c3c;
        }
        
        .terms-checkbox {
            margin: 1.5rem 0;
        }
        
        .login-link {
            text-align: center;
            margin-top: 1.5rem;
            padding-top: 1.5rem;
            border-top: 1px solid #eee;
        }
        
        .avatar-upload {
            position: relative;
            display: inline-block;
            margin-bottom: 1rem;
        }
        
        .avatar-preview {
            width: 100px;
            height: 100px;
            border-radius: 50%;
            border: 3px solid #ddd;
            object-fit: cover;
            cursor: pointer;
        }
        
        .avatar-placeholder {
            width: 100px;
            height: 100px;
            border-radius: 50%;
            border: 3px dashed #ddd;
            display: flex;
            align-items: center;
            justify-content: center;
            background: #f8f9fa;
            cursor: pointer;
            color: #6c757d;
        }
        
        .avatar-upload input[type="file"] {
            display: none;
        }
    </style>
</head>
<body>
    <div class="register-container">
        <div class="register-card">
            <div class="register-header">
                <h2 class="mb-2">
                    <i class="fas fa-user-plus me-3"></i>Đăng ký tài khoản
                </h2>
                <p class="mb-0">Tham gia cộng đồng TaphoaMMO ngay hôm nay</p>
            </div>
            
            <div class="register-body">
                <form action="/users/register" method="post" id="registerForm" enctype="multipart/form-data">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                    <div class="row">
                        <!-- Avatar Upload -->
                        <div class="col-12 text-center mb-4">
                            <div class="avatar-upload">
                                <div class="avatar-placeholder" onclick="document.getElementById('avatarInput').click()">
                                    <i class="fas fa-camera fa-2x"></i>
                                </div>
                                <input type="file" id="avatarInput" name="avatarFile" accept="image/*" onchange="previewAvatar(this)">
                            </div>
                            <div class="text-muted small">Nhấp để chọn ảnh đại diện</div>
                        </div>
                        
                        <!-- Basic Information -->
                        <div class="col-md-6">
                            <div class="form-floating">
                                <input type="text" class="form-control" id="username" name="username" 
                                       placeholder="Tên đăng nhập" required minlength="3" maxlength="50"
                                       onblur="checkUsername(this.value)">
                                <label for="username">
                                    <i class="fas fa-user me-2"></i>Tên đăng nhập
                                </label>
                                <div id="usernameValidation" class="validation-feedback"></div>
                            </div>
                        </div>
                        
                        <div class="col-md-6">
                            <div class="form-floating">
                                <input type="email" class="form-control" id="email" name="email" 
                                       placeholder="Email" required onblur="checkEmail(this.value)">
                                <label for="email">
                                    <i class="fas fa-envelope me-2"></i>Email
                                </label>
                                <div id="emailValidation" class="validation-feedback"></div>
                            </div>
                        </div>
                        
                        <div class="col-md-6">
                            <div class="form-floating">
                                <input type="text" class="form-control" id="fullName" name="fullName" 
                                       placeholder="Họ và tên" required maxlength="100">
                                <label for="fullName">
                                    <i class="fas fa-id-card me-2"></i>Họ và tên
                                </label>
                            </div>
                        </div>
                        
                        <div class="col-md-6">
                            <div class="form-floating">
                                <input type="tel" class="form-control" id="phone" name="phone" 
                                       placeholder="Số điện thoại" maxlength="15">
                                <label for="phone">
                                    <i class="fas fa-phone me-2"></i>Số điện thoại
                                </label>
                            </div>
                        </div>
                        
                        <!-- Password Fields -->
                        <div class="col-md-6">
                            <div class="form-floating">
                                <input type="password" class="form-control" id="password" name="password" 
                                       placeholder="Mật khẩu" required minlength="6" 
                                       onkeyup="checkPasswordStrength(this.value)">
                                <label for="password">
                                    <i class="fas fa-lock me-2"></i>Mật khẩu
                                </label>
                                <div class="password-strength" id="passwordStrength"></div>
                                <div id="passwordHelp" class="form-text">
                                    Mật khẩu phải có ít nhất 6 ký tự
                                </div>
                            </div>
                        </div>
                        
                        <div class="col-md-6">
                            <div class="form-floating">
                                <input type="password" class="form-control" id="confirmPassword" name="confirmPassword" 
                                       placeholder="Xác nhận mật khẩu" required 
                                       onkeyup="checkPasswordMatch()">
                                <label for="confirmPassword">
                                    <i class="fas fa-lock me-2"></i>Xác nhận mật khẩu
                                </label>
                                <div id="passwordMatchValidation" class="validation-feedback"></div>
                            </div>
                        </div>
                        
                        <!-- Additional Information -->
                        <div class="col-md-6">
                            <div class="form-floating">
                                <input type="date" class="form-control" id="dateOfBirth" name="dateOfBirth">
                                <label for="dateOfBirth">
                                    <i class="fas fa-birthday-cake me-2"></i>Ngày sinh
                                </label>
                            </div>
                        </div>
                        
                        <div class="col-md-6">
                            <div class="form-floating">
                                <select class="form-select" id="gender" name="gender">
                                    <option value="">Chọn giới tính</option>
                                    <option value="MALE">Nam</option>
                                    <option value="FEMALE">Nữ</option>
                                    <option value="OTHER">Khác</option>
                                    <option value="PREFER_NOT_TO_SAY">Không muốn tiết lộ</option>
                                </select>
                                <label for="gender">
                                    <i class="fas fa-venus-mars me-2"></i>Giới tính
                                </label>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Terms and Conditions -->
                    <div class="terms-checkbox">
                        <div class="form-check">
                            <input class="form-check-input" type="checkbox" id="agreeTerms" name="agreeTerms" required>
                            <label class="form-check-label" for="agreeTerms">
                                Tôi đồng ý với 
                                <a href="/terms" target="_blank">Điều khoản sử dụng</a> và 
                                <a href="/privacy" target="_blank">Chính sách bảo mật</a>
                            </label>
                        </div>
                    </div>
                    
                    <!-- Submit Button -->
                    <div class="d-grid">
                        <button type="submit" class="btn btn-register btn-lg" id="submitBtn" disabled>
                            <i class="fas fa-user-plus me-2"></i>Đăng ký tài khoản
                        </button>
                    </div>
                </form>
                
                <!-- Login Link -->
                <div class="login-link">
                    <p class="text-muted">
                        Đã có tài khoản? 
                        <a href="/auth/login" class="text-decoration-none">Đăng nhập ngay</a>
                    </p>
                </div>
            </div>
        </div>
    </div>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    
    <script>
        let usernameValid = false;
        let emailValid = false;
        let passwordValid = false;
        let passwordMatch = false;
        let termsAccepted = false;
        
        // Preview avatar
        function previewAvatar(input) {
            if (input.files && input.files[0]) {
                const reader = new FileReader();
                reader.onload = function(e) {
                    const placeholder = document.querySelector('.avatar-placeholder');
                    placeholder.innerHTML = `<img src="${e.target.result}" class="avatar-preview">`;
                };
                reader.readAsDataURL(input.files[0]);
            }
        }
        
        // Check username availability
        function checkUsername(username) {
            if (username.length < 3) {
                showValidation('usernameValidation', 'Tên đăng nhập phải có ít nhất 3 ký tự', false);
                usernameValid = false;
                updateSubmitButton();
                return;
            }
            
            $.ajax({
                url: '/users/check-username',
                method: 'GET',
                data: { username: username },
                success: function(response) {
                    if (response.available) {
                        showValidation('usernameValidation', 'Tên đăng nhập có thể sử dụng', true);
                        usernameValid = true;
                    } else {
                        showValidation('usernameValidation', 'Tên đăng nhập đã tồn tại', false);
                        usernameValid = false;
                    }
                    updateSubmitButton();
                },
                error: function() {
                    showValidation('usernameValidation', 'Không thể kiểm tra tên đăng nhập', false);
                    usernameValid = false;
                    updateSubmitButton();
                }
            });
        }
        
        // Check email availability
        function checkEmail(email) {
            if (!isValidEmail(email)) {
                showValidation('emailValidation', 'Email không hợp lệ', false);
                emailValid = false;
                updateSubmitButton();
                return;
            }
            
            $.ajax({
                url: '/users/check-email',
                method: 'GET',
                data: { email: email },
                success: function(response) {
                    if (response.available) {
                        showValidation('emailValidation', 'Email có thể sử dụng', true);
                        emailValid = true;
                    } else {
                        showValidation('emailValidation', 'Email đã được sử dụng', false);
                        emailValid = false;
                    }
                    updateSubmitButton();
                },
                error: function() {
                    showValidation('emailValidation', 'Không thể kiểm tra email', false);
                    emailValid = false;
                    updateSubmitButton();
                }
            });
        }
        
        // Check password strength
        function checkPasswordStrength(password) {
            const strengthBar = document.getElementById('passwordStrength');
            const helpText = document.getElementById('passwordHelp');
            
            if (password.length < 6) {
                strengthBar.className = 'password-strength';
                helpText.textContent = 'Mật khẩu phải có ít nhất 6 ký tự';
                passwordValid = false;
            } else if (password.length < 8) {
                strengthBar.className = 'password-strength strength-weak';
                helpText.textContent = 'Mật khẩu yếu';
                passwordValid = true;
            } else if (password.length < 12 || !/(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/.test(password)) {
                strengthBar.className = 'password-strength strength-medium';
                helpText.textContent = 'Mật khẩu trung bình';
                passwordValid = true;
            } else {
                strengthBar.className = 'password-strength strength-strong';
                helpText.textContent = 'Mật khẩu mạnh';
                passwordValid = true;
            }
            
            checkPasswordMatch();
            updateSubmitButton();
        }
        
        // Check password match
        function checkPasswordMatch() {
            const password = document.getElementById('password').value;
            const confirmPassword = document.getElementById('confirmPassword').value;
            
            if (confirmPassword === '') {
                document.getElementById('passwordMatchValidation').textContent = '';
                passwordMatch = false;
            } else if (password === confirmPassword) {
                showValidation('passwordMatchValidation', 'Mật khẩu khớp', true);
                passwordMatch = true;
            } else {
                showValidation('passwordMatchValidation', 'Mật khẩu không khớp', false);
                passwordMatch = false;
            }
            
            updateSubmitButton();
        }
        
        // Show validation message
        function showValidation(elementId, message, isValid) {
            const element = document.getElementById(elementId);
            element.textContent = message;
            element.className = `validation-feedback ${isValid ? 'valid' : 'invalid'}`;
        }
        
        // Validate email format
        function isValidEmail(email) {
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            return emailRegex.test(email);
        }
        
        // Update submit button state
        function updateSubmitButton() {
            const submitBtn = document.getElementById('submitBtn');
            const canSubmit = usernameValid && emailValid && passwordValid && passwordMatch && termsAccepted;
            
            submitBtn.disabled = !canSubmit;
            if (canSubmit) {
                submitBtn.classList.remove('btn-secondary');
                submitBtn.classList.add('btn-register');
            } else {
                submitBtn.classList.remove('btn-register');
                submitBtn.classList.add('btn-secondary');
            }
        }
        
        // Terms checkbox handler
        document.getElementById('agreeTerms').addEventListener('change', function() {
            termsAccepted = this.checked;
            updateSubmitButton();
        });
        
        // Form submission
        document.getElementById('registerForm').addEventListener('submit', function(e) {
            if (!usernameValid || !emailValid || !passwordValid || !passwordMatch || !termsAccepted) {
                e.preventDefault();
                alert('Vui lòng kiểm tra lại thông tin đăng ký');
            }
        });
    </script>
</body>
</html>
