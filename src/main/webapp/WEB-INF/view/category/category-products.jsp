<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
            <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
                <html lang="en">

                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>${parentCategory.name} - Danh sách sản phẩm</title>
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

                        /* Product card styling */
                        .product-card {
                            transition: transform 0.2s ease-in-out;
                            height: 100%;
                        }

                        .product-card:hover {
                            transform: translateY(-5px);
                            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
                        }

                        .product-image {
                            width: 100%;
                            height: 200px;
                            object-fit: cover;
                        }

                        .price {
                            color: #e74c3c;
                            font-weight: bold;
                            font-size: 1.2em;
                        }

                        /* Filter section */
                        .filter-section {
                            background: white;
                            border-radius: 8px;
                            padding: 20px;
                            margin-bottom: 20px;
                            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
                        }

                        /* Pagination */
                        .pagination .page-link {
                            color: #28a745;
                        }

                        .pagination .page-item.active .page-link {
                            background-color: #28a745;
                            border-color: #28a745;
                        }

                        /* Responsive Design */
                        @media (max-width: 768px) {
                            .content {
                                margin-left: 200px;
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
                                            <li class="breadcrumb-item active" aria-current="page">
                                                ${parentCategory.name}</li>
                                        </ol>
                                    </nav>

                                    <!-- Category Header -->
                                    <div class="row mb-4">
                                        <div class="col-12">
                                            <div class="card border-success">
                                                <div class="card-body text-center">
                                                    <div class="mb-3">
                                                        <img src="<c:url value='/images/${parentCategory.name}.png'/>"
                                                            alt="${parentCategory.name}" class="img-fluid"
                                                            style="width:80px;height:80px;">
                                                    </div>
                                                    <h2 class="card-title text-success">${parentCategory.name}</h2>
                                                    <p class="card-text">${parentCategory.description}</p>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Filter and Search Section -->
                                    <div class="filter-section">
                                        <form method="get"
                                            action="<c:url value='/category/${parentCategory.name.toLowerCase()}'/>"
                                            id="filterForm">
                                            <div class="row">
                                                <!-- Search Box -->
                                                <div class="col-md-4 mb-3">
                                                    <label for="keyword" class="form-label">Tìm kiếm sản phẩm:</label>
                                                    <input type="text" class="form-control" id="keyword" name="keyword"
                                                        value="${keyword}" placeholder="Nhập từ khóa...">
                                                </div>

                                                <!-- Category Filter -->
                                                <div class="col-md-3 mb-3">
                                                    <label for="childCategory" class="form-label">Danh mục con:</label>
                                                    <select class="form-select" id="childCategory" name="childCategory">
                                                        <option value="">Tất cả danh mục con</option>
                                                        <c:forEach var="childCat" items="${childCategories}">
                                                            <option value="${childCat.id}" <c:if
                                                                test="${selectedChildCategory == childCat.id}">selected
                                                                </c:if>>
                                                                ${childCat.name}
                                                            </option>
                                                        </c:forEach>
                                                    </select>
                                                </div>

                                                <!-- Sort Options -->
                                                <div class="col-md-2 mb-3">
                                                    <label for="sort" class="form-label">Sắp xếp theo:</label>
                                                    <select class="form-select" id="sort" name="sort">
                                                        <option value="name" <c:if test="${sortBy == 'name'}">selected
                                                            </c:if>>Tên</option>
                                                        <option value="price" <c:if test="${sortBy == 'price'}">selected
                                                            </c:if>>Giá</option>
                                                        <option value="createdAt" <c:if test="${sortBy == 'createdAt'}">
                                                            selected</c:if>>Ngày tạo</option>
                                                    </select>
                                                </div>

                                                <!-- Sort Direction -->
                                                <div class="col-md-2 mb-3">
                                                    <label for="direction" class="form-label">Thứ tự:</label>
                                                    <select class="form-select" id="direction" name="direction">
                                                        <option value="asc" <c:if test="${sortDirection == 'asc'}">
                                                            selected</c:if>>Tăng dần</option>
                                                        <option value="desc" <c:if test="${sortDirection == 'desc'}">
                                                            selected</c:if>>Giảm dần</option>
                                                    </select>
                                                </div>

                                                <!-- Filter Button -->
                                                <div class="col-md-1 mb-3 d-flex align-items-end">
                                                    <button type="submit" class="btn btn-success w-100">
                                                        <i class="fas fa-search"></i>
                                                    </button>
                                                </div>
                                            </div>
                                        </form>
                                    </div>

                                    <!-- Results Info -->
                                    <div class="row mb-3">
                                        <div class="col-12">
                                            <p class="text-muted">
                                                Hiển thị ${products.numberOfElements} trên tổng ${totalElements} sản
                                                phẩm
                                                <c:if test="${not empty keyword}">
                                                    cho từ khóa "<strong>${keyword}</strong>"
                                                </c:if>
                                                <c:if test="${selectedChildCategory != null}">
                                                    trong danh mục con đã chọn
                                                </c:if>
                                            </p>
                                        </div>
                                    </div>

                                    <!-- Products Grid -->
                                    <div class="row">
                                        <c:choose>
                                            <c:when test="${not empty products.content}">
                                                <c:forEach var="product" items="${products.content}">
                                                    <div class="col-lg-3 col-md-4 col-sm-6 mb-4">
                                                        <div class="card product-card border-0 shadow-sm">
                                                            <div class="card-body">
                                                                <div class="text-center mb-3">
                                                                    <c:choose>
                                                                        <c:when test="${not empty product.productUrl}">
                                                                            <img src="${product.productUrl}"
                                                                                alt="${product.name}"
                                                                                class="product-image rounded">
                                                                        </c:when>
                                                                        <c:otherwise>
                                                                            <div
                                                                                class="product-image bg-light rounded d-flex align-items-center justify-content-center">
                                                                                <i
                                                                                    class="fas fa-image fa-3x text-muted"></i>
                                                                            </div>
                                                                        </c:otherwise>
                                                                    </c:choose>
                                                                </div>
                                                                <h6 class="card-title">
                                                                    <a href="<c:url value='/product/${product.id}'/>"
                                                                        class="text-decoration-none text-dark">
                                                                        ${product.name}
                                                                    </a>
                                                                </h6>
                                                                <p class="card-text text-muted small">
                                                                    <c:choose>
                                                                        <c:when
                                                                            test="${product.description.length() > 80}">
                                                                            ${product.description.substring(0, 80)}...
                                                                        </c:when>
                                                                        <c:otherwise>
                                                                            ${product.description}
                                                                        </c:otherwise>
                                                                    </c:choose>
                                                                </p>
                                                                <div
                                                                    class="d-flex justify-content-between align-items-center">
                                                                    <span class="price">
                                                                        <fmt:formatNumber value="${product.price}"
                                                                            type="currency" currencySymbol=""
                                                                            maxFractionDigits="0" />đ
                                                                    </span>
                                                                    <small class="text-muted">
                                                                        Kho: ${product.stock}
                                                                    </small>
                                                                </div>
                                                                <div class="mt-2">
                                                                    <small class="text-success">
                                                                        <i class="fas fa-tag"></i>
                                                                        ${product.category.name}
                                                                    </small>
                                                                </div>
                                                                <div class="mt-3">
                                                                    <a href="<c:url value='/product/${product.id}'/>"
                                                                        class="btn btn-success btn-sm w-100">
                                                                        <i class="fas fa-eye"></i> Xem chi tiết
                                                                    </a>
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </c:forEach>
                                            </c:when>
                                            <c:otherwise>
                                                <div class="col-12">
                                                    <div class="alert alert-info text-center" role="alert">
                                                        <h4><i class="fas fa-info-circle"></i> Không tìm thấy sản phẩm
                                                        </h4>
                                                        <p>
                                                            <c:choose>
                                                                <c:when test="${not empty keyword}">
                                                                    Không có sản phẩm nào phù hợp với từ khóa
                                                                    "<strong>${keyword}</strong>".
                                                                </c:when>
                                                                <c:otherwise>
                                                                    Danh mục này hiện tại chưa có sản phẩm nào.
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </p>
                                                        <a href="<c:url value='/category/${parentCategory.name.toLowerCase()}'/>"
                                                            class="btn btn-primary">Xem tất cả sản phẩm</a>
                                                    </div>
                                                </div>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>

                                    <!-- Pagination -->
                                    <c:if test="${totalPages > 1}">
                                        <div class="row mt-4">
                                            <div class="col-12">
                                                <nav aria-label="Product pagination">
                                                    <ul class="pagination justify-content-center">
                                                        <!-- Previous page -->
                                                        <li class="page-item <c:if test=" ${!hasPrevious}">disabled
                                    </c:if>">
                                    <a class="page-link" href="<c:url value='/category/${parentCategory.name.toLowerCase()}'>
                                                <c:param name='page' value='${previousPage}'/>
                                                <c:param name='size' value='${size}'/>
                                                <c:param name='sort' value='${sortBy}'/>
                                                <c:param name='direction' value='${sortDirection}'/>
                                                <c:if test='${not empty keyword}'>
                                                    <c:param name='keyword' value='${keyword}'/>
                                                </c:if>
                                                <c:if test='${selectedChildCategory != null}'>
                                                    <c:param name='childCategory' value='${selectedChildCategory}'/>
                                                </c:if>
                                             </c:url>">
                                        <i class="fas fa-chevron-left"></i> Trước
                                    </a>
                                    </li>

                                    <!-- Page numbers -->
                                    <c:forEach begin="0" end="${totalPages - 1}" var="pageNum">
                                        <c:if test="${pageNum >= currentPage - 2 && pageNum <= currentPage + 2}">
                                            <li class="page-item <c:if test='${pageNum == currentPage}'>active</c:if>">
                                                <a class="page-link" href="<c:url value='/category/${parentCategory.name.toLowerCase()}'>
                                                        <c:param name='page' value='${pageNum}'/>
                                                        <c:param name='size' value='${size}'/>
                                                        <c:param name='sort' value='${sortBy}'/>
                                                        <c:param name='direction' value='${sortDirection}'/>
                                                        <c:if test='${not empty keyword}'>
                                                            <c:param name='keyword' value='${keyword}'/>
                                                        </c:if>
                                                        <c:if test='${selectedChildCategory != null}'>
                                                            <c:param name='childCategory' value='${selectedChildCategory}'/>
                                                        </c:if>
                                                     </c:url>">
                                                    ${pageNum + 1}
                                                </a>
                                            </li>
                                        </c:if>
                                    </c:forEach>

                                    <!-- Next page -->
                                    <li class="page-item <c:if test=" ${!hasNext}">disabled</c:if>">
                                        <a class="page-link" href="<c:url value='/category/${parentCategory.name.toLowerCase()}'>
                                                <c:param name='page' value='${nextPage}'/>
                                                <c:param name='size' value='${size}'/>
                                                <c:param name='sort' value='${sortBy}'/>
                                                <c:param name='direction' value='${sortDirection}'/>
                                                <c:if test='${not empty keyword}'>
                                                    <c:param name='keyword' value='${keyword}'/>
                                                </c:if>
                                                <c:if test='${selectedChildCategory != null}'>
                                                    <c:param name='childCategory' value='${selectedChildCategory}'/>
                                                </c:if>
                                             </c:url>">
                                            Sau <i class="fas fa-chevron-right"></i>
                                        </a>
                                    </li>
                                    </ul>
                                    </nav>
                                </div>
                            </div>
                            </c:if>
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

                                // Auto submit form when filter options change
                                document.getElementById('childCategory').addEventListener('change', function () {
                                    document.getElementById('filterForm').submit();
                                });

                                document.getElementById('sort').addEventListener('change', function () {
                                    document.getElementById('filterForm').submit();
                                });

                                document.getElementById('direction').addEventListener('change', function () {
                                    document.getElementById('filterForm').submit();
                                });
                            </script>

                            <!-- iziToast JS -->
                            <script
                                src="https://cdnjs.cloudflare.com/ajax/libs/izitoast/1.4.0/js/iziToast.min.js"></script>

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

                            <!-- Include Footer -->
                            <%@ include file="../common/footer.jsp" %>
                </body>

                </html>