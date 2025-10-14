<%@ page contentType="text/html; charset=UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

                <!DOCTYPE html>
                <html lang="vi">

                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>
                        <c:if test="${not empty pageTitle}">${pageTitle} - </c:if>MMO Market System
                    </title>
                    <jsp:include page="../common/head.jsp" />
                </head>

                <body>
                    <jsp:include page="../common/navbar.jsp" />
                    <jsp:include page="../common/sidebar.jsp" />

                    <div class="container mt-4">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <h4>Danh sách sản phẩm</h4>
                            <c:url var="newUrl" value="/seller/products/new">
                                <c:param name="storeId" value="${storeId}" />
                            </c:url>
                            <a class="btn btn-primary" href="${newUrl}">Thêm sản phẩm</a>
                        </div>

                        <!-- Flash -->
                        <c:if test="${not empty success}">
                            <div class="alert alert-success alert-dismissible fade show" role="alert">
                                ${success}
                                <button type="button" class="btn-close" data-bs-dismiss="alert"
                                    aria-label="Close"></button>
                            </div>
                        </c:if>
                        <c:if test="${not empty error}">
                            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                                ${error}
                                <button type="button" class="btn-close" data-bs-dismiss="alert"
                                    aria-label="Close"></button>
                            </div>
                        </c:if>

                        <!-- FILTER -->
                        <form id="filterForm" class="row g-2 mb-3 needs-validation" method="get"
                            action="<c:url value='/seller/products'/>" novalidate>
                            <input type="hidden" name="storeId" value="${storeId}" />
                            <input type="hidden" name="size" value="${page.size}" />

                            <div class="col-md-3">
                                <input class="form-control" name="q" value="${fn:escapeXml(q)}"
                                    placeholder="Từ khoá tên/slug..." maxlength="100" aria-describedby="qHelp" />
                                <div id="qHelp" class="form-text">Tối đa 100 ký tự. Không nhập chỉ khoảng trắng.</div>
                                <div class="invalid-feedback">Từ khoá quá dài hoặc không hợp lệ.</div>
                            </div>

                            <div class="col-md-2">
                                <select class="form-select" name="status" aria-label="Trạng thái">
                                    <option value="">-- Trạng thái --</option>
                                    <c:forEach var="st" items="${ProductStatus}">
                                        <option value="${st}" <c:if test="${status == st}">selected</c:if>>${st}
                                        </option>
                                    </c:forEach>
                                </select>
                                <div class="invalid-feedback">Giá trị trạng thái không hợp lệ.</div>
                            </div>

                            <div class="col-md-3">
                                <select class="form-select" name="parentCategoryId" onchange="this.form.submit()"
                                    aria-label="Danh mục cha">
                                    <option value="">-- Tùy chọn danh mục --</option>
                                    <c:forEach var="pc" items="${parentCategories}">
                                        <option value="${pc.id}" <c:if test="${parentCategoryId == pc.id}">selected
                                            </c:if>>${pc.name}</option>
                                    </c:forEach>
                                </select>
                                <div class="invalid-feedback">Danh mục cha không hợp lệ.</div>
                            </div>

                            <div class="col-md-2">
                                <select class="form-select" name="categoryId" aria-label="Danh mục">
                                    <option value="">-- Danh mục --</option>
                                    <c:forEach var="c" items="${subCategories}">
                                        <option value="${c.id}" <c:if test="${categoryId == c.id}">selected</c:if>
                                            >${c.name}</option>
                                    </c:forEach>
                                </select>
                                <div class="invalid-feedback">Danh mục không hợp lệ.</div>
                            </div>

                            <div class="col-md-2">
                                <input type="date" class="form-control" name="fromDate" value="${fromDate}"
                                    placeholder="Từ ngày" aria-label="Từ ngày" />
                                <div class="invalid-feedback">Ngày bắt đầu không hợp lệ.</div>
                            </div>
                            <div class="col-md-2">
                                <input type="date" class="form-control" name="toDate" value="${toDate}"
                                    placeholder="Đến ngày" aria-label="Đến ngày" />
                                <div class="invalid-feedback">Ngày kết thúc phải ≥ ngày bắt đầu.</div>
                            </div>

                            <div class="col-md-2">
                                <button class="btn btn-outline-secondary w-100" type="submit">Lọc</button>
                            </div>
                        </form>

                        <!-- TABLE -->
                        <div class="table-responsive">
                            <table class="table table-striped align-middle">
                                <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th style="min-width:260px">Tên</th>
                                        <th>Danh mục</th>
                                        <th>Giá</th>
                                        <th>Trạng thái</th>
                                        <th>Tồn</th>
                                        <th class="text-end">Hành động</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:if test="${empty page.content}">
                                        <tr>
                                            <td colspan="7" class="text-center text-muted py-4">Không có sản phẩm nào
                                                khớp bộ lọc.</td>
                                        </tr>
                                    </c:if>
                                    <c:forEach var="p" items="${page.content}">
                                        <tr>
                                            <td>#${p.id}</td>
                                            <td>
                                                <div class="d-flex gap-2 align-items-center">
                                                    <c:choose>
                                                        <c:when test="${not empty p.productUrl}">
                                                            <img src="${p.productUrl}" alt="img"
                                                                style="height:40px;width:40px;object-fit:cover;border-radius:6px;border:1px solid #eee" />
                                                        </c:when>
                                                        <c:otherwise>
                                                            <div style="height:40px;width:40px;border:1px dashed #ccc;border-radius:6px"
                                                                class="d-flex align-items-center justify-content-center text-muted small">
                                                                —</div>
                                                        </c:otherwise>
                                                    </c:choose>
                                                    <div>
                                                        <div class="fw-semibold">${p.name}</div>
                                                        <div class="text-muted small">${p.slug}</div>
                                                    </div>
                                                </div>
                                            </td>
                                            <td>${p.category != null ? p.category.name : '-'}</td>
                                            <td>
                                                <fmt:formatNumber value="${p.price}" type="currency"
                                                    currencySymbol="₫" />
                                            </td>
                                            <td><span
                                                    class="badge ${p.status=='ACTIVE'?'bg-success':'bg-secondary'}">${p.status}</span>
                                            </td>
                                            <td>${p.stock}</td>
                                            <td class="text-end">
                                                <!-- Toggle -->
                                                <c:url var="toggleUrl" value="/seller/products/${p.id}/toggle">
                                                    <c:param name="storeId" value="${storeId}" />
                                                </c:url>
                                                <form class="d-inline" method="post" action="${toggleUrl}">
                                                    <input type="hidden" name="to"
                                                        value="${p.status=='ACTIVE'?'INACTIVE':'ACTIVE'}" />
                                                    <c:if test="${not empty _csrf}">
                                                        <input type="hidden" name="${_csrf.parameterName}"
                                                            value="${_csrf.token}" />
                                                    </c:if>
                                                    <button
                                                        class="btn btn-sm ${p.status=='ACTIVE'?'btn-outline-warning':'btn-outline-success'}">
                                                        ${p.status=='ACTIVE'?'Tắt':'Bật'}
                                                    </button>
                                                </form>

                                                <!-- Edit -->
                                                <c:url var="editUrl" value="/seller/products/${p.id}/edit">
                                                    <c:param name="storeId" value="${storeId}" />
                                                </c:url>
                                                <a class="btn btn-sm btn-outline-primary" href="${editUrl}">Sửa</a>

                                                <!-- Soft delete -->
                                                <c:url var="deleteUrl" value="/seller/products/${p.id}/delete">
                                                    <c:param name="storeId" value="${storeId}" />
                                                </c:url>
                                                <form class="d-inline" method="post" action="${deleteUrl}"
                                                    onsubmit="return confirm('Ẩn sản phẩm này?');">
                                                    <c:if test="${not empty _csrf}">
                                                        <input type="hidden" name="${_csrf.parameterName}"
                                                            value="${_csrf.token}" />
                                                    </c:if>
                                                    <!-- <button class="btn btn-sm btn-outline-danger">Ẩn</button> -->
                                                </form>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>

                        <!-- Pagination -->
                        <c:if test="${page.totalPages > 1}">
                            <nav>
                                <ul class="pagination">
                                    <c:if test="${!page.first}">
                                        <c:url var="prevUrl" value="/seller/products">
                                            <c:param name="storeId" value="${storeId}" />
                                            <c:param name="q" value="${q}" />
                                            <c:param name="status" value="${status}" />
                                            <c:param name="parentCategoryId" value="${parentCategoryId}" />
                                            <c:param name="categoryId" value="${categoryId}" />
                                            <c:param name="fromDate" value="${fromDate}" />
                                            <c:param name="toDate" value="${toDate}" />
                                            <c:param name="size" value="${page.size}" />
                                            <c:param name="page" value="${page.number - 1}" />
                                        </c:url>
                                        <li class="page-item"><a class="page-link" href="${prevUrl}">&laquo;</a></li>
                                    </c:if>

                                    <c:forEach begin="0" end="${page.totalPages-1}" var="i">
                                        <c:url var="pageUrl" value="/seller/products">
                                            <c:param name="storeId" value="${storeId}" />
                                            <c:param name="q" value="${q}" />
                                            <c:param name="status" value="${status}" />
                                            <c:param name="parentCategoryId" value="${parentCategoryId}" />
                                            <c:param name="categoryId" value="${categoryId}" />
                                            <c:param name="fromDate" value="${fromDate}" />
                                            <c:param name="toDate" value="${toDate}" />
                                            <c:param name="size" value="${page.size}" />
                                            <c:param name="page" value="${i}" />
                                        </c:url>
                                        <li class="page-item ${i==page.number?'active':''}">
                                            <a class="page-link" href="${pageUrl}">${i+1}</a>
                                        </li>
                                    </c:forEach>

                                    <c:if test="${!page.last}">
                                        <c:url var="nextUrl" value="/seller/products">
                                            <c:param name="storeId" value="${storeId}" />
                                            <c:param name="q" value="${q}" />
                                            <c:param name="status" value="${status}" />
                                            <c:param name="parentCategoryId" value="${parentCategoryId}" />
                                            <c:param name="categoryId" value="${categoryId}" />
                                            <c:param name="fromDate" value="${fromDate}" />
                                            <c:param name="toDate" value="${toDate}" />
                                            <c:param name="size" value="${page.size}" />
                                            <c:param name="page" value="${page.number + 1}" />
                                        </c:url>
                                        <li class="page-item"><a class="page-link" href="${nextUrl}">&raquo;</a></li>
                                    </c:if>
                                </ul>
                            </nav>
                        </c:if>
                    </div>

                    <jsp:include page="../common/footer.jsp" />

                    <!-- Toast -->
                    <c:if test="${not empty successMessage}">
                        <script>iziToast.success({ title: 'Success!', message: '${successMessage}', position: 'topRight', timeout: 5000 });</script>
                    </c:if>
                    <c:if test="${not empty errorMessage}">
                        <script>iziToast.error({ title: 'Error!', message: '${errorMessage}', position: 'topRight', timeout: 5000 });</script>
                    </c:if>

                    <!-- Validate filter: chống chỉ khoảng trắng + kiểm ngày -->
                    <script>
                        (function () {
                            const form = document.getElementById('filterForm');
                            if (!form) return;

                            const qInput = form.querySelector('input[name="q"]');
                            const fromIn = form.querySelector('input[name="fromDate"]');
                            const toIn = form.querySelector('input[name="toDate"]');

                            function vKeyword() {
                                if (!qInput) return true;
                                const raw = qInput.value || '';
                                const v = raw.trim();
                                if (raw.length && v.length === 0) { // chỉ toàn khoảng trắng
                                    qInput.setCustomValidity('only-spaces'); return false;
                                }
                                if (v.length > 100) { qInput.setCustomValidity('too-long'); return false; }
                                qInput.setCustomValidity(''); return true;
                            }
                            function iso(d) { return d ? new Date(d + 'T00:00:00') : null; }
                            function vDateRange() {
                                const f = fromIn?.value, t = toIn?.value;
                                if (!f || !t) { fromIn?.setCustomValidity(''); toIn?.setCustomValidity(''); return true; }
                                const fd = iso(f), td = iso(t);
                                if (isNaN(fd) || isNaN(td)) { fromIn?.setCustomValidity(isNaN(fd) ? 'invalid' : ''); toIn?.setCustomValidity(isNaN(td) ? 'invalid' : ''); return false; }
                                if (td < fd) { toIn.setCustomValidity('end-before-start'); return false; }
                                fromIn.setCustomValidity(''); toIn.setCustomValidity(''); return true;
                            }

                            qInput?.addEventListener('input', vKeyword);
                            fromIn?.addEventListener('change', vDateRange);
                            toIn?.addEventListener('change', vDateRange);

                            form.addEventListener('submit', function (e) {
                                const ok = vKeyword() & vDateRange();
                                if (!form.checkValidity() || !ok) { e.preventDefault(); e.stopPropagation(); }
                                form.classList.add('was-validated');
                            });

                            // chống double submit cho form POST (toggle/delete)
                            document.querySelectorAll('form.d-inline[method="post"]').forEach(f => {
                                f.addEventListener('submit', function () {
                                    const btn = f.querySelector('button[type="submit"],button:not([type])');
                                    if (btn) {
                                        btn.disabled = true; const t = btn.innerHTML; btn.dataset.t = t; btn.innerHTML = 'Đang xử lý...';
                                        setTimeout(() => { btn.disabled = false; btn.innerHTML = btn.dataset.t; }, 3000);
                                    }
                                });
                            });
                        })();
                    </script>
                </body>

                </html>