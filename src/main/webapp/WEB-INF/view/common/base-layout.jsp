<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%--
  Base Layout Wrapper

  Usage in content pages:
  <c:set var="pageTitle" value="Page Title" scope="request" />
  <c:set var="hasSidebar" value="true" scope="request" />
  <c:set var="sidebarMode" value="sticky" scope="request" /> <!-- or "overlay" -->
  <jsp:include page="/WEB-INF/view/common/base-layout.jsp">
      <jsp:param name="contentPage" value="/WEB-INF/view/your-content.jsp" />
  </jsp:include>
--%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${pageTitle} - TaphoaMMO</title>

    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <!-- Common CSS -->
    <link rel="stylesheet" href="/resources/css/common.css">

    <!-- Additional CSS -->
    ${additionalCSS}
</head>
<body>
    <!-- Navbar -->
    <jsp:include page="/WEB-INF/view/common/navbar.jsp" />

    <c:choose>
        <c:when test="${hasSidebar}">
            <!-- Layout with Sidebar -->
            <div class="layout-container">
                <!-- Sidebar -->
                <jsp:include page="/WEB-INF/view/common/sidebar.jsp" />

                <!-- Main Content -->
                <div class="main-content" id="mainContent">
                    <!-- Flash Messages -->
                    <c:if test="${not empty success}">
                        <div class="alert alert-success alert-dismissible fade show">
                            <i class="fas fa-check-circle me-2"></i>${success}
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </div>
                    </c:if>
                    <c:if test="${not empty error}">
                        <div class="alert alert-danger alert-dismissible fade show">
                            <i class="fas fa-exclamation-circle me-2"></i>${error}
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </div>
                    </c:if>
                    <c:if test="${not empty warning}">
                        <div class="alert alert-warning alert-dismissible fade show">
                            <i class="fas fa-exclamation-triangle me-2"></i>${warning}
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </div>
                    </c:if>
                    <c:if test="${not empty info}">
                        <div class="alert alert-info alert-dismissible fade show">
                            <i class="fas fa-info-circle me-2"></i>${info}
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </div>
                    </c:if>

                    <!-- Page Content -->
                    <jsp:include page="${param.contentPage}" />
                </div>
            </div>
        </c:when>
        <c:otherwise>
            <!-- Layout without Sidebar (Public pages) -->
            <div class="main-content">
                <!-- Flash Messages -->
                <c:if test="${not empty success}">
                    <div class="alert alert-success alert-dismissible fade show">
                        <i class="fas fa-check-circle me-2"></i>${success}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>
                <c:if test="${not empty error}">
                    <div class="alert alert-danger alert-dismissible fade show">
                        <i class="fas fa-exclamation-circle me-2"></i>${error}
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                </c:if>

                <!-- Page Content -->
                <jsp:include page="${param.contentPage}" />
            </div>
        </c:otherwise>
    </c:choose>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

    <!-- jQuery (optional) -->
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>

    <!-- Common JavaScript -->
    <script>
        // Toggle Sidebar Function
        function toggleSidebar() {
            const sidebar = document.getElementById('sidebar');
            const mainContent = document.getElementById('mainContent');

            if (!sidebar) return;

            // Check sidebar mode
            const isOverlayMode = sidebar.classList.contains('mode-overlay');
            const isStickyMode = sidebar.classList.contains('mode-sticky');

            if (isOverlayMode) {
                // Overlay mode: toggle active class
                sidebar.classList.toggle('active');
                if (mainContent) {
                    mainContent.classList.toggle('shifted');
                }
            } else if (isStickyMode) {
                // Sticky mode: toggle collapsed class
                sidebar.classList.toggle('collapsed');
            }

            // Store state
            localStorage.setItem('sidebarOpen', !sidebar.classList.contains('collapsed'));
        }

        // Restore sidebar state on load
        document.addEventListener('DOMContentLoaded', function() {
            const sidebar = document.getElementById('sidebar');
            if (!sidebar) return;

            // Restore state
            const sidebarOpen = localStorage.getItem('sidebarOpen');
            if (sidebarOpen === 'false' && sidebar.classList.contains('mode-sticky')) {
                sidebar.classList.add('collapsed');
            } else if (sidebarOpen === 'true' && sidebar.classList.contains('mode-overlay')) {
                sidebar.classList.add('active');
                const mainContent = document.getElementById('mainContent');
                if (mainContent) {
                    mainContent.classList.add('shifted');
                }
            }

            // Set active nav link
            const currentPath = window.location.pathname;
            document.querySelectorAll('.sidebar .menu a').forEach(link => {
                const href = link.getAttribute('href');
                if (href === currentPath || (currentPath.startsWith(href) && href !== '/')) {
                    link.classList.add('active');
                }
            });
        });

        // Auto-hide alerts
        setTimeout(function() {
            const alerts = document.querySelectorAll('.alert');
            alerts.forEach(alert => {
                const bsAlert = new bootstrap.Alert(alert);
                bsAlert.close();
            });
        }, 5000);
    </script>

    <!-- Additional JavaScript -->
    ${additionalJS}
</body>
</html>
