<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
            <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

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

                    <!-- Main Content Area -->
                    <div class="content" id="content">
                        <!-- Page Content will be inserted here -->

                        <body>

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
                                                    <h4><i class="fas fa-user-circle text-primary"></i> Thông
                                                        tin cơ bản
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
                                                                    <c:otherwise><span class="text-muted">Chưa
                                                                            cập
                                                                            nhật</span></c:otherwise>
                                                                </c:choose>
                                                            </div>
                                                        </div>
                                                        <div class="col-md-6 mb-3">
                                                            <label class="form-label">Số điện thoại</label>
                                                            <div class="form-control-plaintext border rounded p-2">
                                                                <i class="fas fa-phone me-2 text-info"></i>
                                                                <c:choose>
                                                                    <c:when test="${not empty user.phone}">
                                                                        ${user.phone}
                                                                    </c:when>
                                                                    <c:otherwise><span class="text-muted">Chưa
                                                                            cập
                                                                            nhật</span></c:otherwise>
                                                                </c:choose>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>

                                                <!-- Personal Information Section -->
                                                <div class="form-section">
                                                    <h4><i class="fas fa-id-card text-info"></i> Thông tin cá
                                                        nhân</h4>
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
                                                                        <span class="text-muted">Chưa cập
                                                                            nhật</span>
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
                                                                    <c:when test="${user.gender == 'MALE'}">Nam
                                                                    </c:when>
                                                                    <c:when test="${user.gender == 'FEMALE'}">Nữ
                                                                    </c:when>
                                                                    <c:when test="${user.gender == 'OTHER'}">
                                                                        Khác
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <span class="text-muted">Chưa cập
                                                                            nhật</span>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>

                                                <!-- Account Status Section -->
                                                <div class="form-section">
                                                    <h4><i class="fas fa-shield-alt text-warning"></i> Trạng
                                                        thái tài
                                                        khoản</h4>
                                                    <div class="row">
                                                        <div class="col-md-6 mb-3">
                                                            <label class="form-label">Trạng thái</label>
                                                            <div>
                                                                <span
                                                                    class="status-badge ${user.status == 'ACTIVE' ? 'status-active' : (user.status == 'INACTIVE' ? 'status-inactive' : 'status-suspended')}">
                                                                    <i class="fas fa-circle"></i>
                                                                    <c:choose>
                                                                        <c:when test="${user.status == 'ACTIVE'}">
                                                                            Hoạt
                                                                            động</c:when>
                                                                        <c:when test="${user.status == 'INACTIVE'}">
                                                                            Không hoạt động</c:when>
                                                                        <c:when test="${user.status == 'SUSPENDED'}">
                                                                            Bị
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
                                                        <p class="text-muted small">Cập nhật thông tin cá nhân
                                                        </p>
                                                        <button type="button" class="btn btn-outline-primary btn-sm"
                                                            data-bs-toggle="modal"
                                                            data-bs-target="#editProfileModal">Chỉnh
                                                            sửa</button>
                                                    </div>
                                                    <div class="action-card">
                                                        <div class="action-icon text-warning">
                                                            <i class="fas fa-key"></i>
                                                        </div>
                                                        <h6>Đổi mật khẩu</h6>
                                                        <p class="text-muted small">Thay đổi mật khẩu đăng nhập
                                                        </p>
                                                        <a href="#" class="btn btn-outline-warning btn-sm">Đổi
                                                            mật
                                                            khẩu</a>
                                                    </div>
                                                    <div class="action-card">
                                                        <div class="action-icon text-success">
                                                            <i class="fas fa-shopping-bag"></i>
                                                        </div>
                                                        <h6>Đơn hàng</h6>
                                                        <p class="text-muted small">Xem lịch sử đơn hàng</p>
                                                        <a href="/user/orders"
                                                            class="btn btn-outline-success btn-sm">Xem đơn
                                                            hàng</a>
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
                                                            <i class="fas fa-user me-2 text-muted"></i>Tên đăng
                                                            nhập
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
                                                            <i class="fas fa-id-card me-2 text-success"></i>Họ
                                                            và tên
                                                        </label>
                                                        <input type="text" class="form-control" id="fullName"
                                                            name="fullName" value="${user.fullName}">
                                                    </div>

                                                    <!-- Phone -->
                                                    <div class="col-md-6 mb-3">
                                                        <label for="phone" class="form-label">
                                                            <i class="fas fa-phone me-2 text-info"></i>Số điện
                                                            thoại
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
                                                            <i class="fas fa-venus-mars me-2 text-purple"></i>Giới
                                                            tính
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
                            <jsp:include page="../common/footer.jsp" />
                        </body>



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

                        <!-- Common JavaScript -->
                        <script>
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
                        </script>
                </body>

                </html>