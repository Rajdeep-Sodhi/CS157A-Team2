<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="model.User" %>
<%
    User __navUser = (User) session.getAttribute("authUser");
    String currentPage = (String) request.getAttribute("currentPage");
    if (currentPage == null) currentPage = "";
%>
<nav class="navbar">
    <div class="nav-brand"><span style="color:#3b82f6;font-weight:800;letter-spacing:1px;">FIFA</span> World Cup 2026</div>
    <ul class="nav-links">
        <li><a href="<%= request.getContextPath() %>/" class="<%= currentPage.equals("home") ? "active" : "" %>">Home</a></li>
        <li><a href="<%= request.getContextPath() %>/matches" class="<%= currentPage.equals("matches") ? "active" : "" %>">Matches</a></li>
        <li><a href="standings.jsp" class="<%= currentPage.equals("standings") ? "active" : "" %>">Standings</a></li>
        <li><a href="<%= request.getContextPath() %>/teams" class="<%= currentPage.equals("teams") ? "active" : "" %>">Teams</a></li>
        <li><a href="<%= request.getContextPath() %>/venues" class="<%= currentPage.equals("venues") ? "active" : "" %>">Venues</a></li>
        <li><a href="<%= request.getContextPath() %>/referees" class="<%= currentPage.equals("referees") ? "active" : "" %>">Referees</a></li>
        <li><a href="predictions.jsp" class="<%= currentPage.equals("predictions") ? "active" : "" %>">Predictions</a></li>
        <% if (__navUser != null && __navUser.isAdmin()) { %>
        <li><a href="<%= request.getContextPath() %>/users" class="<%= currentPage.equals("users") ? "active" : "" %>">Users</a></li>
        <% } %>
    </ul>
    <div class="nav-auth">
        <% if (__navUser != null) { %>
            <span class="nav-user">
                Hi, <%= __navUser.getName() %><% if (__navUser.isAdmin()) { %> <span class="badge">admin</span><% } %>
            </span>
            <a href="<%= request.getContextPath() %>/logout" class="btn-login">Sign Out</a>
        <% } else { %>
            <a href="<%= request.getContextPath() %>/login" class="btn-login">Sign In</a>
            <a href="<%= request.getContextPath() %>/register" class="btn-register">Register</a>
        <% } %>
    </div>
</nav>
