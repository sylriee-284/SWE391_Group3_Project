<%@ page contentType="text/html; charset=UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
                <!DOCTYPE html>
                <html lang="vi">

                <head>
                    <meta charset="UTF-8">
                    <title>
                        <c:choose>
                            <c:when test="${formMode=='CREATE'}">Thêm sản phẩm</c:when>
                            <c:otherwise>Cập nhật sản phẩm #${form.id}</c:otherwise>
                        </c:choose>
                    </title>
                    <jsp:include page="../common/head.jsp" />
                </head>

                <body>
                    <jsp:include page="../common/navbar.jsp" />
                    <jsp:include page="../common/sidebar.jsp" />

                    <!-- Prefill ids từ Controller -->
                    <span id="prefill" data-parent="${selectedParentId}" data-child="${selectedChildId}"></span>

                    <div class="content" id="content">
                        <div class="container mt-4">
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <h4>
                                    <c:choose>
                                        <c:when test="${formMode=='CREATE'}">Thêm sản phẩm</c:when>
                                        <c:otherwise>Cập nhật sản phẩm #${form.id}</c:otherwise>
                                    </c:choose>
                                </h4>

                                <c:url var="backUrl" value="/seller/products">
                                    <c:param name="storeId" value="${storeId}" />
                                </c:url>
                                <a class="btn btn-outline-secondary" href="${backUrl}">← Danh sách</a>
                            </div>

                            <!-- Action tùy theo mode -->
                            <c:choose>
                                <c:when test="${formMode=='CREATE'}">
                                    <c:url var="formAction" value="/seller/products">
                                        <c:param name="storeId" value="${storeId}" />
                                    </c:url>
                                </c:when>
                                <c:otherwise>
                                    <c:url var="formAction" value="/seller/products/${form.id}">
                                        <c:param name="storeId" value="${storeId}" />
                                    </c:url>
                                </c:otherwise>
                            </c:choose>

                            <!-- Quan trọng: modelAttribute="form" trùng với Controller -->
                            <form:form id="productForm" method="post" action="${formAction}" modelAttribute="form"
                                enctype="multipart/form-data">
                                <c:if test="${not empty _csrf}">
                                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                                </c:if>

                                <div class="card">
                                    <div class="card-body row g-3">

                                        <!-- Tên sản phẩm -->
                                        <div class="col-md-6">
                                            <label class="form-label">Tên sản phẩm</label>
                                            <form:input path="name" cssClass="form-control" required="required"
                                                maxlength="120" data-noblank="true" />
                                            <form:errors path="name" cssClass="text-danger small" />
                                        </div>

                                        <!-- Slug -->
                                        <div class="col-md-6">
                                            <label class="form-label">Slug (duy nhất trong store)</label>
                                            <form:input path="slug" cssClass="form-control" required="required"
                                                maxlength="120" pattern="^[a-z0-9-]{2,120}$" data-noblank="true" />
                                            <div class="form-text">Chỉ a-z, 0-9, dấu gạch ngang (-), 2–120 ký tự.</div>
                                            <form:errors path="slug" cssClass="text-danger small" />
                                        </div>

                                        <!-- Danh mục CHA (không bind) -->
                                        <div class="col-md-6">
                                            <label class="form-label">Tùy chọn danh mục</label>
                                            <select class="form-select" id="parentCategory">
                                                <option value="">-- Tùy chọn danh mục --</option>
                                                <c:forEach var="pc" items="${parentCategories}">
                                                    <option value="${pc.id}" <c:if
                                                        test="${not empty selectedParentId && selectedParentId == pc.id}">
                                                        selected</c:if>>
                                                        ${pc.name}
                                                    </option>
                                                </c:forEach>
                                            </select>
                                        </div>

                                        <!-- Danh mục CON (bind vào category.id) -->
                                        <div class="col-md-6">
                                            <label class="form-label">Danh mục</label>
                                            <form:select path="category.id" cssClass="form-select" required="required">
                                                <form:option value="">-- Chọn danh mục --</form:option>
                                                <c:forEach var="c" items="${subCategories}">
                                                    <form:option value="${c.id}">${c.name}</form:option>
                                                </c:forEach>
                                            </form:select>
                                            <form:errors path="category" cssClass="text-danger small" />
                                            <form:errors path="category.id" cssClass="text-danger small" />
                                        </div>

                                        <!-- Giá -->
                                        <div class="col-md-6">
                                            <label class="form-label">Giá</label>
                                            <form:input path="price" type="number" step="0.01" min="0.01"
                                                cssClass="form-control" required="required" />
                                            <form:errors path="price" cssClass="text-danger small" />
                                        </div>

                                        <!-- Trạng thái -->
                                        <div class="col-md-6">
                                            <label class="form-label">Trạng thái</label>
                                            <form:select path="status" cssClass="form-select" required="required">
                                                <form:option value="ACTIVE">ACTIVE</form:option>
                                                <form:option value="INACTIVE">INACTIVE</form:option>
                                            </form:select>
                                            <form:errors path="status" cssClass="text-danger small" />
                                        </div>

                                        <!-- Ảnh đại diện (upload) -->
                                        <div class="col-md-12">
                                            <label class="form-label">Ảnh đại diện sản phẩm</label>
                                            <input class="form-control" type="file" name="imageFile"
                                                accept="image/jpeg,image/png" />
                                            <c:if test="${not empty form.productUrl}">
                                                <div class="mt-2">
                                                    <img src="${form.productUrl}" alt="Ảnh sản phẩm"
                                                        style="max-height:160px;border:1px solid #eee;border-radius:8px;padding:4px;background:#fff" />
                                                    <div class="form-text">Ảnh hiện tại. Nếu không chọn ảnh mới, sẽ giữ
                                                        nguyên.</div>
                                                </div>
                                            </c:if>
                                            <div class="form-text">Chỉ JPG/PNG, tối đa 10MB.</div>
                                            <form:errors path="productUrl" cssClass="text-danger small" />
                                        </div>

                                        <!-- Mô tả -->
                                        <div class="col-md-12">
                                            <label class="form-label">Mô tả</label>
                                            <form:textarea path="description" rows="4" cssClass="form-control"
                                                maxlength="2000" />
                                            <form:errors path="description" cssClass="text-danger small" />
                                        </div>

                                        <!-- Stock (tồn hiển thị) -->
                                        <div class="col-md-4">
                                            <label class="form-label">Tồn hiển thị (stock)</label>
                                            <form:input path="stock" type="number" min="0" cssClass="form-control" />
                                            <form:errors path="stock" cssClass="text-danger small" />
                                        </div>

                                        <div class="col-md-8 d-flex align-items-end justify-content-end">
                                            <button class="btn btn-primary px-4" type="submit">
                                                <c:choose>
                                                    <c:when test="${formMode=='CREATE'}">Lưu mới</c:when>
                                                    <c:otherwise>Lưu thay đổi</c:otherwise>
                                                </c:choose>
                                            </button>
                                        </div>

                                    </div>
                                </div>
                            </form:form>
                        </div>
                    </div>

                    <jsp:include page="../common/footer.jsp" />

                    <!-- API load danh mục con -->
                    <c:url var="childrenApi" value="/seller/products/categories" />

                    <script>
                        /* Build options helper */
                        function buildOptions(selectEl, items, placeholder) {
                            selectEl.innerHTML = '';
                            var opt0 = document.createElement('option');
                            opt0.value = '';
                            opt0.textContent = placeholder || '-- Chọn danh mục --';
                            selectEl.appendChild(opt0);
                            items.forEach(function (it) {
                                var opt = document.createElement('option');
                                opt.value = it.id;
                                opt.textContent = it.name;
                                selectEl.appendChild(opt);
                            });
                        }

                        document.addEventListener('DOMContentLoaded', function () {
                            var parentSelect = document.getElementById('parentCategory');
                            var childSelect = document.getElementById('category.id') || document.getElementsByName('category.id')[0];
                            var prefillEl = document.getElementById('prefill');
                            var selectedParentId = prefillEl ? (prefillEl.dataset.parent || '') : '';
                            var currentChildId = prefillEl ? (prefillEl.dataset.child || '') : '';

                            async function loadChildren(parentId, selectedChildId) {
                                if (!parentId) {
                                    buildOptions(childSelect, [], '-- Chọn danh mục --');
                                    return;
                                }
                                try {
                                    var url = new URL("${childrenApi}", window.location.origin);
                                    url.searchParams.set('parentId', parentId);
                                    var res = await fetch(url.toString(), { method: 'GET' });
                                    if (!res.ok) throw new Error('Network error');
                                    var data = await res.json();
                                    buildOptions(childSelect, data, '-- Chọn danh mục --');
                                    if (selectedChildId) childSelect.value = String(selectedChildId);
                                } catch (e) {
                                    console.error(e);
                                    buildOptions(childSelect, [], '-- Không tải được danh mục con --');
                                }
                            }

                            parentSelect?.addEventListener('change', function () {
                                loadChildren(parentSelect.value, null);
                            });

                            if (selectedParentId && childSelect && childSelect.options.length <= 1) {
                                loadChildren(selectedParentId, currentChildId);
                            }
                        });
                    </script>

                    <!-- Client-side validation: chống chuỗi toàn khoảng trắng + kiểm pattern/required -->
                    <script>
                        (function () {
                            const form = document.getElementById('productForm');
                            if (!form) return;

                            const nameEl = form.querySelector('[name="name"]');
                            const slugEl = form.querySelector('[name="slug"]');
                            const catEl = form.querySelector('[name="category.id"]');
                            const priceEl = form.querySelector('[name="price"]');
                            const descEl = form.querySelector('[name="description"]');

                            function noBlank(el) {
                                if (!el) return true;
                                const raw = el.value || '';
                                const trimmed = raw.trim();
                                if (raw.length && trimmed.length === 0) { el.setCustomValidity('only-spaces'); return false; }
                                el.setCustomValidity(''); return true;
                            }
                            function vSlug() {
                                if (!slugEl) return true;
                                const v = (slugEl.value || '').trim();
                                const ok = /^[a-z0-9-]{2,120}$/.test(v);
                                if (!ok) { slugEl.setCustomValidity('invalid-slug'); return false; }
                                slugEl.setCustomValidity(''); return true;
                            }
                            function vCategory() {
                                if (!catEl) return true;
                                if (!catEl.value) { catEl.setCustomValidity('required'); return false; }
                                catEl.setCustomValidity(''); return true;
                            }
                            function vPrice() {
                                if (!priceEl) return true;
                                const val = parseFloat(priceEl.value);
                                if (isNaN(val) || val < 0.01) { priceEl.setCustomValidity('price-min'); return false; }
                                priceEl.setCustomValidity(''); return true;
                            }
                            function vDesc() {
                                if (!descEl) return true;
                                const v = descEl.value || '';
                                if (v.length > 2000) { descEl.setCustomValidity('too-long'); return false; }
                                descEl.setCustomValidity(''); return true;
                            }

                            nameEl?.addEventListener('input', () => noBlank(nameEl));
                            slugEl?.addEventListener('input', () => { noBlank(slugEl); vSlug(); });
                            catEl?.addEventListener('change', vCategory);
                            priceEl?.addEventListener('input', vPrice);
                            descEl?.addEventListener('input', vDesc);

                            form.addEventListener('submit', function (e) {
                                const ok = [
                                    noBlank(nameEl),
                                    noBlank(slugEl) && vSlug(),
                                    vCategory(),
                                    vPrice(),
                                    vDesc()
                                ].every(Boolean);

                                if (!form.checkValidity() || !ok) {
                                    e.preventDefault(); e.stopPropagation();
                                    const firstInvalid = form.querySelector(':invalid');
                                    if (firstInvalid) firstInvalid.focus({ preventScroll: false });
                                }
                                form.classList.add('was-validated');
                            });
                        })();
                    </script>
                </body>

                </html>