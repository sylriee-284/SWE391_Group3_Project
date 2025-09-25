<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cài đặt Cửa hàng - ${store.storeName} - TaphoaMMO</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        .settings-container {
            max-width: 900px;
            margin: 0 auto;
        }
        .settings-section {
            background: white;
            border-radius: 15px;
            padding: 30px;
            margin-bottom: 30px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.08);
        }
        .section-title {
            color: #495057;
            border-bottom: 2px solid #e9ecef;
            padding-bottom: 15px;
            margin-bottom: 25px;
        }
        .store-logo-preview {
            width: 120px;
            height: 120px;
            object-fit: cover;
            border-radius: 15px;
            border: 3px solid #e9ecef;
        }
        .logo-placeholder {
            width: 120px;
            height: 120px;
            background: #f8f9fa;
            border: 3px dashed #dee2e6;
            border-radius: 15px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #6c757d;
        }
        .store-status-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-radius: 15px;
            padding: 25px;
            margin-bottom: 30px;
        }
        .danger-zone {
            border: 2px solid #dc3545;
            border-radius: 15px;
            padding: 25px;
            background: #fff5f5;
        }
    </style>
</head>
<body class="bg-light">
    <div class="container py-5">
        <div class="settings-container">
            
            <!-- Header -->
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h1 class="h2 text-primary">
                        <i class="fas fa-cog"></i>
                        Cài đặt Cửa hàng
                    </h1>
                    <p class="text-muted mb-0">Quản lý thông tin và cấu hình cửa hàng của bạn</p>
                </div>
                <div>
                    <a href="/stores/my-store" class="btn btn-outline-primary">
                        <i class="fas fa-arrow-left"></i> Quay lại Dashboard
                    </a>
                </div>
            </div>

            <!-- Store Status -->
            <div class="store-status-card">
                <div class="row align-items-center">
                    <div class="col-md-8">
                        <h4 class="mb-2">
                            <i class="fas fa-store"></i>
                            ${store.storeName}
                        </h4>
                        <div class="d-flex gap-2 mb-2">
                            <span class="badge bg-light text-dark">${store.status}</span>
                            <span class="badge bg-light text-dark">
                                ${store.isVerified ? 'Đã xác minh' : 'Chưa xác minh'}
                            </span>
                            <span class="badge ${store.isActive ? 'bg-success' : 'bg-warning'}">
                                ${store.isActive ? 'Hoạt động' : 'Tạm ngưng'}
                            </span>
                        </div>
                        <p class="mb-0 opacity-75">
                            ID: ${store.id} | Tạo ngày: 
                            <c:choose>
                                <c:when test="${not empty store.createdAt}">
                                    ${fn:substring(store.createdAt.toString().replace('T', ' '), 0, 16)}
                                </c:when>
                                <c:otherwise>N/A</c:otherwise>
                            </c:choose>
                        </p>
                    </div>
                    <div class="col-md-4 text-end">
                        <div class="mb-2">
                            <div class="h5 mb-0">${store.formattedDeposit}</div>
                            <small class="opacity-75">Deposit</small>
                        </div>
                        <div>
                            <div class="h6 mb-0">${store.formattedMaxPrice}</div>
                            <small class="opacity-75">Giá tối đa</small>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Store Information Form -->
            <div class="settings-section">
                <h4 class="section-title">
                    <i class="fas fa-info-circle"></i>
                    Thông tin cửa hàng
                </h4>

                <form:form method="post" action="/stores/my-store/settings" modelAttribute="updateRequest" class="needs-validation" novalidate="true">
                    
                    <div class="row">
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label for="storeName" class="form-label">
                                    Tên cửa hàng <span class="text-danger">*</span>
                                </label>
                                <form:input path="storeName" class="form-control" id="storeName" required="true"/>
                                <form:errors path="storeName" class="text-danger small"/>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label for="contactEmail" class="form-label">Email liên hệ</label>
                                <form:input path="contactEmail" type="email" class="form-control" id="contactEmail"/>
                                <form:errors path="contactEmail" class="text-danger small"/>
                            </div>
                        </div>
                    </div>

                    <div class="mb-3">
                        <label for="storeDescription" class="form-label">Mô tả cửa hàng</label>
                        <form:textarea path="storeDescription" class="form-control" id="storeDescription" rows="4"/>
                        <form:errors path="storeDescription" class="text-danger small"/>
                        <div class="form-text">Mô tả chi tiết về cửa hàng và sản phẩm của bạn</div>
                    </div>

                    <div class="row">
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label for="contactPhone" class="form-label">Số điện thoại</label>
                                <form:input path="contactPhone" class="form-control" id="contactPhone"/>
                                <form:errors path="contactPhone" class="text-danger small"/>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label for="businessLicense" class="form-label">Giấy phép kinh doanh</label>
                                <form:input path="businessLicense" class="form-control" id="businessLicense"/>
                                <form:errors path="businessLicense" class="text-danger small"/>
                                <div class="form-text">Giúp tăng độ tin cậy với khách hàng</div>
                            </div>
                        </div>
                    </div>

                    <div class="text-end">
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-save"></i>
                            Lưu thay đổi
                        </button>
                    </div>
                </form:form>
            </div>

            <!-- Store Logo -->
            <div class="settings-section">
                <h4 class="section-title">
                    <i class="fas fa-image"></i>
                    Logo cửa hàng
                </h4>

                <div class="row align-items-center">
                    <div class="col-md-3">
                        <c:choose>
                            <c:when test="${not empty store.storeLogoUrl}">
                                <img src="${store.storeLogoUrl}" alt="Store Logo" class="store-logo-preview">
                            </c:when>
                            <c:otherwise>
                                <div class="logo-placeholder">
                                    <i class="fas fa-image fa-2x"></i>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div class="col-md-9">
                        <h6>Tải lên logo mới</h6>
                        <p class="text-muted mb-3">
                            Kích thước khuyến nghị: 200x200px. Định dạng: JPG, PNG. Dung lượng tối đa: 2MB.
                        </p>
                        
                        <form action="/stores/my-store/upload-logo" method="post" enctype="multipart/form-data" class="d-inline">
                            <div class="input-group">
                                <input type="file" class="form-control" name="logoFile" accept="image/*" required>
                                <button type="submit" class="btn btn-primary">
                                    <i class="fas fa-upload"></i> Tải lên
                                </button>
                            </div>
                        </form>

                        <c:if test="${not empty store.storeLogoUrl}">
                            <form action="/stores/my-store/remove-logo" method="post" class="d-inline ms-2">
                                <button type="submit" class="btn btn-outline-danger" 
                                        onclick="return confirm('Bạn có chắc muốn xóa logo hiện tại?')">
                                    <i class="fas fa-trash"></i> Xóa logo
                                </button>
                            </form>
                        </c:if>
                    </div>
                </div>
            </div>

            <!-- Store Actions -->
            <div class="settings-section">
                <h4 class="section-title">
                    <i class="fas fa-tools"></i>
                    Quản lý cửa hàng
                </h4>

                <div class="row">
                    <div class="col-md-6">
                        <div class="card h-100">
                            <div class="card-body text-center">
                                <i class="fas fa-pause-circle fa-3x text-warning mb-3"></i>
                                <h6>Tạm ngưng hoạt động</h6>
                                <p class="text-muted small">
                                    Tạm thời ngưng nhận đơn hàng mới. Bạn có thể kích hoạt lại bất cứ lúc nào.
                                </p>
                                <c:choose>
                                    <c:when test="${store.isActive}">
                                        <form action="/stores/my-store/deactivate" method="post">
                                            <button type="submit" class="btn btn-warning" 
                                                    onclick="return confirm('Bạn có chắc muốn tạm ngưng cửa hàng?')">
                                                <i class="fas fa-pause"></i> Tạm ngưng
                                            </button>
                                        </form>
                                    </c:when>
                                    <c:otherwise>
                                        <form action="/stores/my-store/activate" method="post">
                                            <button type="submit" class="btn btn-success">
                                                <i class="fas fa-play"></i> Kích hoạt
                                            </button>
                                        </form>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="card h-100">
                            <div class="card-body text-center">
                                <i class="fas fa-chart-line fa-3x text-info mb-3"></i>
                                <h6>Báo cáo & Thống kê</h6>
                                <p class="text-muted small">
                                    Xem báo cáo chi tiết về doanh thu, đơn hàng và hiệu suất kinh doanh.
                                </p>
                                <a href="/stores/my-store/reports" class="btn btn-info">
                                    <i class="fas fa-chart-bar"></i> Xem báo cáo
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Verification Status -->
            <c:if test="${not store.isVerified}">
                <div class="settings-section">
                    <h4 class="section-title">
                        <i class="fas fa-shield-alt"></i>
                        Xác minh cửa hàng
                    </h4>

                    <div class="alert alert-warning">
                        <div class="row align-items-center">
                            <div class="col-md-8">
                                <h6 class="alert-heading">
                                    <i class="fas fa-exclamation-triangle"></i>
                                    Cửa hàng chưa được xác minh
                                </h6>
                                <p class="mb-0">
                                    Để tăng độ tin cậy và có thể bán được nhiều sản phẩm hơn, 
                                    hãy hoàn thiện thông tin và chờ admin xác minh.
                                </p>
                            </div>
                            <div class="col-md-4 text-end">
                                <a href="/help/verification" class="btn btn-warning">
                                    <i class="fas fa-question-circle"></i> Hướng dẫn
                                </a>
                            </div>
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-md-6">
                            <h6>Checklist xác minh:</h6>
                            <ul class="list-unstyled">
                                <li class="${not empty store.storeName ? 'text-success' : 'text-muted'}">
                                    <i class="fas ${not empty store.storeName ? 'fa-check' : 'fa-times'}"></i>
                                    Tên cửa hàng
                                </li>
                                <li class="${not empty store.storeDescription ? 'text-success' : 'text-muted'}">
                                    <i class="fas ${not empty store.storeDescription ? 'fa-check' : 'fa-times'}"></i>
                                    Mô tả cửa hàng
                                </li>
                                <li class="${not empty store.contactEmail ? 'text-success' : 'text-muted'}">
                                    <i class="fas ${not empty store.contactEmail ? 'fa-check' : 'fa-times'}"></i>
                                    Email liên hệ
                                </li>
                                <li class="${not empty store.contactPhone ? 'text-success' : 'text-muted'}">
                                    <i class="fas ${not empty store.contactPhone ? 'fa-check' : 'fa-times'}"></i>
                                    Số điện thoại
                                </li>
                                <li class="${not empty store.businessLicense ? 'text-success' : 'text-muted'}">
                                    <i class="fas ${not empty store.businessLicense ? 'fa-check' : 'fa-times'}"></i>
                                    Giấy phép kinh doanh (khuyến nghị)
                                </li>
                            </ul>
                        </div>
                        <div class="col-md-6">
                            <h6>Lợi ích khi được xác minh:</h6>
                            <ul class="list-unstyled text-muted">
                                <li><i class="fas fa-star text-warning"></i> Badge "Đã xác minh"</li>
                                <li><i class="fas fa-search-plus text-info"></i> Hiển thị ưu tiên trong tìm kiếm</li>
                                <li><i class="fas fa-shield-alt text-success"></i> Tăng độ tin cậy với khách hàng</li>
                                <li><i class="fas fa-chart-line text-primary"></i> Truy cập tính năng nâng cao</li>
                            </ul>
                        </div>
                    </div>
                </div>
            </c:if>

            <!-- Danger Zone -->
            <div class="danger-zone">
                <h4 class="text-danger mb-3">
                    <i class="fas fa-exclamation-triangle"></i>
                    Vùng nguy hiểm
                </h4>
                <p class="text-muted mb-4">
                    Các hành động trong vùng này có thể ảnh hưởng nghiêm trọng đến cửa hàng của bạn. 
                    Hãy cân nhắc kỹ trước khi thực hiện.
                </p>

                <div class="row">
                    <div class="col-md-6">
                        <div class="border border-danger rounded p-3 text-center">
                            <i class="fas fa-trash fa-2x text-danger mb-2"></i>
                            <h6 class="text-danger">Xóa cửa hàng</h6>
                            <p class="text-muted small">
                                Xóa vĩnh viễn cửa hàng và tất cả dữ liệu liên quan. 
                                Hành động này không thể hoàn tác.
                            </p>
                            <button type="button" class="btn btn-outline-danger" data-bs-toggle="modal" data-bs-target="#deleteStoreModal">
                                <i class="fas fa-trash"></i> Xóa cửa hàng
                            </button>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="border border-warning rounded p-3 text-center">
                            <i class="fas fa-life-ring fa-2x text-warning mb-2"></i>
                            <h6 class="text-warning">Cần hỗ trợ?</h6>
                            <p class="text-muted small">
                                Liên hệ với đội ngũ hỗ trợ nếu bạn gặp vấn đề 
                                hoặc cần tư vấn về cửa hàng.
                            </p>
                            <a href="/support" class="btn btn-outline-warning">
                                <i class="fas fa-headset"></i> Liên hệ hỗ trợ
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Delete Store Modal -->
    <div class="modal fade" id="deleteStoreModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title text-danger">
                        <i class="fas fa-exclamation-triangle"></i>
                        Xác nhận xóa cửa hàng
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="alert alert-danger">
                        <strong>Cảnh báo:</strong> Hành động này sẽ xóa vĩnh viễn cửa hàng "${store.storeName}" 
                        và tất cả dữ liệu liên quan bao gồm sản phẩm, đơn hàng, và đánh giá.
                    </div>
                    <p>Để xác nhận, vui lòng nhập tên cửa hàng: <strong>${store.storeName}</strong></p>
                    <input type="text" class="form-control" id="confirmStoreName" 
                           placeholder="Nhập tên cửa hàng để xác nhận">
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy bỏ</button>
                    <button type="button" class="btn btn-danger" id="confirmDeleteBtn" disabled>
                        <i class="fas fa-trash"></i> Xóa cửa hàng
                    </button>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Form validation
        (function() {
            'use strict';
            window.addEventListener('load', function() {
                var forms = document.getElementsByClassName('needs-validation');
                var validation = Array.prototype.filter.call(forms, function(form) {
                    form.addEventListener('submit', function(event) {
                        if (form.checkValidity() === false) {
                            event.preventDefault();
                            event.stopPropagation();
                        }
                        form.classList.add('was-validated');
                    }, false);
                });
            }, false);
        })();

        // Delete store confirmation
        document.getElementById('confirmStoreName').addEventListener('input', function() {
            const confirmBtn = document.getElementById('confirmDeleteBtn');
            const storeName = '${store.storeName}';
            
            if (this.value === storeName) {
                confirmBtn.disabled = false;
            } else {
                confirmBtn.disabled = true;
            }
        });

        document.getElementById('confirmDeleteBtn').addEventListener('click', function() {
            // TODO: Implement store deletion
            alert('Tính năng xóa cửa hàng sẽ được triển khai sau.');
        });
    </script>
</body>
</html>
