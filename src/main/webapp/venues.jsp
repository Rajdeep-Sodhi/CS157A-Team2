<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, model.User" %>
<%
    User authUser = (User) session.getAttribute("authUser");
    boolean isAdmin = authUser != null && authUser.isAdmin();

    List<Map<String,Object>> venues = (List<Map<String,Object>>) request.getAttribute("venues");
    if (venues == null) venues = new ArrayList<>();
    String dbError = (String) request.getAttribute("dbError");
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Venues - World Cup 2026</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<% request.setAttribute("currentPage", "venues"); %>
<%@ include file="nav.jsp" %>
<main class="container">

    <% if (dbError != null) { %>
    <div class="db-error">Error: <%= dbError %></div>
    <% } %>

    <section class="section">
        <h2 class="section-title">Stadiums</h2>
        <table class="data-table">
            <thead>
                <tr><th>Stadium</th><th>City</th><th>Host Country</th><th>Capacity</th><th>Matches Scheduled</th><% if (isAdmin) { %><th></th><% } %></tr>
            </thead>
            <tbody>
            <% for (Map<String,Object> v : venues) {
                int matchCount = ((Number) v.get("match_count")).intValue();
            %>
                <tr>
                    <td class="team-name"><%= v.get("stadium_name") %></td>
                    <td><%= v.get("city") == null ? "-" : v.get("city") %></td>
                    <td><%= v.get("host_country") == null ? "-" : v.get("host_country") %></td>
                    <td><%= v.get("capacity") == null ? "-" : v.get("capacity") %></td>
                    <td><%= matchCount %></td>
                    <% if (isAdmin) { %>
                    <td class="action-row">
                        <button type="button" class="btn btn-sm btn-secondary" onclick="document.getElementById('edit-<%= v.get("venue_id") %>').classList.toggle('hidden-form')">Edit</button>
                        <form method="post" action="<%= ctx %>/venues" style="display:inline">
                            <input type="hidden" name="action" value="delete">
                            <input type="hidden" name="venue_id" value="<%= v.get("venue_id") %>">
                            <button type="submit" class="btn btn-sm btn-danger" onclick="return confirm('<%= matchCount > 0 ? "This stadium has matches scheduled and cannot be removed. OK to try anyway?" : "Delete this stadium?" %>');">Delete</button>
                        </form>
                    </td>
                    <% } %>
                </tr>
                <% if (isAdmin) { %>
                <tr id="edit-<%= v.get("venue_id") %>" class="hidden-form">
                    <td colspan="6">
                        <form method="post" action="<%= ctx %>/venues" class="form-grid" style="padding:1rem 0;">
                            <input type="hidden" name="action" value="edit">
                            <input type="hidden" name="venue_id" value="<%= v.get("venue_id") %>">
                            <div class="form-field">
                                <label>Stadium Name</label>
                                <input type="text" name="stadium_name" value="<%= v.get("stadium_name") %>" required>
                            </div>
                            <div class="form-field">
                                <label>City</label>
                                <input type="text" name="city" value="<%= v.get("city") == null ? "" : v.get("city") %>">
                            </div>
                            <div class="form-field">
                                <label>Host Country</label>
                                <input type="text" name="host_country" value="<%= v.get("host_country") == null ? "" : v.get("host_country") %>">
                            </div>
                            <div class="form-field">
                                <label>Capacity</label>
                                <input type="number" name="capacity" value="<%= v.get("capacity") == null ? "" : v.get("capacity") %>">
                            </div>
                            <div class="form-field full form-actions">
                                <button type="submit" class="btn btn-primary btn-sm">Save</button>
                            </div>
                        </form>
                    </td>
                </tr>
                <% } %>
            <% } %>
            <% if (venues.isEmpty()) { %>
                <tr><td colspan="<%= isAdmin ? 6 : 5 %>" class="muted">No venues yet.</td></tr>
            <% } %>
            </tbody>
        </table>
    </section>

    <% if (isAdmin) { %>
    <section class="section">
        <h2 class="section-title">Add a Stadium</h2>
        <div class="form-card wide">
            <form method="post" action="<%= ctx %>/venues">
                <input type="hidden" name="action" value="add">
                <div class="form-grid">
                    <div class="form-field">
                        <label for="stadium_name">Stadium Name</label>
                        <input type="text" id="stadium_name" name="stadium_name" required>
                    </div>
                    <div class="form-field">
                        <label for="city">City</label>
                        <input type="text" id="city" name="city">
                    </div>
                    <div class="form-field">
                        <label for="host_country">Host Country</label>
                        <input type="text" id="host_country" name="host_country">
                    </div>
                    <div class="form-field">
                        <label for="capacity">Capacity</label>
                        <input type="number" id="capacity" name="capacity" min="1">
                    </div>
                </div>
                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">Add Stadium</button>
                </div>
            </form>
        </div>
    </section>
    <% } %>

</main>
<footer class="footer">CS157A Team 2 | FIFA World Cup 2026 | SJSU</footer>
<style>.hidden-form{display:none}</style>
</body>
</html>
