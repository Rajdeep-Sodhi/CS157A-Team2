<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User" %>
<%
    User authUser = (User) session.getAttribute("authUser");
    if (authUser != null) {
        response.sendRedirect(request.getContextPath() + "/");
        return;
    }
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Sign In - World Cup 2026</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<% request.setAttribute("currentPage", "login"); %>
<%@ include file="nav.jsp" %>
<main class="container">
    <section class="section" style="max-width:480px;margin:0 auto;">
        <h2 class="section-title">Sign In</h2>

        <% if (error != null) { %>
        <div class="db-error"><%= error %></div>
        <% } %>

        <div class="form-card">
            <form method="post" action="<%= request.getContextPath() %>/login">
                <div class="form-field">
                    <label for="email">Email</label>
                    <input type="email" id="email" name="email" required autofocus>
                </div>
                <div class="form-field">
                    <label for="password">Password</label>
                    <input type="password" id="password" name="password" required>
                </div>
                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">Sign In</button>
                </div>
            </form>
            <p class="muted" style="margin-top:1rem;">
                No account yet? <a href="<%= request.getContextPath() %>/register">Register here</a>.
            </p>
            <p class="muted" style="margin-top:.5rem;">
                Demo accounts: admin@worldcup.com / changeme (admin), fan@worldcup.com / changeme (fan)
            </p>
        </div>
    </section>
</main>
<footer class="footer">CS157A Team 2 | FIFA World Cup 2026 | SJSU</footer>
</body>
</html>
