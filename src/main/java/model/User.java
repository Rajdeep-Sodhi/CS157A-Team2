package model;

import java.io.Serializable;

/**
 * User.java
 * Minimal representation of the logged-in user, stored in the
 * HttpSession under the "authUser" attribute.
 */
public class User implements Serializable {
    private int userId;
    private String name;
    private String email;
    private String role; // "guest" | "fan" | "admin"
    private int flaggedCommentCount;

    public User(int userId, String name, String email, String role) {
        this.userId = userId;
        this.name = name;
        this.email = email;
        this.role = role;
    }

    public int getUserId() { return userId; }
    public String getName() { return name; }
    public String getEmail() { return email; }
    public String getRole() { return role; }

    public boolean isAdmin() { return "admin".equalsIgnoreCase(role); }
    public int getFlaggedCommentCount() { return flaggedCommentCount; }
    public void setFlaggedCommentCount(int flaggedCommentCount) { this.flaggedCommentCount = flaggedCommentCount; }
}
