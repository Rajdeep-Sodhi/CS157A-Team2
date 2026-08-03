<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.net.URLEncoder, model.User" %>
<%
    User authUser = (User) session.getAttribute("authUser");
    boolean isAdmin = authUser != null && authUser.isAdmin();

    List<Map<String,Object>> teams = (List<Map<String,Object>>) request.getAttribute("teams");
    if (teams == null) teams = new ArrayList<>();
    Map<String,Object> selectedTeam = (Map<String,Object>) request.getAttribute("selectedTeam");
    List<Map<String,Object>> roster = (List<Map<String,Object>>) request.getAttribute("roster");
    List<Map<String,Object>> unassigned = (List<Map<String,Object>>) request.getAttribute("unassignedPlayers");
    String dbError = (String) request.getAttribute("dbError");
    String ctx = request.getContextPath();

    String selectedCountry = selectedTeam != null ? (String) selectedTeam.get("country_name") : null;
    String selectedCountryUrl = selectedCountry != null ? URLEncoder.encode(selectedCountry, "UTF-8") : "";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Teams - World Cup 2026</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<% request.setAttribute("currentPage", "teams"); %>
<%@ include file="nav.jsp" %>
<main class="container">

    <% if (dbError != null) { %>
    <div class="db-error">Error: <%= dbError %></div>
    <% } %>

    <section class="section">
        <h2 class="section-title">Teams</h2>

        <table class="data-table">
            <thead>
                <tr>
                    <th>Group</th><th>Country</th><th>FIFA Rank</th><th>Confederation</th>
                    <th>Coach</th><th>Players</th><th></th>
                </tr>
            </thead>
            <tbody>
            <% for (Map<String,Object> t : teams) {
                String tCountry = (String) t.get("country_name");
                boolean isSelected = tCountry.equals(selectedCountry);
            %>
                <tr class="<%= isSelected ? "qualify-row" : "" %>">
                    <td><% if (t.get("group_letter") != null) { %><span class="badge"><%= t.get("group_letter") %></span><% } else { %><span class="muted">unassigned</span><% } %></td>
                    <td class="team-name"><%= tCountry %></td>
                    <td><%= t.get("fifa_ranking") == null ? "-" : t.get("fifa_ranking") %></td>
                    <td><%= t.get("confederation") == null ? "-" : t.get("confederation") %></td>
                    <td><%= t.get("coach_name") == null ? "-" : t.get("coach_name") %></td>
                    <td><%= t.get("player_count") %></td>
                    <td><a class="btn btn-sm btn-secondary" href="teams?country=<%= URLEncoder.encode(tCountry, "UTF-8") %>#roster">View Roster</a></td>
                </tr>
            <% } %>
            <% if (teams.isEmpty()) { %>
                <tr><td colspan="7" class="muted">No teams yet.</td></tr>
            <% } %>
            </tbody>
        </table>
    </section>

    <% if (isAdmin) { %>
    <section class="section">
        <h2 class="section-title">Add a Team</h2>
        <div class="form-card wide">
            <form method="post" action="<%= ctx %>/teams">
                <input type="hidden" name="action" value="add">
                <div class="form-grid">
                    <div class="form-field">
                        <label for="country_name">Country / Team Name</label>
                        <input type="text" id="country_name" name="country_name" required>
                    </div>
                    <div class="form-field">
                        <label for="fifa_ranking">FIFA Ranking</label>
                        <input type="number" id="fifa_ranking" name="fifa_ranking">
                    </div>
                    <div class="form-field">
                        <label for="confederation">Confederation</label>
                        <input type="text" id="confederation" name="confederation" placeholder="e.g. UEFA, CONMEBOL">
                    </div>
                    <div class="form-field">
                        <label for="group_letter">FIFA Group</label>
                        <input type="text" id="group_letter" name="group_letter" maxlength="1" placeholder="A-H">
                    </div>
                    <div class="form-field full">
                        <label for="coach_name">Coach Name</label>
                        <input type="text" id="coach_name" name="coach_name">
                    </div>
                </div>
                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">Add Team</button>
                </div>
            </form>
        </div>
    </section>
    <% } %>

    <% if (selectedTeam != null) { %>
    <section class="section" id="roster">
        <h2 class="section-title"><%= selectedCountry %> - Roster</h2>

        <div class="two-col">
            <div>
                <table class="data-table">
                    <thead><tr><th>#</th><th>Name</th><th>Position</th><th>DOB</th><% if (isAdmin) { %><th></th><% } %></tr></thead>
                    <tbody>
                    <% if (roster != null) { for (Map<String,Object> p : roster) { %>
                        <tr>
                            <td><%= p.get("jersey_number") == null ? "-" : p.get("jersey_number") %></td>
                            <td class="team-name"><%= p.get("name") %></td>
                            <td><%= p.get("position") == null ? "-" : p.get("position") %></td>
                            <td><%= p.get("date_of_birth") == null ? "-" : p.get("date_of_birth") %></td>
                            <% if (isAdmin) { %>
                            <td class="action-row">
                                <button type="button" class="btn btn-sm btn-secondary" onclick="document.getElementById('player-edit-<%= p.get("player_id") %>').classList.toggle('hidden-form')">Edit</button>
                                <form method="post" action="<%= ctx %>/players" style="display:inline">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="player_id" value="<%= p.get("player_id") %>">
                                    <input type="hidden" name="return_country" value="<%= selectedCountryUrl %>">
                                    <button type="submit" class="btn btn-sm btn-danger" onclick="return confirm('Remove this player?');">Delete</button>
                                </form>
                            </td>
                            <% } %>
                        </tr>
                        <% if (isAdmin) { %>
                        <tr id="player-edit-<%= p.get("player_id") %>" class="hidden-form">
                            <td colspan="5">
                                <form method="post" action="<%= ctx %>/players" class="form-grid" style="padding:.75rem 0;">
                                    <input type="hidden" name="action" value="edit">
                                    <input type="hidden" name="player_id" value="<%= p.get("player_id") %>">
                                    <input type="hidden" name="country_name" value="<%= selectedCountry %>">
                                    <input type="hidden" name="return_country" value="<%= selectedCountryUrl %>">
                                    <div class="form-field">
                                        <label>Full Name</label>
                                        <input type="text" name="name" value="<%= p.get("name") %>" required>
                                    </div>
                                    <div class="form-field">
                                        <label>Position</label>
                                        <select name="position">
                                            <% String currentPos = (String) p.get("position");
                                               for (String pos : new String[]{"Forward","Midfielder","Defender","Goalkeeper"}) { %>
                                            <option <%= pos.equals(currentPos) ? "selected" : "" %>><%= pos %></option>
                                            <% } %>
                                        </select>
                                    </div>
                                    <div class="form-field">
                                        <label>Jersey Number</label>
                                        <input type="number" name="jersey_number" min="1" max="99"
                                               value="<%= p.get("jersey_number") == null ? "" : p.get("jersey_number") %>">
                                    </div>
                                    <div class="form-field">
                                        <label>Date of Birth</label>
                                        <input type="date" name="date_of_birth"
                                               value="<%= p.get("date_of_birth") == null ? "" : p.get("date_of_birth") %>">
                                    </div>
                                    <div class="form-field form-actions full">
                                        <button type="submit" class="btn btn-primary btn-sm">Save Changes</button>
                                    </div>
                                </form>
                            </td>
                        </tr>
                        <% } %>
                    <% } } if (roster == null || roster.isEmpty()) { %>
                        <tr><td colspan="<%= isAdmin ? 5 : 4 %>" class="muted">No players on this roster yet.</td></tr>
                    <% } %>
                    </tbody>
                </table>
            </div>

            <% if (isAdmin) { %>
            <div>
                <div class="form-card">
                    <h3 class="section-title" style="font-size:1rem;">Add Player</h3>
                    <form method="post" action="<%= ctx %>/players">
                        <input type="hidden" name="action" value="add">
                        <input type="hidden" name="country_name" value="<%= selectedCountry %>">
                        <input type="hidden" name="return_country" value="<%= selectedCountryUrl %>">
                        <div class="form-field">
                            <label for="p_name">Full Name</label>
                            <input type="text" id="p_name" name="name" required>
                        </div>
                        <div class="form-field">
                            <label for="p_position">Position</label>
                            <select id="p_position" name="position">
                                <option>Forward</option>
                                <option>Midfielder</option>
                                <option>Defender</option>
                                <option>Goalkeeper</option>
                            </select>
                        </div>
                        <div class="form-field">
                            <label for="p_jersey">Jersey Number</label>
                            <input type="number" id="p_jersey" name="jersey_number" min="1" max="99">
                        </div>
                        <div class="form-field">
                            <label for="p_dob">Date of Birth</label>
                            <input type="date" id="p_dob" name="date_of_birth">
                        </div>
                        <div class="form-actions">
                            <button type="submit" class="btn btn-primary">Add Player</button>
                        </div>
                    </form>
                </div>

                <div class="form-card" style="margin-top:1.5rem;">
                    <h3 class="section-title" style="font-size:1rem;">Edit Team Info</h3>
                    <p class="muted" style="margin-bottom:.75rem;">The country name itself can't be changed here (too many other records reference it) - only the details below.</p>
                    <form method="post" action="<%= ctx %>/teams">
                        <input type="hidden" name="action" value="edit">
                        <input type="hidden" name="country_name" value="<%= selectedCountry %>">
                        <div class="form-field">
                            <label>Country / Team Name</label>
                            <input type="text" value="<%= selectedCountry %>" disabled>
                        </div>
                        <div class="form-field">
                            <label for="e_fifa_ranking">FIFA Ranking</label>
                            <input type="number" id="e_fifa_ranking" name="fifa_ranking" value="<%= selectedTeam.get("fifa_ranking") == null ? "" : selectedTeam.get("fifa_ranking") %>">
                        </div>
                        <div class="form-field">
                            <label for="e_confederation">Confederation</label>
                            <input type="text" id="e_confederation" name="confederation" value="<%= selectedTeam.get("confederation") == null ? "" : selectedTeam.get("confederation") %>">
                        </div>
                        <div class="form-field">
                            <label for="e_group_letter">FIFA Group</label>
                            <input type="text" id="e_group_letter" name="group_letter" maxlength="1" value="<%= selectedTeam.get("group_letter") == null ? "" : selectedTeam.get("group_letter") %>">
                        </div>
                        <div class="form-field">
                            <label for="e_coach_name">Coach Name</label>
                            <input type="text" id="e_coach_name" name="coach_name" value="<%= selectedTeam.get("coach_name") == null ? "" : selectedTeam.get("coach_name") %>">
                        </div>
                        <div class="form-actions">
                            <button type="submit" class="btn btn-primary">Save Changes</button>
                        </div>
                    </form>
                    <form method="post" action="<%= ctx %>/teams" style="margin-top:.75rem;">
                        <input type="hidden" name="action" value="delete">
                        <input type="hidden" name="country_name" value="<%= selectedCountry %>">
                        <button type="submit" class="btn btn-danger" onclick="return confirm('Delete this team? Its players will be kept but marked Not on a Team.');">Delete Team</button>
                    </form>
                </div>
            </div>
            <% } %>
        </div>
    </section>
    <% } %>

    <% if (unassigned != null) { %>
    <section class="section">
        <h2 class="section-title">Players Not on a Team</h2>
        <table class="data-table">
            <thead><tr><th>Name</th><th>Position</th><th>DOB</th><% if (isAdmin) { %><th></th><% } %></tr></thead>
            <tbody>
            <% for (Map<String,Object> p : unassigned) { %>
                <tr>
                    <td class="team-name"><%= p.get("name") %> <span class="badge tag-unassigned">Not on a Team</span></td>
                    <td><%= p.get("position") == null ? "-" : p.get("position") %></td>
                    <td><%= p.get("date_of_birth") == null ? "-" : p.get("date_of_birth") %></td>
                    <% if (isAdmin) { %>
                    <td class="action-row">
                        <form method="post" action="<%= ctx %>/players" style="display:inline">
                            <input type="hidden" name="action" value="delete">
                            <input type="hidden" name="player_id" value="<%= p.get("player_id") %>">
                            <button type="submit" class="btn btn-sm btn-danger" onclick="return confirm('Remove this player?');">Delete</button>
                        </form>
                    </td>
                    <% } %>
                </tr>
            <% } %>
            <% if (unassigned.isEmpty()) { %>
                <tr><td colspan="4" class="muted">Every player currently belongs to a team.</td></tr>
            <% } %>
            </tbody>
        </table>
    </section>
    <% } else { %>
    <p class="muted" style="margin-bottom:2rem;"><a href="teams?view=unassigned">View players not on a team &rarr;</a></p>
    <% } %>

</main>
<footer class="footer">CS157A Team 2 | FIFA World Cup 2026 | SJSU</footer>
<style>.hidden-form{display:none}</style>
</body>
</html>
