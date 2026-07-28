<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.DBConnection,java.sql.*" %>
<%
    Connection conn = null;
    PreparedStatement statement = null;
    ResultSet matches = null;
    String dbError = null;

    try {
        conn = DBConnection.getConnection();
        String sql =
            "SELECT m.match_date, m.stage, " +
            "c1.country_name AS team1, c2.country_name AS team2, " +
            "v.stadium_name, v.city, mr.team1_score, mr.team2_score " +
            "FROM Matches m " +
            "JOIN Countries c1 ON m.team1_country_name = c1.country_name " +
            "JOIN Countries c2 ON m.team2_country_name = c2.country_name " +
            "JOIN Venues v ON m.venue_id = v.venue_id " +
            "LEFT JOIN MatchResults mr ON m.match_id = mr.match_id " +
            "ORDER BY m.match_date ASC";
        statement = conn.prepareStatement(sql);
        matches = statement.executeQuery();
    } catch (SQLException e) {
        dbError = e.getMessage();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Matches - World Cup 2026</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<%@ include file="/WEB-INF/jspf/navbar.jspf" %>
<main class="container">
    <section class="section">
        <h2 class="section-title">Match Schedule</h2>
        <% if (dbError != null) { %>
            <div class="db-error">Unable to load matches: <%= dbError %></div>
        <% } else { %>
            <div class="table-scroll">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Date</th>
                            <th>Stage</th>
                            <th>Home</th>
                            <th>Score</th>
                            <th>Away</th>
                            <th>Venue</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                    <% boolean hasMatches = false;
                       while (matches.next()) {
                           hasMatches = true;
                           Integer team1Score = (Integer) matches.getObject("team1_score");
                           Integer team2Score = (Integer) matches.getObject("team2_score");
                           boolean played = team1Score != null && team2Score != null;
                    %>
                        <tr>
                            <td><%= matches.getTimestamp("match_date") %></td>
                            <td><span class="badge"><%= matches.getString("stage") %></span></td>
                            <td class="team-name"><%= matches.getString("team1") %></td>
                            <td class="score">
                                <% if (played) { %>
                                    <strong><%= team1Score %> &ndash; <%= team2Score %></strong>
                                <% } else { %>
                                    <span class="vs">vs</span>
                                <% } %>
                            </td>
                            <td class="team-name"><%= matches.getString("team2") %></td>
                            <td><%= matches.getString("stadium_name") %>, <%= matches.getString("city") %></td>
                            <td>
                                <span class="status <%= played ? "status-finished" : "status-upcoming" %>">
                                    <%= played ? "Finished" : "Upcoming" %>
                                </span>
                            </td>
                        </tr>
                    <% }
                       if (!hasMatches) { %>
                        <tr><td colspan="7" class="empty-state">No matches are scheduled.</td></tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
        <% } %>
    </section>
</main>
<footer class="footer">CS157A Team 2 | FIFA World Cup 2026 | SJSU</footer>
<%
    if (matches != null) try { matches.close(); } catch (SQLException ignored) {}
    if (statement != null) try { statement.close(); } catch (SQLException ignored) {}
    if (conn != null) try { conn.close(); } catch (SQLException ignored) {}
%>
</body>
</html>
