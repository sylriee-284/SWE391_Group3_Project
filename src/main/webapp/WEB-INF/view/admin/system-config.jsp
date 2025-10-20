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
                    <!-- Page Content will be inserted here -->
                    <div class="container-fluid">
                        <h1>Welcome to MMO Market System</h1>
                        <p>Your trusted marketplace for digital goods and services.</p>
                    </div>

                    <!-- Filter Section -->
                    <div class="filter-section">
                        <form method="post" action="/admin/system-config/filter">
                            <div class="row filter-row">
                                <div class="col-md-2">
                                    <div class="filter-label">ID</div>
                                    <input type="text" class="form-control" name="id" placeholder="ID"
                                        value="${filterId}">
                                </div>
                                <div class="col-md-2">
                                    <div class="filter-label">Setting Key</div>
                                    <input type="text" class="form-control" name="settingKey" placeholder="Setting Key"
                                        value="${filterSettingKey}">
                                </div>
                                <div class="col-md-2">
                                    <div class="filter-label">Setting Value</div>
                                    <input type="text" class="form-control" name="settingValue"
                                        placeholder="Setting Value" value="${filterSettingValue}">
                                </div>
                                <div class="col-md-3">
                                    <div class="row g-2">
                                        <div class="col">
                                            <div class="filter-label">Created From</div>
                                            <input type="date" class="form-control" name="createdFrom"
                                                value="${filterCreatedFrom}">
                                        </div>
                                        <div class="col">
                                            <div class="filter-label">Created To</div>
                                            <input type="date" class="form-control" name="createdTo"
                                                value="${filterCreatedTo}">
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-3">
                                    <div class="d-flex justify-content-top align-items-center"
                                        style="margin-top: 30px;">
                                        <!--filter button-->
                                        <button type="submit" class="btn btn-outline-secondary me-2">
                                            <i class="bi bi-filter"></i> Filter
                                        </button>
                                        <button type="button" class="btn btn-outline-secondary"
                                            onclick="window.location='/admin/system-config'">
                                            <i class="bi bi-x-circle"></i> Reset
                                        </button>
                                        <button type="button" class="btn btn-success ms-2" data-bs-toggle="modal"
                                            data-bs-target="#addModal">
                                            <i class="bi bi-plus-circle"></i> Add Setting
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </form>

                    </div>

                    <!-- Table Section -->
                    <div class="table-container">
                        <table class="resizable-table" id="resizableTable">
                            <thead>
                                <tr>
                                    <!-- Column 0: Mã trung gian (text) -->
                                    <th class="sortable" style="width: 120px;" data-column="0" data-type="text">
                                        ID
                                        <div class="resizer"></div>
                                    </th>

                                    <!-- Column 2: Setting Key (text) -->
                                    <th class="sortable" style="width: 120px;" data-column="2" data-type="text">
                                        Setting Key
                                        <div class="resizer"></div>
                                    </th>

                                    <!-- Column 3: Setting Value (text) -->
                                    <th class="sortable" style="width: 100px;" data-column="3" data-type="number">
                                        Setting Value
                                        <div class="resizer"></div>
                                    </th>

                                    <!-- Column 4: Created At (date) -->
                                    <th class="sortable" style="width: 100px;" data-column="4" data-type="text">
                                        Created At
                                        <div class="resizer"></div>
                                    </th>

                                    <!-- Column 5: Updated At (date) -->
                                    <th class="sortable" style="width: 120px;" data-column="5" data-type="number">
                                        Updated At
                                        <div class="resizer"></div>
                                    </th>

                                    <!-- Column 6: Action (no sort) -->
                                    <th style="width: 120px;">
                                        Action
                                    </th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach items="${systemSettings}" var="systemSetting">
                                    <tr>
                                        <td>${systemSetting.id}</td>
                                        <td>${systemSetting.settingKey}</td>
                                        <td>${systemSetting.settingValue}</td>
                                        <td>${systemSetting.createdAt}</td>
                                        <td>${systemSetting.updatedAt}</td>
                                        <td>
                                            <!-- View Details Button -->
                                            <button class="btn btn-sm btn-info me-1" title="Xem chi tiết"
                                                onclick="showDetailModal('${systemSetting.id}', '${systemSetting.settingKey}', '${systemSetting.settingValue}', '${systemSetting.createdAt}', '${systemSetting.updatedAt}')">
                                                <i class="fas fa-info-circle"></i>
                                            </button>
                                            <!-- Edit Button -->
                                            <button class="btn btn-sm btn-warning me-1" title="Chỉnh sửa"
                                                onclick="showEditModal('${systemSetting.id}', '${systemSetting.settingKey}', '${systemSetting.settingValue}')">
                                                <i class="fas fa-edit"></i>
                                            </button>
                                            <!-- Delete Button -->
                                            <button class="btn btn-sm btn-danger" title="Xóa"
                                                onclick="showDeleteModal('${systemSetting.id}', '${systemSetting.settingKey}')">
                                                <i class="fas fa-trash"></i>
                                            </button>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>

                    <!-- Pagination -->
                    <div class="pagination-container d-flex justify-content-center">
                        <nav>
                            <ul class="pagination mb-0">
                                <li class="page-item ${currentPage == 0 ? 'disabled' : ''}">
                                    <c:choose>
                                        <c:when test="${filtered}">
                                            <a class="page-link"
                                                href="/admin/system-config/filter?page=0&size=${size}&id=${filterId}&settingKey=${filterSettingKey}&settingValue=${filterSettingValue}&createdFrom=${filterCreatedFrom}&createdTo=${filterCreatedTo}"
                                                aria-label="First">
                                        </c:when>
                                        <c:otherwise>
                                            <a class="page-link" href="/admin/system-config?page=0&size=${size}"
                                                aria-label="First">
                                        </c:otherwise>
                                    </c:choose>
                                    <span aria-hidden="true">&laquo;&laquo;</span>
                                    </a>
                                </li>
                                <li class="page-item ${!hasPrev ? 'disabled' : ''}">
                                    <c:choose>
                                        <c:when test="${filtered}">
                                            <a class="page-link"
                                                href="/admin/system-config/filter?page=${currentPage - 1}&size=${size}&id=${filterId}&settingKey=${filterSettingKey}&settingValue=${filterSettingValue}&createdFrom=${filterCreatedFrom}&createdTo=${filterCreatedTo}"
                                                aria-label="Previous">
                                        </c:when>
                                        <c:otherwise>
                                            <a class="page-link"
                                                href="/admin/system-config?page=${currentPage - 1}&size=${size}"
                                                aria-label="Previous">
                                        </c:otherwise>
                                    </c:choose>
                                    <span aria-hidden="true">&laquo;</span>
                                    </a>
                                </li>
                                <c:forEach var="p" items="${pages}">
                                    <li class="page-item ${p == currentPage ? 'active' : ''}">
                                        <c:choose>
                                            <c:when test="${filtered}">
                                                <a class="page-link"
                                                    href="/admin/system-config/filter?page=${p}&size=${size}&id=${filterId}&settingKey=${filterSettingKey}&settingValue=${filterSettingValue}&createdFrom=${filterCreatedFrom}&createdTo=${filterCreatedTo}">${p
                                                    + 1}</a>
                                            </c:when>
                                            <c:otherwise>
                                                <a class="page-link"
                                                    href="/admin/system-config?page=${p}&size=${size}">${p + 1}</a>
                                            </c:otherwise>
                                        </c:choose>
                                    </li>
                                </c:forEach>
                                <li class="page-item ${!hasNext ? 'disabled' : ''}">
                                    <c:choose>
                                        <c:when test="${filtered}">
                                            <a class="page-link"
                                                href="/admin/system-config/filter?page=${currentPage + 1}&size=${size}&id=${filterId}&settingKey=${filterSettingKey}&settingValue=${filterSettingValue}&createdFrom=${filterCreatedFrom}&createdTo=${filterCreatedTo}"
                                                aria-label="Next">
                                        </c:when>
                                        <c:otherwise>
                                            <a class="page-link"
                                                href="/admin/system-config?page=${currentPage + 1}&size=${size}"
                                                aria-label="Next">
                                        </c:otherwise>
                                    </c:choose>
                                    <span aria-hidden="true">&raquo;</span>
                                    </a>
                                </li>
                                <li class="page-item ${currentPage >= totalPages - 1 ? 'disabled' : ''}">
                                    <c:choose>
                                        <c:when test="${filtered}">
                                            <a class="page-link"
                                                href="/admin/system-config/filter?page=${totalPages - 1}&size=${size}&id=${filterId}&settingKey=${filterSettingKey}&settingValue=${filterSettingValue}&createdFrom=${filterCreatedFrom}&createdTo=${filterCreatedTo}"
                                                aria-label="Last">
                                        </c:when>
                                        <c:otherwise>
                                            <a class="page-link"
                                                href="/admin/system-config?page=${totalPages - 1}&size=${size}"
                                                aria-label="Last">
                                        </c:otherwise>
                                    </c:choose>
                                    <span aria-hidden="true">&raquo;&raquo;</span>
                                    </a>
                                </li>
                            </ul>
                        </nav>
                    </div>

                    <!-- ==================== DETAIL MODAL (View) ==================== -->
                    <div class="modal fade" id="detailModal" tabindex="-1" aria-labelledby="detailModalLabel"
                        aria-hidden="true">
                        <div class="modal-dialog modal-lg modal-dialog-centered">
                            <div class="modal-content">
                                <div class="modal-header bg-info text-white">
                                    <h5 class="modal-title" id="detailModalLabel">
                                        <i class="bi bi-info-circle-fill"></i> Chi tiết cài đặt hệ thống
                                    </h5>
                                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"
                                        aria-label="Close"></button>
                                </div>
                                <div class="modal-body">
                                    <div class="container-fluid">
                                        <div class="row mb-3">
                                            <div class="col-md-6">
                                                <div class="detail-item">
                                                    <label class="detail-label">ID:</label>
                                                    <div class="detail-value" id="detail-id"></div>
                                                </div>
                                            </div>
                                            <div class="col-md-6">
                                                <div class="detail-item">
                                                    <label class="detail-label">Setting Key:</label>
                                                    <div class="detail-value" id="detail-key"></div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="row mb-3">
                                            <div class="col-md-12">
                                                <div class="detail-item">
                                                    <label class="detail-label">Setting Value:</label>
                                                    <div class="detail-value" id="detail-value"></div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="row mb-3">
                                            <div class="col-md-6">
                                                <div class="detail-item">
                                                    <label class="detail-label">Created At:</label>
                                                    <div class="detail-value" id="detail-createdAt"></div>
                                                </div>
                                            </div>
                                            <div class="col-md-6">
                                                <div class="detail-item">
                                                    <label class="detail-label">Updated At:</label>
                                                    <div class="detail-value" id="detail-updatedAt"></div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                                        <i class="bi bi-x-circle"></i> Đóng
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- ==================== ADD MODAL (Create) ==================== -->
                    <div class="modal fade" id="addModal" tabindex="-1" aria-labelledby="addModalLabel"
                        aria-hidden="true">
                        <div class="modal-dialog modal-lg modal-dialog-centered">
                            <div class="modal-content">
                                <div class="modal-header bg-success text-white">
                                    <h5 class="modal-title" id="addModalLabel">
                                        <i class="bi bi-plus-circle-fill"></i> Thêm cài đặt hệ thống
                                    </h5>
                                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"
                                        aria-label="Close"></button>
                                </div>
                                <form method="post" action="/admin/system-config/add">
                                    <div class="modal-body">
                                        <div class="row mb-3">
                                            <div class="col-md-6">
                                                <label for="add-settingKey" class="form-label">Cài đặt <span
                                                        class="text-danger">*</span></label>
                                                <input type="text" class="form-control" id="add-settingKey"
                                                    name="settingKey" required>
                                            </div>
                                            <div class="col-md-6">
                                                <label for="add-settingValue" class="form-label">Giá trị <span
                                                        class="text-danger">*</span></label>
                                                <input type="text" class="form-control" id="add-settingValue"
                                                    name="settingValue" required>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="modal-footer">
                                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                                            <i class="bi bi-x-circle"></i> Hủy
                                        </button>
                                        <button type="submit" class="btn btn-success">
                                            <i class="bi bi-check-circle"></i> Thêm
                                        </button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>

                    <!-- ==================== EDIT MODAL (Update) ==================== -->
                    <div class="modal fade" id="editModal" tabindex="-1" aria-labelledby="editModalLabel"
                        aria-hidden="true">
                        <div class="modal-dialog modal-lg modal-dialog-centered">
                            <div class="modal-content">
                                <div class="modal-header bg-warning text-dark">
                                    <h5 class="modal-title" id="editModalLabel">
                                        <i class="bi bi-pencil-fill"></i> Chỉnh sửa cài đặt hệ thống
                                    </h5>
                                    <button type="button" class="btn-close" data-bs-dismiss="modal"
                                        aria-label="Close"></button>
                                </div>
                                <form method="post" action="/admin/system-config/update" id="editForm">
                                    <div class="modal-body">
                                        <input type="hidden" id="edit-id" name="id">
                                        <div class="row mb-3">
                                            <div class="col-md-6">
                                                <label for="edit-settingKey" class="form-label">Cài đặt <span
                                                        class="text-danger">*</span></label>
                                                <input type="text" class="form-control" id="edit-settingKey"
                                                    name="settingKey" required>
                                            </div>
                                            <div class="col-md-6">
                                                <label for="edit-settingValue" class="form-label">Giá trị <span
                                                        class="text-danger">*</span></label>
                                                <input type="text" class="form-control" id="edit-settingValue"
                                                    name="settingValue" required>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="modal-footer">
                                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                                            <i class="bi bi-x-circle"></i> Hủy
                                        </button>
                                        <button type="submit" class="btn btn-warning">
                                            <i class="bi bi-check-circle"></i> Cập nhật
                                        </button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>

                    <!-- ==================== DELETE MODAL (Confirm Delete) ==================== -->
                    <div class="modal fade" id="deleteModal" tabindex="-1" aria-labelledby="deleteModalLabel"
                        aria-hidden="true">
                        <div class="modal-dialog modal-dialog-centered">
                            <div class="modal-content">
                                <div class="modal-header bg-danger text-white">
                                    <h5 class="modal-title" id="deleteModalLabel">
                                        <i class="bi bi-exclamation-triangle-fill"></i> Xác nhận xóa cài đặt hệ thống
                                    </h5>
                                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"
                                        aria-label="Close"></button>
                                </div>
                                <form method="post" action="/admin/system-config/delete">
                                    <div class="modal-body">
                                        <div class="detail-item mb-2">
                                            <label class="detail-label">ID:</label>
                                            <div class="detail-value" id="delete-id-text"></div>
                                        </div>
                                        <div class="detail-item mb-2">
                                            <label class="detail-label">Setting Key:</label>
                                            <div class="detail-value text-danger fw-bold" id="delete-key-text"></div>
                                        </div>
                                        <input type="hidden" id="delete-id" name="id">
                                        <p class="text-muted mt-2 mb-0"><small>Hành động này không thể hoàn tác!</small>
                                        </p>
                                    </div>
                                    <div class="modal-footer">
                                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                                            <i class="bi bi-x-circle"></i> Hủy
                                        </button>
                                        <button type="submit" class="btn btn-danger">
                                            <i class="bi bi-trash-fill"></i> Xóa
                                        </button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>


                </div>

                <!-- Include Footer s-->
                <jsp:include page="../common/footer.jsp" />

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

                    // Show detail modal for SystemSetting
                    function showDetailModal(id, key, value, createdAt, updatedAt) {
                        try {
                            var idEl = document.getElementById('detail-id');
                            var keyEl = document.getElementById('detail-key');
                            var valEl = document.getElementById('detail-value');
                            var createdEl = document.getElementById('detail-createdAt');
                            var updatedEl = document.getElementById('detail-updatedAt');

                            if (idEl) idEl.textContent = id ?? '';
                            if (keyEl) keyEl.textContent = key ?? '';
                            if (valEl) valEl.textContent = value ?? '';
                            if (createdEl) createdEl.textContent = createdAt ?? '';
                            if (updatedEl) updatedEl.textContent = updatedAt ?? '';

                            var modalEl = document.getElementById('detailModal');
                            if (modalEl && window.bootstrap) {
                                var modal = new bootstrap.Modal(modalEl);
                                modal.show();
                            } else if (modalEl) {
                                // Fallback if bootstrap namespace not found
                                modalEl.classList.add('show');
                                modalEl.style.display = 'block';
                                modalEl.removeAttribute('aria-hidden');
                            }
                        } catch (e) {
                            console.error('Failed to open detail modal', e);
                        }
                    }

                    // Show edit modal for SystemSetting
                    function showEditModal(id, key, value) {
                        try {
                            var idInput = document.getElementById('edit-id');
                            var keyInput = document.getElementById('edit-settingKey');
                            var valueInput = document.getElementById('edit-settingValue');

                            if (idInput) idInput.value = id ?? '';
                            if (keyInput) keyInput.value = key ?? '';
                            if (valueInput) valueInput.value = value ?? '';

                            var modalEl = document.getElementById('editModal');
                            if (modalEl && window.bootstrap) {
                                var modal = new bootstrap.Modal(modalEl);
                                modal.show();
                            } else if (modalEl) {
                                modalEl.classList.add('show');
                                modalEl.style.display = 'block';
                                modalEl.removeAttribute('aria-hidden');
                            }
                        } catch (e) {
                            console.error('Failed to open edit modal', e);
                        }
                    }

                    // Show delete modal for SystemSetting
                    function showDeleteModal(id, key) {
                        try {
                            var idText = document.getElementById('delete-id-text');
                            var keyText = document.getElementById('delete-key-text');
                            var idHidden = document.getElementById('delete-id');
                            if (idText) idText.textContent = id ?? '';
                            if (keyText) keyText.textContent = key ?? '';
                            if (idHidden) idHidden.value = id ?? '';

                            var modalEl = document.getElementById('deleteModal');
                            if (modalEl && window.bootstrap) {
                                var modal = new bootstrap.Modal(modalEl);
                                modal.show();
                            } else if (modalEl) {
                                modalEl.classList.add('show');
                                modalEl.style.display = 'block';
                                modalEl.removeAttribute('aria-hidden');
                            }
                        } catch (e) {
                            console.error('Failed to open delete modal', e);
                        }
                    }
                </script>
            </body>

            </html>