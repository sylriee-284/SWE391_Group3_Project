<%@ page language="java" pageEncoding="UTF-8" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>

            <!-- Sidebar Component -->
            <div class="sidebar" id="sidebar">
                <ul class="menu">
                    <li><a href="/homepage">Trang chủ</a></li>
                    <c:if test="${pageContext.request.userPrincipal == null}">
                        <li><a href="/register">Đăng ký ngay</a></li>
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
                                <li><a href="/wallet/deposit" class="text-white text-decoration-none">➕ Nạp tiền</a>
                                </li>
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

                    <sec:authorize access="isAuthenticated() and hasRole('SELLER')">
                        <li><a href="/seller/dashboard">Bảng điều khiển người bán</a></li>
                        <li><a href="/seller/dashboard">Báo cáo</a></li>
                    </sec:authorize>

                    <sec:authorize access="hasRole('ADMIN')">
                        <li><a href="/admin/dashboard">Bảng điều khiển Admin</a></li>

                        <!-- Quản lý platform -->
                        <li>
                            <a class="d-flex justify-content-between align-items-center text-decoration-none text-white"
                                data-bs-toggle="collapse" href="#adminMenu" role="button" aria-expanded="false"
                                aria-controls="adminMenu">
                                Quản lý platform
                                <i class="fas fa-chevron-down"></i>
                            </a>
                            <ul class="collapse list-unstyled ms-3 mt-2" id="adminMenu">
                                <li><a href="#" class="text-white text-decoration-none">Quản lý người dùng</a></li>
                                <li><a href="#" class="text-white text-decoration-none">Quản lý cửa hàng</a></li>
                                <li><a href="#" class="text-white text-decoration-none">Quản lý mặt hàng</a></li>
                                <li><a href="#" class="text-white text-decoration-none">Cài đặt platform</a></li>
                            </ul>
                        </li>
                    </sec:authorize>
                </ul>
            </div>