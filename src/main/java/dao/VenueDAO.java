package dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * VenueDAO.java
 * FR: "Stadium Management"
 */
public class VenueDAO {

    public List<Map<String, Object>> listAll() throws SQLException {
        String sql =
            "SELECT v.venue_id, v.stadium_name, v.city, v.host_country, v.capacity, " +
            "       (SELECT COUNT(*) FROM Matches m WHERE m.venue_id = v.venue_id) AS match_count " +
            "FROM Venues v ORDER BY v.stadium_name ASC";
        List<Map<String, Object>> venues = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) venues.add(rowToMap(rs));
        }
        return venues;
    }

    public Map<String, Object> getById(int venueId) throws SQLException {
        String sql =
            "SELECT v.venue_id, v.stadium_name, v.city, v.host_country, v.capacity, " +
            "       (SELECT COUNT(*) FROM Matches m WHERE m.venue_id = v.venue_id) AS match_count " +
            "FROM Venues v WHERE v.venue_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, venueId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rowToMap(rs) : null;
            }
        }
    }

    private Map<String, Object> rowToMap(ResultSet rs) throws SQLException {
        Map<String, Object> row = new LinkedHashMap<>();
        row.put("venue_id", rs.getInt("venue_id"));
        row.put("stadium_name", rs.getString("stadium_name"));
        row.put("city", rs.getString("city"));
        row.put("host_country", rs.getString("host_country"));
        row.put("capacity", rs.getObject("capacity"));
        row.put("match_count", rs.getInt("match_count"));
        return row;
    }

    public int create(String stadiumName, String city, String hostCountry, Integer capacity) throws SQLException {
        String sql = "INSERT INTO Venues (stadium_name, city, host_country, capacity) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, stadiumName);
            ps.setString(2, city);
            ps.setString(3, hostCountry);
            setNullableInt(ps, 4, capacity);
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                keys.next();
                return keys.getInt(1);
            }
        }
    }

    public void update(int venueId, String stadiumName, String city, String hostCountry, Integer capacity)
            throws SQLException {
        String sql = "UPDATE Venues SET stadium_name = ?, city = ?, host_country = ?, capacity = ? WHERE venue_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, stadiumName);
            ps.setString(2, city);
            ps.setString(3, hostCountry);
            setNullableInt(ps, 4, capacity);
            ps.setInt(5, venueId);
            ps.executeUpdate();
        }
    }

    /** FR: "Stadiums with a schedule can not be removed." */
    public void delete(int venueId) throws SQLException, IllegalStateException {
        try (Connection conn = DBConnection.getConnection()) {
            try (PreparedStatement check = conn.prepareStatement(
                    "SELECT COUNT(*) FROM Matches WHERE venue_id = ?")) {
                check.setInt(1, venueId);
                try (ResultSet rs = check.executeQuery()) {
                    rs.next();
                    if (rs.getInt(1) > 0) {
                        throw new IllegalStateException(
                            "This stadium has matches scheduled and can't be removed. Remove those matches first.");
                    }
                }
            }
            try (PreparedStatement del = conn.prepareStatement("DELETE FROM Venues WHERE venue_id = ?")) {
                del.setInt(1, venueId);
                del.executeUpdate();
            }
        }
    }

    private void setNullableInt(PreparedStatement ps, int index, Integer value) throws SQLException {
        if (value == null) ps.setNull(index, Types.INTEGER);
        else ps.setInt(index, value);
    }
}
