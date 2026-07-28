<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Register - World Cup 2026</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<%@ include file="/WEB-INF/jspf/navbar.jspf" %>
<main class="container">
    <section class="section">
        <div class="auth-card">
            <h1>Create Account</h1>
            <p class="auth-subtitle">New accounts are registered with the fan role.</p>
            <% if (request.getAttribute("error") != null) { %>
                <div class="form-message form-error"><%= request.getAttribute("error") %></div>
            <% } %>
            <% if (request.getAttribute("success") != null) { %>
                <div class="form-message form-success"><%= request.getAttribute("success") %></div>
            <% } %>
            <form action="register" method="post" class="auth-form">
                <label for="email">Email</label>
                <input id="email" name="email" type="email" required autocomplete="email"
                       value="<%= request.getParameter("email") == null ? "" : request.getParameter("email") %>">

                <label for="name">Name</label>
                <input id="name" name="name" type="text" required autocomplete="name"
                       value="<%= request.getParameter("name") == null ? "" : request.getParameter("name") %>">

                <label for="password">Password</label>
                <input id="password" name="password" type="password" required
                       minlength="6" autocomplete="new-password">

                <button type="submit" class="btn-primary">Register</button>
            </form>
            <p class="auth-switch">Already registered? <a href="login.jsp">Sign in</a></p>
        </div>
    </section>
</main>
<footer class="footer">CS157A Team 2 | FIFA World Cup 2026 | SJSU</footer>
</body>
</html>
