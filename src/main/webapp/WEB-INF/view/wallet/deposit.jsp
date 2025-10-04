<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <!DOCTYPE html>
        <html lang="en">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Add Money to Wallet</title>
            <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
            <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
        </head>

        <body>
            <div class="container mt-5">
                <div class="row justify-content-center">
                    <div class="col-md-6">
                        <div class="card">
                            <div class="card-header bg-primary text-white text-center">
                                <h4><i class="fas fa-plus-circle"></i> Add Money to Wallet</h4>
                            </div>
                            <div class="card-body">
                                <!-- Error messages -->
                                <c:if test="${param.error eq 'invalid_amount'}">
                                    <div class="alert alert-danger alert-dismissible fade show" role="alert">
                                        <i class="fas fa-exclamation-circle"></i> Minimum amount is 10,000 VND
                                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                                    </div>
                                </c:if>

                                <c:if test="${param.error eq 'encoding'}">
                                    <div class="alert alert-danger alert-dismissible fade show" role="alert">
                                        <i class="fas fa-exclamation-circle"></i> An error occurred. Please try again!
                                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                                    </div>
                                </c:if>

                                <form action="/wallet/deposit" method="post" id="depositForm">
                                    <div class="mb-3">
                                        <label for="amount" class="form-label">
                                            <i class="fas fa-money-bill-wave"></i> Amount (VND)
                                        </label>
                                        <input type="number" class="form-control" id="amount" name="amount"
                                            placeholder="Enter amount to deposit" min="10000" step="1000" required>
                                        <div class="form-text">Minimum amount: 10,000 VND</div>
                                    </div>

                                    <div class="alert alert-info">
                                        <i class="fas fa-info-circle"></i>
                                        <strong>Note:</strong> You will be redirected to VNPay payment page to complete
                                        the transaction.
                                    </div>

                                    <div class="d-grid">
                                        <button type="submit" class="btn btn-primary btn-lg">
                                            <i class="fas fa-credit-card"></i> Pay with VNPay
                                        </button>
                                    </div>
                                </form>

                                <div class="text-center mt-3">
                                    <a href="/wallet" class="btn btn-outline-secondary">
                                        <i class="fas fa-arrow-left"></i> Back to Wallet
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
            <script>
                // Form validation
                document.getElementById('depositForm').addEventListener('submit', function (e) {
                    const amount = document.getElementById('amount').value;
                    if (!amount || amount < 10000) {
                        e.preventDefault();
                        alert('Please enter minimum amount of 10,000 VND');
                    }
                });

                // Format amount while typing
                document.getElementById('amount').addEventListener('input', function (e) {
                    let value = e.target.value;
                    if (value && !isNaN(value)) {
                        e.target.value = parseInt(value);
                    }
                });
            </script>
        </body>

        </html>