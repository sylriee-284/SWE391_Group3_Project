<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <style>
        body {
            display: flex;
            flex-direction: column;
            min-height: 100vh;
            margin: 0;
        }

        .main-content {
            flex: 1;
        }

        footer {
            width: 100%;
        }
    </style>
    <footer class="bg-dark text-light py-4" style="margin-top:auto;">
        <div class="container">
            <div class="row">

                <div class="col-md-3 mb-3">
                    <h5>MMO Market System</h5>
                    <p>Sàn thương mại điện tử uy tín, đem đến cho bạn sản phẩm chất lượng với giá tốt nhất.</p>
                </div>

                <div class="col-md-3 mb-3">
                    <h5>Liên kết nhanh</h5>
                    <ul class="list-unstyled">
                        <li><a href="${pageContext.request.contextPath}/about"
                                class="text-light text-decoration-none">Về chúng tôi</a></li>
                        <li><a href="${pageContext.request.contextPath}/products"
                                class="text-light text-decoration-none">Sản phẩm</a></li>
                        <li><a href="${pageContext.request.contextPath}/contact"
                                class="text-light text-decoration-none">Liên hệ</a></li>
                        <li><a href="${pageContext.request.contextPath}/faq"
                                class="text-light text-decoration-none">FAQ</a></li>
                    </ul>
                </div>

                <div class="col-md-3 mb-3">
                    <h5>Chính sách</h5>
                    <ul class="list-unstyled">
                        <li><a href="${pageContext.request.contextPath}/shipping"
                                class="text-light text-decoration-none">Vận chuyển</a></li>
                        <li><a href="${pageContext.request.contextPath}/return"
                                class="text-light text-decoration-none">Đổi trả</a></li>
                        <li><a href="${pageContext.request.contextPath}/privacy"
                                class="text-light text-decoration-none">Bảo mật</a></li>
                        <li><a href="${pageContext.request.contextPath}/terms"
                                class="text-light text-decoration-none">Điều khoản</a></li>
                    </ul>
                </div>

                <div class="col-md-3 mb-3">
                    <h5>Liên hệ</h5>
                    <p>📍 Đại Học FPT Hà Nội</p>
                    <p>📞 0123 456 789</p>
                    <p>✉ support@mmomarketsystem.com</p>
                    <div>
                        <a href="#" class="text-light me-2">Facebook</a>
                        <a href="#" class="text-light me-2">Instagram</a>
                        <a href="#" class="text-light">Zalo</a>
                    </div>
                </div>

            </div>
            <div class="text-center border-top border-secondary pt-3 mt-3">
                © 2025 MMO Market System. All rights reserved.
            </div>
        </div>
    </footer>