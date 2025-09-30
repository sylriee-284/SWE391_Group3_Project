<%@ page language="java" pageEncoding="UTF-8" %>
    <!DOCTYPE html>
    <html lang="en">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Sidebar</title>
        <style>
            /* Sidebar */
            .sidebar {
                width: 250px;
                height: 100vh;
                /* Chiều cao sidebar chiếm toàn bộ chiều cao màn hình */
                background-color: #2c3e50;
                color: white;
                padding: 20px;
                display: flex;
                flex-direction: column;
                position: fixed;
                top: 0;
                left: -250px;
                /* Sidebar ẩn ra ngoài */
                transition: left 0.3s ease;
                /* Hiệu ứng trượt sidebar vào/ra */
                overflow-y: scroll;
                /* Bật thanh cuộn dọc trong sidebar */
            }

            /* Khi có class active, sidebar sẽ trượt vào */
            .sidebar.active {
                left: 0;
            }

            /* Logo trong sidebar */
            .sidebar .logo {
                text-align: center;
                font-size: 24px;
                font-weight: bold;
                margin-bottom: 40px;
            }

            /* Menu trong sidebar */
            .sidebar .menu {
                list-style-type: none;
                padding: 0;
                margin: 0;
            }

            /* Các mục trong menu */
            .sidebar .menu li {
                margin-bottom: 20px;
            }

            /* Các liên kết trong menu */
            .sidebar .menu li a {
                color: white;
                text-decoration: none;
                font-size: 18px;
                display: block;
                padding: 10px;
                border-radius: 5px;
                transition: background-color 0.3s, padding-left 0.3s;
            }

            /* Khi di chuột vào liên kết trong menu */
            .sidebar .menu li a:hover {
                background-color: #34495e;
                padding-left: 20px;
            }

            /* Mục đang được chọn trong menu */
            .sidebar .menu li a.active {
                background-color: #e67e22;
            }

            /* Bỏ màu trắng nền của sidebar khi thanh cuộn xuất hiện */
            .sidebar::-webkit-scrollbar {
                width: 8px;
                /* Độ rộng thanh cuộn */
            }

            .sidebar::-webkit-scrollbar-thumb {
                background-color: #7f8c8d;
                /* Màu sắc của thanh cuộn */
                border-radius: 10px;
            }

            .sidebar::-webkit-scrollbar-track {
                background-color: transparent;
                /* Loại bỏ màu nền của track */
            }
        </style>
    </head>

    <body>

        <!-- Sidebar -->
        <div class="sidebar" id="sidebar">
            <div class="logo">
                <br></br>
                <h2>MMO Market System</h2>
            </div>
            <ul class="menu">
                <li><a href="/homepage">Trang chủ</a></li>
                <c:if test="${pageContext.request.userPrincipal == null}">
                    <li><a href="/login">Đăng ký ngay nhận voucher 50k</a></li>
                </c:if>
                <ul class="list-unstyled">

                    <!-- Quản lý thanh toán -->
                    <li>
                        <a class="d-flex justify-content-between align-items-center text-decoration-none text-white"
                            data-bs-toggle="collapse" href="#paymentMenu" role="button" aria-expanded="false"
                            aria-controls="paymentMenu">
                            💳 Quản lý thanh toán
                            <i class="fas fa-chevron-down"></i>
                        </a>
                        <ul class="collapse list-unstyled ms-3 mt-2" id="paymentMenu">
                            <li><a href="/wallet/deposit" class="text-white text-decoration-none">➕ Nạp tiền</a></li>
                            <li><a href="/wallet/history" class="text-white text-decoration-none">📜 Lịch sử giao
                                    dịch</a></li>
                        </ul>
                        <!-- Chỉ hiển thị nếu user có role SELLER -->
                        <sec:authorize access="hasRole('SELLER')">
                    <li><a href="/wallet/withdraw" class="text-white text-decoration-none">📤 Rút tiền</a></li>
                    </sec:authorize>
                    </li>

                    <!-- Mua hàng -->
                    <li class="mt-2">
                        <a class="d-flex justify-content-between align-items-center text-decoration-none text-white"
                            data-bs-toggle="collapse" href="#shoppingMenu" role="button" aria-expanded="false"
                            aria-controls="shoppingMenu">
                            🛒 Mua hàng
                            <i class="fas fa-chevron-down"></i>
                        </a>
                        <ul class="collapse list-unstyled ms-3 mt-2" id="shoppingMenu">
                            <li><a href="/products" class="text-white text-decoration-none">📦 Sản phẩm</a></li>
                            <li><a href="/orders" class="text-white text-decoration-none">📑 Đơn hàng</a></li>
                        </ul>
                    </li>

                </ul>


                <li><a href="#">Feedback</a></li>
                <sec:authorize
                    access="isAuthenticated() and hasRole('USER') and !hasRole('SELLER') and !hasRole('ADMIN')">
                    <li><a href="#">Đăng ký bán hàng</a></li>
                </sec:authorize>

                <sec:authorize access="isAuthenticated() and hasRole('SELLER') and !hasRole('ADMIN')">
                    <li><a href="/seller/dashboard">Bảng điều khiển người bán</a></li>
                    <li><a href="/seller/dashboard">Báo cáo</a></li>
                </sec:authorize>

                <sec:authorize access="hasRole('ADMIN')">
                    <li><a href="/admin/dashboard">Bảng điều khiển Admin</a></li>

                    <!-- Quản lý platform -->
                    <li>
                        <a class="d-flex justify-content-between align-items-center text-decoration-none text-white"
                            data-bs-toggle="collapse" href="#paymentMenu" role="button" aria-expanded="false"
                            aria-controls="paymentMenu">
                            Quản lý platform
                            <i class="fas fa-chevron-down"></i>
                        </a>
                        <ul class="collapse list-unstyled ms-3 mt-2" id="paymentMenu">
                            <li><a href="#" class="text-white text-decoration-none">Quản lý người dùng</a></li>
                            <li><a href="#" class="text-white text-decoration-none">Quản lý cửa hàng</a></li>
                            <li><a href="#" class="text-white text-decoration-none">Quản lý mặt hàng</a></li>
                            <li><a href="#" class="text-white text-decoration-none">Cài đặt platform</a></li>
                        </ul>
                    </li>
                </sec:authorize>

            </ul>
        </div>
    </body>

    </html>