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
                    background-color: #ecf0f1;
                    margin-left: 0;
                    transition: margin-left 0.3s ease;
                }

                .content.shifted {
                    margin-left: 250px;
                    /* Đẩy nội dung sang phải khi sidebar bật */
                }

                .content h1 {
                    font-size: 28px;
                    color: #2c3e50;
                }

                /* Responsive Design */
                @media (max-width: 768px) {
                    .content {
                        margin-left: 200px;
                    }
                }

                @media (max-width: 480px) {
                    .content {
                        margin-left: 150px;
                    }
                }
            </style>

        </head>

        <body>

            <!-- Include Navbar -->
            <%@ include file="common/navbar.jsp" %>

                <!-- Include Sidebar -->
                <%@ include file="common/sidebar.jsp" %>

                    <!-- Nội dung chính -->
                    <div class="content" id="content">
                        <h1>Dashboard</h1>
                        <p>Tổng cộng: 0 bản ghi</p>

                        <!-- Thêm nội dung khác tại đây -->
                        <p>Thông tin dashboard sẽ hiển thị ở đây.</p>
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