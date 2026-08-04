import dao.RefereeDAO;
import model.MatchAssignment;
import model.Referee;
import util.AuthHelper;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

//referee page
//anyone can view but only admin can edit
@WebServlet("/referees")
public class RefereeServlet extends HttpServlet
{
    private final RefereeDAO refereeDAO = new RefereeDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException
    {
        //load referee list
        List<Referee> referees = refereeDAO.getAllReferees();
        req.setAttribute("referees", referees);

        //load matches too for the assign form
        List<MatchAssignment> matches = refereeDAO.getMatchesForAssignment();
        req.setAttribute("matches", matches);

        req.getRequestDispatcher("/referees.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException
    {
        //only admin allowed here
        if(!AuthHelper.requireAdmin(req, resp))
        {
            return;
        }
        String action = req.getParameter("action");
        String errorMessage = null;

        if("add".equals(action))
        {
            handleAdd(req);
        }
        else if("edit".equals(action))
        {
            handleEdit(req);
        }
        else if("delete".equals(action))
        {
            int refereeId = Integer.parseInt(req.getParameter("referee_id"));
            boolean deleted = refereeDAO.deleteReferee(refereeId);

            //deleteReferee returns false if referee still assigned to a match
            if(!deleted)
            {
                errorMessage = "This referee is still assigned to a match, unassign it first.";
            }
        }
        else if("assign".equals(action))
        {
            errorMessage = handleAssign(req);
        }
        else if("unassign".equals(action))
        {
            int matchId = Integer.parseInt(req.getParameter("match_id"));
            refereeDAO.unassignReferee(matchId);
        }

        //something wrong stay on page and show error
        if(errorMessage != null)
        {
            showError(req, resp, errorMessage);
            return;
        }
        resp.sendRedirect(req.getContextPath() + "/referees");
    }

    //add new referee
    private void handleAdd(HttpServletRequest req)
    {
        Referee referee = new Referee();
        referee.setName(req.getParameter("name"));
        referee.setCountryName(req.getParameter("country_name"));
        refereeDAO.addReferee(referee);
    }

    //update existing referee
    private void handleEdit(HttpServletRequest req)
    {
        Referee referee = new Referee();
        referee.setRefereeId(Integer.parseInt(req.getParameter("referee_id")));
        referee.setName(req.getParameter("name"));
        referee.setCountryName(req.getParameter("country_name"));
        refereeDAO.updateReferee(referee);
    }

    //assign referee to match + check if same country with team
    //return error msg if failed, null if it worked
    private String handleAssign(HttpServletRequest req)
    {
        int refereeId = Integer.parseInt(req.getParameter("referee_id"));
        int matchId = Integer.parseInt(req.getParameter("match_id"));
        String conflict = refereeDAO.checkRefereeConflict(refereeId, matchId);
        if(conflict != null)
        {
            return conflict;
        }
        refereeDAO.assignReferee(refereeId, matchId);
        return null;
    }

    //stay on referee page and show what went wrong
    private void showError(HttpServletRequest req, HttpServletResponse resp, String message)
            throws ServletException, IOException
    {
        req.setAttribute("dbError", message);
        req.setAttribute("referees", refereeDAO.getAllReferees());
        req.setAttribute("matches", refereeDAO.getMatchesForAssignment());
        req.getRequestDispatcher("/referees.jsp").forward(req, resp);
    }
}
