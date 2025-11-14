<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
            <%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
                <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
                <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

                <!DOCTYPE html>
                <html lang="en">

                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>Đăng ký Cửa hàng - MMO Market System</title>

                    <!-- Include common head with all CSS and JS -->
                    <jsp:include page="../common/head.jsp" />
                    
                    
                </head>

                <body>
                    <!-- Include Navbar -->
                    <jsp:include page="../common/navbar.jsp" />

                    <!-- Include Sidebar -->
                    <jsp:include page="../common/sidebar.jsp" />

                    <!-- Sidebar Overlay for Mobile -->
                    <div class="sidebar-overlay" id="sidebarOverlay" onclick="toggleSidebar()"></div>

                    <!-- Main Content Area -->
                    <div class="content" id="content">
                        <div class="container-fluid px-5">
                            <div class="row justify-content-center">
                                <div class="col-lg-10">
                                    <!-- Server messages for toast notifications -->
                                    <c:if test="${not empty error}">
                                        <div id="editStoreError" data-error="${fn:escapeXml(error)}" style="display:none;"></div>
                                    </c:if>
                                    <c:if test="${not empty success}">
                                        <div id="editStoreSuccess" data-success="${fn:escapeXml(success)}" style="display:none;"></div>
                                    </c:if>
                                    
                                    <!-- Existing Inactive Store Section -->
                                    <c:if test="${not empty inactiveStore}">
                                        <div class="mb-4">
                                            <!-- Hero Section -->
                                            <div class="d-flex align-items-center gap-3 mb-4">
                                                <c:choose>
                                                    <c:when test="${inactiveStore.status == 'INACTIVE'}">
                                                        <div class="rounded-circle bg-danger text-white d-flex align-items-center justify-content-center" style="width:64px;height:64px;">
                                                            <i class="fas fa-store-slash fa-lg"></i>
                                                        </div>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <div class="rounded-circle bg-warning text-white d-flex align-items-center justify-content-center" style="width:64px;height:64px;">
                                                            <i class="fas fa-store fa-lg"></i>
                                                        </div>
                                                    </c:otherwise>
                                                </c:choose>
                                                <div>
                                                    <h2 class="h4 mb-1">Cửa hàng của bạn</h2>
                                                    <c:choose>
                                                        <c:when test="${inactiveStore.status == 'INACTIVE'}">
                                                            <p class="mb-0 text-muted">Cửa hàng đang đóng. Vui lòng kích hoạt lại để tiếp tục bán hàng</p>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <p class="mb-0 text-muted">Hoàn tất thanh toán ký quỹ để kích hoạt cửa hàng</p>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </div>

                                            <div class="card shadow-sm border-0">
                                                <div class="card-body p-4">
                                                    <!-- Store Status Badge -->
                                                    <div class="mb-3">
                                                        <c:choose>
                                                            <c:when test="${inactiveStore.status == 'INACTIVE'}">
                                                                <span class="badge bg-danger fs-6"><i class="fas fa-times-circle"></i> Cửa hàng đã đóng</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="badge bg-info fs-6"><i class="fas fa-clock"></i> Chờ kích hoạt</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>

                                                    <!-- Store Information Grid -->
                                                    <div class="row g-4 mb-4">
                                                        <div class="col-md-6">
                                                            <div class="p-3 bg-light rounded">
                                                                <h6 class="text-muted mb-3"><i class="fas fa-info-circle me-2"></i>Thông tin cửa hàng</h6>
                                                                <div class="mb-2">
                                                                    <small class="text-muted d-block">Mã cửa hàng</small>
                                                                    <strong>#${inactiveStore.id}</strong>
                                                                </div>
                                                                <div class="mb-2">
                                                                    <small class="text-muted d-block">Tên cửa hàng</small>
                                                                    <strong>${inactiveStore.storeName}</strong>
                                                                </div>
                                                                <c:if test="${not empty inactiveStore.description}">
                                                                    <div class="mb-2">
                                                                        <small class="text-muted d-block">Mô tả</small>
                                                                        <span class="text-muted">${inactiveStore.description}</span>
                                                                    </div>
                                                                </c:if>
                                                                <div>
                                                                    <small class="text-muted d-block">Chủ cửa hàng</small>
                                                                    <strong><i class="fas fa-user me-1"></i>${inactiveStore.owner.username}</strong>
                                                                </div>
                                                            </div>
                                                        </div>

                                                        <div class="col-md-6">
                                                            <div class="p-3 bg-light rounded">
                                                                <h6 class="text-muted mb-3"><i class="fas fa-money-check-alt me-2"></i>Thông tin tài chính</h6>
                                                                <div class="mb-2">
                                                                    <small class="text-muted d-block">Số tiền ký quỹ</small>
                                                                    <strong class="text-danger fs-5">
                                                                        <fmt:formatNumber value="${inactiveStore.depositAmount}" type="number" pattern="#,###" /> VNĐ
                                                                    </strong>
                                                                </div>
                                                                <div class="mb-2">
                                                                    <small class="text-muted d-block">Giá niêm yết tối đa</small>
                                                                    <strong class="text-success">
                                                                        <fmt:formatNumber value="${inactiveStore.maxListingPrice}" type="number" pattern="#,###" /> VNĐ
                                                                    </strong>
                                                                </div>
                                                                <div>
                                                                    <small class="text-muted d-block">Mô hình phí</small>
                                                                    <span class="badge bg-primary text-capitalize">${inactiveStore.feeModel}</span>
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </div>

                                                    <!-- Contract Information -->
                                                    <div class="mb-4">
                                                        <div class="card border-0 shadow-sm">
                                                            <div class="card-header bg-primary bg-gradient text-white">
                                                                <h6 class="mb-0"><i class="fas fa-file-contract me-2"></i>Điều khoản hợp đồng - Mô hình phí đã chọn</h6>
                                                            </div>
                                                            <div class="card-body">
                                                                <c:choose>
                                                                    <c:when test="${inactiveStore.feeModel == 'PERCENTAGE'}">
                                                                        <!-- Percentage Fee Model Contract -->
                                                                        <div class="mb-3">
                                                                            <h6 class="text-primary">
                                                                                <i class="fas fa-percent me-2"></i>Tùy chọn 1: Phí theo phần trăm
                                                                                <span class="badge bg-info ms-2">Khuyến nghị</span>
                                                                            </h6>
                                                                        </div>
                                                                        
                                                                        <div class="mb-3">
                                                                            <p class="mb-2"><strong>Hệ thống sẽ áp dụng mức phí giao dịch dựa trên giá trị đơn hàng như sau:</strong></p>
                                                                            <ul class="list-unstyled ms-3">
                                                                                <li class="mb-2">
                                                                                    <i class="fas fa-arrow-right text-success me-2"></i>
                                                                                    Đơn hàng dưới <strong>100.000 VNĐ</strong> → Phí cố định: <strong class="text-danger"><fmt:formatNumber value="${fixedFee}" type="number" pattern="#,###" /> VNĐ</strong>
                                                                                </li>
                                                                                <li class="mb-2">
                                                                                    <i class="fas fa-arrow-right text-primary me-2"></i>
                                                                                    Đơn hàng từ <strong>100.000 VNĐ</strong> trở lên → Phí theo tỷ lệ: <strong class="text-danger"><fmt:formatNumber value="${percentageFee}" type="number" maxFractionDigits="2" />%</strong> trên tổng giá trị đơn hàng
                                                                                </li>
                                                                            </ul>
                                                                        </div>

                                                                        <div class="alert alert-success border-0 mb-0">
                                                                            <h6 class="alert-heading mb-2"><i class="fas fa-money-bill-wave me-2"></i>Chính sách hoàn phí ký quỹ:</h6>
                                                                            <ul class="mb-2 small">
                                                                                <li>Nếu cửa hàng đóng <strong>sau ${maxRefundRateMinDuration} tháng</strong> kể từ ngày kích hoạt → hoàn <strong class="text-success"><fmt:formatNumber value="${percentageMaxRefundRate}" type="number" maxFractionDigits="0" />% phí ký quỹ</strong>.</li>
                                                                                <li>Nếu cửa hàng đóng <strong>trước ${maxRefundRateMinDuration} tháng</strong> → hoàn <strong class="text-warning"><fmt:formatNumber value="${percentageMinRefundRate}" type="number" maxFractionDigits="0" />% phí ký quỹ</strong>.</li>
                                                                            </ul>
                                                                            <p class="mb-0 small fst-italic">
                                                                                <i class="fas fa-lightbulb text-warning me-1"></i>
                                                                                Chính sách này đảm bảo tính công bằng, khuyến khích hoạt động lâu dài và bảo vệ quyền lợi của cả người mua và người bán.
                                                                            </p>
                                                                        </div>
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <!-- No Fee Model Contract -->
                                                                        <div class="mb-3">
                                                                            <h6 class="text-muted">
                                                                                <i class="fas fa-circle me-2"></i>Tùy chọn 2: Không tính phí
                                                                            </h6>
                                                                        </div>
                                                                        
                                                                        <div class="mb-3">
                                                                            <ul class="list-unstyled ms-3">
                                                                                <li class="mb-2">
                                                                                    <i class="fas fa-check-circle text-success me-2"></i>
                                                                                    Người bán <strong>không phải trả bất kỳ khoản phí giao dịch nào</strong> cho các đơn hàng.
                                                                                </li>
                                                                                <li class="mb-2">
                                                                                    <i class="fas fa-check-circle text-success me-2"></i>
                                                                                    Toàn bộ doanh thu sẽ được chuyển <strong>100%</strong> vào ví hệ thống của người bán.
                                                                                </li>
                                                                            </ul>
                                                                        </div>

                                                                        <div class="alert alert-warning border-0 mb-0">
                                                                            <h6 class="alert-heading mb-2"><i class="fas fa-exclamation-triangle me-2"></i>Chính sách hoàn phí ký quỹ:</h6>
                                                                            <ul class="mb-2 small">
                                                                                <li>Đóng cửa hàng → hoàn <strong class="text-warning"><fmt:formatNumber value="${noFeeRefundRate}" type="number" maxFractionDigits="0" />% phí ký quỹ</strong> (không kể thời gian).</li>
                                                                            </ul>
                                                                            <p class="mb-0 small fst-italic">
                                                                                <i class="fas fa-lightbulb text-warning me-1"></i>
                                                                                Phù hợp với các cửa hàng nhỏ, thử nghiệm hoặc hoạt động ngắn hạn, ưu tiên đơn giản và không phát sinh phí giao dịch.
                                                                            </p>
                                                                        </div>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </div>
                                                        </div>
                                                    </div>
                                                    
                                                    <!-- Action Section -->
                                                    <div class="border-top pt-4">
                                                        <!-- Different message based on store status -->
                                                        <c:choose>
                                                            <c:when test="${inactiveStore.status == 'INACTIVE'}">
                                                                <div class="alert alert-warning border-0 d-flex align-items-center mb-3">
                                                                    <i class="fas fa-exclamation-triangle fa-2x me-3"></i>
                                                                    <div>
                                                                        <strong>Cửa hàng đang đóng</strong><br>
                                                                        <small>Vui lòng kích hoạt lại cửa hàng bằng cách thanh toán ký quỹ để tiếp tục bán hàng trên nền tảng.</small>
                                                                    </div>
                                                                </div>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <div class="alert alert-info border-0 d-flex align-items-center mb-3">
                                                                    <i class="fas fa-info-circle fa-2x me-3"></i>
                                                                    <div>
                                                                        <strong>Cửa hàng đang chờ kích hoạt</strong><br>
                                                                        <small>Vui lòng thanh toán ký quỹ để bắt đầu bán hàng trên nền tảng.</small>
                                                                    </div>
                                                                </div>
                                                            </c:otherwise>
                                                        </c:choose>
                                                        <c:choose>
                                                            <c:when test="${userBalance.compareTo(inactiveStore.depositAmount) >= 0}">
                                                                <div class="d-grid gap-2 d-md-flex">
                                                                    <button type="button" class="btn btn-outline-primary btn-lg" onclick="openEditModal()">
                                                                        <i class="fas fa-edit me-2"></i> Sửa thông tin
                                                                    </button>
                                                                    <form action="${pageContext.request.contextPath}/seller/retry-deposit/${inactiveStore.id}" method="POST" class="flex-grow-1">
                                                                        <button type="submit" class="btn btn-success btn-lg w-100">
                                                                            <i class="fas fa-check-circle me-2"></i> Kích hoạt cửa hàng (Thanh toán ký quỹ)
                                                                        </button>
                                                                    </form>
                                                                </div>
                                                                <div class="mt-2 text-center">
                                                                    <small class="text-muted">
                                                                        <i class="fas fa-wallet me-1"></i>
                                                                        Số dư hiện tại: <strong class="text-success"><fmt:formatNumber value="${userBalance}" type="number" pattern="#,###" /> VNĐ</strong>
                                                                    </small>
                                                                </div>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <div class="alert alert-warning border-0 d-flex align-items-center mb-3">
                                                                    <i class="fas fa-exclamation-triangle fa-2x me-3"></i>
                                                                    <div>
                                                                        <strong>Số dư không đủ</strong><br>
                                                                        <small>Bạn cần nạp thêm <strong><fmt:formatNumber value="${inactiveStore.depositAmount.subtract(userBalance)}" type="number" pattern="#,###" /> VNĐ</strong> để kích hoạt cửa hàng</small>
                                                                    </div>
                                                                </div>
                                                                <div class="d-grid gap-2">
                                                                    <button type="button" class="btn btn-outline-primary btn-lg" onclick="openEditModal()">
                                                                        <i class="fas fa-edit me-2"></i> Sửa thông tin cửa hàng
                                                                    </button>
                                                                    <a href="${pageContext.request.contextPath}/wallet/deposit" class="btn btn-primary btn-lg">
                                                                        <i class="fas fa-wallet me-2"></i> Nạp tiền qua VNPay
                                                                    </a>
                                                                </div>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </c:if>

                            <!-- Seller Registration Card -->
                            <c:if test="${empty inactiveStore}">
                                <!-- Hero Section -->
                                <div class="d-flex align-items-center gap-3 mb-4">
                                    <div class="rounded-circle bg-primary text-white d-flex align-items-center justify-content-center" style="width:64px;height:64px;">
                                        <i class="fas fa-store fa-lg"></i>
                                    </div>
                                    <div>
                                        <h2 class="h4 mb-1">Đăng ký bán hàng</h2>
                                        <p class="mb-0 text-muted">Tạo cửa hàng của bạn và bắt đầu kinh doanh trên nền tảng</p>
                                    </div>
                                </div>

                                <div class="card shadow-sm border-0">
                                    <div class="card-body p-4">
                                        <!-- Server messages stored for client-side toast (iziToast) -->
                                        <c:if test="${not empty error}">
                                            <div id="serverError" data-error="${fn:escapeXml(error)}"></div>
                                        </c:if>
                                        <c:if test="${not empty success}">
                                            <div id="serverSuccess" data-success="${fn:escapeXml(success)}"></div>
                                        </c:if>

                                        <!-- Registration Form -->
                                        <form action="${pageContext.request.contextPath}/seller/register" method="POST"
                                            id="sellerRegistrationForm">
                                            <!-- Owner Information Section -->
                                            <div class="mb-4">
                                                <h5 class="border-bottom pb-2 mb-3">
                                                    <i class="fas fa-user text-primary me-2"></i> Thông tin chủ cửa hàng
                                                </h5>
                                                <div class="row g-3">
                                                    <div class="col-md-6">
                                                        <label class="form-label fw-semibold" for="userId">ID người dùng</label>
                                                        <div class="input-group">
                                                            <span class="input-group-text bg-light"><i class="fas fa-id-card"></i></span>
                                                            <input type="text" class="form-control" id="userId" value="#${user.id}" readonly>
                                                        </div>
                                                    </div>
                                                    <div class="col-md-6">
                                                        <label class="form-label fw-semibold" for="username">Tên đăng nhập</label>
                                                        <div class="input-group">
                                                            <span class="input-group-text bg-light"><i class="fas fa-user"></i></span>
                                                            <input type="text" class="form-control" id="username" value="${user.username}" readonly>
                                                            <input type="hidden" name="ownerName" value="${user.username}">
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>

                                            <!-- Store Information Section -->
                                            <div class="mb-4">
                                                <h5 class="border-bottom pb-2 mb-3">
                                                    <i class="fas fa-store text-primary me-2"></i> Thông tin cửa hàng
                                                </h5>
                                                <div class="mb-3">
                                                    <label class="form-label fw-semibold" for="storeName">
                                                        Tên cửa hàng <span class="text-danger">*</span>
                                                    </label>
                                                    <div class="input-group">
                                                        <span class="input-group-text bg-light"><i class="fas fa-store"></i></span>
                                                        <input type="text" class="form-control" id="storeName"
                                                            name="storeName" required minlength="3" maxlength="100"
                                                            value="${storeName}"
                                                            data-store-check-url="${pageContext.request.contextPath}/seller/check-store-name"
                                                            placeholder="Nhập tên cửa hàng của bạn">
                                                    </div>
                                                    <small class="text-muted d-block mt-1"><i class="fas fa-info-circle me-1"></i>Tên cửa hàng phải là duy nhất</small>
                                                    <div id="storeNameFeedback" class="invalid-feedback"></div>
                                                </div>
                                                <div class="mb-3">
                                                    <label class="form-label fw-semibold" for="storeDescription">Mô tả cửa hàng</label>
                                                    <textarea class="form-control" id="storeDescription"
                                                        name="storeDescription" rows="4"
                                                        maxlength="500"
                                                        placeholder="Giới thiệu ngắn gọn về cửa hàng của bạn...">${storeDescription}</textarea>
                                                    <small class="text-muted d-block mt-1"><i class="fas fa-info-circle me-1"></i>Tối đa 500 ký tự</small>
                                                </div>
                                            </div>

                                            <!-- Deposit Information Section -->
                                            <div class="mb-4">
                                                <h5 class="border-bottom pb-2 mb-3">
                                                    <i class="fas fa-money-check-alt text-success me-2"></i> Thông tin ký quỹ
                                                </h5>
                                                <div class="row g-3">
                                                    <div class="col-md-6">
                                                        <label class="form-label fw-semibold" for="depositAmount">
                                                            Số tiền ký quỹ <span class="text-danger">*</span>
                                                        </label>
                                                        <div class="input-group input-group-lg">
                                                            <span class="input-group-text bg-light"><i class="fas fa-money-bill-wave"></i></span>
                                                            <input type="text" class="form-control text-end"
                                                                id="depositAmount" name="depositAmount" required
                                                                placeholder="0">
                                                            <span class="input-group-text bg-light">VNĐ</span>
                                                        </div>
                                                        <div id="depositAmountHelp" class="form-text">
                                                            <i class="fas fa-info-circle text-primary me-1"></i>
                                                            Tối thiểu: <strong><fmt:formatNumber value="${minDepositAmount}" type="number" pattern="#,###" /> VNĐ</strong>, bước nhảy: 100.000 VNĐ
                                                        </div>
                                                        <div class="alert alert-info border-0 mt-2 py-2 px-3 small">
                                                            <i class="fas fa-lightbulb me-1"></i>
                                                            Giá niêm yết tối đa = <strong><fmt:formatNumber value="${maxListingPriceRate * 100}" type="number" maxFractionDigits="0" />%</strong> số tiền ký quỹ
                                                        </div>
                                                        <div id="depositAmountError" class="invalid-feedback">
                                                            Số tiền không hợp lệ
                                                        </div>
                                                    </div>

                                                    <!-- Display Max Listing Price as Input Field -->
                                                    <div class="col-md-6" id="maxListingPriceContainer">
                                                        <label class="form-label fw-semibold" for="maxListingPrice">
                                                            <i class="fas fa-tag text-success me-1"></i> Giá niêm yết tối đa
                                                        </label>
                                                        <div class="input-group input-group-lg">
                                                            <span class="input-group-text bg-success text-white">
                                                                <i class="fas fa-money-bill-wave"></i>
                                                            </span>
                                                            <input type="text" class="form-control text-end fw-bold text-success"
                                                                id="maxListingPrice" readonly
                                                                style="background-color: #d1e7dd; cursor: not-allowed;"
                                                                placeholder="0">
                                                            <span class="input-group-text bg-success text-white">VNĐ</span>
                                                        </div>
                                                        <small class="text-muted d-block mt-2">
                                                            <i class="fas fa-info-circle me-1"></i>
                                                            Giá trị này được tính tự động dựa trên số tiền ký quỹ
                                                        </small>
                                                    </div>
                                                </div>
                                            </div>

                                            <!-- Fee Model Selection Section -->
                                            <div class="mb-4">
                                                <h5 class="border-bottom pb-2 mb-3">
                                                    <i class="fas fa-hand-pointer text-primary me-2"></i> Chọn mô hình phí
                                                </h5>
                                                
                                                <!-- Option 1: Percentage Fee -->
                                                <div class="card mb-3 border-2 hover-shadow" style="cursor: pointer; transition: all 0.3s;" onclick="document.getElementById('feeModelPercentage').click();">
                                                    <div class="card-body p-4">
                                                        <div class="form-check">
                                                            <input class="form-check-input" type="radio" name="feeModel"
                                                                id="feeModelPercentage" value="PERCENTAGE" <c:if
                                                                test="${empty feeModel || feeModel == 'PERCENTAGE'}">checked</c:if>>
                                                            <label class="form-check-label w-100" for="feeModelPercentage" style="cursor: pointer;">
                                                                <div class="d-flex align-items-start mb-3">
                                                                    <div class="me-3">
                                                                        <div class="rounded-circle bg-primary text-white d-flex align-items-center justify-content-center" style="width: 48px; height: 48px;">
                                                                            <i class="fas fa-percent fa-lg"></i>
                                                                        </div>
                                                                    </div>
                                                                    <div class="flex-grow-1">
                                                                        <h5 class="mb-1">
                                                                             Tùy chọn 1: Phí theo phần trăm
                                                                            <span class="badge bg-info ms-2">Khuyến nghị</span>
                                                                        </h5>
                                                                        <p class="text-muted mb-0 small">Hệ thống sẽ áp dụng mức phí giao dịch dựa trên giá trị đơn hàng như sau:</p>
                                                                    </div>
                                                                </div>
                                                                
                                                                <ul class="list-unstyled mb-3 ms-2">
                                                                    <li class="mb-2">
                                                                        <i class="fas fa-arrow-right text-success me-2"></i>
                                                                        Đơn hàng dưới <strong>100.000 VNĐ</strong> → Phí cố định: <strong class="text-danger"><fmt:formatNumber value="${fixedFee}" type="number" pattern="#,###" /> VNĐ</strong>
                                                                    </li>
                                                                    <li class="mb-2">
                                                                        <i class="fas fa-arrow-right text-primary me-2"></i>
                                                                        Đơn hàng từ <strong>100.000 VNĐ</strong> trở lên → Phí theo tỷ lệ: <strong class="text-danger"><fmt:formatNumber value="${percentageFee}" type="number" maxFractionDigits="2" />%</strong> trên tổng giá trị đơn hàng
                                                                    </li>
                                                                </ul>

                                                                <div class="alert alert-success border-0 mb-0">
                                                                    <p class="mb-2 fw-semibold"><i class="fas fa-money-bill-wave me-2"></i>Chính sách hoàn phí ký quỹ:</p>
                                                                    <ul class="mb-2 small">
                                                                        <li>Nếu cửa hàng đóng <strong>sau ${maxRefundRateMinDuration} tháng</strong> kể từ ngày kích hoạt → hoàn <strong class="text-success"><fmt:formatNumber value="${percentageMaxRefundRate}" type="number" maxFractionDigits="0" />% phí ký quỹ</strong>.</li>
                                                                        <li>Nếu cửa hàng đóng <strong>trước ${maxRefundRateMinDuration} tháng</strong> → hoàn <strong class="text-warning"><fmt:formatNumber value="${percentageMinRefundRate}" type="number" maxFractionDigits="0" />% phí ký quỹ</strong>.</li>
                                                                    </ul>
                                                                    <p class="mb-0 small fst-italic">
                                                                        <i class="fas fa-lightbulb text-warning me-1"></i>
                                                                        💡 Chính sách này đảm bảo tính công bằng, khuyến khích hoạt động lâu dài và bảo vệ quyền lợi của cả người mua và người bán.
                                                                    </p>
                                                                </div>
                                                            </label>
                                                        </div>
                                                    </div>
                                                </div>

                                                <!-- Option 2: No Fee -->
                                                <div class="card border-2 hover-shadow" style="cursor: pointer; transition: all 0.3s;" onclick="document.getElementById('feeModelNoFee').click();">
                                                    <div class="card-body p-4">
                                                        <div class="form-check">
                                                            <input class="form-check-input" type="radio" name="feeModel"
                                                                id="feeModelNoFee" value="NO_FEE" <c:if
                                                                test="${feeModel == 'NO_FEE'}">checked</c:if>>
                                                            <label class="form-check-label w-100" for="feeModelNoFee" style="cursor: pointer;">
                                                                <div class="d-flex align-items-start mb-3">
                                                                    <div class="me-3">
                                                                        <div class="rounded-circle bg-secondary text-white d-flex align-items-center justify-content-center" style="width: 48px; height: 48px;">
                                                                            <i class="fas fa-circle fa-lg"></i>
                                                                        </div>
                                                                    </div>
                                                                    <div class="flex-grow-1">
                                                                        <h5 class="mb-1"> Tùy chọn 2: Không tính phí</h5>
                                                                    </div>
                                                                </div>
                                                                
                                                                <ul class="list-unstyled mb-3 ms-2">
                                                                    <li class="mb-2">
                                                                        <i class="fas fa-check-circle text-success me-2"></i>
                                                                        Người bán <strong>không phải trả bất kỳ khoản phí giao dịch nào</strong> cho các đơn hàng.
                                                                    </li>
                                                                    <li class="mb-2">
                                                                        <i class="fas fa-check-circle text-success me-2"></i>
                                                                        Toàn bộ doanh thu sẽ được chuyển <strong>100%</strong> vào ví hệ thống của người bán.
                                                                    </li>
                                                                </ul>

                                                                <div class="alert alert-warning border-0 mb-0">
                                                                    <p class="mb-2 fw-semibold"><i class="fas fa-exclamation-triangle me-2"></i>Chính sách hoàn phí ký quỹ:</p>
                                                                    <ul class="mb-2 small">
                                                                        <li>Đóng cửa hàng → hoàn <strong class="text-warning"><fmt:formatNumber value="${noFeeRefundRate}" type="number" maxFractionDigits="0" />% phí ký quỹ</strong> (không kể thời gian).</li>
                                                                    </ul>
                                                                    <p class="mb-0 small fst-italic">
                                                                        <i class="fas fa-lightbulb text-warning me-1"></i>
                                                                        💡 Phù hợp với các cửa hàng nhỏ, thử nghiệm hoặc hoạt động ngắn hạn, ưu tiên đơn giản và không phát sinh phí giao dịch.
                                                                    </p>
                                                                </div>
                                                            </label>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>

                                            <!-- Submit Button -->
                                            <div class="border-top pt-4 mt-4">
                                                <div class="d-grid">
                                                    <button type="submit" class="btn btn-primary btn-lg" id="submitBtn">
                                                        <i class="fas fa-check-circle me-2"></i> Đăng ký Cửa hàng
                                                    </button>
                                                </div>
                                                <p class="text-center text-muted mt-3 mb-0 small">
                                                    <i class="fas fa-info-circle me-1"></i>
                                                    Bằng cách đăng ký, bạn đồng ý với điều khoản và chính sách của chúng tôi
                                                </p>
                                            </div>
                                        </form>
                                    </div>
                                </div>
                            </c:if>
                        </div>
                    </div>
                </div>

                    <!-- Include Footer -->
                    <jsp:include page="../common/footer.jsp" />

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

                        // Auto-hide alerts after 5 seconds (except policy alerts in contract and fee model sections)
                        document.addEventListener('DOMContentLoaded', function () {
                            // Only hide error/danger alerts, not policy information alerts
                            var alerts = document.querySelectorAll('.alert-danger');
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

                    <!-- Custom Scripts -->
                    <script>
                        $(document).ready(function () {
                            console.log('=== Seller Registration Script Loaded ===');

                            const $storeName = $('#storeName');
                            const $depositAmount = $('#depositAmount');

                            console.log('Deposit Amount Input Found:', $depositAmount.length > 0);
                            console.log('Max Listing Price Display Found:', $('#maxListingPriceContainer').length > 0);
                            console.log('Max Listing Price Input Found:', $('#maxListingPrice').length > 0);

                            // Get user balance from server
                            const userBalance = parseFloat('${userBalance}') || 0;
                            console.log('User Balance:', userBalance);

                            // Test function - có thể gọi từ console: testMaxPrice()
                            window.testMaxPrice = function () {
                                console.log('=== Testing Max Price Display ===');
                                $('#depositAmount').val('10000000');
                                $('#depositAmount').trigger('input');
                            };

                            // Hàm format số thành tiền VNĐ
                            function formatCurrency(number) {
                                return new Intl.NumberFormat('vi-VN').format(number);
                            }

                            // Hàm chuyển chuỗi tiền thành số
                            function parseCurrency(string) {
                                if (!string) return 0;
                                return parseInt(string.replace(/\D/g, ''));
                            }

                            // Get settings from model
                            const minDepositAmount = parseFloat('${minDepositAmount}') || 5000000;
                            const maxListingPriceRate = parseFloat('${maxListingPriceRate}') || 0.1;

                            console.log('Min Deposit Amount:', minDepositAmount);
                            console.log('Max Listing Price Rate:', maxListingPriceRate);

                            // Function to update max listing price display
                            function updateMaxListingPrice(depositAmount) {
                                console.log('=== updateMaxListingPrice called ===');
                                console.log('Deposit Amount:', depositAmount);
                                console.log('Max Listing Price Rate:', maxListingPriceRate);

                                // Ensure numeric
                                const amt = Number(depositAmount) || 0;
                                const maxListingPrice = amt * maxListingPriceRate;
                                console.log('Calculated Max listing price:', maxListingPrice);

                                const formattedPrice = formatCurrency(maxListingPrice);
                                console.log('Formatted price:', formattedPrice);

                                // Update input field value
                                $('#maxListingPrice').val(formattedPrice);
                                // Always show container
                                $('#maxListingPriceContainer').show();
                            }
                            // Validate và hiển thị max listing price khi nhập
                            let isUpdating = false;

                            // Sử dụng cả input và keyup để đảm bảo cập nhật
                            $depositAmount.on('input keyup', function (e) {
                                if (isUpdating) return;

                                let inputVal = $(this).val();
                                console.log('Input value:', inputVal);
                                let value = parseCurrency(inputVal);
                                console.log('Parsed value:', value);

                                // Update max listing price ngay khi có giá trị hợp lệ
                                if (!isNaN(value) && value > 0) {
                                    console.log('Calling updateMaxListingPrice with:', value);
                                    updateMaxListingPrice(value);
                                } else {
                                    console.log('Hiding max listing price display');
                                    $('#maxListingPriceContainer').hide();
                                    $('#maxListingPrice').val('');
                                }
                            });

                            // Format số khi blur
                            $depositAmount.on('blur', function () {
                                isUpdating = true;
                                let value = parseCurrency($(this).val());
                                console.log('Blur - Parsed value:', value);

                                if (value > 0) {
                                    // Cập nhật giá trị và hiển thị
                                    $(this).val(formatCurrency(value));
                                    $(this).removeClass('is-invalid');
                                    // Update max listing price
                                    updateMaxListingPrice(value);
                                    $('#depositAmountError').text('');
                                } else {
                                    // Chỉ ẩn display, không hiển thị error
                                    $('#maxListingPriceContainer').hide();
                                    $('#maxListingPrice').val('');
                                }

                                isUpdating = false;
                            });

                            // Form validation
                            $('#sellerRegistrationForm').on('submit', function (e) {
                                const $form = $(this);
                                const depositAmount = parseCurrency($depositAmount.val());
                                const storeName = $storeName.val().trim();

                                // Kiểm tra tên cửa hàng không được rỗng
                                if (!storeName || storeName.length < 3) {
                                    e.preventDefault();
                                    iziToast.error({
                                        title: 'Lỗi Validation',
                                        message: 'Tên cửa hàng phải có ít nhất 3 ký tự',
                                        position: 'topRight',
                                        timeout: 4000
                                    });
                                    return false;
                                }

                                // Gửi giá trị số (không có dấu phân cách) lên server
                                $form.find('input[name="depositAmount"]').val(depositAmount);
                                return true;
                            });
                        });
                    </script>

                        <!-- iziToast (for server-side error notifications) -->
                        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/izitoast@1.4.0/dist/css/iziToast.min.css">
                        <script src="https://cdn.jsdelivr.net/npm/izitoast@1.4.0/dist/js/iziToast.min.js"></script>

                        <script>
                            // Show server-side messages as iziToast when present
                            (function () {
                                try {
                                    // Show error message from registration form
                                    const serverErrorEl = document.getElementById('serverError');
                                    if (serverErrorEl) {
                                        const message = serverErrorEl.getAttribute('data-error');
                                        if (message && message.trim().length > 0) {
                                            const lower = message.toLowerCase();
                                            // If insufficient balance, show action to deposit
                                            if (lower.includes('số dư không đủ') || lower.includes('số dư')) {
                                                iziToast.error({
                                                    title: 'Lỗi',
                                                    message: message,
                                                    position: 'topRight',
                                                    timeout: 10000,
                                                    buttons: [
                                                        ['<button>Nạp tiền</button>', function (instance, toast) {
                                                            window.location.href = '${pageContext.request.contextPath}/wallet/deposit';
                                                        }],
                                                        ['<button>Đóng</button>', function (instance, toast) {
                                                            instance.hide({ transitionOut: 'fadeOut' }, toast, 'button');
                                                        }]
                                                    ]
                                                });
                                            } else {
                                                iziToast.error({
                                                    title: 'Lỗi',
                                                    message: message,
                                                    position: 'topRight',
                                                    timeout: 8000
                                                });
                                            }
                                        }
                                    }
                                    
                                    // Show success message from registration form
                                    const serverSuccessEl = document.getElementById('serverSuccess');
                                    if (serverSuccessEl) {
                                        const message = serverSuccessEl.getAttribute('data-success');
                                        if (message && message.trim().length > 0) {
                                            iziToast.success({
                                                title: 'Thành công',
                                                message: message,
                                                position: 'topRight',
                                                timeout: 5000
                                            });
                                        }
                                    }
                                    
                                    // Show error message from edit store (update pending store)
                                    const editStoreErrorEl = document.getElementById('editStoreError');
                                    if (editStoreErrorEl) {
                                        const message = editStoreErrorEl.getAttribute('data-error');
                                        if (message && message.trim().length > 0) {
                                            iziToast.error({
                                                title: 'Cập nhật thất bại',
                                                message: message,
                                                position: 'topRight',
                                                timeout: 8000,
                                                icon: 'fas fa-exclamation-circle'
                                            });
                                        }
                                    }
                                    
                                    // Show success message from edit store (update pending store)
                                    const editStoreSuccessEl = document.getElementById('editStoreSuccess');
                                    if (editStoreSuccessEl) {
                                        const message = editStoreSuccessEl.getAttribute('data-success');
                                        if (message && message.trim().length > 0) {
                                            iziToast.success({
                                                title: 'Cập nhật thành công',
                                                message: message,
                                                position: 'topRight',
                                                timeout: 6000,
                                                icon: 'fas fa-check-circle',
                                                progressBar: true,
                                                progressBarColor: 'rgb(0, 255, 184)',
                                                onOpening: function() {
                                                    console.log('Success toast shown');
                                                }
                                            });
                                        }
                                    }
                                } catch (e) {
                                    console.error('iziToast show failed', e);
                                }
                            })();

                            // Function to open edit modal
                            function openEditModal() {
                                $('#editStoreModal').modal('show');
                                initEditFormValidation();
                            }
                            
                            // Auto-open modal if coming from register-success page
                            $(document).ready(function() {
                                // Check if we should auto-open the edit modal
                                const shouldOpenModal = sessionStorage.getItem('openEditModal');
                                if (shouldOpenModal === 'true') {
                                    console.log('Auto-opening edit modal from sessionStorage flag');
                                    // Clear the flag
                                    sessionStorage.removeItem('openEditModal');
                                    // Open modal after a short delay to ensure page is fully loaded
                                    setTimeout(function() {
                                        openEditModal();
                                    }, 500);
                                }
                            });

                            // Initialize edit form validation
                            function initEditFormValidation() {
                                const $editStoreName = $('#editStoreName');
                                const $editDepositAmount = $('#editDepositAmount');
                                const originalName = $editStoreName.data('original-name');
                                
                                const minDepositAmount = parseFloat('${minDepositAmount}') || 5000000;
                                const maxListingPriceRate = parseFloat('${maxListingPriceRate}') || 0.1;
                                
                                let isEditUpdating = false;
                                
                                // Format currency helper
                                function formatCurrency(number) {
                                    return new Intl.NumberFormat('vi-VN').format(number);
                                }
                                
                                // Parse currency helper
                                function parseCurrency(string) {
                                    if (!string) return 0;
                                    return parseInt(string.replace(/\D/g, ''));
                                }
                                
                                // Update max listing price
                                function updateEditMaxListingPrice(depositAmount) {
                                    const amt = Number(depositAmount) || 0;
                                    const maxListingPrice = amt * maxListingPriceRate;
                                    const formattedPrice = formatCurrency(maxListingPrice);
                                    
                                    $('#editMaxListingPrice').val(formattedPrice);
                                    $('#editMaxListingPriceContainer').show();
                                }
                                
                                // Deposit amount input handling
                                $editDepositAmount.off('input keyup').on('input keyup', function (e) {
                                    if (isEditUpdating) return;
                                    
                                    let inputVal = $(this).val();
                                    let value = parseCurrency(inputVal);
                                    
                                    if (!isNaN(value) && value > 0) {
                                        updateEditMaxListingPrice(value);
                                    } else {
                                        $('#editMaxListingPriceContainer').hide();
                                        $('#editMaxListingPrice').val('');
                                    }
                                });
                                
                                // Format on blur
                                $editDepositAmount.off('blur').on('blur', function () {
                                    isEditUpdating = true;
                                    let value = parseCurrency($(this).val());
                                    
                                    if (value > 0) {
                                        $(this).val(formatCurrency(value));
                                        $(this).removeClass('is-invalid');
                                        updateEditMaxListingPrice(value);
                                        $('#editDepositAmountError').text('');
                                        
                                        // Check minimum deposit
                                        if (value < minDepositAmount) {
                                            $(this).addClass('is-invalid');
                                            const errorMsg = 'Số tiền ký quỹ tối thiểu là ' + formatCurrency(minDepositAmount) + ' VNĐ';
                                            $('#editDepositAmountError').text(errorMsg);
                                            
                                            iziToast.warning({
                                                title: 'Số tiền không đủ',
                                                message: errorMsg,
                                                position: 'topRight',
                                                timeout: 5000
                                            });
                                        }
                                    } else {
                                        $('#editMaxListingPriceContainer').hide();
                                        $('#editMaxListingPrice').val('');
                                    }
                                    
                                    isEditUpdating = false;
                                });
                                
                                // Initialize max listing price display
                                const currentDeposit = parseCurrency($editDepositAmount.val());
                                if (currentDeposit > 0) {
                                    updateEditMaxListingPrice(currentDeposit);
                                }
                                
                                // Form validation on submit
                                $('#editStoreForm').off('submit').on('submit', function (e) {
                                    e.preventDefault(); // Always prevent default first
                                    
                                    const $form = $(this);
                                    const depositAmount = parseCurrency($editDepositAmount.val());
                                    const currentName = $editStoreName.val().trim();
                                    
                                    console.log('Form submit - Name:', currentName, 'Deposit:', depositAmount);
                                    
                                    // Validate store name
                                    if (!currentName || currentName.length < 3) {
                                        $editStoreName.addClass('is-invalid');
                                        
                                        iziToast.error({
                                            title: 'Lỗi Validation',
                                            message: 'Tên cửa hàng phải có ít nhất 3 ký tự',
                                            position: 'topRight',
                                            timeout: 4000
                                        });
                                        return false;
                                    }
                                    
                                    // Validate deposit amount
                                    if (!depositAmount || depositAmount <= 0) {
                                        $editDepositAmount.addClass('is-invalid');
                                        $('#editDepositAmountError').text('Vui lòng nhập số tiền ký quỹ hợp lệ');
                                        $editDepositAmount.focus();
                                        
                                        iziToast.error({
                                            title: 'Lỗi Validation',
                                            message: 'Vui lòng nhập số tiền ký quỹ hợp lệ',
                                            position: 'topRight',
                                            timeout: 4000
                                        });
                                        return false;
                                    }
                                    
                                    // Validate minimum deposit
                                    if (depositAmount < minDepositAmount) {
                                        $editDepositAmount.addClass('is-invalid');
                                        const errorMsg = 'Số tiền ký quỹ tối thiểu là ' + formatCurrency(minDepositAmount) + ' VNĐ';
                                        $('#editDepositAmountError').text(errorMsg);
                                        $editDepositAmount.focus();
                                        
                                        iziToast.warning({
                                            title: 'Số tiền không đủ',
                                            message: errorMsg,
                                            position: 'topRight',
                                            timeout: 6000
                                        });
                                        return false;
                                    }
                                    
                                    // Create a hidden input for the raw deposit value
                                    $form.find('input[name="depositAmount"]').remove();
                                    $('<input>').attr({
                                        type: 'hidden',
                                        name: 'depositAmount',
                                        value: depositAmount
                                    }).appendTo($form);
                                    
                                    console.log('Form data before submit:');
                                    console.log('- storeName:', $form.find('input[name="storeName"]').val());
                                    console.log('- storeDescription:', $form.find('textarea[name="storeDescription"]').val());
                                    console.log('- depositAmount:', $form.find('input[name="depositAmount"]').val());
                                    console.log('- feeModel:', $form.find('input[name="feeModel"]:checked').val());
                                    
                                    // Disable submit button
                                    $('#editSubmitBtn').prop('disabled', true).html('<i class="fas fa-spinner fa-spin me-2"></i> Đang lưu...');
                                    
                                    // Submit form using native submit (not jQuery)
                                    $form[0].submit();
                                    
                                    return false;
                                });
                            }
                        </script>

                        <!-- Edit Store Modal -->
                        <c:if test="${not empty inactiveStore}">
                        <div class="modal fade" id="editStoreModal" tabindex="-1" aria-labelledby="editStoreModalLabel" aria-hidden="true" data-bs-backdrop="static">
                            <div class="modal-dialog modal-xl modal-dialog-scrollable">
                                <div class="modal-content">
                                    <div class="modal-header bg-primary text-white">
                                        <h5 class="modal-title" id="editStoreModalLabel">
                                            <i class="fas fa-edit me-2"></i>Chỉnh sửa thông tin cửa hàng
                                        </h5>
                                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                                    </div>
                                    <div class="modal-body">
                                        <form action="${pageContext.request.contextPath}/seller/update-pending-store/${inactiveStore.id}" method="POST" id="editStoreForm">
                                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                            
                                            <!-- Store Information Section -->
                                            <div class="mb-4">
                                                <h5 class="border-bottom pb-2 mb-3">
                                                    <i class="fas fa-store text-primary me-2"></i> Thông tin cửa hàng
                                                </h5>
                                                <div class="mb-3">
                                                    <label class="form-label fw-semibold" for="editStoreName">
                                                        Tên cửa hàng <span class="text-danger">*</span>
                                                    </label>
                                                    <div class="input-group">
                                                        <span class="input-group-text bg-light"><i class="fas fa-store"></i></span>
                                                        <input type="text" class="form-control" id="editStoreName"
                                                            name="storeName" required minlength="3" maxlength="100"
                                                            value="${inactiveStore.storeName}"
                                                            data-store-check-url="${pageContext.request.contextPath}/seller/check-store-name"
                                                            data-original-name="${inactiveStore.storeName}"
                                                            placeholder="Nhập tên cửa hàng của bạn">
                                                    </div>
                                                    <small class="text-muted d-block mt-1"><i class="fas fa-info-circle me-1"></i>Tên cửa hàng phải là duy nhất</small>
                                                    <div id="editStoreNameFeedback" class="invalid-feedback"></div>
                                                </div>
                                                <div class="mb-3">
                                                    <label class="form-label fw-semibold" for="editStoreDescription">Mô tả cửa hàng</label>
                                                    <textarea class="form-control" id="editStoreDescription"
                                                        name="storeDescription" rows="4"
                                                        maxlength="500"
                                                        placeholder="Giới thiệu ngắn gọn về cửa hàng của bạn...">${inactiveStore.description}</textarea>
                                                    <small class="text-muted d-block mt-1"><i class="fas fa-info-circle me-1"></i>Tối đa 500 ký tự</small>
                                                </div>
                                            </div>

                                            <!-- Deposit Information Section -->
                                            <div class="mb-4">
                                                <h5 class="border-bottom pb-2 mb-3">
                                                    <i class="fas fa-money-check-alt text-success me-2"></i> Thông tin ký quỹ
                                                </h5>
                                                <div class="row g-3">
                                                    <div class="col-md-6">
                                                        <label class="form-label fw-semibold" for="editDepositAmount">
                                                            Số tiền ký quỹ <span class="text-danger">*</span>
                                                        </label>
                                                        <div class="input-group input-group-lg">
                                                            <span class="input-group-text bg-light"><i class="fas fa-money-bill-wave"></i></span>
                                                            <input type="text" class="form-control text-end"
                                                                id="editDepositAmount" name="depositAmountDisplay" required
                                                                value="<fmt:formatNumber value="${inactiveStore.depositAmount}" type="number" pattern="#,###"/>"
                                                                placeholder="0">
                                                            <span class="input-group-text bg-light">VNĐ</span>
                                                        </div>
                                                        <div id="editDepositAmountHelp" class="form-text">
                                                            <i class="fas fa-info-circle text-primary me-1"></i>
                                                            Tối thiểu: <strong><fmt:formatNumber value="${minDepositAmount}" type="number" pattern="#,###" /> VNĐ</strong>
                                                        </div>
                                                        <div class="alert alert-info border-0 mt-2 py-2 px-3 small">
                                                            <i class="fas fa-lightbulb me-1"></i>
                                                            Giá niêm yết tối đa = <strong><fmt:formatNumber value="${maxListingPriceRate * 100}" type="number" maxFractionDigits="0" />%</strong> số tiền ký quỹ
                                                        </div>
                                                        <div id="editDepositAmountError" class="invalid-feedback"></div>
                                                    </div>

                                                    <div class="col-md-6" id="editMaxListingPriceContainer">
                                                        <label class="form-label fw-semibold" for="editMaxListingPrice">
                                                            <i class="fas fa-tag text-success me-1"></i> Giá niêm yết tối đa
                                                        </label>
                                                        <div class="input-group input-group-lg">
                                                            <span class="input-group-text bg-success text-white">
                                                                <i class="fas fa-money-bill-wave"></i>
                                                            </span>
                                                            <input type="text" class="form-control text-end fw-bold text-success"
                                                                id="editMaxListingPrice" readonly
                                                                style="background-color: #d1e7dd; cursor: not-allowed;"
                                                                placeholder="0">
                                                            <span class="input-group-text bg-success text-white">VNĐ</span>
                                                        </div>
                                                        <small class="text-muted d-block mt-2">
                                                            <i class="fas fa-info-circle me-1"></i>
                                                            Giá trị này được tính tự động dựa trên số tiền ký quỹ
                                                        </small>
                                                    </div>
                                                </div>
                                            </div>

                                            <!-- Fee Model Selection Section -->
                                            <div class="mb-4">
                                                <h5 class="border-bottom pb-2 mb-3">
                                                    <i class="fas fa-hand-pointer text-primary me-2"></i> Chọn mô hình phí
                                                </h5>
                                                
                                                <!-- Option 1: Percentage Fee -->
                                                <div class="card mb-3 border-2" style="cursor: pointer; transition: all 0.3s;" onclick="document.getElementById('editFeeModelPercentage').click();">
                                                    <div class="card-body p-4">
                                                        <div class="form-check">
                                                            <input class="form-check-input" type="radio" name="feeModel"
                                                                id="editFeeModelPercentage" value="PERCENTAGE" 
                                                                ${inactiveStore.feeModel == 'PERCENTAGE' ? 'checked' : ''}>
                                                            <label class="form-check-label w-100" for="editFeeModelPercentage" style="cursor: pointer;">
                                                                <div class="d-flex align-items-start mb-3">
                                                                    <div class="me-3">
                                                                        <div class="rounded-circle bg-primary text-white d-flex align-items-center justify-content-center" style="width: 48px; height: 48px;">
                                                                            <i class="fas fa-percent fa-lg"></i>
                                                                        </div>
                                                                    </div>
                                                                    <div class="flex-grow-1">
                                                                        <h5 class="mb-1">
                                                                             Tùy chọn 1: Phí theo phần trăm
                                                                            <span class="badge bg-info ms-2">Khuyến nghị</span>
                                                                        </h5>
                                                                        <p class="text-muted mb-0 small">Hệ thống sẽ áp dụng mức phí giao dịch dựa trên giá trị đơn hàng</p>
                                                                    </div>
                                                                </div>
                                                                
                                                                <ul class="list-unstyled mb-3 ms-2">
                                                                    <li class="mb-2">
                                                                        <i class="fas fa-arrow-right text-success me-2"></i>
                                                                        Đơn hàng dưới <strong>100.000 VNĐ</strong> → Phí cố định: <strong class="text-danger"><fmt:formatNumber value="${fixedFee}" type="number" pattern="#,###" /> VNĐ</strong>
                                                                    </li>
                                                                    <li class="mb-2">
                                                                        <i class="fas fa-arrow-right text-primary me-2"></i>
                                                                        Đơn hàng từ <strong>100.000 VNĐ</strong> trở lên → Phí: <strong class="text-danger"><fmt:formatNumber value="${percentageFee}" type="number" maxFractionDigits="2" />%</strong>
                                                                    </li>
                                                                </ul>

                                                                <div class="alert alert-success border-0 mb-0 small">
                                                                    <p class="mb-1 fw-semibold"><i class="fas fa-money-bill-wave me-2"></i>Chính sách hoàn phí ký quỹ:</p>
                                                                    <ul class="mb-0">
                                                                        <li>Sau ${maxRefundRateMinDuration} tháng → hoàn <fmt:formatNumber value="${percentageMaxRefundRate}" type="number" maxFractionDigits="0" />%</li>
                                                                        <li>Trước ${maxRefundRateMinDuration} tháng → hoàn <fmt:formatNumber value="${percentageMinRefundRate}" type="number" maxFractionDigits="0" />%</li>
                                                                    </ul>
                                                                </div>
                                                            </label>
                                                        </div>
                                                    </div>
                                                </div>

                                                <!-- Option 2: No Fee -->
                                                <div class="card border-2" style="cursor: pointer; transition: all 0.3s;" onclick="document.getElementById('editFeeModelNoFee').click();">
                                                    <div class="card-body p-4">
                                                        <div class="form-check">
                                                            <input class="form-check-input" type="radio" name="feeModel"
                                                                id="editFeeModelNoFee" value="NO_FEE" 
                                                                ${inactiveStore.feeModel == 'NO_FEE' ? 'checked' : ''}>
                                                            <label class="form-check-label w-100" for="editFeeModelNoFee" style="cursor: pointer;">
                                                                <div class="d-flex align-items-start mb-3">
                                                                    <div class="me-3">
                                                                        <div class="rounded-circle bg-secondary text-white d-flex align-items-center justify-content-center" style="width: 48px; height: 48px;">
                                                                            <i class="fas fa-circle fa-lg"></i>
                                                                        </div>
                                                                    </div>
                                                                    <div class="flex-grow-1">
                                                                        <h5 class="mb-1"> Tùy chọn 2: Không tính phí</h5>
                                                                    </div>
                                                                </div>
                                                                
                                                                <ul class="list-unstyled mb-3 ms-2">
                                                                    <li class="mb-2">
                                                                        <i class="fas fa-check-circle text-success me-2"></i>
                                                                        Không phải trả phí giao dịch
                                                                    </li>
                                                                    <li class="mb-2">
                                                                        <i class="fas fa-check-circle text-success me-2"></i>
                                                                        Nhận 100% doanh thu
                                                                    </li>
                                                                </ul>

                                                                <div class="alert alert-warning border-0 mb-0 small">
                                                                    <p class="mb-1 fw-semibold"><i class="fas fa-exclamation-triangle me-2"></i>Chính sách hoàn phí:</p>
                                                                    <p class="mb-0">Đóng cửa hàng → hoàn <fmt:formatNumber value="${noFeeRefundRate}" type="number" maxFractionDigits="0" />%</p>
                                                                </div>
                                                            </label>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </form>
                                    </div>
                                    <div class="modal-footer">
                                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                                            <i class="fas fa-times me-2"></i> Hủy
                                        </button>
                                        <button type="button" class="btn btn-primary" id="editSubmitBtn" onclick="$('#editStoreForm').submit()">
                                            <i class="fas fa-save me-2"></i> Lưu thay đổi
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>
                        </c:if>
                </body>

                </html>