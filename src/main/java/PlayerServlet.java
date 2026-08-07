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
 *
 * Players is a weak entity, identified by (country_name, jersey_number)
 * together rather than a standalone player_id, jersey_number is only
 * unique w/in a team. Editing either of those fields is a primary-key
 * update, so the form submits both the OLD identity (which row to
 * change) and the new values.
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
        String jerseyParam = req.getParameter("jersey_number");
        if (jerseyParam == null || jerseyParam.isBlank()) {
            throw new IllegalStateException("Jersey number is required.");
        }
        int jerseyNumber = Integer.parseInt(jerseyParam.trim());
        String name = req.getParameter("name");
        String position = req.getParameter("position");
        String dob = req.getParameter("date_of_birth");

        playerDAO.create(countryName, jerseyNumber, name, position, dob);
    }

    private void handleEdit(HttpServletRequest req) throws SQLException {
        String oldCountryName = req.getParameter("old_country_name");
        int oldJerseyNumber = Integer.parseInt(req.getParameter("old_jersey_number"));

        String newCountryName = req.getParameter("country_name");
        if (newCountryName == null || newCountryName.isBlank()) {
            throw new IllegalStateException("Every player must belong to a team.");
        }
        String jerseyParam = req.getParameter("jersey_number");
        if (jerseyParam == null || jerseyParam.isBlank()) {
            throw new IllegalStateException("Jersey number is required.");
        }
        int newJerseyNumber = Integer.parseInt(jerseyParam.trim());
        String name = req.getParameter("name");
        String position = req.getParameter("position");
        String dob = req.getParameter("date_of_birth");

        playerDAO.update(oldCountryName, oldJerseyNumber, newCountryName, newJerseyNumber,
            name, position, dob);
    }

    private void handleDelete(HttpServletRequest req) throws SQLException {
        String countryName = req.getParameter("country_name");
        int jerseyNumber = Integer.parseInt(req.getParameter("jersey_number"));
        playerDAO.delete(countryName, jerseyNumber);
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
        return base;
    }

    private void forwardWithError(HttpServletRequest req, HttpServletResponse resp,
                                   String countryName, String message) throws IOException {
        String base = req.getContextPath() + "/teams";
        String qs = (countryName != null && !countryName.isBlank())
            ? "?country=" + URLEncoder.encode(countryName, "UTF-8") + "&error=" + URLEncoder.encode(message, "UTF-8")
            : "?error=" + URLEncoder.encode(message, "UTF-8");
        resp.sendRedirect(base + qs);
    }
}