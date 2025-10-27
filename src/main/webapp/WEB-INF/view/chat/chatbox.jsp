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
                                <span class="collapse-icon">❮❮</span>
                            </div>

                            <!-- Contact Items -->
                            <div class="contact-items">
                                <!-- Active Contact -->
                                <div class="contact-item active">
                                    <img src="${pageContext.request.contextPath}/images/chat/mmo-user.jpg" alt="toannx"
                                        class="contact-avatar">
                                    <div class="contact-info">
                                        <div class="contact-name-row">
                                            <span class="contact-name">toannx</span>
                                        </div>
                                        <div class="contact-preview">oki</div>
                                        <div class="contact-date">24/10/2025</div>
                                    </div>
                                </div>

                                <!-- Platform Contact -->
                                <div class="contact-item">
                                    <img src="${pageContext.request.contextPath}/images/chat/mmo-avatar.jpg"
                                        alt="taphoammo" class="contact-avatar">
                                    <div class="contact-info">
                                        <div class="contact-name-row">
                                            <span class="contact-name">MMO Market System</span>
                                        </div>
                                        <div class="contact-preview">Chào mừng bạn đến với taphoammo. Mình có thể hỗ trợ
                                            gì cho bạn?</div>
                                        <div class="contact-date">15/10/2025</div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Right Column - Chat Area -->
                        <div class="chat-area">
                            <!-- Chat Header -->
                            <div class="chat-header">
                                <h4>
                                    @toannx <span class="online-status">Online 33 phút trước</span>
                                </h4>
                            </div>

                            <!-- Chat Messages -->
                            <div class="chat-messages" id="chatMessages">
                                <!-- Message 1 - Received -->
                                <div class="message message-received">
                                    <div>
                                        <div class="message-content">
                                            copy bắt đầu từ [{... nhé bạn
                                        </div>
                                        <div class="message-time">20:57 - 24/10</div>
                                    </div>
                                </div>

                                <!-- Message 2 - Sent -->
                                <div class="message message-sent">
                                    <div>
                                        <div class="message-content">
                                            là có lấy cả 2 cái đó ạ
                                        </div>
                                        <div class="message-time">20:58 - 24/10</div>
                                    </div>
                                </div>

                                <!-- Message 3 - Received -->
                                <div class="message message-received">
                                    <div>
                                        <div class="message-content">
                                            đợi mình check nhé
                                        </div>
                                        <div class="message-time">20:59 - 24/10</div>
                                    </div>
                                </div>

                                <!-- Message 4 - Received -->
                                <div class="message message-received">
                                    <div>
                                        <div class="message-content">
                                            vẫn bình thường bạn ơi
                                        </div>
                                        <div class="message-time">21:10 - 24/10</div>
                                    </div>
                                </div>

                                <!-- Message 5 - Received -->
                                <div class="message message-received">
                                    <div>
                                        <div class="message-content">
                                            bạn clear cache ở cursor trước nhé
                                        </div>
                                        <div class="message-time">21:10 - 24/10</div>
                                    </div>
                                </div>

                                <!-- Message 6 - Sent -->
                                <div class="message message-sent">
                                    <div>
                                        <div class="message-content">
                                            oki
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