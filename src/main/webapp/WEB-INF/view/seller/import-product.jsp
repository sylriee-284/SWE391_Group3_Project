<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
            <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

                <!DOCTYPE html>
                <html lang="vi">

                <head>
                    <meta charset="UTF-8">
                    <title>MMO Market System</title>
                    <jsp:include page="../common/head.jsp" />
                </head>

                <body>
                    <jsp:include page="../common/navbar.jsp" />
                    <jsp:include page="../common/sidebar.jsp" />

                    <br /><br />
                    <div class="container mt-4">
                        <!-- Page Header -->
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <h4>Thông tin sản phẩm</h4>
                            <a href="<c:url value='/seller/import/${productId}/template'/>" class="btn btn-success">
                                <i class="bi bi-download"></i> Tải Template Excel
                            </a>
                        </div>

                        <!-- Product Information Card -->
                        <div class="card mb-4">
                            <div class="card-body">
                                <div class="row g-3">
                                    <!-- Product Name -->
                                    <div class="col-12">
                                        <label class="form-label">Tên sản phẩm <span
                                                class="text-danger">(*)</span></label>
                                        <input type="text" class="form-control" value="${product.name}" readonly
                                            style="background-color: #e9ecef;">
                                    </div>

                                    <!-- Category -->
                                    <div class="col-12">
                                        <label class="form-label">Danh mục <span class="text-danger">(*)</span></label>
                                        <input type="text" class="form-control" value="${product.category.name}"
                                            readonly style="background-color: #e9ecef;">
                                    </div>

                                    <!-- Price -->
                                    <div class="col-12">
                                        <label class="form-label">Đơn giá sản phẩm (VND) <span
                                                class="text-danger">(*)</span></label>
                                        <fmt:setLocale value="de_DE" />
                                        <input type="text" class="form-control"
                                            value="<fmt:formatNumber value='${product.price}' groupingUsed='true' />"
                                            readonly style="background-color: #e9ecef;">
                                        <fmt:setLocale value="vi_VN" />
                                    </div>

                                    <!-- Stock -->
                                    <div class="col-12">
                                        <label class="form-label">Số lượng còn lại</label>
                                        <input type="text" class="form-control" value="${product.stock}" readonly
                                            style="background-color: #e9ecef;">
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Import Form -->
                        <div class="border rounded p-4 mb-4 bg-light">
                            <form method="post" action="<c:url value='/seller/import/${productId}/execute'/>"
                                enctype="multipart/form-data" class="row g-3 align-items-end">
                                <div class="col-md-9">
                                    <label class="form-label fw-bold">Chọn file Excel</label>
                                    <input type="file" class="form-control" name="file" accept=".xlsx" required>
                                </div>
                                <div class="col-md-3">
                                    <button type="submit" class="btn btn-success w-100">
                                        <i class="bi bi-upload"></i> Nhập hàng
                                    </button>
                                </div>
                            </form>
                        </div>

                    </div>
                    <br />

                    <jsp:include page="../common/footer.jsp" />

                    <!-- Import Result Modal -->
                    <c:if test="${not empty importResult}">
                        <div class="modal fade" id="importResultModal" tabindex="-1"
                            aria-labelledby="importResultModalLabel" aria-hidden="true" data-bs-backdrop="static">
                            <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
                                <div class="modal-content">
                                    <div
                                        class="modal-header ${importResult.isFullSuccess() ? 'bg-success' : importResult.hasAnySuccess() ? 'bg-warning' : 'bg-danger'} text-white">
                                        <h5 class="modal-title" id="importResultModalLabel">
                                            <i
                                                class="bi ${importResult.isFullSuccess() ? 'bi-check-circle' : 'bi-exclamation-triangle'}"></i>
                                            Kết quả import
                                        </h5>
                                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"
                                            aria-label="Close"></button>
                                    </div>
                                    <div class="modal-body">
                                        <!-- Statistics -->
                                        <div class="row text-center mb-4">
                                            <div class="col-md-4">
                                                <div class="p-3 border rounded">
                                                    <h2 class="text-primary mb-1">${importResult.totalCount}</h2>
                                                    <p class="text-muted mb-0">Tổng số bản ghi</p>
                                                </div>
                                            </div>
                                            <div class="col-md-4">
                                                <div class="p-3 border rounded">
                                                    <h2 class="text-success mb-1">${importResult.successCount}</h2>
                                                    <p class="text-muted mb-0">Thành công</p>
                                                </div>
                                            </div>
                                            <div class="col-md-4">
                                                <div class="p-3 border rounded">
                                                    <h2 class="text-danger mb-1">${importResult.errorCount}</h2>
                                                    <p class="text-muted mb-0">Lỗi</p>
                                                </div>
                                            </div>
                                        </div>

                                        <!-- Error Records Table -->
                                        <c:if test="${not empty importResult.errorRecords}">
                                            <hr>
                                            <h6 class="text-danger mb-3">
                                                <i class="bi bi-exclamation-circle"></i> Chi tiết lỗi
                                            </h6>
                                            <div class="table-container" style="max-height: 300px; overflow-y: auto;">
                                                <table class="resizable-table">
                                                    <thead>
                                                        <tr>
                                                            <th style="width: 100px;">STT</th>
                                                            <th>Lỗi</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>
                                                        <c:forEach items="${importResult.errorRecords}"
                                                            var="errorRecord">
                                                            <tr>
                                                                <td>${errorRecord.rowNumber - 1}</td>
                                                                <td>
                                                                    <c:forEach items="${errorRecord.errors}"
                                                                        var="error">
                                                                        • ${error}<br />
                                                                    </c:forEach>
                                                                </td>
                                                            </tr>
                                                        </c:forEach>
                                                    </tbody>
                                                </table>
                                            </div>
                                        </c:if>

                                        <!-- Success Message -->
                                        <c:if test="${importResult.isFullSuccess()}">
                                            <div class="alert alert-success mt-3 mb-0">
                                                <i class="bi bi-check-circle-fill"></i>
                                                Tất cả ${importResult.successCount} bản ghi đã được import thành công!
                                            </div>
                                        </c:if>
                                    </div>
                                    <div class="modal-footer">
                                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                                            <i class="bi bi-x-circle"></i> Đóng
                                        </button>
                                        <a href="<c:url value='/seller/products'/>" class="btn btn-primary">
                                            <i class="bi bi-list-ul"></i> Quay lại danh sách sản phẩm
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </c:if>

                    <!-- Toast Notifications -->
                    <c:if test="${not empty successMessage}">
                        <script>
                            iziToast.success({
                                title: 'Thành công!',
                                message: '${successMessage}',
                                position: 'topRight',
                                timeout: 5000
                            });
                        </script>
                    </c:if>

                    <c:if test="${not empty errorMessage}">
                        <script>
                            iziToast.error({
                                title: 'Lỗi!',
                                message: '${errorMessage}',
                                position: 'topRight',
                                timeout: 5000
                            });
                        </script>
                    </c:if>

                    <c:if test="${not empty warningMessage}">
                        <script>
                            iziToast.warning({
                                title: 'Cảnh báo!',
                                message: '${warningMessage}',
                                position: 'topRight',
                                timeout: 7000
                            });
                        </script>
                    </c:if>

                    <!-- Auto show Import Result Modal -->
                    <c:if test="${not empty importResult}">
                        <script>
                            // Auto show modal when import result is available
                            document.addEventListener('DOMContentLoaded', function () {
                                var importResultModal = new bootstrap.Modal(document.getElementById('importResultModal'));
                                importResultModal.show();
                            });
                        </script>
                    </c:if>

                </body>

                </html>