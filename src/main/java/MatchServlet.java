import dao.MatchDAO;
import dao.TeamDAO;
import dao.VenueDAO;
import util.AuthHelper;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.net.URLEncoder;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;

/**
 * MatchServlet.java
 * FR: "Matches Management" - schedule listing for everyone,
 * create/edit/delete/result-entry restricted to admins.
 * Teams are identified by country name (no team_id in this schema).
 */
@WebServlet("/matches")
public class MatchServlet extends HttpServlet {

    private final MatchDAO matchDAO = new MatchDAO();
    private final TeamDAO teamDAO = new TeamDAO();
    private final VenueDAO venueDAO = new VenueDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String errorParam = req.getParameter("error");
        if (errorParam != null && !errorParam.isBlank()) {
            req.setAttribute("dbError", errorParam);
        }

        try {
            List<Map<String, Object>> matches = matchDAO.listAll();
            req.setAttribute("matches", matches);
            req.setAttribute("groupTeams", teamDAO.listGroupAssignedTeams());
            req.setAttribute("venues", venueDAO.listAll());
        } catch (SQLException e) {
            req.setAttribute("dbError", e.getMessage());
        }

        req.getRequestDispatcher("/matches.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!AuthHelper.requireAdmin(req, resp)) return;

        String action = req.getParameter("action");
        try {
            switch (action == null ? "" : action) {
                case "add":
                    handleAdd(req);
                    break;
                case "edit":
                    handleEdit(req);
                    break;
                case "result":
                    handleResult(req);
                    break;
                case "delete":
                    handleDelete(req);
                    break;
                default:
                    throw new IllegalStateException("Unknown action.");
            }
            resp.sendRedirect(req.getContextPath() + "/matches");
        } catch (SQLException e) {
            redirectWithError(req, resp, "Database error: " + e.getMessage());
        } catch (NumberFormatException e) {
            redirectWithError(req, resp, "Please check that all numeric fields are valid.");
        } catch (IllegalArgumentException | IllegalStateException e) {
            redirectWithError(req, resp, e.getMessage());
        }
    }

    private void handleAdd(HttpServletRequest req) throws SQLException {
        String team1Country = req.getParameter("team1_country");
        String team2Country = req.getParameter("team2_country");
        int venueId = Integer.parseInt(req.getParameter("venue_id"));
        String matchDateTime = req.getParameter("match_date");
        String stage = req.getParameter("stage");
        matchDAO.create(team1Country, team2Country, venueId, matchDateTime, stage);
    }

    private void handleEdit(HttpServletRequest req) throws SQLException {
        int matchId = Integer.parseInt(req.getParameter("match_id"));
        String team1Country = req.getParameter("team1_country");
        String team2Country = req.getParameter("team2_country");
        int venueId = Integer.parseInt(req.getParameter("venue_id"));
        String matchDateTime = req.getParameter("match_date");
        String stage = req.getParameter("stage");
        matchDAO.update(matchId, team1Country, team2Country, venueId, matchDateTime, stage);
    }

    private void handleResult(HttpServletRequest req) throws SQLException {
        int matchId = Integer.parseInt(req.getParameter("match_id"));
        Integer score1 = parseIntOrNull(req.getParameter("team1_score"));
        Integer score2 = parseIntOrNull(req.getParameter("team2_score"));
        matchDAO.updateResult(matchId, score1, score2);
    }

    private void handleDelete(HttpServletRequest req) throws SQLException {
        int matchId = Integer.parseInt(req.getParameter("match_id"));
        matchDAO.delete(matchId);
    }

    private void redirectWithError(HttpServletRequest req, HttpServletResponse resp, String message)
            throws IOException {
        resp.sendRedirect(req.getContextPath() + "/matches?error=" + URLEncoder.encode(message, "UTF-8"));
    }

    private Integer parseIntOrNull(String value) {
        if (value == null || value.isBlank()) return null;
        return Integer.parseInt(value.trim());
    }
}
