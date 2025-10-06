<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
            <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
                <html lang="en">

                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>Thông tin cá nhân</title>



                    </script>- Latest compiled and minified CSS -->
                    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css"
                        rel="stylesheet">

                    <!-- Latest compiled JavaScript -->
                    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

                    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>

                    <!-- Font Awesome for icons -->
                    <link rel="stylesheet"
                        href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

                    <!-- iziToast CSS -->
                    <link rel="stylesheet"
                        href="https://cdnjs.cloudflare.com/ajax/libs/izitoast/1.4.0/css/iziToast.min.css" />

                    <style>
                        /* Content styling */
                        .content {
                            flex-grow: 1;
                            padding: 20px;
                            background-color: #ecf0f1;
                            margin-left: 0;
                            transition: margin-left 0.3s ease;
                            margin-top: 70px;
                            /* Account for fixed navbar */
                        }

                        .content.shifted {
                            margin-left: 250px;
                        }

                        .content h1 {
                            font-size: 28px;
                            color: #2c3e50;
                        }

                        /* Profile card styling */
                        .profile-card {
                            background: white;
                            border-radius: 15px;
                            padding: 30px;
                            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
                            margin-bottom: 20px;
                        }

                        .profile-header {
                            text-align: center;
                            margin-bottom: 30px;
                            padding-bottom: 20px;
                            border-bottom: 2px solid #ecf0f1;
                        }

                        .profile-avatar {
                            width: 120px;
                            height: 120px;
                            border-radius: 50%;
                            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            margin: 0 auto 15px;
                            font-size: 48px;
                            color: white;
                        }

                        .form-section {
                            margin-bottom: 25px;
                            padding: 20px;
                            background: #f8f9fa;
                            border-radius: 10px;
                            border-left: 4px solid #3498db;
                        }

                        .form-section h4 {
                            margin-bottom: 20px;
                            color: #2c3e50;
                            font-weight: 600;
                        }

                        .form-control-plaintext {
                            background-color: white;
                            color: #495057;
                            font-weight: 500;
                        }

                        .status-badge {
                            padding: 8px 16px;
                            border-radius: 20px;
                            font-weight: 600;
                            font-size: 14px;
                        }

                        .status-active {
                            background-color: #d4edda;
                            color: #155724;
                        }

                        .status-inactive {
                            background-color: #f8d7da;
                            color: #721c24;
                        }

                        .status-suspended {
                            background-color: #fff3cd;
                            color: #856404;
                        }

                        /* Quick actions */
                        .quick-actions {
                            display: flex;
                            gap: 15px;
                            justify-content: center;
                            margin-top: 20px;
                        }

                        .action-card {
                            background: white;
                            border-radius: 10px;
                            padding: 20px;
                            text-align: center;
                            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.08);
                            transition: transform 0.3s ease;
                            flex: 1;
                            max-width: 200px;
                        }

                        .action-card:hover {
                            transform: translateY(-5px);
                        }

                        .action-icon {
                            font-size: 32px;
                            margin-bottom: 10px;
                        }

                        .text-purple {
                            color: #9b59b6;
                        }

                        /* Modal styling */
                        .modal-header {
                            border-bottom: 1px solid #dee2e6;
                        }

                        .modal-body {
                            padding: 2rem;
                        }

                        .modal-footer {
                            border-top: 1px solid #dee2e6;
                            padding: 1rem 2rem;
                        }

                        .form-label {
                            font-weight: 600;
                            color: #495057;
                            margin-bottom: 0.5rem;
                        }

                        .form-control:focus,
                        .form-select:focus {
                            border-color: #80bdff;
                            box-shadow: 0 0 0 0.2rem rgba(0, 123, 255, 0.25);
                        }

                        .is-valid {
                            border-color: #28a745;
                        }

                        .is-invalid {
                            border-color: #dc3545;
                        }

                        .btn-primary {
                            background-color: #007bff;
                            border-color: #007bff;
                        }

                        .btn-primary:hover {
                            background-color: #0056b3;
                            border-color: #004085;
                        }

                        /* Responsive */
                        @media (max-width: 768px) {
                            .quick-actions {
                                flex-direction: column;
                                align-items: center;
                            }

                            .action-card {
                                max-width: 100%;
                                margin-bottom: 10px;
                            }

                            .modal-body {
                                padding: 1rem;
                            }

                            .modal-footer {
                                padding: 1rem;
                            }
                        }
                    </style>
                </head>

                <body>
                    <!-- Include common components -->
                    <%@ include file="../common/navbar.jsp" %>
                        <%@ include file="../common/sidebar.jsp" %>

                            <div class="content" id="content">
                                <div class="container-fluid">
                                    <div class="row justify-content-center">
                                        <div class="col-lg-8">
                                            <!-- Profile Header -->
                                            <div class="profile-card">
                                                <div class="profile-header">
                                                    <div class="profile-avatar">
                                                        <i class="fas fa-user"></i>
                                                    </div>
                                                    <h2>${user.fullName != null ? user.fullName :
                                                        user.username}</h2>
                                                    <p class="text-muted">
                                                        <i class="fas fa-envelope me-2"></i>${user.email}
                                                    </p>
                                                </div>

                                                <!-- Basic Information Section -->
                                                <div class="form-section">
                                                    <h4><i class="fas fa-user-circle text-primary"></i> Thông tin cơ bản
                                                    </h4>
                                                    <div class="row">
                                                        <div class="col-md-6 mb-3">
                                                            <label class="form-label">Tên đăng nhập</label>
                                                            <div
                                                                class="form-control-plaintext border rounded p-2 bg-light">
                                                                <i class="fas fa-user me-2"></i>${user.username}
                                                            </div>
                                                        </div>
                                                        <div class="col-md-6 mb-3">
                                                            <label class="form-label">Email</label>
                                                            <div class="form-control-plaintext border rounded p-2">
                                                                <i
                                                                    class="fas fa-envelope me-2 text-primary"></i>${user.email}
                                                            </div>
                                                        </div>
                                                    </div>
                                                    <div class="row">
                                                        <div class="col-md-6 mb-3">
                                                            <label class="form-label">Họ và tên</label>
                                                            <div class="form-control-plaintext border rounded p-2">
                                                                <i class="fas fa-id-card me-2 text-success"></i>
                                                                <c:choose>
                                                                    <c:when test="${not empty user.fullName}">
                                                                        ${user.fullName}</c:when>
                                                                    <c:otherwise><span class="text-muted">Chưa cập
                                                                            nhật</span></c:otherwise>
                                                                </c:choose>
                                                            </div>
                                                        </div>
                                                        <div class="col-md-6 mb-3">
                                                            <label class="form-label">Số điện thoại</label>
                                                            <div class="form-control-plaintext border rounded p-2">
                                                                <i class="fas fa-phone me-2 text-info"></i>
                                                                <c:choose>
                                                                    <c:when test="${not empty user.phone}">${user.phone}
                                                                    </c:when>
                                                                    <c:otherwise><span class="text-muted">Chưa cập
                                                                            nhật</span></c:otherwise>
                                                                </c:choose>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>

                                                <!-- Personal Information Section -->
                                                <div class="form-section">
                                                    <h4><i class="fas fa-id-card text-info"></i> Thông tin cá nhân</h4>
                                                    <div class="row">
                                                        <div class="col-md-6 mb-3">
                                                            <label class="form-label">Ngày sinh</label>
                                                            <div class="form-control-plaintext border rounded p-2">
                                                                <i class="fas fa-birthday-cake me-2 text-warning"></i>
                                                                <!-- Debug: ${user.dateOfBirth} -->
                                                                <c:choose>
                                                                    <c:when test="${user.dateOfBirth != null}">
                                                                        ${user.dateOfBirth}
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <span class="text-muted">Chưa cập nhật</span>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </div>
                                                        </div>
                                                        <div class="col-md-6 mb-3">
                                                            <label class="form-label">Giới tính</label>
                                                            <div class="form-control-plaintext border rounded p-2">
                                                                <i class="fas fa-venus-mars me-2 text-purple"></i>
                                                                <!-- Debug: ${user.gender} -->
                                                                <c:choose>
                                                                    <c:when test="${user.gender == 'MALE'}">Nam</c:when>
                                                                    <c:when test="${user.gender == 'FEMALE'}">Nữ
                                                                    </c:when>
                                                                    <c:when test="${user.gender == 'OTHER'}">Khác
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <span class="text-muted">Chưa cập nhật</span>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>

                                                <!-- Account Status Section -->
                                                <div class="form-section">
                                                    <h4><i class="fas fa-shield-alt text-warning"></i> Trạng thái tài
                                                        khoản</h4>
                                                    <div class="row">
                                                        <div class="col-md-6 mb-3">
                                                            <label class="form-label">Trạng thái</label>
                                                            <div>
                                                                <span
                                                                    class="status-badge ${user.status == 'ACTIVE' ? 'status-active' : (user.status == 'INACTIVE' ? 'status-inactive' : 'status-suspended')}">
                                                                    <i class="fas fa-circle"></i>
                                                                    <c:choose>
                                                                        <c:when test="${user.status == 'ACTIVE'}">Hoạt
                                                                            động</c:when>
                                                                        <c:when test="${user.status == 'INACTIVE'}">
                                                                            Không hoạt động</c:when>
                                                                        <c:when test="${user.status == 'SUSPENDED'}">Bị
                                                                            tạm khóa</c:when>
                                                                        <c:otherwise>Bị cấm</c:otherwise>
                                                                    </c:choose>
                                                                </span>
                                                            </div>
                                                        </div>
                                                        <div class="col-md-6 mb-3">
                                                            <label class="form-label">Vai trò</label>
                                                            <div>
                                                                <c:forEach var="role" items="${user.roles}"
                                                                    varStatus="status">
                                                                    <span
                                                                        class="badge bg-primary me-1">${role.name}</span>
                                                                </c:forEach>
                                                            </div>
                                                        </div>
                                                    </div>

                                                </div>


                                            </div>

                                            <!-- Quick Actions -->
                                            <div class="profile-card">
                                                <h4 class="text-center mb-4"><i class="fas fa-rocket text-primary"></i>
                                                    Thao tác nhanh</h4>
                                                <div class="quick-actions">
                                                    <div class="action-card">
                                                        <div class="action-icon text-primary">
                                                            <i class="fas fa-edit"></i>
                                                        </div>
                                                        <h6>Chỉnh sửa</h6>
                                                        <p class="text-muted small">Cập nhật thông tin cá nhân</p>
                                                        <button type="button" class="btn btn-outline-primary btn-sm"
                                                            data-bs-toggle="modal"
                                                            data-bs-target="#editProfileModal">Chỉnh sửa</button>
                                                    </div>
                                                    <div class="action-card">
                                                        <div class="action-icon text-warning">
                                                            <i class="fas fa-key"></i>
                                                        </div>
                                                        <h6>Đổi mật khẩu</h6>
                                                        <p class="text-muted small">Thay đổi mật khẩu đăng nhập</p>
                                                        <a href="#" class="btn btn-outline-warning btn-sm">Đổi mật
                                                            khẩu</a>
                                                    </div>
                                                    <div class="action-card">
                                                        <div class="action-icon text-success">
                                                            <i class="fas fa-shopping-bag"></i>
                                                        </div>
                                                        <h6>Đơn hàng</h6>
                                                        <p class="text-muted small">Xem lịch sử đơn hàng</p>
                                                        <a href="/user/orders"
                                                            class="btn btn-outline-success btn-sm">Xem đơn hàng</a>
                                                    </div>
                                                    <div class="action-card">
                                                        <div class="action-icon text-info">
                                                            <i class="fas fa-wallet"></i>
                                                        </div>
                                                        <h6>Ví tiền</h6>
                                                        <p class="text-muted small">Quản lý ví và giao dịch</p>
                                                        <a href="/wallet/detail" class="btn btn-outline-info btn-sm">Xem
                                                            ví</a>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- iziToast JS -->
                            <script
                                src="https://cdnjs.cloudflare.com/ajax/libs/izitoast/1.4.0/js/iziToast.min.js"></script>

                            <script>
                                // Toggle sidebar function (if needed by common navbar/sidebar)
                                function toggleSidebar() {
                                    const sidebar = document.getElementById('sidebar');
                                    const content = document.getElementById('content');

                                    if (sidebar) {
                                        sidebar.classList.toggle('active');
                                        content.classList.toggle('shifted');
                                    }
                                }

                                // Check URL parameters for success/error messages
                                document.addEventListener('DOMContentLoaded', function () {
                                    const urlParams = new URLSearchParams(window.location.search);
                                    if (urlParams.get('success') === 'true') {
                                        iziToast.success({
                                            title: 'Thành công!',
                                            message: 'Cập nhật thông tin thành công!',
                                            position: 'topRight',
                                            timeout: 3000
                                        });
                                    } else if (urlParams.get('error') === 'true') {
                                        iziToast.error({
                                            title: 'Lỗi!',
                                            message: 'Có lỗi xảy ra khi cập nhật thông tin!',
                                            position: 'topRight',
                                            timeout: 5000
                                        });
                                    }
                                });

                            </script>

                            <!-- Edit Profile Modal -->
                            <div class="modal fade" id="editProfileModal" tabindex="-1"
                                aria-labelledby="editProfileModalLabel" aria-hidden="true">
                                <div class="modal-dialog modal-lg">
                                    <div class="modal-content">
                                        <div class="modal-header bg-primary text-white">
                                            <h5 class="modal-title" id="editProfileModalLabel">
                                                <i class="fas fa-edit me-2"></i>Chỉnh sửa thông tin cá nhân
                                            </h5>
                                            <button type="button" class="btn-close btn-close-white"
                                                data-bs-dismiss="modal" aria-label="Close"></button>
                                        </div>
                                        <div class="modal-body">
                                            <form id="editProfileForm" action="/user/profile/update" method="POST">
                                                <div class="row">
                                                    <!-- Username (Read-only) -->
                                                    <div class="col-md-6 mb-3">
                                                        <label for="username" class="form-label">
                                                            <i class="fas fa-user me-2 text-muted"></i>Tên đăng nhập
                                                        </label>
                                                        <input type="text" class="form-control" id="username"
                                                            name="username" value="${user.username}" readonly
                                                            style="background-color: #f8f9fa;">
                                                    </div>

                                                    <!-- Email -->
                                                    <div class="col-md-6 mb-3">
                                                        <label for="email" class="form-label">
                                                            <i class="fas fa-envelope me-2 text-primary"></i>Email
                                                        </label>
                                                        <input type="email" class="form-control" id="email" name="email"
                                                            value="${user.email}">
                                                    </div>
                                                </div>

                                                <div class="row">
                                                    <!-- Full Name -->
                                                    <div class="col-md-6 mb-3">
                                                        <label for="fullName" class="form-label">
                                                            <i class="fas fa-id-card me-2 text-success"></i>Họ và tên
                                                        </label>
                                                        <input type="text" class="form-control" id="fullName"
                                                            name="fullName" value="${user.fullName}">
                                                    </div>

                                                    <!-- Phone -->
                                                    <div class="col-md-6 mb-3">
                                                        <label for="phone" class="form-label">
                                                            <i class="fas fa-phone me-2 text-info"></i>Số điện thoại
                                                        </label>
                                                        <input type="tel" class="form-control" id="phone" name="phone"
                                                            value="${user.phone}">
                                                    </div>
                                                </div>

                                                <div class="row">
                                                    <!-- Date of Birth -->
                                                    <div class="col-md-6 mb-3">
                                                        <label for="dateOfBirth" class="form-label">
                                                            <i class="fas fa-birthday-cake me-2 text-warning"></i>Ngày
                                                            sinh
                                                        </label>
                                                        <input type="date" class="form-control" id="dateOfBirth"
                                                            name="dateOfBirth" value="${user.dateOfBirth}">
                                                    </div>

                                                    <!-- Gender -->
                                                    <div class="col-md-6 mb-3">
                                                        <label for="gender" class="form-label">
                                                            <i class="fas fa-venus-mars me-2 text-purple"></i>Giới tính
                                                        </label>
                                                        <select class="form-select" id="gender" name="gender">
                                                            <option value="">Chọn giới tính</option>
                                                            <option value="MALE" ${user.gender=='MALE' ? 'selected' : ''
                                                                }>Nam</option>
                                                            <option value="FEMALE" ${user.gender=='FEMALE' ? 'selected'
                                                                : '' }>Nữ</option>
                                                            <option value="OTHER" ${user.gender=='OTHER' ? 'selected'
                                                                : '' }>Khác</option>
                                                        </select>
                                                    </div>
                                                </div>
                                                <div class="modal-footer">
                                                    <button type="button" class="btn btn-secondary"
                                                        data-bs-dismiss="modal">
                                                        <i class="fas fa-times me-2"></i>Hủy
                                                    </button>
                                                    <button type="submit" class="btn btn-primary" id="updateProfileBtn">
                                                        <i class="fas fa-save me-2"></i>Cập nhật
                                                    </button>
                                                </div>
                                            </form>
                                        </div>

                                    </div>
                                </div>
                            </div>

                            <!-- Include Footer -->
                            <%@ include file="../common/footer.jsp" %>
                </body>

                </html>