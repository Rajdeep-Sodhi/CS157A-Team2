import dao.DBConnection;
import util.AuthHelper;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

@WebServlet("/delete-comment")
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

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                try (PreparedStatement delVotes = conn.prepareStatement(
                        "DELETE FROM CommentVotes WHERE comment_id = ?")) {
                    delVotes.setInt(1, commentId);
                    delVotes.executeUpdate();
                }

                int deleted;
                try (PreparedStatement ps = conn.prepareStatement(
                        "DELETE FROM Comments WHERE comment_id = ? AND match_id = ?")) {
                    ps.setInt(1, commentId);
                    ps.setInt(2, matchId);
                    deleted = ps.executeUpdate();
                }

                conn.commit();
                String status = deleted == 1 ? "deleted" : "delete-invalid";
                resp.sendRedirect(req.getContextPath() + "/matches?comment=" + status + "#match-" + matchId);
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            req.setAttribute("dbError", "Unable to delete comment: " + e.getMessage());
            req.getRequestDispatcher("/matches").forward(req, resp);
        }
    }
}