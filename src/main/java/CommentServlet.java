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
            // Was "/login.jsp" - now goes through LoginServlet ("/login")
            // for consistency with the rest of the app.
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        int matchId;
        try {
            matchId = Integer.parseInt(req.getParameter("matchId"));
        } catch (NumberFormatException e) {
            // Was "/matches.jsp" - that's the raw file, which depends entirely
            // on MatchServlet setting its request attributes. Hitting it
            // directly (bypassing the servlet) always showed an empty
            // "No matches scheduled yet" page, even with real data in the DB.
            resp.sendRedirect(req.getContextPath() + "/matches?comment=invalid");
            return;
        }

        String content = req.getParameter("content");
        if (content == null || content.trim().isEmpty() || content.length() > 250) {
            resp.sendRedirect(req.getContextPath()
                + "/matches?comment=invalid#match-" + matchId);
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
                    resp.sendRedirect(req.getContextPath() + "/matches?comment=invalid");
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
                + "/matches?comment=saved#match-" + matchId);
        } catch (SQLException e) {
            req.setAttribute("commentError", "Unable to post comment: " + e.getMessage());
            req.getRequestDispatcher("/matches").forward(req, resp);
        }
    }
}