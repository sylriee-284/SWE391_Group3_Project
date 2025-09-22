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
                <li><a href="#">Trang chủ</a></li>
                <li><a href="#">Quản lý thanh toán</a></li>
                <li><a href="#">Mua hàng</a></li>
                <li><a href="#">Trung gian</a></li>
                <li><a href="#">Trang chủ</a></li>
                <li><a href="#">Quản lý thanh toán</a></li>
                <li><a href="#">Mua hàng</a></li>
                <li><a href="#">Trung gian</a></li>
                <li><a href="#">Trang chủ</a></li>
                <li><a href="#">Quản lý thanh toán</a></li>
                <li><a href="#">Mua hàng</a></li>
                <li><a href="#">Trung gian</a></li>
                <li><a href="#">Trang chủ</a></li>
                <li><a href="#">Quản lý thanh toán</a></li>
                <li><a href="#">Mua hàng</a></li>
                <li><a href="#">Trung gian</a></li>
                <li><a href="#">Trang chủ</a></li>
                <li><a href="#">Quản lý thanh toán</a></li>
                <li><a href="#">Mua hàng</a></li>
                <li><a href="#">Trung gian</a></li>
                <li><a href="#">Trang chủ</a></li>
                <li><a href="#">Quản lý thanh toán</a></li>
                <li><a href="#">Mua hàng</a></li>
                <li><a href="#">Trung gian</a></li>
            </ul>
        </div>
    </body>

    </html>