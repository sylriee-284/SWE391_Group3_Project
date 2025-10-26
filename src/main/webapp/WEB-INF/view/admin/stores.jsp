<%@ page contentType="text/html; charset=UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
                <!DOCTYPE html>
                <html lang="vi">

                <head>
                    <meta charset="UTF-8" />
                    <meta name="viewport" content="width=device-width, initial-scale=1" />
                    <title>Quản lý cửa hàng - MMO Market System</title>

                    <jsp:include page="/WEB-INF/view/common/head.jsp" />
                    <link rel="stylesheet" href="<c:url value='/resources/css/products.css'/>">
                    <meta name="_csrf_header" content="${_csrf.headerName}" />
                    <meta name="_csrf" content="${_csrf.token}" />

                    <style>
                        .badge-status {
                            font-weight: 600;
                        }

                        .btn-chip {
                            display: inline-flex;
                            align-items: center;
                            gap: .35rem;
                            padding: .4rem .65rem;
                            border-radius: 999px;
                            border: 1px solid transparent;
                        }

                        .btn-chip i {
                            font-size: 1rem;
                        }

                        .chip-info {
                            background: #0d6efd;
                            border-color: #0d6efd;
                            color: #fff;
                        }

                        .chip-ban {
                            background: #fff;
                            border: 1px solid #dc3545;
                            color: #dc3545;
                        }

                        .chip-on {
                            background: #198754;
                            border-color: #198754;
                            color: #fff;
                        }

                        .chip-dark {
                            background: #fd7e14;
                            border-color: #fd7e14;
                            color: #fff;
                        }

                        .actions {
                            display: flex;
                            gap: .4rem;
                            justify-content: flex-end;
                            flex-wrap: wrap;
                        }

                        /* Filter: cao đều & đủ rộng cho chữ */
                        .filter .form-control,
                        .filter .form-select {
                            height: 42px;
                        }

                        .filter .col-status {
                            min-width: 260px;
                        }

                        /* đủ để hiển thị “-- Tất cả trạng thái --” */
                        .filter .col-date {
                            min-width: 170px;
                        }

                        /* Bảng + sort/resize */
                        .resizer {
                            width: 6px;
                            cursor: col-resize;
                            position: absolute;
                            right: 0;
                            top: 0;
                            bottom: 0;
                        }

                        th.sortable {
                            position: relative;
                            user-select: none;
                        }

                        .table-hover tbody tr:hover {
                            background: rgba(13, 110, 253, .06);
                        }

                        /* Dropdown trượt nhẹ */
                        .dropdown-menu.slide {
                            transform-origin: top right;
                            animation: dd-slide .16s ease;
                        }

                        @keyframes dd-slide {
                            from {
                                opacity: 0;
                                transform: translateY(-4px) scale(.98);
                            }

                            to {
                                opacity: 1;
                                transform: translateY(0) scale(1);
                            }
                        }

                        /* panel trượt cho đổi trạng thái */
                        .status-pop-wrap {
                            position: relative;
                            display: inline-block;
                        }

                        .status-pop {
                            position: absolute;
                            right: 0;
                            top: 100%;
                            margin-top: 8px;
                            display: none;
                            gap: 6px;
                            white-space: nowrap;
                            background: #fff;
                            padding: 8px;
                            border-radius: 12px;
                            box-shadow: 0 12px 28px rgba(0, 0, 0, .14);
                            z-index: 2000;
                            /* đè lên các hàng khác */
                        }

                        .status-pop.open {
                            display: flex;
                        }

                        /* chip màu cho 3 trạng thái */
                        .chip-active {
                            background: #198754;
                            border-color: #198754;
                            color: #fff;
                        }

                        .chip-inactive {
                            background: #6c757d;
                            border-color: #6c757d;
                            color: #fff;
                        }

                        .chip-pending {
                            background: #ffc107;
                            border-color: #ffc107;
                            color: #212529;
                        }

                        /* nút mở panel – màu cam như bạn chọn */
                        .chip-menu {
                            background: #fd7e14;
                            border-color: #fd7e14;
                            color: #fff;
                        }

                        .chip-menu:hover,
                        .chip-menu:focus {
                            background: #e86c0c;
                            border-color: #e86c0c;
                            color: #fff;
                            box-shadow: 0 0 0 .2rem rgba(253, 126, 20, .28);
                        }

                        /* nếu bị set disabled tạm thời vẫn giữ màu cam */
                        .chip-menu:disabled,
                        .chip-menu.disabled {
                            opacity: 1;
                            background: #fd7e14;
                            border-color: #fd7e14;
                            color: #fff;
                        }

                        /* Cho panel tràn ra ngoài vùng table-responsive (khỏi bị cắt) */
                        .card .table-responsive {
                            overflow: visible !important;
                        }

                        /* Đảm bảo mọi lớp trong bảng không chặn overflow của panel */
                        #storesTable,
                        #storesTable thead,
                        #storesTable tbody,
                        #storesTable tr,
                        #storesTable td,
                        #storesTable th {
                            overflow: visible;
                        }

                        /* Tăng z-index để panel nổi hẳn lên trên mọi thứ */
                        .status-pop {
                            z-index: 3000;
                        }

                        :root {
                            --sb-w: 260px;
                        }

                        /* đúng với bề rộng sidebar của bạn */

                        #pageContainer {
                            transition: margin-left .24s ease;
                        }

                        #pageContainer.shifted {
                            margin-left: var(--sb-w) !important;
                        }

                        /* Mobile: để sidebar phủ lên, không đẩy nội dung */
                        @media (max-width: 991.98px) {
                            #pageContainer.shifted {
                                margin-left: 0 !important;
                            }
                        }


                        /* Overlay giống trang Orders */
                        .sidebar-overlay {
                            position: fixed;
                            inset: 0;
                            background: rgba(0, 0, 0, .25);
                            z-index: 1040;
                            opacity: 0;
                            visibility: hidden;
                            transition: opacity .2s;
                        }

                        .sidebar-overlay.active {
                            opacity: 1;
                            visibility: visible;
                        }

                        .detail-item {
                            margin-bottom: .25rem;
                        }

                        .detail-label {
                            font-weight: 600;
                            display: block;
                            margin-bottom: .25rem;
                        }

                        .detail-value {
                            color: #2b2f36;
                            word-break: break-word;
                        }
                    </style>
                </head>

                <body class="has-fixed-navbar">
                    <jsp:include page="/WEB-INF/view/common/navbar.jsp" />
                    <jsp:include page="/WEB-INF/view/common/sidebar.jsp" />

                    <div class="sidebar-overlay" id="sidebarOverlay" role="button" tabindex="0"></div>

                    <div id="pageContainer" class="container-xxl mt-5 mb-5">
                        <!-- Title -->
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <h4 class="mb-0">Quản lý cửa hàng</h4>
                        </div>

                        <!-- Filters -->
                        <form id="filterForm" method="get" action=""
                            class="row row-cols-1 row-cols-md-2 row-cols-lg-6 g-2 mb-3 needs-validation filter"
                            novalidate>
                            <div class="col">
                                <input class="form-control" id="f-id" name="id" placeholder="Tìm theo ID "
                                    maxlength="12" />
                            </div>
                            <div class="col">
                                <input class="form-control" id="f-name" name="name" placeholder="Tên cửa hàng"
                                    maxlength="100" />
                            </div>
                            <div class="col col-status">
                                <select class="form-select" id="f-status" name="status" aria-label="Trạng thái">
                                    <option value="">-- Tất cả trạng thái --</option>
                                    <option value="ACTIVE">ACTIVE</option>
                                    <option value="INACTIVE">INACTIVE</option>
                                    <option value="BANNED">BANNED</option>
                                    <option value="PENDING">PENDING</option>
                                </select>
                            </div>

                            <div class="col col-date">
                                <input type="date" class="form-control" id="f-from" name="from" aria-label="Từ ngày" />
                            </div>
                            <div class="col col-date">
                                <input type="date" class="form-control" id="f-to" name="to" aria-label="Đến ngày" />
                            </div>

                            <div class="col-12 d-flex align-items-start gap-2 mt-1">
                                <button class="btn btn-primary" type="button" id="btnApply">Lọc</button>
                                <a class="btn btn-outline-secondary" href="<c:url value='/admin/stores'/>"
                                    id="btnClear">Bỏ lọc</a>
                            </div>
                        </form>

                        <!-- Table -->
                        <div class="card p-4">
                            <div class="table-responsive">
                                <table class="resizable-table table table-hover align-middle" id="storesTable">
                                    <thead class="table-light">
                                        <tr>
                                            <th class="sortable" style="width:100px" data-type="number">ID<div
                                                    class="resizer"></div>
                                            </th>
                                            <th class="sortable" style="width:420px" data-type="text">Store Name<div
                                                    class="resizer"></div>
                                            </th>
                                            <th class="sortable" style="width:180px" data-type="text">Status<div
                                                    class="resizer"></div>
                                            </th>
                                            <th style="width:380px">Hành động</th>
                                        </tr>
                                    </thead>
                                    <tbody id="storesTbody">
                                        <c:if test="${empty stores}">
                                            <tr>
                                                <td colspan="4" class="text-center text-muted py-4">Không có cửa hàng
                                                    nào.</td>
                                            </tr>
                                        </c:if>

                                        <c:forEach var="s" items="${stores}">
                                            <tr data-id="${s.id}" data-name="${fn:escapeXml(s.storeName)}"
                                                data-status="${s.status}"
                                                data-description="${fn:escapeXml(s.description)}"
                                                data-fee-model="${s.feeModel}" data-fee-rate="${s.feePercentageRate}"
                                                data-deposit="${s.depositAmount}"
                                                data-deposit-currency="${s.depositCurrency}"
                                                data-escrow="${s.escrowAmount}" data-rating="${s.rating}"
                                                data-created="${s.createdAt}">
                                                <td>#${s.id}</td>
                                                <td>
                                                    <div class="fw-semibold">${fn:escapeXml(s.storeName)}</div>
                                                    <div class="small text-muted">
                                                        Owner: #${s.owner.id} • Rating:
                                                        <fmt:formatNumber value="${s.rating}" minFractionDigits="2"
                                                            maxFractionDigits="2" />
                                                    </div>
                                                </td>
                                                <td>
                                                    <c:set var="st" value="${s.status}" />
                                                    <span
                                                        class="badge badge-status
                    ${st == 'ACTIVE' ? 'bg-success' : (st == 'BANNED' ? 'bg-danger' : (st == 'PENDING' ? 'bg-warning text-dark' : 'bg-secondary'))}">
                                                        ${s.status}
                                                    </span>
                                                </td>
                                                <td class="text-end">
                                                    <div class="actions">

                                                        <!-- Ban/Kích hoạt (riêng) -->
                                                        <c:choose>
                                                            <c:when test="${s.status == 'BANNED'}">
                                                                <form method="post"
                                                                    action="<c:url value='/admin/stores/status'/>"
                                                                    class="d-inline">
                                                                    <input type="hidden" name="storeId"
                                                                        value="${s.id}" />
                                                                    <input type="hidden" name="${_csrf.parameterName}"
                                                                        value="${_csrf.token}" />
                                                                    <input type="hidden" name="status"
                                                                        value="INACTIVE" />
                                                                    <button type="submit"
                                                                        class="btn-chip chip-on btn-unban"
                                                                        title="UnBan (đưa về INACTIVE)">
                                                                        <i class="bi bi-unlock"></i><span>UnBan</span>
                                                                    </button>
                                                                </form>
                                                            </c:when>

                                                            <c:otherwise>
                                                                <form method="post"
                                                                    action="<c:url value='/admin/stores/ban'/>"
                                                                    class="d-inline">
                                                                    <input type="hidden" name="storeId"
                                                                        value="${s.id}" />
                                                                    <input type="hidden" name="${_csrf.parameterName}"
                                                                        value="${_csrf.token}" />
                                                                    <button type="submit"
                                                                        class="btn-chip chip-ban btn-ban"
                                                                        title="Ban shop">
                                                                        <i class="bi bi-slash-circle"></i><span>Ban
                                                                            shop</span>
                                                                    </button>
                                                                </form>
                                                            </c:otherwise>
                                                        </c:choose>

                                                        <!-- Chi tiết -->
                                                        <button type="button" class="btn-chip chip-info btn-detail"
                                                            title="Chi tiết">
                                                            <i class="bi bi-info-circle"></i><span>Chi tiết</span>
                                                        </button>

                                                        <!-- ĐỔI TRẠNG THÁI: chỉ ACTIVE / INACTIVE / PENDING -->
                                                        <form method="post"
                                                            action="<c:url value='/admin/stores/status'/>"
                                                            class="d-inline">
                                                            <input type="hidden" name="storeId" value="${s.id}" />
                                                            <input type="hidden" name="${_csrf.parameterName}"
                                                                value="${_csrf.token}" />

                                                            <span class="status-pop-wrap">
                                                                <button type="button"
                                                                    class="btn-chip chip-menu status-toggle"
                                                                    title="Đổi trạng thái">
                                                                    <i class="bi bi-arrow-repeat"></i><span>Đổi trạng
                                                                        thái</span>
                                                                    <i class="bi bi-caret-down-fill ms-1"></i>
                                                                </button>

                                                                <div class="status-pop">
                                                                    <button type="button"
                                                                        class="btn-chip chip-active  status-item"
                                                                        data-status="ACTIVE">ACTIVE</button>
                                                                    <button type="button"
                                                                        class="btn-chip chip-inactive status-item"
                                                                        data-status="INACTIVE">INACTIVE</button>
                                                                    <button type="button"
                                                                        class="btn-chip chip-pending  status-item"
                                                                        data-status="PENDING">PENDING</button>
                                                                </div>
                                                            </span>
                                                        </form>
                                                    </div>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </div>

                        <!-- Detail Modal -->
                        <div class="modal fade" id="detailModal" tabindex="-1" aria-hidden="true">
                            <div class="modal-dialog modal-lg modal-dialog-centered">
                                <div class="modal-content">
                                    <div class="modal-header bg-info text-white">
                                        <h5 class="modal-title"><i class="bi bi-info-circle-fill"></i> Chi tiết cửa hàng
                                        </h5>
                                        <button class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                                    </div>

                                    <div class="modal-body">
                                        <div class="container-fluid">
                                            <!-- Hàng 1: Tên + ID -->
                                            <div class="row mb-3">
                                                <div class="col-md-8">
                                                    <div class="detail-item">
                                                        <label class="detail-label">Tên:</label>
                                                        <div class="detail-value" id="d-name"></div>
                                                    </div>
                                                </div>
                                                <div class="col-md-4">
                                                    <div class="detail-item">
                                                        <label class="detail-label">Mã (#ID):</label>
                                                        <div class="detail-value" id="d-id"></div>
                                                    </div>
                                                </div>
                                            </div>

                                            <!-- Hàng 2: Mô tả + Trạng thái -->
                                            <div class="row mb-3">
                                                <div class="col-md-8">
                                                    <div class="detail-item">
                                                        <label class="detail-label">Mô tả:</label>
                                                        <div class="detail-value" id="d-description"></div>
                                                    </div>
                                                </div>
                                                <div class="col-md-4">
                                                    <div class="detail-item">
                                                        <label class="detail-label">Trạng thái:</label>
                                                        <div class="detail-value">
                                                            <span id="d-status" class="badge badge-status"></span>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>

                                            <!-- Hàng 3: Tạo lúc + Fee model -->
                                            <div class="row mb-3">
                                                <div class="col-md-6">
                                                    <div class="detail-item">
                                                        <label class="detail-label">Tạo lúc:</label>
                                                        <div class="detail-value" id="d-created"></div>
                                                    </div>
                                                </div>
                                                <div class="col-md-6">
                                                    <div class="detail-item">
                                                        <label class="detail-label">Fee model:</label>
                                                        <div class="detail-value" id="d-fee-model"></div>
                                                    </div>
                                                </div>
                                            </div>

                                            <!-- Hàng 4: Fee % (ẩn khi NO_FEE) -->
                                            <div class="row mb-3" id="feeRateRow">
                                                <div class="col-md-6">
                                                    <div class="detail-item">
                                                        <label class="detail-label">Fee %:</label>
                                                        <div class="detail-value" id="d-fee-rate"></div>
                                                    </div>
                                                </div>
                                            </div>

                                            <!-- Hàng 5: Deposit + Tiền tệ -->
                                            <div class="row mb-2">
                                                <div class="col-md-6">
                                                    <div class="detail-item">
                                                        <label class="detail-label">Deposit:</label>
                                                        <div class="detail-value" id="d-deposit"></div>
                                                    </div>
                                                </div>
                                                <div class="col-md-6">
                                                    <div class="detail-item">
                                                        <label class="detail-label">Tiền tệ ký quỹ:</label>
                                                        <div class="detail-value" id="d-dep-currency"></div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="modal-footer">
                                        <button class="btn btn-secondary" data-bs-dismiss="modal">
                                            <i class="bi bi-x-circle"></i> Đóng
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>


                    </div>
                    </div>

                    <jsp:include page="/WEB-INF/view/common/footer.jsp" />

                    <!-- iziToast notifications -->
                    <c:if test="${not empty successMessage}">
                        <script>
                            if (window.iziToast) {
                                iziToast.success({ title: 'Success', message: '${successMessage}', position: 'topRight', timeout: 4500 });
                            }
                        </script>
                    </c:if>
                    <c:if test="${not empty errorMessage}">
                        <script>
                            if (window.iziToast) {
                                iziToast.error({ title: 'Error', message: '${errorMessage}', position: 'topRight', timeout: 5500 });
                            }
                        </script>
                    </c:if>

                    <script>
                        // Filter (client-side)
                        const $tbody = document.getElementById('storesTbody');
                        const $rows = () => Array.from($tbody.querySelectorAll('tr'));
                        document.getElementById('btnApply').addEventListener('click', () => {
                            const idVal = (document.getElementById('f-id').value || '').trim();
                            const nameVal = (document.getElementById('f-name').value || '').trim().toLowerCase();
                            const stVal = (document.getElementById('f-status').value || '').trim();
                            const ownerVal = (document.getElementById('f-owner').value || '').trim();
                            const fromVal = document.getElementById('f-from').value;
                            const toVal = document.getElementById('f-to').value;

                            $rows().forEach(tr => {
                                const id = tr.dataset.id || '';
                                const nm = (tr.dataset.name || '').toLowerCase();
                                const st = tr.dataset.status || '';
                                const ow = tr.dataset.owner || '';
                                const cr = tr.dataset.created ? tr.dataset.created.substring(0, 10) : '';
                                let keep = true;
                                if (idVal && id !== idVal) keep = false;
                                if (nameVal && !nm.includes(nameVal)) keep = false;
                                if (stVal && st !== stVal) keep = false;
                                if (ownerVal && ow !== ownerVal) keep = false;
                                if (fromVal && (!cr || cr < fromVal)) keep = false;
                                if (toVal && (!cr || cr > toVal)) keep = false;
                                tr.style.display = keep ? '' : 'none';
                            });
                        });

                        // Sorting + resize
                        (function initTableFeatures() {
                            const table = document.getElementById('storesTable');
                            if (!table) return;
                            const headers = table.querySelectorAll('th.sortable');
                            headers.forEach((th, idx) => {
                                th.addEventListener('click', (e) => {
                                    if (e.target.classList.contains('resizer')) return;
                                    const tbody = table.querySelector('tbody');
                                    const rows = Array.from(tbody.querySelectorAll('tr')).filter(r => r.style.display !== 'none');
                                    const asc = !th.classList.contains('sort-asc');
                                    headers.forEach(h => h.classList.remove('sort-asc', 'sort-desc'));
                                    th.classList.add(asc ? 'sort-asc' : 'sort-desc');
                                    const type = th.dataset.type || 'text';
                                    rows.sort((a, b) => {
                                        const A = (a.cells[idx]?.textContent || '').trim();
                                        const B = (b.cells[idx]?.textContent || '').trim();
                                        const va = (type === 'number') ? (Number(A.replace(/[^\d.-]/g, '')) || 0) : A.toLowerCase();
                                        const vb = (type === 'number') ? (Number(B.replace(/[^\d.-]/g, '')) || 0) : B.toLowerCase();
                                        return asc ? (va > vb ? 1 : (va < vb ? -1 : 0)) : (va < vb ? 1 : (va > vb ? -1 : 0));
                                    });
                                    rows.forEach(r => tbody.appendChild(r));
                                });
                            });
                            const resizers = table.querySelectorAll('.resizer');
                            resizers.forEach(r => {
                                r.addEventListener('mousedown', (e) => {
                                    e.preventDefault();
                                    const th = r.parentElement;
                                    const startX = e.clientX, startW = th.offsetWidth;
                                    function onMove(ev) { th.style.width = Math.max(80, startW + ev.clientX - startX) + 'px'; }
                                    function onUp() { document.removeEventListener('mousemove', onMove); document.removeEventListener('mouseup', onUp); }
                                    document.addEventListener('mousemove', onMove);
                                    document.addEventListener('mouseup', onUp);
                                });
                            });
                        })();

                        // Detail modal fill
                        const storesDetailModal = new bootstrap.Modal(document.getElementById('detailModal'));

                        document.addEventListener('click', (e) => {
                            const btn = e.target.closest('.btn-detail');
                            if (!btn) return;

                            const tr = btn.closest('tr');

                            const setText = (id, val) => {
                                const el = document.getElementById(id);
                                if (el) el.textContent = val ?? '';
                            };

                            const setBadge = (st) => {
                                const el = document.getElementById('d-status');
                                if (!el) return;
                                el.textContent = st || '';
                                el.className = 'badge badge-status ' + (
                                    st === 'ACTIVE' ? 'bg-success' :
                                        st === 'BANNED' ? 'bg-danger' :
                                            st === 'PENDING' ? 'bg-warning text-dark' : 'bg-secondary'
                                );
                            };

                            setText('d-id', '#' + (tr.dataset.id || ''));
                            setText('d-name', tr.dataset.name || '');
                            setText('d-description', tr.dataset.description || '(Không có mô tả)');
                            setText('d-created', tr.dataset.created || '');
                            setText('d-fee-model', tr.dataset.feeModel || '');
                            setText('d-deposit', tr.dataset.deposit || '');
                            setText('d-dep-currency', tr.dataset.depositCurrency || '');
                            setBadge(tr.dataset.status || '');

                            // Ẩn/hiện Fee % theo Fee model
                            const feeModel = (tr.dataset.feeModel || '').toUpperCase();
                            const feeRate = tr.dataset.feeRate || '';
                            const feeRow = document.getElementById('feeRateRow');
                            if (feeModel && feeModel !== 'NO_FEE' && feeRate) {
                                setText('d-fee-rate', feeRate);
                                feeRow?.classList.remove('d-none');
                            } else {
                                setText('d-fee-rate', '');
                                feeRow?.classList.add('d-none');
                            }

                            storesDetailModal.show();
                        });

                        // Confirm submit cho Ban/Kích hoạt (double-submit guard)
                        document.addEventListener('submit', (e) => {
                            const form = e.target;
                            if (!form.matches('form.d-inline')) return;
                            const btn = form.querySelector('button[type="submit"],button:not([type])');
                            const isBan = btn?.classList.contains('btn-ban');
                            const isUnban = btn?.classList.contains('btn-unban');
                            const tr = form.closest('tr');
                            const id = tr?.dataset.id || '?';
                            if (isBan && !confirm(`Xác nhận BAN shop #${id}?`)) { e.preventDefault(); return; }
                            if (isUnban && !confirm(`UnBan shop #${id} → INACTIVE?`)) { e.preventDefault(); return; }
                            if (btn) { btn.disabled = true; const t = btn.innerHTML; btn.dataset.t = t; btn.innerHTML = 'Đang xử lý...'; setTimeout(() => { btn.disabled = false; btn.innerHTML = t; }, 3000); }
                        });

                        // Mở/đóng panel trượt
                        document.addEventListener('click', function (e) {
                            const tog = e.target.closest('.status-toggle');
                            if (tog) {
                                const wrap = tog.closest('.status-pop-wrap');
                                const panel = wrap.querySelector('.status-pop');
                                // đóng panel khác
                                document.querySelectorAll('.status-pop.open')
                                    .forEach(p => { if (p !== panel) p.classList.remove('open'); });
                                panel.classList.toggle('open');
                                return;
                            }
                            // click ra ngoài -> đóng
                            if (!e.target.closest('.status-pop') && !e.target.closest('.status-toggle')) {
                                document.querySelectorAll('.status-pop.open').forEach(p => p.classList.remove('open'));
                            }
                        });

                        // Chọn trạng thái -> POST
                        document.addEventListener('click', function (e) {
                            const item = e.target.closest('.status-item');
                            if (!item) return;
                            e.preventDefault();
                            const status = item.dataset.status;
                            const form = item.closest('form');
                            const tr = item.closest('tr');
                            const id = tr?.dataset.id || '?';
                            if (!confirm(`Đổi trạng thái shop #${id} → ${status}?`)) return;

                            let inp = form.querySelector('input[name="status"]');
                            if (!inp) { inp = document.createElement('input'); inp.type = 'hidden'; inp.name = 'status'; form.appendChild(inp); }
                            inp.value = status;

                            item.closest('.status-pop')?.classList.remove('open');
                            form.submit();
                        });
                    </script>

                    <script>
                        document.querySelectorAll('.table-responsive').forEach(el => {
                            el.addEventListener('scroll', () => {
                                document.querySelectorAll('.status-pop.open').forEach(p => p.classList.remove('open'));
                            });
                        });
                    </script>

                    <script>
                        (function () {
                            // Tìm sẵn các phần tử, không sửa file chung
                            const sidebar = document.getElementById('sidebar') || document.querySelector('.sidebar');
                            const content = document.getElementById('content') || document.getElementById('pageContainer');
                            const overlay = document.getElementById('sidebarOverlay') || (() => {
                                const d = document.createElement('div');
                                d.id = 'sidebarOverlay'; d.className = 'sidebar-overlay';
                                document.body.appendChild(d); return d;
                            })();

                            // Nút 3 sọc trong navbar (giống Orders dùng .menu-toggle)
                            const menuBtn =
                                document.querySelector('.menu-toggle') ||
                                document.getElementById('sidebarToggleBtn') ||
                                document.querySelector('[data-sidebar-toggle]') ||
                                (document.querySelector('.navbar .bi-list') ? document.querySelector('.navbar .bi-list').closest('button') : null);

                            function isDesktop() { return window.innerWidth >= 992; }
                            function isOpen() { return sidebar?.classList.contains('active'); }

                            function applyShift(open) {
                                if (!content) return;
                                if (open && isDesktop()) content.classList.add('shifted');
                                else content.classList.remove('shifted');
                            }

                            function toggleSidebar(force) {
                                if (!sidebar) return;
                                const open = (force === true) ? true
                                    : (force === false) ? false
                                        : !isOpen();

                                sidebar.classList.toggle('active', open);
                                overlay.classList.toggle('active', open);
                                applyShift(open);
                                try { localStorage.setItem('sb-open', open ? '1' : '0'); } catch (e) { }
                            }

                            // Gắn sự kiện cho nút 3 sọc
                            if (menuBtn) {
                                menuBtn.addEventListener('click', function (e) { e.preventDefault(); toggleSidebar(); });
                            }

                            // Click overlay / ESC để đóng
                            overlay.addEventListener('click', () => toggleSidebar(false));
                            document.addEventListener('keydown', e => { if (e.key === 'Escape' && isOpen()) toggleSidebar(false); });

                            // Resize: cập nhật “expand” giống Orders
                            window.addEventListener('resize', () => applyShift(isOpen()));

                            // Khôi phục trạng thái đã lưu
                            try { if (localStorage.getItem('sb-open') === '1') toggleSidebar(true); } catch (e) { }
                        })();
                    </script>

                    <script>
                        (function () {
                            var CP = '${pageContext.request.contextPath}';
                            function isAbs(u) { return /^[a-zA-Z][a-zA-Z0-9+.-]*:/.test(u); } // http:, https:, mailto:, ...

                            function fixHref(a) {
                                var href = a.getAttribute('href');
                                if (!href || href.startsWith('#') || href.startsWith('javascript:')) return;
                                if (isAbs(href)) return;                    // link tuyệt đối thì bỏ qua
                                if (href.startsWith(CP + '/')) return;      // đã có contextPath thì bỏ qua
                                var abs = href.startsWith('/') ? (CP + href) : (CP + '/' + href.replace(/^(\.\/)+/, ''));
                                a.setAttribute('href', abs);
                            }
                            function fixAction(f) {
                                var act = f.getAttribute('action');
                                if (!act || isAbs(act)) return;
                                if (act.startsWith(CP + '/')) return;
                                var abs = act.startsWith('/') ? (CP + act) : (CP + '/' + act.replace(/^(\.\/)+/, ''));
                                f.setAttribute('action', abs);
                            }

                            // Chỉ sửa link trong navbar & sidebar (không đụng nội dung trang)
                            document.querySelectorAll('.navbar a[href], .sidebar a[href]').forEach(fixHref);
                            document.querySelectorAll('.navbar form[action], .sidebar form[action]').forEach(fixAction);
                        })();
                    </script>



                </body>

                </html>