import dao.PlayerDAO;
import dao.TeamDAO;
import util.AuthHelper;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;

/**
 * TeamServlet.java
 * FR: "Team and Players Management" - list/view teams for everyone,
 * add/edit/delete restricted to admins.
 *
 * A "team" is identified by its country name (Countries.country_name
 * is the primary key in the current schema - there is no separate
 * team_id), so it's passed around and URL-encoded as a string.
 */
@WebServlet("/teams")
public class TeamServlet extends HttpServlet {

    private final TeamDAO teamDAO = new TeamDAO();
    private final PlayerDAO playerDAO = new PlayerDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String errorParam = req.getParameter("error");
        if (errorParam != null && !errorParam.isBlank()) {
            req.setAttribute("dbError", errorParam);
        }

        try {
            List<Map<String, Object>> teams = teamDAO.listAll();
            req.setAttribute("teams", teams);

            String country = req.getParameter("country");
            if (country != null && !country.isBlank()) {
                Map<String, Object> selectedTeam = teamDAO.getById(country);
                req.setAttribute("selectedTeam", selectedTeam);
                if (selectedTeam != null) {
                    req.setAttribute("roster", playerDAO.listByTeam(country));
                }
            }

            if ("unassigned".equals(req.getParameter("view"))) {
                req.setAttribute("unassignedPlayers", playerDAO.listUnassigned());
            }
        } catch (SQLException e) {
            req.setAttribute("dbError", e.getMessage());
        }

        req.getRequestDispatcher("/teams.jsp").forward(req, resp);
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
                case "delete":
                    handleDelete(req);
                    break;
                default:
                    throw new IllegalStateException("Unknown action.");
            }
            resp.sendRedirect(req.getContextPath() + "/teams");
        } catch (SQLException e) {
            showError(req, resp, "Database error: " + e.getMessage());
        } catch (IllegalStateException e) {
            showError(req, resp, e.getMessage());
        } catch (NumberFormatException e) {
            showError(req, resp, "Please enter a valid number for the ranking field.");
        }
    }

    private void showError(HttpServletRequest req, HttpServletResponse resp, String message)
            throws ServletException, IOException {
        req.setAttribute("dbError", message);
        try {
            req.setAttribute("teams", teamDAO.listAll());
        } catch (SQLException ignored) {
            // best effort - teams list may just be empty if this also fails
        }
        req.getRequestDispatcher("/teams.jsp").forward(req, resp);
    }

    private void handleAdd(HttpServletRequest req) throws SQLException {
        String countryName = req.getParameter("country_name");
        Integer fifaRanking = parseIntOrNull(req.getParameter("fifa_ranking"));
        String confederation = req.getParameter("confederation");
        String groupLetter = req.getParameter("group_letter");
        String coachName = req.getParameter("coach_name");

        teamDAO.create(countryName, fifaRanking, confederation, groupLetter, coachName);
    }

    private void handleEdit(HttpServletRequest req) throws SQLException {
        String countryName = req.getParameter("country_name");
        Integer fifaRanking = parseIntOrNull(req.getParameter("fifa_ranking"));
        String confederation = req.getParameter("confederation");
        String groupLetter = req.getParameter("group_letter");
        String coachName = req.getParameter("coach_name");

        teamDAO.update(countryName, fifaRanking, confederation, groupLetter, coachName);
    }

    private void handleDelete(HttpServletRequest req) throws SQLException {
        String countryName = req.getParameter("country_name");
        teamDAO.delete(countryName);
    }

    private Integer parseIntOrNull(String value) {
        if (value == null || value.isBlank()) return null;
        return Integer.parseInt(value.trim());
    }
}
