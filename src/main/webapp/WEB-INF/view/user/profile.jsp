<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hồ sơ cá nhân - TaphoaMMO</title>
    
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <style>
        body {
            background-color: #f8f9fa;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        
        .profile-header {
            background: linear-gradient(135deg, #2c3e50, #3498db);
            color: white;
            padding: 3rem 0;
            margin-bottom: 2rem;
            border-radius: 0 0 20px 20px;
        }
        
        .profile-avatar {
            width: 120px;
            height: 120px;
            border-radius: 50%;
            border: 5px solid white;
            object-fit: cover;
            box-shadow: 0 4px 15px rgba(0,0,0,0.2);
        }
        
        .profile-card {
            background: white;
            border-radius: 15px;
            padding: 2rem;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
            margin-bottom: 2rem;
        }
        
        .info-item {
            display: flex;
            align-items: center;
            padding: 1rem 0;
            border-bottom: 1px solid #eee;
        }
        
        .info-item:last-child {
            border-bottom: none;
        }
        
        .info-icon {
            width: 40px;
            height: 40px;
            background: #f8f9fa;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-right: 1rem;
            color: #3498db;
        }
        
        .info-content {
            flex-grow: 1;
        }
        
        .info-label {
            font-size: 0.875rem;
            color: #6c757d;
            margin-bottom: 0.25rem;
        }
        
        .info-value {
            font-weight: 600;
            color: #2c3e50;
        }
        
        .wallet-card {
            background: linear-gradient(135deg, #27ae60, #2ecc71);
            color: white;
            border-radius: 15px;
            padding: 2rem;
            margin-bottom: 2rem;
        }
        
        .wallet-balance {
            font-size: 2.5rem;
            font-weight: bold;
            margin-bottom: 0.5rem;
        }
        
        .role-badge {
            display: inline-block;
            padding: 0.5rem 1rem;
            background: #3498db;
            color: white;
            border-radius: 20px;
            font-size: 0.875rem;
            margin-right: 0.5rem;
            margin-bottom: 0.5rem;
        }
        
        .status-badge {
            padding: 0.5rem 1rem;
            border-radius: 20px;
            font-weight: 600;
            font-size: 0.875rem;
        }
        
        .status-active {
            background: #d4edda;
            color: #155724;
        }
        
        .status-inactive {
            background: #fff3cd;
            color: #856404;
        }
        
        .status-suspended {
            background: #f8d7da;
            color: #721c24;
        }
        
        .action-btn {
            border-radius: 10px;
            padding: 0.75rem 1.5rem;
            font-weight: 600;
            margin-right: 0.5rem;
            margin-bottom: 0.5rem;
        }
    </style>
</head>
<body>
    <!-- Profile Header -->
    <div class="profile-header">
        <div class="container">
            <div class="row align-items-center">
                <div class="col-md-3 text-center">
                    <c:choose>
                        <c:when test="${not empty user.avatarUrl}">
                            <img src="${user.avatarUrl}" alt="Avatar" class="profile-avatar">
                        </c:when>
                        <c:otherwise>
                            <div class="profile-avatar bg-secondary d-flex align-items-center justify-content-center mx-auto">
                                <i class="fas fa-user fa-3x"></i>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
                <div class="col-md-6">
                    <h1 class="mb-2">${user.displayName}</h1>
                    <p class="mb-2">@${user.username}</p>
                    <div class="mb-3">
                        <c:forEach var="role" items="${user.roles}">
                            <span class="role-badge">${role.name}</span>
                        </c:forEach>
                    </div>
                    <div>
                        <c:choose>
                            <c:when test="${user.status == 'ACTIVE' && user.enabled}">
                                <span class="status-badge status-active">
                                    <i class="fas fa-check-circle me-1"></i>Hoạt động
                                </span>
                            </c:when>
                            <c:when test="${user.status == 'INACTIVE' || !user.enabled}">
                                <span class="status-badge status-inactive">
                                    <i class="fas fa-clock me-1"></i>Không hoạt động
                                </span>
                            </c:when>
                            <c:when test="${user.status == 'SUSPENDED'}">
                                <span class="status-badge status-suspended">
                                    <i class="fas fa-ban me-1"></i>Bị khóa
                                </span>
                            </c:when>
                        </c:choose>
                    </div>
                </div>
                <div class="col-md-3 text-md-end">
                    <a href="/users/edit" class="btn btn-light action-btn">
                        <i class="fas fa-edit me-2"></i>Chỉnh sửa hồ sơ
                    </a>
                    <a href="/users/change-password" class="btn btn-outline-light action-btn">
                        <i class="fas fa-key me-2"></i>Đổi mật khẩu
                    </a>
                </div>
            </div>
        </div>
    </div>

    <div class="container">
        <div class="row">
            <!-- Wallet Information -->
            <div class="col-md-4">
                <c:if test="${not empty user.wallet}">
                    <div class="wallet-card">
                        <div class="d-flex align-items-center mb-3">
                            <i class="fas fa-wallet fa-2x me-3"></i>
                            <h4 class="mb-0">Ví của tôi</h4>
                        </div>
                        <div class="wallet-balance">
                            <fmt:formatNumber value="${walletBalance}" type="currency" 
                                            currencySymbol="" maxFractionDigits="0"/> VND
                        </div>
                        <p class="mb-3 opacity-75">Số dư hiện tại</p>
                        <div class="d-grid gap-2">
                            <a href="/wallet/deposit" class="btn btn-light">
                                <i class="fas fa-plus me-2"></i>Nạp tiền
                            </a>
                            <a href="/wallet/withdraw" class="btn btn-outline-light">
                                <i class="fas fa-minus me-2"></i>Rút tiền
                            </a>
                            <a href="/wallet/history" class="btn btn-outline-light">
                                <i class="fas fa-history me-2"></i>Lịch sử giao dịch
                            </a>
                        </div>
                    </div>
                </c:if>
                
                <!-- Quick Actions -->
                <div class="profile-card">
                    <h5 class="mb-3">
                        <i class="fas fa-bolt me-2 text-warning"></i>Thao tác nhanh
                    </h5>
                    <div class="d-grid gap-2">
                        <c:if test="${user.hasRole('SELLER') || user.canCreateSellerStore}">
                            <a href="/stores/create" class="btn btn-outline-primary">
                                <i class="fas fa-store me-2"></i>Tạo cửa hàng
                            </a>
                        </c:if>
                        <a href="/orders" class="btn btn-outline-info">
                            <i class="fas fa-shopping-cart me-2"></i>Đơn hàng của tôi
                        </a>
                        <a href="/products/favorites" class="btn btn-outline-danger">
                            <i class="fas fa-heart me-2"></i>Sản phẩm yêu thích
                        </a>
                        <a href="/support" class="btn btn-outline-secondary">
                            <i class="fas fa-headset me-2"></i>Hỗ trợ
                        </a>
                    </div>
                </div>
            </div>
            
            <!-- Personal Information -->
            <div class="col-md-8">
                <div class="profile-card">
                    <h5 class="mb-4">
                        <i class="fas fa-user me-2 text-primary"></i>Thông tin cá nhân
                    </h5>
                    
                    <div class="info-item">
                        <div class="info-icon">
                            <i class="fas fa-envelope"></i>
                        </div>
                        <div class="info-content">
                            <div class="info-label">Email</div>
                            <div class="info-value">${user.email}</div>
                        </div>
                    </div>
                    
                    <div class="info-item">
                        <div class="info-icon">
                            <i class="fas fa-phone"></i>
                        </div>
                        <div class="info-content">
                            <div class="info-label">Số điện thoại</div>
                            <div class="info-value">
                                <c:choose>
                                    <c:when test="${not empty user.phone}">
                                        ${user.phone}
                                    </c:when>
                                    <c:otherwise>
                                        <span class="text-muted">Chưa cập nhật</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>
                    
                    <div class="info-item">
                        <div class="info-icon">
                            <i class="fas fa-birthday-cake"></i>
                        </div>
                        <div class="info-content">
                            <div class="info-label">Ngày sinh</div>
                            <div class="info-value">
                                <c:choose>
                                    <c:when test="${not empty user.dateOfBirth}">
                                        ${user.dateOfBirth}
                                    </c:when>
                                    <c:otherwise>
                                        <span class="text-muted">Chưa cập nhật</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>
                    
                    <div class="info-item">
                        <div class="info-icon">
                            <i class="fas fa-venus-mars"></i>
                        </div>
                        <div class="info-content">
                            <div class="info-label">Giới tính</div>
                            <div class="info-value">
                                <c:choose>
                                    <c:when test="${user.gender == 'MALE'}">Nam</c:when>
                                    <c:when test="${user.gender == 'FEMALE'}">Nữ</c:when>
                                    <c:when test="${user.gender == 'OTHER'}">Khác</c:when>
                                    <c:otherwise>
                                        <span class="text-muted">Chưa cập nhật</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>
                    
                    <div class="info-item">
                        <div class="info-icon">
                            <i class="fas fa-calendar-plus"></i>
                        </div>
                        <div class="info-content">
                            <div class="info-label">Ngày tham gia</div>
                            <div class="info-value">
                                <c:choose>
                                    <c:when test="${not empty user.createdAt}">
                                        ${fn:substring(user.createdAt.toString().replace('T', ' '), 0, 16)}
                                    </c:when>
                                    <c:otherwise>
                                        <span class="text-muted">N/A</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>
                    
                    <div class="info-item">
                        <div class="info-icon">
                            <i class="fas fa-clock"></i>
                        </div>
                        <div class="info-content">
                            <div class="info-label">Cập nhật lần cuối</div>
                            <div class="info-value">
                                <c:choose>
                                    <c:when test="${not empty user.updatedAt}">
                                        ${fn:substring(user.updatedAt.toString().replace('T', ' '), 0, 16)}
                                    </c:when>
                                    <c:otherwise>
                                        <span class="text-muted">Chưa có cập nhật</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Seller Store Information -->
                <c:if test="${not empty user.sellerStore}">
                    <div class="profile-card">
                        <h5 class="mb-4">
                            <i class="fas fa-store me-2 text-success"></i>Cửa hàng của tôi
                        </h5>
                        
                        <div class="info-item">
                            <div class="info-icon">
                                <i class="fas fa-tag"></i>
                            </div>
                            <div class="info-content">
                                <div class="info-label">Tên cửa hàng</div>
                                <div class="info-value">${user.sellerStore.storeName}</div>
                            </div>
                        </div>
                        
                        <div class="info-item">
                            <div class="info-icon">
                                <i class="fas fa-money-bill"></i>
                            </div>
                            <div class="info-content">
                                <div class="info-label">Tiền đặt cọc</div>
                                <div class="info-value">
                                    <fmt:formatNumber value="${user.sellerStore.depositAmount}" type="currency" 
                                                    currencySymbol="" maxFractionDigits="0"/> VND
                                </div>
                            </div>
                        </div>
                        
                        <div class="text-end mt-3">
                            <a href="/stores/manage" class="btn btn-success">
                                <i class="fas fa-cog me-2"></i>Quản lý cửa hàng
                            </a>
                        </div>
                    </div>
                </c:if>
            </div>
        </div>
    </div>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
</body>
</html>
