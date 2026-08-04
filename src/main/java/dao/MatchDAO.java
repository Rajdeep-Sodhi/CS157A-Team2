package dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * MatchDAO.java
 * FR: "Matches Management"
 *
 * Current schema notes: Matches stores team1_country_name /
 * team2_country_name directly (no Teams table to join through),
 * and match scores live in MatchResults, not on Matches itself.
 */
public class MatchDAO {

    private static final String SCORE_SUBQUERY_T1 =
        "(SELECT mr.team1_score FROM MatchResults mr WHERE mr.match_id = m.match_id ORDER BY mr.result_id DESC LIMIT 1)";
    private static final String SCORE_SUBQUERY_T2 =
        "(SELECT mr.team2_score FROM MatchResults mr WHERE mr.match_id = m.match_id ORDER BY mr.result_id DESC LIMIT 1)";

    public List<Map<String, Object>> listAll() throws SQLException {
        String sql =
            "SELECT m.match_id, m.match_date, m.stage, " +
            "       m.team1_country_name, m.team2_country_name, " +
            "       v.venue_id, v.stadium_name, v.city, " +
            "       " + SCORE_SUBQUERY_T1 + " AS team1_score, " +
            "       " + SCORE_SUBQUERY_T2 + " AS team2_score " +
            "FROM Matches m " +
            "JOIN Venues v ON m.venue_id = v.venue_id " +
            "ORDER BY m.match_date ASC";
        List<Map<String, Object>> matches = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) matches.add(rowToMap(rs));
        }
        return matches;
    }

    public Map<String, Object> getById(int matchId) throws SQLException {
        String sql =
            "SELECT m.match_id, m.match_date, m.stage, " +
            "       m.team1_country_name, m.team2_country_name, " +
            "       v.venue_id, v.stadium_name, v.city, " +
            "       " + SCORE_SUBQUERY_T1 + " AS team1_score, " +
            "       " + SCORE_SUBQUERY_T2 + " AS team2_score " +
            "FROM Matches m " +
            "JOIN Venues v ON m.venue_id = v.venue_id " +
            "WHERE m.match_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, matchId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rowToMap(rs) : null;
            }
        }
    }

    private Map<String, Object> rowToMap(ResultSet rs) throws SQLException {
        Map<String, Object> row = new LinkedHashMap<>();
        row.put("match_id", rs.getInt("match_id"));
        Timestamp ts = rs.getTimestamp("match_date");
        row.put("match_date", ts == null ? null : ts.toString());
        row.put("stage", rs.getString("stage"));
        row.put("team1_score", rs.getObject("team1_score"));
        row.put("team2_score", rs.getObject("team2_score"));
        row.put("team1_country_name", rs.getString("team1_country_name"));
        row.put("team2_country_name", rs.getString("team2_country_name"));
        row.put("venue_id", rs.getInt("venue_id"));
        row.put("stadium_name", rs.getString("stadium_name"));
        row.put("city", rs.getString("city"));
        return row;
    }

    /**
     * Creates a new match. Enforces:
     *  - the two teams are different
     *  - both teams already belong to a group ("assigned to a group before the match begins")
     *  - no other match is booked at the same stadium/time
     */
    public int create(String team1Country, String team2Country, int venueId, String matchDateTime, String stage)
            throws SQLException, IllegalArgumentException {
        if (team1Country.equals(team2Country)) {
            throw new IllegalArgumentException("A team can't play itself - choose two different teams.");
        }
        try (Connection conn = DBConnection.getConnection()) {
            assertTeamsHaveGroups(conn, team1Country, team2Country);
            assertVenueFree(conn, venueId, matchDateTime, null);

            String sql =
                "INSERT INTO Matches (team1_country_name, team2_country_name, venue_id, match_date, stage) " +
                "VALUES (?, ?, ?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, team1Country);
                ps.setString(2, team2Country);
                ps.setInt(3, venueId);
                ps.setTimestamp(4, Timestamp.valueOf(matchDateTime.replace("T", " ") + ":00"));
                ps.setString(5, stage);
                ps.executeUpdate();
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    keys.next();
                    return keys.getInt(1);
                }
            }
        }
    }

    public void update(int matchId, String team1Country, String team2Country, int venueId,
                        String matchDateTime, String stage) throws SQLException, IllegalArgumentException {
        if (team1Country.equals(team2Country)) {
            throw new IllegalArgumentException("A team can't play itself - choose two different teams.");
        }
        try (Connection conn = DBConnection.getConnection()) {
            assertTeamsHaveGroups(conn, team1Country, team2Country);
            assertVenueFree(conn, venueId, matchDateTime, matchId);

            String sql =
                "UPDATE Matches SET team1_country_name = ?, team2_country_name = ?, venue_id = ?, " +
                "match_date = ?, stage = ? WHERE match_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, team1Country);
                ps.setString(2, team2Country);
                ps.setInt(3, venueId);
                ps.setTimestamp(4, Timestamp.valueOf(matchDateTime.replace("T", " ") + ":00"));
                ps.setString(5, stage);
                ps.setInt(6, matchId);
                ps.executeUpdate();
            }
        }
    }

    /** FR: "Match results are updated after the match ends." Upserts into MatchResults. */
    public void updateResult(int matchId, Integer team1Score, Integer team2Score) throws SQLException {
        try (Connection conn = DBConnection.getConnection()) {
            String team1Country = null, team2Country = null;
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT team1_country_name, team2_country_name FROM Matches WHERE match_id = ?")) {
                ps.setInt(1, matchId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        team1Country = rs.getString("team1_country_name");
                        team2Country = rs.getString("team2_country_name");
                    }
                }
            }

            String winner = null;
            if (team1Score != null && team2Score != null && team1Country != null) {
                if (team1Score > team2Score) winner = team1Country;
                else if (team2Score > team1Score) winner = team2Country;
                // else a draw - winner stays null
            }

            Integer existingResultId = null;
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT result_id FROM MatchResults WHERE match_id = ? ORDER BY result_id DESC LIMIT 1")) {
                ps.setInt(1, matchId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) existingResultId = rs.getInt("result_id");
                }
            }

            if (existingResultId != null) {
                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE MatchResults SET team1_score = ?, team2_score = ?, winner_country_name = ? " +
                        "WHERE result_id = ?")) {
                    setNullableInt(ps, 1, team1Score);
                    setNullableInt(ps, 2, team2Score);
                    ps.setString(3, winner);
                    ps.setInt(4, existingResultId);
                    ps.executeUpdate();
                }
            } else {
                try (PreparedStatement ps = conn.prepareStatement(
                        "INSERT INTO MatchResults (match_id, team1_score, team2_score, winner_country_name) " +
                        "VALUES (?, ?, ?, ?)")) {
                    ps.setInt(1, matchId);
                    setNullableInt(ps, 2, team1Score);
                    setNullableInt(ps, 3, team2Score);
                    ps.setString(4, winner);
                    ps.executeUpdate();
                }
            }

            // FR: "Standings update automatically after each match result is entered."
            // Recalculated from scratch (not incremented) so correcting a result
            // later doesn't double-count.
            if (team1Country != null) recalculateStandings(conn, team1Country);
            if (team2Country != null) recalculateStandings(conn, team2Country);
        }
    }

    /** Recomputes one team's full win/draw/loss/points record from every completed match they've played. */
    private void recalculateStandings(Connection conn, String countryName) throws SQLException {
        int wins = 0, draws = 0, losses = 0;
        String sql =
            "SELECT m.team1_country_name, m.team2_country_name, " +
            "       " + SCORE_SUBQUERY_T1 + " AS team1_score, " +
            "       " + SCORE_SUBQUERY_T2 + " AS team2_score " +
            "FROM Matches m " +
            "WHERE m.team1_country_name = ? OR m.team2_country_name = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, countryName);
            ps.setString(2, countryName);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Object s1Obj = rs.getObject("team1_score");
                    Object s2Obj = rs.getObject("team2_score");
                    if (s1Obj == null || s2Obj == null) continue; // not played yet
                    int s1 = ((Number) s1Obj).intValue();
                    int s2 = ((Number) s2Obj).intValue();
                    boolean isTeam1 = countryName.equals(rs.getString("team1_country_name"));
                    int ourScore = isTeam1 ? s1 : s2;
                    int theirScore = isTeam1 ? s2 : s1;
                    if (ourScore > theirScore) wins++;
                    else if (ourScore == theirScore) draws++;
                    else losses++;
                }
            }
        }
        int points = wins * 3 + draws;

        Integer existingStandingId = null;
        try (PreparedStatement check = conn.prepareStatement(
                "SELECT standing_id FROM GroupStandings WHERE country_name = ?")) {
            check.setString(1, countryName);
            try (ResultSet rs = check.executeQuery()) {
                if (rs.next()) existingStandingId = rs.getInt("standing_id");
            }
        }

        if (existingStandingId != null) {
            try (PreparedStatement update = conn.prepareStatement(
                    "UPDATE GroupStandings SET wins = ?, draws = ?, losses = ?, points = ? WHERE standing_id = ?")) {
                update.setInt(1, wins);
                update.setInt(2, draws);
                update.setInt(3, losses);
                update.setInt(4, points);
                update.setInt(5, existingStandingId);
                update.executeUpdate();
            }
        } else {
            try (PreparedStatement insert = conn.prepareStatement(
                    "INSERT INTO GroupStandings (country_name, wins, draws, losses, points) VALUES (?, ?, ?, ?, ?)")) {
                insert.setString(1, countryName);
                insert.setInt(2, wins);
                insert.setInt(3, draws);
                insert.setInt(4, losses);
                insert.setInt(5, points);
                insert.executeUpdate();
            }
        }
    }

    public void delete(int matchId) throws SQLException {
        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                // Clean up dependent rows first so the delete doesn't fail on a FK constraint.
                deleteFrom(conn, "MatchEvents", matchId);
                deleteFrom(conn, "MatchResults", matchId);
                deleteFrom(conn, "Predictions", matchId);
                deleteFrom(conn, "Comments", matchId);
                deleteFrom(conn, "SponsoredBy", matchId);
                deleteFrom(conn, "PlaysAsTeam1", matchId);
                deleteFrom(conn, "PlaysAsTeam2", matchId);
                deleteFrom(conn, "HostedAt", matchId);
                try (PreparedStatement ps = conn.prepareStatement("DELETE FROM Matches WHERE match_id = ?")) {
                    ps.setInt(1, matchId);
                    ps.executeUpdate();
                }
                conn.commit();
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    private void deleteFrom(Connection conn, String table, int matchId) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement("DELETE FROM " + table + " WHERE match_id = ?")) {
            ps.setInt(1, matchId);
            ps.executeUpdate();
        } catch (SQLException e) {
            // Table might not exist/apply in every deployment; ignore and continue.
        }
    }

    private void assertTeamsHaveGroups(Connection conn, String team1Country, String team2Country) throws SQLException {
        String sql = "SELECT country_name, group_letter FROM Countries WHERE country_name IN (?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, team1Country);
            ps.setString(2, team2Country);
            try (ResultSet rs = ps.executeQuery()) {
                int found = 0;
                while (rs.next()) {
                    found++;
                    if (rs.getString("group_letter") == null) {
                        throw new IllegalArgumentException(
                            "Every team must be assigned to a group before it can be scheduled for a match.");
                    }
                }
                if (found < 2) {
                    throw new IllegalArgumentException("One of the selected teams no longer exists.");
                }
            }
        }
    }

    /** FR: "Two matches can not be scheduled at the same stadium and time." */
    private void assertVenueFree(Connection conn, int venueId, String matchDateTime, Integer excludeMatchId)
            throws SQLException {
        String sql = "SELECT match_id FROM Matches WHERE venue_id = ? AND match_date = ?" +
                     (excludeMatchId != null ? " AND match_id <> ?" : "");
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, venueId);
            ps.setTimestamp(2, Timestamp.valueOf(matchDateTime.replace("T", " ") + ":00"));
            if (excludeMatchId != null) ps.setInt(3, excludeMatchId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    throw new IllegalArgumentException(
                        "That stadium already has a match scheduled at this exact date and time.");
                }
            }
        }
    }

    private void setNullableInt(PreparedStatement ps, int index, Integer value) throws SQLException {
        if (value == null) ps.setNull(index, Types.INTEGER);
        else ps.setInt(index, value);
    }
}