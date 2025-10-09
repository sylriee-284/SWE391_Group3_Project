<%@ page contentType="text/html;charset=UTF-8" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

        <jsp:include page="../common/navbar.jsp" />
        <div class="container-fluid">
            <div class="row">
                <jsp:include page="../common/sidebar.jsp" />

                <main class="col-md-9 ms-sm-auto col-lg-10 px-4">
                    <div class="d-flex justify-content-between align-items-center mt-4 mb-3">
                        <h3 class="m-0">${formTitle}</h3>
                        <a class="btn btn-outline-secondary" href="<c:url value='/admin/users'/>">← Quay lại</a>
                    </div>

                    <div class="card shadow-sm">
                        <div class="card-body">
                            <c:set var="isEdit" value="${not empty user.id}" />

                            <%-- build action cho create/update --%>
                                <c:set var="formAction" value="/admin/users" />
                                <c:if test="${isEdit}">
                                    <c:set var="formAction" value="/admin/users/update/${user.id}" />
                                </c:if>

                                <form method="post" action="${pageContext.request.contextPath}${formAction}">
                                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />

                                    <div class="row g-3">
                                        <div class="col-md-6">
                                            <label class="form-label">Username</label>
                                            <input name="username" class="form-control" value="${user.username}"
                                                required />
                                        </div>

                                        <div class="col-md-6">
                                            <label class="form-label">Email</label>
                                            <input type="email" name="email" class="form-control" value="${user.email}"
                                                required />
                                        </div>

                                        <div class="col-md-6">
                                            <label class="form-label">Họ tên</label>
                                            <input name="fullName" class="form-control" value="${user.fullName}" />
                                        </div>

                                        <div class="col-md-3">
                                            <label class="form-label">Trạng thái</label>
                                            <select name="status" class="form-select">
                                                <option value="ACTIVE" ${user.status=='ACTIVE' ? 'selected' : '' }>
                                                    ACTIVE</option>
                                                <option value="INACTIVE" ${user.status=='INACTIVE' ? 'selected' : '' }>
                                                    INACTIVE</option>
                                            </select>
                                        </div>

                                        <div class="col-md-3">
                                            <label class="form-label">Số dư (VND)</label>
                                            <input type="number" min="0" step="1" name="balance" class="form-control"
                                                value="${user.balance}" />
                                        </div>
                                    </div>

                                    <div class="mt-4">
                                        <button class="btn btn-primary" type="submit">
                                            <c:out value="${isEdit ? 'Cập nhật' : 'Tạo mới'}" />
                                        </button>
                                        <a class="btn btn-light ms-2" href="<c:url value='/admin/users'/>">Hủy</a>
                                    </div>
                                </form>
                        </div>
                    </div>
                </main>
            </div>
        </div>
        <jsp:include page="../common/footer.jsp" />