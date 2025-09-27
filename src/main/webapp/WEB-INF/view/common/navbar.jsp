<%@ page language="java" pageEncoding="UTF-8" %>
    <!DOCTYPE html>
    <html lang="en">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Navbar</title>
        <style>
            /* Navbar */
            .navbar {
                width: 100%;
                background-color: #2c3e50;
                color: white;
                padding: 10px 20px;
                text-align: left;
                position: fixed;
                top: 0;
                left: 0;
                z-index: 200;
            }

            .navbar .menu-toggle {
                font-size: 24px;
                /* Biểu tượng 3 gạch ngang */
                color: white;
                background-color: transparent;
                border: none;
                cursor: pointer;
                display: inline-block;
                /* Loại bỏ bất kỳ transform nào */
                transition: background-color 0.3s, padding 0.3s;
                /* Chỉ giữ hiệu ứng background-color và padding */
            }

            .navbar .menu-toggle:hover {
                background-color: #34495e;
                padding: 8px 12px;
                border-radius: 5px;
                /* Loại bỏ mọi hiệu ứng phóng to hoặc zoom */
                /* Không sử dụng transform: scale() */
            }
        </style>
    </head>

    <body>
        <!-- Navbar -->
        <div class="navbar">
            <!-- Nút Toggle Sidebar chỉ còn biểu tượng ☰ -->
            <button class="menu-toggle" onclick="toggleSidebar()">☰</button>
        </div>
    </body>

    </html>