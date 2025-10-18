<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8" />
                <title>
                    <c:out
                        value="${pageTitle != null ? pageTitle : (category.id==null?'Thêm danh mục':'Sửa danh mục')}" />
                    - MMO Market System
                </title>
                <jsp:include page="/WEB-INF/view/common/head.jsp" />
            </head>

            <body>
                <jsp:include page="/WEB-INF/view/common/navbar.jsp" />
                <jsp:include page="/WEB-INF/view/common/sidebar.jsp" />
                <div class="sidebar-overlay" id="sidebarOverlay" onclick="toggleSidebar()"></div>

                <div class="main-content" id="mainContent">
                    <div class="container-fluid">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <h4 class="mb-0">
                                <c:choose>
                                    <c:when test="${category.parentId == null}">
                                        ${category.id == null ? 'Thêm danh mục CHA' : 'Sửa danh mục CHA'}
                                    </c:when>
                                    <c:otherwise>
                                        ${category.id == null ? 'Thêm danh mục con' : 'Sửa danh mục con'}
                                    </c:otherwise>
                                </c:choose>
                            </h4>
                            <a class="btn btn-outline-secondary" href="<c:url value='/admin/categories'/>">← Quay
                                lại</a>
                        </div>

                        <!-- Xác định action theo controller -->
                        <c:choose>
                            <c:when test="${category.id != null}">
                                <c:set var="formAction" value="/admin/categories/update/${category.id}" />
                            </c:when>
                            <c:when test="${category.parentId != null}">
                                <c:set var="formAction"
                                    value="/admin/categories/${category.parentId}/subcategories/create" />
                            </c:when>
                            <c:otherwise>
                                <c:set var="formAction" value="/admin/categories/create" />
                            </c:otherwise>
                        </c:choose>

                        <div class="card p-3 mb-4">
                            <form method="post" action="<c:url value='${formAction}'/>">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                                <c:if test="${category.id != null}">
                                    <input type="hidden" name="id" value="${category.id}" />
                                </c:if>
                                <c:if test="${category.parentId != null}">
                                    <input type="hidden" name="parentId" value="${category.parentId}" />
                                </c:if>

                                <div class="row g-3">
                                    <div class="col-12">
                                        <label class="form-label">Tên danh mục <span
                                                class="text-danger">*</span></label>
                                        <input type="text" class="form-control" name="name" value="${category.name}"
                                            required>
                                    </div>
                                    <div class="col-12">
                                        <label class="form-label">Mô tả</label>
                                        <textarea class="form-control" rows="4"
                                            name="description">${category.description}</textarea>
                                    </div>
                                    <div class="col-12">
                                        <label class="form-label me-2">Trạng thái:</label>
                                        <span class="badge ${category.isActive ? 'bg-success' : 'bg-secondary'}">
                                            ${category.isActive ? 'ACTIVE' : 'INACTIVE'}
                                        </span>
                                    </div>
                                </div>

                                <div class="d-flex gap-2 mt-4">
                                    <button type="submit" class="btn btn-primary">${category.id == null ? 'Tạo mới' :
                                        'Cập nhật'}</button>
                                    <a class="btn btn-secondary" href="<c:url value='/admin/categories'/>">Hủy</a>
                                </div>
                            </form>
                        </div>

                        <!-- BẢNG CON khi đang sửa CHA -->
                        <c:if test="${category.id != null && category.parentId == null}">
                            <div class="d-flex justify-content-between align-items-center mb-2">
                                <h5 class="mb-0">Danh mục con của: <strong>
                                        <c:out value="${category.name}" />
                                    </strong></h5>
                                <a href="<c:url value='/admin/categories/${category.id}/subcategories/add'/>"
                                    class="btn btn-primary">
                                    + Thêm danh mục con
                                </a>
                            </div>

                            <div class="table-container">
                                <table class="resizable-table" id="resizableTable">
                                    <thead>
                                        <tr>
                                            <th style="width: 80px">ID<div class="resizer"></div>
                                            </th>
                                            <th style="width: 320px">Tên<div class="resizer"></div>
                                            </th>
                                            <th style="width: 420px">Mô tả<div class="resizer"></div>
                                            </th>
                                            <th style="width: 140px">Trạng thái<div class="resizer"></div>
                                            </th>
                                            <th style="width: 240px">Thao tác</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="c" items="${children}">
                                            <tr>
                                                <td>${c.id}</td>
                                                <td>${c.name}</td>
                                                <td>
                                                    <c:out value="${c.description}" />
                                                </td>
                                                <td>
                                                    <span class="badge ${c.isActive ? 'bg-success' : 'bg-secondary'}">
                                                        ${c.isActive ? 'ACTIVE' : 'INACTIVE'}
                                                    </span>
                                                </td>
                                                <td class="d-flex gap-2">
                                                    <a class="btn btn-sm btn-primary"
                                                        href="<c:url value='/admin/categories/edit/${c.id}'/>">Sửa</a>

                                                    <!-- Toggle con: POST + CSRF -->
                                                    <form method="post"
                                                        action="<c:url value='/admin/categories/toggle/${c.id}'/>"
                                                        class="d-inline">
                                                        <input type="hidden" name="${_csrf.parameterName}"
                                                            value="${_csrf.token}" />
                                                        <button
                                                            class="btn btn-sm ${c.isActive ? 'btn-warning' : 'btn-success'}"
                                                            type="submit">
                                                            ${c.isActive ? 'Tắt' : 'Bật'}
                                                        </button>
                                                    </form>

                                                    <!-- Xoá con: POST + CSRF qua modal -->
                                                    <button class="btn btn-sm btn-danger" data-id="${c.id}"
                                                        data-name="${fn:escapeXml(c.name)}"
                                                        onclick="openDeleteChild(this)">Xoá</button>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </c:if>
                    </div>
                </div>

                <!-- MODAL XOÁ dùng chung -->
                <div class="modal fade" id="deleteModal" tabindex="-1" aria-hidden="true">
                    <div class="modal-dialog modal-dialog-centered">
                        <form class="modal-content" method="post" id="deleteChildForm">
                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                            <div class="modal-header bg-danger text-white">
                                <h5 class="modal-title">Xác nhận xóa</h5>
                                <button type="button" class="btn-close btn-close-white"
                                    data-bs-dismiss="modal"></button>
                            </div>
                            <div class="modal-body">
                                <p>Bạn có chắc muốn xoá: <strong id="delName"></strong></p>
                            </div>
                            <div class="modal-footer">
                                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                                <button type="submit" class="btn btn-danger">OK</button>
                            </div>
                        </form>
                    </div>
                </div>

                <jsp:include page="/WEB-INF/view/common/footer.jsp" />
                <script>
                    function toggleSidebar() {
                        const s = document.getElementById('sidebar'), m = document.getElementById('mainContent');
                        if (s) s.classList.toggle('collapsed'); if (m) m.classList.toggle('expanded');
                    }
                    function openDeleteChild(btn) {
                        document.getElementById('delName').innerText = btn.dataset.name || '';
                        document.getElementById('deleteChildForm').action =
                            '<c:url value="/admin/categories/delete/"/>' + btn.dataset.id;
                        new bootstrap.Modal(document.getElementById('deleteModal')).show();
                    }
                </script>
            </body>

            </html>