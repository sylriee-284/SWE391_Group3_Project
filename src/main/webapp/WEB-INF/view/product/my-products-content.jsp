<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!-- My Products Content (Seller Dashboard) -->

<div class="row mb-4">
    <div class="col">
        <h2><i class="fas fa-boxes"></i> Quản lý Sản phẩm của tôi</h2>
        <p class="text-muted">Quản lý và theo dõi sản phẩm của bạn</p>
    </div>
    <div class="col-auto">
        <a href="/products/create" class="btn btn-primary">
            <i class="fas fa-plus"></i> Thêm sản phẩm mới
        </a>
    </div>
</div>

<!-- Statistics -->
<div class="row g-3 mb-4">
    <div class="col-md-3">
        <div class="card stats-card">
            <div class="d-flex justify-content-between align-items-center">
                <div>
                    <h3>${totalProducts}</h3>
                    <p class="mb-0">Tổng sản phẩm</p>
                </div>
                <i class="fas fa-box fa-3x opacity-50"></i>
            </div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card stats-card success">
            <div class="d-flex justify-content-between align-items-center">
                <div>
                    <h3>${activeProducts}</h3>
                    <p class="mb-0">Đang hoạt động</p>
                </div>
                <i class="fas fa-check-circle fa-3x opacity-50"></i>
            </div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card stats-card warning">
            <div class="d-flex justify-content-between align-items-center">
                <div>
                    <h3>${fn:length(lowStockProducts)}</h3>
                    <p class="mb-0">Sắp hết hàng</p>
                </div>
                <i class="fas fa-exclamation-triangle fa-3x opacity-50"></i>
            </div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card stats-card danger">
            <div class="d-flex justify-content-between align-items-center">
                <div>
                    <h3>${fn:length(outOfStockProducts)}</h3>
                    <p class="mb-0">Hết hàng</p>
                </div>
                <i class="fas fa-times-circle fa-3x opacity-50"></i>
            </div>
        </div>
    </div>
</div>

<!-- Products Table -->
<div class="card">
    <div class="card-header">
        <h5 class="mb-0"><i class="fas fa-list"></i> Danh sách sản phẩm</h5>
    </div>
    <div class="card-body">
        <c:choose>
            <c:when test="${empty products.content}">
                <div class="text-center py-5">
                    <i class="fas fa-box-open fa-5x text-muted mb-3"></i>
                    <h4>Chưa có sản phẩm nào</h4>
                    <p class="text-muted">Hãy bắt đầu thêm sản phẩm đầu tiên của bạn!</p>
                    <a href="/products/create" class="btn btn-primary">
                        <i class="fas fa-plus"></i> Thêm sản phẩm
                    </a>
                </div>
            </c:when>
            <c:otherwise>
                <div class="table-responsive">
                    <table class="table table-hover">
                        <thead>
                            <tr>
                                <th>SKU</th>
                                <th>Tên sản phẩm</th>
                                <th>Danh mục</th>
                                <th>Giá</th>
                                <th>Tồn kho</th>
                                <th>Trạng thái</th>
                                <th>Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach items="${products.content}" var="product">
                                <tr>
                                    <td><code>${product.sku}</code></td>
                                    <td><strong>${product.productName}</strong></td>
                                    <td><span class="badge bg-info">${product.categoryDisplayName}</span></td>
                                    <td><strong>${product.formattedPrice}</strong></td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${product.stockQuantity == 0}">
                                                <span class="badge bg-danger">Hết hàng</span>
                                            </c:when>
                                            <c:when test="${product.stockQuantity <= 10}">
                                                <span class="badge bg-warning text-dark">${product.stockQuantity}</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-success">${product.stockQuantity}</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${product.isActive}">
                                                <span class="badge bg-success">Đang bán</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-secondary">Tạm ngưng</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <div class="btn-group btn-group-sm">
                                            <a href="/products/${product.id}" class="btn btn-info" title="Xem">
                                                <i class="fas fa-eye"></i>
                                            </a>
                                            <a href="/products/${product.id}/edit" class="btn btn-warning" title="Sửa">
                                                <i class="fas fa-edit"></i>
                                            </a>
                                            <form method="post" action="/products/${product.id}/toggle-status" style="display: inline;">
                                                <button type="submit" class="btn btn-secondary" title="Bật/Tắt">
                                                    <i class="fas fa-power-off"></i>
                                                </button>
                                            </form>
                                            <form method="post" action="/products/${product.id}/delete"
                                                  onsubmit="return confirm('Bạn có chắc muốn xóa sản phẩm này?');" style="display: inline;">
                                                <button type="submit" class="btn btn-danger" title="Xóa">
                                                    <i class="fas fa-trash"></i>
                                                </button>
                                            </form>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>

                <!-- Pagination -->
                <c:if test="${totalPages > 1}">
                    <nav class="mt-3">
                        <ul class="pagination justify-content-center">
                            <li class="page-item ${currentPage == 0 ? 'disabled' : ''}">
                                <a class="page-link" href="?page=${currentPage - 1}">Trước</a>
                            </li>
                            <c:forEach begin="0" end="${totalPages - 1}" var="i">
                                <li class="page-item ${currentPage == i ? 'active' : ''}">
                                    <a class="page-link" href="?page=${i}">${i + 1}</a>
                                </li>
                            </c:forEach>
                            <li class="page-item ${currentPage == totalPages - 1 ? 'disabled' : ''}">
                                <a class="page-link" href="?page=${currentPage + 1}">Sau</a>
                            </li>
                        </ul>
                    </nav>
                </c:if>
            </c:otherwise>
        </c:choose>
    </div>
</div>
