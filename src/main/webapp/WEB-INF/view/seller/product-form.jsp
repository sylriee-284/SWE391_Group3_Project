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
                    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/product-form.css">
                </head>

                <body>
                    <jsp:include page="../common/navbar.jsp" />
                    <jsp:include page="../common/sidebar.jsp" />

                    <!-- Sidebar Overlay for Mobile -->
                    <div class="sidebar-overlay" id="sidebarOverlay" onclick="toggleSidebar()" role="button"
                        tabindex="0" onKeyPress="if(event.key === 'Enter') toggleSidebar()"></div>

                    <!-- Prefill ids từ Controller -->
                    <span id="prefill" data-parent="${selectedParentId}" data-child="${selectedChildId}"></span>

                    <div class="content" id="content">
                        <div class="product-form-container">
                            <div class="product-form-wrapper">
                                <div class="product-form-header">
                                    <h4 class="product-form-title">
                                        <c:choose>
                                            <c:when test="${formMode=='CREATE'}">Thêm sản phẩm</c:when>
                                            <c:otherwise>Cập nhật sản phẩm #${form.id}</c:otherwise>
                                        </c:choose>
                                    </h4>

                                    <c:url var="backUrl" value="/seller/products">
                                        <c:param name="storeId" value="${storeId}" />
                                    </c:url>
                                    <a class="product-form-back-btn" href="${backUrl}">← Danh sách</a>
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
                                    <c:if test="${not empty _csrf}"><input type="hidden" name="${_csrf.parameterName}"
                                            value="${_csrf.token}" /></c:if>

                                    <div class="product-form-card">
                                        <div class="product-form-body">
                                            <div class="product-form-grid">

                                                <!-- Tên sản phẩm -->
                                                <div class="product-form-group">
                                                    <label class="product-form-label">Tên sản phẩm</label>
                                                    <form:input path="name" cssClass="product-form-control"
                                                        required="required" maxlength="120" data-noblank="true" />
                                                    <form:errors path="name" cssClass="product-form-error" />
                                                </div>

                                                <!-- Slug -->
                                                <div class="product-form-group">
                                                    <label class="product-form-label">Slug (duy nhất trong
                                                        store)</label>
                                                    <form:input path="slug" cssClass="product-form-control"
                                                        required="required" maxlength="120" pattern="^[a-z0-9-]{2,120}$"
                                                        data-noblank="true" />
                                                    <div class="product-form-text">Chỉ a-z, 0-9, dấu gạch ngang (-),
                                                        2–120 ký tự.</div>
                                                    <form:errors path="slug" cssClass="product-form-error" />
                                                </div>

                                                <!-- Danh mục CHA (không bind) -->
                                                <div class="product-form-group">
                                                    <label class="product-form-label">Tùy chọn danh mục</label>
                                                    <select class="product-form-select" id="parentCategory">
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
                                                <div class="product-form-group">
                                                    <label class="product-form-label">Danh mục</label>
                                                    <form:select path="category.id" cssClass="product-form-select"
                                                        required="required">
                                                        <form:option value="">-- Chọn danh mục --</form:option>
                                                        <c:forEach var="c" items="${subCategories}">
                                                            <form:option value="${c.id}">${c.name}</form:option>
                                                        </c:forEach>
                                                    </form:select>
                                                    <form:errors path="category" cssClass="product-form-error" />
                                                    <form:errors path="category.id" cssClass="product-form-error" />
                                                </div>

                                                <!-- Giá (GIỚI HẠN THEO storeMaxListingPrice) -->
                                                <div class="product-form-group">
                                                    <label class="product-form-label">Giá</label>

                                                    <!-- Lấy max từ Model: storeMaxListingPrice -->
                                                    <c:set var="priceMax" value="${storeMaxListingPrice}" />

                                                    <form:input path="price" type="number" step="1" min="0"
                                                        cssClass="product-form-control" required="required"
                                                        max="${priceMax}" />

                                                    <c:if test="${priceMax != null}">
                                                        <div class="product-form-text">
                                                            Tối đa được phép niêm yết:
                                                            <fmt:formatNumber value="${priceMax}" type="currency"
                                                                currencySymbol="₫" />
                                                        </div>
                                                    </c:if>

                                                    <form:errors path="price" cssClass="product-form-error" />
                                                </div>

                                                <!-- Trạng thái: CREATE -> hidden INACTIVE, UPDATE -> select (lock nếu stock <=0) -->
                                                <c:choose>
                                                    <c:when test="${formMode=='CREATE'}">
                                                        <input type="hidden" name="status" value="INACTIVE" />
                                                    </c:when>
                                                    <c:otherwise>
                                                        <c:choose>
                                                            <c:when test="${form.stock == null || form.stock <= 0}">
                                                                <div class="product-form-group">
                                                                    <label class="product-form-label">Trạng thái</label>
                                                                    <form:select path="status"
                                                                        cssClass="product-form-select"
                                                                        disabled="disabled">
                                                                        <form:option value="ACTIVE">ACTIVE</form:option>
                                                                        <form:option value="INACTIVE">INACTIVE
                                                                        </form:option>
                                                                    </form:select>
                                                                    <div class="product-form-text text-danger">Vui lòng
                                                                        nhập hàng trước khi kích hoạt.</div>
                                                                    <form:errors path="status"
                                                                        cssClass="product-form-error" />
                                                                </div>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <div class="product-form-group">
                                                                    <label class="product-form-label">Trạng thái</label>
                                                                    <form:select path="status"
                                                                        cssClass="product-form-select"
                                                                        required="required">
                                                                        <form:option value="ACTIVE">ACTIVE</form:option>
                                                                        <form:option value="INACTIVE">INACTIVE
                                                                        </form:option>
                                                                    </form:select>
                                                                    <form:errors path="status"
                                                                        cssClass="product-form-error" />
                                                                </div>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </c:otherwise>
                                                </c:choose>

                                                <!-- Ảnh đại diện -->
                                                <div class="product-form-group product-form-full-width">
                                                    <label class="product-form-label">Ảnh đại diện sản phẩm</label>
                                                    <input class="product-form-control" type="file" name="imageFiles"
                                                        accept="image/jpeg,image/png" id="imageFileInput" />
                                                    <c:if test="${not empty form.productUrl}">
                                                        <div class="product-image-container" style="margin-top: 10px;">
                                                            <img src="<c:url value='${form.productUrl}'/>"
                                                                alt="Ảnh sản phẩm" class="product-image-preview"
                                                                onerror="handleImageError(this)"
                                                                style="max-width: 300px; max-height: 300px; object-fit: contain; border: 1px solid #ddd; padding: 5px;" />
                                                            <div class="product-form-text">
                                                                Ảnh hiện tại: <strong>${form.productUrl}</strong>
                                                                <br />Nếu không chọn ảnh mới, sẽ giữ nguyên.
                                                            </div>
                                                        </div>
                                                    </c:if>
                                                    <c:if test="${empty form.productUrl}">
                                                        <div class="product-form-text text-muted"
                                                            style="margin-top: 10px;">
                                                            Chưa có ảnh. Vui lòng chọn ảnh để upload.
                                                        </div>
                                                    </c:if>
                                                    <div class="product-form-text">Chỉ JPG/PNG, tối đa 10MB.</div>
                                                    <form:errors path="productUrl" cssClass="product-form-error" />
                                                </div>

                                                <!-- Mô tả -->
                                                <div class="product-form-group product-form-full-width">
                                                    <label class="product-form-label">Mô tả</label>
                                                    <form:textarea path="description" rows="4"
                                                        cssClass="product-form-control" maxlength="200" />
                                                    <form:errors path="description" cssClass="product-form-error" />
                                                </div>

                                                <!-- Stock: CREATE -> không hiển thị input; UPDATE -> chỉ xem -->
                                                <c:choose>
                                                    <c:when test="${formMode=='CREATE'}">
                                                        <!-- nothing -->
                                                    </c:when>
                                                    <c:otherwise>
                                                        <div class="product-form-group">
                                                            <label class="product-form-label">Số lượng hiện tại</label>
                                                            <div class="product-form-plaintext">${form.stock}</div>
                                                            <form:errors path="stock" cssClass="product-form-error" />
                                                        </div>
                                                    </c:otherwise>
                                                </c:choose>

                                                <!-- Submit -->
                                                <div class="product-form-submit-container">
                                                    <button class="product-form-submit-btn" type="submit">
                                                        <c:choose>
                                                            <c:when test="${formMode=='CREATE'}">Lưu mới</c:when>
                                                            <c:otherwise>Lưu thay đổi</c:otherwise>
                                                        </c:choose>
                                                    </button>
                                                </div>

                                            </div>
                                        </div>
                                    </div>
                                </form:form>
                            </div>
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

                    <!-- Toast notifications -->
                    <c:if test="${not empty successMessage}">
                        <script>iziToast.success({ title: 'Success!', message: '${successMessage}', position: 'topRight', timeout: 5000 });</script>
                    </c:if>
                    <c:if test="${not empty errorMessage}">
                        <script>iziToast.error({ title: 'Error!', message: '${errorMessage}', position: 'topRight', timeout: 5000 });</script>
                    </c:if>

                    <script>
                        // Xử lý lỗi khi ảnh không load được
                        function handleImageError(img) {
                            if (!img) return;
                            img.onerror = null; // Tránh loop vô hạn
                            img.src = '<c:url value="/images/others.png"/>';
                            img.style.border = '2px dashed #ccc';
                            img.alt = 'Ảnh không tồn tại';
                        }
                    </script>

                    <!-- Client-side validation (có thêm vPriceMax) -->
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
                                const raw = el.value || ''; const trimmed = raw.trim();
                                if (raw.length === 0) { el.setCustomValidity('Vui lòng nhập nội dung'); return false; }
                                if (trimmed.length === 0) { el.setCustomValidity('Vui lòng nhập nội dung phù hợp'); return false; }
                                el.setCustomValidity(''); return true;
                            }
                            function vSlug() {
                                if (!slugEl) return true;
                                const v = (slugEl.value || '').trim();
                                if (v.length === 0) { slugEl.setCustomValidity('Vui lòng nhập nội dung'); return false; }
                                const ok = /^[a-z0-9-]{2,120}$/.test(v);
                                if (!ok) { slugEl.setCustomValidity('Slug không hợp lệ. Chỉ a-z, 0-9 và - (2-120 ký tự)'); return false; }
                                slugEl.setCustomValidity(''); return true;
                            }
                            function vCategory() {
                                if (!catEl) return true;
                                if (!catEl.value) { catEl.setCustomValidity('Vui lòng nhập nội dung'); return false; }
                                catEl.setCustomValidity(''); return true;
                            }
                            function vPrice() {
                                if (!priceEl) return true;
                                const val = parseFloat(priceEl.value);
                                if (isNaN(val)) { priceEl.setCustomValidity('Vui lòng nhập nội dung'); return false; }
                                if (val < 0.01) { priceEl.setCustomValidity('Giá phải lớn hơn hoặc bằng 0.01'); return false; }
                                priceEl.setCustomValidity(''); return true;
                            }
                            // NEW: kiểm tra vượt trần từ thuộc tính max (nếu có)
                            function vPriceMax() {
                                if (!priceEl) return true;
                                const maxAttr = priceEl.getAttribute('max');
                                if (!maxAttr) { priceEl.setCustomValidity(''); return true; }
                                const maxVal = parseFloat(maxAttr);
                                const val = parseFloat(priceEl.value);
                                if (!isNaN(val) && !isNaN(maxVal) && val > maxVal) {
                                    priceEl.setCustomValidity('Giá vượt mức tối đa cho phép');
                                    return false;
                                }
                                // Không ghi đè lỗi khác nếu đã có; chỉ xóa nếu chúng ta đã đặt
                                if (priceEl.validationMessage === 'Giá vượt mức tối đa cho phép') {
                                    priceEl.setCustomValidity('');
                                }
                                return true;
                            }
                            function vDesc() {
                                if (!descEl) return true;
                                const v = descEl.value || ''; const trimmed = v.trim();
                                if (v.length === 0) { descEl.setCustomValidity('Vui lòng nhập nội dung'); return false; }
                                if (trimmed.length === 0) { descEl.setCustomValidity('Vui lòng nhập nội dung phù hợp'); return false; }
                                if (v.length > 200) { descEl.setCustomValidity('Mô tả tối đa 200 ký tự'); return false; }
                                descEl.setCustomValidity(''); return true;
                            }

                            nameEl?.addEventListener('input', () => noBlank(nameEl));
                            slugEl?.addEventListener('input', () => { noBlank(slugEl); vSlug(); });
                            catEl?.addEventListener('change', vCategory);
                            priceEl?.addEventListener('input', () => { vPrice(); vPriceMax(); });
                            descEl?.addEventListener('input', vDesc);

                            form.addEventListener('submit', function (e) {
                                const validations = [
                                    noBlank(nameEl),
                                    vSlug(),
                                    vCategory(),
                                    vPrice(),
                                    vPriceMax(), // NEW
                                    vDesc()
                                ];

                                const ok = validations.every(Boolean) && form.checkValidity();
                                if (!ok) {
                                    e.preventDefault(); e.stopPropagation();
                                    const firstInvalid = form.querySelector(':invalid');
                                    if (firstInvalid) {
                                        firstInvalid.reportValidity();
                                        firstInvalid.focus({ preventScroll: false });
                                    }
                                }
                                form.classList.add('was-validated');
                            });
                        })();
                    </script>

                    <script>
                        // Toggle sidebar khi nhấn vào nút (same as other pages)
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
                                menuToggle && !menuToggle.contains(event.target)) {
                                toggleSidebar();
                            }
                        });
                    </script>
                </body>

                </html>