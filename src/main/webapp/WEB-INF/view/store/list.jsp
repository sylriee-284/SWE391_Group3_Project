<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Danh sách Cửa hàng - TaphoaMMO</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        .store-card {
            transition: transform 0.2s, box-shadow 0.2s;
            height: 100%;
        }
        .store-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 25px rgba(0,0,0,0.15);
        }
        .store-logo {
            width: 80px;
            height: 80px;
            object-fit: cover;
            border-radius: 10px;
        }
        .store-stats {
            font-size: 0.9rem;
        }
        .search-filters {
            background: #f8f9fa;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 30px;
        }
    </style>
</head>
<body>
    <div class="container-fluid">
        <!-- Header -->
        <div class="row mb-4">
            <div class="col-12">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <h1 class="h3 mb-0">
                            <i class="fas fa-store text-primary"></i>
                            Danh sách Cửa hàng
                        </h1>
                        <p class="text-muted mb-0">Khám phá các cửa hàng uy tín trên TaphoaMMO</p>
                    </div>
                    <div>
                        <a href="/stores/create" class="btn btn-primary">
                            <i class="fas fa-plus"></i> Tạo cửa hàng
                        </a>
                    </div>
                </div>
            </div>
        </div>

        <!-- Search and Filters -->
        <div class="search-filters">
            <form method="get" action="/stores">
                <div class="row g-3">
                    <div class="col-md-4">
                        <label class="form-label">Tìm kiếm</label>
                        <div class="input-group">
                            <span class="input-group-text"><i class="fas fa-search"></i></span>
                            <input type="text" class="form-control" name="search" 
                                   value="${search}" placeholder="Tên cửa hàng, mô tả...">
                        </div>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Trạng thái</label>
                        <select class="form-select" name="status">
                            <option value="">Tất cả</option>
                            <option value="active" ${status == 'active' ? 'selected' : ''}>Hoạt động</option>
                            <option value="inactive" ${status == 'inactive' ? 'selected' : ''}>Không hoạt động</option>
                            <option value="suspended" ${status == 'suspended' ? 'selected' : ''}>Bị khóa</option>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Sắp xếp</label>
                        <select class="form-select" name="sort">
                            <option value="createdAt" ${sort == 'createdAt' ? 'selected' : ''}>Ngày tạo</option>
                            <option value="storeName" ${sort == 'storeName' ? 'selected' : ''}>Tên cửa hàng</option>
                            <option value="depositAmount" ${sort == 'depositAmount' ? 'selected' : ''}>Deposit</option>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label">Thứ tự</label>
                        <select class="form-select" name="direction">
                            <option value="desc" ${direction == 'desc' ? 'selected' : ''}>Giảm dần</option>
                            <option value="asc" ${direction == 'asc' ? 'selected' : ''}>Tăng dần</option>
                        </select>
                    </div>
                </div>
                <div class="row mt-3">
                    <div class="col-12">
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-search"></i> Tìm kiếm
                        </button>
                        <a href="/stores" class="btn btn-outline-secondary">
                            <i class="fas fa-times"></i> Xóa bộ lọc
                        </a>
                    </div>
                </div>
            </form>
        </div>

        <!-- Results Summary -->
        <div class="row mb-3">
            <div class="col-12">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <span class="text-muted">
                            Hiển thị ${stores.numberOfElements} trong tổng số ${stores.totalElements} cửa hàng
                        </span>
                    </div>
                    <div>
                        <span class="text-muted">Trang ${currentPage + 1} / ${totalPages}</span>
                    </div>
                </div>
            </div>
        </div>

        <!-- Store Grid -->
        <div class="row">
            <c:forEach var="store" items="${stores.content}">
                <div class="col-lg-4 col-md-6 mb-4">
                    <div class="card store-card h-100">
                        <div class="card-body">
                            <!-- Store Header -->
                            <div class="d-flex align-items-start mb-3">
                                <div class="me-3">
                                    <c:choose>
                                        <c:when test="${not empty store.storeLogoUrl}">
                                            <img src="${store.storeLogoUrl}" alt="Logo" class="store-logo">
                                        </c:when>
                                        <c:otherwise>
                                            <div class="store-logo bg-primary d-flex align-items-center justify-content-center text-white">
                                                <i class="fas fa-store fa-2x"></i>
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <div class="flex-grow-1">
                                    <h5 class="card-title mb-1">
                                        <a href="/stores/${store.id}" class="text-decoration-none">
                                            ${store.storeName}
                                        </a>
                                    </h5>
                                    <div class="mb-2">
                                        <span class="badge ${store.statusBadgeClass}">${store.statusDisplayText}</span>
                                        <span class="badge ${store.verificationBadgeClass}">${store.verificationStatus}</span>
                                    </div>
                                    <p class="text-muted small mb-0">
                                        Chủ sở hữu: ${store.ownerFullName}
                                    </p>
                                </div>
                            </div>

                            <!-- Store Description -->
                            <c:if test="${not empty store.storeDescription}">
                                <p class="card-text text-muted small">
                                    <c:choose>
                                        <c:when test="${fn:length(store.storeDescription) > 100}">
                                            ${fn:substring(store.storeDescription, 0, 100)}...
                                        </c:when>
                                        <c:otherwise>
                                            ${store.storeDescription}
                                        </c:otherwise>
                                    </c:choose>
                                </p>
                            </c:if>

                            <!-- Store Stats -->
                            <div class="store-stats">
                                <div class="row text-center">
                                    <div class="col-4">
                                        <div class="text-primary fw-bold">${store.totalProducts != null ? store.totalProducts : 0}</div>
                                        <div class="text-muted small">Sản phẩm</div>
                                    </div>
                                    <div class="col-4">
                                        <div class="text-success fw-bold">${store.totalOrders != null ? store.totalOrders : 0}</div>
                                        <div class="text-muted small">Đơn hàng</div>
                                    </div>
                                    <div class="col-4">
                                        <div class="text-warning fw-bold">
                                            <c:choose>
                                                <c:when test="${store.averageRating != null}">
                                                    ${store.formattedAverageRating} <i class="fas fa-star"></i>
                                                </c:when>
                                                <c:otherwise>
                                                    N/A
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                        <div class="text-muted small">Đánh giá</div>
                                    </div>
                                </div>
                            </div>

                            <!-- Financial Info -->
                            <div class="mt-3 pt-3 border-top">
                                <div class="row">
                                    <div class="col-6">
                                        <div class="text-muted small">Deposit</div>
                                        <div class="fw-bold text-primary">${store.formattedDeposit}</div>
                                    </div>
                                    <div class="col-6">
                                        <div class="text-muted small">Giá tối đa</div>
                                        <div class="fw-bold text-success">${store.formattedMaxListingPrice}</div>
                                    </div>
                                </div>
                            </div>

                            <!-- Contact Info -->
                            <c:if test="${not empty store.contactEmail or not empty store.contactPhone}">
                                <div class="mt-3 pt-3 border-top">
                                    <c:if test="${not empty store.contactEmail}">
                                        <div class="text-muted small">
                                            <i class="fas fa-envelope"></i> ${store.contactEmail}
                                        </div>
                                    </c:if>
                                    <c:if test="${not empty store.contactPhone}">
                                        <div class="text-muted small">
                                            <i class="fas fa-phone"></i> ${store.contactPhone}
                                        </div>
                                    </c:if>
                                </div>
                            </c:if>

                            <!-- Created Date -->
                            <div class="mt-3 pt-3 border-top">
                                <div class="text-muted small">
                                    <i class="fas fa-calendar"></i>
                                    Tạo ngày: 
                                    <c:choose>
                                        <c:when test="${not empty store.createdAt}">
                                            ${fn:substring(store.createdAt.toString().replace('T', ' '), 0, 16)}
                                        </c:when>
                                        <c:otherwise>
                                            N/A
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Card Footer -->
                        <div class="card-footer bg-transparent">
                            <div class="d-grid">
                                <a href="/stores/${store.id}" class="btn btn-outline-primary">
                                    <i class="fas fa-eye"></i> Xem chi tiết
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </div>

        <!-- No Results -->
        <c:if test="${stores.totalElements == 0}">
            <div class="row">
                <div class="col-12">
                    <div class="text-center py-5">
                        <i class="fas fa-store fa-3x text-muted mb-3"></i>
                        <h4 class="text-muted">Không tìm thấy cửa hàng nào</h4>
                        <p class="text-muted">Thử thay đổi bộ lọc hoặc từ khóa tìm kiếm</p>
                        <a href="/stores" class="btn btn-primary">Xem tất cả cửa hàng</a>
                    </div>
                </div>
            </div>
        </c:if>

        <!-- Pagination -->
        <c:if test="${totalPages > 1}">
            <div class="row mt-4">
                <div class="col-12">
                    <nav aria-label="Store pagination">
                        <ul class="pagination justify-content-center">
                            <!-- Previous -->
                            <li class="page-item ${currentPage == 0 ? 'disabled' : ''}">
                                <a class="page-link" href="?page=${currentPage - 1}&size=12&sort=${sort}&direction=${direction}&search=${search}&status=${status}">
                                    <i class="fas fa-chevron-left"></i>
                                </a>
                            </li>

                            <!-- Page Numbers -->
                            <c:forEach begin="0" end="${totalPages - 1}" var="pageNum">
                                <c:if test="${pageNum >= currentPage - 2 && pageNum <= currentPage + 2}">
                                    <li class="page-item ${pageNum == currentPage ? 'active' : ''}">
                                        <a class="page-link" href="?page=${pageNum}&size=12&sort=${sort}&direction=${direction}&search=${search}&status=${status}">
                                            ${pageNum + 1}
                                        </a>
                                    </li>
                                </c:if>
                            </c:forEach>

                            <!-- Next -->
                            <li class="page-item ${currentPage == totalPages - 1 ? 'disabled' : ''}">
                                <a class="page-link" href="?page=${currentPage + 1}&size=12&sort=${sort}&direction=${direction}&search=${search}&status=${status}">
                                    <i class="fas fa-chevron-right"></i>
                                </a>
                            </li>
                        </ul>
                    </nav>
                </div>
            </div>
        </c:if>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
