import dao.UserDAO;
import model.User;
import util.AuthHelper;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;

@WebServlet("/users")
public class UsersServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!AuthHelper.requireAdmin(req, resp)) return;

        String errorParam = req.getParameter("error");
        if (errorParam != null && !errorParam.isBlank()) {
            req.setAttribute("dbError", errorParam);
        }

        try {
            List<User> users = userDAO.listAll();
            req.setAttribute("users", users);
        } catch (SQLException e) {
            req.setAttribute("dbError", e.getMessage());
        }

        req.getRequestDispatcher("/users.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!AuthHelper.requireAdmin(req, resp)) return;

        int userId;
        try {
            userId = Integer.parseInt(req.getParameter("user_id"));
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/users?error=Please+select+a+valid+user.");
            return;
        }

        String action = req.getParameter("action");
        try {
            User targetUser = userDAO.getById(userId);
            if (targetUser == null) {
                throw new IllegalStateException("That user no longer exists.");
            }

            switch (action == null ? "" : action) {
                case "promote":
                    if (targetUser.isAdmin()) {
                        throw new IllegalStateException("This user is already an admin.");
                    }
                    userDAO.setRole(userId, "admin");
                    break;
                case "demote":
                    if (!targetUser.isAdmin()) {
                        throw new IllegalStateException("This user is not an admin.");
                    }
                    User self = (User) req.getSession().getAttribute("authUser");
                    if (self != null && self.getUserId() == userId) {
                        throw new IllegalStateException("You can't remove your own admin access.");
                    }
                    if (userDAO.countAdmins() <= 2) {
                        throw new IllegalStateException(
                            "There must be at least 2 admins at all times. Promote another user to admin first.");
                    }
                    userDAO.setRole(userId, "fan");
                    break;
                case "delete":
                    if (targetUser.isAdmin()) {
                        throw new IllegalStateException("Admin accounts cannot be deleted.");
                    }
                    userDAO.deleteUser(userId);
                    break;
                case "ban":
                    userDAO.setBanned(userId, true);
                    break;
                case "unban":
                    userDAO.setBanned(userId, false);
                    break;
                default:
                    throw new IllegalStateException("Unknown action.");
            }
            resp.sendRedirect(req.getContextPath() + "/users");
        } catch (IllegalStateException e) {
            resp.sendRedirect(req.getContextPath() + "/users?error=" + encode(e.getMessage()));
        } catch (SQLException e) {
            resp.sendRedirect(req.getContextPath() + "/users?error=" + encode("Database error: " + e.getMessage()));
        }
    }

    private String encode(String message) {
        return URLEncoder.encode(message, StandardCharsets.UTF_8);
    }
}