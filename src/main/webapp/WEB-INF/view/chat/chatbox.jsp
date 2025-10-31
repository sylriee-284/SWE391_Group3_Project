<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
            <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
                <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

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
                        <!-- Firebase App (core) -->
                        <script src="https://www.gstatic.com/firebasejs/9.6.10/firebase-app-compat.js"></script>
                        <!-- Firebase Firestore -->
                        <script src="https://www.gstatic.com/firebasejs/9.6.10/firebase-firestore-compat.js"></script>

                        <script src="https://ajax.googleapis.com/ajax/libs/jquery/2.2.0/jquery.min.js"></script>

                        <!-- Firebase Auth -->
                        <script src="https://www.gstatic.com/firebasejs/9.6.10/firebase-auth-compat.js"></script>

                        <script>
                            const firebaseConfig = {
                                apiKey: "AIzaSyDenK3979rENG3vgxb3MlynYZqLzyZfV_A",
                                authDomain: "mmo-market-system.firebaseapp.com",
                                projectId: "mmo-market-system"
                            };
                        </script>

                        <script>
                            const CONTEXT_PATH = '<c:url value="/" />'.replace(/\/$/, ''); // bỏ dấu / cuối
                            const USER_AVATAR_URL = '<c:url value="/images/chat/mmo-user.jpg" />';
                            const ADMIN_AVATAR_URL = '<c:url value="/images/chat/mmo-avatar.jpg" />';
                        </script>

                        <meta id="me-username" content="${fn:escapeXml(currentUser.username)}" />

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
                                        <h3>Gần đây</h3>
                                    </div>

                                    <!-- Contact Items (filled by JS) -->
                                    <div class="contact-items" id="convos">
                                        <!-- JS sẽ đổ danh sách conversations vào đây -->
                                    </div>

                                    <!-- Contact Admin Button (by username) -->
                                    <button type="button" class="contact-admin-btn" id="contactAdminBtn"
                                        aria-label="Liên hệ Admin">
                                        <svg width="24" height="24" viewBox="0 0 24 24" fill="none"
                                            stroke="currentColor" stroke-width="2" aria-hidden="true">
                                            <path
                                                d="M21 11.5a8.38 8.38 0 0 1-.9 3.8 8.5 8.5 0 0 1-7.6 4.7 8.38 8.38 0 0 1-3.8-.9L3 21l1.9-5.7a8.38 8.38 0 0 1-.9-3.8 8.5 8.5 0 0 1 4.7-7.6 8.38 8.38 0 0 1 3.8-.9h.5a8.48 8.48 0 0 1 8 8v.5z" />
                                            <circle cx="8" cy="13" r="1" fill="currentColor" />
                                            <circle cx="12" cy="13" r="1" fill="currentColor" />
                                            <circle cx="16" cy="13" r="1" fill="currentColor" />
                                        </svg>
                                        <span class="admin-btn-label">Liên hệ Admin</span>
                                    </button>
                                </div>

                                <!-- Right Column - Chat Area -->
                                <div class="chat-area">
                                    <!-- Chat Header -->
                                    <div class="chat-header">
                                        <h4 id="chatTitleDyn">Select a conversation</h4>
                                    </div>

                                    <!-- Chat Messages -->
                                    <div class="chat-messages" id="chatMessagesDyn">
                                        <div style="text-align:center; padding: 20px; color:#999;">
                                            Hãy chọn một cuộc hội thoại hoặc nhấn “Liên hệ Admin”
                                        </div>
                                    </div>

                                    <!-- Chat Input Area -->
                                    <div class="chat-input-area">
                                        <div class="chat-input-row">
                                            <input type="text" class="chat-input" id="messageInputDyn"
                                                placeholder="Type a message" maxlength="2000" disabled />
                                            <button class="send-button" id="sendButtonDyn" disabled>
                                                <i class="fas fa-paper-plane"></i>
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            </div>

                        </div>

                        <script>
                            // ========= 1) INIT =========
                            if (!window.firebase) { alert('Firebase SDK chưa được nhúng'); }
                            if (!firebase.apps.length) firebase.initializeApp(firebaseConfig);
                            const auth = firebase.auth();
                            const db = firebase.firestore();

                            // ========= 2) HELPERS =========
                            const esc = (s) => String(s || "").replace(/[&<>"']/g, m => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#039;' }[m]));
                            const cidOf = (a, b) => [String(a).toLowerCase(), String(b).toLowerCase()].sort().join('_');
                            const otherOf = (arr, me) => (arr || []).find(u => String(u).toLowerCase() !== String(me).toLowerCase()) || "unknown";

                            // Các biến toàn cục tối thiểu
                            let meUsername = '';
                            let activeCid = null;
                            let unsubConvos = null;
                            let unsubMsgs = null;

                            // ====== HÀM CHÍNH, CHỈ CHẠY SAU KHI DOM SẴN SÀNG ======
                            async function boot() {
                                // ---- Lấy refs
                                const listEl = document.getElementById('convos');           // sidebar conversations
                                const titleEl = document.getElementById('chatTitleDyn');     // header title
                                const msgsEl = document.getElementById('chatMessagesDyn');  // messages pane
                                const inputEl = document.getElementById('messageInputDyn');  // input
                                const sendBtn = document.getElementById('sendButtonDyn');    // send button
                                const adminBtn = document.getElementById('contactAdminBtn');  // "Liên hệ Admin"

                                // Bảo vệ: nếu thiếu phần tử UI
                                if (!listEl || !titleEl || !msgsEl || !inputEl || !sendBtn) {
                                    return;
                                }

                                // ---- Tiện ích UI
                                function enableComposer(on) {
                                    inputEl.disabled = !on;
                                    sendBtn.disabled = !on;
                                }

                                // ---- Hiển thị loading state ngay lập tức
                                listEl.innerHTML = '<div style="padding: 20px; text-align: center; color: #999;">Đang tải...</div>';

                                // ---- Lấy username từ meta #me-username
                                const meta = document.getElementById('me-username');
                                const fromJsp = (meta && meta.content ? meta.content : '').trim();
                                if (!fromJsp) {
                                    alert('Thiếu currentUser.username (meta #me-username).'); throw new Error('missing-username');
                                }
                                meUsername = fromJsp.toLowerCase();

                                // ---- Đăng nhập ẩn danh (nếu chưa đăng nhập)
                                if (!auth.currentUser) {
                                    await auth.signInAnonymously();
                                }

                                // ---- Render 1 item hội thoại
                                function renderConvoItem(doc) {
                                    const data = doc.data();
                                    const cid = doc.id;
                                    const other = otherOf(data.participantsUsernames, meUsername);
                                    const time = (data.lastMessageAt && data.lastMessageAt.toDate) ? data.lastMessageAt.toDate().toLocaleString() : '';
                                    const avatarUrl = (other === 'admin') ? ADMIN_AVATAR_URL : USER_AVATAR_URL;

                                    const verifiedBadge = (other === 'admin') ? '<svg width="16" height="16" viewBox="0 0 24 24" fill="#0d6efd" style="vertical-align: middle; margin-left: 4px;"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"/></svg>' : '';
                                    const wrap = document.createElement('div');
                                    wrap.className = 'contact-item';
                                    wrap.style.cursor = 'pointer';
                                    wrap.innerHTML =
                                        '<img src="' + avatarUrl + '" alt="' + esc(other) + '" class="contact-avatar">' +
                                        '<div class="contact-info">' +
                                        '<div class="contact-name-row"><span class="contact-name">@' + esc(other) + verifiedBadge + '</span></div>' +
                                        '<div class="contact-preview">' + esc(data.lastMessagePreview || '') + '</div>' +
                                        '<div class="contact-date">' + esc(time) + '</div>' +
                                        '</div>';

                                    wrap.onclick = function () { selectConversation(cid); };
                                    return wrap;
                                }

                                // ---- Lắng nghe danh sách hội thoại
                                function listenConversations() {
                                    if (unsubConvos) unsubConvos();
                                    if (!meUsername) return;

                                    const q = db.collection('conversations')
                                        .where('participantsUsernames', 'array-contains', meUsername)
                                        .orderBy('lastMessageAt', 'desc')
                                        .limit(50);

                                    // Load nhanh bằng get() trước, sau đó listen updates bằng onSnapshot
                                    q.get().then(function (snap) {
                                        listEl.innerHTML = '';
                                        if (snap.empty) {
                                            listEl.innerHTML = '<div style="padding: 20px; text-align: center; color: #999;">Chưa có cuộc hội thoại nào</div>';
                                        } else {
                                            snap.forEach(function (doc) {
                                                listEl.appendChild(renderConvoItem(doc));
                                            });
                                        }
                                    }).catch(function (err) {
                                        // Nếu lỗi do thiếu index, thử query không có orderBy
                                        if (err.code === 'failed-precondition') {
                                            const simpleQ = db.collection('conversations')
                                                .where('participantsUsernames', 'array-contains', meUsername)
                                                .limit(50);
                                            simpleQ.get().then(function (snap) {
                                                listEl.innerHTML = '';
                                                if (snap.empty) {
                                                    listEl.innerHTML = '<div style="padding: 20px; text-align: center; color: #999;">Chưa có cuộc hội thoại nào</div>';
                                                } else {
                                                    snap.forEach(function (doc) {
                                                        listEl.appendChild(renderConvoItem(doc));
                                                    });
                                                }
                                            }).catch(function (e) {
                                                listEl.innerHTML = '<div style="padding: 20px; text-align: center; color: #f00;">Lỗi tải conversations</div>';
                                            });
                                        } else {
                                            listEl.innerHTML = '<div style="padding: 20px; text-align: center; color: #f00;">Lỗi tải conversations</div>';
                                        }
                                    });

                                    // Sau đó listen real-time updates
                                    unsubConvos = q.onSnapshot(function (snap) {
                                        if (!snap.empty) {
                                            listEl.innerHTML = '';
                                            snap.forEach(function (doc) {
                                                listEl.appendChild(renderConvoItem(doc));
                                            });
                                        }
                                    }, function (err) {
                                        // Ignore errors vì đã handle ở get() phía trên
                                    });
                                }

                                // ---- Tạo/mở cuộc trò chuyện theo username
                                async function getOrCreateConversationWithUsername(partnerUsername) {
                                    const me = meUsername;
                                    const you = String(partnerUsername || '').toLowerCase();
                                    if (!me || !you || me === you) throw new Error('invalid-usernames');

                                    const cid = cidOf(me, you);
                                    const cref = db.collection('conversations').doc(cid);

                                    try {
                                        const snap = await cref.get();
                                        if (!snap.exists) {
                                            // Tạo conversation mới
                                            await cref.set({
                                                participantsUsernames: [me, you].sort(),
                                                createdAt: firebase.firestore.FieldValue.serverTimestamp(),
                                                lastMessageAt: firebase.firestore.FieldValue.serverTimestamp(),
                                                lastMessageId: '',
                                                lastSenderUsername: '',
                                                lastMessagePreview: '',
                                                lastSeenAt: (function (o) { o[me] = firebase.firestore.FieldValue.serverTimestamp(); return o; })({})
                                            });
                                        }
                                    } catch (error) {
                                        // Nếu lỗi permissions, thử lại với merge
                                        if (error.code === 'permission-denied') {
                                            try {
                                                await cref.set({
                                                    participantsUsernames: [me, you].sort(),
                                                    lastMessageAt: firebase.firestore.FieldValue.serverTimestamp()
                                                }, { merge: true });
                                            } catch (mergeError) {
                                                throw new Error('Không thể tạo conversation. Kiểm tra Firebase Security Rules.');
                                            }
                                        } else {
                                            throw error;
                                        }
                                    }
                                    return cid;
                                }

                                // ---- Chọn conversation & nghe messages
                                function selectConversation(cid) {
                                    activeCid = cid;
                                    if (unsubMsgs) unsubMsgs();
                                    enableComposer(true);

                                    // header
                                    db.collection('conversations').doc(cid).get().then(function (s) {
                                        const d = s.data() || {};
                                        const other = otherOf(d.participantsUsernames, meUsername);
                                        const verifiedBadge = (other === 'admin') ? '<svg width="18" height="18" viewBox="0 0 24 24" fill="#0d6efd" style="vertical-align: middle; margin-left: 6px;"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"/></svg>' : '';
                                        titleEl.innerHTML = '@' + other + verifiedBadge;
                                    });

                                    msgsEl.innerHTML = '<div style="color:#999;padding:12px">Đang tải…</div>';

                                    const q = db.collection('conversations').doc(cid)
                                        .collection('messages').orderBy('ts', 'asc').limit(200);

                                    unsubMsgs = q.onSnapshot(async function (snap) {
                                        msgsEl.innerHTML = '';
                                        snap.forEach(function (doc) {
                                            const m = doc.data();
                                            const isMe = String(m.senderUsername || '').toLowerCase() === meUsername;

                                            const row = document.createElement('div');
                                            row.style.cssText = 'display:flex;margin-bottom:15px;align-items:flex-start;justify-content:' + (isMe ? 'flex-end' : 'flex-start') + ';';

                                            const col = document.createElement('div');
                                            col.style.maxWidth = '70%';

                                            const bubble = document.createElement('div');
                                            bubble.style.cssText =
                                                'padding:12px 16px;border-radius:18px;font-size:14px;line-height:1.4;' +
                                                'background:' + (isMe ? '#0d6efd' : '#e5e5e5') + ';color:' + (isMe ? '#fff' : '#333') + ';' +
                                                (isMe ? 'border-bottom-right-radius:4px;' : 'border-bottom-left-radius:4px;') +
                                                'white-space:pre-wrap;word-break:break-word;';
                                            bubble.textContent = m.text || '';

                                            const meta = document.createElement('div');
                                            meta.style.cssText = 'font-size:11px;color:#999;margin-top:4px;text-align:' + (isMe ? 'right' : 'left') + ';';
                                            meta.textContent = (m.ts && m.ts.toDate) ? m.ts.toDate().toLocaleString() : '';

                                            col.appendChild(bubble);
                                            col.appendChild(meta);
                                            row.appendChild(col);
                                            msgsEl.appendChild(row);
                                        });
                                        msgsEl.scrollTop = msgsEl.scrollHeight;

                                        // mark read
                                        try {
                                            await db.collection('conversations').doc(cid)
                                                .set({ lastSeenAt: (function (o) { o[meUsername] = firebase.firestore.FieldValue.serverTimestamp(); return o; })({}) }, { merge: true });
                                        } catch (e) { }
                                    }, function (err) { });
                                }

                                // ---- Gửi message (text-only)
                                async function sendMessage() {
                                    if (!activeCid) return;
                                    const t = (inputEl.value || '').trim();
                                    if (!t) return;

                                    const cref = db.collection('conversations').doc(activeCid);
                                    const mref = cref.collection('messages').doc();
                                    const preview = t.length > 120 ? t.slice(0, 120) + '…' : t;

                                    const batch = db.batch();
                                    batch.set(mref, {
                                        text: t,
                                        senderUsername: meUsername,
                                        ts: firebase.firestore.FieldValue.serverTimestamp()
                                    });
                                    batch.set(cref, {
                                        lastMessageAt: firebase.firestore.FieldValue.serverTimestamp(),
                                        lastSenderUsername: meUsername,
                                        lastMessageId: mref.id,
                                        lastMessagePreview: preview
                                    }, { merge: true });

                                    try {
                                        await batch.commit();
                                        inputEl.value = '';
                                        inputEl.focus();
                                    } catch (e) {
                                        alert('Gửi thất bại: ' + (e && e.message ? e.message : e));
                                    }
                                }

                                // ---- Liên hệ Admin
                                async function openAdminChat() {
                                    try {
                                        const cid = await getOrCreateConversationWithUsername('admin');
                                        selectConversation(cid);
                                    } catch (e) {
                                        alert('Không thể mở chat với admin: ' + (e && e.message ? e.message : e));
                                    }
                                }

                                // ---- Wire UI
                                enableComposer(false);
                                sendBtn.addEventListener('click', function (e) { e.preventDefault(); sendMessage(); });
                                inputEl.addEventListener('keydown', function (e) { if (e.key === 'Enter' && !e.shiftKey) { e.preventDefault(); sendMessage(); } });
                                adminBtn && adminBtn.addEventListener('click', openAdminChat);

                                // ---- Start
                                listenConversations();
                            }

                            // Chạy sau khi DOM sẵn sàng
                            document.addEventListener('DOMContentLoaded', function () {
                                // Đăng nhập anonymous và khởi động boot song song
                                const signInPromise = auth.signInAnonymously().catch(e => {
                                    alert('Không thể khởi tạo chat: ' + (e?.message || e));
                                });

                                // Khởi động boot ngay, không cần chờ signIn (vì boot() không cần await signIn nữa)
                                signInPromise.then(() => boot());
                            });
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
                                    }
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