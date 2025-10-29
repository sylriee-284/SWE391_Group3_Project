<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Tin nhắn</title>
                <jsp:include page="../common/head.jsp" />
                <link rel="stylesheet" href="/resources/css/chat.css">
            </head>

            <body>
                <%@ include file="../common/navbar.jsp" %>
                    <%@ include file="../common/sidebar.jsp" %>
                        <div class="sidebar-overlay" id="sidebarOverlay" onclick="toggleSidebar()"></div>
                        <input type="hidden" id="initialSellerId" value="${sellerId}">
                        <input type="hidden" id="initialProductId" value="${productId}">
                        <input type="hidden" id="currentUserId" value="${currentUserId}">
                        <div class="content" id="content">
                            <div class="container-fluid chat-container">
                                <div class="row h-100">
                                    <div class="col-md-4 col-lg-3 border-end bg-white">
                                        <div class="p-3">
                                            <h5 class="mb-3">Tin nhắn</h5>
                                            <div class="mb-3">
                                                <input type="text" id="searchInput" class="form-control"
                                                    placeholder="Tìm kiếm..." onkeyup="filterConversations()">
                                            </div>
                                            <div class="conversations-list" id="conversationsList">
                                                <div class="text-center text-muted p-3"><i
                                                        class="fas fa-spinner fa-spin"></i> Đang tải...</div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-8 col-lg-9 d-flex flex-column bg-white">
                                        <div class="border-bottom p-3" id="chatHeader" style="display: none;">
                                            <div class="d-flex align-items-center">
                                                <img src="" id="chatHeaderAvatar" alt="" class="rounded-circle me-3"
                                                    width="50" height="50">
                                                <div>
                                                    <h6 class="mb-0" id="chatHeaderName"></h6>
                                                    <small class="text-muted" id="chatHeaderStatus">Offline</small>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="messages-area flex-grow-1" id="messagesArea">
                                            <div class="empty-state">
                                                <i class="fas fa-comments"></i>
                                                <p>Chọn một cuộc hội thoại để bắt đầu nhắn tin</p>
                                            </div>
                                        </div>
                                        <div class="border-top p-3" id="messageInputArea" style="display: none;">
                                            <form id="chatForm">
                                                <div class="input-group">
                                                    <input type="text" name="message" class="form-control"
                                                        placeholder="Nhập tin nhắn..." required autocomplete="off">
                                                    <button type="submit" class="btn btn-primary"><i
                                                            class="fas fa-paper-plane"></i> Gửi</button>
                                                </div>
                                            </form>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <jsp:include page="../common/footer.jsp" />
                        <script>
                            let currentSellerId = null;
                            let currentUserId = document.getElementById('currentUserId').value || null;
                            let conversationsData = [];

                            function toggleSidebar() {
                                const sidebar = document.getElementById('sidebar');
                                const content = document.getElementById('content');
                                const overlay = document.getElementById('sidebarOverlay');
                                if (sidebar) sidebar.classList.toggle('active');
                                if (content) content.classList.toggle('shifted');
                                if (overlay) overlay.classList.toggle('active');
                            }

                            document.addEventListener('DOMContentLoaded', function () {
                                console.log('[Chat] Page loaded, currentUserId:', currentUserId);
                                loadConversations();
                                const initialSellerId = document.getElementById('initialSellerId').value;
                                const initialProductId = document.getElementById('initialProductId').value;
                                console.log('[Chat] Initial params - sellerId:', initialSellerId, 'productId:', initialProductId);
                                if (initialSellerId && initialSellerId !== '') {
                                    setTimeout(() => selectConversationBySellerId(parseInt(initialSellerId)), 500);
                                }
                            });

                            function loadConversations() {
                                console.log('[Chat] Loading conversations...');
                                fetch('/chat/conversations').then(r => r.json()).then(data => {
                                    console.log('[Chat] Loaded', data.length, 'conversations:', data);
                                    conversationsData = data;
                                    renderConversations(data);
                                }).catch(err => {
                                    console.error('[Chat] Failed to load conversations', err);
                                    document.getElementById('conversationsList').innerHTML = '<div class="text-center text-danger p-3"><i class="fas fa-exclamation-circle"></i> Không thể tải danh sách tin nhắn</div>';
                                });
                            }

                            function renderConversations(conversations) {
                                const container = document.getElementById('conversationsList');
                                if (!conversations || conversations.length === 0) {
                                    container.innerHTML = '<div class="text-center text-muted p-3"><i class="fas fa-inbox"></i><br>Chưa có tin nhắn nào</div>';
                                    return;
                                }
                                let html = '';
                                conversations.forEach(conv => {
                                    // Skip conversation with yourself
                                    if (currentUserId && conv.otherUser.id == currentUserId) {
                                        console.log('[Chat] Skipping self-conversation with user:', conv.otherUser.id);
                                        return;
                                    }

                                    const lastMsgTime = conv.lastMessage && conv.lastMessage.createdAt ? conv.lastMessage.createdAt : null;
                                    const timeAgo = formatTimeAgo(lastMsgTime);
                                    const unreadBadge = conv.unreadCount > 0 ? '<span class="badge bg-danger ms-1">' + conv.unreadCount + '</span>' : '';
                                    const displayName = conv.otherUser.fullName ? conv.otherUser.fullName : conv.otherUser.username;
                                    const lastMsgContent = conv.lastMessage && conv.lastMessage.content ? conv.lastMessage.content : 'Chưa có tin nhắn';
                                    // Use avatar from API or generate fallback
                                    const avatarUrl = conv.otherUser.avatar || ('https://ui-avatars.com/api/?name=' + encodeURIComponent(displayName) + '&background=random&color=fff&size=128&rounded=true');
                                    const onclickHandler = "selectConversation(" + conv.otherUser.id + ", '" + escapeQuotes(displayName) + "', '" + escapeQuotes(avatarUrl) + "')";

                                    html += '<div class="conversation-item" data-seller-id="' + conv.otherUser.id + '" onclick="' + onclickHandler + '">' +
                                        '<div class="d-flex align-items-center">' +
                                        '<img src="' + avatarUrl + '" alt="' + escapeHtml(conv.otherUser.username) + '" class="rounded-circle me-3" width="50" height="50" loading="lazy">' +
                                        '<div class="flex-grow-1">' +
                                        '<h6 class="mb-1">' + escapeHtml(displayName) + unreadBadge + '</h6>' +
                                        '<small class="text-muted text-truncate d-block" style="max-width: 200px;">' + escapeHtml(lastMsgContent) + '</small>' +
                                        '</div>' +
                                        '<div class="text-end"><small class="text-muted">' + timeAgo + '</small></div>' +
                                        '</div></div>';
                                });

                                if (html === '') {
                                    container.innerHTML = '<div class="text-center text-muted p-3"><i class="fas fa-inbox"></i><br>Chưa có tin nhắn nào</div>';
                                } else {
                                    container.innerHTML = html;
                                }
                            }

                            function selectConversationBySellerId(sellerId) {
                                const conversationItem = document.querySelector('.conversation-item[data-seller-id="' + sellerId + '"]');
                                if (conversationItem) {
                                    conversationItem.click();
                                } else {
                                    // Generate fallback avatar if conversation not found
                                    const fallbackAvatar = 'https://ui-avatars.com/api/?name=User&background=random&color=fff&size=128&rounded=true';
                                    selectConversation(sellerId, 'Seller', fallbackAvatar);
                                }
                            }

                            function selectConversation(sellerId, sellerName, avatarUrl) {
                                console.log('[Chat] Selecting conversation - sellerId:', sellerId, 'name:', sellerName);

                                // Prevent chatting with yourself
                                if (currentUserId && sellerId == currentUserId) {
                                    alert('Bạn không thể tự nhắn tin với chính mình.');
                                    console.warn('[Chat] Blocked self-conversation attempt');
                                    return;
                                }

                                document.querySelectorAll('.conversation-item').forEach(item => item.classList.remove('active'));
                                const selectedItem = document.querySelector('.conversation-item[data-seller-id="' + sellerId + '"]');
                                if (selectedItem) selectedItem.classList.add('active');
                                document.getElementById('chatHeader').style.display = 'block';
                                document.getElementById('chatHeaderName').textContent = sellerName;
                                document.getElementById('chatHeaderAvatar').src = avatarUrl;
                                document.getElementById('chatHeaderAvatar').alt = sellerName;
                                document.getElementById('messageInputArea').style.display = 'block';
                                currentSellerId = sellerId;
                                loadMessages(sellerId);
                            }

                            function loadMessages(sellerId) {
                                console.log('[Chat] Loading messages with sellerId:', sellerId);
                                const messagesArea = document.getElementById('messagesArea');
                                messagesArea.innerHTML = '<div class="text-center text-muted p-3"><i class="fas fa-spinner fa-spin"></i> Đang tải tin nhắn...</div>';
                                fetch('/chat/messages?sellerId=' + sellerId).then(r => r.json()).then(data => {
                                    console.log('[Chat] Loaded', data.messages ? data.messages.length : 0, 'messages. CurrentUserId:', data.currentUserId);
                                    messagesArea.innerHTML = '';
                                    if (!data.messages || data.messages.length === 0) {
                                        messagesArea.innerHTML = '<div class="empty-state"><i class="fas fa-comments"></i><p>Chưa có tin nhắn. Hãy gửi tin nhắn đầu tiên!</p></div>';
                                        return;
                                    }
                                    const userId = data.currentUserId || currentUserId;
                                    data.messages.forEach(m => {
                                        const isSent = m.senderId && userId && m.senderId == userId;
                                        console.log('[Chat] Message:', m.id, 'senderId:', m.senderId, 'isSent:', isSent);
                                        addMessage(m.content, isSent ? 'sent' : 'received', m.createdAt);
                                    });
                                }).catch(err => {
                                    console.error('[Chat] Failed to load messages', err);
                                    messagesArea.innerHTML = '<div class="text-center text-danger p-3"><i class="fas fa-exclamation-circle"></i> Không thể tải tin nhắn</div>';
                                });
                            }

                            function addMessage(text, type, timestamp) {
                                const messagesArea = document.getElementById('messagesArea');
                                const messageDiv = document.createElement('div');
                                messageDiv.className = 'message ' + type;
                                const timeString = timestamp ? formatMessageTime(timestamp) : 'Vừa xong';
                                messageDiv.innerHTML = '<div class="message-bubble">' + escapeHtml(text) + '<div class="message-time">' + timeString + '</div></div>';
                                messagesArea.appendChild(messageDiv);
                                messagesArea.scrollTop = messagesArea.scrollHeight;
                            }

                            function filterConversations() {
                                const searchTerm = document.getElementById('searchInput').value.toLowerCase();
                                const filtered = conversationsData.filter(conv => {
                                    const name = (conv.otherUser.fullName || conv.otherUser.username).toLowerCase();
                                    const lastMsg = (conv.lastMessage && conv.lastMessage.content ? conv.lastMessage.content : '').toLowerCase();
                                    return name.includes(searchTerm) || lastMsg.includes(searchTerm);
                                });
                                renderConversations(filtered);
                            }

                            function formatTimeAgo(dateString) {
                                if (!dateString) return '';
                                const date = new Date(dateString);
                                const now = new Date();
                                const diffMs = now - date;
                                const diffMins = Math.floor(diffMs / 60000);
                                const diffHours = Math.floor(diffMs / 3600000);
                                const diffDays = Math.floor(diffMs / 86400000);
                                if (diffMins < 1) return 'Vừa xong';
                                if (diffMins < 60) return diffMins + ' phút';
                                if (diffHours < 24) return diffHours + ' giờ';
                                if (diffDays === 1) return 'Hôm qua';
                                if (diffDays < 7) return diffDays + ' ngày';
                                return date.toLocaleDateString('vi-VN');
                            }

                            function formatMessageTime(dateString) {
                                if (!dateString) return '';
                                const date = new Date(dateString);
                                return date.toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit' });
                            }

                            function escapeHtml(text) {
                                if (!text) return '';
                                const div = document.createElement('div');
                                div.textContent = text;
                                return div.innerHTML;
                            }

                            function escapeQuotes(text) {
                                if (!text) return '';
                                return text.replace(/'/g, "\\\\'").replace(/"/g, '&quot;');
                            }

                            document.getElementById('chatForm').addEventListener('submit', function (e) {
                                e.preventDefault();
                                const input = this.querySelector('input[name="message"]');
                                const text = input.value.trim();
                                if (!text || !currentSellerId) {
                                    console.warn('[Chat] Cannot send - text:', text, 'sellerId:', currentSellerId);
                                    return;
                                }
                                const formData = new FormData();
                                formData.append('sellerId', currentSellerId);
                                formData.append('message', text);
                                const productId = document.getElementById('initialProductId').value;
                                if (productId && productId !== '') formData.append('productId', productId);
                                console.log('[Chat] Sending message to sellerId:', currentSellerId, 'text:', text, 'productId:', productId);
                                fetch('/chat/send', { method: 'POST', body: formData }).then(r => r.json()).then(resp => {
                                    console.log('[Chat] Send response:', resp);
                                    if (!resp.ok) {
                                        if (resp.error && resp.error.includes('đăng nhập')) {
                                            alert('Vui lòng đăng nhập để gửi tin nhắn');
                                            window.location.href = '/login';
                                        } else {
                                            alert('Không thể gửi tin nhắn: ' + (resp.error || 'Lỗi không xác định'));
                                        }
                                        return;
                                    }
                                    console.log('[Chat] Message sent successfully:', resp.message);
                                    addMessage(resp.message.content, 'sent', resp.message.createdAt);
                                    input.value = '';
                                    loadConversations();
                                }).catch(err => {
                                    console.error('[Chat] Failed to send message', err);
                                    alert('Không thể gửi tin nhắn. Vui lòng thử lại.');
                                });
                            });
                        </script>
            </body>

            </html>