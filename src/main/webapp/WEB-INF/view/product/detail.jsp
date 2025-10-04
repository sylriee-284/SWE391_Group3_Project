<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
            <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
                <html lang="en">

                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>${product.name} - Chi tiết sản phẩm</title>
                    <!-- Latest compiled and minified CSS -->
                    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css"
                        rel="stylesheet">

                    <!-- Latest compiled JavaScript -->
                    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

                    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>

                    <!-- Font Awesome for icons -->
                    <link rel="stylesheet"
                        href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

                    <!-- iziToast CSS -->
                    <link rel="stylesheet"
                        href="https://cdnjs.cloudflare.com/ajax/libs/izitoast/1.4.0/css/iziToast.min.css" />

                    <style>
                        /* Content styling */
                        .content {
                            flex-grow: 1;
                            padding: 20px;
                            background-color: #ecf0f1;
                            margin-left: 0;
                            transition: margin-left 0.3s ease;
                        }

                        .content.shifted {
                            margin-left: 250px;
                        }

                        .content h1 {
                            font-size: 28px;
                            color: #2c3e50;
                        }

                        /* Product image styling */
                        .product-image {
                            width: 100%;
                            max-width: 500px;
                            height: 400px;
                            object-fit: cover;
                            border-radius: 8px;
                            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
                        }

                        .product-placeholder {
                            width: 100%;
                            max-width: 500px;
                            height: 400px;
                            background-color: #f8f9fa;
                            border-radius: 8px;
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
                        }

                        /* Price styling */
                        .price {
                            color: #e74c3c;
                            font-weight: bold;
                            font-size: 2rem;
                        }

                        .original-price {
                            color: #7f8c8d;
                            text-decoration: line-through;
                            font-size: 1.2rem;
                        }

                        /* Product info cards */
                        .info-card {
                            background: white;
                            border-radius: 8px;
                            padding: 20px;
                            margin-bottom: 20px;
                            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
                        }

                        /* Stock indicator */
                        .stock-indicator {
                            padding: 5px 10px;
                            border-radius: 15px;
                            font-size: 0.9rem;
                            font-weight: bold;
                        }

                        .stock-available {
                            background-color: #d4edda;
                            color: #155724;
                        }

                        .stock-low {
                            background-color: #fff3cd;
                            color: #856404;
                        }

                        .stock-out {
                            background-color: #f8d7da;
                            color: #721c24;
                        }

                        /* Action buttons */
                        .action-buttons {
                            position: sticky;
                            top: 20px;
                        }

                        .btn-buy-now {
                            background: linear-gradient(45deg, #28a745, #20c997);
                            border: none;
                            color: white;
                            font-weight: bold;
                            padding: 12px 30px;
                            border-radius: 25px;
                            transition: all 0.3s ease;
                        }

                        .btn-buy-now:hover {
                            background: linear-gradient(45deg, #218838, #1ea879);
                            transform: translateY(-2px);
                            box-shadow: 0 4px 15px rgba(40, 167, 69, 0.3);
                            color: white;
                        }



                        /* Quantity input */
                        .quantity-input {
                            border: 2px solid #28a745;
                            border-radius: 8px;
                            text-align: center;
                            font-weight: bold;
                        }





                        /* Responsive Design */
                        @media (max-width: 768px) {
                            .content {
                                margin-left: 200px;
                            }

                            .price {
                                font-size: 1.5rem;
                            }
                        }

                        @media (max-width: 480px) {
                            .content {
                                margin-left: 150px;
                            }
                        }

                        html,
                        body {
                            height: 100%;
                        }

                        .wrapper {
                            min-height: 100%;
                            display: flex;
                            flex-direction: column;
                        }

                        .content {
                            flex: 1;
                        }
                    </style>
                </head>

                <body>
                    <!-- Include Navbar -->
                    <%@ include file="../common/navbar.jsp" %>

                        <!-- Include Sidebar -->
                        <%@ include file="../common/sidebar.jsp" %>

                            <!-- Main Content -->
                            <div class="content" id="content">
                                <br />

                                <div class="container-fluid">
                                    <!-- Breadcrumb -->
                                    <nav aria-label="breadcrumb">
                                        <ol class="breadcrumb">
                                            <li class="breadcrumb-item"><a href="<c:url value='/'/>"
                                                    class="text-decoration-none">Trang chủ</a></li>
                                            <li class="breadcrumb-item">
                                                <a href="<c:url value='/category/${product.category.parent.name.toLowerCase()}'/>"
                                                    class="text-decoration-none">${product.category.parent.name}</a>
                                            </li>
                                            <li class="breadcrumb-item">
                                                <a href="<c:url value='/category/${product.category.parent.name.toLowerCase()}?childCategory=${product.category.id}'/>"
                                                    class="text-decoration-none">${product.category.name}</a>
                                            </li>
                                            <li class="breadcrumb-item active" aria-current="page">${product.name}</li>
                                        </ol>
                                    </nav>

                                    <div class="row">
                                        <!-- Product Image -->
                                        <div class="col-lg-6 mb-4">
                                            <div class="text-center">
                                                <c:choose>
                                                    <c:when test="${not empty product.productUrl}">
                                                        <img src="${product.productUrl}" alt="${product.name}"
                                                            class="product-image">
                                                    </c:when>
                                                    <c:otherwise>
                                                        <div class="product-placeholder">
                                                            <div class="text-center">
                                                                <i class="fas fa-image fa-4x text-muted mb-3"></i>
                                                                <p class="text-muted">Chưa có hình ảnh</p>
                                                            </div>
                                                        </div>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </div>

                                        <!-- Product Info -->
                                        <div class="col-lg-6">
                                            <div class="info-card">
                                                <!-- Product Name -->
                                                <h1 class="mb-3">${product.name}</h1>

                                                <!-- Category Badge -->
                                                <div class="mb-3">
                                                    <span class="badge bg-success fs-6">
                                                        <i class="fas fa-tag"></i> ${product.category.name}
                                                    </span>
                                                </div>

                                                <!-- Price -->
                                                <div class="mb-4">
                                                    <div class="price">
                                                        <fmt:formatNumber value="${product.price}" type="currency"
                                                            currencySymbol="" maxFractionDigits="0" />đ
                                                    </div>
                                                </div>

                                                <!-- Stock Status -->
                                                <div class="mb-4">
                                                    <span
                                                        class="stock-indicator ${product.stock > 10 ? 'stock-available' : (product.stock > 0 ? 'stock-low' : 'stock-out')}">
                                                        <i class="fas fa-boxes"></i>
                                                        <c:choose>
                                                            <c:when test="${product.stock > 10}">
                                                                Còn hàng (${product.stock} sản phẩm)
                                                            </c:when>
                                                            <c:when test="${product.stock > 0}">
                                                                Sắp hết hàng (${product.stock} sản phẩm)
                                                            </c:when>
                                                            <c:otherwise>
                                                                Hết hàng
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </span>
                                                </div>

                                                <!-- Product Status -->
                                                <div class="mb-4">
                                                    <span
                                                        class="badge ${product.status == 'ACTIVE' ? 'bg-success' : 'bg-warning'} fs-6">
                                                        <i class="fas fa-circle"></i>
                                                        ${product.status == 'ACTIVE' ? 'Đang bán' : 'Tạm ngưng'}
                                                    </span>
                                                </div>

                                                <!-- Quantity and Action Buttons -->
                                                <c:if test="${product.status == 'ACTIVE' && product.stock > 0}">
                                                    <div class="action-buttons">
                                                        <form id="productForm" method="post">
                                                            <!-- Quantity Selection -->
                                                            <div class="row mb-4">
                                                                <div class="col-md-6">
                                                                    <label class="form-label fw-bold">Số lượng:</label>
                                                                    <input type="number" id="quantity" name="quantity"
                                                                        class="form-control quantity-input" value="1"
                                                                        min="1" max="${product.stock}"
                                                                        style="width: 100px;">
                                                                </div>
                                                            </div>

                                                            <!-- Action Button -->
                                                            <div class="d-grid">
                                                                <button type="button" class="btn btn-buy-now btn-lg"
                                                                    onclick="buyNow()">
                                                                    <i class="fas fa-bolt"></i> Mua ngay
                                                                </button>
                                                            </div>
                                                        </form>
                                                    </div>
                                                </c:if>

                                                <c:if test="${product.status != 'ACTIVE' || product.stock <= 0}">
                                                    <div class="alert alert-warning text-center">
                                                        <i class="fas fa-exclamation-triangle"></i>
                                                        Sản phẩm hiện tại không thể mua
                                                    </div>
                                                </c:if>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Product Description -->
                                    <div class="row mt-4">
                                        <div class="col-12">
                                            <div class="info-card">
                                                <h3 class="mb-3">
                                                    <i class="fas fa-info-circle text-success"></i> Mô tả sản phẩm
                                                </h3>
                                                <c:choose>
                                                    <c:when test="${not empty product.description}">
                                                        <div class="product-description">
                                                            <p>
                                                                ${product.description}</p>
                                                        </div>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <p class="text-muted fst-italic">Chưa có mô tả cho sản phẩm này.
                                                        </p>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </div>
                                    </div>




                                </div>
                            </div>

                            <script>
                                // Toggle sidebar function
                                function toggleSidebar() {
                                    var sidebar = document.getElementById('sidebar');
                                    var content = document.getElementById('content');
                                    sidebar.classList.toggle('active');
                                    content.classList.toggle('shifted');
                                }



                                // Buy now function
                                function buyNow() {
                                    var form = document.getElementById('productForm');
                                    form.action = '<c:url value="/product/${product.id}/buy-now"/>';
                                    form.submit();
                                }

                                // Validate quantity input
                                document.getElementById('quantity').addEventListener('input', function () {
                                    var value = parseInt(this.value);
                                    var min = parseInt(this.min);
                                    var max = parseInt(this.max);

                                    if (value < min) this.value = min;
                                    if (value > max) this.value = max;
                                });
                            </script>

                            <!-- iziToast JS -->
                            <script
                                src="https://cdnjs.cloudflare.com/ajax/libs/izitoast/1.4.0/js/iziToast.min.js"></script>

                            <!-- Script to display notifications using iziToast -->
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

                            <!-- Include Footer -->
                            <%@ include file="../common/footer.jsp" %>
                </body>

                </html>