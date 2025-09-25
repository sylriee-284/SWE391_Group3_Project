<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <html lang="en">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Document</title>
            <!-- Latest compiled and minified CSS -->
            <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

            <!-- Latest compiled JavaScript -->
            <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

            <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>

            <title>Dashboard</title>
            <style>
                /* Nội dung chính */
                .content {
                    flex-grow: 1;
                    padding: 20px;
                    background-color: #f8f9fa;
                    margin-left: 0;
                    transition: margin-left 0.3s ease;
                    min-height: 100vh;
                }

                .content.shifted {
                    margin-left: 250px;
                    /* Đẩy nội dung sang phải khi sidebar bật */
                }

                .content h1 {
                    font-size: 28px;
                    color: #2c3e50;
                }

                /* Dashboard Cards */
                .card {
                    border: none;
                    border-radius: 10px;
                    box-shadow: 0 0.15rem 1.75rem 0 rgba(58, 59, 69, 0.15);
                    margin-bottom: 1.5rem;
                }

                .card-header {
                    background-color: #f8f9fa;
                    border-bottom: 1px solid #e3e6f0;
                    border-radius: 10px 10px 0 0 !important;
                }

                .border-left-primary {
                    border-left: 0.25rem solid #4e73df !important;
                }

                .border-left-success {
                    border-left: 0.25rem solid #1cc88a !important;
                }

                .border-left-info {
                    border-left: 0.25rem solid #36b9cc !important;
                }

                .border-left-warning {
                    border-left: 0.25rem solid #f6c23e !important;
                }

                .text-primary {
                    color: #4e73df !important;
                }

                .text-success {
                    color: #1cc88a !important;
                }

                .text-info {
                    color: #36b9cc !important;
                }

                .text-warning {
                    color: #f6c23e !important;
                }

                .text-gray-800 {
                    color: #5a5c69 !important;
                }

                .text-gray-300 {
                    color: #dddfeb !important;
                }

                .btn-block {
                    width: 100%;
                    margin-bottom: 0.5rem;
                }

                .btn {
                    border-radius: 8px;
                    font-weight: 600;
                    padding: 0.75rem 1rem;
                }

                .badge {
                    font-size: 0.75em;
                    padding: 0.5em 0.75em;
                    border-radius: 10px;
                }

                /* Responsive Design */
                @media (max-width: 768px) {
                    .content {
                        margin-left: 0;
                        padding: 15px;
                    }

                    .content.shifted {
                        margin-left: 0;
                    }
                }

                @media (max-width: 480px) {
                    .content {
                        padding: 10px;
                    }
                }
            </style>

        </head>

        <body>

            <!-- Include Navbar -->
            <%@ include file="navbar.jsp" %>

                <!-- Include Sidebar -->
                <%@ include file="sidebar.jsp" %>

                    <!-- Nội dung chính -->
                    <div class="content" id="content">
                        <div class="container-fluid">
                            <!-- Page Header -->
                            <div class="d-flex justify-content-between align-items-center mb-4">
                                <div>
                                    <h1 class="h3 mb-0 text-gray-800">Dashboard</h1>
                                    <p class="mb-0 text-muted">Tổng quan hệ thống TaphoaMMO</p>
                                </div>
                                <div>
                                    <span class="badge bg-success">Hệ thống hoạt động</span>
                                </div>
                            </div>

                            <!-- Statistics Cards -->
                            <div class="row mb-4">
                                <div class="col-xl-3 col-md-6 mb-4">
                                    <div class="card border-left-primary shadow h-100 py-2">
                                        <div class="card-body">
                                            <div class="row no-gutters align-items-center">
                                                <div class="col mr-2">
                                                    <div class="text-xs font-weight-bold text-primary text-uppercase mb-1">
                                                        Tổng người dùng
                                                    </div>
                                                    <div class="h5 mb-0 font-weight-bold text-gray-800">0</div>
                                                </div>
                                                <div class="col-auto">
                                                    <i class="fas fa-users fa-2x text-gray-300"></i>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <div class="col-xl-3 col-md-6 mb-4">
                                    <div class="card border-left-success shadow h-100 py-2">
                                        <div class="card-body">
                                            <div class="row no-gutters align-items-center">
                                                <div class="col mr-2">
                                                    <div class="text-xs font-weight-bold text-success text-uppercase mb-1">
                                                        Cửa hàng hoạt động
                                                    </div>
                                                    <div class="h5 mb-0 font-weight-bold text-gray-800">0</div>
                                                </div>
                                                <div class="col-auto">
                                                    <i class="fas fa-store fa-2x text-gray-300"></i>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <div class="col-xl-3 col-md-6 mb-4">
                                    <div class="card border-left-info shadow h-100 py-2">
                                        <div class="card-body">
                                            <div class="row no-gutters align-items-center">
                                                <div class="col mr-2">
                                                    <div class="text-xs font-weight-bold text-info text-uppercase mb-1">
                                                        Đơn hàng hôm nay
                                                    </div>
                                                    <div class="h5 mb-0 font-weight-bold text-gray-800">0</div>
                                                </div>
                                                <div class="col-auto">
                                                    <i class="fas fa-shopping-cart fa-2x text-gray-300"></i>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <div class="col-xl-3 col-md-6 mb-4">
                                    <div class="card border-left-warning shadow h-100 py-2">
                                        <div class="card-body">
                                            <div class="row no-gutters align-items-center">
                                                <div class="col mr-2">
                                                    <div class="text-xs font-weight-bold text-warning text-uppercase mb-1">
                                                        Doanh thu tháng
                                                    </div>
                                                    <div class="h5 mb-0 font-weight-bold text-gray-800">0 VND</div>
                                                </div>
                                                <div class="col-auto">
                                                    <i class="fas fa-dollar-sign fa-2x text-gray-300"></i>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Quick Actions -->
                            <div class="row mb-4">
                                <div class="col-lg-6">
                                    <div class="card shadow">
                                        <div class="card-header py-3">
                                            <h6 class="m-0 font-weight-bold text-primary">
                                                <i class="fas fa-bolt me-2"></i>Thao tác nhanh
                                            </h6>
                                        </div>
                                        <div class="card-body">
                                            <div class="row">
                                                <div class="col-md-6 mb-3">
                                                    <a href="/users" class="btn btn-primary btn-block">
                                                        <i class="fas fa-users me-2"></i>Quản lý người dùng
                                                    </a>
                                                </div>
                                                <div class="col-md-6 mb-3">
                                                    <a href="/users/register" class="btn btn-success btn-block">
                                                        <i class="fas fa-user-plus me-2"></i>Thêm người dùng
                                                    </a>
                                                </div>
                                                <div class="col-md-6 mb-3">
                                                    <a href="/stores" class="btn btn-info btn-block">
                                                        <i class="fas fa-store me-2"></i>Quản lý cửa hàng
                                                    </a>
                                                </div>
                                                <div class="col-md-6 mb-3">
                                                    <a href="/products" class="btn btn-warning btn-block">
                                                        <i class="fas fa-box me-2"></i>Quản lý sản phẩm
                                                    </a>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <div class="col-lg-6">
                                    <div class="card shadow">
                                        <div class="card-header py-3">
                                            <h6 class="m-0 font-weight-bold text-primary">
                                                <i class="fas fa-info-circle me-2"></i>Thông tin hệ thống
                                            </h6>
                                        </div>
                                        <div class="card-body">
                                            <div class="mb-3">
                                                <strong>Phiên bản:</strong> TaphoaMMO v1.0.0
                                            </div>
                                            <div class="mb-3">
                                                <strong>Framework:</strong> Spring Boot 3.5.5
                                            </div>
                                            <div class="mb-3">
                                                <strong>Database:</strong> MySQL
                                            </div>
                                            <div class="mb-3">
                                                <strong>Trạng thái:</strong>
                                                <span class="badge bg-success">Hoạt động</span>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Recent Activity -->
                            <div class="row">
                                <div class="col-lg-12">
                                    <div class="card shadow">
                                        <div class="card-header py-3">
                                            <h6 class="m-0 font-weight-bold text-primary">
                                                <i class="fas fa-clock me-2"></i>Hoạt động gần đây
                                            </h6>
                                        </div>
                                        <div class="card-body">
                                            <div class="text-center text-muted py-4">
                                                <i class="fas fa-history fa-3x mb-3"></i>
                                                <p>Chưa có hoạt động nào được ghi nhận</p>
                                                <small>Các hoạt động của hệ thống sẽ hiển thị tại đây</small>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <script>
                        // Toggle sidebar khi nhấn vào nút
                        function toggleSidebar() {
                            var sidebar = document.getElementById('sidebar');
                            var content = document.getElementById('content');

                            // Toggle class 'active' cho sidebar
                            sidebar.classList.toggle('active');

                            // Toggle margin-left cho nội dung chính khi sidebar thay đổi trạng thái
                            content.classList.toggle('shifted');
                        }
                    </script>

        </body>

        </html>