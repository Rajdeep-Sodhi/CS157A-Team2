import dao.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

@WebServlet("/flag-comment")
public class FlagCommentServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
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
}
