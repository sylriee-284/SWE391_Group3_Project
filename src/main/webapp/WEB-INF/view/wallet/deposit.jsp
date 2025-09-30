<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <!DOCTYPE html>
    <html>

    <head>
        <meta charset="UTF-8">
        <title>Nạp tiền - Wallet</title>
        <style>
            .deposit-form {
                max-width: 400px;
                margin: 20px auto;
                padding: 20px;
                border: 1px solid #ddd;
                border-radius: 8px;
            }

            .deposit-input {
                width: 100%;
                padding: 10px;
                margin: 10px 0;
                border: 1px solid #ddd;
                border-radius: 4px;
                font-size: 16px;
            }

            .deposit-button {
                width: 100%;
                padding: 12px;
                background-color: #00a5f4;
                color: white;
                border: none;
                border-radius: 4px;
                cursor: pointer;
                font-size: 16px;
            }

            .deposit-button:hover {
                background-color: #0089cc;
            }
        </style>
    </head>

    <body>
        <div class="deposit-form">
            <form action="/wallet/deposit" method="post">
                <input type="number" name="amount" class="deposit-input" placeholder="Nhập số tiền muốn nạp" min="1000"
                    step="1000" required>
                <button type="submit" class="deposit-button">Nạp tiền bằng VNPAY</button>
            </form>
        </div>
    </body>

    </html>