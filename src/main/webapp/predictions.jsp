<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.DBConnection,java.sql.*,java.util.*,model.User" %>
<%!
    private String escapeHtml(Object value) {
        if (value == null) return "";
        return value.toString()
            .replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace("\"", "&quot;")
            .replace("'", "&#39;");
    }
%>
<%
    User predictionUser = (User) session.getAttribute("authUser");
    Integer predictionUserId = predictionUser == null ? null : predictionUser.getUserId();
    List<Map<String,Object>> upcomingMatches = new ArrayList<>();
    Map<Integer,List<Map<String,Object>>> predictionsByMatch = new HashMap<>();
    List<Map<String,Object>> finishedMatches = new ArrayList<>();
    Map<Integer,List<Map<String,Object>>> finishedPredictionsByMatch = new HashMap<>();
    List<Map<String,Object>> leaderboard = new ArrayList<>();
    String predictionError = (String) request.getAttribute("error");

    if (predictionError == null) {
        try (Connection conn = DBConnection.getConnection()) {
            String matchSql =
                "SELECT m.match_id, m.match_date, m.stage, " +
                "m.team1_country_name AS team1, m.team2_country_name AS team2, " +
                "v.stadium_name, v.city, p.predicted_team1_score, p.predicted_team2_score " +
                "FROM Matches m " +
                "JOIN Venues v ON m.venue_id = v.venue_id " +
                "LEFT JOIN MatchResults mr ON mr.match_id = m.match_id " +
                "LEFT JOIN Predictions p ON p.match_id = m.match_id AND p.user_id = ? " +
                "WHERE mr.result_id IS NULL ORDER BY m.match_date ASC";
            try (PreparedStatement ps = conn.prepareStatement(matchSql)) {
                ps.setInt(1, predictionUserId == null ? -1 : predictionUserId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String,Object> match = new LinkedHashMap<>();
                        match.put("match_id", rs.getInt("match_id"));
                        match.put("match_date", rs.getTimestamp("match_date"));
                        match.put("stage", rs.getString("stage"));
                        match.put("team1", rs.getString("team1"));
                        match.put("team2", rs.getString("team2"));
                        match.put("stadium_name", rs.getString("stadium_name"));
                        match.put("city", rs.getString("city"));
                        match.put("saved_team1", rs.getObject("predicted_team1_score"));
                        match.put("saved_team2", rs.getObject("predicted_team2_score"));
                        upcomingMatches.add(match);
                    }
                }
            }

            String communitySql =
                "SELECT p.match_id, p.user_id, u.name, " +
                "p.predicted_team1_score, p.predicted_team2_score " +
                "FROM Predictions p JOIN Users u ON u.user_id = p.user_id " +
                "JOIN Matches m ON m.match_id = p.match_id " +
                "LEFT JOIN MatchResults mr ON mr.match_id = m.match_id " +
                "WHERE mr.result_id IS NULL ORDER BY u.name ASC";
            try (PreparedStatement ps = conn.prepareStatement(communitySql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String,Object> prediction = new LinkedHashMap<>();
                    int matchId = rs.getInt("match_id");
                    prediction.put("user_id", rs.getInt("user_id"));
                    prediction.put("name", rs.getString("name"));
                    prediction.put("team1_score", rs.getInt("predicted_team1_score"));
                    prediction.put("team2_score", rs.getInt("predicted_team2_score"));
                    predictionsByMatch.computeIfAbsent(matchId, key -> new ArrayList<>()).add(prediction);
                }
            }

            String finishedSql =
                "SELECT m.match_id, m.match_date, m.stage, " +
                "m.team1_country_name AS team1, m.team2_country_name AS team2, " +
                "v.stadium_name, v.city, mr.team1_score, mr.team2_score, " +
                "p.user_id, u.name, p.predicted_team1_score, p.predicted_team2_score " +
                "FROM Matches m JOIN Venues v ON v.venue_id = m.venue_id " +
                "JOIN MatchResults mr ON mr.result_id = " +
                "(SELECT MAX(latest.result_id) FROM MatchResults latest WHERE latest.match_id = m.match_id) " +
                "JOIN Predictions p ON p.match_id = m.match_id " +
                "JOIN Users u ON u.user_id = p.user_id " +
                "WHERE mr.team1_score IS NOT NULL AND mr.team2_score IS NOT NULL " +
                "ORDER BY m.match_date DESC, u.name ASC";
            Map<Integer,Map<String,Object>> finishedMatchIndex = new LinkedHashMap<>();
            try (PreparedStatement ps = conn.prepareStatement(finishedSql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int matchId = rs.getInt("match_id");
                    if (!finishedMatchIndex.containsKey(matchId)) {
                        Map<String,Object> match = new LinkedHashMap<>();
                        match.put("match_id", matchId);
                        match.put("match_date", rs.getTimestamp("match_date"));
                        match.put("stage", rs.getString("stage"));
                        match.put("team1", rs.getString("team1"));
                        match.put("team2", rs.getString("team2"));
                        match.put("stadium_name", rs.getString("stadium_name"));
                        match.put("city", rs.getString("city"));
                        match.put("team1_score", rs.getInt("team1_score"));
                        match.put("team2_score", rs.getInt("team2_score"));
                        finishedMatchIndex.put(matchId, match);
                    }
                    Map<String,Object> prediction = new LinkedHashMap<>();
                    prediction.put("user_id", rs.getInt("user_id"));
                    prediction.put("name", rs.getString("name"));
                    prediction.put("team1_score", rs.getInt("predicted_team1_score"));
                    prediction.put("team2_score", rs.getInt("predicted_team2_score"));
                    finishedPredictionsByMatch.computeIfAbsent(matchId, key -> new ArrayList<>()).add(prediction);
                }
            }
            finishedMatches.addAll(finishedMatchIndex.values());

            // FR: "points added to user account... leaderboard page." Computed
            // fresh from Predictions + MatchResults each time (same approach as
            // GroupStandings), so it can never drift out of sync - no separate
            // points column to keep updated. Scoring matches the per-match
            // grading shown above: 3 points for an exact score match, 1 point
            // if exactly one side matches, 0 otherwise.
            String leaderboardSql =
                "SELECT u.user_id, u.name, " +
                "  SUM(CASE " +
                "        WHEN p.predicted_team1_score = mr.team1_score AND p.predicted_team2_score = mr.team2_score THEN 3 " +
                "        WHEN p.predicted_team1_score = mr.team1_score OR p.predicted_team2_score = mr.team2_score THEN 1 " +
                "        ELSE 0 END) AS total_points, " +
                "  COUNT(*) AS predictions_graded " +
                "FROM Predictions p " +
                "JOIN Users u ON u.user_id = p.user_id " +
                "JOIN MatchResults mr ON mr.result_id = " +
                "  (SELECT MAX(latest.result_id) FROM MatchResults latest WHERE latest.match_id = p.match_id) " +
                "WHERE mr.team1_score IS NOT NULL AND mr.team2_score IS NOT NULL " +
                "GROUP BY u.user_id, u.name " +
                "ORDER BY total_points DESC, u.name ASC";
            try (PreparedStatement ps = conn.prepareStatement(leaderboardSql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String,Object> row = new LinkedHashMap<>();
                    row.put("user_id", rs.getInt("user_id"));
                    row.put("name", rs.getString("name"));
                    row.put("total_points", rs.getInt("total_points"));
                    row.put("predictions_graded", rs.getInt("predictions_graded"));
                    leaderboard.add(row);
                }
            }
        } catch (SQLException e) {
            predictionError = e.getMessage();
        }
    }
    String ctx = request.getContextPath();
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
        <h1 class="section-title">Leaderboard</h1>
        <p class="muted" style="margin-bottom: 1rem;">
            3 points for an exact score, 1 point if you get either team's score right, 0 otherwise.
            Only matches with a final result count.
        </p>
        <table class="data-table">
            <thead>
                <tr><th>Rank</th><th>Name</th><th>Points</th><th>Predictions Graded</th></tr>
            </thead>
            <tbody>
            <% int rank = 1; for (Map<String,Object> row : leaderboard) {
                boolean isYou = predictionUserId != null && predictionUserId.equals(row.get("user_id")); %>
                <tr class="<%= isYou ? "qualify-row" : "" %>">
                    <td><%= rank++ %></td>
                    <td class="team-name"><%= escapeHtml(row.get("name")) %><%= isYou ? " (You)" : "" %></td>
                    <td><strong><%= row.get("total_points") %></strong></td>
                    <td><%= row.get("predictions_graded") %></td>
                </tr>
            <% } %>
            <% if (leaderboard.isEmpty()) { %>
                <tr><td colspan="4" class="muted">No graded predictions yet - check back once some matches have results.</td></tr>
            <% } %>
            </tbody>
        </table>
    </section>

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
        <div class="login-notice">You can browse community predictions, but you must
            <a href="<%= ctx %>/login">sign in</a> to predict a score.
        </div>
        <% } %>

        <% if (predictionError != null) { %>
        <div class="db-error">Unable to load predictions: <%= escapeHtml(predictionError) %></div>
        <% } else { %>
        <div class="table-scroll">
            <table class="data-table prediction-table">
                <thead>
                    <tr><th>Date</th><th>Stage</th><th>Home</th><th>Score</th><th>Away</th><th>Venue</th><th>Status</th><th></th></tr>
                </thead>
                <tbody>
                <% for (Map<String,Object> match : upcomingMatches) {
                    int matchId = (Integer) match.get("match_id");
                    Timestamp matchDate = (Timestamp) match.get("match_date");
                    List<Map<String,Object>> community = predictionsByMatch.get(matchId);
                    if (community == null) community = Collections.emptyList();
                    Object savedTeam1 = match.get("saved_team1");
                    Object savedTeam2 = match.get("saved_team2");
                %>
                    <tr id="match-<%= matchId %>">
                        <td><%= matchDate == null ? "-" : escapeHtml(matchDate.toString().substring(0, 16)) %></td>
                        <td><span class="badge"><%= escapeHtml(match.get("stage")) %></span></td>
                        <td class="team-name"><%= escapeHtml(match.get("team1")) %></td>
                        <td class="score"><span class="vs">vs</span></td>
                        <td class="team-name"><%= escapeHtml(match.get("team2")) %></td>
                        <td><%= escapeHtml(match.get("stadium_name")) %>, <%= escapeHtml(match.get("city")) %></td>
                        <td><span class="status status-upcoming">Upcoming</span></td>
                        <td class="action-row">
                            <button type="button" class="btn btn-sm btn-secondary prediction-toggle"
                                aria-expanded="false" aria-controls="predictions-<%= matchId %>"
                                onclick="togglePredictionPanel('predictions-<%= matchId %>', this)">
                                Predictions (<%= community.size() %>)
                            </button>
                        </td>
                    </tr>
                    <tr id="predictions-<%= matchId %>" class="hidden-form">
                        <td colspan="8">
                            <div class="predictions-panel">
                                <div class="community-predictions">
                                    <h3>Community predictions</h3>
                                    <% if (community.isEmpty()) { %>
                                    <p class="empty-state">No predictions yet. Be the first to predict this match.</p>
                                    <% } else { %>
                                    <div class="prediction-list">
                                        <% for (Map<String,Object> item : community) {
                                            boolean isOwn = predictionUserId != null && predictionUserId.equals(item.get("user_id")); %>
                                        <div class="prediction-item">
                                            <span class="prediction-user"><%= escapeHtml(item.get("name")) %><%= isOwn ? " (You)" : "" %></span>
                                            <strong><%= item.get("team1_score") %> &ndash; <%= item.get("team2_score") %></strong>
                                        </div>
                                        <% } %>
                                    </div>
                                    <% } %>
                                </div>

                                <% if (predictionUserId != null) { %>
                                <form action="<%= ctx %>/predict" method="post" class="prediction-entry-form">
                                    <input type="hidden" name="matchId" value="<%= matchId %>">
                                    <h3><%= savedTeam1 == null ? "Predict the score" : "Update your prediction" %></h3>
                                    <div class="score-form">
                                        <label><span><%= escapeHtml(match.get("team1")) %></span>
                                            <input type="number" name="team1Score" min="0" max="99" required value="<%= savedTeam1 == null ? "" : savedTeam1 %>">
                                        </label>
                                        <span class="score-separator">&ndash;</span>
                                        <label><span><%= escapeHtml(match.get("team2")) %></span>
                                            <input type="number" name="team2Score" min="0" max="99" required value="<%= savedTeam2 == null ? "" : savedTeam2 %>">
                                        </label>
                                        <button type="submit" class="btn btn-primary btn-sm"><%= savedTeam1 == null ? "Save Prediction" : "Update Prediction" %></button>
                                    </div>
                                </form>
                                <% } else { %>
                                <p class="comment-signin-notice"><a href="<%= ctx %>/login">Sign in</a> to predict a score.</p>
                                <% } %>
                            </div>
                        </td>
                    </tr>
                <% } %>
                <% if (upcomingMatches.isEmpty()) { %>
                    <tr><td colspan="8" class="muted">There are no matches open for predictions.</td></tr>
                <% } %>
                </tbody>
            </table>
        </div>
        <% } %>
    </section>

    <% if (predictionError == null) { %>
    <section class="section">
        <h2 class="section-title">Finished Match Predictions</h2>
        <p class="prediction-legend">
            <span class="prediction-grade grade-correct">Correct</span> both scores match
            <span class="prediction-grade grade-partial">Partly correct</span> one score matches
            <span class="prediction-grade grade-incorrect">Incorrect</span> neither score matches
        </p>
        <div class="table-scroll">
            <table class="data-table prediction-table">
                <thead>
                    <tr><th>Date</th><th>Stage</th><th>Home</th><th>Final Score</th><th>Away</th><th>Venue</th><th>Status</th><th></th></tr>
                </thead>
                <tbody>
                <% for (Map<String,Object> match : finishedMatches) {
                    int matchId = (Integer) match.get("match_id");
                    int actualTeam1 = (Integer) match.get("team1_score");
                    int actualTeam2 = (Integer) match.get("team2_score");
                    Timestamp matchDate = (Timestamp) match.get("match_date");
                    List<Map<String,Object>> finishedPredictions = finishedPredictionsByMatch.get(matchId);
                %>
                    <tr id="finished-match-<%= matchId %>">
                        <td><%= matchDate == null ? "-" : escapeHtml(matchDate.toString().substring(0, 16)) %></td>
                        <td><span class="badge"><%= escapeHtml(match.get("stage")) %></span></td>
                        <td class="team-name"><%= escapeHtml(match.get("team1")) %></td>
                        <td class="score"><strong><%= actualTeam1 %> &ndash; <%= actualTeam2 %></strong></td>
                        <td class="team-name"><%= escapeHtml(match.get("team2")) %></td>
                        <td><%= escapeHtml(match.get("stadium_name")) %>, <%= escapeHtml(match.get("city")) %></td>
                        <td><span class="status status-finished">Finished</span></td>
                        <td class="action-row">
                            <button type="button" class="btn btn-sm btn-secondary prediction-toggle"
                                aria-expanded="false" aria-controls="finished-predictions-<%= matchId %>"
                                onclick="togglePredictionPanel('finished-predictions-<%= matchId %>', this)">
                                Results (<%= finishedPredictions.size() %>)
                            </button>
                        </td>
                    </tr>
                    <tr id="finished-predictions-<%= matchId %>" class="hidden-form">
                        <td colspan="8">
                            <div class="predictions-panel">
                                <h3>Prediction results</h3>
                                <div class="prediction-list finished-prediction-list">
                                <% for (Map<String,Object> item : finishedPredictions) {
                                    int predictedTeam1 = (Integer) item.get("team1_score");
                                    int predictedTeam2 = (Integer) item.get("team2_score");
                                    int matchingSides = (predictedTeam1 == actualTeam1 ? 1 : 0) + (predictedTeam2 == actualTeam2 ? 1 : 0);
                                    String gradeClass = matchingSides == 2 ? "grade-correct" : matchingSides == 1 ? "grade-partial" : "grade-incorrect";
                                    String gradeLabel = matchingSides == 2 ? "Correct" : matchingSides == 1 ? "Partly correct" : "Incorrect";
                                    boolean isOwn = predictionUserId != null && predictionUserId.equals(item.get("user_id"));
                                %>
                                    <div class="prediction-item finished-prediction-item">
                                        <span class="prediction-user"><%= escapeHtml(item.get("name")) %><%= isOwn ? " (You)" : "" %></span>
                                        <strong><%= predictedTeam1 %> &ndash; <%= predictedTeam2 %></strong>
                                        <span class="prediction-grade <%= gradeClass %>"><%= gradeLabel %></span>
                                    </div>
                                <% } %>
                                </div>
                            </div>
                        </td>
                    </tr>
                <% } %>
                <% if (finishedMatches.isEmpty()) { %>
                    <tr><td colspan="8" class="muted">No finished matches have predictions yet.</td></tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </section>
    <% } %>
</main>
<footer class="footer">CS157A Team 2 | FIFA World Cup 2026 | SJSU</footer>
<script>
function togglePredictionPanel(panelId, button) {
    var panel = document.getElementById(panelId);
    var willOpen = panel.classList.contains('hidden-form');
    panel.classList.toggle('hidden-form');
    button.setAttribute('aria-expanded', String(willOpen));
}

if (window.location.hash && window.location.hash.startsWith('#match-')) {
    var matchId = window.location.hash.replace('#match-', '');
    var panel = document.getElementById('predictions-' + matchId);
    var button = document.querySelector('[aria-controls="predictions-' + matchId + '"]');
    if (panel) panel.classList.remove('hidden-form');
    if (button) button.setAttribute('aria-expanded', 'true');
}
</script>
</body>
</html>
