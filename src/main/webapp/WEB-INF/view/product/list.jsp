<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%-- Set page properties --%>
<c:set var="pageTitle" value="Danh sách Sản phẩm" scope="request" />
<c:set var="hasSidebar" value="true" scope="request" />
<c:set var="sidebarMode" value="sticky" scope="request" />

<%-- Use base layout --%>
<jsp:include page="/WEB-INF/view/common/base-layout.jsp">
    <jsp:param name="contentPage" value="/WEB-INF/view/product/list-content.jsp" />
</jsp:include>
