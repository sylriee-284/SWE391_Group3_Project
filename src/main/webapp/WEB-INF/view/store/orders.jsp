<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Quản lý Đơn hàng - ${store.storeName}" scope="request" />

<!-- Store Orders Specific Styles -->
<c:set var="additionalCSS" scope="request">
    <style>
        .orders-container {
            max-width: 1200px;
            margin: 0 auto;
        }
        .orders-card {
            background: white;
            border-radius: 15px;
            padding: 25px;
            margin-bottom: 25px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.08);
        }
        .order-item {
            border: 1px solid #e9ecef;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 15px;
            transition: all 0.3s ease;
        }
        .order-item:hover {
            box-shadow: 0 3px 10px rgba(0,0,0,0.1);
        }
        .status-badge {
            font-size: 0.8rem;
            padding: 5px 10px;
        }
        .empty-state {
            text-align: center;
            padding: 60px 20px;
            color: #6c757d;
        }
    </style>
</c:set>

<!-- Include Sidebar Layout -->
<%@ include file="../sidebar.jsp" %>

<!-- Store Orders JavaScript -->
<c:set var="additionalJS" scope="request">
    <script>
        // Add store orders content to the main content area
        document.addEventListener('DOMContentLoaded', function() {
            const pageContent = document.getElementById('pageContent');
            pageContent.innerHTML = \`
                <div class="container py-5">
                    <div class="orders-container">

                        <!-- Header -->
                        <div class="d-flex justify-content-between align-items-center mb-4">
                            <div>
                                <h1 class="h2 text-primary">
                                    <i class="fas fa-shopping-cart"></i>
                                    Quản lý Đơn hàng
                                </h1>
                                <p class="text-muted mb-0">Theo dõi và xử lý đơn hàng của cửa hàng \${store.storeName}</p>
                            </div>
                            <div>
                                <a href="/stores/my-store" class="btn btn-outline-primary">
                                    <i class="fas fa-arrow-left"></i> Quay lại Dashboard
                                </a>
                            </div>
                        </div>

                        <!-- Filter and Search -->
                        <div class="orders-card">
                            <div class="row align-items-center">
                                <div class="col-md-6">
                                    <div class="input-group">
                                        <span class="input-group-text">
                                            <i class="fas fa-search"></i>
                                        </span>
                                        <input type="text" class="form-control" placeholder="Tìm kiếm đơn hàng..." id="searchInput">
                                    </div>
                                </div>
                                <div class="col-md-3">
                                    <select class="form-select" id="statusFilter">
                                        <option value="">Tất cả trạng thái</option>
                                        <option value="pending">Chờ xử lý</option>
                                        <option value="processing">Đang xử lý</option>
                                        <option value="completed">Hoàn thành</option>
                                        <option value="cancelled">Đã hủy</option>
                                    </select>
                                </div>
                                <div class="col-md-3">
                                    <select class="form-select" id="dateFilter">
                                        <option value="">Tất cả thời gian</option>
                                        <option value="today">Hôm nay</option>
                                        <option value="week">Tuần này</option>
                                        <option value="month">Tháng này</option>
                                    </select>
                                </div>
                            </div>
                        </div>

                        <!-- Orders List -->
                        <div class="orders-card">
                            <h4 class="mb-4">
                                <i class="fas fa-list"></i>
                                Danh sách đơn hàng
                            </h4>

                            <!-- Empty State -->
                            <div class="empty-state">
                                <i class="fas fa-inbox fa-4x mb-3"></i>
                                <h4>Chưa có đơn hàng nào</h4>
                                <p class="mb-4">
                                    Cửa hàng của bạn chưa nhận được đơn hàng nào.
                                    Hãy thêm sản phẩm và quảng bá để thu hút khách hàng!
                                </p>
                                <div class="d-flex justify-content-center gap-2">
                                    <a href="/stores/my-store/inventory" class="btn btn-primary">
                                        <i class="fas fa-plus"></i> Thêm sản phẩm
                                    </a>
                                    <a href="/help/selling-tips" class="btn btn-outline-info">
                                        <i class="fas fa-lightbulb"></i> Mẹo bán hàng
                                    </a>
                                </div>
                            </div>

                            <!-- Sample Order Item (hidden by default, will be shown when orders exist) -->
                            <div class="order-item d-none" id="sampleOrder">
                                <div class="row align-items-center">
                                    <div class="col-md-2">
                                        <strong>#ORD001</strong>
                                        <br>
                                        <small class="text-muted">01/01/2024</small>
                                    </div>
                                    <div class="col-md-3">
                                        <div class="d-flex align-items-center">
                                            <img src="/images/default-product.png" alt="Product" class="rounded me-2" width="40" height="40">
                                            <div>
                                                <div class="fw-bold">Tên sản phẩm</div>
                                                <small class="text-muted">Số lượng: 1</small>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-2">
                                        <div class="fw-bold">100,000 VND</div>
                                    </div>
                                    <div class="col-md-2">
                                        <span class="badge bg-warning status-badge">Chờ xử lý</span>
                                    </div>
                                    <div class="col-md-3 text-end">
                                        <div class="btn-group btn-group-sm">
                                            <button class="btn btn-outline-primary" title="Xem chi tiết">
                                                <i class="fas fa-eye"></i>
                                            </button>
                                            <button class="btn btn-outline-success" title="Xử lý">
                                                <i class="fas fa-check"></i>
                                            </button>
                                            <button class="btn btn-outline-danger" title="Hủy">
                                                <i class="fas fa-times"></i>
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Quick Stats -->
                        <div class="orders-card">
                            <h4 class="mb-4">
                                <i class="fas fa-chart-pie"></i>
                                Thống kê nhanh
                            </h4>
                            <div class="row text-center">
                                <div class="col-md-3">
                                    <div class="border rounded p-3">
                                        <div class="h4 text-warning mb-1">0</div>
                                        <small class="text-muted">Chờ xử lý</small>
                                    </div>
                                </div>
                                <div class="col-md-3">
                                    <div class="border rounded p-3">
                                        <div class="h4 text-info mb-1">0</div>
                                        <small class="text-muted">Đang xử lý</small>
                                    </div>
                                </div>
                                <div class="col-md-3">
                                    <div class="border rounded p-3">
                                        <div class="h4 text-success mb-1">0</div>
                                        <small class="text-muted">Hoàn thành</small>
                                    </div>
                                </div>
                                <div class="col-md-3">
                                    <div class="border rounded p-3">
                                        <div class="h4 text-danger mb-1">0</div>
                                        <small class="text-muted">Đã hủy</small>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Coming Soon Notice -->
                        <div class="orders-card">
                            <div class="alert alert-info">
                                <div class="d-flex align-items-center">
                                    <i class="fas fa-info-circle fa-2x me-3"></i>
                                    <div>
                                        <h6 class="alert-heading mb-1">Tính năng đang phát triển</h6>
                                        <p class="mb-0">
                                            Hệ thống quản lý đơn hàng sẽ được triển khai sau khi hoàn thiện module sản phẩm và thanh toán.
                                        </p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            \`;

            // Initialize store orders functionality
            initializeStoreOrders();
        });

        function initializeStoreOrders() {
            // Search functionality (placeholder)
            const searchInput = document.getElementById('searchInput');
            if (searchInput) {
                searchInput.addEventListener('input', function() {
                    // TODO: Implement search when orders are available
                    console.log('Searching for:', this.value);
                });
            }

            // Filter functionality (placeholder)
            const statusFilter = document.getElementById('statusFilter');
            if (statusFilter) {
                statusFilter.addEventListener('change', function() {
                    // TODO: Implement status filter when orders are available
                    console.log('Filter by status:', this.value);
                });
            }

            const dateFilter = document.getElementById('dateFilter');
            if (dateFilter) {
                dateFilter.addEventListener('change', function() {
                    // TODO: Implement date filter when orders are available
                    console.log('Filter by date:', this.value);
                });
            }
        }
    </script>
</c:set>
