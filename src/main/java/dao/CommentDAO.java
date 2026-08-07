package dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * CommentDAO.java
 * FR: "Commenting/Chatting" - fetches comments to display alongside
 * each match. Posting a new comment is handled by CommentServlet.
 */
public class CommentDAO {

    /**
     * Fetches comments for a batch of match IDs in one query
     * (avoids one query per match on the schedule page), grouped
     * by match_id, oldest first.
     */
    public Map<Integer, List<Map<String, Object>>> listByMatchIds(List<Integer> matchIds) throws SQLException {
        Map<Integer, List<Map<String, Object>>> result = new LinkedHashMap<>();
        if (matchIds == null || matchIds.isEmpty()) return result;

        StringBuilder placeholders = new StringBuilder();
        for (int i = 0; i < matchIds.size(); i++) {
            if (i > 0) placeholders.append(",");
            placeholders.append("?");
        }

        String sql =
            "SELECT c.comment_id, c.user_id, c.match_id, c.content, c.upvote_count, c.is_flagged, " +
            "       c.flag_reason, c.flagged_at, c.created_at, u.name AS commenter_name, " +
            "       (SELECT reporter.name FROM Users reporter WHERE reporter.user_id = c.flagged_by_user_id) AS reporter_name " +
            "FROM Comments c " +
            "JOIN Users u ON c.user_id = u.user_id " +
            "WHERE c.match_id IN (" + placeholders + ") " +
            "ORDER BY c.created_at ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            for (int i = 0; i < matchIds.size(); i++) {
                ps.setInt(i + 1, matchIds.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int matchId = rs.getInt("match_id");
                    Map<String, Object> row = new LinkedHashMap<>();
                    row.put("comment_id", rs.getInt("comment_id"));
                    row.put("user_id", rs.getInt("user_id"));
                    row.put("content", rs.getString("content"));
                    row.put("upvote_count", rs.getInt("upvote_count"));
                    row.put("is_flagged", rs.getBoolean("is_flagged"));
                    Timestamp ts = rs.getTimestamp("created_at");
                    row.put("created_at", ts == null ? null : ts.toString());
                    row.put("commenter_name", rs.getString("commenter_name"));
                    row.put("flag_reason", rs.getString("flag_reason"));
                    row.put("flagged_at", rs.getTimestamp("flagged_at"));
                    row.put("reporter_name", rs.getString("reporter_name"));
                    result.computeIfAbsent(matchId, k -> new ArrayList<>()).add(row);
                }
            }
        }
        return result;
    }

    /**
     * Casts, changes, or removes a user's vote on a comment, keeping
     * Comments.upvote_count in sync as a running net total.
     * Clicking the same direction again removes the vote (toggle off);
     * clicking the opposite direction switches it; voting fresh adds it.
     * Returns the comment's new net vote count.
     */
    public int castVote(int commentId, int userId, int voteValue) throws SQLException {
        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                Integer existingValue = null;
                try (PreparedStatement check = conn.prepareStatement(
                        "SELECT vote_value FROM CommentVotes WHERE comment_id = ? AND user_id = ?")) {
                    check.setInt(1, commentId);
                    check.setInt(2, userId);
                    try (ResultSet rs = check.executeQuery()) {
                        if (rs.next()) existingValue = rs.getInt("vote_value");
                    }
                }

                int delta;
                if (existingValue == null) {
                    try (PreparedStatement insert = conn.prepareStatement(
                            "INSERT INTO CommentVotes (comment_id, user_id, vote_value) VALUES (?, ?, ?)")) {
                        insert.setInt(1, commentId);
                        insert.setInt(2, userId);
                        insert.setInt(3, voteValue);
                        insert.executeUpdate();
                    }
                    delta = voteValue;
                } else if (existingValue == voteValue) {
                    try (PreparedStatement delete = conn.prepareStatement(
                            "DELETE FROM CommentVotes WHERE comment_id = ? AND user_id = ?")) {
                        delete.setInt(1, commentId);
                        delete.setInt(2, userId);
                        delete.executeUpdate();
                    }
                    delta = -voteValue;
                } else {
                    try (PreparedStatement update = conn.prepareStatement(
                            "UPDATE CommentVotes SET vote_value = ? WHERE comment_id = ? AND user_id = ?")) {
                        update.setInt(1, voteValue);
                        update.setInt(2, commentId);
                        update.setInt(3, userId);
                        update.executeUpdate();
                    }
                    delta = voteValue - existingValue;
                }

                try (PreparedStatement updateCount = conn.prepareStatement(
                        "UPDATE Comments SET upvote_count = upvote_count + ? WHERE comment_id = ?")) {
                    updateCount.setInt(1, delta);
                    updateCount.setInt(2, commentId);
                    updateCount.executeUpdate();
                }

                int newCount;
                try (PreparedStatement getCount = conn.prepareStatement(
                        "SELECT upvote_count FROM Comments WHERE comment_id = ?")) {
                    getCount.setInt(1, commentId);
                    try (ResultSet rs = getCount.executeQuery()) {
                        newCount = rs.next() ? rs.getInt("upvote_count") : 0;
                    }
                }

                conn.commit();
                return newCount;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    /** Batch fetch of one user's votes across a set of comments, so the page can show their current vote state. */
    public Map<Integer, Integer> getUserVotes(int userId, List<Integer> commentIds) throws SQLException {
        Map<Integer, Integer> result = new LinkedHashMap<>();
        if (commentIds == null || commentIds.isEmpty()) return result;

        StringBuilder placeholders = new StringBuilder();
        for (int i = 0; i < commentIds.size(); i++) {
            if (i > 0) placeholders.append(",");
            placeholders.append("?");
        }

        String sql = "SELECT comment_id, vote_value FROM CommentVotes " +
                     "WHERE user_id = ? AND comment_id IN (" + placeholders + ")";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            for (int i = 0; i < commentIds.size(); i++) {
                ps.setInt(i + 2, commentIds.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    result.put(rs.getInt("comment_id"), rs.getInt("vote_value"));
                }
            }
        }
        return result;
    }
}