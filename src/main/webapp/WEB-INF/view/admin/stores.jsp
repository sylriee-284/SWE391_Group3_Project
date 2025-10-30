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
                            font-weight: 600
                        }

                        .btn-chip {
                            display: inline-flex;
                            align-items: center;
                            gap: .35rem;
                            padding: .4rem .65rem;
                            border-radius: 999px;
                            border: 1px solid transparent
                        }

                        .btn-chip i {
                            font-size: 1rem
                        }

                        .chip-info {
                            background: #0d6efd;
                            border-color: #0d6efd;
                            color: #fff
                        }

                        .chip-ban {
                            background: #fff;
                            border: 1px solid #dc3545;
                            color: #dc3545
                        }

                        .chip-on {
                            background: #198754;
                            border-color: #198754;
                            color: #fff
                        }

                        .chip-dark {
                            background: #fd7e14;
                            border-color: #fd7e14;
                            color: #fff
                        }

                        .actions {
                            display: flex;
                            gap: .4rem;
                            justify-content: flex-end;
                            flex-wrap: wrap
                        }

                        .filter .col-date {
                            min-width: 170px
                        }

                        .resizer {
                            width: 6px;
                            cursor: col-resize;
                            position: absolute;
                            right: 0;
                            top: 0;
                            bottom: 0
                        }

                        th.sortable {
                            position: relative;
                            user-select: none
                        }

                        .table-hover tbody tr:hover {
                            background: rgba(13, 110, 253, .06)
                        }

                        .status-pop-wrap {
                            position: relative;
                            display: inline-block
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
                            z-index: 3000
                        }

                        .status-pop.open {
                            display: flex
                        }

                        .chip-active {
                            background: #198754;
                            border-color: #198754;
                            color: #fff
                        }

                        .chip-inactive {
                            background: #6c757d;
                            border-color: #6c757d;
                            color: #fff
                        }

                        .chip-pending {
                            background: #ffc107;
                            border-color: #ffc107;
                            color: #212529
                        }

                        .chip-menu {
                            background: #fd7e14;
                            border-color: #fd7e14;
                            color: #fff
                        }

                        .chip-menu:hover,
                        .chip-menu:focus {
                            background: #e86c0c;
                            border-color: #e86c0c;
                            color: #fff;
                            box-shadow: 0 0 0 .2rem rgba(253, 126, 20, .28)
                        }

                        .chip-menu:disabled,
                        .chip-menu.disabled {
                            opacity: 1;
                            background: #fd7e14;
                            border-color: #fd7e14;
                            color: #fff
                        }

                        .card .table-responsive {
                            overflow: visible !important
                        }

                        #storesTable,
                        #storesTable thead,
                        #storesTable tbody,
                        #storesTable tr,
                        #storesTable td,
                        #storesTable th {
                            overflow: visible
                        }

                        :root {
                            --sb-w: 260px
                        }

                        #pageContainer {
                            transition: margin-left .24s ease
                        }

                        #pageContainer.shifted {
                            margin-left: var(--sb-w) !important
                        }

                        @media (max-width: 991.98px) {
                            #pageContainer.shifted {
                                margin-left: 0 !important
                            }
                        }

                        .sidebar-overlay {
                            position: fixed;
                            inset: 0;
                            background: rgba(0, 0, 0, .25);
                            z-index: 1040;
                            opacity: 0;
                            visibility: hidden;
                            transition: opacity .2s
                        }

                        .sidebar-overlay.active {
                            opacity: 1;
                            visibility: visible
                        }

                        .detail-item {
                            margin-bottom: .25rem
                        }

                        .detail-label {
                            font-weight: 600;
                            display: block;
                            margin-bottom: .25rem
                        }

                        .detail-value {
                            color: #2b2f36;
                            word-break: break-word
                        }


                        @media (min-width: 992px) {
                            .w-lg-auto {
                                width: auto !important;
                            }
                        }




                        .page-item.disabled .page-link {
                            pointer-events: none;
                            opacity: .5;
                        }

                        .filter .form-select {
                            -webkit-appearance: none;
                            -moz-appearance: none;
                            appearance: none;
                            background-repeat: no-repeat;
                            background-position: right 0.9rem center;
                            /* vị trí caret */
                            background-size: 16px 12px;
                            padding-right: 3.25rem;
                            /* chừa rộng hơn cho mũi tên */
                        }

                        /* Firefox thường “ăn” thêm 1 chút – chừa rộng hơn một tí */
                        @-moz-document url-prefix() {
                            .filter .form-select {
                                padding-right: 3.75rem;
                            }
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

                        <!-- Filters (submit GET về server + giữ giá trị) -->
                        <form id="filterForm" method="get" action="" class="row g-2 align-items-center mb-3 filter"
                            novalidate>

                            <!-- ID -->
                            <div class="col-12 col-lg-2">
                                <input class="form-control" id="f-id" name="id" placeholder="Tìm theo ID" maxlength="12"
                                    value="${fn:escapeXml(param.id)}" />
                            </div>

                            <!-- Tên cửa hàng -->
                            <div class="col-12 col-lg-3">
                                <input class="form-control" id="f-name" name="name" placeholder="Tên cửa hàng"
                                    maxlength="100" value="${fn:escapeXml(param.name)}" />
                            </div>

                            <!-- Trạng thái -->
                            <div class="col-12 col-lg-2">
                                <select class="form-select" id="f-status" name="status" aria-label="Trạng thái">
                                    <option value="">-- Tất cả trạng thái --</option>
                                    <option value="ACTIVE" ${param.status=='ACTIVE' ? 'selected' : '' }>ACTIVE</option>
                                    <option value="INACTIVE" ${param.status=='INACTIVE' ? 'selected' : '' }>INACTIVE
                                    </option>
                                    <option value="BANNED" ${param.status=='BANNED' ? 'selected' : '' }>BANNED</option>
                                    <option value="PENDING" ${param.status=='PENDING' ? 'selected' : '' }>PENDING
                                    </option>
                                </select>
                            </div>

                            <!-- Từ ngày -->
                            <div class="col-6 col-lg-2">
                                <input type="date" class="form-control" id="f-from" name="from" aria-label="Từ ngày"
                                    value="${param.from}" />
                            </div>

                            <!-- Đến ngày -->
                            <div class="col-6 col-lg-2">
                                <input type="date" class="form-control" id="f-to" name="to" aria-label="Đến ngày"
                                    value="${param.to}" />
                            </div>



                            <!-- Nút hành động: xuống hàng dưới -->
                            <div class="col-12 d-flex gap-2 mt-1">
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
                                                data-status="${s.status}" data-deposit="${s.depositAmount}"
                                                data-deposit-currency="${s.depositCurrency}"
                                                data-created="${s.createdAt}">
                                                <td>#${s.id}</td>
                                                <td>
                                                    <div class="fw-semibold">${fn:escapeXml(s.storeName)}</div>
                                                    <div class="small text-muted">
                                                        Owner: #${s.owner.id}
                                                    </div>
                                                </td>
                                                <td>
                                                    <c:set var="stt" value="${s.status}" />
                                                    <span
                                                        class="badge badge-status
                  ${stt == 'ACTIVE' ? 'bg-success' : (stt == 'BANNED' ? 'bg-danger' : (stt == 'PENDING' ? 'bg-warning text-dark' : 'bg-secondary'))}">
                                                        ${s.status}
                                                    </span>
                                                </td>
                                                <td class="text-end">
                                                    <div class="actions">
                                                        <!-- Ban / Unban -->
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

                                                        <!-- Đổi trạng thái (ACTIVE/INACTIVE/PENDING) -->
                                                        <%-- ẨN TẠM NÚT ĐỔI TRẠNG THÁI <form method="post"
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
                                                            --%>
                                                    </div>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>

                            <!-- Pagination -->
                            <c:if test="${totalPages != null && totalPages >= 1}">
                                <c:url var="baseUrl" value="/admin/stores" />
                                <c:set var="keep">
                                    id=${fn:escapeXml(paramId)}&name=${fn:escapeXml(paramName)}&status=${fn:escapeXml(paramStatus)}&from=${paramFrom}&to=${paramTo}&size=${pageSize}
                                </c:set>

                                <nav class="mt-3">
                                    <ul class="pagination justify-content-center">

                                        <!-- << -->
                                        <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                                            <c:choose>
                                                <c:when test="${currentPage == 1}">
                                                    <span class="page-link">&laquo;</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <a class="page-link" href="${baseUrl}?page=1&${keep}">&laquo;</a>
                                                </c:otherwise>
                                            </c:choose>
                                        </li>

                                        <!-- < -->
                                        <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                                            <c:choose>
                                                <c:when test="${currentPage == 1}">
                                                    <span class="page-link">&lsaquo;</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <a class="page-link"
                                                        href="${baseUrl}?page=${currentPage-1}&${keep}">&lsaquo;</a>
                                                </c:otherwise>
                                            </c:choose>
                                        </li>

                                        <!-- window các số trang -->
                                        <c:set var="start" value="${currentPage-2 < 1 ? 1 : currentPage-2}" />
                                        <c:set var="end"
                                            value="${currentPage+2 > totalPages ? totalPages : currentPage+2}" />
                                        <c:forEach var="p" begin="${start}" end="${end}">
                                            <li class="page-item ${p == currentPage ? 'active' : ''}">
                                                <a class="page-link" href="${baseUrl}?page=${p}&${keep}">${p}</a>
                                            </li>
                                        </c:forEach>

                                        <!-- > -->
                                        <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                                            <c:choose>
                                                <c:when test="${currentPage == totalPages}">
                                                    <span class="page-link">&rsaquo;</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <a class="page-link"
                                                        href="${baseUrl}?page=${currentPage+1}&${keep}">&rsaquo;</a>
                                                </c:otherwise>
                                            </c:choose>
                                        </li>

                                        <!-- >> -->
                                        <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                                            <c:choose>
                                                <c:when test="${currentPage == totalPages}">
                                                    <span class="page-link">&raquo;</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <a class="page-link"
                                                        href="${baseUrl}?page=${totalPages}&${keep}">&raquo;</a>
                                                </c:otherwise>
                                            </c:choose>
                                        </li>

                                    </ul>
                                </nav>
                            </c:if>
                        </div>
                    </div>

                    <jsp:include page="/WEB-INF/view/common/footer.jsp" />

                    <!-- Toast -->
                    <c:if test="${not empty successMessage}">
                        <script>window.iziToast && iziToast.success({ title: 'Success', message: '${successMessage}', position: 'topRight', timeout: 4500 });</script>
                    </c:if>
                    <c:if test="${not empty errorMessage}">
                        <script>window.iziToast && iziToast.error({ title: 'Error', message: '${errorMessage}', position: 'topRight', timeout: 5500 });</script>
                    </c:if>

                    <!-- Sort + resize -->
                    <script>
                        (function initTableFeatures() {
                            const table = document.getElementById('storesTable'); if (!table) return;
                            const headers = table.querySelectorAll('th.sortable');
                            headers.forEach((th, idx) => {
                                th.addEventListener('click', (e) => {
                                    if (e.target.classList.contains('resizer')) return;
                                    const tbody = table.querySelector('tbody');
                                    const rows = Array.from(tbody.querySelectorAll('tr'));
                                    const asc = !th.classList.contains('sort-asc');
                                    headers.forEach(h => h.classList.remove('sort-asc', 'sort-desc'));
                                    th.classList.add(asc ? 'sort-asc' : 'sort-desc');
                                    const type = th.dataset.type || 'text';
                                    rows.sort((a, b) => {
                                        const A = (a.cells[idx]?.textContent || '').trim();
                                        const B = (b.cells[idx]?.textContent || '').trim();
                                        let va = A, vb = B;
                                        if (type === 'number') { va = Number(A.replace(/[^\d.-]/g, '')) || 0; vb = Number(B.replace(/[^\d.-]/g, '')) || 0; }
                                        else { va = A.toLowerCase(); vb = B.toLowerCase(); }
                                        return asc ? (va > vb ? 1 : va < vb ? -1 : 0) : (va < vb ? 1 : va > vb ? -1 : 0);
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
                    </script>

                    <!-- Detail modal -->
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
                                        <div class="row mb-3">
                                            <div class="col-md-8">
                                                <div class="detail-item"><label class="detail-label">Tên:</label>
                                                    <div class="detail-value" id="d-name"></div>
                                                </div>
                                            </div>
                                            <div class="col-md-4">
                                                <div class="detail-item"><label class="detail-label">Mã (#ID):</label>
                                                    <div class="detail-value" id="d-id"></div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="row mb-3">
                                            <div class="col-md-8">
                                                <div class="detail-item"><label class="detail-label">Mô tả:</label>
                                                    <div class="detail-value" id="d-description"></div>
                                                </div>
                                            </div>
                                            <div class="col-md-4">
                                                <div class="detail-item"><label class="detail-label">Trạng thái:</label>
                                                    <div class="detail-value"><span id="d-status"
                                                            class="badge badge-status"></span></div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="row mb-3">
                                            <div class="col-md-6">
                                                <div class="detail-item"><label class="detail-label">Tạo lúc:</label>
                                                    <div class="detail-value" id="d-created"></div>
                                                </div>
                                            </div>
                                            <div class="col-md-6">
                                                <div class="detail-item"><label class="detail-label">Fee model:</label>
                                                    <div class="detail-value" id="d-fee-model"></div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="row mb-3" id="feeRateRow">
                                            <div class="col-md-6">
                                                <div class="detail-item"><label class="detail-label">Fee %:</label>
                                                    <div class="detail-value" id="d-fee-rate"></div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="row mb-2">
                                            <div class="col-md-6">
                                                <div class="detail-item"><label class="detail-label">Deposit:</label>
                                                    <div class="detail-value" id="d-deposit"></div>
                                                </div>
                                            </div>
                                            <div class="col-md-6">
                                                <div class="detail-item"><label class="detail-label">Tiền tệ ký
                                                        quỹ:</label>
                                                    <div class="detail-value" id="d-dep-currency"></div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="modal-footer">
                                    <button class="btn btn-secondary" data-bs-dismiss="modal"><i
                                            class="bi bi-x-circle"></i> Đóng</button>
                                </div>
                            </div>
                        </div>
                    </div>

                    <script>
                        const storesDetailModal = new bootstrap.Modal(document.getElementById('detailModal'));
                        document.addEventListener('click', (e) => {
                            const btn = e.target.closest('.btn-detail'); if (!btn) return;
                            const tr = btn.closest('tr');
                            const setText = (id, val) => { const el = document.getElementById(id); if (el) el.textContent = val ?? ''; };
                            const setBadge = (st) => {
                                const el = document.getElementById('d-status'); if (!el) return;
                                el.textContent = st || ''; el.className = 'badge badge-status ' + (st === 'ACTIVE' ? 'bg-success' : st === 'BANNED' ? 'bg-danger' : st === 'PENDING' ? 'bg-warning text-dark' : 'bg-secondary');
                            };
                            setText('d-id', '#' + (tr.dataset.id || '')); setText('d-name', tr.dataset.name || '');
                            setText('d-description', tr.dataset.description || '(Không có mô tả)');
                            setText('d-created', tr.dataset.created || ''); setText('d-fee-model', tr.dataset.feeModel || '');
                            setText('d-deposit', tr.dataset.deposit || ''); setText('d-dep-currency', tr.dataset.depositCurrency || '');
                            setBadge(tr.dataset.status || '');
                            const feeModel = (tr.dataset.feeModel || '').toUpperCase(); const feeRate = tr.dataset.feeRate || ''; const feeRow = document.getElementById('feeRateRow');
                            if (feeModel && feeModel !== 'NO_FEE' && feeRate) { setText('d-fee-rate', feeRate); feeRow?.classList.remove('d-none'); }
                            else { setText('d-fee-rate', ''); feeRow?.classList.add('d-none'); }
                            storesDetailModal.show();
                        });

                        // Ban / Unban confirm + double-submit guard
                        document.addEventListener('submit', (e) => {
                            const form = e.target; if (!form.matches('form.d-inline')) return;
                            const btn = form.querySelector('button[type="submit"],button:not([type])');
                            const isBan = btn?.classList.contains('btn-ban'); const isUnban = btn?.classList.contains('btn-unban');
                            const tr = form.closest('tr'); const id = tr?.dataset.id || '?';
                            if (isBan && !confirm(`Xác nhận BAN shop #${id}?`)) { e.preventDefault(); return; }
                            if (isUnban && !confirm(`UnBan shop #${id} → INACTIVE?`)) { e.preventDefault(); return; }
                            if (btn) {
                                btn.disabled = true; const t = btn.innerHTML; btn.dataset.t = t; btn.innerHTML = 'Đang xử lý...';
                                setTimeout(() => { btn.disabled = false; btn.innerHTML = t; }, 3000);
                            }
                        });

                        // Toggle status menu
                        document.addEventListener('click', function (e) {
                            const tog = e.target.closest('.status-toggle');
                            if (tog) {
                                const wrap = tog.closest('.status-pop-wrap'); const panel = wrap.querySelector('.status-pop');
                                document.querySelectorAll('.status-pop.open').forEach(p => { if (p !== panel) p.classList.remove('open'); });
                                panel.classList.toggle('open'); return;
                            }
                            if (!e.target.closest('.status-pop') && !e.target.closest('.status-toggle')) {
                                document.querySelectorAll('.status-pop.open').forEach(p => p.classList.remove('open'));
                            }
                        });

                        // Pick status → POST
                        document.addEventListener('click', function (e) {
                            const item = e.target.closest('.status-item'); if (!item) return;
                            e.preventDefault();
                            const status = item.dataset.status; const form = item.closest('form'); const tr = item.closest('tr'); const id = tr?.dataset.id || '?';
                            if (!confirm(`Đổi trạng thái shop #${id} → ${status}?`)) return;
                            let inp = form.querySelector('input[name="status"]');
                            if (!inp) { inp = document.createElement('input'); inp.type = 'hidden'; inp.name = 'status'; form.appendChild(inp); }
                            inp.value = status;
                            item.closest('.status-pop')?.classList.remove('open');
                            form.submit();
                        });

                        // Đóng menu khi scroll bảng
                        document.querySelectorAll('.table-responsive').forEach(el => {
                            el.addEventListener('scroll', () => { document.querySelectorAll('.status-pop.open').forEach(p => p.classList.remove('open')); });
                        });

                        // Sidebar toggle (khớp layout hiện có)
                        (function () {
                            const sidebar = document.getElementById('sidebar') || document.querySelector('.sidebar');
                            const content = document.getElementById('content') || document.getElementById('pageContainer');
                            const overlay = document.getElementById('sidebarOverlay') || (() => { const d = document.createElement('div'); d.id = 'sidebarOverlay'; d.className = 'sidebar-overlay'; document.body.appendChild(d); return d; })();
                            const menuBtn = document.querySelector('.menu-toggle') || document.getElementById('sidebarToggleBtn') || document.querySelector('[data-sidebar-toggle]') || (document.querySelector('.navbar .bi-list') ? document.querySelector('.navbar .bi-list').closest('button') : null);
                            function isDesktop() { return window.innerWidth >= 992; }
                            function isOpen() { return sidebar?.classList.contains('active'); }
                            function applyShift(open) { if (!content) return; if (open && isDesktop()) content.classList.add('shifted'); else content.classList.remove('shifted'); }
                            function toggleSidebar(force) {
                                if (!sidebar) return;
                                const open = (force === true) ? true : (force === false) ? false : !isOpen();
                                sidebar.classList.toggle('active', open); overlay.classList.toggle('active', open); applyShift(open);
                                try { localStorage.setItem('sb-open', open ? '1' : '0'); } catch (e) { }
                            }
                            if (menuBtn) { menuBtn.addEventListener('click', e => { e.preventDefault(); toggleSidebar(); }); }
                            overlay.addEventListener('click', () => toggleSidebar(false));
                            document.addEventListener('keydown', e => { if (e.key === 'Escape' && isOpen()) toggleSidebar(false); });
                            window.addEventListener('resize', () => applyShift(isOpen()));
                            try { if (localStorage.getItem('sb-open') === '1') toggleSidebar(true); } catch (e) { }
                        })();

                        // Sửa đường dẫn navbar/sidebar theo contextPath (như các trang khác)
                        (function () {
                            var CP = '${pageContext.request.contextPath}';
                            function isAbs(u) { return /^[a-zA-Z][a-zA-Z0-9+.-]*:/.test(u); }
                            function fixHref(a) {
                                var href = a.getAttribute('href'); if (!href || href.startsWith('#') || href.startsWith('javascript:')) return;
                                if (isAbs(href) || href.startsWith(CP + '/')) return; var abs = href.startsWith('/') ? (CP + href) : (CP + '/' + href.replace(/^(\.\/)+/, ''));
                                a.setAttribute('href', abs);
                            }
                            function fixAction(f) {
                                var act = f.getAttribute('action'); if (!act || isAbs(act) || act.startsWith(CP + '/')) return;
                                var abs = act.startsWith('/') ? (CP + act) : (CP + '/' + act.replace(/^(\.\/)+/, '')); f.setAttribute('action', abs);
                            }
                            document.querySelectorAll('.navbar a[href], .sidebar a[href]').forEach(fixHref);
                            document.querySelectorAll('.navbar form[action], .sidebar form[action]').forEach(fixAction);
                        })();
                    </script>

                    <script>
                        (function () {
                            const btn = document.getElementById('btnApply');
                            const form = document.getElementById('filterForm');
                            if (!btn || !form) return;
                            btn.addEventListener('click', function () {
                                let p = form.querySelector('input[name="page"]');
                                if (!p) { p = document.createElement('input'); p.type = 'hidden'; p.name = 'page'; form.appendChild(p); }
                                p.value = 1; // reset về trang 1 khi lọc
                                let s = form.querySelector('input[name="size"]');
                                if (!s) { s = document.createElement('input'); s.type = 'hidden'; s.name = 'size'; form.appendChild(s); }
                                s.value = '${pageSize}';
                                form.submit();
                            });
                        })();
                    </script>

                </body>

                </html>