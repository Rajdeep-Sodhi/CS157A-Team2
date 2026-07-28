package dao;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

/**
 * PasswordUtil.java
 * Small helper for hashing/verifying passwords with SHA-256.
 *
 * Note: the seeded demo accounts in sql/seed_data.sql store their
 * password_hash column as plain text (e.g. "changeme") so the team
 * can log in immediately without re-seeding. verify() accepts a
 * plain-text match as a fallback for those legacy rows, but every
 * NEW account created through register.jsp is stored as a real
 * SHA-256 hash. In a production app you'd use a salted algorithm
 * like bcrypt instead - SHA-256 here is meant to match the scope
 * of this course project.
 */
public class PasswordUtil {

    public static String hash(String plainPassword) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] bytes = digest.digest(plainPassword.getBytes("UTF-8"));
            StringBuilder sb = new StringBuilder();
            for (byte b : bytes) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (NoSuchAlgorithmException | java.io.UnsupportedEncodingException e) {
            throw new RuntimeException("Unable to hash password", e);
        }
    }

    public static boolean verify(String plainPassword, String storedValue) {
        if (storedValue == null) return false;
        // Newly registered accounts: stored value is a 64-char hex SHA-256 hash.
        if (storedValue.length() == 64 && storedValue.matches("[0-9a-f]+")) {
            return hash(plainPassword).equals(storedValue);
        }
        // Legacy/seeded accounts: stored value is plain text.
        return storedValue.equals(plainPassword);
    }
}
