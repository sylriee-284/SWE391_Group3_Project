<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <html>

        <head>
            <title>Verify OTP - Registration</title>
            <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css"
                rel="stylesheet">

            <!-- iziToast CSS -->
            <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/izitoast/1.4.0/css/iziToast.min.css" />

            <style>
                .divider:after,
                .divider:before {
                    content: "";
                    flex: 1;
                    height: 1px;
                    background: #eee;
                }

                .h-custom {
                    height: calc(100% - 73px);
                }

                @media (max-width: 450px) {
                    .h-custom {
                        height: 100%;
                    }
                }

                .otp-container {
                    max-width: 400px;
                    margin: 0 auto;
                    border: 2px solid #e9ecef;
                    border-radius: 15px;
                    padding: 2rem;
                    background-color: #ffffff;
                    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
                }

                .otp-input {
                    font-size: 1.5rem;
                    text-align: center;
                    letter-spacing: 0.5rem;
                    border: 2px solid #dee2e6;
                    border-radius: 8px;
                    transition: border-color 0.3s ease;
                }

                .otp-input:focus {
                    border-color: #007bff;
                    box-shadow: 0 0 0 0.2rem rgba(0, 123, 255, 0.25);
                }

                .resend-timer {
                    font-size: 0.9rem;
                    color: #6c757d;
                }

                .btn-verify {
                    border: 2px solid #007bff;
                    border-radius: 8px;
                    font-weight: 600;
                    transition: all 0.3s ease;
                }

                .btn-verify:hover {
                    border-color: #0056b3;
                    transform: translateY(-1px);
                    box-shadow: 0 4px 8px rgba(0, 123, 255, 0.3);
                }

                .back-link {
                    display: inline-block;
                    padding: 0.5rem 1rem;
                    border: 1px solid #6c757d;
                    border-radius: 6px;
                    color: #6c757d;
                    text-decoration: none;
                    transition: all 0.3s ease;
                }

                .back-link:hover {
                    border-color: #495057;
                    color: #495057;
                    background-color: #f8f9fa;
                }
            </style>
        </head>

        <body>
            <section class="vh-100">
                <div class="container-fluid h-custom">
                    <div class="row d-flex justify-content-center align-items-center h-100">
                        <div class="col-md-8 col-lg-6 col-xl-4">
                            <div class="otp-container">
                                <div class="text-center mb-4">
                                    <h2 class="fw-bold mb-2">Verify Your Email</h2>
                                    <p class="text-muted">We've sent a verification code to your email address</p>
                                </div>

                                <form action="/verify-otp" method="post">
                                    <!-- OTP input -->
                                    <div class="form-outline mb-4">
                                        <label class="form-label" for="otp">Enter 4-digit Verification Code</label>
                                        <input type="text" id="otp" name="otp"
                                            class="form-control form-control-lg otp-input" placeholder="Enter OTP"
                                            maxlength="4" pattern="[0-9]{4}"
                                            title="Please enter a 4-digit verification code" required />
                                        <label class="form-label" for="otp">You have ${registration_time} times to enter
                                            the verification code</label>
                                        <div class="invalid-feedback" id="otpError">
                                            Please enter a valid 4-digit verification code
                                        </div>
                                    </div>

                                    <div class="text-center mb-3">
                                        <button type="submit" class="btn btn-primary btn-lg w-100 btn-verify">
                                            Verify Email
                                        </button>
                                    </div>

                                    <div class="text-center">
                                        <p class="resend-timer mb-2">
                                            Didn't receive the code?
                                            <a href="#" onclick="resendOTP()" class="text-decoration-none"
                                                style="color: #007bff; cursor: pointer;">
                                                Resend OTP
                                            </a>
                                        </p>
                                        <p class="small text-muted">
                                            The 4-digit verification code will expire in 10 minutes
                                        </p>
                                    </div>
                                </form>

                                <!-- Separate form for resend OTP -->
                                <form id="resendForm" action="/resend-otp" method="post" style="display: none;">
                                </form>

                                <div class="text-center mt-3">
                                    <a href="/register" class="back-link">
                                        <i class="fas fa-arrow-left me-1"></i>
                                        Back to Registration
                                    </a>
                                </div>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>

                <div
                    class="d-flex flex-column flex-md-row text-center text-md-start justify-content-between py-4 px-4 px-xl-5 bg-primary">
                    <!-- Copyright -->
                    <div class="text-white mb-3 mb-md-0">
                        Copyright © 2024. All rights reserved.
                    </div>
                    <!-- Copyright -->

                    <!-- Right -->
                    <div>
                        <a href="#!" class="text-white me-4">
                            <i class="fab fa-facebook-f"></i>
                        </a>
                        <a href="#!" class="text-white me-4">
                            <i class="fab fa-twitter"></i>
                        </a>
                        <a href="#!" class="text-white me-4">
                            <i class="fab fa-google"></i>
                        </a>
                        <a href="#!" class="text-white">
                            <i class="fab fa-linkedin-in"></i>
                        </a>
                    </div>
                    <!-- Right -->
                </div>
            </section>

            <!-- iziToast JS -->
            <script src="https://cdnjs.cloudflare.com/ajax/libs/izitoast/1.4.0/js/iziToast.min.js"></script>

            <script>
                // OTP validation
                function validateOTP(otp) {
                    // Check if OTP is 4 digits
                    return /^[0-9]{4}$/.test(otp);
                }

                // Real-time validation
                document.getElementById('otp').addEventListener('input', function () {
                    var otp = this.value;
                    var isValid = validateOTP(otp);

                    if (otp.length > 0 && !isValid) {
                        this.setCustomValidity('Please enter a valid 4-digit verification code');
                        this.classList.add('is-invalid');
                    } else {
                        this.setCustomValidity('');
                        this.classList.remove('is-invalid');
                    }
                });

                // Form submission validation
                document.querySelector('form').addEventListener('submit', function (e) {
                    var otp = document.getElementById('otp').value;

                    if (!validateOTP(otp)) {
                        e.preventDefault();
                        iziToast.error({
                            title: 'Error!',
                            message: 'Please enter a valid 4-digit verification code',
                            position: 'topRight',
                            timeout: 5000
                        });
                        return false;
                    }
                });

                // Auto-format OTP input (only allow numbers)
                document.getElementById('otp').addEventListener('keypress', function (e) {
                    if (!/[0-9]/.test(e.key) && !['Backspace', 'Delete', 'Tab', 'Enter', 'ArrowLeft', 'ArrowRight'].includes(e.key)) {
                        e.preventDefault();
                    }
                });

                // Auto-focus on page load
                document.addEventListener('DOMContentLoaded', function () {
                    document.getElementById('otp').focus();
                });

                // Function to resend OTP
                function resendOTP() {
                    document.getElementById('resendForm').submit();
                }
            </script>

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
                    // Clear the OTP input field when there's an error
                    document.getElementById('otp').value = '';
                    document.getElementById('otp').focus();
                </script>
            </c:if>

        </body>

        </html>