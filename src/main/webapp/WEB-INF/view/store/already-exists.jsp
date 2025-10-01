<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<c:set var="pageTitle" value="Cửa hàng đã tồn tại" scope="request" />

<!-- Store Already Exists Specific Styles -->
<c:set var="additionalCSS" scope="request">
    <style>
        .alert-custom {
            border-radius: 15px;
            border: none;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }
        .btn-custom {
            border-radius: 25px;
            padding: 12px 30px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        .icon-large {
            font-size: 4rem;
            margin-bottom: 1rem;
        }
        .card-custom {
            border: none;
            border-radius: 20px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
        }
    </style>
</c:set>

<!-- Include Sidebar Layout -->
<%@ include file="../sidebar.jsp" %>

<!-- Store Already Exists JavaScript -->
<c:set var="additionalJS" scope="request">
    <script>
        // Add store already exists content to the main content area
        document.addEventListener('DOMContentLoaded', function() {
            const pageContent = document.getElementById('pageContent');
            pageContent.innerHTML = \`
                <div class="container mt-5">
                    <div class="row justify-content-center">
                        <div class="col-md-8 col-lg-6">
                            <div class="card card-custom">
                                <div class="card-body text-center p-5">
                                    <!-- Icon -->
                                    <div class="text-warning icon-large">
                                        <i class="fas fa-store"></i>
                                    </div>

                                    <!-- Title -->
                                    <h2 class="card-title text-dark mb-3">
                                        <strong>Bạn đã có cửa hàng!</strong>
                                    </h2>

                                    <!-- Message -->
                                    <div class="alert alert-warning alert-custom mb-4">
                                        <i class="fas fa-exclamation-triangle me-2"></i>
                                        <strong>Thông báo:</strong> Bạn đã có một cửa hàng đang hoạt động trên hệ thống.
                                        Mỗi người dùng chỉ được phép tạo một cửa hàng duy nhất.
                                    </div>

                                    <!-- Store Info -->
                                    <c:if test="\${not empty store}">
                                        <div class="card bg-light mb-4">
                                            <div class="card-body">
                                                <h5 class="card-title text-primary">
                                                    <i class="fas fa-shop me-2"></i>
                                                    \${store.storeName}
                                                </h5>
                                                <p class="card-text text-muted mb-2">
                                                    <i class="fas fa-envelope me-2"></i>
                                                    \${store.contactEmail}
                                                </p>
                                                <p class="card-text text-muted mb-2">
                                                    <i class="fas fa-phone me-2"></i>
                                                    \${store.contactPhone}
                                                </p>
                                                <span class="badge \${store.status == 'active' ? 'bg-success' : 'bg-warning'} fs-6">
                                                    <i class="fas fa-circle me-1"></i>
                                                    <c:choose>
                                                        <c:when test="\${store.status == 'active'}">Đang hoạt động</c:when>
                                                        <c:when test="\${store.status == 'pending'}">Chờ duyệt</c:when>
                                                        <c:when test="\${store.status == 'suspended'}">Tạm ngưng</c:when>
                                                        <c:otherwise>Không xác định</c:otherwise>
                                                    </c:choose>
                                                </span>
                                            </div>
                                        </div>
                                    </c:if>

                                    <!-- Action Buttons -->
                                    <div class="d-grid gap-2 d-md-flex justify-content-md-center">
                                        <a href="/stores/my-store" class="btn btn-primary btn-custom me-md-2">
                                            <i class="fas fa-tachometer-alt me-2"></i>
                                            Quản lý cửa hàng
                                        </a>
                                        <a href="/stores/my-store/settings" class="btn btn-outline-secondary btn-custom">
                                            <i class="fas fa-cog me-2"></i>
                                            Cài đặt
                                        </a>
                                    </div>

                                    <!-- Back to Home -->
                                    <div class="mt-4">
                                        <a href="/" class="text-muted text-decoration-none">
                                            <i class="fas fa-arrow-left me-2"></i>
                                            Quay về trang chủ
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            \`;
        });
    </script>
</c:set>
