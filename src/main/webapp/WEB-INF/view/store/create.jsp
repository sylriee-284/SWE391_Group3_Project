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

        /* Page Header */
        .page-header {
            background: linear-gradient(135deg, #2c3e50, #3498db);
            color: white;
            padding: 2rem;
            margin-bottom: 2rem;
            border-radius: 10px;
        }

        /* Info Cards */
        .info-card {
            background: white;
            border-radius: 10px;
            padding: 1.5rem;
            margin-bottom: 1.5rem;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }

        .info-card.warning {
            background: #fff3cd;
            border-left: 4px solid #ffc107;
        }

        .info-card.success {
            background: #d1ecf1;
            border-left: 4px solid #0dcaf0;
        }

        /* Table Form */
        .form-table {
            width: 100%;
            background: white;
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            margin-bottom: 2rem;
        }

        .form-table table {
            width: 100%;
            border-collapse: collapse;
        }

        .form-table th {
            background: #f8f9fa;
            padding: 15px 20px;
            text-align: left;
            font-weight: 600;
            color: #2c3e50;
            border-bottom: 2px solid #dee2e6;
            width: 30%;
        }

        .form-table td {
            padding: 15px 20px;
            border-bottom: 1px solid #dee2e6;
        }

        .form-table tr:last-child td {
            border-bottom: none;
        }

        .form-table th i {
            margin-right: 8px;
            color: #3498db;
        }

        .form-table .required {
            color: #dc3545;
            margin-left: 3px;
        }

        .form-control, .form-select {
            border-radius: 6px;
        }

        .help-text {
            font-size: 0.875rem;
            color: #6c757d;
            margin-top: 5px;
        }

        .section-header {
            background: #e9ecef;
            padding: 12px 20px;
            font-weight: 600;
            color: #2c3e50;
            border-bottom: 2px solid #dee2e6;
        }

        .section-header i {
            margin-right: 10px;
            color: #3498db;
        }

        /* Button styles */
        .btn-submit {
            background: linear-gradient(135deg, #3498db, #2980b9);
            border: none;
            padding: 12px 40px;
            font-size: 16px;
            border-radius: 8px;
            color: white;
            font-weight: 600;
        }

        .btn-submit:hover {
            background: linear-gradient(135deg, #2980b9, #21618c);
            color: white;
        }

        .btn-cancel {
            padding: 12px 40px;
            font-size: 16px;
            border-radius: 8px;
        }

        /* Validation styles */
        .is-invalid {
            border-color: #dc3545;
        }

        .is-valid {
            border-color: #28a745;
        }

        .invalid-feedback, .text-danger {
            color: #dc3545;
            font-size: 0.875rem;
            margin-top: 5px;
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
            <!-- Page Header -->
            <div class="page-header">
                <h1 class="mb-2">
                    <i class="fas fa-store"></i>
                    Tạo Cửa hàng Mới
                </h1>
                <p class="mb-0">Điền thông tin để bắt đầu kinh doanh trên TaphoaMMO</p>
            </div>


            <!-- Create Store Form -->
            <form:form method="post" action="/stores/create" modelAttribute="createRequest">

                <!-- Basic Information Table -->
                <div class="form-table">
                    <table>
                        <thead>
                            <tr>
                                <th colspan="2" class="section-header">
                                    <i class="fas fa-info-circle"></i>
                                    Thông tin cơ bản
                                </th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <th>
                                    <i class="fas fa-store"></i>
                                    Tên cửa hàng<span class="required">*</span>
                                </th>
                                <td>
                                    <form:input path="storeName" class="form-control" id="storeName"
                                               placeholder="Nhập tên cửa hàng" required="true"/>
                                    <form:errors path="storeName" cssClass="text-danger"/>
                                    <div class="help-text">Tên cửa hàng phải duy nhất và dễ nhớ</div>
                                </td>
                            </tr>
                            <tr>
                                <th>
                                    <i class="fas fa-align-left"></i>
                                    Mô tả cửa hàng
                                </th>
                                <td>
                                    <form:textarea path="storeDescription" class="form-control"
                                                  id="storeDescription" rows="4"
                                                  placeholder="Mô tả về cửa hàng, sản phẩm và dịch vụ của bạn"/>
                                    <form:errors path="storeDescription" cssClass="text-danger"/>
                                    <div class="help-text">Mô tả chi tiết giúp khách hàng hiểu rõ hơn về cửa hàng</div>
                                </td>
                            </tr>
                            <tr>
                                <th>
                                    <i class="fas fa-envelope"></i>
                                    Email liên hệ
                                </th>
                                <td>
                                    <form:input path="contactEmail" type="email" class="form-control"
                                               id="contactEmail" placeholder="email@example.com"/>
                                    <form:errors path="contactEmail" cssClass="text-danger"/>
                                </td>
                            </tr>
                            <tr>
                                <th>
                                    <i class="fas fa-phone"></i>
                                    Số điện thoại
                                </th>
                                <td>
                                    <form:input path="contactPhone" class="form-control" id="contactPhone"
                                               placeholder="+84xxxxxxxxx"/>
                                    <form:errors path="contactPhone" cssClass="text-danger"/>
                                </td>
                            </tr>
                            <tr>
                                <th>
                                    <i class="fas fa-certificate"></i>
                                    Giấy phép kinh doanh
                                </th>
                                <td>
                                    <form:input path="businessLicense" class="form-control"
                                               id="businessLicense" placeholder="Số giấy phép (nếu có)"/>
                                    <form:errors path="businessLicense" cssClass="text-danger"/>
                                    <div class="help-text">Không bắt buộc nhưng giúp tăng độ tin cậy</div>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>


                <!-- Terms and Conditions Table -->
                <div class="form-table">
                    <table>
                        <thead>
                            <tr>
                                <th colspan="2" class="section-header">
                                    <i class="fas fa-file-contract"></i>
                                    Điều khoản và Điều kiện
                                </th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td colspan="2">
                                    <div class="form-check">
                                        <form:checkbox path="agreeToTerms" class="form-check-input"
                                                      id="agreeToTerms" required="true"/>
                                        <label class="form-check-label" for="agreeToTerms">
                                            Tôi đồng ý với
                                            <a href="/terms" target="_blank">Điều khoản sử dụng</a> và
                                            <a href="/privacy" target="_blank">Chính sách bảo mật</a> của TaphoaMMO
                                            <span class="required">*</span>
                                        </label>
                                        <form:errors path="agreeToTerms" cssClass="text-danger d-block"/>
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="2">
                                    <div class="alert alert-warning mb-0">
                                        <h6><i class="fas fa-exclamation-triangle"></i> Cam kết của Seller:</h6>
                                        <ul class="mb-0">
                                            <li>Cung cấp sản phẩm chất lượng và đúng mô tả</li>
                                            <li>Giao hàng đúng thời gian cam kết</li>
                                            <li>Hỗ trợ khách hàng một cách tận tình</li>
                                            <li>Tuân thủ các quy định của nền tảng</li>
                                        </ul>
                                    </div>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>

                <!-- Submit Buttons -->
                <div class="text-center mt-4">
                    <button type="submit" class="btn btn-submit" id="submitBtn">
                        <i class="fas fa-store"></i>
                        Tạo Cửa hàng
                    </button>
                    <a href="/stores" class="btn btn-outline-secondary btn-cancel ms-3">
                        <i class="fas fa-times"></i>
                        Hủy bỏ
                    </a>
                </div>
            </form:form>
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
