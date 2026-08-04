import dao.DBConnection;
import dao.UserDAO;
import util.AuthHelper;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

@WebServlet("/flag-comment")
public class FlagCommentServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");

        // FR: "review flagged comments, select an action - dismiss/delete/
        // ban user" - these two are admin-only. Delete is handled by
        // DeleteCommentServlet; this file owns flag-state changes since
        // dismiss is the direct inverse of the flag action below it.
        if ("dismiss".equals(action)) {
            handleDismiss(req, resp);
            return;
        }
        if ("ban".equals(action)) {
            handleBan(req, resp);
            return;
        }

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        int commentId;
        int matchId;
        try {
            commentId = Integer.parseInt(req.getParameter("commentId"));
            matchId = Integer.parseInt(req.getParameter("matchId"));
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/matches?flag=invalid");
            return;
        }

        String reason = req.getParameter("reason");
        if (reason == null || reason.trim().isEmpty() || reason.trim().length() > 250) {
            resp.sendRedirect(req.getContextPath() + "/matches?flag=invalid#match-" + matchId);
            return;
        }

        String sql =
            "UPDATE Comments SET is_flagged = TRUE, flagged_by_user_id = ?, " +
            "flag_reason = ?, flagged_at = CURRENT_TIMESTAMP " +
            "WHERE comment_id = ? AND match_id = ? AND user_id <> ? AND is_flagged = FALSE";
        int userId = (Integer) session.getAttribute("userId");
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, reason.trim());
            ps.setInt(3, commentId);
            ps.setInt(4, matchId);
            ps.setInt(5, userId);
            int updated = ps.executeUpdate();
            String status = updated == 1 ? "submitted" : "unavailable";
            resp.sendRedirect(req.getContextPath() + "/matches?flag=" + status + "#match-" + matchId);
        } catch (SQLException e) {
            req.setAttribute("dbError", "Unable to flag comment: " + e.getMessage());
            req.getRequestDispatcher("/matches").forward(req, resp);
        }
    }

    /** Clears a comment's flag without deleting it - the flag was reviewed and found unwarranted. */
    private void handleDismiss(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        if (!AuthHelper.requireAdmin(req, resp)) return;

        int commentId;
        int matchId;
        try {
            commentId = Integer.parseInt(req.getParameter("commentId"));
            matchId = Integer.parseInt(req.getParameter("matchId"));
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/matches?flag=invalid");
            return;
        }

        String sql =
            "UPDATE Comments SET is_flagged = FALSE, flagged_by_user_id = NULL, " +
            "flag_reason = NULL, flagged_at = NULL WHERE comment_id = ? AND match_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, commentId);
            ps.setInt(2, matchId);
            ps.executeUpdate();
            resp.sendRedirect(req.getContextPath() + "/matches?flag=dismissed#match-" + matchId);
        } catch (SQLException e) {
            resp.sendRedirect(req.getContextPath() + "/matches?error="
                + URLEncoder.encode("Unable to dismiss flag: " + e.getMessage(), StandardCharsets.UTF_8)
                + "#match-" + matchId);
        }
    }

    /** Bans the comment's author directly from the flag-review panel. */
    private void handleBan(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        if (!AuthHelper.requireAdmin(req, resp)) return;

        int matchId;
        int authorUserId;
        try {
            matchId = Integer.parseInt(req.getParameter("matchId"));
            authorUserId = Integer.parseInt(req.getParameter("authorUserId"));
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/matches?flag=invalid");
            return;
        }

        try {
            userDAO.setBanned(authorUserId, true);
            resp.sendRedirect(req.getContextPath() + "/matches?flag=banned#match-" + matchId);
        } catch (IllegalStateException e) {
            resp.sendRedirect(req.getContextPath() + "/matches?error="
                + URLEncoder.encode(e.getMessage(), StandardCharsets.UTF_8) + "#match-" + matchId);
        } catch (SQLException e) {
            resp.sendRedirect(req.getContextPath() + "/matches?error="
                + URLEncoder.encode("Unable to ban user: " + e.getMessage(), StandardCharsets.UTF_8)
                + "#match-" + matchId);
        }
    }
}