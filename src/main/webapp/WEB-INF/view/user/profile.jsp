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

                                    <!-- View Mode Section -->
                                    <div id="viewMode">
                                        <!-- Basic Information Section -->
                                        <div class="form-section">
                                            <h4><i class="fas fa-user-circle text-primary"></i> Thông tin cơ
                                                bản</h4>
                                            <div class="row">
                                                <div class="col-md-6 mb-3">
                                                    <label class="form-label">Tên đăng nhập</label>
                                                    <div class="form-control-plaintext border rounded p-2 bg-light">
                                                        <i class="fas fa-user me-2"></i>${user.username}
                                                    </div>
                                                </div>
                                                <div class="col-md-6 mb-3">
                                                    <label class="form-label">Email</label>
                                                    <div class="form-control-plaintext border rounded p-2 bg-light">
                                                        <i class="fas fa-envelope me-2 text-primary"></i>${user.email}
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
                                                                ${user.fullName}
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="text-muted">Chưa cập
                                                                    nhật</span>
                                                            </c:otherwise>
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
                                                            <c:otherwise>
                                                                <span class="text-muted">Chưa cập
                                                                    nhật</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>

                                        <!-- Personal Information Section -->
                                        <div class="form-section">
                                            <h4><i class="fas fa-id-card text-info"></i> Thông tin cá nhân
                                            </h4>
                                            <div class="row">
                                                <div class="col-md-6 mb-3">
                                                    <label class="form-label">Ngày sinh</label>
                                                    <div class="form-control-plaintext border rounded p-2">
                                                        <i class="fas fa-birthday-cake me-2 text-warning"></i>
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
                                                        <c:choose>
                                                            <c:when test="${user.gender == 'MALE'}">Nam
                                                            </c:when>
                                                            <c:when test="${user.gender == 'FEMALE'}">Nữ
                                                            </c:when>
                                                            <c:when test="${user.gender == 'OTHER'}">Khác
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

                                        <!-- Edit Button -->
                                        <div class="d-flex justify-content-end mb-3">
                                            <button type="button" class="btn btn-outline-primary"
                                                onclick="toggleEditMode()">
                                                <i class="fas fa-edit"></i> Chỉnh sửa
                                            </button>
                                        </div>
                                    </div>

                                    <!-- Edit Form -->
                                    <form id="profileForm" action="/user/profile/update" method="POST"
                                        style="display: none;">
                                        <sec:csrfInput />
                                        <input type="hidden" name="email" value="${user.email}">

                                        <!-- Basic Information Section -->
                                        <div class="form-section">
                                            <h4><i class="fas fa-user-circle text-primary"></i> Thông tin cơ
                                                bản</h4>
                                            <div class="row">
                                                <div class="col-md-6 mb-3">
                                                    <label class="form-label">Họ và tên</label>
                                                    <div class="input-group">
                                                        <span class="input-group-text">
                                                            <i class="fas fa-id-card text-success"></i>
                                                        </span>
                                                        <input type="text" class="form-control" name="fullName"
                                                            value="${user.fullName}" placeholder="Nhập họ và tên">
                                                    </div>
                                                </div>
                                                <div class="col-md-6 mb-3">
                                                    <label class="form-label">Số điện thoại</label>
                                                    <div class="input-group">
                                                        <span class="input-group-text">
                                                            <i class="fas fa-phone text-info"></i>
                                                        </span>
                                                        <input type="tel" class="form-control" name="phone"
                                                            value="${user.phone}" placeholder="Nhập số điện thoại">
                                                    </div>
                                                </div>
                                            </div>
                                        </div>

                                        <!-- Personal Information Section -->
                                        <div class="form-section">
                                            <h4><i class="fas fa-id-card text-info"></i> Thông tin cá nhân
                                            </h4>
                                            <div class="row">
                                                <div class="col-md-6 mb-3">
                                                    <label class="form-label">Ngày sinh</label>
                                                    <div class="input-group">
                                                        <span class="input-group-text">
                                                            <i class="fas fa-birthday-cake text-warning"></i>
                                                        </span>
                                                        <input type="date" class="form-control" name="dateOfBirth"
                                                            value="${user.dateOfBirth}">
                                                    </div>
                                                </div>
                                                <div class="col-md-6 mb-3">
                                                    <label class="form-label">Giới tính</label>
                                                    <div class="input-group">
                                                        <span class="input-group-text">
                                                            <i class="fas fa-venus-mars text-purple"></i>
                                                        </span>
                                                        <select class="form-select" name="gender">
                                                            <option value="MALE" ${user.gender=='MALE' ? 'selected' : ''
                                                                }>Nam</option>
                                                            <option value="FEMALE" ${user.gender=='FEMALE' ? 'selected'
                                                                : '' }>Nữ</option>
                                                            <option value="OTHER" ${user.gender=='OTHER' ? 'selected'
                                                                : '' }>Khác</option>
                                                        </select>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>

                                        <!-- Action Buttons -->
                                        <div class="d-flex justify-content-end mb-3">
                                            <button type="submit" class="btn btn-success me-2">
                                                <i class="fas fa-save"></i> Lưu
                                            </button>
                                            <button type="button" class="btn btn-secondary" onclick="cancelEdit()">
                                                <i class="fas fa-times"></i> Hủy
                                            </button>
                                        </div>
                                    </form>
                                    <!-- Script toggleEditMode/cancelEdit đơn giản -->
                                    <script>
                                        function toggleEditMode() {
                                            var viewMode = document.getElementById('viewMode');
                                            var profileForm = document.getElementById('profileForm');
                                            if (viewMode && profileForm) {
                                                viewMode.style.display = 'none';
                                                profileForm.style.display = 'block';
                                            }
                                        }
                                        function cancelEdit() {
                                            var viewMode = document.getElementById('viewMode');
                                            var profileForm = document.getElementById('profileForm');
                                            if (viewMode && profileForm) {
                                                viewMode.style.display = 'block';
                                                profileForm.style.display = 'none';
                                            }
                                        }
                                    </script>


                                </div>


                            </div>
                        </div>
                    </div>
                </div>
                <script>


                    // Format date to dd/MM/yyyy
                    function formatDate(date) {
                        if (!date) return '';
                        const d = new Date(date);
                        if (isNaN(d.getTime())) return '';
                        const day = String(d.getDate()).padStart(2, '0');
                        const month = String(d.getMonth() + 1).padStart(2, '0');
                        const year = d.getFullYear();
                        return `${day}/${month}/${year}`;
                    }

                    // Parse date from dd/MM/yyyy to yyyy-MM-dd
                    function parseDate(dateStr) {
                        if (!dateStr) return '';
                        const [day, month, year] = dateStr.split('/');
                        return `${year}-${month.padStart(2, '0')}-${day.padStart(2, '0')}`;
                    }

                    // Store original values
                    let originalValues = {};



                    // Submit form handler
                    document.getElementById('profileForm').addEventListener('submit', function (e) {
                        // Xử lý ngày sinh trước khi submit nếu cần
                        const dateOfBirthInput = document.getElementById('dateOfBirth');
                        if (dateOfBirthInput && dateOfBirthInput.value) {
                            // Đảm bảo định dạng yyyy-MM-dd
                            const date = new Date(dateOfBirthInput.value);
                            if (!isNaN(date.getTime())) {
                                dateOfBirthInput.value = date.toISOString().split('T')[0];
                            }
                        }
                    });


                    // Password change function
                    function togglePasswordModal() {
                        // Implementation for password change modal
                    }

                    // Check URL parameters for success/error messages
                    document.addEventListener('DOMContentLoaded', function () {
                        // Format ngày sinh khi trang load
                        const dateOfBirthInput = document.getElementById('dateOfBirth');
                        if (dateOfBirthInput && dateOfBirthInput.value) {
                            // Đảm bảo ngày sinh được hiển thị đúng định dạng trong input
                            const formattedDate = new Date(dateOfBirthInput.value).toISOString().split('T')[0];
                            dateOfBirthInput.value = formattedDate;
                        }

                        // Check URL parameters for messages
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
                <div class="modal fade" id="editProfileModal" tabindex="-1" aria-labelledby="editProfileModalLabel"
                    aria-hidden="true">
                    <div class="modal-dialog modal-lg">
                        <div class="modal-content">
                            <div class="modal-header bg-primary text-white">
                                <h5 class="modal-title" id="editProfileModalLabel">
                                    <i class="fas fa-edit me-2"></i>Chỉnh sửa thông tin cá nhân
                                </h5>
                                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"
                                    aria-label="Close"></button>
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
                                            <input type="text" class="form-control" id="username" name="username"
                                                value="${user.username}" readonly style="background-color: #f8f9fa;">
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
                                            <input type="text" class="form-control" id="fullName" name="fullName"
                                                value="${user.fullName}">
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
                                            <input type="date" class="form-control" id="dateOfBirth" name="dateOfBirth"
                                                value="${user.dateOfBirth}">
                                        </div>

                                        <!-- Gender -->
                                        <div class="col-md-6 mb-3">
                                            <label for="gender" class="form-label">
                                                <i class="fas fa-venus-mars me-2 text-purple"></i>Giới
                                                tính
                                            </label>
                                            <select class="form-select" id="gender" name="gender">
                                                <option value="">Chọn giới tính</option>
                                                <option value="MALE" ${user.gender=='MALE' ? 'selected' : '' }>
                                                    Nam</option>
                                                <option value="FEMALE" ${user.gender=='FEMALE' ? 'selected' : '' }>
                                                    Nữ</option>
                                                <option value="OTHER" ${user.gender=='OTHER' ? 'selected' : '' }>
                                                    Khác</option>
                                            </select>
                                        </div>
                                    </div>
                                    <div class="modal-footer">
                                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
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