<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
            <html lang="en">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>MMO Market System - Homepage</title>

                <!-- Include common head with all CSS and JS -->
                <jsp:include page="common/head.jsp" />
            </head>

            <body>
                <!-- Include Navbar -->
                <jsp:include page="common/navbar.jsp" />

                <!-- Include Sidebar -->
                <jsp:include page="common/sidebar.jsp" />

                <!-- Nội dung chính -->
                <div class="content" id="content">
                    <!-- Notifications will be displayed using iziToast -->
                    <div class="container my-4">
                        <div class="row justify-content-center">
                            <div class="col-md-8">
                                <form action="/search" method="get" class="d-flex">
                                    <input type="text" name="keyword" class="form-control me-2"
                                        placeholder="Tìm sản phẩm..." required>
                                    <button type="submit" class="btn btn-primary">🔍 Tìm kiếm</button>
                                </form>
                            </div>
                        </div>
                    </div>

                    <div class="container my-5">
                        <h3 class="text-center mb-4" style="color: green;">-- DANH SÁCH SẢN PHẨM --</h3>
                        <div class="row text-center">
                            <c:forEach var="parentCategory" items="${parentCategories}">
                                <div class="col-md-3 mb-4">
                                    <div class="card h-100 border-success">
                                        <div class="card-body text-center">
                                            <div class="mb-3">
                                                <a
                                                    href="<c:url value='/category/${parentCategory.name.toLowerCase()}'/>">
                                                    <img src="<c:url value='/images/${parentCategory.name}.png'/>"
                                                        alt="${parentCategory.name}" class="img-fluid"
                                                        style="width:70px;height:70px;">
                                                </a>
                                            </div>
                                            <h5 class="card-title text-success">
                                                <a href="<c:url value='/category/${parentCategory.name.toLowerCase()}'/>"
                                                    class="text-success text-decoration-none">
                                                    ${parentCategory.name}
                                                </a>
                                            </h5>
                                            <p class="card-text">${parentCategory.description}</p>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </div>

                    <!-- Hardcode -->
                    <div class="container my-5">
                        <h3 class="text-center mb-4" style="color: green;">-- DANH SÁCH DỊCH VỤ --</h3>
                        <div class="row text-center">
                            <!-- Tăng tương tác -->
                            <div class="col-md-3 mb-4">
                                <div class="card h-100 border-success">
                                    <div class="card-body text-center">
                                        <div class="mb-3">
                                            <a href="#">
                                                <img src="<c:url value='/images/tuongtac.png'/>" alt="Tăng tương tác"
                                                    class="img-fluid" style="width:70px;height:70px;">
                                            </a>
                                        </div>
                                        <h5 class="card-title text-success">
                                            <a href="#" class="text-success text-decoration-none">Tăng tương
                                                tác</a>
                                        </h5>
                                        <p class="card-text">Tăng like, view, share, comment... cho sản phẩm của
                                            bạn</p>
                                    </div>
                                </div>
                            </div>

                            <!-- Dịch vụ phần mềm -->
                            <div class="col-md-3 mb-4">
                                <div class="card h-100 border-success">
                                    <div class="card-body text-center">
                                        <div class="mb-3">
                                            <a href="#">
                                                <img src="<c:url value='/images/dichvuphanmem.png'/>"
                                                    alt="Dịch vụ phần mềm" class="img-fluid"
                                                    style="width:70px;height:70px;">
                                            </a>
                                        </div>
                                        <h5 class="card-title text-success">
                                            <a href="#" class="text-success text-decoration-none">Dịch vụ phần
                                                mềm</a>
                                        </h5>
                                        <p class="card-text">Dịch vụ code tool MMO, đồ họa, video... và các dịch
                                            vụ liên quan</p>
                                    </div>
                                </div>
                            </div>

                            <!-- Blockchain -->
                            <div class="col-md-3 mb-4">
                                <div class="card h-100 border-success">
                                    <div class="card-body text-center">
                                        <div class="mb-3">
                                            <a href="#">
                                                <img src="<c:url value='/images/blockchain.png'/>" alt="Blockchain"
                                                    class="img-fluid" style="width:70px;height:70px;">
                                            </a>
                                        </div>
                                        <h5 class="card-title text-success">
                                            <a href="#" class="text-success text-decoration-none">Blockchain</a>
                                        </h5>
                                        <p class="card-text">Dịch vụ tiền ảo, NFT, coinlist... và các dịch vụ
                                            blockchain khác</p>
                                    </div>
                                </div>
                            </div>

                            <!-- Dịch vụ khác -->
                            <div class="col-md-3 mb-4">
                                <div class="card h-100 border-success">
                                    <div class="card-body text-center">
                                        <div class="mb-3">
                                            <a href="#">
                                                <img src="<c:url value='/images/dvkhac.jpg'/>" alt="Dịch vụ khác"
                                                    class="img-fluid" style="width:70px;height:70px;">
                                            </a>
                                        </div>
                                        <h5 class="card-title text-success">
                                            <a href="#" class="text-success text-decoration-none">Dịch vụ
                                                khác</a>
                                        </h5>
                                        <p class="card-text">Các dịch vụ MMO phổ biến khác hiện nay</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="container my-5">
                        <div class="card border-success">
                            <div class="card-body">
                                <!-- Tiêu đề -->
                                <h4 class="card-title text-center fw-bold">
                                    MMO Market System - Chuyên mua bán sản phẩm số - Phục vụ cộng đồng MMO (Kiếm
                                    tiền online)
                                </h4>
                                <p class="text-center text-muted">
                                    Một sản phẩm ra đời với mục đích thuận tiện và an toàn hơn trong các giao
                                    dịch mua bán sản phẩm số.
                                </p>

                                <!-- Nội dung giới thiệu -->
                                <p>
                                    Như các bạn đã biết, tình trạng lừa đảo trên mạng xã hội kéo dài bao nhiêu
                                    năm nay, mặc dù đã có rất
                                    nhiều giải pháp từ cộng đồng như trung gian hay bảo hiểm, nhưng vẫn rất
                                    nhiều người dùng lựa chọn mua bán
                                    nhanh gọn mà bỏ qua các bước kiểm tra, hay trung gian, từ đó tạo cơ hội cho
                                    scammer hoạt động. Ở MMO Market System,
                                    bạn sẽ có 1 trải nghiệm mua hàng yên tâm hơn rất nhiều, chúng tôi sẽ giữ
                                    tiền người bán tối
                                    thiểu 3 ngày, kiểm tra toàn bộ sản phẩm bán ra có trùng với người khác hay
                                    không, nhằm mục đích tạo ra
                                    một nơi giao dịch mà người dùng có thể tin tưởng, một trang mà người bán có
                                    thể yên tâm đặt kho hàng, và
                                    cạnh tranh song phẳng.
                                </p>

                                <!-- Các tính năng -->
                                <h5 class="mt-4 fw-bold">Các tính năng trên trang:</h5>
                                <ul>
                                    <li>Check trùng sản phẩm bán ra: toàn bộ gian hàng cam kết không bán trùng,
                                        hệ thống sẽ kiểm tra từng sản phẩm một.</li>
                                    <li>Nạp tiền và thanh toán tự động: có thể nạp tiền đúng cú pháp, số dư được
                                        cập nhật sau 1-5 phút, giao dịch tức thì.</li>
                                    <li>Giữ tiền đơn hàng 3 ngày: sau khi mua hàng, đơn hàng sẽ ở trạng thái Tạm
                                        giữ 3 ngày, đủ thời gian để bạn kiểm tra.</li>
                                    <li>Tính năng dành cho cộng tác viên (Reseller).</li>
                                </ul>

                                <!-- Các mặt hàng -->
                                <h5 class="mt-4 fw-bold">Các mặt hàng đang kinh doanh tại Tạp Hóa MMO:</h5>
                                <ul>
                                    <li>Mua bán email: Gmail, mail outlook, domain...</li>
                                    <li>Mua bán phần mềm MMO: phần mềm kiếm tiền online, phần mềm youtube, phần
                                        mềm chạy facebook...</li>
                                    <li>Mua bán tài khoản: Facebook, Twitter, Zalo, Instagram...</li>
                                    <li>Các sản phẩm số khác: VPS, key bản quyền, diệt virus, blockchain...</li>
                                    <li>Các dịch vụ tăng tương tác: like, comment, share...</li>
                                </ul>

                                <!-- Nút thu gọn -->
                                <div class="text-center mt-3">
                                    <button class="btn btn-success">Thu gọn</button>
                                </div>
                            </div>
                        </div>
                    </div>


                </div>

                <!-- Script to display notifications using iziToast -->
                <c:if test="${not empty successMessage}">
                    <script>
                        iziToast.success({
                            title: 'Success!',
                            message: '${successMessage}',
                            position: 'topRight',
                            timeout: 5000
                        });
                    </script>
                </c:if>

                <c:if test="${not empty errorMessage}">
                    <script>
                        iziToast.error({
                            title: 'Error!',
                            message: '${errorMessage}',
                            position: 'topRight',
                            timeout: 5000
                        });
                    </script>
                </c:if>

                <!-- Include Footer -->
                <%@ include file="common/footer.jsp" %>

                    <script>
                        // Toggle sidebar khi nhấn vào nút
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
                    </script>



            </body>

            </html>