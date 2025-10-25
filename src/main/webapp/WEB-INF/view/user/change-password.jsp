<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>

            <!DOCTYPE html>
            <html lang="en">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>
                    <c:if test="${not empty pageTitle}">${pageTitle} - </c:if>MMO Market System
                </title>

                <!-- Include common head with all CSS and JS -->
                <jsp:include page="../common/head.jsp" />
            </head>

            <body>
                <!-- Include Navbar -->
                <jsp:include page="../common/navbar.jsp" />

                <!-- Include Sidebar -->
                <jsp:include page="../common/sidebar.jsp" />

                <!-- Sidebar Overlay for Mobile -->
                <div class="sidebar-overlay" id="sidebarOverlay" onclick="toggleSidebar()"></div>

                <!-- Main Content Area -->
                <div class="content" id="content">
                    <div class="container mt-4">
                        <!-- Page Header -->
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <h4><i class="fas fa-key me-2"></i>Đổi Mật Khẩu</h4>
                        </div>

                        <!-- Change Password Form -->
                        <div class="border rounded p-4 mb-4 bg-light">
                            <form action="${pageContext.request.contextPath}/user/change-password" method="POST">
                                <div class="row g-3">
                                    <!-- Old Password -->
                                    <div class="col-12">
                                        <label for="oldPassword" class="form-label fw-bold">
                                            Mật khẩu hiện tại <span class="text-danger">(*)</span>
                                        </label>
                                        <div class="input-group">
                                            <input type="password" class="form-control" id="oldPassword"
                                                name="oldPassword" placeholder="Nhập mật khẩu hiện tại"
                                                style="height: 42px;" required>
                                            <button class="btn btn-outline-secondary" type="button"
                                                onclick="togglePassword('oldPassword')" style="height: 42px;">
                                                <i class="fas fa-eye" id="oldPassword-icon"></i>
                                            </button>
                                        </div>
                                        <div id="oldPasswordError" class="invalid-feedback d-none">
                                            <i class="fas fa-exclamation-circle me-1"></i>
                                            <span id="oldPasswordErrorText"></span>
                                        </div>
                                    </div>

                                    <!-- New Password -->
                                    <div class="col-12">
                                        <label for="newPassword" class="form-label fw-bold">
                                            Mật khẩu mới <span class="text-danger">(*)</span>
                                        </label>
                                        <div class="input-group">
                                            <input type="password" class="form-control" id="newPassword"
                                                name="newPassword" placeholder="Nhập mật khẩu mới" style="height: 42px;"
                                                required>
                                            <button class="btn btn-outline-secondary" type="button"
                                                onclick="togglePassword('newPassword')" style="height: 42px;">
                                                <i class="fas fa-eye" id="newPassword-icon"></i>
                                            </button>
                                        </div>
                                        <div id="newPasswordError" class="invalid-feedback d-none">
                                            <i class="fas fa-exclamation-circle me-1"></i>
                                            <span id="newPasswordErrorText"></span>
                                        </div>
                                        <div id="newPasswordSuccess" class="valid-feedback d-none">
                                            <i class="fas fa-check-circle me-1"></i>
                                            Mật khẩu hợp lệ
                                        </div>
                                    </div>

                                    <!-- Confirm Password -->
                                    <div class="col-12">
                                        <label for="confirmPassword" class="form-label fw-bold">
                                            Xác nhận mật khẩu mới <span class="text-danger">(*)</span>
                                        </label>
                                        <div class="input-group">
                                            <input type="password" class="form-control" id="confirmPassword"
                                                name="confirmPassword" placeholder="Nhập lại mật khẩu mới"
                                                style="height: 42px;" required>
                                            <button class="btn btn-outline-secondary" type="button"
                                                onclick="togglePassword('confirmPassword')" style="height: 42px;">
                                                <i class="fas fa-eye" id="confirmPassword-icon"></i>
                                            </button>
                                        </div>
                                        <div id="confirmPasswordError" class="invalid-feedback d-none">
                                            <i class="fas fa-exclamation-circle me-1"></i>
                                            <span id="confirmPasswordErrorText"></span>
                                        </div>
                                        <div id="confirmPasswordSuccess" class="valid-feedback d-none">
                                            <i class="fas fa-check-circle me-1"></i>
                                            Mật khẩu khớp
                                        </div>
                                    </div>

                                    <!-- Submit Buttons -->
                                    <div class="col-12">
                                        <div class="d-flex gap-2">
                                            <button type="submit" class="btn btn-success"
                                                style="height: 42px; font-size: 16px;">
                                                <i class="fas fa-check-circle me-2"></i>Đổi Mật Khẩu
                                            </button>
                                            <a href="${pageContext.request.contextPath}/homepage"
                                                class="btn btn-secondary" style="height: 42px; font-size: 16px;">
                                                <i class="fas fa-times-circle me-2"></i>Hủy
                                            </a>
                                        </div>
                                    </div>
                                </div>
                            </form>
                        </div>
                    </div>
                    <br />
                </div>

                <!-- Include Footer s-->
                <jsp:include page="../common/footer.jsp" />

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

                <!-- Page-specific JavaScript -->
                <c:if test="${not empty pageJS}">
                    <c:forEach var="js" items="${pageJS}">
                        <script src="${pageContext.request.contextPath}${js}"></script>
                    </c:forEach>
                </c:if>

                <!-- Custom CSS -->
                <style>
                    .input-group .btn-outline-secondary {
                        border-color: #ced4da;
                        border-left: none;
                    }

                    .input-group .btn-outline-secondary:hover {
                        background-color: #e9ecef;
                        border-color: #ced4da;
                        color: #495057;
                    }

                    .input-group .btn-outline-secondary:focus {
                        box-shadow: none;
                        border-color: #ced4da;
                    }

                    .input-group .form-control:focus+.btn-outline-secondary {
                        border-color: #86b7fe;
                        border-left: none;
                    }

                    .bg-light {
                        background-color: #f8f9fa !important;
                    }

                    /* Validation messages */
                    .invalid-feedback {
                        display: block !important;
                        color: #dc3545;
                        font-size: 0.875rem;
                        margin-top: 0.25rem;
                    }

                    .valid-feedback {
                        display: block !important;
                        color: #198754;
                        font-size: 0.875rem;
                        margin-top: 0.25rem;
                    }

                    .invalid-feedback.d-none,
                    .valid-feedback.d-none {
                        display: none !important;
                    }

                    .form-control.is-invalid {
                        border-color: #dc3545;
                    }

                    .form-control.is-valid {
                        border-color: #198754;
                    }

                    .input-group .form-control.is-invalid+.btn-outline-secondary {
                        border-color: #dc3545;
                    }

                    .input-group .form-control.is-valid+.btn-outline-secondary {
                        border-color: #198754;
                    }
                </style>

                <!-- Common JavaScript -->
                <script>
                    // Toggle password visibility
                    function togglePassword(inputId) {
                        const input = document.getElementById(inputId);
                        const icon = document.getElementById(inputId + '-icon');

                        if (input.type === 'password') {
                            input.type = 'text';
                            icon.classList.remove('fa-eye');
                            icon.classList.add('fa-eye-slash');
                        } else {
                            input.type = 'password';
                            icon.classList.remove('fa-eye-slash');
                            icon.classList.add('fa-eye');
                        }
                    }

                    // Password validation
                    function validatePassword(password) {
                        const minLength = 8;
                        const hasUpperCase = /[A-Z]/.test(password);
                        const hasLowerCase = /[a-z]/.test(password);
                        const hasNumbers = /\d/.test(password);

                        // Ký tự đặc biệt chỉ đề xuất, không bắt buộc
                        const isValid = password.length >= minLength && hasUpperCase && hasLowerCase && hasNumbers;

                        if (!isValid) {
                            return {
                                valid: false,
                                message: 'Mật khẩu phải có ít nhất 8 ký tự, 1 chữ hoa, 1 chữ thường và 1 số'
                            };
                        }

                        return { valid: true, message: '' };
                    }

                    // Show error message
                    function showError(inputId, message) {
                        const input = document.getElementById(inputId);
                        const errorDiv = document.getElementById(inputId + 'Error');
                        const errorText = document.getElementById(inputId + 'ErrorText');
                        const successDiv = document.getElementById(inputId + 'Success');

                        input.classList.add('is-invalid');
                        input.classList.remove('is-valid');
                        errorDiv.classList.remove('d-none');
                        if (errorText) errorText.textContent = message;
                        if (successDiv) successDiv.classList.add('d-none');
                    }

                    // Show success message
                    function showSuccess(inputId) {
                        const input = document.getElementById(inputId);
                        const errorDiv = document.getElementById(inputId + 'Error');
                        const successDiv = document.getElementById(inputId + 'Success');

                        input.classList.remove('is-invalid');
                        input.classList.add('is-valid');
                        errorDiv.classList.add('d-none');
                        if (successDiv) successDiv.classList.remove('d-none');
                    }

                    // Clear validation
                    function clearValidation(inputId) {
                        const input = document.getElementById(inputId);
                        const errorDiv = document.getElementById(inputId + 'Error');
                        const successDiv = document.getElementById(inputId + 'Success');

                        input.classList.remove('is-invalid', 'is-valid');
                        errorDiv.classList.add('d-none');
                        if (successDiv) successDiv.classList.add('d-none');
                    }

                    // Initialize validation on page load
                    document.addEventListener('DOMContentLoaded', function () {
                        const oldPasswordInput = document.getElementById('oldPassword');
                        const newPasswordInput = document.getElementById('newPassword');
                        const confirmPasswordInput = document.getElementById('confirmPassword');

                        // Validate old password on blur
                        oldPasswordInput.addEventListener('blur', function () {
                            if (this.value.trim() === '') {
                                showError('oldPassword', 'Vui lòng nhập mật khẩu cũ');
                            } else {
                                clearValidation('oldPassword');
                            }
                        });

                        // Validate new password on input
                        newPasswordInput.addEventListener('input', function () {
                            if (this.value.trim() === '') {
                                clearValidation('newPassword');
                                return;
                            }

                            const result = validatePassword(this.value);
                            if (!result.valid) {
                                showError('newPassword', result.message);
                            } else {
                                showSuccess('newPassword');
                            }

                            // Also check confirm password if it has value
                            if (confirmPasswordInput.value.trim() !== '') {
                                validateConfirmPassword();
                            }
                        });

                        // Validate confirm password
                        function validateConfirmPassword() {
                            const newPassword = newPasswordInput.value;
                            const confirmPassword = confirmPasswordInput.value;

                            if (confirmPassword.trim() === '') {
                                clearValidation('confirmPassword');
                                return;
                            }

                            if (newPassword !== confirmPassword) {
                                showError('confirmPassword', 'Mật khẩu xác nhận không khớp');
                            } else {
                                showSuccess('confirmPassword');
                            }
                        }

                        confirmPasswordInput.addEventListener('input', validateConfirmPassword);

                        // Form submit validation
                        document.querySelector('form').addEventListener('submit', function (e) {
                            let hasError = false;

                            // Check old password
                            if (oldPasswordInput.value.trim() === '') {
                                showError('oldPassword', 'Vui lòng nhập mật khẩu cũ');
                                hasError = true;
                            }

                            // Check new password
                            const newPasswordResult = validatePassword(newPasswordInput.value);
                            if (!newPasswordResult.valid) {
                                showError('newPassword', newPasswordResult.message);
                                hasError = true;
                            }

                            // Check confirm password
                            if (newPasswordInput.value !== confirmPasswordInput.value) {
                                showError('confirmPassword', 'Mật khẩu xác nhận không khớp');
                                hasError = true;
                            }

                            // Check if old and new password are same
                            if (oldPasswordInput.value === newPasswordInput.value && oldPasswordInput.value !== '') {
                                showError('newPassword', 'Mật khẩu mới phải khác mật khẩu cũ');
                                hasError = true;
                            }

                            if (hasError) {
                                e.preventDefault();
                            }
                        });
                    });

                    // Toggle sidebar function
                    function toggleSidebar() {
                        var sidebar = document.getElementById('sidebar');
                        var content = document.getElementById('content');
                        var overlay = document.getElementById('sidebarOverlay');

                        if (sidebar && content) {
                            sidebar.classList.toggle('active');
                            content.classList.toggle('shifted');

                            // Toggle overlay for mobile
                            if (overlay) {
                                overlay.classList.toggle('active');
                            }
                        }
                    }

                    // Close sidebar when clicking outside on mobile
                    document.addEventListener('click', function (event) {
                        var sidebar = document.getElementById('sidebar');
                        var overlay = document.getElementById('sidebarOverlay');
                        var menuToggle = document.querySelector('.menu-toggle');

                        if (sidebar && sidebar.classList.contains('active') &&
                            !sidebar.contains(event.target) &&
                            !menuToggle.contains(event.target)) {
                            toggleSidebar();
                        }
                    });

                    // Auto-hide alerts after 5 seconds
                    document.addEventListener('DOMContentLoaded', function () {
                        var alerts = document.querySelectorAll('.alert');
                        alerts.forEach(function (alert) {
                            setTimeout(function () {
                                alert.style.opacity = '0';
                                setTimeout(function () {
                                    alert.remove();
                                }, 300);
                            }, 5000);
                        });
                    });

                    // Table functionality
                    document.addEventListener('DOMContentLoaded', function () {
                        // Initialize table sorting and resizing if table exists
                        var table = document.getElementById('resizableTable');
                        if (table) {
                            initializeTableFeatures();
                        }
                    });

                    function initializeTableFeatures() {
                        // Add sorting functionality
                        var headers = document.querySelectorAll('.resizable-table th.sortable');
                        headers.forEach(function (header, index) {
                            header.addEventListener('click', function () {
                                sortTable(index, this);
                            });
                        });

                        // Add resizing functionality
                        var resizers = document.querySelectorAll('.resizer');
                        resizers.forEach(function (resizer) {
                            resizer.addEventListener('mousedown', function (e) {
                                startResize(e, this);
                            });
                        });
                    }

                    function sortTable(columnIndex, header) {
                        // Basic sorting implementation
                        var table = document.getElementById('resizableTable');
                        var tbody = table.querySelector('tbody');
                        var rows = Array.from(tbody.querySelectorAll('tr'));

                        var isAsc = !header.classList.contains('sort-asc');

                        // Remove existing sort classes
                        document.querySelectorAll('.resizable-table th').forEach(th => {
                            th.classList.remove('sort-asc', 'sort-desc');
                        });

                        // Add current sort class
                        header.classList.add(isAsc ? 'sort-asc' : 'sort-desc');

                        // Sort rows
                        rows.sort(function (a, b) {
                            var aVal = a.cells[columnIndex].textContent.trim();
                            var bVal = b.cells[columnIndex].textContent.trim();

                            if (isAsc) {
                                return aVal > bVal ? 1 : -1;
                            } else {
                                return aVal < bVal ? 1 : -1;
                            }
                        });

                        // Reorder rows
                        rows.forEach(row => tbody.appendChild(row));
                    }

                    function startResize(e, resizer) {
                        e.preventDefault();
                        resizer.classList.add('resizing');

                        var startX = e.clientX;
                        var startWidth = resizer.parentElement.offsetWidth;

                        function doResize(e) {
                            var newWidth = startWidth + e.clientX - startX;
                            resizer.parentElement.style.width = newWidth + 'px';
                        }

                        function stopResize() {
                            resizer.classList.remove('resizing');
                            document.removeEventListener('mousemove', doResize);
                            document.removeEventListener('mouseup', stopResize);
                        }

                        document.addEventListener('mousemove', doResize);
                        document.addEventListener('mouseup', stopResize);
                    }
                </script>
            </body>

            </html>