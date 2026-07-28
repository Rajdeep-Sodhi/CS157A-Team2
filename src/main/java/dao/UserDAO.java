package dao;

import model.User;

import java.sql.*;

/**
 * UserDAO.java
 * Handles login lookups and new-user registration.
 */
public class UserDAO {

    /** Returns the User if email/password match, otherwise null. */
    public User authenticate(String email, String password) throws SQLException {
        String sql = "SELECT user_id, name, email, password_hash, role FROM Users WHERE email = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String storedHash = rs.getString("password_hash");
                    if (PasswordUtil.verify(password, storedHash)) {
                        return new User(
                                rs.getInt("user_id"),
                                rs.getString("name"),
                                rs.getString("email"),
                                rs.getString("role"));
                    }
                }
            }
        }
        return null;
    }

    public boolean emailExists(String email) throws SQLException {
        String sql = "SELECT user_id FROM Users WHERE email = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    /**
     * Registers a new fan account (guests never get a row; admins are
     * promoted manually by an existing admin, per the functional spec).
     * dateOfBirth (ISO yyyy-MM-dd) and country are optional.
     */
    public User register(String name, String email, String plainPassword,
                          String dateOfBirth, String country) throws SQLException {
        String sql = "INSERT INTO Users (name, email, password_hash, role, date_of_birth, country) " +
                     "VALUES (?, ?, ?, 'fan', ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, name);
            ps.setString(2, email);
            ps.setString(3, PasswordUtil.hash(plainPassword));
            if (dateOfBirth == null || dateOfBirth.isBlank()) {
                ps.setNull(4, Types.DATE);
            } else {
                ps.setDate(4, Date.valueOf(dateOfBirth));
            }
            ps.setString(5, country);
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                int newId = keys.next() ? keys.getInt(1) : -1;
                return new User(newId, name, email, "fan");
            }
        }
    }

    /** Used by admins to promote an existing fan to admin (FR: "admin needs to provide access manually"). */
    public void setRole(int userId, String role) throws SQLException {
        String sql = "UPDATE Users SET role = ? WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, role);
            ps.setInt(2, userId);
            ps.executeUpdate();
        }
    }
}
