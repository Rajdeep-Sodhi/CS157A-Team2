package util;
import model.User;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * AuthHelper.java
 * Shared role-checking logic used by the admin-only servlets
 * (TeamServlet, PlayerServlet, MatchServlet, VenueServlet, RefereeServlet).
 */
public class AuthHelper {
    public static User currentUser(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) return null;
        return (User) session.getAttribute("authUser");
    }

    public static boolean isAdmin(HttpServletRequest req) {
        //some servlets store a full User object in "authUser"
        User user = currentUser(req);
        if (user != null) {
            return user.isAdmin();
        }

        //login servlet actually stores the role as a plain string in "userRole"
        //check that too so admin pages work no matter which login flow set the session
        HttpSession session = req.getSession(false);
        if (session == null) return false;

        Object role = session.getAttribute("userRole");
        return role != null && "admin".equalsIgnoreCase(role.toString());
    }

    /**
     * Returns true if the request may proceed. If the user isn't an
     * admin, redirects them away and returns false - callers should
     * return immediately when this returns false.
     */
    public static boolean requireAdmin(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        if (isAdmin(req)) return true;
        resp.sendRedirect(req.getContextPath() + "/login");
        return false;
    }
}