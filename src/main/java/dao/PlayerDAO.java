package dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * PlayerDAO.java
 * FR: "Team and Players Management" (the player half).
 * Players link to a team via Players.country_name (the current
 * schema has no separate team_id).
 */
public class PlayerDAO {

    public List<Map<String, Object>> listByTeam(String countryName) throws SQLException {
        String sql =
            "SELECT player_id, country_name, name, position, jersey_number, date_of_birth " +
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

    /** Players whose team was deleted - shown on the roster page as "Not on a Team". */
    public List<Map<String, Object>> listUnassigned() throws SQLException {
        String sql =
            "SELECT player_id, country_name, name, position, jersey_number, date_of_birth " +
            "FROM Players WHERE country_name IS NULL ORDER BY name ASC";
        List<Map<String, Object>> players = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) players.add(rowToMap(rs));
        }
        return players;
    }

    public Map<String, Object> getById(int playerId) throws SQLException {
        String sql =
            "SELECT player_id, country_name, name, position, jersey_number, date_of_birth " +
            "FROM Players WHERE player_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, playerId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rowToMap(rs) : null;
            }
        }
    }

    private Map<String, Object> rowToMap(ResultSet rs) throws SQLException {
        Map<String, Object> row = new LinkedHashMap<>();
        row.put("player_id", rs.getInt("player_id"));
        row.put("country_name", rs.getString("country_name")); // may be null
        row.put("name", rs.getString("name"));
        row.put("position", rs.getString("position"));
        row.put("jersey_number", rs.getObject("jersey_number"));
        Date dob = rs.getDate("date_of_birth");
        row.put("date_of_birth", dob == null ? null : dob.toString());
        return row;
    }

    /** countryName may be null only when re-creating a player that's intentionally unassigned. */
    public int create(String countryName, String name, String position,
                       Integer jerseyNumber, String dateOfBirth) throws SQLException {
        String sql =
            "INSERT INTO Players (country_name, name, position, jersey_number, date_of_birth) " +
            "VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, countryName);
            ps.setString(2, name);
            ps.setString(3, position);
            setNullableInt(ps, 4, jerseyNumber);
            setNullableDate(ps, 5, dateOfBirth);
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                keys.next();
                return keys.getInt(1);
            }
        }
    }

    public void update(int playerId, String countryName, String name, String position,
                        Integer jerseyNumber, String dateOfBirth) throws SQLException {
        String sql =
            "UPDATE Players SET country_name = ?, name = ?, position = ?, jersey_number = ?, date_of_birth = ? " +
            "WHERE player_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, countryName);
            ps.setString(2, name);
            ps.setString(3, position);
            setNullableInt(ps, 4, jerseyNumber);
            setNullableDate(ps, 5, dateOfBirth);
            ps.setInt(6, playerId);
            ps.executeUpdate();
        }
    }

    public void delete(int playerId) throws SQLException {
        // PlayerStats/MatchEvents rows for this player are left as-is by design
        // (historical stat/event records); only the roster entry is removed.
        String sql = "DELETE FROM Players WHERE player_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, playerId);
            ps.executeUpdate();
        }
    }

    private void setNullableInt(PreparedStatement ps, int index, Integer value) throws SQLException {
        if (value == null) ps.setNull(index, Types.INTEGER);
        else ps.setInt(index, value);
    }

    private void setNullableDate(PreparedStatement ps, int index, String isoDate) throws SQLException {
        if (isoDate == null || isoDate.isBlank()) ps.setNull(index, Types.DATE);
        else ps.setDate(index, Date.valueOf(isoDate));
    }
}
