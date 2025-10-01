<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!-- Navbar Component -->
<nav class="navbar navbar-expand-lg navbar-custom">
    <div class="container-fluid">
        <!-- Toggle Button (only shown if hasSidebar is true) -->
        <c:if test="${hasSidebar}">
            <button class="btn btn-link text-white me-3" id="sidebarToggle" onclick="toggleSidebar()">
                <i class="fas fa-bars fa-lg"></i>
            </button>
        </c:if>

        <!-- Brand -->
        <a class="navbar-brand" href="/">
            <i class="fas fa-store me-2"></i>TaphoaMMO
        </a>

        <!-- Mobile Toggle -->
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
            <span class="navbar-toggler-icon"></span>
        </button>

        <!-- Navbar Content -->
        <div class="collapse navbar-collapse" id="navbarNav">
            <!-- Left Nav Links -->
            <ul class="navbar-nav me-auto">
                <li class="nav-item">
                    <a class="nav-link" href="/"><i class="fas fa-home me-1"></i> Trang chủ</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="/products"><i class="fas fa-box me-1"></i> Sản phẩm</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="/stores"><i class="fas fa-store me-1"></i> Cửa hàng</a>
                </li>
            </ul>

            <!-- Right Nav Links -->
            <ul class="navbar-nav ms-auto">
                <c:choose>
                    <c:when test="${not empty sessionScope.currentUser}">
                        <!-- User Dropdown -->
                        <li class="nav-item dropdown">
                            <a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown">
                                <i class="fas fa-user-circle me-1"></i>
                                ${sessionScope.currentUser.username}
                            </a>
                            <ul class="dropdown-menu dropdown-menu-end">
                                <li><a class="dropdown-item" href="/users/profile">
                                    <i class="fas fa-user me-2"></i>Hồ sơ
                                </a></li>
                                <li><a class="dropdown-item" href="/wallets/my-wallet">
                                    <i class="fas fa-wallet me-2"></i>Ví của tôi
                                </a></li>
                                <c:if test="${sessionScope.currentUser.role == 'SELLER' or sessionScope.currentUser.role == 'ADMIN'}">
                                    <li><hr class="dropdown-divider"></li>
                                    <li><a class="dropdown-item" href="/stores/my-store">
                                        <i class="fas fa-store me-2"></i>Cửa hàng của tôi
                                    </a></li>
                                    <li><a class="dropdown-item" href="/products/my-products">
                                        <i class="fas fa-boxes me-2"></i>Sản phẩm của tôi
                                    </a></li>
                                </c:if>
                                <li><hr class="dropdown-divider"></li>
                                <li><a class="dropdown-item" href="/users/change-password">
                                    <i class="fas fa-key me-2"></i>Đổi mật khẩu
                                </a></li>
                                <li><a class="dropdown-item" href="/auth/logout">
                                    <i class="fas fa-sign-out-alt me-2"></i>Đăng xuất
                                </a></li>
                            </ul>
                        </li>
                    </c:when>
                    <c:otherwise>
                        <li class="nav-item">
                            <a class="nav-link" href="/auth/login">
                                <i class="fas fa-sign-in-alt me-1"></i> Đăng nhập
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="/auth/register">
                                <i class="fas fa-user-plus me-1"></i> Đăng ký
                            </a>
                        </li>
                    </c:otherwise>
                </c:choose>
            </ul>
        </div>
    </div>
</nav>
