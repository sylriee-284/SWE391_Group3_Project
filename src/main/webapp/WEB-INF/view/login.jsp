<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <html>

        <head>
            <title>Login Page</title>
            <link rel="stylesheet" href="<c:url value='/css/style.css' />">
        </head>

        <body>
            <h2>Login</h2>

            <form action="<c:url value='/login'/>" method="post">
                <input type="text" name="username" />
                <input type="password" name="password" />
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                <button type="submit">Login</button>
            </form>


        </body>

        </html>