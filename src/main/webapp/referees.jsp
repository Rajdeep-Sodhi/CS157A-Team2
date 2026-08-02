<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, model.User, model.Referee, model.MatchAssignment"%>
<%
    User authUser = (User) session.getAttribute("authUser");
    boolean isAdmin = authUser != null && authUser.isAdmin();

    List<Referee> referees = (List<Referee>) request.getAttribute("referees");
    if (referees == null) referees = new ArrayList<>();
    List<MatchAssignment> matches = (List<MatchAssignment>) request.getAttribute("matches");
    if (matches == null) matches = new ArrayList<>();
    String dbError = (String) request.getAttribute("dbError");
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Referees - World Cup 2026</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<% request.setAttribute("currentPage", "referees"); %>
<%@ include file="nav.jsp" %>
<main class="container">

    <% if (dbError != null) { %>
    <div class="db-error">Error: <%= dbError %></div>
    <% } %>

    <section class="section">
        <h2 class="section-title">Referees</h2>
        <table class="data-table">
            <thead>
                <tr>
                    <th>Name</th><th>Nationality</th><th>FIFA Certificate</th>
                    <th>Years of Experience</th>
                    <% if (isAdmin) { %><th></th><% } %>
                </tr>
            </thead>
            <tbody>
            <% for (Referee r : referees) { %>
                <tr>
                    <td class="team-name"><%= r.getName() %></td>
                    <td><%= r.getCountryName() == null ? "-" : r.getCountryName() %></td>
                    <td><%= r.getFifaCertificate() == null ? "-" : r.getFifaCertificate() %></td>
                    <td><%= r.getYearsExperience() %></td>
                    <% if (isAdmin) { %>
                    <td class="action-row">
                        <button type="button" class="btn btn-sm btn-secondary"
                                onclick="document.getElementById('edit-<%= r.getRefereeId() %>').classList.toggle('hidden-form')">Edit</button>
                        <form method="post" action="<%= ctx %>/referees" style="display:inline">
                            <input type="hidden" name="action" value="delete">
                            <input type="hidden" name="referee_id" value="<%= r.getRefereeId() %>">
                            <button type="submit" class="btn btn-sm btn-danger"
                                    onclick="return confirm('Delete this referee?');">Delete</button>
                        </form>
                    </td>
                    <% } %>
                </tr>
                <% if (isAdmin) { %>
                <tr id="edit-<%= r.getRefereeId() %>" class="hidden-form">
                    <td colspan="5">
                        <form method="post" action="<%= ctx %>/referees" class="form-grid" style="padding:1rem 0;">
                            <input type="hidden" name="action" value="edit">
                            <input type="hidden" name="referee_id" value="<%= r.getRefereeId() %>">
                            <div class="form-field">
                                <label>Full Name</label>
                                <input type="text" name="name" value="<%= r.getName() %>" required>
                            </div>
                            <div class="form-field">
                                <label>Nationality (Country)</label>
                                <input type="text" name="country_name" value="<%= r.getCountryName() == null ? "" : r.getCountryName() %>">
                            </div>
                            <div class="form-field">
                                <label>FIFA Certificate</label>
                                <input type="text" name="fifa_certificate" value="<%= r.getFifaCertificate() == null ? "" : r.getFifaCertificate() %>">
                            </div>
                            <div class="form-field">
                                <label>Years of Experience</label>
                                <input type="number" name="years_experience" min="0" value="<%= r.getYearsExperience() %>">
                            </div>
                            <div class="form-field full form-actions">
                                <button type="submit" class="btn btn-primary btn-sm">Save</button>
                            </div>
                        </form>
                    </td>
                </tr>
                <% } %>
            <% } %>
            <% if (referees.isEmpty()) { %>
                <tr><td colspan="<%= isAdmin ? 5 : 4 %>" class="muted">No referees yet.</td></tr>
            <% } %>
            </tbody>
        </table>
    </section>

    <% if (isAdmin) { %>
    <section class="section">
        <h2 class="section-title">Add a Referee</h2>
        <div class="form-card wide">
            <form method="post" action="<%= ctx %>/referees">
                <input type="hidden" name="action" value="add">
                <div class="form-grid">
                    <div class="form-field">
                        <label for="name">Full Name</label>
                        <input type="text" id="name" name="name" required>
                    </div>
                    <div class="form-field">
                        <label for="country_name">Nationality (Country)</label>
                        <input type="text" id="country_name" name="country_name">
                    </div>
                    <div class="form-field">
                        <label for="fifa_certificate">FIFA Certificate</label>
                        <input type="text" id="fifa_certificate" name="fifa_certificate">
                    </div>
                    <div class="form-field">
                        <label for="years_experience">Years of Experience</label>
                        <input type="number" id="years_experience" name="years_experience" min="0">
                    </div>
                </div>
                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">Add Referee</button>
                </div>
            </form>
        </div>
    </section>

    <section class="section">
        <h2 class="section-title">Assign Referee to Match</h2>
        <table class="data-table">
            <thead>
                <tr><th>Match</th><th>Date</th><th>Current Referee</th><th>Assign</th></tr>
            </thead>
            <tbody>
            <% for (MatchAssignment m : matches) { %>
                <tr>
                    <td><%= m.getTeam1CountryName() %> vs <%= m.getTeam2CountryName() %></td>
                    <td><%= m.getMatchDate() == null ? "-" : m.getMatchDate() %></td>
                    <td><%= m.getRefereeName() == null ? "Not assigned" : m.getRefereeName() %></td>
                    <td>
                        <form method="post" action="<%= ctx %>/referees" style="display:flex; gap:.5rem;">
                            <input type="hidden" name="action" value="assign">
                            <input type="hidden" name="match_id" value="<%= m.getMatchId() %>">
                            <select name="referee_id" required>
                                <option value="">-- select referee --</option>
                                <% for (Referee r : referees) { %>
                                <option value="<%= r.getRefereeId() %>"><%= r.getName() %> (<%= r.getCountryName() %>)</option>
                                <% } %>
                            </select>
                            <button type="submit" class="btn btn-sm btn-primary">Assign</button>
                        </form>
                    </td>
                </tr>
            <% } %>
            <% if (matches.isEmpty()) { %>
                <tr><td colspan="4" class="muted">No matches yet.</td></tr>
            <% } %>
            </tbody>
        </table>
    </section>
    <% } %>

</main>
<footer class="footer">CS157A Team 2 | FIFA World Cup 2026 | SJSU</footer>
<style>.hidden-form{display:none}</style>
</body>
</html>