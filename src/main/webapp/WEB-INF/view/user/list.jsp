<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<c:set var="pageTitle" value="Quản lý người dùng" scope="request" />

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${pageTitle} - TaphoaMMO</title>
    
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <style>
        body {
            background-color: #f8f9fa;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        
        .page-header {
            background: linear-gradient(135deg, #2c3e50, #3498db);
            color: white;
            padding: 2rem 0;
            margin-bottom: 2rem;
            border-radius: 0 0 15px 15px;
        }
        
        .stats-card {
            background: white;
            border-radius: 10px;
            padding: 1.5rem;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            border-left: 4px solid #3498db;
            margin-bottom: 1rem;
        }
        
        .stats-number {
            font-size: 2rem;
            font-weight: bold;
            color: #2c3e50;
        }
        
        .search-card {
            background: white;
            border-radius: 10px;
            padding: 1.5rem;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            margin-bottom: 2rem;
        }
        
        .table-card {
            background: white;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            overflow: hidden;
        }
        
        .table th {
            background-color: #f8f9fa;
            border: none;
            font-weight: 600;
            color: #2c3e50;
        }
        
        .table td {
            border: none;
            vertical-align: middle;
        }
        
        .table tbody tr {
            border-bottom: 1px solid #dee2e6;
        }
        
        .table tbody tr:hover {
            background-color: #f8f9fa;
        }
        
        .badge {
            font-size: 0.75em;
            padding: 0.5em 0.75em;
        }
        
        .avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            object-fit: cover;
        }
        
        .btn-sm {
            padding: 0.25rem 0.5rem;
            font-size: 0.875rem;
        }
        
        .pagination {
            justify-content: center;
        }
        
        .page-link {
            color: #3498db;
        }
        
        .page-item.active .page-link {
            background-color: #3498db;
            border-color: #3498db;
        }
    </style>
</head>
<body>
    <!-- Page Header -->
    <div class="page-header">
        <div class="container">
            <div class="row align-items-center">
                <div class="col-md-6">
                    <h1 class="mb-0">
                        <i class="fas fa-users me-3"></i>Quản lý người dùng
                    </h1>
                    <p class="mb-0 mt-2">Quản lý tài khoản người dùng trong hệ thống</p>
                </div>
                <div class="col-md-6 text-md-end">
                    <a href="/users/register" class="btn btn-light btn-lg">
                        <i class="fas fa-plus me-2"></i>Thêm người dùng
                    </a>
                </div>
            </div>
        </div>
    </div>

    <div class="container">
        <!-- Statistics Cards -->
        <div class="row mb-4">
            <div class="col-md-3">
                <div class="stats-card">
                    <div class="d-flex align-items-center">
                        <div class="flex-grow-1">
                            <div class="stats-number">${userStats.total}</div>
                            <div class="text-muted">Tổng người dùng</div>
                        </div>
                        <div class="text-primary">
                            <i class="fas fa-users fa-2x"></i>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stats-card">
                    <div class="d-flex align-items-center">
                        <div class="flex-grow-1">
                            <div class="stats-number text-success">${userStats.active}</div>
                            <div class="text-muted">Đang hoạt động</div>
                        </div>
                        <div class="text-success">
                            <i class="fas fa-user-check fa-2x"></i>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stats-card">
                    <div class="d-flex align-items-center">
                        <div class="flex-grow-1">
                            <div class="stats-number text-warning">${userStats.inactive}</div>
                            <div class="text-muted">Không hoạt động</div>
                        </div>
                        <div class="text-warning">
                            <i class="fas fa-user-clock fa-2x"></i>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stats-card">
                    <div class="d-flex align-items-center">
                        <div class="flex-grow-1">
                            <div class="stats-number text-danger">${userStats.suspended}</div>
                            <div class="text-muted">Bị khóa</div>
                        </div>
                        <div class="text-danger">
                            <i class="fas fa-user-slash fa-2x"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Search and Filter -->
        <div class="search-card">
            <form method="get" action="/users" class="row g-3">
                <div class="col-md-4">
                    <label for="search" class="form-label">Tìm kiếm</label>
                    <input type="text" class="form-control" id="search" name="search" 
                           value="${search}" placeholder="Tên đăng nhập, email, họ tên...">
                </div>
                <div class="col-md-3">
                    <label for="status" class="form-label">Trạng thái</label>
                    <select class="form-select" id="status" name="status">
                        <option value="">Tất cả trạng thái</option>
                        <option value="active" ${status == 'active' ? 'selected' : ''}>Hoạt động</option>
                        <option value="inactive" ${status == 'inactive' ? 'selected' : ''}>Không hoạt động</option>
                        <option value="suspended" ${status == 'suspended' ? 'selected' : ''}>Bị khóa</option>
                    </select>
                </div>
                <div class="col-md-3">
                    <label for="role" class="form-label">Vai trò</label>
                    <select class="form-select" id="role" name="role">
                        <option value="">Tất cả vai trò</option>
                        <option value="BUYER" ${role == 'BUYER' ? 'selected' : ''}>Người mua</option>
                        <option value="SELLER" ${role == 'SELLER' ? 'selected' : ''}>Người bán</option>
                        <option value="ADMIN" ${role == 'ADMIN' ? 'selected' : ''}>Quản trị viên</option>
                        <option value="MODERATOR" ${role == 'MODERATOR' ? 'selected' : ''}>Điều hành viên</option>
                    </select>
                </div>
                <div class="col-md-2">
                    <label class="form-label">&nbsp;</label>
                    <div class="d-grid">
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-search me-1"></i>Tìm kiếm
                        </button>
                    </div>
                </div>
            </form>
        </div>

        <!-- Users Table -->
        <div class="table-card">
            <div class="table-responsive">
                <table class="table table-hover mb-0">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Người dùng</th>
                            <th>Email</th>
                            <th>Vai trò</th>
                            <th>Trạng thái</th>
                            <th>Số dư ví</th>
                            <th>Ngày tạo</th>
                            <th>Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="user" items="${users.content}">
                            <tr>
                                <td>#${user.id}</td>
                                <td>
                                    <div class="d-flex align-items-center">
                                        <c:choose>
                                            <c:when test="${not empty user.avatarUrl}">
                                                <img src="${user.avatarUrl}" alt="Avatar" class="avatar me-3">
                                            </c:when>
                                            <c:otherwise>
                                                <div class="avatar me-3 bg-secondary d-flex align-items-center justify-content-center text-white">
                                                    <i class="fas fa-user"></i>
                                                </div>
                                            </c:otherwise>
                                        </c:choose>
                                        <div>
                                            <div class="fw-bold">${user.displayName}</div>
                                            <small class="text-muted">@${user.username}</small>
                                        </div>
                                    </div>
                                </td>
                                <td>${user.email}</td>
                                <td>
                                    <c:forEach var="role" items="${user.roles}" varStatus="status">
                                        <span class="badge bg-info me-1">${role.name}</span>
                                    </c:forEach>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${user.status == 'ACTIVE' && user.enabled}">
                                            <span class="badge bg-success">Hoạt động</span>
                                        </c:when>
                                        <c:when test="${user.status == 'INACTIVE' || !user.enabled}">
                                            <span class="badge bg-warning">Không hoạt động</span>
                                        </c:when>
                                        <c:when test="${user.status == 'SUSPENDED'}">
                                            <span class="badge bg-danger">Bị khóa</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge bg-secondary">${user.status}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${not empty user.wallet}">
                                            <span class="fw-bold text-success">
                                                <fmt:formatNumber value="${user.wallet.balance}" type="currency" 
                                                                currencySymbol="" maxFractionDigits="0"/> VND
                                            </span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="text-muted">Chưa có ví</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${not empty user.createdAt}">
                                            ${fn:substring(user.createdAt.toString().replace('T', ' '), 0, 16)}
                                        </c:when>
                                        <c:otherwise>
                                            <span class="text-muted">N/A</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <div class="btn-group" role="group">
                                        <a href="/users/${user.id}" class="btn btn-sm btn-outline-primary" 
                                           title="Xem chi tiết">
                                            <i class="fas fa-eye"></i>
                                        </a>
                                        <a href="/users/${user.id}/edit" class="btn btn-sm btn-outline-warning" 
                                           title="Chỉnh sửa">
                                            <i class="fas fa-edit"></i>
                                        </a>
                                        <c:if test="${user.enabled}">
                                            <button type="button" class="btn btn-sm btn-outline-danger" 
                                                    onclick="toggleUserStatus(${user.id}, false)" title="Vô hiệu hóa">
                                                <i class="fas fa-ban"></i>
                                            </button>
                                        </c:if>
                                        <c:if test="${!user.enabled}">
                                            <button type="button" class="btn btn-sm btn-outline-success" 
                                                    onclick="toggleUserStatus(${user.id}, true)" title="Kích hoạt">
                                                <i class="fas fa-check"></i>
                                            </button>
                                        </c:if>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                        
                        <c:if test="${empty users.content}">
                            <tr>
                                <td colspan="8" class="text-center py-4">
                                    <i class="fas fa-users fa-3x text-muted mb-3"></i>
                                    <div class="text-muted">Không tìm thấy người dùng nào</div>
                                </td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
            
            <!-- Pagination -->
            <c:if test="${users.totalPages > 1}">
                <div class="d-flex justify-content-between align-items-center p-3">
                    <div class="text-muted">
                        Hiển thị ${users.numberOfElements} trong tổng số ${users.totalElements} người dùng
                    </div>
                    
                    <nav>
                        <ul class="pagination mb-0">
                            <c:if test="${users.hasPrevious()}">
                                <li class="page-item">
                                    <a class="page-link" href="?page=${users.number - 1}&size=${users.size}&search=${search}&status=${status}&role=${role}">
                                        <i class="fas fa-chevron-left"></i>
                                    </a>
                                </li>
                            </c:if>
                            
                            <c:forEach begin="0" end="${users.totalPages - 1}" var="pageNum">
                                <c:if test="${pageNum >= users.number - 2 && pageNum <= users.number + 2}">
                                    <li class="page-item ${pageNum == users.number ? 'active' : ''}">
                                        <a class="page-link" href="?page=${pageNum}&size=${users.size}&search=${search}&status=${status}&role=${role}">
                                            ${pageNum + 1}
                                        </a>
                                    </li>
                                </c:if>
                            </c:forEach>
                            
                            <c:if test="${users.hasNext()}">
                                <li class="page-item">
                                    <a class="page-link" href="?page=${users.number + 1}&size=${users.size}&search=${search}&status=${status}&role=${role}">
                                        <i class="fas fa-chevron-right"></i>
                                    </a>
                                </li>
                            </c:if>
                        </ul>
                    </nav>
                </div>
            </c:if>
        </div>
    </div>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    
    <script>
        function toggleUserStatus(userId, enabled) {
            const action = enabled ? 'kích hoạt' : 'vô hiệu hóa';
            
            if (confirm(`Bạn có chắc chắn muốn ${action} người dùng này?`)) {
                $.ajax({
                    url: `/users/${userId}/toggle-status`,
                    method: 'POST',
                    data: { enabled: enabled },
                    success: function(response) {
                        location.reload();
                    },
                    error: function() {
                        alert('Có lỗi xảy ra. Vui lòng thử lại.');
                    }
                });
            }
        }
        
        // Auto-submit form when filters change
        $('#status, #role').change(function() {
            $(this).closest('form').submit();
        });
    </script>
</body>
</html>
