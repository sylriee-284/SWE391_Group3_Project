<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

            <!DOCTYPE html>
            <html lang="en">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>
                    <c:if test="${not empty pageTitle}">${pageTitle} - </c:if>MMO Market System
                </title>

                <!-- Include common head with all CSS and JS -->
                <jsp:include page="../common/head.jsp" />
            </head>

            <body>
                <!-- Include Navbar -->
                <jsp:include page="../common/navbar.jsp" />

                <!-- Include Sidebar -->
                <jsp:include page="../common/sidebar.jsp" />

                <!-- Main Content Area -->
                <div class="content" id="content">
                    <div class="container mt-4">
                        <div class="row">
                            <div class="col-md-8 mx-auto">
                                <!-- Header -->
                                <div class="d-flex justify-content-between align-items-center mb-4">
                                    <h2><i class="fas fa-wallet text-primary"></i> My Wallet</h2>
                                    <a href="/" class="btn btn-outline-secondary">
                                        <i class="fas fa-home"></i> Back to Home
                                    </a>
                                </div>

                                <!-- Thông tin ví -->
                                <div class="row mb-4">
                                    <div class="col-md-6">
                                        <div class="card bg-primary text-white">
                                            <div class="card-body text-center">
                                                <h5 class="card-title">
                                                    <i class="fas fa-coins"></i> Current Balance
                                                </h5>
                                                <h2 class="card-text">
                                                    <c:choose>
                                                        <c:when test="${wallet != null}">
                                                            <fmt:formatNumber value="${wallet.balance}" type="currency"
                                                                currencySymbol="₫" />
                                                        </c:when>
                                                        <c:otherwise>
                                                            0 ₫
                                                        </c:otherwise>
                                                    </c:choose>
                                                </h2>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="col-md-6">
                                        <div class="card">
                                            <div class="card-body text-center">
                                                <h5 class="card-title">
                                                    <i class="fas fa-user"></i> Account Owner
                                                </h5>
                                                <p class="card-text">
                                                    <strong>${user.fullName != null ? user.fullName :
                                                        user.username}</strong><br>
                                                    <small class="text-muted">${user.email}</small>
                                                </p>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <!-- Thao tác -->
                                <div class="row mb-4">
                                    <div class="col-12">
                                        <div class="card">
                                            <div class="card-header">
                                                <h5><i class="fas fa-cog"></i> Actions</h5>
                                            </div>
                                            <div class="card-body">
                                                <div class="row">
                                                    <div class="col-md-4 mb-3">
                                                        <a href="/wallet/deposit" class="btn btn-success w-100">
                                                            <i class="fas fa-plus-circle"></i><br>
                                                            Deposit
                                                        </a>
                                                    </div>
                                                    <div class="col-md-4 mb-3">
                                                        <button class="btn btn-warning w-100" disabled>
                                                            <i class="fas fa-minus-circle"></i><br>
                                                            Withdraw<br>
                                                            <small>(Coming Soon)</small>
                                                        </button>
                                                    </div>
                                                    <div class="col-md-4 mb-3">
                                                        <a href="/wallet/transactions" class="btn btn-info w-100">
                                                            <i class="fas fa-history"></i><br>
                                                            Transaction History
                                                        </a>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <!-- Thông tin bổ sung -->
                                <div class="alert alert-info">
                                    <h6><i class="fas fa-info-circle"></i> Important Information:</h6>
                                    <ul class="mb-0">
                                        <li>Wallet balance is updated immediately after successful payment</li>
                                        <li>You can use your balance to make purchases on the system</li>
                                        <li>All transactions are secure and safely stored</li>
                                    </ul>
                                </div>
                            </div>
                        </div>
                    </div>





                </div>

                <!-- Include Footer -->
                <jsp:include page="../common/footer.jsp" />

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

                <!-- Page-specific JavaScript -->
                <c:if test="${not empty pageJS}">
                    <c:forEach var="js" items="${pageJS}">
                        <script src="${pageContext.request.contextPath}${js}"></script>
                    </c:forEach>
                </c:if>

                <!-- Common JavaScript -->
                <script>
                    // Toggle sidebar function
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

                    // Auto-hide alerts after 5 seconds
                    document.addEventListener('DOMContentLoaded', function () {
                        var alerts = document.querySelectorAll('.alert');
                        alerts.forEach(function (alert) {
                            setTimeout(function () {
                                alert.style.opacity = '0';
                                setTimeout(function () {
                                    alert.remove();
                                }, 300);
                            }, 5000);
                        });
                    });
                </script>
            </body>

            </html>