import dao.UserDAO;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;

/**
 * RegisterServlet.java
 * FR: "Users registration/login" - handles new-fan sign up on register.jsp.
 * New accounts are always created with role='fan'; admin access is
 * granted manually by an existing admin (per the functional spec).
 */
@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.getRequestDispatcher("/register.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String name = req.getParameter("name");
        String email = req.getParameter("email");
        String password = req.getParameter("password");
        String dob = req.getParameter("dob");
        String country = req.getParameter("country");

        if (isBlank(name) || isBlank(email) || isBlank(password)) {
            req.setAttribute("error", "Name, email, and password are required.");
            forwardWithInput(req, resp, name, email, dob, country);
            return;
        }

        try {
            UserDAO userDAO = new UserDAO();
            if (userDAO.emailExists(email.trim())) {
                req.setAttribute("error", "That email is already in use.");
                forwardWithInput(req, resp, name, email, dob, country);
                return;
            }

            User user = userDAO.register(name.trim(), email.trim(), password, dob, country);

            HttpSession session = req.getSession(true);
            session.setAttribute("authUser", user);

            resp.sendRedirect(req.getContextPath() + "/");
        } catch (SQLException e) {
            req.setAttribute("error", "Database error: " + e.getMessage());
            forwardWithInput(req, resp, name, email, dob, country);
        }
    }

    private boolean isBlank(String s) {
        return s == null || s.isBlank();
    }

    private void forwardWithInput(HttpServletRequest req, HttpServletResponse resp,
                                   String name, String email, String dob, String country)
            throws ServletException, IOException {
        req.setAttribute("name", name);
        req.setAttribute("email", email);
        req.setAttribute("dob", dob);
        req.setAttribute("country", country);
        req.getRequestDispatcher("/register.jsp").forward(req, resp);
    }
}
