<%@ page language="java" pageEncoding="UTF-8" %>
    <%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
        <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
            <%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

                <!-- Navbar Component -->
                <div class="navbar d-flex align-items-center justify-content-between">
                    <div class="d-flex align-items-center">
                        <!-- Nút Toggle Sidebar chỉ còn biểu tượng ☰ -->
                        <button class="menu-toggle" onclick="toggleSidebar()">☰</button>
                        <!-- Logo/dòng MMO Market System -->
                        <a href="/homepage" class="fw-bold text-light text-decoration-none ms-4 me-4"
                            style="font-size: 22px;">MMO Market System</a>
                        <!-- Các nút chức năng bên trái -->
                        <div class="dropdown me-2">
                            <button class="btn btn-secondary btn-sm dropdown-toggle" type="button" id="categoryDropdown"
                                data-bs-toggle="dropdown" aria-expanded="false">
                                Category
                            </button>
                            <ul class="dropdown-menu" aria-labelledby="categoryDropdown">
                                <c:forEach var="cat" items="${parentCategories}">
                                    <li>
                                        <a class="dropdown-item" href="/category/${cat.name.toLowerCase()}">
                                            ${cat.name}
                                        </a>
                                    </li>
                                </c:forEach>
                            </ul>
                        </div>

                        <a href="#" class="btn btn-outline-light btn-sm me-2">Support</a>
                        <a href="#" class="btn btn-outline-light btn-sm me-2">Share</a>
                        <a href="#" class="btn btn-outline-light btn-sm me-2">Tools</a>
                        <a href="#" class="btn btn-outline-light btn-sm me-2">FAQs</a>
                    </div>

                    <div class="d-flex align-items-center ms-auto">
                        <!-- Nếu chưa login -->
                        <sec:authorize access="!isAuthenticated()">
                            <a href="/login" class="btn btn-warning btn-sm">Đăng nhập</a>
                        </sec:authorize>

                        <!-- Nếu đã login -->
                        <sec:authorize access="isAuthenticated()">
                            <sec:authentication var="user" property="principal" />
                            <div class="dropdown">
                                <button class="btn btn-success btn-sm dropdown-toggle" type="button" id="userDropdown"
                                    data-bs-toggle="dropdown" aria-expanded="false">
                                    💰
                                    <fmt:formatNumber value="${user.balance}" type="number" maxFractionDigits="0" />
                                    VND | Xin chào, ${user.username}
                                </button>
                                <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="userDropdown">
                                    <li><a class="dropdown-item" href="/user/profile">👤 Hồ sơ</a></li>
                                    <li>
                                        <hr class="dropdown-divider">
                                    </li>
                                    <li>
                                        <form action="/logout" method="post" style="display:inline;">
                                            <button type="submit" class="dropdown-item">🚪 Đăng xuất</button>
                                        </form>
                                    </li>
                                </ul>
                            </div>
                        </sec:authorize>

                    </div>

                </div>

                <!-- Script để cập nhật balance real-time -->
                <script>
                    // Function để cập nhật balance trong navbar
                    function updateBalanceDisplay() {
                        fetch('/wallet/api/balance')
                            .then(response => response.json())
                            .then(data => {
                                if (data.success) {
                                    // Format số tiền
                                    const balance = new Intl.NumberFormat('vi-VN', {
                                        maximumFractionDigits: 0
                                    }).format(data.balance);

                                    // Cập nhật text trong button
                                    const userDropdown = document.getElementById('userDropdown');
                                    if (userDropdown) {
                                        // Sử dụng username từ API response
                                        const username = data.username || 'User';

                                        // Cập nhật toàn bộ text với balance mới
                                        userDropdown.innerHTML = '💰 ' + balance + ' VND | Xin chào, ' + username;
                                    }

                                } else {
                                    console.error('Failed to update balance:', data.error);
                                }
                            })
                            .catch(error => {
                                console.error('Error fetching balance:', error);
                            });
                    }

                    // Cập nhật balance mỗi 3 giây
                    let balanceUpdateInterval;

                    function startBalancePolling() {
                        // Cập nhật ngay lập tức
                        updateBalanceDisplay();

                        // Cập nhật định kỳ mỗi 3 giây
                        balanceUpdateInterval = setInterval(updateBalanceDisplay, 3000);
                    }

                    function stopBalancePolling() {
                        if (balanceUpdateInterval) {
                            clearInterval(balanceUpdateInterval);
                            balanceUpdateInterval = null;
                        }
                    }

                    // Bắt đầu polling khi trang load
                    document.addEventListener('DOMContentLoaded', function () {
                        // Chỉ start polling nếu user đã đăng nhập
                        <sec:authorize access="isAuthenticated()">
                            startBalancePolling();
                        </sec:authorize>
                    });

                    // Dừng polling khi user rời khỏi trang
                    window.addEventListener('beforeunload', function () {
                        stopBalancePolling();
                    });

                    // Expose function để có thể gọi từ các trang khác
                    window.updateBalanceDisplay = updateBalanceDisplay;
                </script>