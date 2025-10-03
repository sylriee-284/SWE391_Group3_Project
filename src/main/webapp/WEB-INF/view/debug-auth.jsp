<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
        <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

            <!DOCTYPE html>
            <html>

            <head>
                <title>Debug Authentication</title>
                <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
            </head>

            <body>
                <div class="container mt-5">
                    <h1>Debug Authentication Status</h1>

                    <div class="card mt-4">
                        <div class="card-header">
                            <h3>Spring Security Tags Test</h3>
                        </div>
                        <div class="card-body">
                            <sec:authorize access="isAuthenticated()">
                                <div class="alert alert-success">
                                    ✅ <strong>isAuthenticated() = TRUE</strong>
                                    <sec:authentication var="user" property="principal" />
                                    <ul class="mt-2">
                                        <li><strong>Username:</strong> ${user.username}</li>
                                        <li><strong>Balance:</strong> ${user.balance}</li>
                                        <li><strong>Email:</strong> ${user.email}</li>
                                        <li><strong>ID:</strong> ${user.id}</li>
                                    </ul>
                                </div>
                            </sec:authorize>

                            <sec:authorize access="!isAuthenticated()">
                                <div class="alert alert-danger">
                                    ❌ <strong>isAuthenticated() = FALSE</strong>
                                    <p>User is not authenticated</p>
                                </div>
                            </sec:authorize>
                        </div>
                    </div>

                    <div class="mt-3">
                        <a href="/debug/auth" class="btn btn-info">View Raw Debug Info</a>
                        <a href="/login" class="btn btn-warning">Go to Login</a>
                        <a href="/homepage" class="btn btn-primary">Go to Homepage</a>
                    </div>
                </div>
            </body>

            </html>