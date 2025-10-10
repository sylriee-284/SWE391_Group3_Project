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
                    <div class="container mt-5">
                        <div class="row justify-content-center">
                            <div class="col-md-6">
                                <div class="card">
                                    <div class="card-header bg-primary text-white text-center">
                                        <h4><i class="fas fa-plus-circle"></i> Add Money to Wallet</h4>
                                    </div>
                                    <div class="card-body">
                                        <!-- Error messages -->
                                        <c:if test="${param.error eq 'invalid_amount'}">
                                            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                                                <i class="fas fa-exclamation-circle"></i> Minimum amount is 10,000 VND
                                                <button type="button" class="btn-close"
                                                    data-bs-dismiss="alert"></button>
                                            </div>
                                        </c:if>

                                        <c:if test="${param.error eq 'encoding'}">
                                            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                                                <i class="fas fa-exclamation-circle"></i> An error occurred. Please try
                                                again!
                                                <button type="button" class="btn-close"
                                                    data-bs-dismiss="alert"></button>
                                            </div>
                                        </c:if>

                                        <form action="/wallet/deposit" method="post" id="depositForm">
                                            <div class="mb-3">
                                                <label for="amount" class="form-label">
                                                    <i class="fas fa-money-bill-wave"></i> Amount (VND)
                                                </label>
                                                <input type="number" class="form-control" id="amount" name="amount"
                                                    placeholder="Enter amount to deposit" min="10000" step="1000"
                                                    required>
                                                <div class="form-text">Minimum amount: 10,000 VND</div>
                                            </div>

                                            <div class="alert alert-info">
                                                <i class="fas fa-info-circle"></i>
                                                <strong>Note:</strong> You will be redirected to VNPay payment page to
                                                complete
                                                the transaction.
                                            </div>

                                            <div class="d-grid">
                                                <button type="submit" class="btn btn-primary btn-lg">
                                                    <i class="fas fa-credit-card"></i> Pay with VNPay
                                                </button>
                                            </div>
                                        </form>

                                        <div class="text-center mt-3">
                                            <a href="/wallet" class="btn btn-outline-secondary">
                                                <i class="fas fa-arrow-left"></i> Back to Wallet
                                            </a>
                                        </div>
                                    </div>
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


                    // Form validation
                    document.getElementById('depositForm').addEventListener('submit', function (e) {
                        const amount = document.getElementById('amount').value;
                        if (!amount || amount < 10000) {
                            e.preventDefault();
                            alert('Please enter minimum amount of 10,000 VND');
                        }
                    });

                    // Format amount while typing
                    document.getElementById('amount').addEventListener('input', function (e) {
                        let value = e.target.value;
                        if (value && !isNaN(value)) {
                            e.target.value = parseInt(value);
                        }
                    });

                </script>
            </body>

            </html>