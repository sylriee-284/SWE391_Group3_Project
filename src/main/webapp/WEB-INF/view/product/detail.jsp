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
                        Product detail
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
                        <br />

                        <div class="container-fluid">
                            <!-- Breadcrumb -->
                            <nav aria-label="breadcrumb">
                                <ol class="breadcrumb">
                                    <li class="breadcrumb-item"><a href="<c:url value='/'/>"
                                            class="text-decoration-none">Trang chủ</a></li>
                                    <li class="breadcrumb-item">
                                        <a href="<c:url value='/category/${product.category.parent.name.toLowerCase()}'/>"
                                            class="text-decoration-none">${product.category.parent.name}</a>
                                    </li>
                                    <li class="breadcrumb-item">
                                        <a href="<c:url value='/category/${product.category.parent.name.toLowerCase()}?childCategory=${product.category.id}'/>"
                                            class="text-decoration-none">${product.category.name}</a>
                                    </li>
                                    <li class="breadcrumb-item active" aria-current="page">${product.name}</li>
                                </ol>
                            </nav>

                            <div class="row">
                                <!-- Product Image -->
                                <div class="col-lg-6 mb-4">
                                    <div class="text-center">
                                        <c:choose>
                                            <c:when test="${not empty product.productUrl}">
                                                <img src="${product.productUrl}" alt="${product.name}"
                                                    class="product-image">
                                            </c:when>
                                            <c:otherwise>
                                                <div class="product-placeholder">
                                                    <div class="text-center">
                                                        <i class="fas fa-image fa-4x text-muted mb-3"></i>
                                                        <p class="text-muted">Chưa có hình ảnh</p>
                                                    </div>
                                                </div>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>

                                <!-- Product Info -->
                                <div class="col-lg-6">
                                    <div class="info-card">
                                        <!-- Product Name -->
                                        <h1 class="mb-3">${product.name}</h1>

                                        <!-- Rating Stars -->
                                        <div class="mb-3">
                                            <div class="rating">
                                                <c:forEach begin="1" end="5" var="star">
                                                    <i
                                                        class="fas fa-star ${star <= product.rating ? 'text-warning' : 'text-muted'}"></i>
                                                </c:forEach>
                                                <span class="ms-2">${product.rating}/5</span>
                                            </div>
                                        </div>

                                        <!-- Category Badge -->
                                        <div class="mb-3">
                                            <span class="badge bg-success fs-6">
                                                <i class="fas fa-tag"></i> ${product.category.name}
                                            </span>
                                        </div>

                                        <!-- Price -->
                                        <div class="mb-4">
                                            <div class="price">
                                                <fmt:formatNumber value="${product.price}" type="currency"
                                                    currencySymbol="" maxFractionDigits="0" />đ
                                            </div>
                                        </div>

                                        <!-- Shop Information -->
                                        <div class="mb-4 shop-info">

                                            <div class="d-flex align-items-center">

                                                <div class="flex-grow-1">

                                                    <h6 class="mb-1 text-dark">Người bán: ${shop.storeName}</h6>


                                                    <div>
                                                        <span
                                                            class="badge ${shop.status == 'ACTIVE' ? 'bg-success' : 'bg-warning'}">
                                                            <i class="fas fa-circle me-1"></i>${shop.status ==
                                                            'ACTIVE' ? 'Đang hoạt động' : 'Tạm ngưng'}
                                                        </span>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>



                                        <!-- Stock Status -->
                                        <div class="mb-4">
                                            <span
                                                class="stock-indicator ${product.stock > 10 ? 'stock-available' : (product.stock > 0 ? 'stock-low' : 'stock-out')}">
                                                <i class="fas fa-boxes"></i>
                                                <c:choose>
                                                    <c:when test="${product.stock > 10}">
                                                        Còn hàng (${product.stock} sản phẩm)
                                                    </c:when>
                                                    <c:when test="${product.stock > 0}">
                                                        Sắp hết hàng (${product.stock} sản phẩm)
                                                    </c:when>
                                                    <c:otherwise>
                                                        Hết hàng
                                                    </c:otherwise>
                                                </c:choose>
                                            </span>
                                        </div>

                                        <!-- Product Status -->
                                        <div class="mb-4">
                                            <span
                                                class="badge ${product.status == 'ACTIVE' ? 'bg-success' : 'bg-warning'} fs-6">
                                                <i class="fas fa-circle"></i>
                                                ${product.status == 'ACTIVE' ? 'Đang bán' : 'Tạm ngưng'}
                                            </span>
                                        </div>

                                        <!-- Quantity and Action Buttons -->
                                        <c:if test="${product.status == 'ACTIVE' && product.stock > 0}">
                                            <div class="action-buttons">
                                                <!-- Quantity Selection -->
                                                <div class="row mb-4">
                                                    <div class="col-md-6">
                                                        <label class="form-label fw-bold">Số lượng:</label>
                                                        <input type="number" id="quantity" name="quantity"
                                                            class="form-control quantity-input" value="1" min="1"
                                                            max="${product.stock}" style="width: 100px;">
                                                    </div>
                                                </div>

                                                <!-- Action Button -->
                                                <div class="d-grid">
                                                    <button type="button" class="btn btn-buy-now btn-lg"
                                                        onclick="buyNow()">
                                                        <i class="fas fa-bolt"></i> Mua ngay
                                                    </button>
                                                </div>
                                            </div>
                                        </c:if>

                                        <c:if test="${product.status != 'ACTIVE' || product.stock <= 0}">
                                            <div class="alert alert-warning text-center">
                                                <i class="fas fa-exclamation-triangle"></i>
                                                Sản phẩm hiện tại không thể mua
                                            </div>
                                        </c:if>
                                    </div>
                                </div>
                            </div>

                            <!-- Product Description -->
                            <div class="row mt-4">
                                <div class="col-12">
                                    <div class="info-card">
                                        <h3 class="mb-3">
                                            <i class="fas fa-info-circle text-success"></i> Mô tả sản phẩm
                                        </h3>
                                        <c:choose>
                                            <c:when test="${not empty product.description}">
                                                <div class="product-description">
                                                    <p>
                                                        ${product.description}</p>
                                                </div>
                                            </c:when>
                                            <c:otherwise>
                                                <p class="text-muted fst-italic">Chưa có mô tả cho sản phẩm này.
                                                </p>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>
                            </div>

                            <!-- ==================== DETAIL MODAL (View) ==================== -->
                            <div class="modal fade" id="detailModal" tabindex="-1" aria-labelledby="detailModalLabel"
                                aria-hidden="true">
                                <div class="modal-dialog modal-lg modal-dialog-centered">
                                    <div class="modal-content">
                                        <div class="modal-header bg-info text-white">
                                            <h5 class="modal-title" id="detailModalLabel">
                                                <i class="bi bi-info-circle-fill"></i> Chi tiết đơn trung gian
                                            </h5>
                                            <button type="button" class="btn-close btn-close-white"
                                                data-bs-dismiss="modal" aria-label="Close"></button>
                                        </div>
                                        <div class="modal-body">
                                            <div class="container-fluid">
                                                <div class="row mb-3">
                                                    <div class="col-md-6">
                                                        <div class="detail-item">
                                                            <label class="detail-label">Mã trung gian:</label>
                                                            <div class="detail-value" id="detail-ma"></div>
                                                        </div>
                                                    </div>
                                                    <div class="col-md-6">
                                                        <div class="detail-item">
                                                            <label class="detail-label">Người bán:</label>
                                                            <div class="detail-value" id="detail-nguoiban"></div>
                                                        </div>
                                                    </div>
                                                </div>
                                                <div class="row mb-3">
                                                    <div class="col-md-12">
                                                        <div class="detail-item">
                                                            <label class="detail-label">Chủ đề trung gian:</label>
                                                            <div class="detail-value" id="detail-chude"></div>
                                                        </div>
                                                    </div>
                                                </div>
                                                <div class="row mb-3">
                                                    <div class="col-md-6">
                                                        <div class="detail-item">
                                                            <label class="detail-label">Phương thức:</label>
                                                            <div class="detail-value" id="detail-phuongthuc"></div>
                                                        </div>
                                                    </div>
                                                    <div class="col-md-6">
                                                        <div class="detail-item">
                                                            <label class="detail-label">Giá tiền:</label>
                                                            <div class="detail-value text-success fw-bold"
                                                                id="detail-giatien"></div>
                                                        </div>
                                                    </div>
                                                </div>
                                                <div class="row mb-3">
                                                    <div class="col-md-4">
                                                        <div class="detail-item">
                                                            <label class="detail-label">Bên chịu phí:</label>
                                                            <div class="detail-value" id="detail-benchiuphi"></div>
                                                        </div>
                                                    </div>
                                                    <div class="col-md-4">
                                                        <div class="detail-item">
                                                            <label class="detail-label">Phí trung gian:</label>
                                                            <div class="detail-value text-warning fw-bold"
                                                                id="detail-phitrunggian"></div>
                                                        </div>
                                                    </div>
                                                    <div class="col-md-4">
                                                        <div class="detail-item">
                                                            <label class="detail-label">Tổng phí cần:</label>
                                                            <div class="detail-value text-danger fw-bold"
                                                                id="detail-tongphi"></div>
                                                        </div>
                                                    </div>
                                                </div>
                                                <div class="row mb-3">
                                                    <div class="col-md-6">
                                                        <div class="detail-item">
                                                            <label class="detail-label">Thời gian tạo:</label>
                                                            <div class="detail-value" id="detail-thoigiantao"></div>
                                                        </div>
                                                    </div>
                                                    <div class="col-md-6">
                                                        <div class="detail-item">
                                                            <label class="detail-label">Cập nhật cuối:</label>
                                                            <div class="detail-value" id="detail-capnhat"></div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="modal-footer">
                                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                                                <i class="bi bi-x-circle"></i> Đóng
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- ==================== ADD MODAL (Create) ==================== -->
                            <div class="modal fade" id="addModal" tabindex="-1" aria-labelledby="addModalLabel"
                                aria-hidden="true">
                                <div class="modal-dialog modal-lg modal-dialog-centered">
                                    <div class="modal-content">
                                        <div class="modal-header bg-success text-white">
                                            <h5 class="modal-title" id="addModalLabel">
                                                <i class="bi bi-plus-circle-fill"></i> Thêm đơn trung gian
                                            </h5>
                                            <button type="button" class="btn-close btn-close-white"
                                                data-bs-dismiss="modal" aria-label="Close"></button>
                                        </div>
                                        <div class="modal-body">
                                            <form id="addForm">
                                                <div class="row mb-3">
                                                    <div class="col-md-6">
                                                        <label class="form-label">Chủ đề trung gian <span
                                                                class="text-danger">*</span></label>
                                                        <input type="text" class="form-control" id="add-chude" required>
                                                    </div>
                                                    <div class="col-md-6">
                                                        <label class="form-label">Phương thức <span
                                                                class="text-danger">*</span></label>
                                                        <input type="text" class="form-control" id="add-phuongthuc"
                                                            required>
                                                    </div>
                                                </div>
                                                <div class="row mb-3">
                                                    <div class="col-md-6">
                                                        <label class="form-label">Giá tiền <span
                                                                class="text-danger">*</span></label>
                                                        <input type="text" class="form-control" id="add-giatien"
                                                            placeholder="VD: 1,000,000" required>
                                                    </div>
                                                    <div class="col-md-6">
                                                        <label class="form-label">Bên chịu phí <span
                                                                class="text-danger">*</span></label>
                                                        <select class="form-select" id="add-benchiuphi" required>
                                                            <option value="">Chọn...</option>
                                                            <option value="Bên bán">Bên bán</option>
                                                            <option value="Bên mua">Bên mua</option>
                                                        </select>
                                                    </div>
                                                </div>
                                                <div class="row mb-3">
                                                    <div class="col-md-6">
                                                        <label class="form-label">Phí trung gian <span
                                                                class="text-danger">*</span></label>
                                                        <input type="text" class="form-control" id="add-phitrunggian"
                                                            placeholder="VD: 50,000" required>
                                                    </div>
                                                    <div class="col-md-6">
                                                        <label class="form-label">Người bán <span
                                                                class="text-danger">*</span></label>
                                                        <input type="text" class="form-control" id="add-nguoiban"
                                                            required>
                                                    </div>
                                                </div>
                                            </form>
                                        </div>
                                        <div class="modal-footer">
                                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                                                <i class="bi bi-x-circle"></i> Hủy
                                            </button>
                                            <button type="button" class="btn btn-success" onclick="handleAdd()">
                                                <i class="bi bi-check-circle"></i> Thêm mới
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- ==================== EDIT MODAL (Update) ==================== -->
                            <div class="modal fade" id="editModal" tabindex="-1" aria-labelledby="editModalLabel"
                                aria-hidden="true">
                                <div class="modal-dialog modal-lg modal-dialog-centered">
                                    <div class="modal-content">
                                        <div class="modal-header bg-warning text-dark">
                                            <h5 class="modal-title" id="editModalLabel">
                                                <i class="bi bi-pencil-fill"></i> Chỉnh sửa đơn trung gian
                                            </h5>
                                            <button type="button" class="btn-close" data-bs-dismiss="modal"
                                                aria-label="Close"></button>
                                        </div>
                                        <div class="modal-body">
                                            <form id="editForm">
                                                <input type="hidden" id="edit-ma">
                                                <div class="row mb-3">
                                                    <div class="col-md-6">
                                                        <label class="form-label">Chủ đề trung gian <span
                                                                class="text-danger">*</span></label>
                                                        <input type="text" class="form-control" id="edit-chude"
                                                            required>
                                                    </div>
                                                    <div class="col-md-6">
                                                        <label class="form-label">Phương thức <span
                                                                class="text-danger">*</span></label>
                                                        <input type="text" class="form-control" id="edit-phuongthuc"
                                                            required>
                                                    </div>
                                                </div>
                                                <div class="row mb-3">
                                                    <div class="col-md-6">
                                                        <label class="form-label">Giá tiền <span
                                                                class="text-danger">*</span></label>
                                                        <input type="text" class="form-control" id="edit-giatien"
                                                            placeholder="VD: 1,000,000" required>
                                                    </div>
                                                    <div class="col-md-6">
                                                        <label class="form-label">Bên chịu phí <span
                                                                class="text-danger">*</span></label>
                                                        <select class="form-select" id="edit-benchiuphi" required>
                                                            <option value="">Chọn...</option>
                                                            <option value="Bên bán">Bên bán</option>
                                                            <option value="Bên mua">Bên mua</option>
                                                        </select>
                                                    </div>
                                                </div>
                                                <div class="row mb-3">
                                                    <div class="col-md-6">
                                                        <label class="form-label">Phí trung gian <span
                                                                class="text-danger">*</span></label>
                                                        <input type="text" class="form-control" id="edit-phitrunggian"
                                                            placeholder="VD: 50,000" required>
                                                    </div>
                                                    <div class="col-md-6">
                                                        <label class="form-label">Người bán <span
                                                                class="text-danger">*</span></label>
                                                        <input type="text" class="form-control" id="edit-nguoiban"
                                                            required>
                                                    </div>
                                                </div>
                                            </form>
                                        </div>
                                        <div class="modal-footer">
                                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                                                <i class="bi bi-x-circle"></i> Hủy
                                            </button>
                                            <button type="button" class="btn btn-warning" onclick="handleEdit()">
                                                <i class="bi bi-check-circle"></i> Cập nhật
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- ==================== DELETE MODAL (Confirm Delete) ==================== -->
                            <div class="modal fade" id="deleteModal" tabindex="-1" aria-labelledby="deleteModalLabel"
                                aria-hidden="true">
                                <div class="modal-dialog modal-dialog-centered">
                                    <div class="modal-content">
                                        <div class="modal-header bg-danger text-white">
                                            <h5 class="modal-title" id="deleteModalLabel">
                                                <i class="bi bi-exclamation-triangle-fill"></i> Xác nhận xóa
                                            </h5>
                                            <button type="button" class="btn-close btn-close-white"
                                                data-bs-dismiss="modal" aria-label="Close"></button>
                                        </div>
                                        <div class="modal-body">
                                            <p class="mb-0">Bạn có chắc chắn muốn xóa đơn trung gian:</p>
                                            <h5 class="text-danger mt-2" id="delete-name"></h5>
                                            <input type="hidden" id="delete-ma">
                                            <p class="text-muted mt-3 mb-0"><small>Hành động này không thể hoàn
                                                    tác!</small></p>
                                        </div>
                                        <div class="modal-footer">
                                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                                                <i class="bi bi-x-circle"></i> Hủy
                                            </button>
                                            <button type="button" class="btn btn-danger" onclick="handleDelete()">
                                                <i class="bi bi-trash-fill"></i> Xóa
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            </div>



                        </div>
                    </div>

                    <script>
                        // Toggle sidebar function
                        function toggleSidebar() {
                            var sidebar = document.getElementById('sidebar');
                            var content = document.getElementById('content');
                            sidebar.classList.toggle('active');
                            content.classList.toggle('shifted');
                        }

                        // Check authentication status
                        var isAuthenticated = <c:choose><c:when test="${pageContext.request.userPrincipal != null}">true</c:when><c:otherwise>false</c:otherwise></c:choose>;

                        // Buy now function - Show modal
                        function buyNow() {
                            // Check if user is authenticated
                            if (!isAuthenticated) {
                                // User not logged in - redirect to login with error message
                                window.location.href = '<c:url value="/login"/>?errorMessage=' + encodeURIComponent('Bạn cần đăng nhập để thực hiện chức năng này');
                                return;
                            }

                            // User is logged in - proceed with buy now
                            var quantity = document.getElementById('quantity').value;
                            document.getElementById('modalQuantity').value = quantity;
                            updateTotalPrice();

                            // Show modal
                            var modal = new bootstrap.Modal(document.getElementById('buyNowModal'));
                            modal.show();
                        }

                        // Update total price in modal
                        function updateTotalPrice() {
                            var quantity = parseInt(document.getElementById('modalQuantity').value) || 1;
                            var price = parseFloat('${product.price}');
                            var total = quantity * price;

                            document.getElementById('totalPrice').textContent =
                                new Intl.NumberFormat('vi-VN').format(total) + 'đ';
                        }

                        // Confirm buy now
                        function confirmBuyNow() {
                            var quantity = document.getElementById('modalQuantity').value;
                            var productName = '${product.name}';
                            var price = parseFloat('${product.price}');
                            var total = quantity * price;

                            // Show confirmation popup
                            if (confirm('Bạn có chắc chắn muốn mua sản phẩm "' + productName + '" với số lượng ' + quantity + ' và tổng tiền ' + new Intl.NumberFormat('vi-VN').format(total) + 'đ?')) {
                                // Close modal
                                var modal = bootstrap.Modal.getInstance(document.getElementById('buyNowModal'));
                                modal.hide();

                                // Redirect to homepage with order modal
                                window.location.href = '<c:url value="/homepage"/>?showOrderModal=true';
                            }
                        }

                        // Validate quantity input
                        document.getElementById('quantity').addEventListener('input', function () {
                            var value = parseInt(this.value);
                            var min = parseInt(this.min);
                            var max = parseInt(this.max);

                            if (value < min) this.value = min;
                            if (value > max) this.value = max;
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
                                timeout: 5000
                            });
                        </script>
                    </c:if>


                    <!-- Buy Now Modal -->
                    <div class="modal fade" id="buyNowModal" tabindex="-1" aria-labelledby="buyNowModalLabel"
                        aria-hidden="true">
                        <div class="modal-dialog modal-dialog-centered">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <h5 class="modal-title" id="buyNowModalLabel">
                                        <i class="fas fa-shopping-cart text-success"></i> Mua ngay
                                    </h5>
                                    <button type="button" class="btn-close" data-bs-dismiss="modal"
                                        aria-label="Close"></button>
                                </div>
                                <div class="modal-body">
                                    <div class="row">
                                        <div class="col-md-4">
                                            <c:choose>
                                                <c:when test="${not empty product.productUrl}">
                                                    <img src="${product.productUrl}" alt="${product.name}"
                                                        class="img-fluid rounded">
                                                </c:when>
                                                <c:otherwise>
                                                    <div class="img-fluid rounded bg-light d-flex align-items-center justify-content-center"
                                                        style="height: 150px;">
                                                        <i class="fas fa-image fa-3x text-muted"></i>
                                                    </div>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                        <div class="col-md-8">
                                            <h6 class="fw-bold">${product.name}</h6>
                                            <p class="text-muted small">${product.category.name}</p>
                                            <div class="d-flex justify-content-between align-items-center">
                                                <span class="h5 text-success mb-0">
                                                    <fmt:formatNumber value="${product.price}" type="currency"
                                                        currencySymbol="" maxFractionDigits="0" />đ
                                                </span>
                                                <span class="text-muted">Kho: ${product.stock}</span>
                                            </div>
                                            <hr>
                                            <div class="mb-3">
                                                <label class="form-label fw-bold">Số lượng:</label>
                                                <input type="number" id="modalQuantity" class="form-control" value="1"
                                                    min="1" max="${product.stock}" style="width: 100px;">
                                            </div>
                                            <div class="d-flex justify-content-between">
                                                <span class="fw-bold">Tổng cộng:</span>
                                                <span class="h6 text-success" id="totalPrice">
                                                    <fmt:formatNumber value="${product.price}" type="currency"
                                                        currencySymbol="" maxFractionDigits="0" />đ
                                                </span>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                                    <button type="button" class="btn btn-success" onclick="confirmBuyNow()">
                                        <i class="fas fa-check"></i> Xác nhận mua
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Include Footer -->
                    <jsp:include page="../common/footer.jsp" />





                    </div>




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

                            // Add event listener for modal quantity change
                            var modalQuantity = document.getElementById('modalQuantity');
                            if (modalQuantity) {
                                modalQuantity.addEventListener('input', updateTotalPrice);
                            }
                        });
                    </script>
                </body>

                </html>