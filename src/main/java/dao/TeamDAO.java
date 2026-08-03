package dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * TeamDAO.java
 * FR: "Team and Players Management" (the team half).
 *
 * In the current schema a "Team" IS a Countries row - group_letter
 * and coach_name live directly on Countries, and country_name is
 * the primary key (there is no separate Teams table). Because
 * country_name is also the foreign key target from Players,
 * Venues, Matches, MatchResults, GroupStandings, etc., renaming a
 * country is not supported here (it would require cascading that
 * rename across every dependent table); the edit form only updates
 * fifa_ranking, confederation, group_letter, and coach_name.
 */
public class TeamDAO {

    public List<Map<String, Object>> listAll() throws SQLException {
        String sql =
            "SELECT c.country_name, c.fifa_ranking, c.confederation, c.coach_name, c.group_letter, " +
            "       (SELECT COUNT(*) FROM Players p WHERE p.country_name = c.country_name) AS player_count " +
            "FROM Countries c " +
            "ORDER BY c.group_letter IS NULL, c.group_letter ASC, c.country_name ASC";
        List<Map<String, Object>> teams = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) {
                teams.add(rowToMap(rs));
            }
        }
        return teams;
    }

    public Map<String, Object> getById(String countryName) throws SQLException {
        String sql =
            "SELECT c.country_name, c.fifa_ranking, c.confederation, c.coach_name, c.group_letter, " +
            "       (SELECT COUNT(*) FROM Players p WHERE p.country_name = c.country_name) AS player_count " +
            "FROM Countries c WHERE c.country_name = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, countryName);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rowToMap(rs) : null;
            }
        }
    }

    /** Every team already assigned to a group, used when creating/editing a match. */
    public List<Map<String, Object>> listGroupAssignedTeams() throws SQLException {
        String sql =
            "SELECT country_name, group_letter FROM Countries " +
            "WHERE group_letter IS NOT NULL " +
            "ORDER BY group_letter ASC, country_name ASC";
        List<Map<String, Object>> teams = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) {
                Map<String, Object> row = new LinkedHashMap<>();
                row.put("country_name", rs.getString("country_name"));
                row.put("group_letter", rs.getString("group_letter"));
                teams.add(row);
            }
        }
        return teams;
    }

    private Map<String, Object> rowToMap(ResultSet rs) throws SQLException {
        Map<String, Object> row = new LinkedHashMap<>();
        row.put("country_name", rs.getString("country_name"));
        row.put("fifa_ranking", rs.getObject("fifa_ranking"));
        row.put("confederation", rs.getString("confederation"));
        row.put("coach_name", rs.getString("coach_name"));
        row.put("group_letter", rs.getString("group_letter"));
        row.put("player_count", rs.getInt("player_count"));
        return row;
    }

    public void create(String countryName, Integer fifaRanking, String confederation,
                        String groupLetter, String coachName) throws SQLException {
        String sql =
            "INSERT INTO Countries (country_name, fifa_ranking, confederation, coach_name, group_letter) " +
            "VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, countryName);
            setNullableInt(ps, 2, fifaRanking);
            ps.setString(3, confederation);
            ps.setString(4, coachName);
            ps.setString(5, (groupLetter == null || groupLetter.isBlank()) ? null : groupLetter);
            ps.executeUpdate();
        }
    }

    /** country_name is the lookup key only - it is never modified by an edit. */
    public void update(String countryName, Integer fifaRanking, String confederation,
                        String groupLetter, String coachName) throws SQLException {
        String sql =
            "UPDATE Countries SET fifa_ranking = ?, confederation = ?, coach_name = ?, group_letter = ? " +
            "WHERE country_name = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            setNullableInt(ps, 1, fifaRanking);
            ps.setString(2, confederation);
            ps.setString(3, coachName);
            ps.setString(4, (groupLetter == null || groupLetter.isBlank()) ? null : groupLetter);
            ps.setString(5, countryName);
            ps.executeUpdate();
        }
    }

    /**
     * Deletes a team (Countries row) AND its players outright - not
     * unassigned, actually removed, along with their PlayerStats and
     * MatchEvents records (both have NOT NULL foreign keys to
     * player_id, so those must go first or the delete fails).
     * Fails with a friendly message if the team still has matches
     * scheduled, or is set as a venue's host country - both must be
     * resolved first.
     */
    public void delete(String countryName) throws SQLException, IllegalStateException {
        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                try (PreparedStatement check = conn.prepareStatement(
                        "SELECT COUNT(*) FROM Matches WHERE team1_country_name = ? OR team2_country_name = ?")) {
                    check.setString(1, countryName);
                    check.setString(2, countryName);
                    try (ResultSet rs = check.executeQuery()) {
                        rs.next();
                        if (rs.getInt(1) > 0) {
                            throw new IllegalStateException(
                                "This team has matches scheduled. Remove those matches before deleting the team.");
                        }
                    }
                }

                try (PreparedStatement checkVenue = conn.prepareStatement(
                        "SELECT COUNT(*) FROM Venues WHERE host_country = ?")) {
                    checkVenue.setString(1, countryName);
                    try (ResultSet rs = checkVenue.executeQuery()) {
                        rs.next();
                        if (rs.getInt(1) > 0) {
                            throw new IllegalStateException(
                                "This country is set as the host country for one or more venues. Update those venues first.");
                        }
                    }
                }

                List<Integer> playerIds = new ArrayList<>();
                try (PreparedStatement getPlayers = conn.prepareStatement(
                        "SELECT player_id FROM Players WHERE country_name = ?")) {
                    getPlayers.setString(1, countryName);
                    try (ResultSet rs = getPlayers.executeQuery()) {
                        while (rs.next()) playerIds.add(rs.getInt("player_id"));
                    }
                }

                for (int playerId : playerIds) {
                    try (PreparedStatement delStats = conn.prepareStatement(
                            "DELETE FROM PlayerStats WHERE player_id = ?")) {
                        delStats.setInt(1, playerId);
                        delStats.executeUpdate();
                    }
                    try (PreparedStatement delEvents = conn.prepareStatement(
                            "DELETE FROM MatchEvents WHERE player_id = ?")) {
                        delEvents.setInt(1, playerId);
                        delEvents.executeUpdate();
                    }
                }

                try (PreparedStatement deletePlayers = conn.prepareStatement(
                        "DELETE FROM Players WHERE country_name = ?")) {
                    deletePlayers.setString(1, countryName);
                    deletePlayers.executeUpdate();
                }

                try (PreparedStatement deleteStandings = conn.prepareStatement(
                        "DELETE FROM GroupStandings WHERE country_name = ?")) {
                    deleteStandings.setString(1, countryName);
                    deleteStandings.executeUpdate();
                }

                try (PreparedStatement deleteTeam = conn.prepareStatement(
                        "DELETE FROM Countries WHERE country_name = ?")) {
                    deleteTeam.setString(1, countryName);
                    deleteTeam.executeUpdate();
                }

                conn.commit();
            } catch (SQLException | IllegalStateException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    private void setNullableInt(PreparedStatement ps, int index, Integer value) throws SQLException {
        if (value == null) {
            ps.setNull(index, Types.INTEGER);
        } else {
            ps.setInt(index, value);
        }
    }
}