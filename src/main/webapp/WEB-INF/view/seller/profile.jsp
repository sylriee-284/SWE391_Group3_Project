<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
            <%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>

                <!DOCTYPE html>
                <html lang="en">

                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>Profile Seller - MMO Market System</title>

                    <!-- Include common head with all CSS and JS -->
                    <jsp:include page="../common/head.jsp" />

                    <style>
                        .profile-card {
                            background: #fff;
                            border-radius: 15px;
                            box-shadow: 0 0 20px rgba(0, 0, 0, 0.1);
                            padding: 30px;
                            margin-bottom: 30px;
                        }

                        .profile-header {
                            text-align: center;
                            margin-bottom: 30px;
                            border-bottom: 2px solid #e9ecef;
                            padding-bottom: 20px;
                        }

                        .profile-avatar {
                            width: 100px;
                            height: 100px;
                            background: linear-gradient(135deg, #198754, #20c997);
                            border-radius: 50%;
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            margin: 0 auto 20px;
                            font-size: 2.5rem;
                            color: white;
                        }

                        .form-section {
                            margin-bottom: 30px;
                        }

                        .form-section h4 {
                            color: #198754;
                            border-bottom: 2px solid #e9ecef;
                            padding-bottom: 10px;
                            margin-bottom: 20px;
                        }

                        .info-row {
                            display: flex;
                            justify-content: space-between;
                            align-items: center;
                            padding: 15px 0;
                            border-bottom: 1px solid #f8f9fa;
                        }

                        .info-row:last-child {
                            border-bottom: none;
                        }

                        .info-label {
                            font-weight: 600;
                            color: #6c757d;
                            min-width: 150px;
                        }

                        .info-value {
                            color: #495057;
                            flex: 1;
                            text-align: right;
                        }

                        .status-badge {
                            padding: 6px 12px;
                            border-radius: 20px;
                            font-size: 0.875rem;
                            font-weight: 600;
                            text-transform: uppercase;
                        }

                        .status-active {
                            background-color: #d1ecf1;
                            color: #0c5460;
                        }

                        .status-inactive {
                            background-color: #f8d7da;
                            color: #721c24;
                        }

                        .status-pending {
                            background-color: #fff3cd;
                            color: #856404;
                        }

                        .fee-info {
                            background-color: #f8f9fa;
                            border-left: 4px solid #198754;
                            padding: 15px;
                            margin-top: 10px;
                            border-radius: 0 8px 8px 0;
                        }

                        .bg-light-success {
                            background-color: #d1ecf1 !important;
                            border-left: 4px solid #0c5460;
                        }

                        .btn-edit {
                            background: linear-gradient(135deg, #198754, #20c997);
                            border: none;
                            padding: 12px 30px;
                            border-radius: 25px;
                            color: white;
                            font-weight: 600;
                            transition: all 0.3s ease;
                        }

                        .btn-edit:hover {
                            transform: translateY(-2px);
                            box-shadow: 0 5px 15px rgba(25, 135, 84, 0.4);
                            color: white;
                        }
                    </style>
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
                                                <i class="fas fa-store"></i>
                                            </div>
                                            <h2>${store.storeName}</h2>
                                            <p class="text-muted">
                                                <i class="fas fa-user me-2"></i>Chủ cửa hàng: ${user.fullName != null ?
                                                user.fullName : user.username}
                                            </p>
                                        </div>

                                        <!-- View Mode Section -->
                                        <div id="viewMode">
                                            <!-- Store Information Section -->
                                            <div class="form-section">
                                                <h4><i class="fas fa-store-alt text-success"></i> Thông tin cửa hàng
                                                </h4>

                                                <div class="info-row">
                                                    <span class="info-label">
                                                        <i class="fas fa-tag me-2"></i>Tên cửa hàng:
                                                    </span>
                                                    <span class="info-value">${store.storeName}</span>
                                                </div>

                                                <div class="info-row">
                                                    <span class="info-label">
                                                        <i class="fas fa-align-left me-2"></i>Mô tả:
                                                    </span>
                                                    <span class="info-value">
                                                        <c:choose>
                                                            <c:when test="${not empty store.description}">
                                                                ${store.description}
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="text-muted">Chưa có mô tả</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </span>
                                                </div>

                                                <div class="info-row">
                                                    <span class="info-label">
                                                        <i class="fas fa-info-circle me-2"></i>Trạng thái:
                                                    </span>
                                                    <span class="info-value">
                                                        <c:choose>
                                                            <c:when test="${store.status == 'ACTIVE'}">
                                                                <span class="status-badge status-active">Hoạt
                                                                    động</span>
                                                            </c:when>
                                                            <c:when test="${store.status == 'INACTIVE'}">
                                                                <span class="status-badge status-inactive">Không hoạt
                                                                    động</span>
                                                            </c:when>
                                                            <c:when test="${store.status == 'PENDING'}">
                                                                <span class="status-badge status-pending">Chờ xác
                                                                    nhận</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="status-badge">${store.status}</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </span>
                                                </div>
                                            </div>

                                            <!-- Fee Model Section -->
                                            <div class="form-section">
                                                <h4><i class="fas fa-percentage text-success"></i> Mô hình phí</h4>

                                                <div class="info-row">
                                                    <span class="info-label">
                                                        <i class="fas fa-coins me-2"></i>Loại phí:
                                                    </span>
                                                    <span class="info-value">
                                                        <c:choose>
                                                            <c:when test="${store.feeModel == 'PERCENTAGE'}">
                                                                <span class="badge bg-info">PERCENTAGE</span>
                                                            </c:when>
                                                            <c:when test="${store.feeModel == 'NO_FEE'}">
                                                                <span class="badge bg-success">NO FEE</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span
                                                                    class="badge bg-secondary">${store.feeModel}</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </span>
                                                </div>

                                                <!-- Show fee percentage only if fee model is PERCENTAGE -->
                                                <c:if test="${store.feeModel == 'PERCENTAGE'}">
                                                    <div class="info-row">
                                                        <span class="info-label">
                                                            <i class="fas fa-percent me-2"></i>Tỷ lệ phí:
                                                        </span>
                                                        <span class="info-value">
                                                            <c:choose>
                                                                <c:when test="${store.feePercentageRate != null}">
                                                                    <fmt:formatNumber value="${store.feePercentageRate}"
                                                                        maxFractionDigits="2" />%
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <fmt:formatNumber value="${systemPercentageFee}"
                                                                        maxFractionDigits="2" />% (Hệ thống)
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </span>
                                                    </div>

                                                    <div class="fee-info">
                                                        <h6 class="fw-bold mb-2">
                                                            <i class="fas fa-chart-line me-1"></i>Hệ thống sẽ áp dụng
                                                            mức phí giao dịch dựa trên giá trị đơn hàng như sau:
                                                        </h6>
                                                        <div class="row">
                                                            <div class="col-md-6 mb-2">
                                                                <i class="fas fa-arrow-right text-success me-1"></i>
                                                                Đơn hàng dưới <strong>100.000 VNĐ</strong> → Phí cố
                                                                định: <strong class="text-danger">5.000 VNĐ</strong>
                                                            </div>
                                                            <div class="col-md-6 mb-2">
                                                                <i class="fas fa-arrow-right text-primary me-1"></i>
                                                                Đơn hàng từ <strong>100.000 VNĐ</strong> trở lên → Phí
                                                                theo tỷ lệ: <strong class="text-danger">3%</strong> trên
                                                                tổng giá trị đơn hàng
                                                            </div>
                                                        </div>

                                                        <div class="alert alert-success mt-3 mb-2">
                                                            <h6 class="fw-bold mb-2">
                                                                <i class="fas fa-money-check-alt me-1"></i>Chính sách
                                                                hoàn phí ký quỹ:
                                                            </h6>
                                                            <ul class="mb-0 ps-3">
                                                                <li>Nếu cửa hàng đóng sau <strong>01 năm</strong> kể từ
                                                                    ngày kích hoạt → hoàn <strong
                                                                        class="text-success">100% phí ký quỹ</strong>.
                                                                </li>
                                                                <li>Nếu cửa hàng đóng trước <strong>01 năm</strong> →
                                                                    hoàn <strong class="text-warning">70% phí ký
                                                                        quỹ</strong>.</li>
                                                                <li>Phí hoàn sẽ được chuyển vào ví hệ thống trong vòng
                                                                    <strong>07 ngày làm việc</strong> sau khi xác nhận
                                                                    đóng cửa hàng.
                                                                </li>
                                                            </ul>
                                                        </div>

                                                        <small class="text-muted">
                                                            <i class="fas fa-lightbulb me-1"></i>
                                                            <em>Chính sách này đảm bảo tính công bằng, khuyến khích hoạt
                                                                động lâu dài và bảo vệ quyền lợi của cả người mua và
                                                                người bán.</em>
                                                        </small>
                                                    </div>
                                                </c:if>

                                                <!-- Show NO_FEE policy -->
                                                <c:if test="${store.feeModel == 'NO_FEE'}">
                                                    <div class="fee-info bg-light-success">
                                                        <h6 class="fw-bold mb-2 text-success">
                                                            <i class="fas fa-check-circle me-1"></i>Ưu đãi đặc biệt -
                                                            Miễn phí giao dịch
                                                        </h6>
                                                        <div class="row mb-3">
                                                            <div class="col-md-6">
                                                                <i class="fas fa-check text-success me-1"></i>
                                                                Người bán <strong>không phải trả bất kỳ khoản phí giao
                                                                    dịch nào</strong> cho các đơn hàng.
                                                            </div>
                                                            <div class="col-md-6">
                                                                <i class="fas fa-check text-success me-1"></i>
                                                                Toàn bộ doanh thu sẽ được chuyển <strong>100%</strong>
                                                                vào ví hệ thống của người bán.
                                                            </div>
                                                        </div>

                                                        <div class="alert alert-warning mb-2">
                                                            <h6 class="fw-bold mb-2">
                                                                <i class="fas fa-exclamation-triangle me-1"></i>Chính
                                                                sách hoàn phí ký quỹ:
                                                            </h6>
                                                            <ul class="mb-2 ps-3">
                                                                <li><strong>Không áp dụng hoàn phí ký quỹ</strong> trong
                                                                    mọi trường hợp.</li>
                                                                <li>Khi cửa hàng ngừng hoạt động, phí ký quỹ sẽ
                                                                    <strong>không được hoàn lại</strong>, kể cả khi thời
                                                                    gian hoạt động đã vượt qua 01 năm.
                                                                </li>
                                                            </ul>
                                                            <small class="text-muted">
                                                                <i class="fas fa-lightbulb me-1"></i>
                                                                <strong>Phù hợp với các cửa hàng nhỏ, thử nghiệm hoặc
                                                                    hoạt động ngắn hạn, ưu tiên đơn giản và không phát
                                                                    sinh phí giao dịch.</strong>
                                                            </small>
                                                        </div>
                                                    </div>
                                                </c:if>
                                            </div>

                                            <!-- Financial Information Section -->
                                            <div class="form-section">
                                                <h4><i class="fas fa-wallet text-success"></i> Thông tin tài chính</h4>

                                                <div class="info-row">
                                                    <span class="info-label">
                                                        <i class="fas fa-piggy-bank me-2"></i>Số tiền ký quỹ:
                                                    </span>
                                                    <span class="info-value">
                                                        <strong class="text-success">
                                                            <fmt:formatNumber value="${store.depositAmount}"
                                                                type="currency" currencySymbol=""
                                                                maxFractionDigits="0" />đ
                                                        </strong>
                                                    </span>
                                                </div>

                                                <div class="info-row">
                                                    <span class="info-label">
                                                        <i class="fas fa-chart-line me-2"></i>Giá tối đa sản phẩm:
                                                    </span>
                                                    <span class="info-value">
                                                        <c:choose>
                                                            <c:when test="${store.maxListingPrice != null}">
                                                                <strong class="text-primary">
                                                                    <fmt:formatNumber value="${store.maxListingPrice}"
                                                                        type="currency" currencySymbol=""
                                                                        maxFractionDigits="0" />đ
                                                                </strong>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="text-muted">Không giới hạn</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </span>
                                                </div>
                                            </div>

                                            <!-- Action Buttons -->
                                            <div class="text-center">
                                                <button type="button" class="btn btn-edit" onclick="switchToEditMode()">
                                                    <i class="fas fa-edit me-2"></i>Chỉnh sửa thông tin
                                                </button>
                                            </div>
                                        </div>

                                        <!-- Edit Mode Section -->
                                        <div id="editMode" style="display: none;">
                                            <form action="<c:url value='/seller/profile/update'/>" method="post">
                                                <!-- Store Information Section -->
                                                <div class="form-section">
                                                    <h4><i class="fas fa-store-alt text-success"></i> Chỉnh sửa thông
                                                        tin cửa hàng</h4>

                                                    <div class="mb-3">
                                                        <label for="storeName" class="form-label fw-bold">
                                                            <i class="fas fa-tag me-2"></i>Tên cửa hàng <span
                                                                class="text-danger">*</span>
                                                        </label>
                                                        <input type="text" class="form-control" id="storeName"
                                                            name="storeName" value="${store.storeName}" required
                                                            maxlength="100">
                                                        <div class="form-text">Tên cửa hàng phải là duy nhất</div>
                                                    </div>

                                                    <div class="mb-3">
                                                        <label for="description" class="form-label fw-bold">
                                                            <i class="fas fa-align-left me-2"></i>Mô tả cửa hàng
                                                        </label>
                                                        <textarea class="form-control" id="description"
                                                            name="description" rows="4" maxlength="500"
                                                            placeholder="Mô tả về cửa hàng của bạn...">${store.description}</textarea>
                                                        <div class="form-text">Tối đa 500 ký tự</div>
                                                    </div>
                                                </div>

                                                <!-- Action Buttons -->
                                                <div class="text-center">
                                                    <button type="button" class="btn btn-secondary me-2"
                                                        onclick="cancelEdit()">
                                                        <i class="fas fa-times me-2"></i>Hủy
                                                    </button>
                                                    <button type="submit" class="btn btn-edit">
                                                        <i class="fas fa-save me-2"></i>Lưu thay đổi
                                                    </button>
                                                </div>
                                            </form>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Include Footer -->
                    <jsp:include page="../common/footer.jsp" />

                    <!-- JavaScript -->
                    <script>
                        function switchToEditMode() {
                            document.getElementById('viewMode').style.display = 'none';
                            document.getElementById('editMode').style.display = 'block';
                        }

                        function cancelEdit() {
                            document.getElementById('editMode').style.display = 'none';
                            document.getElementById('viewMode').style.display = 'block';
                        }

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
                    </script>

                    <!-- Script to display notifications using iziToast -->
                    <c:if test="${not empty successMessage}">
                        <script>
                            iziToast.success({
                                title: 'Thành công!',
                                message: '${successMessage}',
                                position: 'topRight',
                                timeout: 5000
                            });
                        </script>
                    </c:if>

                    <c:if test="${not empty errorMessage}">
                        <script>
                            iziToast.error({
                                title: 'Lỗi!',
                                message: '${errorMessage}',
                                position: 'topRight',
                                timeout: 8000
                            });
                        </script>
                    </c:if>
                </body>

                </html>