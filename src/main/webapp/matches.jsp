<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.DBConnection,java.sql.*,java.util.*" %>
<%!
    private String escapeHtml(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }
%>
<%
    List<Map<String,Object>> matchList = new ArrayList<>();
    Map<Integer,List<Map<String,Object>>> commentsByMatch = new LinkedHashMap<>();
    String dbError = null;
    String commentError = (String) request.getAttribute("commentError");

    String matchSql =
        "SELECT m.match_id, m.match_date, m.stage, " +
        "c1.country_name AS team1, c2.country_name AS team2, " +
        "v.stadium_name, v.city, mr.team1_score, mr.team2_score " +
        "FROM Matches m " +
        "JOIN Countries c1 ON m.team1_country_name = c1.country_name " +
        "JOIN Countries c2 ON m.team2_country_name = c2.country_name " +
        "JOIN Venues v ON m.venue_id = v.venue_id " +
        "LEFT JOIN MatchResults mr ON m.match_id = mr.match_id " +
        "ORDER BY m.match_date ASC";

    String commentsSql =
        "SELECT c.match_id, c.content, c.created_at, u.name AS author " +
        "FROM Comments c JOIN Users u ON u.user_id = c.user_id " +
        "ORDER BY c.created_at ASC, c.comment_id ASC";

    try (Connection matchConn = DBConnection.getConnection()) {
        try (PreparedStatement matchStatement = matchConn.prepareStatement(matchSql);
             ResultSet matchRows = matchStatement.executeQuery()) {
            while (matchRows.next()) {
                Map<String,Object> match = new LinkedHashMap<>();
                match.put("id", matchRows.getInt("match_id"));
                match.put("date", matchRows.getTimestamp("match_date"));
                match.put("stage", matchRows.getString("stage"));
                match.put("team1", matchRows.getString("team1"));
                match.put("team2", matchRows.getString("team2"));
                match.put("stadium", matchRows.getString("stadium_name"));
                match.put("city", matchRows.getString("city"));
                match.put("score1", matchRows.getObject("team1_score"));
                match.put("score2", matchRows.getObject("team2_score"));
                matchList.add(match);
                commentsByMatch.put(matchRows.getInt("match_id"), new ArrayList<>());
            }
        }

        try (PreparedStatement commentsStatement = matchConn.prepareStatement(commentsSql);
             ResultSet commentRows = commentsStatement.executeQuery()) {
            while (commentRows.next()) {
                List<Map<String,Object>> matchComments =
                    commentsByMatch.get(commentRows.getInt("match_id"));
                if (matchComments != null) {
                    Map<String,Object> comment = new LinkedHashMap<>();
                    comment.put("author", commentRows.getString("author"));
                    comment.put("content", commentRows.getString("content"));
                    comment.put("created", commentRows.getTimestamp("created_at"));
                    matchComments.add(comment);
                }
            }
        }
    } catch (SQLException e) {
        dbError = e.getMessage();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Matches - World Cup 2026</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<%@ include file="/WEB-INF/jspf/navbar.jspf" %>
<main class="container">
    <section class="section">
        <h1 class="section-title">Match Schedule and Comments</h1>

        <% if ("saved".equals(request.getParameter("comment"))) { %>
            <div class="form-message form-success">Your comment was posted permanently.</div>
        <% } else if ("invalid".equals(request.getParameter("comment"))) { %>
            <div class="form-message form-error">Comments must contain 1–250 characters.</div>
        <% } %>
        <% if (commentError != null) { %>
            <div class="db-error"><%= escapeHtml(commentError) %></div>
        <% } %>

        <% if (dbError != null) { %>
            <div class="db-error">Unable to load matches: <%= escapeHtml(dbError) %></div>
        <% } else if (matchList.isEmpty()) { %>
            <p class="empty-state">No matches are scheduled.</p>
        <% } else { %>
            <div class="match-list">
            <% for (Map<String,Object> match : matchList) {
                int matchId = (Integer) match.get("id");
                Object team1Score = match.get("score1");
                Object team2Score = match.get("score2");
                boolean played = team1Score != null && team2Score != null;
                List<Map<String,Object>> matchComments = commentsByMatch.get(matchId);
            %>
                <article class="match-card" id="match-<%= matchId %>">
                    <div class="match-summary">
                        <div class="match-heading">
                            <span class="badge"><%= match.get("stage") %></span>
                            <span><%= match.get("date") %></span>
                        </div>
                        <div class="match-teams">
                            <strong><%= match.get("team1") %></strong>
                            <span class="match-score">
                                <%= played ? team1Score + " – " + team2Score : "vs" %>
                            </span>
                            <strong><%= match.get("team2") %></strong>
                        </div>
                        <p class="prediction-venue"><%= match.get("stadium") %>, <%= match.get("city") %></p>
                    </div>

                    <div class="comments-section">
                        <h2>Fan Comments <span>(<%= matchComments.size() %>)</span></h2>
                        <% if (matchComments.isEmpty()) { %>
                            <p class="no-comments">No comments yet.</p>
                        <% } else { %>
                            <div class="comment-list">
                            <% for (Map<String,Object> comment : matchComments) { %>
                                <div class="comment">
                                    <div class="comment-meta">
                                        <strong><%= escapeHtml((String) comment.get("author")) %></strong>
                                        <time><%= comment.get("created") %></time>
                                    </div>
                                    <p><%= escapeHtml((String) comment.get("content")) %></p>
                                </div>
                            <% } %>
                            </div>
                        <% } %>

                        <% if (session.getAttribute("userId") != null) { %>
                            <form action="comment" method="post" class="comment-form">
                                <input type="hidden" name="matchId" value="<%= matchId %>">
                                <label for="comment-<%= matchId %>">Add a permanent comment</label>
                                <textarea id="comment-<%= matchId %>" name="content"
                                          maxlength="250" required
                                          placeholder="Share your thoughts about this match…"></textarea>
                                <div class="comment-actions">
                                    <small>Maximum 250 characters. Comments cannot be edited or deleted.</small>
                                    <button type="submit" class="btn-primary">Post Comment</button>
                                </div>
                            </form>
                        <% } else { %>
                            <p class="comment-login">
                                <a href="login.jsp">Sign in</a> to post a comment.
                            </p>
                        <% } %>
                    </div>
                </article>
            <% } %>
            </div>
        <% } %>
    </section>
</main>
<footer class="footer">CS157A Team 2 | FIFA World Cup 2026 | SJSU</footer>
</body>
</html>
