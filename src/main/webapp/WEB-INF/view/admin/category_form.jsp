<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8" />
                <title>
                    <c:choose>
                        <c:when test="${category.id == null}">
                            ${category.parentId == null ? 'Thêm danh mục CHA' : 'Thêm danh mục con'}
                        </c:when>
                        <c:otherwise>
                            ${category.parentId == null ? 'Sửa danh mục CHA' : 'Sửa danh mục con'}
                        </c:otherwise>
                    </c:choose> - MMO Market System
                </title>
                <jsp:include page="/WEB-INF/view/common/head.jsp" />
                <style>
                    #pageWrap {
                        padding-top: calc(var(--nav-h, 64px) + 16px);
                        padding-bottom: 24px;
                    }
                </style>
            </head>

            <body>
                <jsp:include page="/WEB-INF/view/common/navbar.jsp" />
                <jsp:include page="/WEB-INF/view/common/sidebar.jsp" />
                <div class="sidebar-overlay" id="sidebarOverlay" onclick="toggleSidebar()"></div>

                <div id="pageWrap">
                    <div class="container-fluid">

                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <h4 class="mb-0">
                                <c:choose>
                                    <c:when test="${category.id == null}">
                                        ${category.parentId == null ? 'Thêm danh mục CHA' : 'Thêm danh mục con'}
                                    </c:when>
                                    <c:otherwise>
                                        ${category.parentId == null ? 'Sửa danh mục CHA' : 'Sửa danh mục con'}
                                    </c:otherwise>
                                </c:choose>
                            </h4>
                            <a class="btn btn-outline-secondary" href="<c:url value='${category.parentId != null ? ("
                                /admin/categories/"+category.parentId+"/subcategories") : "/admin/categories" }' />">←
                            Quay lại</a>
                        </div>

                        <!-- Xác định action -->
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
                                    <c:if test="${category.id != null}">
                                        <div class="col-12">
                                            <label class="form-label me-2">Trạng thái:</label>
                                            <span class="badge ${category.isActive?'bg-success':'bg-secondary'}">
                                                ${category.isActive?'ACTIVE':'INACTIVE'}
                                            </span>
                                        </div>
                                    </c:if>
                                </div>

                                <div class="d-flex gap-2 mt-4">
                                    <button type="submit" class="btn btn-primary">${category.id == null ? 'Tạo mới' :
                                        'Cập nhật'}</button>
                                    <a class="btn btn-secondary" href="<c:url value='${category.parentId != null ? ("
                                        /admin/categories/"+category.parentId+"/subcategories") : "/admin/categories"
                                        }' />">Hủy</a>
                                </div>
                            </form>
                        </div>

                        <!-- Bảng con khi sửa CHA -->
                        <c:if test="${category.id != null && category.parentId == null && not empty children}">
                            <div class="d-flex justify-content-between align-items-center mb-2">
                                <h5 class="mb-0">Danh mục con của: <strong>
                                        <c:out value="${category.name}" />
                                    </strong></h5>
                                <a href="<c:url value='/admin/categories/${category.id}/subcategories/add'/>"
                                    class="btn btn-primary">+ Thêm danh mục con</a>
                            </div>

                            <div class="table-container">
                                <table class="table table-hover align-middle">
                                    <thead class="table-light">
                                        <tr>
                                            <th style="width:80px">ID</th>
                                            <th style="width:320px">Tên</th>
                                            <th style="width:420px">Mô tả</th>
                                            <th style="width:140px">Trạng thái</th>
                                            <th style="width:240px">Thao tác</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="c" items="${children}">
                                            <tr>
                                                <td>${c.id}</td>
                                                <td>
                                                    <c:out value="${c.name}" />
                                                </td>
                                                <td>
                                                    <c:out value="${c.description}" />
                                                </td>
                                                <td><span
                                                        class="badge ${c.isActive?'bg-success':'bg-secondary'}">${c.isActive?'ACTIVE':'INACTIVE'}</span>
                                                </td>
                                                <td class="d-flex gap-2">
                                                    <a class="btn btn-sm btn-primary"
                                                        href="<c:url value='/admin/categories/edit/${c.id}'/>">Sửa</a>
                                                    <form method="post"
                                                        action="<c:url value='/admin/categories/toggle/${c.id}'/>"
                                                        class="d-inline">
                                                        <input type="hidden" name="${_csrf.parameterName}"
                                                            value="${_csrf.token}" />
                                                        <button
                                                            class="btn btn-sm ${c.isActive?'btn-warning':'btn-success'}"
                                                            type="submit">
                                                            ${c.isActive?'Tắt':'Bật'}
                                                        </button>
                                                    </form>
                                                    <form method="post"
                                                        action="<c:url value='/admin/categories/delete/${c.id}'/>"
                                                        class="d-inline"
                                                        onsubmit="return confirm('Xoá '+ '${c.name}' +' ?');">
                                                        <input type="hidden" name="${_csrf.parameterName}"
                                                            value="${_csrf.token}" />
                                                        <button class="btn btn-sm btn-danger" type="submit">Xoá</button>
                                                    </form>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </c:if>

                    </div>
                </div>

                <jsp:include page="/WEB-INF/view/common/footer.jsp" />
                <script>
                    (function () {
                        const wrap = document.getElementById('pageWrap');
                        const nav = document.querySelector('.navbar');
                        const overlay = document.getElementById('sidebarOverlay');
                        function applyOffsets() {
                            if (nav) document.documentElement.style.setProperty('--nav-h', nav.getBoundingClientRect().height + 'px');
                        }
                        window.toggleSidebar = function () {
                            const s = document.getElementById('sidebar');
                            if (s) s.classList.toggle('collapsed');
                            if (wrap) wrap.classList.toggle('expanded');
                            if (overlay) overlay.classList.toggle('show');
                        };
                        window.addEventListener('load', applyOffsets);
                        window.addEventListener('resize', applyOffsets);
                    })();
                </script>
            </body>

            </html>