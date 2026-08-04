import dao.CommentDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;

/**
 * CommentVoteServlet.java
 * FR: "Users can upvote comments, upvote count displayed" (the
 * team also added downvoting). One vote per user per comment -
 * clicking the same direction again removes it, clicking the
 * other direction switches it. See CommentDAO.castVote().
 */
@WebServlet("/comment-vote")
public class CommentVoteServlet extends HttpServlet {

    private final CommentDAO commentDAO = new CommentDAO();

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
        int voteValue;
        try {
            commentId = Integer.parseInt(req.getParameter("comment_id"));
            matchId = Integer.parseInt(req.getParameter("match_id"));
            String direction = req.getParameter("direction");
            if ("up".equals(direction)) {
                voteValue = 1;
            } else if ("down".equals(direction)) {
                voteValue = -1;
            } else {
                throw new NumberFormatException("Unknown direction");
            }
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/matches");
            return;
        }

        int userId = (Integer) session.getAttribute("userId");

        try {
            commentDAO.castVote(commentId, userId, voteValue);
            resp.sendRedirect(req.getContextPath() + "/matches#match-" + matchId);
        } catch (SQLException e) {
            resp.sendRedirect(req.getContextPath() + "/matches?error="
                + URLEncoder.encode("Unable to record vote: " + e.getMessage(), StandardCharsets.UTF_8)
                + "#match-" + matchId);
        }
    }
}