<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>

            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Chatbox</title>
                <jsp:include page="../common/head.jsp" />

                <style>
                    /* Custom styles cho chat interface */
                    /* keep minimal overrides only */
                    body {
                        padding-top: 60px;
                    }

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

                        <!-- Sidebar Overlay for Mobile -->
                        <div class="sidebar-overlay" id="sidebarOverlay" onclick="toggleSidebar()" role="button"
                            tabindex="0" onKeyPress="if(event.key === 'Enter') toggleSidebar()"></div>

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

                                        <!-- Messages Area (loaded from server) -->
                                        <div class="messages-area flex-grow-1 p-3" id="messagesArea"
                                            style="height: 400px; overflow-y: auto; background-color: #f8f9fa;">
                                            <!-- messages will be injected here -->
                                        </div>

                                        <!-- Message Input -->
                                        <div class="message-input bg-white border-top p-3">
                                            <form id="chat-form" action="#" method="post" enctype="multipart/form-data">
                                                <div class="input-group">
                                                    <input type="text" name="message" class="form-control"
                                                        placeholder="Nhập tin nhắn..." required>
                                                    <input type="file" name="image" accept="image/*"
                                                        style="display: none;" id="image-input">
                                                    <button type="button" class="btn btn-outline-secondary"
                                                        onclick="document.getElementById('image-input').click()">
                                                        <i class="fas fa-image"></i>
                                                    </button>
                                                    <button type="submit" class="btn btn-primary" id="sendBtn">
                                                        <i class="fas fa-paper-plane"></i> Gửi
                                                    </button>
                                                </div>
                                            </form>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <jsp:include page="../common/footer.jsp" />

                        <!-- Sidebar Toggle Script -->
                        <script>
                            function toggleSidebar() {
                                var sidebar = document.getElementById('sidebar');
                                var content = document.getElementById('content');
                                if (sidebar) sidebar.classList.toggle('active');
                                if (content) content.classList.toggle('shifted');
                            }

                            // Select shop function
                            var currentSellerId = null;
                            function selectShop(shopId, shopName) {
                                // Remove active class from all shop items
                                document.querySelectorAll('.shop-item').forEach(item => {
                                    item.classList.remove('active');
                                });

                                // Add active class to selected shop
                                event.currentTarget.classList.add('active');

                                // Update chat header (if present)
                                var headerName = document.querySelector('.chat-header h6');
                                if (headerName) headerName.textContent = shopName;
                                var headerStatus = document.querySelector('.chat-header small');
                                if (headerStatus) headerStatus.textContent = 'Online';

                                currentSellerId = shopId;
                                // Load messages for selected shop
                                loadMessages(shopId);
                            }

                            // Load messages function (from server)
                            function loadMessages(sellerId) {
                                const messagesArea = document.getElementById('messagesArea');
                                messagesArea.innerHTML = '';
                                if (!sellerId) return;
                                fetch(`/chat/messages?sellerId=${sellerId}`)
                                    .then(r => r.json())
                                    .then(data => {
                                        if (!Array.isArray(data)) return;
                                        data.forEach(m => {
                                            const sender = (m.senderId && m.senderId == /* current user id unknown client-side */ null) ? 'sent' : 'received';
                                            addMessage(m.content, sender, m.createdAt);
                                        });
                                    })
                                    .catch(err => {
                                        console.error('Failed to load messages', err);
                                    });
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
                            // Wire up AJAX send
                            document.getElementById('chat-form').addEventListener('submit', function (e) {
                                e.preventDefault();
                                var input = this.querySelector('input[name="message"]');
                                var text = input.value.trim();
                                if (!text || !currentSellerId) return;
                                var fd = new FormData();
                                fd.append('sellerId', currentSellerId);
                                fd.append('message', text);
                                // optional: attach productId if present in URL
                                var params = new URLSearchParams(window.location.search);
                                if (params.get('productId')) fd.append('productId', params.get('productId'));

                                fetch('/chat/send', { method: 'POST', body: fd })
                                    .then(r => r.json())
                                    .then(resp => {
                                        if (!resp.ok) {
                                            // not logged in or error
                                            if (resp.error && resp.error.includes('đăng nhập')) {
                                                window.location.href = '/login';
                                            } else {
                                                console.error('Send error', resp);
                                            }
                                            return;
                                        }
                                        // append message locally
                                        addMessage(resp.message.content, 'sent', resp.message.createdAt);
                                        input.value = '';
                                    })
                                    .catch(err => {
                                        console.error('Failed to send message', err);
                                    });
                            });
                        </script>
            </body>

            </html>