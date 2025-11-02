<%@ page contentType="text/html; charset=UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <title>Chi tiết sản phẩm</title>
                <jsp:include page="../common/head.jsp" />
            </head>

            <body>
                <jsp:include page="../common/navbar.jsp" />
                <jsp:include page="../common/sidebar.jsp" />

                <div class="container mt-4">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h4>Chi tiết sản phẩm #${product.id}</h4>
                        <a class="btn btn-outline-secondary" href="/seller/dashboard">
                            <i class="fas fa-arrow-left"></i> Quay lại
                        </a>
                    </div>

                    <div class="card">
                        <div class="card-body row g-3">

                            <div class="col-md-6">
                                <label class="form-label">Tên sản phẩm</label>
                                <div class="form-control-plaintext">${product.name}</div>
                            </div>

                            <div class="col-md-6">
                                <label class="form-label">Slug</label>
                                <div class="form-control-plaintext">${product.slug}</div>
                            </div>

                            <div class="col-md-6">
                                <label class="form-label">Danh mục</label>
                                <div class="form-control-plaintext">${product.category != null ? product.category.name :
                                    '-'}</div>
                            </div>

                            <div class="col-md-6">
                                <label class="form-label">Giá</label>
                                <div class="form-control-plaintext">
                                    <fmt:formatNumber value="${product.price}" type="currency" currencySymbol="₫" />
                                </div>
                            </div>

                            <div class="col-md-6">
                                <label class="form-label">Trạng thái</label>
                                <div class="form-control-plaintext">${product.status}</div>
                            </div>

                            <div class="col-md-6">
                                <label class="form-label">Tồn (stock)</label>
                                <div class="form-control-plaintext">${product.stock}</div>
                            </div>

                            <div class="col-md-12">
                                <label class="form-label">Mô tả</label>
                                <div class="border rounded p-2 bg-white" style="min-height:120px">${product.description}
                                </div>
                            </div>

                            <div class="col-md-12">
                                <label class="form-label">Ảnh</label>
                                <div>
                                    <c:if test="${not empty product.productUrl}">
                                        <img src="${product.productUrl}" alt=""
                                            style="max-width:360px;max-height:360px;object-fit:contain;border:1px solid #eee;padding:8px;background:#fff;" />
                                    </c:if>
                                    <c:if test="${empty product.productUrl}">
                                        <div class="text-muted">Không có ảnh</div>
                                    </c:if>
                                </div>
                            </div>

                        </div>
                    </div>

                </div>

                <jsp:include page="../common/footer.jsp" />
            </body>

            </html>