<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đổi mật khẩu - TaphoaMMO</title>
    
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
        
        .password-container {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 2rem 0;
        }
        
        .password-card {
            background: white;
            border-radius: 20px;
            box-shadow: 0 15px 35px rgba(0,0,0,0.1);
            overflow: hidden;
            max-width: 500px;
            width: 100%;
        }
        
        .password-header {
            background: linear-gradient(135deg, #2c3e50, #3498db);
            color: white;
            padding: 2rem;
            text-align: center;
        }
        
        .password-body {
            padding: 2rem;
        }
        
        .form-floating {
            margin-bottom: 1rem;
            position: relative;
        }
        
        .form-control:focus {
            border-color: #3498db;
            box-shadow: 0 0 0 0.2rem rgba(52, 152, 219, 0.25);
        }
        
        .password-toggle {
            position: absolute;
            right: 15px;
            top: 50%;
            transform: translateY(-50%);
            background: none;
            border: none;
            color: #6c757d;
            cursor: pointer;
            z-index: 10;
        }
        
        .password-toggle:hover {
            color: #3498db;
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
        
        .btn-change {
            background: linear-gradient(135deg, #3498db, #2980b9);
            border: none;
            border-radius: 10px;
            padding: 0.75rem 2rem;
            font-weight: 600;
            color: white;
            transition: all 0.3s ease;
            width: 100%;
        }
        
        .btn-change:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(52, 152, 219, 0.4);
            color: white;
        }
        
        .btn-cancel {
            background: #6c757d;
            border: none;
            border-radius: 10px;
            padding: 0.75rem 2rem;
            font-weight: 600;
            color: white;
            transition: all 0.3s ease;
            width: 100%;
            margin-top: 0.5rem;
        }
        
        .btn-cancel:hover {
            background: #5a6268;
            color: white;
        }
        
        .security-tips {
            background: #f8f9fa;
            border-radius: 10px;
            padding: 1rem;
            margin-top: 1.5rem;
        }
        
        .security-tips h6 {
            color: #2c3e50;
            margin-bottom: 0.5rem;
        }
        
        .security-tips ul {
            margin-bottom: 0;
            padding-left: 1.2rem;
        }
        
        .security-tips li {
            font-size: 0.875rem;
            color: #6c757d;
            margin-bottom: 0.25rem;
        }
        
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
    </style>
</head>
<body>
    <div class="password-container">
        <div class="password-card">
            <div class="password-header">
                <h2 class="mb-2">
                    <i class="fas fa-key me-3"></i>Đổi mật khẩu
                </h2>
                <p class="mb-0">Cập nhật mật khẩu để bảo mật tài khoản</p>
            </div>
            
            <div class="password-body">
                <!-- Flash Messages -->
                <c:if test="${not empty success}">
                    <div class="alert alert-success alert-dismissible fade show" role="alert">
                        <i class="fas fa-check-circle me-2"></i>${success}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>
                
                <c:if test="${not empty error}">
                    <div class="alert alert-danger alert-dismissible fade show" role="alert">
                        <i class="fas fa-exclamation-circle me-2"></i>${error}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>
                
                <form action="/users/change-password" method="post" id="changePasswordForm">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                    
                    <!-- Current Password -->
                    <div class="form-floating">
                        <input type="password" class="form-control" id="oldPassword" name="oldPassword" 
                               placeholder="Mật khẩu hiện tại" required>
                        <label for="oldPassword">
                            <i class="fas fa-lock me-2"></i>Mật khẩu hiện tại
                        </label>
                        <button type="button" class="password-toggle" onclick="togglePassword('oldPassword')">
                            <i class="fas fa-eye"></i>
                        </button>
                    </div>
                    
                    <!-- New Password -->
                    <div class="form-floating">
                        <input type="password" class="form-control" id="newPassword" name="newPassword" 
                               placeholder="Mật khẩu mới" required minlength="6" 
                               onkeyup="checkPasswordStrength(this.value)">
                        <label for="newPassword">
                            <i class="fas fa-key me-2"></i>Mật khẩu mới
                        </label>
                        <button type="button" class="password-toggle" onclick="togglePassword('newPassword')">
                            <i class="fas fa-eye"></i>
                        </button>
                        <div class="password-strength" id="passwordStrength"></div>
                        <div id="passwordHelp" class="form-text">
                            Mật khẩu phải có ít nhất 6 ký tự
                        </div>
                    </div>
                    
                    <!-- Confirm New Password -->
                    <div class="form-floating">
                        <input type="password" class="form-control" id="confirmPassword" name="confirmPassword" 
                               placeholder="Xác nhận mật khẩu mới" required 
                               onkeyup="checkPasswordMatch()">
                        <label for="confirmPassword">
                            <i class="fas fa-check me-2"></i>Xác nhận mật khẩu mới
                        </label>
                        <button type="button" class="password-toggle" onclick="togglePassword('confirmPassword')">
                            <i class="fas fa-eye"></i>
                        </button>
                        <div id="passwordMatchValidation" class="validation-feedback"></div>
                    </div>
                    
                    <!-- Submit Buttons -->
                    <button type="submit" class="btn btn-change" id="submitBtn" disabled>
                        <i class="fas fa-save me-2"></i>Đổi mật khẩu
                    </button>
                    
                    <a href="/users/profile" class="btn btn-cancel">
                        <i class="fas fa-times me-2"></i>Hủy bỏ
                    </a>
                </form>
                
                <!-- Security Tips -->
                <div class="security-tips">
                    <h6>
                        <i class="fas fa-shield-alt me-2 text-primary"></i>Mẹo bảo mật
                    </h6>
                    <ul>
                        <li>Sử dụng mật khẩu dài ít nhất 8 ký tự</li>
                        <li>Kết hợp chữ hoa, chữ thường, số và ký tự đặc biệt</li>
                        <li>Không sử dụng thông tin cá nhân dễ đoán</li>
                        <li>Không chia sẻ mật khẩu với bất kỳ ai</li>
                        <li>Thay đổi mật khẩu định kỳ</li>
                    </ul>
                </div>
            </div>
        </div>
    </div>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    
    <script>
        let passwordValid = false;
        let passwordMatch = false;
        
        // Toggle password visibility
        function togglePassword(fieldId) {
            const field = document.getElementById(fieldId);
            const button = field.nextElementSibling.nextElementSibling;
            const icon = button.querySelector('i');
            
            if (field.type === 'password') {
                field.type = 'text';
                icon.className = 'fas fa-eye-slash';
            } else {
                field.type = 'password';
                icon.className = 'fas fa-eye';
            }
        }
        
        // Check password strength
        function checkPasswordStrength(password) {
            const strengthBar = document.getElementById('passwordStrength');
            const helpText = document.getElementById('passwordHelp');
            
            if (password.length < 6) {
                strengthBar.className = 'password-strength';
                helpText.textContent = 'Mật khẩu phải có ít nhất 6 ký tự';
                helpText.className = 'form-text text-danger';
                passwordValid = false;
            } else if (password.length < 8) {
                strengthBar.className = 'password-strength strength-weak';
                helpText.textContent = 'Mật khẩu yếu - nên dài hơn 8 ký tự';
                helpText.className = 'form-text text-warning';
                passwordValid = true;
            } else if (password.length < 12 || !/(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/.test(password)) {
                strengthBar.className = 'password-strength strength-medium';
                helpText.textContent = 'Mật khẩu trung bình - thêm chữ hoa, số để mạnh hơn';
                helpText.className = 'form-text text-info';
                passwordValid = true;
            } else {
                strengthBar.className = 'password-strength strength-strong';
                helpText.textContent = 'Mật khẩu mạnh';
                helpText.className = 'form-text text-success';
                passwordValid = true;
            }
            
            checkPasswordMatch();
            updateSubmitButton();
        }
        
        // Check password match
        function checkPasswordMatch() {
            const newPassword = document.getElementById('newPassword').value;
            const confirmPassword = document.getElementById('confirmPassword').value;
            const validation = document.getElementById('passwordMatchValidation');
            
            if (confirmPassword === '') {
                validation.textContent = '';
                passwordMatch = false;
            } else if (newPassword === confirmPassword) {
                validation.textContent = 'Mật khẩu khớp';
                validation.className = 'validation-feedback valid';
                passwordMatch = true;
            } else {
                validation.textContent = 'Mật khẩu không khớp';
                validation.className = 'validation-feedback invalid';
                passwordMatch = false;
            }
            
            updateSubmitButton();
        }
        
        // Update submit button state
        function updateSubmitButton() {
            const submitBtn = document.getElementById('submitBtn');
            const oldPassword = document.getElementById('oldPassword').value;
            const canSubmit = oldPassword.length > 0 && passwordValid && passwordMatch;
            
            submitBtn.disabled = !canSubmit;
            if (canSubmit) {
                submitBtn.classList.remove('btn-secondary');
                submitBtn.classList.add('btn-change');
            } else {
                submitBtn.classList.remove('btn-change');
                submitBtn.classList.add('btn-secondary');
            }
        }
        
        // Form submission
        document.getElementById('changePasswordForm').addEventListener('submit', function(e) {
            if (!passwordValid || !passwordMatch) {
                e.preventDefault();
                alert('Vui lòng kiểm tra lại mật khẩu');
                return;
            }
            
            // Show loading state
            const submitBtn = document.getElementById('submitBtn');
            const originalText = submitBtn.innerHTML;
            submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>Đang xử lý...';
            submitBtn.disabled = true;
            
            // Re-enable button after 5 seconds (in case of error)
            setTimeout(function() {
                submitBtn.innerHTML = originalText;
                submitBtn.disabled = false;
            }, 5000);
        });
        
        // Monitor old password input
        document.getElementById('oldPassword').addEventListener('input', updateSubmitButton);
        
        // Auto-hide alerts after 5 seconds
        setTimeout(function() {
            $('.alert').fadeOut('slow');
        }, 5000);
    </script>
</body>
</html>
