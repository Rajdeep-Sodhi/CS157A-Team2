<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.DBConnection,java.sql.*,java.util.*" %>
<%
    Map<String,List<Map<String,Object>>> standingsGroups = new LinkedHashMap<>();
    String standingsError = null;
    String standingsSql =
        "SELECT c.country_name, c.group_letter, gs.wins, gs.draws, " +
        "gs.losses, gs.points " +
        "FROM GroupStandings gs " +
        "JOIN Countries c ON c.country_name = gs.country_name " +
        "ORDER BY c.group_letter, gs.points DESC, gs.wins DESC, c.country_name";

    try (Connection standingsConn = DBConnection.getConnection();
         PreparedStatement standingsStatement = standingsConn.prepareStatement(standingsSql);
         ResultSet standingsRows = standingsStatement.executeQuery()) {
        while (standingsRows.next()) {
            String group = standingsRows.getString("group_letter");
            Map<String,Object> team = new LinkedHashMap<>();
            team.put("country", standingsRows.getString("country_name"));
            team.put("wins", standingsRows.getObject("wins"));
            team.put("draws", standingsRows.getObject("draws"));
            team.put("losses", standingsRows.getObject("losses"));
            team.put("points", standingsRows.getObject("points"));
            standingsGroups.computeIfAbsent(group, key -> new ArrayList<>()).add(team);
        }
    } catch (SQLException e) {
        standingsError = e.getMessage();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Group Standings - World Cup 2026</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<% request.setAttribute("currentPage", "standings"); %>
<%@ include file="nav.jsp" %>
<main class="container">
    <section class="section">
        <h1 class="section-title">Group Standings</h1>
        <% if (standingsError != null) { %>
            <div class="db-error">Unable to load standings: <%= standingsError %></div>
        <% } else { %>
            <div class="standings-grid">
            <% for (Map.Entry<String,List<Map<String,Object>>> group : standingsGroups.entrySet()) { %>
                <article class="group-card">
                    <h2 class="group-title">Group <%= group.getKey() %></h2>
                    <table class="data-table">
                        <thead>
                            <tr><th>Team</th><th>W</th><th>D</th><th>L</th><th>Pts</th></tr>
                        </thead>
                        <tbody>
                        <% int position = 1;
                           for (Map<String,Object> team : group.getValue()) { %>
                            <tr class="<%= position <= 2 ? "qualify-row" : "" %>">
                                <td><%= team.get("country") %></td>
                                <td><%= team.get("wins") %></td>
                                <td><%= team.get("draws") %></td>
                                <td><%= team.get("losses") %></td>
                                <td><strong><%= team.get("points") %></strong></td>
                            </tr>
                        <% position++; } %>
                        </tbody>
                    </table>
                </article>
            <% } %>
            </div>
        <% } %>
    </section>
</main>
<footer class="footer">CS157A Team 2 | FIFA World Cup 2026 | SJSU</footer>
</body>
</html>
