package dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * PlayerDAO.java
 * FR: "Team and Players Management" (the player half).
 *
 * Players is a weak entity: jersey_number is only unique WITHIN a
 * team (two countries can both have a #10), so a player is
 * identified by (country_name, jersey_number) together, not by a
 * standalone player_id. country_name can never be null.
 */
public class PlayerDAO {

    public List<Map<String, Object>> listByTeam(String countryName) throws SQLException {
        String sql =
            "SELECT country_name, jersey_number, name, position, date_of_birth " +
            "FROM Players WHERE country_name = ? ORDER BY name ASC";
        List<Map<String, Object>> players = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, countryName);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) players.add(rowToMap(rs));
            }
        }
        return players;
    }

    public Map<String, Object> getById(String countryName, int jerseyNumber) throws SQLException {
        String sql =
            "SELECT country_name, jersey_number, name, position, date_of_birth " +
            "FROM Players WHERE country_name = ? AND jersey_number = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, countryName);
            ps.setInt(2, jerseyNumber);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rowToMap(rs) : null;
            }
        }
    }

    private Map<String, Object> rowToMap(ResultSet rs) throws SQLException {
        Map<String, Object> row = new LinkedHashMap<>();
        row.put("country_name", rs.getString("country_name"));
        row.put("jersey_number", rs.getInt("jersey_number"));
        row.put("name", rs.getString("name"));
        row.put("position", rs.getString("position"));
        Date dob = rs.getDate("date_of_birth");
        row.put("date_of_birth", dob == null ? null : dob.toString());
        return row;
    }

    /** jerseyNumber is required now (part of the primary key) - not nullable. */
    public void create(String countryName, int jerseyNumber, String name, String position,
                        String dateOfBirth) throws SQLException {
        String sql =
            "INSERT INTO Players (country_name, jersey_number, name, position, date_of_birth) " +
            "VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, countryName);
            ps.setInt(2, jerseyNumber);
            ps.setString(3, name);
            ps.setString(4, position);
            setNullableDate(ps, 5, dateOfBirth);
            ps.executeUpdate();
        }
    }

    /**
     * oldCountryName/oldJerseyNumber identify which player to update (the
     * WHERE clause); the rest are the new values. Changing country_name
     * or jersey_number here is a primary-key update. if this player has
     * any PlayerStats/MatchEvents rows, the foreign key will reject it
     * (SQLException), same as trying to delete a referenced row.
     */
    public void update(String oldCountryName, int oldJerseyNumber, String newCountryName,
                        int newJerseyNumber, String name, String position,
                        String dateOfBirth) throws SQLException {
        String sql =
            "UPDATE Players SET country_name = ?, jersey_number = ?, name = ?, position = ?, date_of_birth = ? " +
            "WHERE country_name = ? AND jersey_number = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newCountryName);
            ps.setInt(2, newJerseyNumber);
            ps.setString(3, name);
            ps.setString(4, position);
            setNullableDate(ps, 5, dateOfBirth);
            ps.setString(6, oldCountryName);
            ps.setInt(7, oldJerseyNumber);
            ps.executeUpdate();
        }
    }

    public void delete(String countryName, int jerseyNumber) throws SQLException {
        // If this player has PlayerStats/MatchEvents rows, the foreign
        // key will reject this delete (SQLException) rather than
        // silently orphaning that history.
        String sql = "DELETE FROM Players WHERE country_name = ? AND jersey_number = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, countryName);
            ps.setInt(2, jerseyNumber);
            ps.executeUpdate();
        }
    }

    private void setNullableDate(PreparedStatement ps, int index, String isoDate) throws SQLException {
        if (isoDate == null || isoDate.isBlank()) ps.setNull(index, Types.DATE);
        else ps.setDate(index, Date.valueOf(isoDate));
    }
}