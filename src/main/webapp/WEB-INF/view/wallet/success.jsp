<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>

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
                    <!-- Page Content will be inserted here -->

                    <body>


                        <div class="container mt-5">
                            <div class="row justify-content-center">
                                <div class="col-md-6">
                                    <div class="card border-success">
                                        <div class="card-header bg-success text-white text-center">
                                            <h4><i class="fas fa-check-circle"></i> Top-up Successful!</h4>
                                        </div>
                                        <div class="card-body text-center">
                                            <div class="mb-4">
                                                <i class="fas fa-check-circle text-success"
                                                    style="font-size: 4rem;"></i>
                                            </div>
                                            <h5 class="text-success">Transaction processed successfully</h5>
                                            <p class="text-muted">The amount has been added to your wallet.</p>

                                            <div class="d-grid gap-2 mt-4">
                                                <a href="/wallet" class="btn btn-success">
                                                    <i class="fas fa-wallet"></i> View My Wallet
                                                </a>
                                                <a href="/" class="btn btn-outline-secondary">
                                                    <i class="fas fa-home"></i> Back to Home
                                                </a>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>



                        <script
                            src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
                    </body>




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