<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Quản lý Kho hàng - ${store.storeName}" scope="request" />

<!-- Store Inventory Specific Styles -->
<c:set var="additionalCSS" scope="request">
    <style>
        .inventory-container {
            max-width: 1200px;
            margin: 0 auto;
        }
        .inventory-card {
            background: white;
            border-radius: 15px;
            padding: 25px;
            margin-bottom: 25px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.08);
        }
        .product-item {
            border: 1px solid #e9ecef;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 15px;
            transition: all 0.3s ease;
        }
        .product-item:hover {
            box-shadow: 0 3px 10px rgba(0,0,0,0.1);
        }
        .product-image {
            width: 60px;
            height: 60px;
            object-fit: cover;
            border-radius: 8px;
        }
        .stock-badge {
            font-size: 0.8rem;
            padding: 5px 10px;
        }
        .empty-state {
            text-align: center;
            padding: 60px 20px;
            color: #6c757d;
        }
        .add-product-card {
            border: 2px dashed #dee2e6;
            background: #f8f9fa;
            text-align: center;
            padding: 40px 20px;
            border-radius: 15px;
            transition: all 0.3s ease;
        }
        .add-product-card:hover {
            border-color: #007bff;
            background: #e7f3ff;
        }
    </style>
</c:set>

<!-- Include Sidebar Layout -->
<%@ include file="../sidebar.jsp" %>

<!-- Store Inventory JavaScript -->
<c:set var="additionalJS" scope="request">
    <script>
        // Add store inventory content to the main content area
        document.addEventListener('DOMContentLoaded', function() {
            const pageContent = document.getElementById('pageContent');
            pageContent.innerHTML = \`
                <div class="container py-5">
                    <div class="inventory-container">

                        <!-- Header -->
                        <div class="d-flex justify-content-between align-items-center mb-4">
                            <div>
                                <h1 class="h2 text-primary">
                                    <i class="fas fa-boxes"></i>
                                    Quản lý Kho hàng
                                </h1>
                                <p class="text-muted mb-0">Quản lý sản phẩm và tồn kho của cửa hàng \${store.storeName}</p>
                            </div>
                            <div>
                                <a href="/stores/my-store" class="btn btn-outline-primary">
                                    <i class="fas fa-arrow-left"></i> Quay lại Dashboard
                                </a>
                            </div>
                        </div>

                        <!-- Quick Stats -->
                        <div class="inventory-card">
                            <div class="row text-center">
                                <div class="col-md-3">
                                    <div class="border rounded p-3">
                                        <div class="h4 text-primary mb-1">0</div>
                                        <small class="text-muted">Tổng sản phẩm</small>
                                    </div>
                                </div>
                                <div class="col-md-3">
                                    <div class="border rounded p-3">
                                        <div class="h4 text-success mb-1">0</div>
                                        <small class="text-muted">Đang bán</small>
                                    </div>
                                </div>
                                <div class="col-md-3">
                                    <div class="border rounded p-3">
                                        <div class="h4 text-warning mb-1">0</div>
                                        <small class="text-muted">Hết hàng</small>
                                    </div>
                                </div>
                                <div class="col-md-3">
                                    <div class="border rounded p-3">
                                        <div class="h4 text-info mb-1">\${store.formattedMaxPrice}</div>
                                        <small class="text-muted">Giá tối đa</small>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Add Product Card -->
                        <div class="add-product-card mb-4">
                            <i class="fas fa-plus-circle fa-3x text-primary mb-3"></i>
                            <h4>Thêm sản phẩm mới</h4>
                            <p class="text-muted mb-4">
                                Bắt đầu bán hàng bằng cách thêm sản phẩm đầu tiên của bạn
                            </p>
                            <button class="btn btn-primary btn-lg" disabled>
                                <i class="fas fa-plus"></i> Thêm sản phẩm
                            </button>
                            <div class="mt-3">
                                <small class="text-muted">
                                    <i class="fas fa-info-circle"></i>
                                    Tính năng sẽ khả dụng sau khi hoàn thiện module sản phẩm
                                </small>
                            </div>
                        </div>

                        <!-- Filter and Search -->
                        <div class="inventory-card">
                            <div class="row align-items-center">
                                <div class="col-md-6">
                                    <div class="input-group">
                                        <span class="input-group-text">
                                            <i class="fas fa-search"></i>
                                        </span>
                                        <input type="text" class="form-control" placeholder="Tìm kiếm sản phẩm..." id="searchInput">
                                    </div>
                                </div>
                                <div class="col-md-3">
                                    <select class="form-select" id="categoryFilter">
                                        <option value="">Tất cả danh mục</option>
                                        <option value="accounts">Tài khoản</option>
                                        <option value="tools">Công cụ MMO</option>
                                        <option value="services">Dịch vụ</option>
                                        <option value="other">Khác</option>
                                    </select>
                                </div>
                                <div class="col-md-3">
                                    <select class="form-select" id="statusFilter">
                                        <option value="">Tất cả trạng thái</option>
                                        <option value="active">Đang bán</option>
                                        <option value="inactive">Ngưng bán</option>
                                        <option value="out_of_stock">Hết hàng</option>
                                    </select>
                                </div>
                            </div>
                        </div>

                        <!-- Products List -->
                        <div class="inventory-card">
                            <div class="d-flex justify-content-between align-items-center mb-4">
                                <h4>
                                    <i class="fas fa-list"></i>
                                    Danh sách sản phẩm
                                </h4>
                                <div class="btn-group btn-group-sm">
                                    <button class="btn btn-outline-secondary active" data-view="list">
                                        <i class="fas fa-list"></i>
                                    </button>
                                    <button class="btn btn-outline-secondary" data-view="grid">
                                        <i class="fas fa-th"></i>
                                    </button>
                                </div>
                            </div>

                            <!-- Empty State -->
                            <div class="empty-state">
                                <i class="fas fa-box-open fa-4x mb-3"></i>
                                <h4>Chưa có sản phẩm nào</h4>
                                <p class="mb-4">
                                    Cửa hàng của bạn chưa có sản phẩm nào.
                                    Hãy thêm sản phẩm đầu tiên để bắt đầu kinh doanh!
                                </p>
                                <div class="d-flex justify-content-center gap-2">
                                    <button class="btn btn-primary" disabled>
                                        <i class="fas fa-plus"></i> Thêm sản phẩm đầu tiên
                                    </button>
                                    <a href="/help/product-guidelines" class="btn btn-outline-info">
                                        <i class="fas fa-question-circle"></i> Hướng dẫn đăng bán
                                    </a>
                                </div>
                            </div>

                            <!-- Sample Product Item (hidden by default, will be shown when products exist) -->
                            <div class="product-item d-none" id="sampleProduct">
                                <div class="row align-items-center">
                                    <div class="col-md-1">
                                        <img src="/images/default-product.png" alt="Product" class="product-image">
                                    </div>
                                    <div class="col-md-4">
                                        <div class="fw-bold">Tên sản phẩm</div>
                                        <small class="text-muted">Mô tả ngắn sản phẩm...</small>
                                        <br>
                                        <span class="badge bg-secondary">Danh mục</span>
                                    </div>
                                    <div class="col-md-2">
                                        <div class="fw-bold text-success">100,000 VND</div>
                                        <small class="text-muted">Giá bán</small>
                                    </div>
                                    <div class="col-md-2">
                                        <span class="badge bg-success stock-badge">Còn hàng</span>
                                        <br>
                                        <small class="text-muted">Số lượng: 10</small>
                                    </div>
                                    <div class="col-md-2">
                                        <small class="text-muted">Đã bán: 0</small>
                                        <br>
                                        <small class="text-muted">Lượt xem: 0</small>
                                    </div>
                                    <div class="col-md-1 text-end">
                                        <div class="btn-group btn-group-sm">
                                            <button class="btn btn-outline-primary" title="Chỉnh sửa">
                                                <i class="fas fa-edit"></i>
                                            </button>
                                            <button class="btn btn-outline-danger" title="Xóa">
                                                <i class="fas fa-trash"></i>
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Coming Soon Notice -->
                        <div class="inventory-card">
                            <div class="alert alert-info">
                                <div class="d-flex align-items-center">
                                    <i class="fas fa-info-circle fa-2x me-3"></i>
                                    <div>
                                        <h6 class="alert-heading mb-1">Tính năng đang phát triển</h6>
                                        <p class="mb-0">
                                            Hệ thống quản lý sản phẩm sẽ được triển khai trong giai đoạn tiếp theo.
                                            Hiện tại bạn có thể quản lý thông tin cửa hàng và theo dõi số dư tài khoản.
                                        </p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            \`;

            // Initialize store inventory functionality
            initializeStoreInventory();
        });

        function initializeStoreInventory() {
            // View toggle functionality
            document.querySelectorAll('[data-view]').forEach(button => {
                button.addEventListener('click', function() {
                    document.querySelectorAll('[data-view]').forEach(btn => btn.classList.remove('active'));
                    this.classList.add('active');

                    const view = this.getAttribute('data-view');
                    // TODO: Implement view switching when products are available
                    console.log('Switching to view:', view);
                });
            });

            // Search functionality (placeholder)
            const searchInput = document.getElementById('searchInput');
            if (searchInput) {
                searchInput.addEventListener('input', function() {
                    // TODO: Implement search when products are available
                    console.log('Searching for:', this.value);
                });
            }

            // Filter functionality (placeholder)
            const categoryFilter = document.getElementById('categoryFilter');
            if (categoryFilter) {
                categoryFilter.addEventListener('change', function() {
                    // TODO: Implement category filter when products are available
                    console.log('Filter by category:', this.value);
                });
            }

            const statusFilter = document.getElementById('statusFilter');
            if (statusFilter) {
                statusFilter.addEventListener('change', function() {
                    // TODO: Implement status filter when products are available
                    console.log('Filter by status:', this.value);
                });
            }
        }
    </script>
</c:set>
