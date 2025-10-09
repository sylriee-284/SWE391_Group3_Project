<%@ page contentType="text/html;charset=UTF-8" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

        <jsp:include page="../common/navbar.jsp" />
        <div class="container-fluid">
            <div class="row">
                <jsp:include page="../common/sidebar.jsp" />

                <main class="col-md-9 ms-sm-auto col-lg-10 px-4">
                    <div class="d-flex justify-content-between align-items-center mt-4 mb-3">
                        <h3 class="m-0">${formTitle}</h3>
                        <a class="btn btn-outline-secondary" href="<c:url value='/admin/categories'/>">← Quay lại</a>
                    </div>

                    <div class="card shadow-sm">
                        <div class="card-body">
                            <c:set var="isEdit" value="${not empty category.id}" />

                            <%-- build đúng action cho create / update --%>
                                <c:set var="formAction" value="/admin/categories" />
                                <c:if test="${isEdit}">
                                    <c:set var="formAction" value="/admin/categories/update/${category.id}" />
                                </c:if>

                                <form method="post" action="${pageContext.request.contextPath}${formAction}">
                                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />

                                    <div class="row g-3">
                                        <div class="col-md-6">
                                            <label class="form-label">Tên danh mục</label>
                                            <input name="name" class="form-control" value="${category.name}" required />
                                        </div>

                                        <div class="col-md-12">
                                            <label class="form-label">Mô tả</label>
                                            <textarea name="description" rows="3"
                                                class="form-control">${category.description}</textarea>
                                        </div>
                                    </div>

                                    <div class="mt-4">
                                        <button class="btn btn-primary" type="submit">
                                            <c:out value="${isEdit ? 'Cập nhật' : 'Tạo mới'}" />
                                        </button>
                                        <a class="btn btn-light ms-2" href="<c:url value='/admin/categories'/>">Hủy</a>
                                    </div>
                                </form>
                        </div>
                    </div>
                </main>
            </div>
        </div>
        <jsp:include page="../common/footer.jsp" />