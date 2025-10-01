<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!-- Product Detail Content -->

<style>
    .product-detail-card {
        background-color: white;
        border-radius: 10px;
        padding: 2rem;
        box-shadow: 0 2px 10px rgba(0,0,0,0.1);
    }

    .product-image-main {
        width: 100%;
        height: 400px;
        object-fit: cover;
        border-radius: 10px;
        background-color: #f8f9fa;
    }

    .product-image-thumbnail {
        width: 80px;
        height: 80px;
        object-fit: cover;
        border-radius: 5px;
        cursor: pointer;
        border: 2px solid transparent;
        transition: border-color 0.3s;
    }

    .product-image-thumbnail:hover,
    .product-image-thumbnail.active {
        border-color: var(--accent-color);
    }

    .product-title {
        font-size: 2rem;
        font-weight: bold;
        color: var(--primary-color);
        margin-bottom: 1rem;
    }

    .product-price {
        font-size: 2.5rem;
        font-weight: bold;
        color: #e74c3c;
        margin-bottom: 1.5rem;
    }

    .info-row {
        padding: 0.75rem 0;
        border-bottom: 1px solid #ecf0f1;
    }

    .info-label {
        font-weight: 600;
        color: #7f8c8d;
    }

    .store-info-card {
        background-color: #f8f9fa;
        padding: 1.5rem;
        border-radius: 10px;
        border: 1px solid #dee2e6;
    }
</style>

<div class="container my-4">
    <!-- Breadcrumb -->
    <nav aria-label="breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="/">Trang chủ</a></li>
            <li class="breadcrumb-item"><a href="/products">Sản phẩm</a></li>
            <li class="breadcrumb-item active">${product.productName}</li>
        </ol>
    </nav>

    <div class="product-detail-card">
        <div class="row">
            <!-- Product Images -->
            <div class="col-md-6">
                <c:choose>
                    <c:when test="${not empty productImagesList}">
                        <!-- Main Image -->
                        <img src="${productImagesList[0]}" id="mainProductImage"
                             class="product-image-main mb-3" alt="${product.productName}">

                        <!-- Thumbnails -->
                        <c:if test="${fn:length(productImagesList) > 1}">
                            <div class="d-flex gap-2 flex-wrap">
                                <c:forEach items="${productImagesList}" var="image" varStatus="status">
                                    <img src="${image}" class="product-image-thumbnail ${status.index == 0 ? 'active' : ''}"
                                         onclick="changeMainImage('${image}', this)" alt="Thumbnail ${status.index + 1}">
                                </c:forEach>
                            </div>
                        </c:if>
                    </c:when>
                    <c:otherwise>
                        <div class="product-image-main d-flex align-items-center justify-content-center bg-light">
                            <div class="text-center">
                                <i class="fas fa-image fa-5x text-muted mb-3"></i>
                                <p class="text-muted">Không có ảnh sản phẩm</p>
                            </div>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>

            <!-- Product Info -->
            <div class="col-md-6">
                <!-- Title -->
                <h1 class="product-title">${product.productName}</h1>

                <!-- Badges -->
                <div class="mb-3">
                    <span class="badge bg-info me-2">
                        <i class="fas fa-tag"></i> ${product.categoryDisplayName}
                    </span>
                    <c:choose>
                        <c:when test="${product.stockQuantity > 0}">
                            <span class="badge bg-success">
                                <i class="fas fa-check-circle"></i> Còn hàng
                            </span>
                        </c:when>
                        <c:otherwise>
                            <span class="badge bg-danger">
                                <i class="fas fa-times-circle"></i> Hết hàng
                            </span>
                        </c:otherwise>
                    </c:choose>
                </div>

                <!-- Price -->
                <div class="product-price">${product.formattedPrice}</div>

                <!-- Product Details -->
                <div class="mb-4">
                    <div class="info-row">
                        <span class="info-label">SKU:</span>
                        <span class="ms-3">${product.sku}</span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Số lượng còn lại:</span>
                        <span class="ms-3">
                            <c:choose>
                                <c:when test="${product.stockQuantity > 0}">
                                    <span class="badge bg-success">${product.stockQuantity}</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge bg-danger">Hết hàng</span>
                                </c:otherwise>
                            </c:choose>
                        </span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Trạng thái:</span>
                        <span class="ms-3">
                            <c:choose>
                                <c:when test="${product.isActive}">
                                    <span class="badge bg-success">Đang bán</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge bg-secondary">Tạm ngưng</span>
                                </c:otherwise>
                            </c:choose>
                        </span>
                    </div>
                </div>

                <!-- Actions -->
                <div class="d-grid gap-2">
                    <c:choose>
                        <c:when test="${product.stockQuantity > 0 && product.isActive}">
                            <button class="btn btn-primary btn-lg" onclick="alert('Tính năng mua hàng đang phát triển')">
                                <i class="fas fa-shopping-cart"></i> Mua ngay
                            </button>
                            <button class="btn btn-outline-primary btn-lg" onclick="alert('Tính năng giỏ hàng đang phát triển')">
                                <i class="fas fa-cart-plus"></i> Thêm vào giỏ
                            </button>
                        </c:when>
                        <c:otherwise>
                            <button class="btn btn-secondary btn-lg" disabled>
                                <i class="fas fa-times-circle"></i> Không thể mua
                            </button>
                        </c:otherwise>
                    </c:choose>
                </div>

                <!-- Store Info -->
                <div class="store-info-card mt-4">
                    <h5 class="mb-3"><i class="fas fa-store"></i> Thông tin cửa hàng</h5>
                    <div class="d-flex align-items-center">
                        <c:choose>
                            <c:when test="${not empty product.storeLogoUrl}">
                                <img src="${product.storeLogoUrl}" alt="${product.storeName}"
                                     class="rounded-circle me-3" width="60" height="60">
                            </c:when>
                            <c:otherwise>
                                <div class="rounded-circle bg-primary text-white d-flex align-items-center justify-content-center me-3"
                                     style="width: 60px; height: 60px;">
                                    <i class="fas fa-store fa-2x"></i>
                                </div>
                            </c:otherwise>
                        </c:choose>
                        <div>
                            <h6 class="mb-1">${product.storeName}</h6>
                            <p class="text-muted mb-0 small">Người bán: ${product.sellerName}</p>
                        </div>
                    </div>
                    <a href="/stores/${product.storeId}" class="btn btn-outline-primary btn-sm mt-3 w-100">
                        <i class="fas fa-external-link-alt"></i> Xem cửa hàng
                    </a>
                </div>
            </div>
        </div>

        <!-- Product Description -->
        <div class="row mt-5">
            <div class="col-12">
                <h3 class="mb-3"><i class="fas fa-info-circle"></i> Mô tả sản phẩm</h3>
                <div class="border-top pt-3">
                    <c:choose>
                        <c:when test="${not empty product.description}">
                            <p style="white-space: pre-wrap;">${product.description}</p>
                        </c:when>
                        <c:otherwise>
                            <p class="text-muted fst-italic">Chưa có mô tả cho sản phẩm này.</p>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>

        <!-- Back Button -->
        <div class="row mt-4">
            <div class="col-12">
                <a href="/products" class="btn btn-secondary">
                    <i class="fas fa-arrow-left"></i> Quay lại danh sách
                </a>
            </div>
        </div>
    </div>
</div>

<script>
    function changeMainImage(imageSrc, thumbnailElement) {
        document.getElementById('mainProductImage').src = imageSrc;
        document.querySelectorAll('.product-image-thumbnail').forEach(thumb => {
            thumb.classList.remove('active');
        });
        thumbnailElement.classList.add('active');
    }
</script>
