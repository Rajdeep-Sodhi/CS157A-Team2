import dao.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        String email = req.getParameter("email");
        String password = req.getParameter("password");

        if (email == null || email.isBlank() || password == null || password.isBlank()) {
            req.setAttribute("error", "Email and password are required.");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
            return;
        }

        String sql =
            "SELECT user_id, name, role FROM Users " +
            "WHERE email = ? AND password_hash = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement statement = conn.prepareStatement(sql)) {

            statement.setString(1, email.trim());
            statement.setString(2, password);

            try (ResultSet rs = statement.executeQuery()) {
                if (rs.next()) {
                    HttpSession session = req.getSession();
                    session.setAttribute("userId", rs.getInt("user_id"));
                    session.setAttribute("userName", rs.getString("name"));
                    session.setAttribute("userRole", rs.getString("role"));
                    resp.sendRedirect(req.getContextPath() + "/matches.jsp");
                    return;
                }
            }

            req.setAttribute("error", "Invalid email or password.");
        } catch (SQLException e) {
            req.setAttribute("error", "Unable to sign in right now: " + e.getMessage());
        }

        req.getRequestDispatcher("/login.jsp").forward(req, resp);
    }
}
