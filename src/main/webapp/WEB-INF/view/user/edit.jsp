<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chỉnh sửa hồ sơ - TaphoaMMO</title>
    
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <style>
        body {
            background-color: #f8f9fa;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        
        .edit-header {
            background: linear-gradient(135deg, #2c3e50, #3498db);
            color: white;
            padding: 2rem 0;
            margin-bottom: 2rem;
            border-radius: 0 0 15px 15px;
        }
        
        .edit-card {
            background: white;
            border-radius: 15px;
            padding: 2rem;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
            margin-bottom: 2rem;
        }
        
        .form-floating {
            margin-bottom: 1rem;
        }
        
        .form-control:focus {
            border-color: #3498db;
            box-shadow: 0 0 0 0.2rem rgba(52, 152, 219, 0.25);
        }
        
        .avatar-upload {
            position: relative;
            display: inline-block;
            margin-bottom: 1rem;
        }
        
        .avatar-preview {
            width: 120px;
            height: 120px;
            border-radius: 50%;
            border: 3px solid #ddd;
            object-fit: cover;
            cursor: pointer;
        }
        
        .avatar-placeholder {
            width: 120px;
            height: 120px;
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
        
        .avatar-overlay {
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(0,0,0,0.5);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            opacity: 0;
            transition: opacity 0.3s ease;
            cursor: pointer;
        }
        
        .avatar-upload:hover .avatar-overlay {
            opacity: 1;
        }
        
        .btn-save {
            background: linear-gradient(135deg, #27ae60, #2ecc71);
            border: none;
            border-radius: 10px;
            padding: 0.75rem 2rem;
            font-weight: 600;
            color: white;
            transition: all 0.3s ease;
        }
        
        .btn-save:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(39, 174, 96, 0.4);
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
        }
        
        .btn-cancel:hover {
            background: #5a6268;
            color: white;
        }
        
        .section-title {
            color: #2c3e50;
            font-weight: 600;
            margin-bottom: 1.5rem;
            padding-bottom: 0.5rem;
            border-bottom: 2px solid #3498db;
        }
    </style>
</head>
<body>
    <!-- Edit Header -->
    <div class="edit-header">
        <div class="container">
            <div class="row align-items-center">
                <div class="col-md-8">
                    <h1 class="mb-2">
                        <i class="fas fa-user-edit me-3"></i>Chỉnh sửa hồ sơ
                    </h1>
                    <p class="mb-0">Cập nhật thông tin cá nhân của bạn</p>
                </div>
                <div class="col-md-4 text-md-end">
                    <a href="/users/profile" class="btn btn-outline-light">
                        <i class="fas fa-arrow-left me-2"></i>Quay lại hồ sơ
                    </a>
                </div>
            </div>
        </div>
    </div>

    <div class="container">
        <div class="row justify-content-center">
            <div class="col-lg-8">
                <div class="edit-card">
                    <form action="/users/edit" method="post" id="editForm" enctype="multipart/form-data">
                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                        <input type="hidden" name="id" value="${user.id}"/>
                        
                        <!-- Avatar Section -->
                        <div class="text-center mb-4">
                            <h5 class="section-title text-center">Ảnh đại diện</h5>
                            <div class="avatar-upload">
                                <c:choose>
                                    <c:when test="${not empty user.avatarUrl}">
                                        <img src="${user.avatarUrl}" alt="Avatar" class="avatar-preview" id="avatarPreview">
                                    </c:when>
                                    <c:otherwise>
                                        <div class="avatar-placeholder" id="avatarPreview">
                                            <i class="fas fa-user fa-3x"></i>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                                <div class="avatar-overlay" onclick="document.getElementById('avatarInput').click()">
                                    <i class="fas fa-camera fa-2x text-white"></i>
                                </div>
                                <input type="file" id="avatarInput" name="avatarFile" accept="image/*" onchange="previewAvatar(this)">
                            </div>
                            <div class="text-muted small">Nhấp để thay đổi ảnh đại diện</div>
                        </div>
                        
                        <!-- Basic Information -->
                        <h5 class="section-title">Thông tin cơ bản</h5>
                        <div class="row">
                            <div class="col-md-6">
                                <div class="form-floating">
                                    <input type="text" class="form-control" id="fullName" name="fullName" 
                                           value="${user.fullName}" placeholder="Họ và tên" required maxlength="100">
                                    <label for="fullName">
                                        <i class="fas fa-id-card me-2"></i>Họ và tên
                                    </label>
                                </div>
                            </div>
                            
                            <div class="col-md-6">
                                <div class="form-floating">
                                    <input type="tel" class="form-control" id="phone" name="phone" 
                                           value="${user.phone}" placeholder="Số điện thoại" maxlength="15">
                                    <label for="phone">
                                        <i class="fas fa-phone me-2"></i>Số điện thoại
                                    </label>
                                </div>
                            </div>
                            
                            <div class="col-md-6">
                                <div class="form-floating">
                                    <input type="date" class="form-control" id="dateOfBirth" name="dateOfBirth"
                                           value="${user.dateOfBirth}">
                                    <label for="dateOfBirth">
                                        <i class="fas fa-birthday-cake me-2"></i>Ngày sinh
                                    </label>
                                </div>
                            </div>
                            
                            <div class="col-md-6">
                                <div class="form-floating">
                                    <select class="form-select" id="gender" name="gender">
                                        <option value="">Chọn giới tính</option>
                                        <option value="MALE" ${user.gender == 'MALE' ? 'selected' : ''}>Nam</option>
                                        <option value="FEMALE" ${user.gender == 'FEMALE' ? 'selected' : ''}>Nữ</option>
                                        <option value="OTHER" ${user.gender == 'OTHER' ? 'selected' : ''}>Khác</option>
                                        <option value="PREFER_NOT_TO_SAY" ${user.gender == 'PREFER_NOT_TO_SAY' ? 'selected' : ''}>Không muốn tiết lộ</option>
                                    </select>
                                    <label for="gender">
                                        <i class="fas fa-venus-mars me-2"></i>Giới tính
                                    </label>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Account Information (Read-only) -->
                        <h5 class="section-title mt-4">Thông tin tài khoản</h5>
                        <div class="row">
                            <div class="col-md-6">
                                <div class="form-floating">
                                    <input type="text" class="form-control" value="${user.username}" readonly>
                                    <label>
                                        <i class="fas fa-user me-2"></i>Tên đăng nhập
                                    </label>
                                    <div class="form-text">Tên đăng nhập không thể thay đổi</div>
                                </div>
                            </div>
                            
                            <div class="col-md-6">
                                <div class="form-floating">
                                    <input type="email" class="form-control" value="${user.email}" readonly>
                                    <label>
                                        <i class="fas fa-envelope me-2"></i>Email
                                    </label>
                                    <div class="form-text">Email không thể thay đổi</div>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Account Status -->
                        <div class="row mt-3">
                            <div class="col-md-6">
                                <div class="form-floating">
                                    <input type="text" class="form-control"
                                           value="${fn:substring(user.createdAt.toString().replace('T', ' '), 0, 16)}" readonly>
                                    <label>
                                        <i class="fas fa-calendar-plus me-2"></i>Ngày tham gia
                                    </label>
                                </div>
                            </div>
                            
                            <div class="col-md-6">
                                <div class="form-floating">
                                    <input type="text" class="form-control" 
                                           value="${user.status == 'ACTIVE' && user.enabled ? 'Hoạt động' : 'Không hoạt động'}" readonly>
                                    <label>
                                        <i class="fas fa-info-circle me-2"></i>Trạng thái
                                    </label>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Action Buttons -->
                        <div class="d-flex justify-content-between mt-4 pt-3 border-top">
                            <a href="/users/profile" class="btn btn-cancel">
                                <i class="fas fa-times me-2"></i>Hủy bỏ
                            </a>
                            <button type="submit" class="btn btn-save">
                                <i class="fas fa-save me-2"></i>Lưu thay đổi
                            </button>
                        </div>
                    </form>
                </div>
                
                <!-- Additional Actions -->
                <div class="edit-card">
                    <h5 class="section-title">Thao tác khác</h5>
                    <div class="row">
                        <div class="col-md-6">
                            <a href="/users/change-password" class="btn btn-outline-warning w-100 mb-2">
                                <i class="fas fa-key me-2"></i>Đổi mật khẩu
                            </a>
                        </div>
                        <div class="col-md-6">
                            <a href="/users/security" class="btn btn-outline-info w-100 mb-2">
                                <i class="fas fa-shield-alt me-2"></i>Cài đặt bảo mật
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    
    <script>
        // Preview avatar
        function previewAvatar(input) {
            if (input.files && input.files[0]) {
                const reader = new FileReader();
                reader.onload = function(e) {
                    const preview = document.getElementById('avatarPreview');
                    preview.innerHTML = `<img src="${e.target.result}" class="avatar-preview">`;
                };
                reader.readAsDataURL(input.files[0]);
            }
        }
        
        // Form validation
        document.getElementById('editForm').addEventListener('submit', function(e) {
            const fullName = document.getElementById('fullName').value.trim();
            
            if (fullName === '') {
                e.preventDefault();
                alert('Vui lòng nhập họ và tên');
                document.getElementById('fullName').focus();
                return;
            }
            
            // Show loading state
            const submitBtn = this.querySelector('button[type="submit"]');
            const originalText = submitBtn.innerHTML;
            submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>Đang lưu...';
            submitBtn.disabled = true;
            
            // Re-enable button after 5 seconds (in case of error)
            setTimeout(function() {
                submitBtn.innerHTML = originalText;
                submitBtn.disabled = false;
            }, 5000);
        });
        
        // Phone number formatting
        document.getElementById('phone').addEventListener('input', function(e) {
            let value = e.target.value.replace(/\D/g, '');
            if (value.length > 0) {
                if (value.startsWith('84')) {
                    value = '+' + value;
                } else if (value.startsWith('0')) {
                    value = '+84' + value.substring(1);
                }
            }
            e.target.value = value;
        });
    </script>
</body>
</html>
