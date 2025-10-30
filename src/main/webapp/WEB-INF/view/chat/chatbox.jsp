<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>

            <!DOCTYPE html>
            <html lang="en">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>
                    <c:if test="${not empty pageTitle}">${pageTitle} - </c:if>MMO Market System
                </title>

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
                    <div class="chat-container">
                        <!-- Left Column - Contact List -->
                        <div class="contact-list">
                            <!-- Contact Header -->
                            <div class="contact-header">
                                <h3>
                                    Gần đây
                                </h3>
                            </div>

                            <!-- Contact Items -->
                            <div class="contact-items">
                                <c:forEach var="conversation" items="${conversations}">
                                    <c:set var="conversationPartner"
                                        value="${messageService.getConversationPartner(conversation, currentUser.id)}" />
                                    <a href="/chat?chat-to=${conversationPartner.username}" class="contact-item-link">
                                        <div class="contact-item">
                                            <c:choose>
                                                <c:when test="${messageService.isAdminUser(conversationPartner)}">
                                                    <img src="${pageContext.request.contextPath}/images/chat/mmo-avatar.jpg"
                                                        alt="${messageService.getUserDisplayName(conversationPartner)}"
                                                        class="contact-avatar">
                                                </c:when>
                                                <c:otherwise>
                                                    <img src="${pageContext.request.contextPath}/images/chat/mmo-user.jpg"
                                                        alt="${messageService.getUserDisplayName(conversationPartner)}"
                                                        class="contact-avatar">
                                                </c:otherwise>
                                            </c:choose>
                                            <div class="contact-info">
                                                <div class="contact-name-row">
                                                    <span
                                                        class="contact-name">${messageService.getUserDisplayName(conversationPartner)}</span>
                                                </div>
                                                <div class="contact-preview">
                                                    ${messageService.getConversationPreview(conversation,
                                                    currentUser.id)}
                                                </div>
                                                <div class="contact-date">
                                                    ${messageService.formatMessageTime(conversation.createdAt)}</div>
                                            </div>
                                        </div>
                                    </a>
                                </c:forEach>
                            </div>

                            <!-- Contact Admin Button -->
                            <a href="/chat/admin" class="contact-admin-btn" role="button" tabindex="0"
                                aria-label="Liên hệ Admin">
                                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                    stroke-width="2" aria-hidden="true">
                                    <path
                                        d="M21 11.5a8.38 8.38 0 0 1-.9 3.8 8.5 8.5 0 0 1-7.6 4.7 8.38 8.38 0 0 1-3.8-.9L3 21l1.9-5.7a8.38 8.38 0 0 1-.9-3.8 8.5 8.5 0 0 1 4.7-7.6 8.38 8.38 0 0 1 3.8-.9h.5a8.48 8.48 0 0 1 8 8v.5z" />
                                    <circle cx="8" cy="13" r="1" fill="currentColor" />
                                    <circle cx="12" cy="13" r="1" fill="currentColor" />
                                    <circle cx="16" cy="13" r="1" fill="currentColor" />
                                </svg>
                                <span class="admin-btn-label">Liên hệ Admin</span>
                            </a>
                        </div>

                        <!-- Right Column - Chat Area -->
                        <div class="chat-area">
                            <!-- Chat Header -->
                            <div class="chat-header">
                                <h4>
                                    ${messageService.getUserDisplayName(selectedUser)}
                                </h4>
                            </div>

                            <!-- Chat Messages -->
                            <div class="chat-messages" id="chatMessages">
                                <c:forEach var="message" items="${messages}">
                                    <c:set var="isSent" value="${message.senderUser.id eq currentUser.id}" />
                                    <c:choose>
                                        <c:when test="${isSent}">
                                            <div
                                                style="display: flex !important; margin-bottom: 15px; align-items: flex-start; justify-content: flex-end;">
                                                <div style="max-width: 70% !important;">
                                                    <div
                                                        style="padding: 12px 16px !important; border-radius: 18px !important; font-size: 14px !important; line-height: 1.4 !important; background: #0d6efd !important; color: #fff !important; border-bottom-right-radius: 4px !important; word-break: normal !important; white-space: normal !important;">
                                                        ${message.content}
                                                    </div>
                                                    <div
                                                        style="font-size: 11px !important; color: #999 !important; margin-top: 4px !important; text-align: right !important;">
                                                        ${messageService.formatMessageTime(message.createdAt)}</div>
                                                </div>
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <div
                                                style="display: flex !important; margin-bottom: 15px; align-items: flex-start; justify-content: flex-start;">
                                                <div style="max-width: 70% !important;">
                                                    <div
                                                        style="padding: 12px 16px !important; border-radius: 18px !important; font-size: 14px !important; line-height: 1.4 !important; background: #e5e5e5 !important; color: #333 !important; border-bottom-left-radius: 4px !important; word-break: normal !important; white-space: normal !important;">
                                                        ${message.content}
                                                    </div>
                                                    <div
                                                        style="font-size: 11px !important; color: #999 !important; margin-top: 4px !important; text-align: left !important;">
                                                        ${messageService.formatMessageTime(message.createdAt)}</div>
                                                </div>
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                </c:forEach>
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
                    </div>
                </div>



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
                    </script>
                </c:if>

                <!-- Page-specific JavaScript -->
                <c:if test="${not empty pageJS}">
                    <c:forEach var="js" items="${pageJS}">
                        <script src="${pageContext.request.contextPath}${js}"></script>
                    </c:forEach>
                </c:if>

                <!-- Common JavaScript -->
                <script>
                    document.addEventListener('DOMContentLoaded', function () {
                        const messageInput = document.getElementById('messageInput');
                        const sendButton = document.getElementById('sendButton');
                        const currentUserId = '${currentUser.id}';

                        <c:choose>
                            <c:when test="${selectedUser != null}">
                                const partnerUserId = ${selectedUser.id};
                            </c:when>
                            <c:otherwise>
                                const partnerUserId = null;
                            </c:otherwise>
                        </c:choose>

                        // Auto scroll to bottom to show latest messages
                        const chatMessages = document.getElementById('chatMessages');
                        if (chatMessages) {
                            chatMessages.scrollTop = chatMessages.scrollHeight;
                        }

                        function sendMessage() {
                            const content = messageInput.value.trim();
                            if (!content || partnerUserId === null) return;

                            fetch('/api/chat/send', {
                                method: 'POST',
                                headers: { 'Content-Type': 'application/json' },
                                body: JSON.stringify({
                                    partnerUserId: partnerUserId,
                                    content: content
                                })
                            })
                                .then(response => response.json())
                                .then(data => {
                                    if (data.success) {
                                        // Add message to UI immediately
                                        const chatMessages = document.getElementById('chatMessages');
                                        if (!chatMessages) {
                                            console.error('Chat messages container not found');
                                            return;
                                        }

                                        const timestamp = new Date().toLocaleTimeString('vi-VN', {
                                            hour: '2-digit',
                                            minute: '2-digit'
                                        });

                                        const messageHTML = `
                                            <div style="display: flex !important; margin-bottom: 15px; align-items: flex-start; justify-content: flex-end;">
                                                <div style="max-width: 70% !important;">
                                                    <div style="padding: 12px 16px !important; border-radius: 18px !important; font-size: 14px !important; line-height: 1.4 !important; background: #0d6efd !important; color: #fff !important; border-bottom-right-radius: 4px !important; word-break: normal !important; white-space: normal !important;">${'${content}'}</div>
                                                    <div style="font-size: 11px !important; color: #999 !important; margin-top: 4px !important; text-align: right !important;">${'${timestamp}'}</div>
                                                </div>
                                            </div>
                                        `;

                                        chatMessages.insertAdjacentHTML('beforeend', messageHTML);
                                        chatMessages.scrollTop = chatMessages.scrollHeight;
                                    }
                                })
                                .catch(error => console.error('Error:', error));

                            messageInput.value = '';
                        }

                        sendButton.addEventListener('click', sendMessage);
                        messageInput.addEventListener('keypress', function (e) {
                            if (e.key === 'Enter') {
                                e.preventDefault();
                                sendMessage();
                            }
                        });
                    });

                    // Subscribe to WebSocket messages - Subscribe to CURRENT USER's queue
                    if (stompClient && stompClient.connected && partnerUserId) {
                        stompClient.subscribe('/user/' + currentUserId + '/queue/messages', function (message) {
                            try {
                                // Parse the message
                                const messageData = JSON.parse(message.body);

                                // Only show messages from the partner
                                if (messageData.senderUserId !== partnerUserId) {
                                    return;
                                }

                                // Create message element
                                const chatMessages = document.getElementById('chatMessages');
                                if (!chatMessages) return;

                                // Format timestamp - handle both LocalDateTime and millis
                                let timestamp;
                                if (messageData.timestamp) {
                                    // If timestamp is ISO string (LocalDateTime)
                                    if (typeof messageData.timestamp === 'string') {
                                        timestamp = new Date(messageData.timestamp).toLocaleTimeString('vi-VN', {
                                            hour: '2-digit',
                                            minute: '2-digit'
                                        });
                                    } else {
                                        // If timestamp is milliseconds
                                        timestamp = new Date(messageData.timestamp).toLocaleTimeString('vi-VN', {
                                            hour: '2-digit',
                                            minute: '2-digit'
                                        });
                                    }
                                } else {
                                    timestamp = new Date().toLocaleTimeString('vi-VN', {
                                        hour: '2-digit',
                                        minute: '2-digit'
                                    });
                                }

                                // Create message HTML
                                const messageHTML = `
                                    <div style="display: flex !important; margin-bottom: 15px; align-items: flex-start; justify-content: flex-start;">
                                        <div style="max-width: 70% !important;">
                                            <div style="padding: 12px 16px !important; border-radius: 18px !important; font-size: 14px !important; line-height: 1.4 !important; background: #e5e5e5 !important; color: #333 !important; border-bottom-left-radius: 4px !important; word-break: normal !important; white-space: normal !important;">${messageData.content}</div>
                                            <div style="font-size: 11px !important; color: #999 !important; margin-top: 4px !important; text-align: left !important;">${timestamp}</div>
                                        </div>
                                    </div>
                                `;

                                chatMessages.insertAdjacentHTML('beforeend', messageHTML);
                                chatMessages.scrollTop = chatMessages.scrollHeight;
                            } catch (error) {
                                console.error('Error processing message:', error);
                            }
                        });
                    }

                    // Start chat refresh when page loads
                    startChatRefresh();

                    // Stop refresh when page is hidden or user leaves
                    document.addEventListener('visibilitychange', function () {
                        if (document.hidden) {
                            stopChatRefresh();
                        } else {
                            startChatRefresh();
                        }
                    });

                    // Stop refresh when user leaves the page
                    window.addEventListener('beforeunload', function () {
                        stopChatRefresh();
                    });


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

                    // Auto-hide alerts after 5 seconds
                    document.addEventListener('DOMContentLoaded', function () {
                        var alerts = document.querySelectorAll('.alert');
                        alerts.forEach(function (alert) {
                            setTimeout(function () {
                                alert.style.opacity = '0';
                                setTimeout(function () {
                                    alert.remove();
                                }, 300);
                            }, 5000);
                        });
                    });

                    // Table functionality
                    document.addEventListener('DOMContentLoaded', function () {
                        // Initialize table sorting and resizing if table exists
                        var table = document.getElementById('resizableTable');
                        if (table) {
                            initializeTableFeatures();
                        }
                    });

                    function initializeTableFeatures() {
                        // Add sorting functionality
                        var headers = document.querySelectorAll('.resizable-table th.sortable');
                        headers.forEach(function (header, index) {
                            header.addEventListener('click', function () {
                                sortTable(index, this);
                            });
                        });

                        // Add resizing functionality
                        var resizers = document.querySelectorAll('.resizer');
                        resizers.forEach(function (resizer) {
                            resizer.addEventListener('mousedown', function (e) {
                                startResize(e, this);
                            });
                        });
                    }

                    function sortTable(columnIndex, header) {
                        // Basic sorting implementation
                        var table = document.getElementById('resizableTable');
                        var tbody = table.querySelector('tbody');
                        var rows = Array.from(tbody.querySelectorAll('tr'));

                        var isAsc = !header.classList.contains('sort-asc');

                        // Remove existing sort classes
                        document.querySelectorAll('.resizable-table th').forEach(th => {
                            th.classList.remove('sort-asc', 'sort-desc');
                        });

                        // Add current sort class
                        header.classList.add(isAsc ? 'sort-asc' : 'sort-desc');

                        // Sort rows
                        rows.sort(function (a, b) {
                            var aVal = a.cells[columnIndex].textContent.trim();
                            var bVal = b.cells[columnIndex].textContent.trim();

                            if (isAsc) {
                                return aVal > bVal ? 1 : -1;
                            } else {
                                return aVal < bVal ? 1 : -1;
                            } image.png
                        });

                        // Reorder rows
                        rows.forEach(row => tbody.appendChild(row));
                    }

                    function startResize(e, resizer) {
                        e.preventDefault();
                        resizer.classList.add('resizing');

                        var startX = e.clientX;
                        var startWidth = resizer.parentElement.offsetWidth;

                        function doResize(e) {
                            var newWidth = startWidth + e.clientX - startX;
                            resizer.parentElement.style.width = newWidth + 'px';
                        }

                        function stopResize() {
                            resizer.classList.remove('resizing');
                            document.removeEventListener('mousemove', doResize);
                            document.removeEventListener('mouseup', stopResize);
                        }

                        document.addEventListener('mousemove', doResize);
                        document.addEventListener('mouseup', stopResize);
                    }
                </script>
            </body>

            </html>