import dao.DBConnection;
import util.AuthHelper;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

public class DeleteCommentServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!AuthHelper.requireAdmin(req, resp)) return;

        int commentId;
        int matchId;
        try {
            commentId = Integer.parseInt(req.getParameter("commentId"));
            matchId = Integer.parseInt(req.getParameter("matchId"));
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/matches?comment=delete-invalid");
            return;
        }

        String sql = "DELETE FROM Comments WHERE comment_id = ? AND match_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, commentId);
            ps.setInt(2, matchId);
            int deleted = ps.executeUpdate();
            String status = deleted == 1 ? "deleted" : "delete-invalid";
            resp.sendRedirect(req.getContextPath() + "/matches?comment=" + status + "#match-" + matchId);
        } catch (SQLException e) {
            req.setAttribute("dbError", "Unable to delete comment: " + e.getMessage());
            req.getRequestDispatcher("/matches").forward(req, resp);
        }
    }
}
