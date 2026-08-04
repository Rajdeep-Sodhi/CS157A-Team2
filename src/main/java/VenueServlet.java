import dao.TeamDAO;
import dao.VenueDAO;
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
 * VenueServlet.java
 * FR: "Stadium Management" - list/view for everyone, add/edit/delete for admins.
 */
@WebServlet("/venues")
public class VenueServlet extends HttpServlet {

    private final VenueDAO venueDAO = new VenueDAO();
    private final TeamDAO teamDAO = new TeamDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            List<Map<String, Object>> venues = venueDAO.listAll();
            req.setAttribute("venues", venues);
            // host_country has a foreign key to Countries.country_name, so
            // the form needs to offer a dropdown of real values rather than
            // a free-text field - any typo there throws a FK violation.
            req.setAttribute("countries", teamDAO.listAll());
        } catch (SQLException e) {
            req.setAttribute("dbError", e.getMessage());
        }
        req.getRequestDispatcher("/venues.jsp").forward(req, resp);
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
            resp.sendRedirect(req.getContextPath() + "/venues");
        } catch (SQLException e) {
            showError(req, resp, "Database error: " + e.getMessage());
        } catch (IllegalStateException e) {
            showError(req, resp, e.getMessage());
        } catch (NumberFormatException e) {
            showError(req, resp, "Capacity must be a whole number.");
        }
    }

    private void handleAdd(HttpServletRequest req) throws SQLException {
        String stadiumName = req.getParameter("stadium_name");
        String city = req.getParameter("city");
        String hostCountry = req.getParameter("host_country");
        Integer capacity = parseIntOrNull(req.getParameter("capacity"));
        venueDAO.create(stadiumName, city, hostCountry, capacity);
    }

    private void handleEdit(HttpServletRequest req) throws SQLException {
        int venueId = Integer.parseInt(req.getParameter("venue_id"));
        String stadiumName = req.getParameter("stadium_name");
        String city = req.getParameter("city");
        String hostCountry = req.getParameter("host_country");
        Integer capacity = parseIntOrNull(req.getParameter("capacity"));
        venueDAO.update(venueId, stadiumName, city, hostCountry, capacity);
    }

    private void handleDelete(HttpServletRequest req) throws SQLException {
        int venueId = Integer.parseInt(req.getParameter("venue_id"));
        venueDAO.delete(venueId);
    }

    private void showError(HttpServletRequest req, HttpServletResponse resp, String message)
            throws ServletException, IOException {
        req.setAttribute("dbError", message);
        try {
            req.setAttribute("venues", venueDAO.listAll());
            req.setAttribute("countries", teamDAO.listAll());
        } catch (SQLException ignored) {
        }
        req.getRequestDispatcher("/venues.jsp").forward(req, resp);
    }

    private Integer parseIntOrNull(String value) {
        if (value == null || value.isBlank()) return null;
        return Integer.parseInt(value.trim());
    }
}