<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.util.*" %>
<%
    List<Map<String,String>> matches = new ArrayList<>();
    List<Map<String,String>> standings = new ArrayList<>();
    String dbError = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/worldcup2026?useSSL=false&allowPublicKeyRetrieval=true",
            "root", "YOUR_PASSWORD_HERE");

        String matchSQL =
            "SELECT m.match_date, m.stage, " +
            "c1.country_name AS team1, c2.country_name AS team2, " +
            "v.stadium_name, v.city, m.team1_score, m.team2_score " +
            "FROM Matches m " +
            "JOIN Teams t1 ON m.team1_id = t1.team_id " +
            "JOIN Teams t2 ON m.team2_id = t2.team_id " +
            "JOIN Countries c1 ON t1.country_id = c1.country_id " +
            "JOIN Countries c2 ON t2.country_id = c2.country_id " +
            "JOIN Venues v ON m.venue_id = v.venue_id " +
            "ORDER BY m.match_date ASC";
        ResultSet rs = conn.createStatement().executeQuery(matchSQL);
        while (rs.next()) {
            Map<String,String> row = new LinkedHashMap<>();
            row.put("match_date",  rs.getString("match_date"));
            row.put("stage",       rs.getString("stage"));
            row.put("team1",       rs.getString("team1"));
            row.put("team2",       rs.getString("team2"));
            row.put("stadium",     rs.getString("stadium_name"));
            row.put("city",        rs.getString("city"));
            row.put("team1_score", rs.getString("team1_score"));
            row.put("team2_score", rs.getString("team2_score"));
            matches.add(row);
        }

        String standSQL =
            "SELECT c.country_name, t.group_letter, " +
            "gs.wins, gs.draws, gs.losses, gs.goal_diff, gs.points " +
            "FROM GroupStandings gs " +
            "JOIN Teams t ON gs.team_id = t.team_id " +
            "JOIN Countries c ON t.country_id = c.country_id " +
            "ORDER BY t.group_letter ASC, gs.points DESC, gs.goal_diff DESC";
        rs = conn.createStatement().executeQuery(standSQL);
        while (rs.next()) {
            Map<String,String> row = new LinkedHashMap<>();
            row.put("country",   rs.getString("country_name"));
            row.put("group",     rs.getString("group_letter"));
            row.put("wins",      rs.getString("wins"));
            row.put("draws",     rs.getString("draws"));
            row.put("losses",    rs.getString("losses"));
            row.put("goal_diff", rs.getString("goal_diff"));
            row.put("points",    rs.getString("points"));
            standings.add(row);
        }
        conn.close();
    } catch (Exception e) {
        dbError = e.getMessage();
    }

    Map<String,List<Map<String,String>>> grouped = new LinkedHashMap<>();
    for (Map<String,String> row : standings) {
        String g = row.get("group");
        grouped.computeIfAbsent(g, k -> new ArrayList<>()).add(row);
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>World Cup 2026</title>
    <style>
        *{box-sizing:border-box;margin:0;padding:0}
        body{font-family:'Segoe UI',system-ui,Arial,sans-serif;background:#f0f2f5;color:#1a1a2e;min-height:100vh}
        .navbar{display:flex;align-items:center;justify-content:space-between;background:#1e293b;padding:0 2rem;height:60px;border-bottom:3px solid #3b82f6;position:sticky;top:0;z-index:100}
        .nav-brand{font-size:1.1rem;font-weight:700;color:#f8fafc;letter-spacing:.5px}
        .nav-links{display:flex;gap:2rem;list-style:none}
        .nav-links a{color:#94a3b8;text-decoration:none;font-size:.9rem;font-weight:500;transition:color .2s}
        .nav-links a:hover,.nav-links a.active{color:#f8fafc}
        .nav-auth{display:flex;gap:.6rem}
        .btn-login{padding:.35rem 1rem;border:1px solid #475569;color:#cbd5e1;text-decoration:none;border-radius:6px;font-size:.85rem}
        .btn-login:hover{border-color:#94a3b8;color:#f8fafc}
        .btn-register{padding:.35rem 1rem;background:#3b82f6;color:#fff;text-decoration:none;border-radius:6px;font-size:.85rem;font-weight:600}
        .btn-register:hover{background:#2563eb}
        .hero{background:#1e293b;border-bottom:1px solid #334155;padding:4rem 2rem;text-align:center}
        .hero-label{font-size:.72rem;letter-spacing:4px;color:#3b82f6;font-weight:700;margin-bottom:1rem;text-transform:uppercase}
        .hero h1{font-size:2.8rem;font-weight:800;color:#f8fafc;letter-spacing:2px;margin-bottom:.75rem}
        .hero p{color:#64748b;font-size:1rem}
        .container{max-width:1200px;margin:0 auto;padding:2.5rem 2rem}
        .section{margin-bottom:3rem}
        .section-title{font-size:1.15rem;font-weight:700;color:#1e293b;margin-bottom:1rem;padding-bottom:.5rem;border-bottom:2px solid #e2e8f0}
        .data-table{width:100%;border-collapse:collapse;background:#fff;border-radius:8px;overflow:hidden;font-size:.88rem;box-shadow:0 1px 4px rgba(0,0,0,.06)}
        .data-table thead{background:#f8fafc;border-bottom:2px solid #e2e8f0}
        .data-table th{padding:.75rem 1rem;text-align:left;color:#64748b;font-weight:600;font-size:.75rem;letter-spacing:.8px;text-transform:uppercase}
        .data-table td{padding:.75rem 1rem;border-bottom:1px solid #f1f5f9;color:#374151;vertical-align:middle}
        .data-table tbody tr:hover{background:#f8fafc}
        .data-table tbody tr:last-child td{border-bottom:none}
        .team-name{font-weight:600;color:#1e293b}
        .score{text-align:center;min-width:80px}
        .score strong{font-size:1rem;color:#1e293b}
        .vs{color:#cbd5e1;font-size:.85rem}
        .badge{display:inline-block;padding:.2rem .6rem;background:#eff6ff;color:#3b82f6;border-radius:4px;font-size:.72rem;font-weight:600}
        .status{display:inline-block;padding:.2rem .6rem;border-radius:4px;font-size:.72rem;font-weight:600}
        .status-finished{background:#f0fdf4;color:#16a34a}
        .status-upcoming{background:#f8fafc;color:#64748b}
        .standings-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(265px,1fr));gap:1.25rem}
        .group-card{background:#fff;border-radius:8px;overflow:hidden;box-shadow:0 1px 4px rgba(0,0,0,.06);border:1px solid #e2e8f0}
        .group-title{background:#1e293b;color:#f8fafc;font-size:.8rem;font-weight:700;padding:.6rem 1rem;letter-spacing:3px;text-transform:uppercase}
        .qualify-row td:first-child{border-left:3px solid #3b82f6;padding-left:.75rem}
        .db-error{background:#fef2f2;border:1px solid #fca5a5;color:#dc2626;padding:1rem 1.5rem;border-radius:6px;margin-bottom:2rem;font-size:.88rem}
        .footer{text-align:center;padding:1.5rem;color:#94a3b8;font-size:.82rem;border-top:1px solid #e2e8f0;background:#fff;margin-top:1rem}
    </style>
</head>
<body>

<nav class="navbar">
    <div class="nav-brand">🏆 World Cup 2026</div>
    <ul class="nav-links">
        <li><a href="index.jsp" class="active">Home</a></li>
        <li><a href="matches.jsp">Matches</a></li>
        <li><a href="standings.jsp">Standings</a></li>
        <li><a href="teams.jsp">Teams</a></li>
        <li><a href="predictions.jsp">Predictions</a></li>
    </ul>
    <div class="nav-auth">
        <a href="login.jsp" class="btn-login">Sign In</a>
        <a href="register.jsp" class="btn-register">Register</a>
    </div>
</nav>

<section class="hero">
    <div class="hero-label">FIFA WORLD CUP 2026</div>
    <h1>USA &middot; Canada &middot; Mexico</h1>
    <p>Track every match, predict every result.</p>
</section>

<main class="container">

<% if (dbError != null) { %>
<div class="db-error">⚠️ DB Error: <%= dbError %></div>
<% } %>

    <section class="section">
        <h2 class="section-title">Match Schedule</h2>
        <table class="data-table">
            <thead>
                <tr>
                    <th>Date</th><th>Stage</th><th>Home</th>
                    <th>Score</th><th>Away</th><th>Venue</th><th>Status</th>
                </tr>
            </thead>
            <tbody>
            <% for (Map<String,String> m : matches) {
                String s1 = m.get("team1_score");
                String s2 = m.get("team2_score");
                boolean played = (s1 != null && !s1.equals("null") && s2 != null && !s2.equals("null")); %>
                <tr>
                    <td><%= m.get("match_date") %></td>
                    <td><span class="badge"><%= m.get("stage") %></span></td>
                    <td class="team-name"><%= m.get("team1") %></td>
                    <td class="score">
                        <% if (played) { %><strong><%= s1 %> &ndash; <%= s2 %></strong>
                        <% } else { %><span class="vs">vs</span><% } %>
                    </td>
                    <td class="team-name"><%= m.get("team2") %></td>
                    <td><%= m.get("stadium") %>, <%= m.get("city") %></td>
                    <td><span class="status <%= played ? "status-finished" : "status-upcoming" %>">
                        <%= played ? "Finished" : "Upcoming" %></span></td>
                </tr>
            <% } %>
            </tbody>
        </table>
    </section>

    <section class="section">
        <h2 class="section-title">Group Standings</h2>
        <div class="standings-grid">
        <% for (Map.Entry<String,List<Map<String,String>>> entry : grouped.entrySet()) { %>
            <div class="group-card">
                <h3 class="group-title">GROUP <%= entry.getKey() %></h3>
                <table class="data-table">
                    <thead><tr><th>Team</th><th>W</th><th>D</th><th>L</th><th>GD</th><th>Pts</th></tr></thead>
                    <tbody>
                    <% int rank = 1; for (Map<String,String> row : entry.getValue()) { %>
                        <tr class="<%= rank <= 2 ? "qualify-row" : "" %>">
                            <td><%= row.get("country") %></td>
                            <td><%= row.get("wins") %></td>
                            <td><%= row.get("draws") %></td>
                            <td><%= row.get("losses") %></td>
                            <td><%= row.get("goal_diff") %></td>
                            <td><strong><%= row.get("points") %></strong></td>
                        </tr>
                    <% rank++; } %>
                    </tbody>
                </table>
            </div>
        <% } %>
        </div>
    </section>

</main>

<footer class="footer">
    CS157A Team 2 &nbsp;|&nbsp; FIFA World Cup 2026 &nbsp;|&nbsp; SJSU
</footer>
</body>
</html>
