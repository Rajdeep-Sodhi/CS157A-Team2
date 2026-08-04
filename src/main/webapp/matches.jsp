<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, model.User" %>
<%
    User authUser = (User) session.getAttribute("authUser");
    boolean isAdmin = authUser != null && authUser.isAdmin();
    boolean isLoggedIn = authUser != null;

    List<Map<String,Object>> matches = (List<Map<String,Object>>) request.getAttribute("matches");
    if (matches == null) matches = new ArrayList<>();
    List<Map<String,Object>> groupTeams = (List<Map<String,Object>>) request.getAttribute("groupTeams");
    if (groupTeams == null) groupTeams = new ArrayList<>();
    List<Map<String,Object>> venues = (List<Map<String,Object>>) request.getAttribute("venues");
    if (venues == null) venues = new ArrayList<>();
    Map<Integer,List<Map<String,Object>>> commentsByMatch =
        (Map<Integer,List<Map<String,Object>>>) request.getAttribute("commentsByMatch");
    if (commentsByMatch == null) commentsByMatch = new HashMap<>();
    String dbError = (String) request.getAttribute("dbError");
    String commentStatus = request.getParameter("comment");
    String flagStatus = request.getParameter("flag");
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Matches - World Cup 2026</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<% request.setAttribute("currentPage", "matches"); %>
<%@ include file="nav.jsp" %>
<main class="container">

    <% if (dbError != null) { %>
    <div class="db-error">Error: <%= dbError %></div>
    <% } %>

    <% if ("submitted".equals(flagStatus)) { %>
    <div id="flag-message" class="form-message form-success">Your flag has been taken into consideration. The admins have been notified.</div>
    <% } else if ("invalid".equals(flagStatus)) { %>
    <div id="flag-message" class="form-message form-error">Please provide a reason between 1 and 250 characters.</div>
    <% } else if ("unavailable".equals(flagStatus)) { %>
    <div id="flag-message" class="form-message form-error">That comment cannot be flagged. It may be yours or already reported.</div>
    <% } %>

    <% if ("saved".equals(commentStatus)) { %>
    <div class="form-message form-success">Your comment was posted.</div>
    <% } else if ("invalid".equals(commentStatus)) { %>
    <div class="form-message form-error">Comment couldn't be posted - check it's between 1 and 250 characters.</div>
    <% } else if ("deleted".equals(commentStatus)) { %>
    <div id="comment-message" class="form-message form-success">The comment was removed.</div>
    <% } else if ("delete-invalid".equals(commentStatus)) { %>
    <div id="comment-message" class="form-message form-error">The comment could not be removed. It may no longer exist.</div>
    <% } %>

    <section class="section">
        <h2 class="section-title">Match Schedule</h2>
        <table class="data-table">
            <thead>
                <tr>
                    <th>Date</th><th>Stage</th><th>Home</th><th>Score</th><th>Away</th><th>Venue</th><th>Status</th><th></th>
                    <% if (isAdmin) { %><th></th><% } %>
                </tr>
            </thead>
            <tbody>
            <% for (Map<String,Object> m : matches) {
                Object s1 = m.get("team1_score");
                Object s2 = m.get("team2_score");
                boolean played = (s1 != null && s2 != null);
                String rawDate = (String) m.get("match_date"); // "2026-06-22 18:00:00.0"
                String dtLocal = rawDate == null ? "" : rawDate.substring(0, 16).replace(" ", "T");
                String team1Country = (String) m.get("team1_country_name");
                String team2Country = (String) m.get("team2_country_name");
            %>
                <tr id="match-<%= m.get("match_id") %>">
                    <td><%= rawDate == null ? "-" : rawDate.substring(0, 16) %></td>
                    <td><span class="badge"><%= m.get("stage") %></span></td>
                    <td class="team-name"><%= team1Country %></td>
                    <td class="score">
                        <% if (played) { %><strong><%= s1 %> &ndash; <%= s2 %></strong>
                        <% } else { %><span class="vs">vs</span><% } %>
                    </td>
                    <td class="team-name"><%= team2Country %></td>
                    <td><%= m.get("stadium_name") %>, <%= m.get("city") %></td>
                    <td><span class="status <%= played ? "status-finished" : "status-upcoming" %>"><%= played ? "Finished" : "Upcoming" %></span></td>
                    <%
                        List<Map<String,Object>> matchComments = commentsByMatch.get((Integer) m.get("match_id"));
                        int commentCount = matchComments == null ? 0 : matchComments.size();
                    %>
                    <td class="action-row">
                        <button type="button" class="btn btn-sm btn-secondary" onclick="document.getElementById('comments-<%= m.get("match_id") %>').classList.toggle('hidden-form')">Comments (<%= commentCount %>)</button>
                    </td>
                    <% if (isAdmin) { %>
                    <td class="action-row">
                        <button type="button" class="btn btn-sm btn-secondary" onclick="document.getElementById('edit-<%= m.get("match_id") %>').classList.toggle('hidden-form')">Manage</button>
                    </td>
                    <% } %>
                </tr>
                <tr id="comments-<%= m.get("match_id") %>" class="hidden-form">
                    <td colspan="<%= isAdmin ? 9 : 8 %>">
                        <div class="comments-panel">
                            <div class="comment-list">
                            <% if (matchComments != null) { for (Map<String,Object> c : matchComments) { %>
                                <div class="comment-item">
                                    <div class="comment-meta">
                                        <span class="comment-author"><%= c.get("commenter_name") %></span>
                                        <span>
                                            <%= c.get("created_at") == null ? "" : ((String) c.get("created_at")).substring(0, 16) %>
                                            <% if (isAdmin && Boolean.TRUE.equals(c.get("is_flagged"))) { %><span class="comment-flagged">Flagged for review</span><% } %>
                                        </span>
                                    </div>
                                    <div class="comment-content"><%= c.get("content") %></div>
                                    <% if (isAdmin) { %>
                                    <form method="post" action="<%= ctx %>/delete-comment" class="comment-delete-form">
                                        <input type="hidden" name="commentId" value="<%= c.get("comment_id") %>">
                                        <input type="hidden" name="matchId" value="<%= m.get("match_id") %>">
                                        <button type="submit" class="btn btn-danger btn-sm" onclick="return confirm('Remove this comment permanently?');">Remove Comment</button>
                                    </form>
                                    <% } %>
                                    <% if (isAdmin && Boolean.TRUE.equals(c.get("is_flagged"))) { %>
                                    <div class="flag-review">
                                        <strong>Report reason:</strong> <%= c.get("flag_reason") %>
                                        <% if (c.get("reporter_name") != null) { %>
                                        <span>Reported by <%= c.get("reporter_name") %></span>
                                        <% } %>
                                    </div>
                                    <% } %>
                                    <% if (isLoggedIn && authUser.getUserId() != (Integer) c.get("user_id") && !Boolean.TRUE.equals(c.get("is_flagged"))) { %>
                                    <button type="button" class="comment-flag-button" onclick="document.getElementById('flag-form-<%= c.get("comment_id") %>').classList.toggle('hidden-form')">Flag comment</button>
                                    <form id="flag-form-<%= c.get("comment_id") %>" method="post" action="<%= ctx %>/flag-comment" class="comment-flag-form hidden-form">
                                        <input type="hidden" name="commentId" value="<%= c.get("comment_id") %>">
                                        <input type="hidden" name="matchId" value="<%= m.get("match_id") %>">
                                        <label for="flag-reason-<%= c.get("comment_id") %>">Why are you flagging this comment?</label>
                                        <textarea id="flag-reason-<%= c.get("comment_id") %>" name="reason" maxlength="250" required placeholder="Explain the issue (250 characters maximum)"></textarea>
                                        <div class="flag-form-footer">
                                            <span class="flag-character-count">250 characters maximum</span>
                                            <button type="submit" class="btn btn-danger btn-sm">Submit Flag</button>
                                        </div>
                                    </form>
                                    <% } %>
                                </div>
                            <% } }
                               if (commentCount == 0) { %>
                                <p class="empty-state">No comments yet.</p>
                            <% } %>
                            </div>
                            <% if (isLoggedIn) { %>
                            <form method="post" action="<%= ctx %>/comment" class="comment-form">
                                <input type="hidden" name="matchId" value="<%= m.get("match_id") %>">
                                <textarea name="content" maxlength="250" placeholder="Share your thoughts on this match (250 char max)..." required></textarea>
                                <div class="form-actions" style="margin-top:.5rem;">
                                    <button type="submit" class="btn btn-primary btn-sm">Post Comment</button>
                                </div>
                            </form>
                            <% } else { %>
                            <p class="comment-signin-notice">
                                <a href="<%= ctx %>/login">Sign in</a> to leave a comment.
                            </p>
                            <% } %>
                        </div>
                    </td>
                </tr>
                <% if (isAdmin) { %>
                <tr id="edit-<%= m.get("match_id") %>" class="hidden-form">
                    <td colspan="9">
                        <div class="two-col" style="padding: 1rem 0;">
                            <form method="post" action="<%= ctx %>/matches" class="form-grid">
                                <input type="hidden" name="action" value="edit">
                                <input type="hidden" name="match_id" value="<%= m.get("match_id") %>">
                                <div class="form-field">
                                    <label>Team 1</label>
                                    <select name="team1_country" required>
                                        <% for (Map<String,Object> gt : groupTeams) {
                                            String gtCountry = (String) gt.get("country_name"); %>
                                        <option value="<%= gtCountry %>" <%= gtCountry.equals(team1Country) ? "selected" : "" %>><%= gtCountry %> (Group <%= gt.get("group_letter") %>)</option>
                                        <% } %>
                                    </select>
                                </div>
                                <div class="form-field">
                                    <label>Team 2</label>
                                    <select name="team2_country" required>
                                        <% for (Map<String,Object> gt : groupTeams) {
                                            String gtCountry = (String) gt.get("country_name"); %>
                                        <option value="<%= gtCountry %>" <%= gtCountry.equals(team2Country) ? "selected" : "" %>><%= gtCountry %> (Group <%= gt.get("group_letter") %>)</option>
                                        <% } %>
                                    </select>
                                </div>
                                <div class="form-field">
                                    <label>Venue</label>
                                    <select name="venue_id" required>
                                        <% for (Map<String,Object> v : venues) { %>
                                        <option value="<%= v.get("venue_id") %>" <%= v.get("venue_id").equals(m.get("venue_id")) ? "selected" : "" %>><%= v.get("stadium_name") %></option>
                                        <% } %>
                                    </select>
                                </div>
                                <div class="form-field">
                                    <label>Date &amp; Time</label>
                                    <input type="datetime-local" name="match_date" value="<%= dtLocal %>" required>
                                </div>
                                <div class="form-field">
                                    <label>Stage</label>
                                    <input type="text" name="stage" value="<%= m.get("stage") %>" required>
                                </div>
                                <div class="form-field form-actions">
                                    <button type="submit" class="btn btn-primary btn-sm">Save Schedule</button>
                                </div>
                            </form>

                            <div>
                                <form method="post" action="<%= ctx %>/matches" class="form-grid">
                                    <input type="hidden" name="action" value="result">
                                    <input type="hidden" name="match_id" value="<%= m.get("match_id") %>">
                                    <div class="form-field">
                                        <label><%= team1Country %> Score</label>
                                        <input type="number" name="team1_score" min="0" value="<%= s1 == null ? "" : s1 %>">
                                    </div>
                                    <div class="form-field">
                                        <label><%= team2Country %> Score</label>
                                        <input type="number" name="team2_score" min="0" value="<%= s2 == null ? "" : s2 %>">
                                    </div>
                                    <div class="form-field form-actions full">
                                        <button type="submit" class="btn btn-primary btn-sm">Save Result</button>
                                    </div>
                                </form>
                                <form method="post" action="<%= ctx %>/matches" style="margin-top:.5rem;">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="match_id" value="<%= m.get("match_id") %>">
                                    <button type="submit" class="btn btn-danger btn-sm" onclick="return confirm('Delete this match?');">Delete Match</button>
                                </form>
                            </div>
                        </div>
                    </td>
                </tr>
                <% } %>
            <% } %>
            <% if (matches.isEmpty()) { %>
                <tr><td colspan="<%= isAdmin ? 9 : 8 %>" class="muted">No matches scheduled yet.</td></tr>
            <% } %>
            </tbody>
        </table>
    </section>

    <% if (isAdmin) { %>
    <section class="section">
        <h2 class="section-title">Schedule a New Match</h2>
        <% if (groupTeams.size() < 2) { %>
        <p class="muted">You need at least two teams assigned to a group before you can schedule a match.</p>
        <% } else { %>
        <div class="form-card wide">
            <form method="post" action="<%= ctx %>/matches">
                <input type="hidden" name="action" value="add">
                <div class="form-grid">
                    <div class="form-field">
                        <label for="n_team1">Team 1</label>
                        <select id="n_team1" name="team1_country" required>
                            <% for (Map<String,Object> gt : groupTeams) { %>
                            <option value="<%= gt.get("country_name") %>"><%= gt.get("country_name") %> (Group <%= gt.get("group_letter") %>)</option>
                            <% } %>
                        </select>
                    </div>
                    <div class="form-field">
                        <label for="n_team2">Team 2</label>
                        <select id="n_team2" name="team2_country" required>
                            <% for (Map<String,Object> gt : groupTeams) { %>
                            <option value="<%= gt.get("country_name") %>"><%= gt.get("country_name") %> (Group <%= gt.get("group_letter") %>)</option>
                            <% } %>
                        </select>
                    </div>
                    <div class="form-field">
                        <label for="n_venue">Venue</label>
                        <select id="n_venue" name="venue_id" required>
                            <% for (Map<String,Object> v : venues) { %>
                            <option value="<%= v.get("venue_id") %>"><%= v.get("stadium_name") %> - <%= v.get("city") %></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="form-field">
                        <label for="n_date">Date &amp; Time</label>
                        <input type="datetime-local" id="n_date" name="match_date" required>
                    </div>
                    <div class="form-field">
                        <label for="n_stage">Stage</label>
                        <input type="text" id="n_stage" name="stage" placeholder="e.g. Group A, Round of 16" required>
                    </div>
                </div>
                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">Schedule Match</button>
                </div>
            </form>
        </div>
        <% } %>
        <p class="muted" style="margin-top:1rem;">
            Only teams already assigned to a group can be scheduled, and a stadium can't host two matches at once.
            <a href="teams">Assign a team to a group &rarr;</a>
        </p>
    </section>
    <% } %>

</main>
<footer class="footer">CS157A Team 2 | FIFA World Cup 2026 | SJSU</footer>
<style>.hidden-form{display:none}</style>
<script>
    // Landing here via a #match-X link (e.g. right after posting a comment)
    // should show the comments panel, not just scroll to a collapsed row.
    if (window.location.hash && window.location.hash.startsWith('#match-')) {
        var matchId = window.location.hash.replace('#match-', '');
        var panel = document.getElementById('comments-' + matchId);
        if (panel) panel.classList.remove('hidden-form');
    }
    var flagMessage = document.getElementById('flag-message');
    if (flagMessage) {
        window.setTimeout(function () { flagMessage.classList.add('message-hidden'); }, 6000);
    }
    var commentMessage = document.getElementById('comment-message');
    if (commentMessage) {
        window.setTimeout(function () { commentMessage.classList.add('message-hidden'); }, 6000);
    }
</script>
</body>
</html>
