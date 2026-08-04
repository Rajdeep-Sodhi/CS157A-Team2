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

@WebServlet("/predict")
public class PredictionServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            // Was "/login.jsp" - now goes through LoginServlet ("/login").
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        int matchId;
        int team1Score;
        int team2Score;
        try {
            matchId = Integer.parseInt(req.getParameter("matchId"));
            team1Score = Integer.parseInt(req.getParameter("team1Score"));
            team2Score = Integer.parseInt(req.getParameter("team2Score"));
            if (team1Score < 0 || team1Score > 99 || team2Score < 0 || team2Score > 99) {
                throw new NumberFormatException();
            }
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/predictions.jsp?status=invalid");
            return;
        }

        int userId = (Integer) session.getAttribute("userId");

        try (Connection conn = DBConnection.getConnection()) {
            // *** TEMPORARY TEST BUILD ***
            // Kickoff-time locking enabled (AND m.match_date > NOW()) to
            // verify the feature actually works. Revert to the version
            // without this line (see PredictionServlet.java's comment
            // there) once testing confirms it - permanently enabling this
            // locks every seeded match, since they're all dated in the past.
            String upcomingSql =
                "SELECT 1 FROM Matches m " +
                "LEFT JOIN MatchResults mr ON mr.match_id = m.match_id " +
                "WHERE m.match_id = ? AND mr.result_id IS NULL AND m.match_date > NOW()";
            try (PreparedStatement check = conn.prepareStatement(upcomingSql)) {
                check.setInt(1, matchId);
                try (ResultSet rs = check.executeQuery()) {
                    if (!rs.next()) {
                        resp.sendRedirect(req.getContextPath() + "/predictions.jsp?status=closed");
                        return;
                    }
                }
            }

            String updateSql =
                "UPDATE Predictions SET predicted_team1_score = ?, " +
                "predicted_team2_score = ? WHERE user_id = ? AND match_id = ?";
            int updated;
            try (PreparedStatement update = conn.prepareStatement(updateSql)) {
                update.setInt(1, team1Score);
                update.setInt(2, team2Score);
                update.setInt(3, userId);
                update.setInt(4, matchId);
                updated = update.executeUpdate();
            }

            if (updated == 0) {
                String insertSql =
                    "INSERT INTO Predictions " +
                    "(user_id, match_id, predicted_team1_score, predicted_team2_score) " +
                    "VALUES (?, ?, ?, ?)";
                try (PreparedStatement insert = conn.prepareStatement(insertSql)) {
                    insert.setInt(1, userId);
                    insert.setInt(2, matchId);
                    insert.setInt(3, team1Score);
                    insert.setInt(4, team2Score);
                    insert.executeUpdate();
                }
            }

            resp.sendRedirect(req.getContextPath() + "/predictions.jsp?status=saved#match-" + matchId);
        } catch (SQLException e) {
            req.setAttribute("error", "Unable to save prediction: " + e.getMessage());
            req.getRequestDispatcher("/predictions.jsp").forward(req, resp);
        }
    }
}