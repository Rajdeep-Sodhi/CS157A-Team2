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
import java.sql.Statement;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        String email = req.getParameter("email");
        String name = req.getParameter("name");
        String password = req.getParameter("password");

        if (email == null || email.isBlank()
                || name == null || name.isBlank()
                || password == null || password.isBlank()) {
            req.setAttribute("error", "Email, name, and password are required.");
            req.getRequestDispatcher("/register.jsp").forward(req, resp);
            return;
        }

        String sql =
            "INSERT INTO Users (email, name, password_hash, role) " +
            "VALUES (?, ?, ?, 'fan')";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement statement =
                     conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            statement.setString(1, email.trim());
            statement.setString(2, name.trim());
            statement.setString(3, password);
            statement.executeUpdate();

            try (ResultSet keys = statement.getGeneratedKeys()) {
                if (keys.next()) {
                    HttpSession session = req.getSession();
                    session.setAttribute("userId", keys.getInt(1));
                    session.setAttribute("userName", name.trim());
                    session.setAttribute("userRole", "fan");
                    resp.sendRedirect(req.getContextPath() + "/predictions.jsp");
                    return;
                } else {
                    req.setAttribute("success", "Registration complete.");
                }
            }
        } catch (SQLException e) {
            if ("23000".equals(e.getSQLState())) {
                req.setAttribute("error", "An account with that email already exists.");
            } else {
                req.setAttribute("error", "Unable to register right now: " + e.getMessage());
            }
        }

        req.getRequestDispatcher("/register.jsp").forward(req, resp);
    }
}
