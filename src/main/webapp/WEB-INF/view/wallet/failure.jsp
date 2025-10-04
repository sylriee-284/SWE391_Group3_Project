<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <!DOCTYPE html>
        <html lang="en">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Deposit Failed</title>
            <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
            <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
        </head>

        <body>

            <div class="container mt-5">
                <div class="row justify-content-center">
                    <div class="col-md-6">
                        <div class="card border-danger">
                            <div class="card-header bg-danger text-white text-center">
                                <h4><i class="fas fa-times-circle"></i> Deposit Failed!</h4>
                            </div>
                            <div class="card-body text-center">
                                <div class="mb-4">
                                    <i class="fas fa-times-circle text-danger" style="font-size: 4rem;"></i>
                                </div>
                                <h5 class="text-danger">Transaction Failed</h5>
                                <p class="text-muted">An error occurred during payment processing. Please try again.
                                </p>

                                <div class="d-grid gap-2 mt-4">
                                    <a href="/wallet/deposit" class="btn btn-primary">
                                        <i class="fas fa-redo"></i> Try Again
                                    </a>
                                    <a href="/wallet" class="btn btn-outline-secondary">
                                        <i class="fas fa-wallet"></i> Back to My Wallet
                                    </a>
                                    <a href="/" class="btn btn-outline-secondary">
                                        <i class="fas fa-home"></i> Back to Home
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
        </body>

        </html>