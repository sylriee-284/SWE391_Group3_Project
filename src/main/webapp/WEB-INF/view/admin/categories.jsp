<%@ page contentType="text/html;charset=UTF-8" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

        <jsp:include page="../common/navbar.jsp" />
        <div class="container-fluid">
            <div class="row">
                <jsp:include page="../common/sidebar.jsp" />

                <main class="col-md-9 ms-sm-auto col-lg-10 px-4">
                    <div class="d-flex justify-content-between align-items-center mt-4 mb-3">
                        <h3 class="m-0">Quản lý danh mục</h3>
                        <a class="btn btn-primary" href="<c:url value='/admin/categories/create'/>">+ Thêm danh mục</a>
                    </div>

                    <!-- Flash -->
                    <c:if test="${not empty success}">
                        <div class="alert alert-success">${success}</div>
                    </c:if>

                    <div class="card shadow-sm">
                        <div class="card-body p-0">
                            <div class="table-responsive">
                                <table class="table table-hover align-middle mb-0">
                                    <thead class="table-light">
                                        <tr>
                                            <th style="width:80px;">ID</th>
                                            <th>Tên</th>
                                            <th>Mô tả</th>
                                            <th style="width:120px;">Trạng thái</th>
                                            <th style="width:170px;" class="text-center">Thao tác</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="cItem" items="${categories}">
                                            <tr>
                                                <td>${cItem.id}</td>
                                                <td>${cItem.name}</td>
                                                <td class="text-muted">${cItem.description}</td>
                                                <td>
                                                    <span
                                                        class="badge ${cItem.isDeleted ? 'bg-secondary' : 'bg-success'}">
                                                        <c:out value="${cItem.isDeleted ? 'INACTIVE' : 'ACTIVE'}" />
                                                    </span>
                                                </td>
                                                <td class="text-center">
                                                    <a class="btn btn-sm btn-outline-primary me-2"
                                                        href="<c:url value='/admin/categories/edit/${cItem.id}'/>">Sửa</a>

                                                    <form class="d-inline" method="post"
                                                        action="<c:url value='/admin/categories/delete/${cItem.id}'/>"
                                                        onsubmit="return confirm('Xóa mềm danh mục #${cItem.id}?');">
                                                        <input type="hidden" name="${_csrf.parameterName}"
                                                            value="${_csrf.token}" />
                                                        <button class="btn btn-sm btn-outline-danger"
                                                            type="submit">Xóa</button>
                                                    </form>
                                                </td>
                                            </tr>
                                        </c:forEach>

                                        <c:if test="${empty categories}">
                                            <tr>
                                                <td colspan="5" class="text-center py-4 text-muted">Chưa có danh mục.
                                                </td>
                                            </tr>
                                        </c:if>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </main>
            </div>
        </div>
        <jsp:include page="../common/footer.jsp" />