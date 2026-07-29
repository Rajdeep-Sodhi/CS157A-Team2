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
import java.sql.ResultSet;
import java.sql.SQLException;

@WebServlet("/comment")
public class CommentServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        int matchId;
        try {
            matchId = Integer.parseInt(req.getParameter("matchId"));
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/matches.jsp?comment=invalid");
            return;
        }

        String content = req.getParameter("content");
        if (content == null || content.trim().isEmpty() || content.length() > 250) {
            resp.sendRedirect(req.getContextPath()
                + "/matches.jsp?comment=invalid#match-" + matchId);
            return;
        }

        String matchSql = "SELECT 1 FROM Matches WHERE match_id = ?";
        String commentSql =
            "INSERT INTO Comments " +
            "(user_id, match_id, content, upvote_count, is_flagged, created_at) " +
            "VALUES (?, ?, ?, 0, FALSE, CURRENT_TIMESTAMP)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement matchCheck = conn.prepareStatement(matchSql)) {

            matchCheck.setInt(1, matchId);
            try (ResultSet rs = matchCheck.executeQuery()) {
                if (!rs.next()) {
                    resp.sendRedirect(req.getContextPath() + "/matches.jsp?comment=invalid");
                    return;
                }
            }

            try (PreparedStatement insert = conn.prepareStatement(commentSql)) {
                insert.setInt(1, (Integer) session.getAttribute("userId"));
                insert.setInt(2, matchId);
                insert.setString(3, content.trim());
                insert.executeUpdate();
            }

            resp.sendRedirect(req.getContextPath()
                + "/matches.jsp?comment=saved#match-" + matchId);
        } catch (SQLException e) {
            req.setAttribute("commentError", "Unable to post comment: " + e.getMessage());
            req.getRequestDispatcher("/matches.jsp").forward(req, resp);
        }
    }
}
