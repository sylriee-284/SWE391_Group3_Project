<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${store.storeName} - Chi tiết cửa hàng - TaphoaMMO</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        /* Content Area */
        .content {
            flex: 1;
            padding: 30px;
            background-color: #ecf0f1;
            min-height: 100vh;
            overflow-x: auto;
        }

        /* Page Header */
        .page-header {
            background: linear-gradient(135deg, #2c3e50, #3498db);
            color: white;
            padding: 2rem;
            margin-bottom: 2rem;
            border-radius: 10px;
        }

        .page-header h1 {
            font-size: 2rem;
            margin-bottom: 0.5rem;
        }

        .page-header .breadcrumb {
            background: transparent;
            padding: 0;
            margin: 0;
        }

        .page-header .breadcrumb-item,
        .page-header .breadcrumb-item a {
            color: rgba(255, 255, 255, 0.8);
        }

        .page-header .breadcrumb-item.active {
            color: white;
        }

        /* Store Header Card */
        .store-header-card {
            background: white;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            padding: 30px;
            margin-bottom: 20px;
        }

        .store-logo {
            width: 120px;
            height: 120px;
            border-radius: 10px;
            object-fit: cover;
            border: 3px solid #3498db;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }

        /* Cards */
        .info-card {
            background: white;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            padding: 25px;
            margin-bottom: 20px;
            border: none;
        }

        .info-card h5 {
            color: #2c3e50;
            font-weight: 600;
            margin-bottom: 1.5rem;
        }

        /* Stats Cards */
        .stat-card {
            background: white;
            border-radius: 10px;
            padding: 20px;
            text-align: center;
            border-left: 4px solid #3498db;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            margin-bottom: 15px;
        }

        .stat-card h3 {
            color: #3498db;
            font-size: 2rem;
            font-weight: 600;
            margin-bottom: 5px;
        }

        .stat-card p {
            color: #7f8c8d;
            margin: 0;
            font-size: 0.9rem;
        }

        .stat-card.success {
            border-left-color: #27ae60;
        }

        .stat-card.success h3 {
            color: #27ae60;
        }

        .stat-card.warning {
            border-left-color: #f39c12;
        }

        .stat-card.warning h3 {
            color: #f39c12;
        }

        .stat-card.info {
            border-left-color: #3498db;
        }

        /* Contact Info */
        .contact-info i {
            width: 25px;
            text-align: center;
            color: #3498db;
        }

        .contact-info a {
            color: #2c3e50;
        }

        .contact-info a:hover {
            color: #3498db;
        }

        /* Badges */
        .badge-custom {
            font-size: 0.85rem;
            padding: 0.5em 0.75em;
            border-radius: 10px;
        }

        /* Buttons */
        .btn {
            border-radius: 8px;
            font-weight: 600;
            padding: 0.75rem 1rem;
        }

        /* Empty State */
        .empty-state {
            text-align: center;
            padding: 3rem 1rem;
            color: #7f8c8d;
        }

        .empty-state i {
            font-size: 3rem;
            margin-bottom: 1rem;
        }

        /* Responsive */
        @media (max-width: 768px) {
            .content {
                padding: 15px;
            }
        }
    </style>
</head>
<body>
    <!-- Include Navbar -->
    <%@ include file="../navbar.jsp" %>

    <!-- Main Layout Container -->
    <div style="display: flex;">
        <!-- Include Sidebar -->
        <%@ include file="../sidebar.jsp" %>

        <!-- Main Content -->
        <div class="content">
            <!-- Page Header -->
            <div class="page-header">
                <div class="d-flex justify-content-between align-items-start">
                    <div>
                        <h1>
                            <i class="fas fa-store me-2"></i>
                            ${store.storeName}
                        </h1>
                        <nav aria-label="breadcrumb">
                            <ol class="breadcrumb">
                                <li class="breadcrumb-item"><a href="/">Trang chủ</a></li>
                                <li class="breadcrumb-item"><a href="/stores">Cửa hàng</a></li>
                                <li class="breadcrumb-item active" aria-current="page">${store.storeName}</li>
                            </ol>
                        </nav>
                    </div>
                    <div>
                        <a href="/stores" class="btn btn-light">
                            <i class="fas fa-arrow-left me-2"></i>
                            Quay lại
                        </a>
                    </div>
                </div>
            </div>

            <!-- Store Header Card -->
            <div class="store-header-card">
                <div class="row align-items-center">
                    <div class="col-md-2 text-center">
                        <c:choose>
                            <c:when test="${not empty store.storeLogoUrl}">
                                <img src="${store.storeLogoUrl}" alt="${store.storeName}" class="store-logo">
                            </c:when>
                            <c:otherwise>
                                <div class="store-logo d-flex align-items-center justify-content-center bg-light text-primary">
                                    <i class="fas fa-store fa-3x"></i>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div class="col-md-10">
                        <h2 class="mb-2">
                            ${store.storeName}
                            <c:if test="${store.isVerified}">
                                <i class="fas fa-certificate text-warning ms-2" title="Đã xác minh"></i>
                            </c:if>
                        </h2>
                        <p class="text-muted mb-3">${store.storeDescription}</p>
                        <div>
                            <span class="badge ${store.statusBadgeClass} badge-custom me-2">
                                <i class="fas fa-circle me-1"></i>
                                ${store.statusDisplayText}
                            </span>
                            <span class="badge ${store.verificationBadgeClass} badge-custom">
                                <i class="fas fa-check-circle me-1"></i>
                                ${store.verificationStatus}
                            </span>
                        </div>
                    </div>
                </div>
            </div>

            <div class="row">
                <!-- Left Column - Store Info -->
                <div class="col-lg-4">
                    <!-- Contact Information -->
                    <div class="info-card">
                        <h5>
                            <i class="fas fa-info-circle me-2"></i>
                            Thông tin liên hệ
                        </h5>
                        <div class="contact-info">
                            <c:if test="${not empty store.contactEmail}">
                                <p class="mb-3">
                                    <i class="fas fa-envelope"></i>
                                    <a href="mailto:${store.contactEmail}" class="text-decoration-none">
                                        ${store.contactEmail}
                                    </a>
                                </p>
                            </c:if>
                            <c:if test="${not empty store.contactPhone}">
                                <p class="mb-3">
                                    <i class="fas fa-phone"></i>
                                    <a href="tel:${store.contactPhone}" class="text-decoration-none">
                                        ${store.contactPhone}
                                    </a>
                                </p>
                            </c:if>
                            <c:if test="${not empty store.businessLicense}">
                                <p class="mb-0">
                                    <i class="fas fa-certificate"></i>
                                    Giấy phép: <strong>${store.businessLicense}</strong>
                                </p>
                            </c:if>
                            <c:if test="${empty store.contactEmail && empty store.contactPhone && empty store.businessLicense}">
                                <p class="text-muted mb-0">Chưa có thông tin liên hệ</p>
                            </c:if>
                        </div>
                    </div>

                    <!-- Store Stats -->
                    <div class="info-card">
                        <h5>
                            <i class="fas fa-chart-bar me-2"></i>
                            Thống kê cửa hàng
                        </h5>
                        <div class="stat-card">
                            <h3>${store.totalProducts != null ? store.totalProducts : 0}</h3>
                            <p>Sản phẩm</p>
                        </div>
                        <div class="stat-card success">
                            <h3>${store.totalOrders != null ? store.totalOrders : 0}</h3>
                            <p>Đơn hàng</p>
                        </div>
                        <div class="stat-card warning">
                            <h3>
                                <c:choose>
                                    <c:when test="${store.averageRating != null}">
                                        <fmt:formatNumber value="${store.averageRating}" maxFractionDigits="1"/>
                                        <i class="fas fa-star"></i>
                                    </c:when>
                                    <c:otherwise>
                                        N/A
                                    </c:otherwise>
                                </c:choose>
                            </h3>
                            <p>Đánh giá trung bình</p>
                        </div>
                        <div class="stat-card info">
                            <h3>${store.totalReviews != null ? store.totalReviews : 0}</h3>
                            <p>Lượt đánh giá</p>
                        </div>
                    </div>

                    <!-- Store Details -->
                    <div class="info-card">
                        <h5>
                            <i class="fas fa-building me-2"></i>
                            Thông tin cửa hàng
                        </h5>
                        <table class="table table-sm table-borderless">
                            <tbody>
                                <tr>
                                    <td class="text-muted" style="width: 40%;">Chủ sở hữu:</td>
                                    <td><strong>${store.ownerUsername != null ? store.ownerUsername : 'N/A'}</strong></td>
                                </tr>
                                <tr>
                                    <td class="text-muted">Đặt cọc tối đa:</td>
                                    <td><strong>${store.formattedMaxListingPrice}</strong></td>
                                </tr>
                                <tr>
                                    <td class="text-muted">Ngày tạo:</td>
                                    <td>
                                        <c:if test="${not empty store.createdAt}">
                                            ${fn:substring(store.createdAt, 0, 10)} ${fn:substring(store.createdAt, 11, 16)}
                                        </c:if>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="text-muted">Cập nhật lần cuối:</td>
                                    <td>
                                        <c:if test="${not empty store.updatedAt}">
                                            ${fn:substring(store.updatedAt, 0, 10)} ${fn:substring(store.updatedAt, 11, 16)}
                                        </c:if>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- Right Column - Products & Reviews -->
                <div class="col-lg-8">
                    <!-- Products Section -->
                    <div class="info-card">
                        <h5>
                            <i class="fas fa-box me-2"></i>
                            Sản phẩm của cửa hàng
                        </h5>
                        <div class="empty-state">
                            <i class="fas fa-box-open"></i>
                            <p class="mb-0">Chức năng hiển thị sản phẩm đang được phát triển</p>
                        </div>
                    </div>

                    <!-- Reviews Section -->
                    <div class="info-card">
                        <h5>
                            <i class="fas fa-star me-2"></i>
                            Đánh giá từ khách hàng
                        </h5>
                        <div class="empty-state">
                            <i class="fas fa-comments"></i>
                            <p class="mb-0">Chức năng đánh giá đang được phát triển</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Toggle sidebar collapse
        function toggleSidebar() {
            var sidebar = document.getElementById('sidebar');
            sidebar.classList.toggle('collapsed');
        }
    </script>
</body>
</html>
