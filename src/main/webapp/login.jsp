<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Sign In - World Cup 2026</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<%@ include file="/WEB-INF/jspf/navbar.jspf" %>
<main class="container">
    <section class="section">
        <div class="auth-card">
            <h1>Sign In</h1>
            <p class="auth-subtitle">Welcome back to World Cup 2026.</p>
            <% if (request.getAttribute("error") != null) { %>
                <div class="form-message form-error"><%= request.getAttribute("error") %></div>
            <% } %>
            <form action="login" method="post" class="auth-form">
                <label for="email">Email</label>
                <input id="email" name="email" type="email" required autocomplete="email"
                       value="<%= request.getParameter("email") == null ? "" : request.getParameter("email") %>">

                <label for="password">Password</label>
                <input id="password" name="password" type="password" required
                       autocomplete="current-password">

                <button type="submit" class="btn-primary">Sign In</button>
            </form>
            <p class="auth-switch">Need an account? <a href="register.jsp">Register</a></p>
        </div>
    </section>
</main>
<footer class="footer">CS157A Team 2 | FIFA World Cup 2026 | SJSU</footer>
</body>
</html>
