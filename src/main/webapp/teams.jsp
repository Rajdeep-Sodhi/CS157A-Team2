<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.DBConnection,java.sql.*,java.util.*" %>
<%
    List<Map<String,Object>> countryList = new ArrayList<>();
    String teamError = null;

    String teamSql =
        "SELECT c.country_name, c.fifa_ranking, c.confederation, " +
        "c.coach_name, c.group_letter, p.name AS player_name, " +
        "p.position, p.jersey_number " +
        "FROM Countries c " +
        "LEFT JOIN Players p ON p.country_name = c.country_name " +
        "ORDER BY c.group_letter, c.country_name, p.jersey_number, p.name";

    try (Connection teamConn = DBConnection.getConnection();
         PreparedStatement teamStatement = teamConn.prepareStatement(teamSql);
         ResultSet teamRows = teamStatement.executeQuery()) {

        Map<String,Object> currentCountry = null;
        String currentCountryName = null;
        while (teamRows.next()) {
            String countryName = teamRows.getString("country_name");
            if (!countryName.equals(currentCountryName)) {
                currentCountry = new LinkedHashMap<>();
                currentCountry.put("name", countryName);
                currentCountry.put("ranking", teamRows.getObject("fifa_ranking"));
                currentCountry.put("confederation", teamRows.getString("confederation"));
                currentCountry.put("coach", teamRows.getString("coach_name"));
                currentCountry.put("group", teamRows.getString("group_letter"));
                currentCountry.put("players", new ArrayList<Map<String,Object>>());
                countryList.add(currentCountry);
                currentCountryName = countryName;
            }

            if (teamRows.getString("player_name") != null) {
                Map<String,Object> player = new LinkedHashMap<>();
                player.put("name", teamRows.getString("player_name"));
                player.put("position", teamRows.getString("position"));
                player.put("number", teamRows.getObject("jersey_number"));
                ((List<Map<String,Object>>) currentCountry.get("players")).add(player);
            }
        }
    } catch (SQLException e) {
        teamError = e.getMessage();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Teams - World Cup 2026</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<%@ include file="/WEB-INF/jspf/navbar.jspf" %>
<main class="container">
    <section class="section">
        <h1 class="section-title">Countries and Players</h1>
        <% if (teamError != null) { %>
            <div class="db-error">Unable to load teams: <%= teamError %></div>
        <% } else { %>
            <div class="country-grid">
            <% for (Map<String,Object> country : countryList) {
                List<Map<String,Object>> players =
                    (List<Map<String,Object>>) country.get("players");
            %>
                <details class="country-card">
                    <summary>
                        <span>
                            <strong><%= country.get("name") %></strong>
                            <small><%= country.get("confederation") %></small>
                        </span>
                        <span class="country-group">Group <%= country.get("group") %></span>
                    </summary>
                    <div class="country-info">
                        <span>FIFA ranking: <strong><%= country.get("ranking") %></strong></span>
                        <span>Coach: <strong><%= country.get("coach") == null ? "TBD" : country.get("coach") %></strong></span>
                    </div>
                    <% if (players.isEmpty()) { %>
                        <p class="empty-state">No players have been added yet.</p>
                    <% } else { %>
                        <table class="player-table">
                            <thead><tr><th>#</th><th>Player</th><th>Position</th></tr></thead>
                            <tbody>
                            <% for (Map<String,Object> player : players) { %>
                                <tr>
                                    <td><%= player.get("number") == null ? "—" : player.get("number") %></td>
                                    <td><strong><%= player.get("name") %></strong></td>
                                    <td><%= player.get("position") %></td>
                                </tr>
                            <% } %>
                            </tbody>
                        </table>
                    <% } %>
                </details>
            <% } %>
            </div>
        <% } %>
    </section>
</main>
<footer class="footer">CS157A Team 2 | FIFA World Cup 2026 | SJSU</footer>
</body>
</html>
