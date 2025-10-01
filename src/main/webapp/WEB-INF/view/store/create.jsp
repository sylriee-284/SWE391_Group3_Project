<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tạo Cửa hàng - TaphoaMMO</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        :root {
            --primary-color: #2c3e50;
            --secondary-color: #34495e;
            --accent-color: #3498db;
            --light-bg: #ecf0f1;
            --sidebar-width: 250px;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: var(--light-bg);
            margin: 0;
            padding: 0;
        }

        /* Layout Container */
        .layout-container {
            display: flex;
        }

        /* Main Content */
        .main-content {
            flex: 1;
            padding: 30px;
            min-height: 100vh;
            overflow-x: auto;
            background-color: #f8f9fa;
        }

        .form-container {
            max-width: 800px;
            margin: 0 auto;
        }
        .deposit-info {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-radius: 15px;
            padding: 25px;
            margin-bottom: 30px;
        }
        .wallet-balance {
            background: #f8f9fa;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 20px;
        }
        .max-price-display {
            background: #e8f5e8;
            border: 2px solid #28a745;
            border-radius: 10px;
            padding: 15px;
            margin-top: 10px;
        }
        .form-section {
            background: white;
            border-radius: 15px;
            padding: 30px;
            margin-bottom: 30px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.08);
        }
        .section-title {
            color: #495057;
            border-bottom: 2px solid #e9ecef;
            padding-bottom: 10px;
            margin-bottom: 25px;
        }
    </style>
</head>
<body>
    <!-- Include Navbar -->
    <%@ include file="../navbar.jsp" %>

    <!-- Layout Container -->
    <div class="layout-container">
        <!-- Include Sidebar -->
        <%@ include file="../sidebar.jsp" %>

        <!-- Main Content Area -->
        <div class="main-content">
            <div class="form-container">
            <!-- Header -->
            <div class="text-center mb-5">
                <h1 class="h2 text-primary">
                    <i class="fas fa-store"></i>
                    Tạo Cửa hàng Mới
                </h1>
                <p class="text-muted">Bắt đầu kinh doanh trên TaphoaMMO với cửa hàng của riêng bạn</p>
            </div>

            <!-- Deposit Information -->
            <div class="deposit-info">
                <div class="row align-items-center">
                    <div class="col-md-8">
                        <h4 class="mb-2">
                            <i class="fas fa-shield-alt"></i>
                            Yêu cầu Deposit
                        </h4>
                        <p class="mb-0">
                            Để đảm bảo chất lượng dịch vụ, bạn cần đặt cọc tối thiểu 
                            <strong><fmt:formatNumber value="${minimumDeposit}" pattern="#,##0"/> VND</strong>
                        </p>
                        <small class="opacity-75">
                            Giá listing tối đa = Deposit ÷ 10
                        </small>
                    </div>
                    <div class="col-md-4 text-center">
                        <div class="display-6 fw-bold">
                            <fmt:formatNumber value="${minimumDeposit}" pattern="#,##0"/>
                        </div>
                        <div>VND tối thiểu</div>
                    </div>
                </div>
            </div>

            <!-- Wallet Balance -->
            <div class="wallet-balance">
                <div class="row align-items-center">
                    <div class="col-md-8">
                        <h5 class="mb-1">
                            <i class="fas fa-wallet text-success"></i>
                            Số dư ví hiện tại
                        </h5>
                        <p class="text-muted mb-0">Đảm bảo bạn có đủ số dư để đặt cọc</p>
                    </div>
                    <div class="col-md-4 text-end">
                        <div class="h4 text-success mb-0">${formattedBalance}</div>
                        <c:if test="${walletBalance < minimumDeposit}">
                            <small class="text-danger">
                                <i class="fas fa-exclamation-triangle"></i>
                                Không đủ số dư
                            </small>
                        </c:if>
                    </div>
                </div>
            </div>

            <!-- Create Store Form -->
            <form:form method="post" action="/stores/create" modelAttribute="createRequest" class="needs-validation" novalidate="true">
                
                <!-- Basic Information -->
                <div class="form-section">
                    <h4 class="section-title">
                        <i class="fas fa-info-circle"></i>
                        Thông tin cơ bản
                    </h4>
                    
                    <div class="row">
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label for="storeName" class="form-label">
                                    Tên cửa hàng <span class="text-danger">*</span>
                                </label>
                                <form:input path="storeName" class="form-control" id="storeName" 
                                           placeholder="Nhập tên cửa hàng" required="true"/>
                                <form:errors path="storeName" class="text-danger small"/>
                                <div class="form-text">Tên cửa hàng phải duy nhất và dễ nhớ</div>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label for="contactEmail" class="form-label">Email liên hệ</label>
                                <form:input path="contactEmail" type="email" class="form-control" 
                                           id="contactEmail" placeholder="email@example.com"/>
                                <form:errors path="contactEmail" class="text-danger small"/>
                            </div>
                        </div>
                    </div>

                    <div class="mb-3">
                        <label for="storeDescription" class="form-label">Mô tả cửa hàng</label>
                        <form:textarea path="storeDescription" class="form-control" id="storeDescription" 
                                      rows="4" placeholder="Mô tả về cửa hàng, sản phẩm và dịch vụ của bạn"/>
                        <form:errors path="storeDescription" class="text-danger small"/>
                        <div class="form-text">Mô tả chi tiết giúp khách hàng hiểu rõ hơn về cửa hàng</div>
                    </div>

                    <div class="row">
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label for="contactPhone" class="form-label">Số điện thoại</label>
                                <form:input path="contactPhone" class="form-control" id="contactPhone" 
                                           placeholder="+84xxxxxxxxx"/>
                                <form:errors path="contactPhone" class="text-danger small"/>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label for="businessLicense" class="form-label">Giấy phép kinh doanh</label>
                                <form:input path="businessLicense" class="form-control" id="businessLicense" 
                                           placeholder="Số giấy phép (nếu có)"/>
                                <form:errors path="businessLicense" class="text-danger small"/>
                                <div class="form-text">Không bắt buộc nhưng giúp tăng độ tin cậy</div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Deposit Information -->
                <div class="form-section">
                    <h4 class="section-title">
                        <i class="fas fa-money-bill-wave"></i>
                        Thông tin Deposit
                    </h4>

                    <div class="row">
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label for="depositAmount" class="form-label">
                                    Số tiền deposit <span class="text-danger">*</span>
                                </label>
                                <div class="input-group">
                                    <form:input path="depositAmount" type="number" class="form-control" 
                                               id="depositAmount" min="${minimumDeposit}" 
                                               step="1000" required="true"/>
                                    <span class="input-group-text">VND</span>
                                </div>
                                <form:errors path="depositAmount" class="text-danger small"/>
                                <div class="form-text">
                                    Tối thiểu: <fmt:formatNumber value="${minimumDeposit}" pattern="#,##0"/> VND
                                </div>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label class="form-label">Giá listing tối đa</label>
                                <div class="max-price-display">
                                    <div class="h5 text-success mb-0" id="maxPriceDisplay">
                                        <fmt:formatNumber value="${minimumDeposit / 10}" pattern="#,##0"/> VND
                                    </div>
                                    <small class="text-muted">Tự động tính = Deposit ÷ 10</small>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="alert alert-info">
                        <i class="fas fa-info-circle"></i>
                        <strong>Lưu ý:</strong> Số tiền deposit sẽ được trừ từ ví của bạn và được giữ như một khoản bảo đảm. 
                        Bạn có thể rút lại khi đóng cửa hàng.
                    </div>
                </div>

                <!-- Terms and Conditions -->
                <div class="form-section">
                    <h4 class="section-title">
                        <i class="fas fa-file-contract"></i>
                        Điều khoản và Điều kiện
                    </h4>

                    <div class="form-check">
                        <form:checkbox path="agreeToTerms" class="form-check-input" id="agreeToTerms" required="true"/>
                        <label class="form-check-label" for="agreeToTerms">
                            Tôi đồng ý với 
                            <a href="/terms" target="_blank">Điều khoản sử dụng</a> và 
                            <a href="/privacy" target="_blank">Chính sách bảo mật</a> của TaphoaMMO
                            <span class="text-danger">*</span>
                        </label>
                        <form:errors path="agreeToTerms" class="text-danger small d-block"/>
                    </div>

                    <div class="mt-3">
                        <div class="alert alert-warning">
                            <h6><i class="fas fa-exclamation-triangle"></i> Cam kết của Seller:</h6>
                            <ul class="mb-0">
                                <li>Cung cấp sản phẩm chất lượng và đúng mô tả</li>
                                <li>Giao hàng đúng thời gian cam kết</li>
                                <li>Hỗ trợ khách hàng một cách tận tình</li>
                                <li>Tuân thủ các quy định của nền tảng</li>
                            </ul>
                        </div>
                    </div>
                </div>

                <!-- Submit Buttons -->
                <div class="text-center">
                    <button type="submit" class="btn btn-primary btn-lg px-5" id="submitBtn">
                        <i class="fas fa-store"></i>
                        Tạo Cửa hàng
                    </button>
                    <a href="/stores" class="btn btn-outline-secondary btn-lg px-5 ms-3">
                        <i class="fas fa-times"></i>
                        Hủy bỏ
                    </a>
                </div>
            </form:form>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Toggle Sidebar
        function toggleSidebar() {
            const sidebar = document.getElementById('sidebar');
            sidebar.classList.toggle('collapsed');
        }
    </script>
    <script>
        // Auto-calculate max listing price
        document.getElementById('depositAmount').addEventListener('input', function() {
            const depositAmount = parseFloat(this.value) || 0;
            const maxPrice = Math.floor(depositAmount / 10);
            document.getElementById('maxPriceDisplay').textContent = 
                new Intl.NumberFormat('vi-VN').format(maxPrice) + ' VND';
        });

        // Form validation
        (function() {
            'use strict';
            window.addEventListener('load', function() {
                var forms = document.getElementsByClassName('needs-validation');
                var validation = Array.prototype.filter.call(forms, function(form) {
                    form.addEventListener('submit', function(event) {
                        if (form.checkValidity() === false) {
                            event.preventDefault();
                            event.stopPropagation();
                        }
                        form.classList.add('was-validated');
                    }, false);
                });
            }, false);
        })();

        // Check wallet balance before submit
        document.getElementById('submitBtn').addEventListener('click', function(e) {
            const depositAmount = parseFloat(document.getElementById('depositAmount').value) || 0;
            const walletBalance = ${walletBalance};
            
            if (depositAmount > walletBalance) {
                e.preventDefault();
                alert('Số dư ví không đủ để đặt cọc. Vui lòng nạp thêm tiền vào ví.');
                return false;
            }
        });

        // Store name availability check
        let nameCheckTimeout;
        document.getElementById('storeName').addEventListener('input', function() {
            clearTimeout(nameCheckTimeout);
            const storeName = this.value.trim();
            
            if (storeName.length >= 3) {
                nameCheckTimeout = setTimeout(() => {
                    fetch('/stores/check-name?storeName=' + encodeURIComponent(storeName))
                        .then(response => response.json())
                        .then(available => {
                            const input = document.getElementById('storeName');
                            if (available) {
                                input.classList.remove('is-invalid');
                                input.classList.add('is-valid');
                            } else {
                                input.classList.remove('is-valid');
                                input.classList.add('is-invalid');
                                // Show error message
                                const errorDiv = input.parentNode.querySelector('.invalid-feedback') || 
                                    document.createElement('div');
                                errorDiv.className = 'invalid-feedback';
                                errorDiv.textContent = 'Tên cửa hàng đã tồn tại';
                                if (!input.parentNode.querySelector('.invalid-feedback')) {
                                    input.parentNode.appendChild(errorDiv);
                                }
                            }
                        })
                        .catch(error => {
                            console.error('Error checking store name:', error);
                        });
                }, 500);
            }
        });
    </script>
</body>
</html>
