<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.DBConnection,java.sql.*" %>
<%
    Integer predictionUserId = (Integer) session.getAttribute("userId");
    Connection predictionConn = null;
    PreparedStatement predictionStatement = null;
    ResultSet upcomingMatches = null;
    String predictionError = (String) request.getAttribute("error");

    try {
        predictionConn = DBConnection.getConnection();
        String predictionSql =
            "SELECT m.match_id, m.match_date, m.stage, " +
            "c1.country_name AS team1, c2.country_name AS team2, " +
            "v.stadium_name, p.predicted_team1_score, p.predicted_team2_score " +
            "FROM Matches m " +
            "JOIN Countries c1 ON m.team1_country_name = c1.country_name " +
            "JOIN Countries c2 ON m.team2_country_name = c2.country_name " +
            "JOIN Venues v ON m.venue_id = v.venue_id " +
            "LEFT JOIN MatchResults mr ON mr.match_id = m.match_id " +
            "LEFT JOIN Predictions p ON p.match_id = m.match_id AND p.user_id = ? " +
            "WHERE mr.result_id IS NULL " +
            "ORDER BY m.match_date ASC";
        predictionStatement = predictionConn.prepareStatement(predictionSql);
        predictionStatement.setInt(1, predictionUserId == null ? -1 : predictionUserId);
        upcomingMatches = predictionStatement.executeQuery();
    } catch (SQLException e) {
        predictionError = e.getMessage();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Predictions - World Cup 2026</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<% request.setAttribute("currentPage", "predictions"); %>
<%@ include file="nav.jsp" %>
<main class="container">
    <section class="section">
        <h1 class="section-title">Upcoming Match Predictions</h1>

        <% if ("saved".equals(request.getParameter("status"))) { %>
            <div class="form-message form-success">Your prediction was saved.</div>
        <% } else if ("closed".equals(request.getParameter("status"))) { %>
            <div class="form-message form-error">That match is no longer open for predictions.</div>
        <% } else if ("invalid".equals(request.getParameter("status"))) { %>
            <div class="form-message form-error">Enter valid scores from 0 to 99.</div>
        <% } %>

        <% if (predictionUserId == null) { %>
            <div class="login-notice">
                You can view upcoming matches, but you must
                <a href="login.jsp">sign in</a> to submit a prediction.
            </div>
        <% } %>

        <% if (predictionError != null) { %>
            <div class="db-error">Unable to load predictions: <%= predictionError %></div>
        <% } else { %>
            <div class="prediction-grid">
            <% boolean foundUpcoming = false;
               while (upcomingMatches.next()) {
                   foundUpcoming = true;
                   Object savedTeam1 = upcomingMatches.getObject("predicted_team1_score");
                   Object savedTeam2 = upcomingMatches.getObject("predicted_team2_score");
            %>
                <article class="prediction-card">
                    <div class="prediction-meta">
                        <span class="badge"><%= upcomingMatches.getString("stage") %></span>
                        <span><%= upcomingMatches.getTimestamp("match_date") %></span>
                    </div>
                    <div class="prediction-teams">
                        <strong><%= upcomingMatches.getString("team1") %></strong>
                        <span>vs</span>
                        <strong><%= upcomingMatches.getString("team2") %></strong>
                    </div>
                    <p class="prediction-venue"><%= upcomingMatches.getString("stadium_name") %></p>

                    <% if (predictionUserId != null) { %>
                        <form action="predict" method="post" class="score-form">
                            <input type="hidden" name="matchId"
                                   value="<%= upcomingMatches.getInt("match_id") %>">
                            <label>
                                <span><%= upcomingMatches.getString("team1") %></span>
                                <input type="number" name="team1Score" min="0" max="99" required
                                       value="<%= savedTeam1 == null ? "" : savedTeam1 %>">
                            </label>
                            <span class="score-separator">&ndash;</span>
                            <label>
                                <span><%= upcomingMatches.getString("team2") %></span>
                                <input type="number" name="team2Score" min="0" max="99" required
                                       value="<%= savedTeam2 == null ? "" : savedTeam2 %>">
                            </label>
                            <button type="submit" class="btn-primary">
                                <%= savedTeam1 == null ? "Save Prediction" : "Update Prediction" %>
                            </button>
                        </form>
                    <% } %>
                </article>
            <% }
               if (!foundUpcoming) { %>
                <p class="empty-state">There are no matches open for predictions.</p>
            <% } %>
            </div>
        <% } %>
    </section>
</main>
<footer class="footer">CS157A Team 2 | FIFA World Cup 2026 | SJSU</footer>
<%
    if (upcomingMatches != null) try { upcomingMatches.close(); } catch (SQLException ignored) {}
    if (predictionStatement != null) try { predictionStatement.close(); } catch (SQLException ignored) {}
    if (predictionConn != null) try { predictionConn.close(); } catch (SQLException ignored) {}
%>
</body>
</html>
