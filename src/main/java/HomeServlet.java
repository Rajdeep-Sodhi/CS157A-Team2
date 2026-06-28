import dao.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.*;
import java.util.*;

/**
 * HomeServlet.java
 * Fetches match schedule and group standings from MySQL,
 * then forwards to index.jsp for rendering.
 */
@WebServlet("/")
public class HomeServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        List<Map<String, String>> matches   = new ArrayList<>();
        List<Map<String, String>> standings = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection()) {

            // --- Fetch matches with team names and venue ---
            String matchSQL =
                "SELECT m.match_id, m.match_date, m.stage, " +
                "       c1.country_name AS team1, c2.country_name AS team2, " +
                "       v.stadium_name, v.city, " +
                "       m.team1_score, m.team2_score " +
                "FROM Matches m " +
                "JOIN Teams t1 ON m.team1_id = t1.team_id " +
                "JOIN Teams t2 ON m.team2_id = t2.team_id " +
                "JOIN Countries c1 ON t1.country_id = c1.country_id " +
                "JOIN Countries c2 ON t2.country_id = c2.country_id " +
                "JOIN Venues v ON m.venue_id = v.venue_id " +
                "ORDER BY m.match_date ASC";

            try (Statement st = conn.createStatement();
                 ResultSet rs = st.executeQuery(matchSQL)) {
                while (rs.next()) {
                    Map<String, String> row = new LinkedHashMap<>();
                    row.put("match_date",  rs.getString("match_date"));
                    row.put("stage",       rs.getString("stage"));
                    row.put("team1",       rs.getString("team1"));
                    row.put("team2",       rs.getString("team2"));
                    row.put("stadium",     rs.getString("stadium_name"));
                    row.put("city",        rs.getString("city"));
                    row.put("team1_score", rs.getString("team1_score")); // null if not played
                    row.put("team2_score", rs.getString("team2_score"));
                    matches.add(row);
                }
            }

            // --- Fetch group standings ---
            String standingsSQL =
                "SELECT c.country_name, t.group_letter, " +
                "       gs.wins, gs.draws, gs.losses, gs.goal_diff, gs.points " +
                "FROM GroupStandings gs " +
                "JOIN Teams t ON gs.team_id = t.team_id " +
                "JOIN Countries c ON t.country_id = c.country_id " +
                "ORDER BY t.group_letter ASC, gs.points DESC, gs.goal_diff DESC";

            try (Statement st = conn.createStatement();
                 ResultSet rs = st.executeQuery(standingsSQL)) {
                while (rs.next()) {
                    Map<String, String> row = new LinkedHashMap<>();
                    row.put("country",   rs.getString("country_name"));
                    row.put("group",     rs.getString("group_letter"));
                    row.put("wins",      rs.getString("wins"));
                    row.put("draws",     rs.getString("draws"));
                    row.put("losses",    rs.getString("losses"));
                    row.put("goal_diff", rs.getString("goal_diff"));
                    row.put("points",    rs.getString("points"));
                    standings.add(row);
                }
            }

        } catch (SQLException e) {
            req.setAttribute("dbError", e.getMessage());
        }

        req.setAttribute("matches",   matches);
        req.setAttribute("standings", standings);
        req.getRequestDispatcher("/index.jsp").forward(req, resp);
    }
}
