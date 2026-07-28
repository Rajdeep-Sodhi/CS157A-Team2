import dao.PlayerDAO;
import util.AuthHelper;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.net.URLEncoder;
import java.sql.SQLException;

/**
 * PlayerServlet.java
 * FR: "Team and Players Management" - admin add/edit/delete for player rows.
 * Every player must belong to a team (enforced by requiring a country
 * on add), except players left over from a deleted team, which stay
 * unassigned.
 */
@WebServlet("/players")
public class PlayerServlet extends HttpServlet {

    private final PlayerDAO playerDAO = new PlayerDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!AuthHelper.requireAdmin(req, resp)) return;

        String action = req.getParameter("action");
        // Which team roster view to send the browser back to.
        String returnCountry = req.getParameter("return_country");

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
            resp.sendRedirect(buildRedirect(req, returnCountry));
        } catch (SQLException e) {
            forwardWithError(req, resp, returnCountry,
                "Database error: " + e.getMessage()
                    + " (if this player has recorded stats or match events, remove those first)");
        } catch (IllegalStateException e) {
            forwardWithError(req, resp, returnCountry, e.getMessage());
        } catch (NumberFormatException e) {
            forwardWithError(req, resp, returnCountry, "Please enter a valid jersey number.");
        }
    }

    private void handleAdd(HttpServletRequest req) throws SQLException {
        String countryName = req.getParameter("country_name");
        if (countryName == null || countryName.isBlank()) {
            throw new IllegalStateException("Every player must belong to a team.");
        }
        String name = req.getParameter("name");
        String position = req.getParameter("position");
        Integer jerseyNumber = parseIntOrNull(req.getParameter("jersey_number"));
        String dob = req.getParameter("date_of_birth");

        playerDAO.create(countryName, name, position, jerseyNumber, dob);
    }

    private void handleEdit(HttpServletRequest req) throws SQLException {
        int playerId = Integer.parseInt(req.getParameter("player_id"));
        String countryName = req.getParameter("country_name");
        String name = req.getParameter("name");
        String position = req.getParameter("position");
        Integer jerseyNumber = parseIntOrNull(req.getParameter("jersey_number"));
        String dob = req.getParameter("date_of_birth");

        playerDAO.update(playerId, countryName, name, position, jerseyNumber, dob);
    }

    private void handleDelete(HttpServletRequest req) throws SQLException {
        int playerId = Integer.parseInt(req.getParameter("player_id"));
        playerDAO.delete(playerId);
    }

    private String buildRedirect(HttpServletRequest req, String countryName) {
        String base = req.getContextPath() + "/teams";
        if (countryName != null && !countryName.isBlank()) {
            try {
                return base + "?country=" + URLEncoder.encode(countryName, "UTF-8");
            } catch (Exception e) {
                return base;
            }
        }
        return base + "?view=unassigned";
    }

    private void forwardWithError(HttpServletRequest req, HttpServletResponse resp,
                                   String countryName, String message) throws IOException {
        String base = req.getContextPath() + "/teams";
        String qs = (countryName != null && !countryName.isBlank())
            ? "?country=" + URLEncoder.encode(countryName, "UTF-8")
            : "?view=unassigned";
        resp.sendRedirect(base + qs + "&error=" + URLEncoder.encode(message, "UTF-8"));
    }

    private Integer parseIntOrNull(String value) {
        if (value == null || value.isBlank()) return null;
        return Integer.parseInt(value.trim());
    }
}
