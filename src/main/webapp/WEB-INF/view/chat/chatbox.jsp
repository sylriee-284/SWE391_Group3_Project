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
                                apiKey: "${firebaseApiKey}",
                                authDomain: "${firebaseAuthDomain}",
                                projectId: "${firebaseProjectId}"
                            };
                        </script>

                        <script>
                            const CONTEXT_PATH = '<c:url value="/" />'.replace(/\/$/, ''); // bỏ dấu / cuối
                            const USER_AVATAR_URL = '<c:url value="/images/chat/mmo-user.jpg" />';
                            const ADMIN_AVATAR_URL = '<c:url value="/images/chat/mmo-avatar.jpg" />';
                        </script>

                        <meta id="me-username" content="${fn:escapeXml(currentUser.username)}" />
                        <c:if test="${not empty chatTo}">
                            <meta id="chat-to-username" content="${fn:escapeXml(chatTo)}" />
                        </c:if>

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
                            let oldestMessageDoc = null; // Document của message cũ nhất đã load
                            let isLoadingMore = false;    // Đang load thêm messages
                            let hasMoreMessages = true;  // Còn messages cũ hơn để load
                            let loadedMessageIds = new Set(); // Track loaded message IDs to prevent duplicates
                            let newestTimestamp = null; // Track newest message timestamp

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
                                    wrap.setAttribute('data-cid', cid); // Thêm data attribute để track
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
                                            // Sort documents by lastMessageAt (desc) để đảm bảo thứ tự đúng
                                            const docs = snap.docs.slice(); // Copy array
                                            docs.sort(function (a, b) {
                                                const aTime = a.data().lastMessageAt;
                                                const bTime = b.data().lastMessageAt;

                                                if (!aTime && !bTime) return 0;
                                                if (!aTime) return 1;
                                                if (!bTime) return -1;

                                                const aTimestamp = aTime.toDate ? aTime.toDate().getTime() : (aTime.getTime ? aTime.getTime() : 0);
                                                const bTimestamp = bTime.toDate ? bTime.toDate().getTime() : (bTime.getTime ? bTime.getTime() : 0);

                                                return bTimestamp - aTimestamp; // Desc order
                                            });

                                            docs.forEach(function (doc) {
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
                                                    // Sort documents by lastMessageAt (desc) vì không có orderBy trong query
                                                    const docs = snap.docs.slice(); // Copy array
                                                    docs.sort(function (a, b) {
                                                        const aTime = a.data().lastMessageAt;
                                                        const bTime = b.data().lastMessageAt;

                                                        if (!aTime && !bTime) return 0;
                                                        if (!aTime) return 1;
                                                        if (!bTime) return -1;

                                                        const aTimestamp = aTime.toDate ? aTime.toDate().getTime() : (aTime.getTime ? aTime.getTime() : 0);
                                                        const bTimestamp = bTime.toDate ? bTime.toDate().getTime() : (bTime.getTime ? bTime.getTime() : 0);

                                                        return bTimestamp - aTimestamp; // Desc order
                                                    });

                                                    docs.forEach(function (doc) {
                                                        listEl.appendChild(renderConvoItem(doc));
                                                    });
                                                }
                                            }).catch(() => {
                                                listEl.innerHTML = '<div style="padding: 20px; text-align: center; color: #f00;">Lỗi tải conversations</div>';
                                            });
                                        } else {
                                            listEl.innerHTML = '<div style="padding: 20px; text-align: center; color: #f00;">Lỗi tải conversations</div>';
                                        }
                                    });

                                    // Sau đó listen real-time updates
                                    unsubConvos = q.onSnapshot(function (snap) {
                                        if (!snap.empty) {
                                            // Sort documents by lastMessageAt (desc) để đảm bảo thứ tự đúng
                                            const docs = snap.docs.slice(); // Copy array
                                            docs.sort(function (a, b) {
                                                const aTime = a.data().lastMessageAt;
                                                const bTime = b.data().lastMessageAt;

                                                if (!aTime && !bTime) return 0;
                                                if (!aTime) return 1;
                                                if (!bTime) return -1;

                                                const aTimestamp = aTime.toDate ? aTime.toDate().getTime() : (aTime.getTime ? aTime.getTime() : 0);
                                                const bTimestamp = bTime.toDate ? bTime.toDate().getTime() : (bTime.getTime ? bTime.getTime() : 0);

                                                return bTimestamp - aTimestamp; // Desc order
                                            });

                                            listEl.innerHTML = '';
                                            docs.forEach(function (doc) {
                                                listEl.appendChild(renderConvoItem(doc));
                                            });
                                        }
                                    }, function (err) {
                                        // Ignore errors vì đã handle ở get() phía trên
                                    });
                                }

                                // ---- Thêm conversation vào danh sách sidebar
                                function addConversationToSidebar(cid) {
                                    // Kiểm tra xem conversation đã có trong sidebar chưa
                                    const existingItem = listEl.querySelector(`[data-cid="${cid}"]`);
                                    if (existingItem) {
                                        return; // Đã có rồi, không cần thêm
                                    }

                                    // Fetch conversation document và thêm vào sidebar
                                    db.collection('conversations').doc(cid).get().then(function (doc) {
                                        if (doc.exists) {
                                            // Xóa message "Chưa có cuộc hội thoại nào" nếu có
                                            const emptyMsg = listEl.querySelector('div[style*="text-align:center"]');
                                            if (emptyMsg) {
                                                emptyMsg.remove();
                                            }

                                            // Render và thêm vào đầu danh sách
                                            const convoItem = renderConvoItem(doc);
                                            convoItem.setAttribute('data-cid', cid);

                                            // Thêm vào đầu danh sách (vì mới nhất)
                                            const firstChild = listEl.firstChild;
                                            if (firstChild && firstChild.classList.contains('contact-item')) {
                                                listEl.insertBefore(convoItem, firstChild);
                                            } else {
                                                listEl.insertBefore(convoItem, listEl.firstChild);
                                            }
                                        }
                                    }).catch(function (err) {
                                        // Nếu không fetch được, chỉ cần refresh toàn bộ danh sách
                                        setTimeout(() => listenConversations(), 500);
                                    });
                                }

                                // ---- Tạo/mở cuộc trò chuyện theo username
                                async function getOrCreateConversationWithUsername(partnerUsername) {
                                    const me = meUsername;
                                    const you = String(partnerUsername || '').toLowerCase();

                                    if (!me || !you || me === you) {
                                        throw new Error('invalid-usernames');
                                    }

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

                                            // Thêm conversation mới vào sidebar ngay lập tức
                                            addConversationToSidebar(cid);
                                        }
                                    } catch (error) {
                                        // Nếu lỗi permissions, thử lại với merge
                                        if (error.code === 'permission-denied') {
                                            await cref.set({
                                                participantsUsernames: [me, you].sort(),
                                                lastMessageAt: firebase.firestore.FieldValue.serverTimestamp()
                                            }, { merge: true });
                                            addConversationToSidebar(cid);
                                        } else {
                                            throw error;
                                        }
                                    }
                                    return cid;
                                }

                                // ---- Render một message thành DOM element
                                function renderMessage(doc) {
                                    const m = doc.data();
                                    const isMe = String(m.senderUsername || '').toLowerCase() === meUsername;

                                    const row = document.createElement('div');
                                    row.className = 'message-row';
                                    row.setAttribute('data-msg-id', doc.id);
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
                                    return row;
                                }

                                // ---- Load thêm messages cũ hơn (20 messages mỗi lần)
                                async function loadMoreMessages() {
                                    if (!activeCid || isLoadingMore || !hasMoreMessages || !oldestMessageDoc) {
                                        return;
                                    }

                                    isLoadingMore = true;
                                    const loadMoreBtn = msgsEl.querySelector('.load-more-btn');
                                    if (loadMoreBtn) {
                                        loadMoreBtn.textContent = 'Đang tải...';
                                        loadMoreBtn.style.pointerEvents = 'none';
                                    }

                                    try {
                                        const q = db.collection('conversations').doc(activeCid)
                                            .collection('messages')
                                            .orderBy('ts', 'desc')
                                            .startAfter(oldestMessageDoc)
                                            .limit(20);

                                        const snap = await q.get();

                                        if (snap.empty) {
                                            hasMoreMessages = false;
                                            if (loadMoreBtn) {
                                                loadMoreBtn.textContent = 'Không còn tin nhắn cũ hơn';
                                                loadMoreBtn.style.opacity = '0.5';
                                                loadMoreBtn.style.cursor = 'default';
                                            }
                                            isLoadingMore = false;
                                            return;
                                        }

                                        // Lưu document cũ nhất mới load được
                                        oldestMessageDoc = snap.docs[snap.docs.length - 1];
                                        if (snap.docs.length < 20) {
                                            hasMoreMessages = false;
                                        }

                                        // Lấy scroll position trước khi thêm messages
                                        const scrollBefore = msgsEl.scrollHeight - msgsEl.scrollTop;
                                        const firstMsgRow = msgsEl.querySelector('.message-row');

                                        // Thêm messages cũ vào đầu (theo thứ tự cũ → mới)
                                        for (let i = snap.docs.length - 1; i >= 0; i--) {
                                            const doc = snap.docs[i];
                                            loadedMessageIds.add(doc.id); // Track loaded message ID
                                            const msgRow = renderMessage(doc);
                                            if (firstMsgRow) {
                                                msgsEl.insertBefore(msgRow, firstMsgRow);
                                            } else {
                                                msgsEl.insertBefore(msgRow, msgsEl.firstChild);
                                            }
                                        }

                                        // Restore scroll position
                                        msgsEl.scrollTop = msgsEl.scrollHeight - scrollBefore;

                                        // Update button
                                        if (loadMoreBtn) {
                                            if (hasMoreMessages) {
                                                loadMoreBtn.textContent = 'Tải thêm tin nhắn cũ';
                                            } else {
                                                loadMoreBtn.textContent = 'Đã tải hết tin nhắn';
                                                loadMoreBtn.style.opacity = '0.5';
                                                loadMoreBtn.style.cursor = 'default';
                                            }
                                            loadMoreBtn.style.pointerEvents = 'auto';
                                        }
                                    } catch (error) {
                                        if (loadMoreBtn) {
                                            loadMoreBtn.textContent = 'Lỗi tải tin nhắn. Nhấn để thử lại';
                                            loadMoreBtn.style.pointerEvents = 'auto';
                                        }
                                    } finally {
                                        isLoadingMore = false;
                                    }
                                }

                                // ---- Chọn conversation & nghe messages
                                function selectConversation(cid) {
                                    activeCid = cid;
                                    if (unsubMsgs) unsubMsgs();
                                    enableComposer(true);

                                    // Reset pagination state
                                    oldestMessageDoc = null;
                                    isLoadingMore = false;
                                    hasMoreMessages = true;

                                    // header
                                    db.collection('conversations').doc(cid).get().then(function (s) {
                                        const d = s.data() || {};
                                        const other = otherOf(d.participantsUsernames, meUsername);
                                        const verifiedBadge = (other === 'admin') ? '<svg width="18" height="18" viewBox="0 0 24 24" fill="#0d6efd" style="vertical-align: middle; margin-left: 6px;"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"/></svg>' : '';
                                        titleEl.innerHTML = '@' + other + verifiedBadge;
                                    });

                                    msgsEl.innerHTML = '<div style="color:#999;padding:12px">Đang tải…</div>';

                                    // Load 20 messages mới nhất ban đầu (orderBy desc)
                                    const initialQuery = db.collection('conversations').doc(cid)
                                        .collection('messages')
                                        .orderBy('ts', 'desc')
                                        .limit(20);

                                    // Reset loaded message IDs
                                    loadedMessageIds.clear();
                                    newestTimestamp = null;

                                    initialQuery.get().then(async function (snap) {
                                        msgsEl.innerHTML = '';

                                        if (snap.empty) {
                                            msgsEl.innerHTML = '<div style="text-align:center; padding: 20px; color:#999;">Chưa có tin nhắn nào</div>';
                                            // Setup real-time listener even when empty
                                            setupRealtimeListener(cid, null);
                                            return;
                                        }

                                        // Lưu document cũ nhất đã load
                                        oldestMessageDoc = snap.docs[snap.docs.length - 1];
                                        if (snap.docs.length < 20) {
                                            hasMoreMessages = false;
                                        }

                                        // Lưu timestamp của message mới nhất
                                        newestTimestamp = snap.docs[0].data().ts;

                                        // Thêm nút "Tải thêm" ở đầu nếu còn messages cũ hơn
                                        if (hasMoreMessages) {
                                            const loadMoreBtn = document.createElement('button');
                                            loadMoreBtn.className = 'load-more-btn';
                                            loadMoreBtn.type = 'button';
                                            loadMoreBtn.style.cssText = 'width:100%;padding:10px;margin-bottom:10px;background:#f0f0f0;border:1px solid #ddd;border-radius:5px;color:#0d6efd;cursor:pointer;font-size:14px;';
                                            loadMoreBtn.textContent = 'Tải thêm tin nhắn cũ';
                                            loadMoreBtn.onclick = loadMoreMessages;
                                            msgsEl.appendChild(loadMoreBtn);
                                        }

                                        // Render messages từ cũ → mới (reverse để hiển thị đúng thứ tự)
                                        for (let i = snap.docs.length - 1; i >= 0; i--) {
                                            const doc = snap.docs[i];
                                            loadedMessageIds.add(doc.id); // Track loaded message ID
                                            const msgRow = renderMessage(doc);
                                            msgsEl.appendChild(msgRow);
                                        }

                                        // Scroll xuống cuối
                                        setTimeout(() => {
                                            msgsEl.scrollTop = msgsEl.scrollHeight;
                                        }, 100);

                                        // mark read
                                        db.collection('conversations').doc(cid)
                                            .set({ lastSeenAt: (function (o) { o[meUsername] = firebase.firestore.FieldValue.serverTimestamp(); return o; })({}) }, { merge: true }).catch(() => { });

                                        // Setup real-time listener
                                        setupRealtimeListener(cid, newestTimestamp);
                                    }).catch(function (err) {
                                        msgsEl.innerHTML = '<div style="text-align:center; padding: 20px; color:#f00;">Lỗi tải tin nhắn</div>';
                                    });

                                    // Helper function to setup real-time listener
                                    function setupRealtimeListener(cid, baseTimestamp) {
                                        if (unsubMsgs) {
                                            unsubMsgs();
                                        }

                                        if (baseTimestamp) {
                                            // Query cho messages mới hơn message mới nhất
                                            const realtimeQuery = db.collection('conversations').doc(cid)
                                                .collection('messages')
                                                .where('ts', '>', baseTimestamp)
                                                .orderBy('ts', 'asc')
                                                .limit(50);

                                            unsubMsgs = realtimeQuery.onSnapshot(async function (newSnap) {
                                                if (!newSnap.empty) {
                                                    let shouldScroll = false;
                                                    newSnap.forEach(function (doc) {
                                                        // Double check: both Set and DOM
                                                        if (!loadedMessageIds.has(doc.id)) {
                                                            const existingRow = msgsEl.querySelector(`[data-msg-id="${doc.id}"]`);
                                                            if (!existingRow) {
                                                                loadedMessageIds.add(doc.id); // Add to Set
                                                                const msgRow = renderMessage(doc);
                                                                msgsEl.appendChild(msgRow);
                                                                shouldScroll = true;

                                                                // Update newestTimestamp
                                                                const msgTimestamp = doc.data().ts;
                                                                if (!newestTimestamp || msgTimestamp > newestTimestamp) {
                                                                    newestTimestamp = msgTimestamp;
                                                                }
                                                            }
                                                        }
                                                    });

                                                    // Always scroll to bottom when new message arrives
                                                    if (shouldScroll) {
                                                        setTimeout(() => {
                                                            msgsEl.scrollTop = msgsEl.scrollHeight;
                                                        }, 100);
                                                    }
                                                }

                                                // mark read
                                                db.collection('conversations').doc(cid)
                                                    .set({ lastSeenAt: (function (o) { o[meUsername] = firebase.firestore.FieldValue.serverTimestamp(); return o; })({}) }, { merge: true }).catch(() => { });
                                            }, function (err) {
                                                // Fallback: listen to all messages and filter
                                                if (err.code === 'failed-precondition') {
                                                    const fallbackQuery = db.collection('conversations').doc(cid)
                                                        .collection('messages')
                                                        .orderBy('ts', 'desc')
                                                        .limit(50);

                                                    unsubMsgs = fallbackQuery.onSnapshot(async function (fallbackSnap) {
                                                        if (!fallbackSnap.empty) {
                                                            let shouldScroll = false;
                                                            fallbackSnap.forEach(function (doc) {
                                                                const docTimestamp = doc.data().ts;
                                                                // Only add if newer than baseTimestamp
                                                                if ((!baseTimestamp || (docTimestamp && docTimestamp > baseTimestamp))
                                                                    && !loadedMessageIds.has(doc.id)) {
                                                                    const existingRow = msgsEl.querySelector(`[data-msg-id="${doc.id}"]`);
                                                                    if (!existingRow) {
                                                                        loadedMessageIds.add(doc.id);
                                                                        const msgRow = renderMessage(doc);
                                                                        // Insert at correct position (newer messages go to end)
                                                                        msgsEl.appendChild(msgRow);
                                                                        shouldScroll = true;

                                                                        if (!newestTimestamp || docTimestamp > newestTimestamp) {
                                                                            newestTimestamp = docTimestamp;
                                                                        }
                                                                    }
                                                                }
                                                            });

                                                            if (shouldScroll) {
                                                                setTimeout(() => {
                                                                    msgsEl.scrollTop = msgsEl.scrollHeight;
                                                                }, 100);
                                                            }
                                                        }

                                                        db.collection('conversations').doc(cid)
                                                            .set({ lastSeenAt: (function (o) { o[meUsername] = firebase.firestore.FieldValue.serverTimestamp(); return o; })({}) }, { merge: true }).catch(() => { });
                                                    }, function (fallbackErr) { });
                                                }
                                            });
                                        } else {
                                            // No base timestamp - listen to all messages
                                            const realtimeQuery = db.collection('conversations').doc(cid)
                                                .collection('messages')
                                                .orderBy('ts', 'asc')
                                                .limit(50);

                                            unsubMsgs = realtimeQuery.onSnapshot(async function (newSnap) {
                                                if (!newSnap.empty) {
                                                    let shouldScroll = false;
                                                    newSnap.forEach(function (doc) {
                                                        if (!loadedMessageIds.has(doc.id)) {
                                                            const existingRow = msgsEl.querySelector(`[data-msg-id="${doc.id}"]`);
                                                            if (!existingRow) {
                                                                loadedMessageIds.add(doc.id);

                                                                // Remove "Chưa có tin nhắn nào" message if exists
                                                                const emptyMsg = msgsEl.querySelector('div[style*="text-align:center"]');
                                                                if (emptyMsg) {
                                                                    emptyMsg.remove();
                                                                }

                                                                const msgRow = renderMessage(doc);
                                                                msgsEl.appendChild(msgRow);
                                                                shouldScroll = true;

                                                                const msgTimestamp = doc.data().ts;
                                                                if (!newestTimestamp || msgTimestamp > newestTimestamp) {
                                                                    newestTimestamp = msgTimestamp;
                                                                }
                                                            }
                                                        }
                                                    });

                                                    if (shouldScroll) {
                                                        setTimeout(() => {
                                                            msgsEl.scrollTop = msgsEl.scrollHeight;
                                                        }, 100);
                                                    }
                                                }

                                                db.collection('conversations').doc(cid)
                                                    .set({ lastSeenAt: (function (o) { o[meUsername] = firebase.firestore.FieldValue.serverTimestamp(); return o; })({}) }, { merge: true }).catch(() => { });
                                            }, function (err) { });
                                        }
                                    }
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

                                        // Force scroll to bottom after sending
                                        setTimeout(() => {
                                            msgsEl.scrollTop = msgsEl.scrollHeight;
                                        }, 100);

                                        // Refresh conversation list to show new message
                                        listenConversations();
                                    } catch (e) {
                                        alert('Gửi thất bại: ' + (e && e.message ? e.message : e));
                                    }
                                }

                                // ---- Liên hệ Admin
                                async function openAdminChat() {
                                    const cid = await getOrCreateConversationWithUsername('admin');
                                    selectConversation(cid);
                                }

                                // ---- Wire UI
                                enableComposer(false);
                                sendBtn.addEventListener('click', function (e) { e.preventDefault(); sendMessage(); });
                                inputEl.addEventListener('keydown', function (e) { if (e.key === 'Enter' && !e.shiftKey) { e.preventDefault(); sendMessage(); } });
                                adminBtn && adminBtn.addEventListener('click', openAdminChat);

                                // ---- Start
                                listenConversations();

                                // ---- Auto-open conversation if chatTo parameter is present
                                const chatToMeta = document.getElementById('chat-to-username');
                                if (chatToMeta && chatToMeta.content) {
                                    const chatToUsername = String(chatToMeta.content).trim().toLowerCase();

                                    if (chatToUsername && chatToUsername !== meUsername) {
                                        // Function to auto-open conversation with retry logic
                                        async function autoOpenChat() {
                                            // Wait for Firebase auth to be ready
                                            let authReady = false;
                                            let retryCount = 0;
                                            const maxRetries = 15;

                                            while (!authReady && retryCount < maxRetries) {
                                                if (auth.currentUser) {
                                                    authReady = true;
                                                } else {
                                                    retryCount++;
                                                    await new Promise(resolve => setTimeout(resolve, 300));
                                                }
                                            }

                                            try {
                                                const cid = await getOrCreateConversationWithUsername(chatToUsername);

                                                // Wait a bit for conversation to be saved
                                                await new Promise(resolve => setTimeout(resolve, 500));

                                                // Verify conversation exists
                                                const convRef = db.collection('conversations').doc(cid);
                                                const convSnap = await convRef.get();

                                                if (convSnap.exists) {
                                                    selectConversation(cid);
                                                } else {
                                                    // Retry once more
                                                    setTimeout(async () => {
                                                        try {
                                                            const newCid = await getOrCreateConversationWithUsername(chatToUsername);
                                                            await new Promise(resolve => setTimeout(resolve, 500));
                                                            selectConversation(newCid);
                                                        } catch (e2) { }
                                                    }, 1000);
                                                }
                                            } catch (e) {
                                                // Retry after delay
                                                setTimeout(async () => {
                                                    try {
                                                        const cid = await getOrCreateConversationWithUsername(chatToUsername);
                                                        await new Promise(resolve => setTimeout(resolve, 500));
                                                        selectConversation(cid);
                                                    } catch (e2) { }
                                                }, 2000);
                                            }
                                        }

                                        // Start auto-open after initial delay
                                        setTimeout(() => {
                                            autoOpenChat();
                                        }, 800);
                                    }
                                }
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
                        </script>
                    </body>

                    </html>