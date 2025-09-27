<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <html>

        <head>
            <title>Login Page</title>
            <link rel="stylesheet" href="<c:url value='/css/style.css' />">
        </head>

        <body>
            <h2>Login</h2>

            <!-- Hiển thị thông báo lỗi khi login fail -->
            <c:if test="${param.error != null}">
                <p style="color: red;">Invalid username or password!</p>
            </c:if>

            <!-- Hiển thị thông báo khi logout -->
            <c:if test="${param.logout != null}">
                <p style="color: green;">You have been logged out successfully.</p>
            </c:if>

            <form action="/login" method="post">
                <div>
                    <label>Username:</label>
                    <input type="text" name="username" required />
                </div>
                <div>
                    <label>Password:</label>
                    <input type="password" name="password" required />
                </div>
                <div>
                    <button type="submit">Login</button>
                </div>
            </form>

        </body>

        </html>