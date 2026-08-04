<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, model.User" %>
<%
    User authUser = (User) session.getAttribute("authUser");
    boolean isAdmin = authUser != null && authUser.isAdmin();

    List<User> users = (List<User>) request.getAttribute("users");
    if (users == null) users = new ArrayList<>();
    String dbError = (String) request.getAttribute("dbError");
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Users - World Cup 2026</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<% request.setAttribute("currentPage", "users"); %>
<%@ include file="nav.jsp" %>
<main class="container">
    <% if (dbError != null) { %>
    <div class="db-error">Error: <%= dbError %></div>
    <% } %>

    <section class="section">
        <h2 class="section-title">Users</h2>
        <p class="muted">Admin accounts are protected and cannot be edited or removed.</p>

        <table class="data-table">
            <thead>
                <tr>
                    <th>Name</th>
                    <th>Email</th>
                    <th>Role</th>
                    <th>Flagged Comments</th>
                    <th></th>
                </tr>
            </thead>
            <tbody>
            <% for (User user : users) { %>
                <tr>
                    <td class="team-name"><%= user.getName() %></td>
                    <td><%= user.getEmail() %></td>
                    <td><span class="badge"><%= user.getRole() %></span></td>
                    <td>
                        <span class="flag-count <%= user.getFlaggedCommentCount() > 0 ? "flag-count-alert" : "" %>">
                            <%= user.getFlaggedCommentCount() %>
                        </span>
                    </td>
                    <td class="action-row">
                        <% if (!user.isAdmin()) { %>
                        <form method="post" action="<%= ctx %>/users" style="display:inline-block; margin-right:.5rem;">
                            <input type="hidden" name="action" value="promote">
                            <input type="hidden" name="user_id" value="<%= user.getUserId() %>">
                            <button type="submit" class="btn btn-sm btn-secondary">Make Admin</button>
                        </form>
                        <form method="post" action="<%= ctx %>/users" style="display:inline-block;">
                            <input type="hidden" name="action" value="delete">
                            <input type="hidden" name="user_id" value="<%= user.getUserId() %>">
                            <button type="submit" class="btn btn-sm btn-danger" onclick="return confirm('Delete this user and all of their comments/predictions?');">Delete</button>
                        </form>
                        <% } else { %>
                        <span class="muted">Protected</span>
                        <% } %>
                    </td>
                </tr>
            <% } %>
            <% if (users.isEmpty()) { %>
                <tr><td colspan="5" class="muted">No users found.</td></tr>
            <% } %>
            </tbody>
        </table>
    </section>
</main>
<footer class="footer">CS157A Team 2 | FIFA World Cup 2026 | SJSU</footer>
</body>
</html>
