<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User" %>
<%
    User authUser = (User) session.getAttribute("authUser");
    if (authUser != null) {
        response.sendRedirect(request.getContextPath() + "/");
        return;
    }
    String error = (String) request.getAttribute("error");
    String nameVal = (String) request.getAttribute("name");
    String emailVal = (String) request.getAttribute("email");
    String dobVal = (String) request.getAttribute("dob");
    String countryVal = (String) request.getAttribute("country");
    if (nameVal == null) nameVal = "";
    if (emailVal == null) emailVal = "";
    if (dobVal == null) dobVal = "";
    if (countryVal == null) countryVal = "";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Register - World Cup 2026</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<% request.setAttribute("currentPage", "register"); %>
<%@ include file="nav.jsp" %>
<main class="container">
    <section class="section" style="max-width:480px;margin:0 auto;">
        <h2 class="section-title">Create an Account</h2>

        <% if (error != null) { %>
        <div class="db-error"><%= error %></div>
        <% } %>

        <div class="form-card">
            <form method="post" action="<%= request.getContextPath() %>/register">
                <div class="form-field">
                    <label for="name">Name</label>
                    <input type="text" id="name" name="name" value="<%= nameVal %>" required autofocus>
                </div>
                <div class="form-field">
                    <label for="email">Email</label>
                    <input type="email" id="email" name="email" value="<%= emailVal %>" required>
                </div>
                <div class="form-field">
                    <label for="password">Password</label>
                    <input type="password" id="password" name="password" required>
                </div>
                <div class="form-field">
                    <label for="dob">Date of Birth</label>
                    <input type="date" id="dob" name="dob" value="<%= dobVal %>">
                </div>
                <div class="form-field">
                    <label for="country">Country</label>
                    <input type="text" id="country" name="country" value="<%= countryVal %>">
                </div>
                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">Register</button>
                </div>
            </form>
            <p class="muted" style="margin-top:1rem;">
                Already have an account? <a href="<%= request.getContextPath() %>/login">Sign in</a>.
            </p>
        </div>
    </section>
</main>
<footer class="footer">CS157A Team 2 | FIFA World Cup 2026 | SJSU</footer>
</body>
</html>
