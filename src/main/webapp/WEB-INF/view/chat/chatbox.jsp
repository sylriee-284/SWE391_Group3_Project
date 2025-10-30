<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
            <!DOCTYPE html>
            <html lang="en">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Chatbox</title>
                <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css"
                    rel="stylesheet">
                <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

                <style>
                    /* CSS để điều chỉnh nội dung khi sidebar mở */
                    .content {
                        margin-left: 0;
                        transition: margin-left 0.3s ease;
                    }

                    .content.shifted {
                        margin-left: 250px;
                    }

                    /* Đảm bảo nội dung không bị che bởi navbar */
                    body {
                        padding-top: 60px;
                    }

                    /* Custom styles cho chat interface */
                    .shop-item {
                        cursor: pointer;
                        transition: background-color 0.2s;
                    }

                    .shop-item:hover {
                        background-color: #e9ecef;
                    }

                    .shop-item.active {
                        background-color: #cfe2ff;
                    }

                    .messages-area {
                        background-color: #f8f9fa;
                    }

                    .message {
                        margin-bottom: 15px;
                    }

                    .message.sent {
                        text-align: right;
                    }

                    .message.received {
                        text-align: left;
                    }

                    .message-bubble {
                        display: inline-block;
                        max-width: 70%;
                        padding: 10px 15px;
                        border-radius: 18px;
                        word-wrap: break-word;
                    }

                    .message.sent .message-bubble {
                        background-color: #007bff;
                        color: white;
                    }

                    .message.received .message-bubble {
                        background-color: white;
                        color: #333;
                        border: 1px solid #e9ecef;
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
                            <div class="container-fluid h-100">
                                <div class="row h-100">
                                    <!-- Left Sidebar - Shops List -->
                                    <div class="col-md-4 col-lg-3 bg-light border-end">
                                        <div class="p-3">
                                            <h5 class="mb-3 text-center">Danh sách Shop</h5>

                                            <!-- Search Box -->
                                            <div class="mb-3">
                                                <input type="text" class="form-control" placeholder="Tìm kiếm shop...">
                                            </div>

                                            <!-- Shops List -->
                                            <div class="shops-list"
                                                style="max-height: calc(100vh - 200px); overflow-y: auto;">
                                                <div class="shop-item p-3 border-bottom active"
                                                    onclick="selectShop('techstore', 'TechStore')">
                                                    <div class="d-flex align-items-center">
                                                        <img src="https://mdbcdn.b-cdn.net/img/Photos/Avatars/avatar-8.webp"
                                                            alt="TechStore" class="rounded-circle me-3" width="50"
                                                            height="50">
                                                        <div class="flex-grow-1">
                                                            <h6 class="mb-1">TechStore</h6>
                                                            <small class="text-muted">Chào bạn! Chúng tôi chuyên bán
                                                                laptop...</small>
                                                        </div>
                                                        <div class="text-end">
                                                            <small class="text-muted">2 phút</small>
                                                            <span class="badge bg-danger ms-1">2</span>
                                                        </div>
                                                    </div>
                                                </div>

                                                <div class="shop-item p-3 border-bottom"
                                                    onclick="selectShop('gameshop', 'GameShop')">
                                                    <div class="d-flex align-items-center">
                                                        <img src="https://mdbcdn.b-cdn.net/img/Photos/Avatars/avatar-1.webp"
                                                            alt="GameShop" class="rounded-circle me-3" width="50"
                                                            height="50">
                                                        <div class="flex-grow-1">
                                                            <h6 class="mb-1">GameShop</h6>
                                                            <small class="text-muted">Có tài khoản PUBG Mobile
                                                                không?</small>
                                                        </div>
                                                        <div class="text-end">
                                                            <small class="text-muted">5 phút</small>
                                                        </div>
                                                    </div>
                                                </div>

                                                <div class="shop-item p-3 border-bottom"
                                                    onclick="selectShop('softwarestore', 'SoftwareStore')">
                                                    <div class="d-flex align-items-center">
                                                        <img src="https://mdbcdn.b-cdn.net/img/Photos/Avatars/avatar-2.webp"
                                                            alt="SoftwareStore" class="rounded-circle me-3" width="50"
                                                            height="50">
                                                        <div class="flex-grow-1">
                                                            <h6 class="mb-1">SoftwareStore</h6>
                                                            <small class="text-muted">Có Microsoft Office không?</small>
                                                        </div>
                                                        <div class="text-end">
                                                            <small class="text-muted">Hôm qua</small>
                                                        </div>
                                                    </div>
                                                </div>

                                                <div class="shop-item p-3 border-bottom"
                                                    onclick="selectShop('digitalgoods', 'DigitalGoods')">
                                                    <div class="d-flex align-items-center">
                                                        <img src="https://mdbcdn.b-cdn.net/img/Photos/Avatars/avatar-3.webp"
                                                            alt="DigitalGoods" class="rounded-circle me-3" width="50"
                                                            height="50">
                                                        <div class="flex-grow-1">
                                                            <h6 class="mb-1">DigitalGoods</h6>
                                                            <small class="text-muted">Có email Gmail không?</small>
                                                        </div>
                                                        <div class="text-end">
                                                            <small class="text-muted">Hôm qua</small>
                                                        </div>
                                                    </div>
                                                </div>

                                                <div class="shop-item p-3 border-bottom"
                                                    onclick="selectShop('supportcenter', 'SupportCenter')">
                                                    <div class="d-flex align-items-center">
                                                        <img src="https://mdbcdn.b-cdn.net/img/Photos/Avatars/avatar-4.webp"
                                                            alt="SupportCenter" class="rounded-circle me-3" width="50"
                                                            height="50">
                                                        <div class="flex-grow-1">
                                                            <h6 class="mb-1">SupportCenter</h6>
                                                            <small class="text-muted">Tôi gặp vấn đề với đơn
                                                                hàng</small>
                                                        </div>
                                                        <div class="text-end">
                                                            <small class="text-muted">2 ngày</small>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Right Side - Messages Area -->
                                    <div class="col-md-8 col-lg-9 d-flex flex-column">
                                        <!-- Chat Header -->
                                        <div class="chat-header bg-white border-bottom p-3">
                                            <div class="d-flex align-items-center">
                                                <img src="https://mdbcdn.b-cdn.net/img/Photos/Avatars/avatar-8.webp"
                                                    alt="TechStore" class="rounded-circle me-3" width="40" height="40">
                                                <div>
                                                    <h6 class="mb-0">TechStore</h6>
                                                    <small class="text-muted">Online</small>
                                                </div>
                                            </div>
                                        </div>

                                        <!-- Messages Area -->
                                        <div class="messages-area flex-grow-1 p-3"
                                            style="height: 400px; overflow-y: auto; background-color: #f8f9fa;">

                                            <!-- Hardcoded Messages -->
                                            <div class="message received">
                                                <div class="message-bubble">
                                                    Chào bạn! Chúng tôi chuyên bán laptop, điện thoại và phụ kiện công
                                                    nghệ
                                                    <div class="small text-muted mt-1">14:30</div>
                                                </div>
                                            </div>

                                            <div class="message sent">
                                                <div class="message-bubble">
                                                    Bạn có sản phẩm nào đang khuyến mãi không?
                                                    <div class="small text-muted mt-1">14:32</div>
                                                </div>
                                            </div>

                                            <div class="message received">
                                                <div class="message-bubble">
                                                    Hiện tại chúng tôi đang có chương trình giảm giá 20% cho laptop
                                                    gaming
                                                    <div class="small text-muted mt-1">14:33</div>
                                                </div>
                                            </div>

                                            <div class="message sent">
                                                <div class="message-bubble">
                                                    Tuyệt vời! Tôi muốn xem laptop gaming Dell
                                                    <div class="small text-muted mt-1">14:35</div>
                                                </div>
                                            </div>

                                            <div class="message received">
                                                <div class="message-bubble">
                                                    Chúng tôi có Dell G15 với RTX 4060, giá 25 triệu sau giảm giá. Bạn
                                                    có quan tâm không?
                                                    <div class="small text-muted mt-1">14:36</div>
                                                </div>
                                            </div>

                                            <div class="message sent">
                                                <div class="message-bubble">
                                                    Có ạ! Tôi muốn đặt hàng
                                                    <div class="small text-muted mt-1">14:38</div>
                                                </div>
                                            </div>

                                            <div class="message received">
                                                <div class="message-bubble">
                                                    Tuyệt! Tôi sẽ gửi link đặt hàng cho bạn ngay
                                                    <div class="small text-muted mt-1">14:39</div>
                                                </div>
                                            </div>

                                        </div>

                                        <!-- Message Input -->
                                        <div class="message-input bg-white border-top p-3">
                                            <form id="chat-form" action="/chat/send" method="post"
                                                enctype="multipart/form-data">
                                                <div class="input-group">
                                                    <input type="text" name="message" class="form-control"
                                                        placeholder="Nhập tin nhắn..." required>
                                                    <input type="file" name="image" accept="image/*"
                                                        style="display: none;" id="image-input">
                                                    <button type="button" class="btn btn-outline-secondary"
                                                        onclick="document.getElementById('image-input').click()">
                                                        <i class="fas fa-image"></i>
                                                    </button>
                                                    <button type="submit" class="btn btn-primary">
                                                        <i class="fas fa-paper-plane"></i> Gửi
                                                    </button>
                                                </div>
                                            </form>
                                        </div>
                                        <div class="message-time">21:17 - 24/10</div>
                                    </div>
                                </div>
                            </div>

                            <!-- Chat Input Area -->
                            <div class="chat-input-area">
                                <div class="chat-input-row">
                                    <input type="text" class="chat-input" placeholder="Type a message"
                                        id="messageInput">
                                    <button class="send-button" id="sendButton">
                                        <i class="fas fa-paper-plane"></i>
                                    </button>
                                </div>
                            </div>
                        </div>

                        <!-- Bootstrap JS -->
                        <script
                            src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>

                        <!-- Sidebar Toggle Script -->
                        <script>
                            function toggleSidebar() {
                                var sidebar = document.getElementById('sidebar');
                                var content = document.getElementById('content');
                                sidebar.classList.toggle('active');
                                content.classList.toggle('shifted');
                            }

                            // Select shop function
                            function selectShop(shopId, shopName) {
                                // Remove active class from all shop items
                                document.querySelectorAll('.shop-item').forEach(item => {
                                    item.classList.remove('active');
                                });

                                // Add active class to selected shop
                                event.currentTarget.classList.add('active');

                                // Update chat header
                                document.getElementById('current-shop-name').textContent = shopName;
                                document.getElementById('shop-status').textContent = 'Online';

                                // Load messages for selected shop
                                loadMessages(shopId);
                            }

                            // Load messages function
                            function loadMessages(shopId) {
                                const messagesArea = document.querySelector('.messages-area');

                                // Hardcoded messages for demo
                                const shopMessages = {
                                    'techstore': [
                                        { text: 'Chào bạn! Chúng tôi chuyên bán laptop, điện thoại và phụ kiện công nghệ', sender: 'received', time: '14:30' },
                                        { text: 'Bạn có sản phẩm nào đang khuyến mãi không?', sender: 'sent', time: '14:32' },
                                        { text: 'Hiện tại chúng tôi đang có chương trình giảm giá 20% cho laptop gaming', sender: 'received', time: '14:33' }
                                    ],
                                    'gameshop': [
                                        { text: 'Chào bạn! Chúng tôi chuyên bán tài khoản game và gift card', sender: 'received', time: '15:00' },
                                        { text: 'Có tài khoản PUBG Mobile không?', sender: 'sent', time: '15:02' },
                                        { text: 'Có ạ! Chúng tôi có nhiều loại tài khoản PUBG từ cơ bản đến VIP', sender: 'received', time: '15:03' }
                                    ]
                                };

                                // Clear current messages
                                messagesArea.innerHTML = '';

                                if (shopMessages[shopId]) {
                                    shopMessages[shopId].forEach(msg => {
                                        addMessage(msg.text, msg.sender, msg.time);
                                    });
                                } else {
                                    addMessage('Chào mừng đến với ' + shopName + '! Bắt đầu cuộc trò chuyện với shop này.', 'received');
                                }
                            }

                            // Add message function
                            function addMessage(text, sender, time = null) {
                                const messagesArea = document.querySelector('.messages-area');
                                const messageDiv = document.createElement('div');
                                messageDiv.className = `message ${sender}`;

                                let timeString = time || new Date().toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit' });

                                messageDiv.innerHTML = `
                <div class="message-bubble">
                    ${text}
                    <div class="small text-muted mt-1">${timeString}</div>
                </div>
            `;

                                messagesArea.appendChild(messageDiv);
                                messagesArea.scrollTop = messagesArea.scrollHeight;
                            }

                            // Enter key to submit form
                            document.querySelector('input[name="message"]').addEventListener('keypress', function (e) {
                                if (e.key === 'Enter') {
                                    e.preventDefault();
                                    document.getElementById('chat-form').submit();
                                }
                            });
                        </script>
            </body>

            </html>