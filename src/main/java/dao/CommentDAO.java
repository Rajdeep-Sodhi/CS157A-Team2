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
            "       reporter.name AS reporter_name " +
            "FROM Comments c " +
            "JOIN Users u ON c.user_id = u.user_id " +
            "LEFT JOIN Users reporter ON c.flagged_by_user_id = reporter.user_id " +
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
}
