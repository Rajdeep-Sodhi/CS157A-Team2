package dao;

import model.User;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * UserDAO.java
 * Handles login lookups and new-user registration.
 */
public class UserDAO {

    public User getById(int userId) throws SQLException {
        String sql = "SELECT user_id, name, email, role, is_banned FROM Users WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                User user = new User(
                    rs.getInt("user_id"),
                    rs.getString("name"),
                    rs.getString("email"),
                    rs.getString("role")
                );
                user.setBanned(rs.getBoolean("is_banned"));
                return user;
            }
        }
    }

    public List<User> listAll() throws SQLException {
        String sql =
            "SELECT u.user_id, u.name, u.email, u.role, u.is_banned, " +
            "       (SELECT COUNT(*) FROM Comments c WHERE c.user_id = u.user_id AND c.is_flagged = TRUE) AS flagged_comment_count " +
            "FROM Users u " +
            "ORDER BY u.role = 'admin' DESC, u.name ASC, u.email ASC";
        List<User> users = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) {
                User user = new User(
                    rs.getInt("user_id"),
                    rs.getString("name"),
                    rs.getString("email"),
                    rs.getString("role")
                );
                user.setFlaggedCommentCount(rs.getInt("flagged_comment_count"));
                user.setBanned(rs.getBoolean("is_banned"));
                users.add(user);
            }
        }
        return users;
    }

    /** Returns the User if email/password match, otherwise null. Banned status is set on the returned User - LoginServlet checks it and refuses login. */
    public User authenticate(String email, String password) throws SQLException {
        String sql = "SELECT user_id, name, email, password_hash, role, is_banned FROM Users WHERE email = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String storedHash = rs.getString("password_hash");
                    if (PasswordUtil.verify(password, storedHash)) {
                        User user = new User(
                                rs.getInt("user_id"),
                                rs.getString("name"),
                                rs.getString("email"),
                                rs.getString("role"));
                        user.setBanned(rs.getBoolean("is_banned"));
                        return user;
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

    /** Used before demoting an admin, so the system can never end up with zero admins. */
    public int countAdmins() throws SQLException {
        String sql = "SELECT COUNT(*) FROM Users WHERE role = 'admin'";
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    /**
     * FR: comment-moderation action "ban user". Banned users keep their
     * account, comments, and predictions - they just can't log in
     * (LoginServlet checks User.isBanned()). Admin accounts can never
     * be banned, same protection as delete/demote.
     */
    public void setBanned(int userId, boolean banned) throws SQLException, IllegalStateException {
        String role = null;
        try (Connection conn = DBConnection.getConnection()) {
            try (PreparedStatement check = conn.prepareStatement(
                    "SELECT role FROM Users WHERE user_id = ?")) {
                check.setInt(1, userId);
                try (ResultSet rs = check.executeQuery()) {
                    if (rs.next()) role = rs.getString("role");
                }
            }

            if (role == null) {
                throw new IllegalStateException("That user no longer exists.");
            }
            if ("admin".equalsIgnoreCase(role)) {
                throw new IllegalStateException("Admin accounts cannot be banned.");
            }

            try (PreparedStatement update = conn.prepareStatement(
                    "UPDATE Users SET is_banned = ? WHERE user_id = ?")) {
                update.setBoolean(1, banned);
                update.setInt(2, userId);
                update.executeUpdate();
            }
        }
    }

    public void deleteUser(int userId) throws SQLException {
        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                String role = null;
                try (PreparedStatement check = conn.prepareStatement(
                        "SELECT role FROM Users WHERE user_id = ?")) {
                    check.setInt(1, userId);
                    try (ResultSet rs = check.executeQuery()) {
                        if (rs.next()) {
                            role = rs.getString("role");
                        }
                    }
                }

                if (role == null) {
                    throw new IllegalStateException("That user no longer exists.");
                }
                if ("admin".equalsIgnoreCase(role)) {
                    throw new IllegalStateException("Admin accounts cannot be edited or removed.");
                }

                try (PreparedStatement clearFlags = conn.prepareStatement(
                        "UPDATE Comments SET flagged_by_user_id = NULL WHERE flagged_by_user_id = ?")) {
                    clearFlags.setInt(1, userId);
                    clearFlags.executeUpdate();
                }

                try (PreparedStatement deleteVotesCast = conn.prepareStatement(
                        "DELETE FROM CommentVotes WHERE user_id = ?")) {
                    deleteVotesCast.setInt(1, userId);
                    deleteVotesCast.executeUpdate();
                }

                try (PreparedStatement deletePredictions = conn.prepareStatement(
                        "DELETE FROM Predictions WHERE user_id = ?")) {
                    deletePredictions.setInt(1, userId);
                    deletePredictions.executeUpdate();
                }

                try (PreparedStatement deleteVotesReceived = conn.prepareStatement(
                        "DELETE FROM CommentVotes WHERE comment_id IN (SELECT comment_id FROM Comments WHERE user_id = ?)")) {
                    deleteVotesReceived.setInt(1, userId);
                    deleteVotesReceived.executeUpdate();
                }

                try (PreparedStatement deleteComments = conn.prepareStatement(
                        "DELETE FROM Comments WHERE user_id = ?")) {
                    deleteComments.setInt(1, userId);
                    deleteComments.executeUpdate();
                }

                try (PreparedStatement deleteUser = conn.prepareStatement(
                        "DELETE FROM Users WHERE user_id = ?")) {
                    deleteUser.setInt(1, userId);
                    deleteUser.executeUpdate();
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
}