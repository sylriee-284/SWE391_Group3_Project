<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8" />
                <title>
                    <c:out
                        value="${pageTitle != null ? pageTitle : (parentCategory == null ? 'Quản lý danh mục (CHA)' : ('Danh mục con của: ' += parentCategory.name))}" />
                    - MMO Market System
                </title>
                <jsp:include page="/WEB-INF/view/common/head.jsp" />
            </head>

            <body>
                <!-- Header + Sidebar -->
                <jsp:include page="/WEB-INF/view/common/navbar.jsp" />
                <jsp:include page="/WEB-INF/view/common/sidebar.jsp" />
                <div class="sidebar-overlay" id="sidebarOverlay" onclick="toggleSidebar()"></div>

                <!-- Main -->
                <div class="main-content" id="mainContent">
                    <div class="container-fluid">

                        <!-- Title + Add child (khi đang xem CON) -->
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <h4 class="mb-0">
                                <c:choose>
                                    <c:when test="${parentCategory == null}">
                                        Quản lý danh mục (CHA)
                                    </c:when>
                                    <c:otherwise>
                                        Danh mục con của: <strong>
                                            <c:out value="${parentCategory.name}" />
                                        </strong>
                                    </c:otherwise>
                                </c:choose>
                            </h4>

                            <c:if test="${parentCategory != null}">
                                <a href="<c:url value='/admin/categories/${parentCategory.id}/subcategories/add'/>"
                                    class="btn btn-primary">+ Thêm danh mục con</a>
                            </c:if>
                        </div>

                        <!-- Filters (nhẹ) -->
                        <div class="filter-section">
                            <form method="get" action="">
                                <div class="row filter-row">
                                    <div class="col-md-6">
                                        <div class="filter-label">Tìm theo tên</div>
                                        <input name="q" value="${fn:escapeXml(param.q)}" type="text"
                                            class="form-control" placeholder="Tên danh mục...">
                                    </div>
                                    <div class="col-md-3">
                                        <div class="filter-label">Trạng thái</div>
                                        <select name="active" class="form-select">
                                            <option value="">Tất cả</option>
                                            <option value="true" <c:if test="${param.active=='true'}">selected</c:if>
                                                >Active</option>
                                            <option value="false" <c:if test="${param.active=='false'}">selected</c:if>
                                                >Inactive</option>
                                        </select>
                                    </div>
                                    <div class="col-md-3 d-flex align-items-end gap-2">
                                        <button class="btn btn-primary" type="submit">Lọc</button>
                                        <a class="btn btn-outline-secondary"
                                            href="<c:url value='${parentCategory == null ? " /admin/categories" :
                                            ("/admin/categories/" +=parentCategory.id +="/subcategories" )}' />">
                                        Bỏ lọc
                                        </a>
                                    </div>
                                </div>
                            </form>
                        </div>

                        <!-- Table -->
                        <div class="table-container">
                            <table class="resizable-table" id="resizableTable">
                                <thead>
                                    <tr>
                                        <th style="width:80px">ID<div class="resizer"></div>
                                        </th>
                                        <th style="width:380px">Tên danh mục<div class="resizer"></div>
                                        </th>
                                        <th style="width:420px">Mô tả<div class="resizer"></div>
                                        </th>
                                        <th style="width:140px">Trạng thái<div class="resizer"></div>
                                        </th>
                                        <th style="width:220px">Hành động</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="c" items="${categories}">
                                        <tr>
                                            <td>${c.id}</td>
                                            <td>
                                                <c:out value="${c.name}" />
                                            </td>
                                            <td>
                                                <c:out value="${c.description}" />
                                            </td>
                                            <td>
                                                <span class="badge ${c.isActive ? 'bg-success' : 'bg-secondary'}">
                                                    ${c.isActive ? 'ACTIVE' : 'INACTIVE'}
                                                </span>
                                            </td>
                                            <td class="d-flex gap-2">
                                                <!-- Chi tiết / Sửa -->
                                                <a class="btn btn-sm btn-primary"
                                                    href="<c:url value='/admin/categories/edit/${c.id}'/>">Chi tiết</a>

                                                <!-- Toggle: POST /toggle/{id} -->
                                                <form method="post"
                                                    action="<c:url value='/admin/categories/toggle/${c.id}'/>"
                                                    class="d-inline">
                                                    <input type="hidden" name="${_csrf.parameterName}"
                                                        value="${_csrf.token}" />
                                                    <button type="submit"
                                                        class="btn btn-sm ${c.isActive ? 'btn-warning' : 'btn-success'}">
                                                        ${c.isActive ? 'Tắt' : 'Bật'}
                                                    </button>
                                                </form>

                                                <!-- Xoá: POST /delete/{id} -->
                                                <button class="btn btn-sm btn-danger" data-id="${c.id}"
                                                    data-name="${fn:escapeXml(c.name)}"
                                                    onclick="openDeleteCategory(this)">Xoá</button>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>

                        <!-- Pagination (inline, không file riêng) -->
                        <c:if test="${totalPages != null && totalPages > 1}">
                            <c:set var="baseUrl" value="${parentCategory == null
                         ? '/admin/categories'
                         : '/admin/categories/' += parentCategory.id += '/subcategories'}" />
                            <nav class="mt-3">
                                <ul class="pagination justify-content-center">
                                    <!-- First / Prev -->
                                    <li class="page-item ${currentPage <= 1 ? 'disabled' : ''}">
                                        <a class="page-link"
                                            href="${pageContext.request.contextPath}${baseUrl}?page=1&size=${pageSize}">&laquo;</a>
                                    </li>
                                    <li class="page-item ${currentPage <= 1 ? 'disabled' : ''}">
                                        <a class="page-link"
                                            href="${pageContext.request.contextPath}${baseUrl}?page=${currentPage-1}&size=${pageSize}">&lsaquo;</a>
                                    </li>

                                    <!-- Window current-2 .. current+2 -->
                                    <c:set var="start" value="${currentPage-2 < 1 ? 1 : currentPage-2}" />
                                    <c:set var="end"
                                        value="${currentPage+2 > totalPages ? totalPages : currentPage+2}" />
                                    <c:forEach begin="${start}" end="${end}" var="p">
                                        <li class="page-item ${p == currentPage ? 'active' : ''}">
                                            <a class="page-link"
                                                href="${pageContext.request.contextPath}${baseUrl}?page=${p}&size=${pageSize}">${p}</a>
                                        </li>
                                    </c:forEach>

                                    <!-- Next / Last -->
                                    <li class="page-item ${currentPage >= totalPages ? 'disabled' : ''}">
                                        <a class="page-link"
                                            href="${pageContext.request.contextPath}${baseUrl}?page=${currentPage+1}&size=${pageSize}">&rsaquo;</a>
                                    </li>
                                    <li class="page-item ${currentPage >= totalPages ? 'disabled' : ''}">
                                        <a class="page-link"
                                            href="${pageContext.request.contextPath}${baseUrl}?page=${totalPages}&size=${pageSize}">&raquo;</a>
                                    </li>
                                </ul>
                            </nav>
                        </c:if>

                    </div>
                </div>

                <!-- Delete Modal -->
                <div class="modal fade" id="deleteCategoryModal" tabindex="-1" aria-hidden="true">
                    <div class="modal-dialog modal-dialog-centered">
                        <form class="modal-content" method="post" id="deleteForm">
                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                            <div class="modal-header bg-danger text-white">
                                <h5 class="modal-title">Xác nhận xóa</h5>
                                <button type="button" class="btn-close btn-close-white"
                                    data-bs-dismiss="modal"></button>
                            </div>
                            <div class="modal-body">
                                <p>Bạn có chắc chắn muốn xóa danh mục:</p>
                                <h5 class="text-danger" id="deleteCategoryName"></h5>
                            </div>
                            <div class="modal-footer">
                                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                                <button type="submit" class="btn btn-danger">Xóa</button>
                            </div>
                        </form>
                    </div>
                </div>

                <!-- Footer + Scripts -->
                <jsp:include page="/WEB-INF/view/common/footer.jsp" />
                <script>
                    function toggleSidebar() {
                        const s = document.getElementById('sidebar'), m = document.getElementById('mainContent');
                        if (s) s.classList.toggle('collapsed');
                        if (m) m.classList.toggle('expanded');
                    }
                    function openDeleteCategory(btn) {
                        const id = btn.dataset.id, name = btn.dataset.name || '';
                        document.getElementById('deleteCategoryName').innerText = name;
                        document.getElementById('deleteForm').action =
                            '<c:url value="/admin/categories/delete/"/>' + id;
                        new bootstrap.Modal(document.getElementById('deleteCategoryModal')).show();
                    }
                </script>
            </body>

            </html>