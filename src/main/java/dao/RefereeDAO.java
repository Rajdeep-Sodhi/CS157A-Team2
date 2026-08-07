package dao;

import model.Referee;
import model.MatchAssignment;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

//handles referee management
//includes add, edit, delete, and assign referees
//and checking that a referee isn't from the same country as either team
//and checking that a referee isn't double-booked at the same time
public class RefereeDAO
{
    //load all referees
    public List<Referee> getAllReferees()
    {
        List<Referee> refereeList = new ArrayList<>();
        String sql = "SELECT referee_id, name, country_name FROM Referees ORDER BY referee_id";
        try
        {
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            while(rs.next())
            {
                Referee referee = new Referee();

                //read referee info from each row
                referee.setRefereeId(rs.getInt("referee_id"));
                referee.setName(rs.getString("name"));
                referee.setCountryName(rs.getString("country_name"));

                //add referee to the list
                refereeList.add(referee);
            }
            rs.close();
            ps.close();
            conn.close();
        }
        catch(SQLException e)
        {
            e.printStackTrace();
        }

        return refereeList;
    }

    //find one referee by id
    public Referee getRefereeById(int refereeId)
    {
        Referee referee = null;
        String sql = "SELECT referee_id, name, country_name FROM Referees WHERE referee_id = ?";

        try
        {
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);

            //set referee id
            ps.setInt(1, refereeId);
            ResultSet rs = ps.executeQuery();
            if(rs.next())
            {
                referee = new Referee();

                //read referee info from database
                referee.setRefereeId(rs.getInt("referee_id"));
                referee.setName(rs.getString("name"));
                referee.setCountryName(rs.getString("country_name"));
            }
            rs.close();
            ps.close();
            conn.close();
        }
        catch(SQLException e)
        {
            e.printStackTrace();
        }
        return referee;
    }

    //save a new referee
    public boolean addReferee(Referee referee)
    {
        String sql = "INSERT INTO Referees(name, country_name) VALUES(?, ?)";
        try
        {
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);

            //save referee info
            ps.setString(1, referee.getName());
            ps.setString(2, referee.getCountryName());
            int rows = ps.executeUpdate();

            ps.close();
            conn.close();
            return rows > 0;
        }
        catch(SQLException e)
        {
            e.printStackTrace();
        }
        return false;
    }

    //update referee info
    public boolean updateReferee(Referee referee)
    {
        String sql = "UPDATE Referees SET name = ?, country_name = ? WHERE referee_id = ?";
        try
        {
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);

            //update
            ps.setString(1, referee.getName());
            ps.setString(2, referee.getCountryName());
            ps.setInt(3, referee.getRefereeId());
            int rows = ps.executeUpdate();

            ps.close();
            conn.close();
            return rows > 0;
        }
        catch(SQLException e)
        {
            e.printStackTrace();
        }
        return false;
    }

    //delete referee
    //dont allow delete a referee already assigned to a match
    public boolean deleteReferee(int refereeId)
    {
        //check if this referee is assigned to any match
        if(countMatchesForReferee(refereeId) > 0)
        {
            //this referee is used
            return false;
        }

        //delete referee
        String sql = "DELETE FROM Referees WHERE referee_id = ?";
        try
        {
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, refereeId);
            int rows = ps.executeUpdate();

            ps.close();
            conn.close();
            return rows > 0;
        }
        catch(SQLException e)
        {
            e.printStackTrace();
        }
        return false;
    }

    //count how many matches are assigned to this referee
    public int countMatchesForReferee(int refereeId)
    {
        int count = 0;
        String sql = "SELECT COUNT(*) AS total FROM Matches WHERE referee_id = ?";
        try
        {
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, refereeId);
            ResultSet rs = ps.executeQuery();
            if(rs.next())
            {
                //save total number of matches
                count = rs.getInt("total");
            }
            rs.close();
            ps.close();
            conn.close();
        }
        catch(SQLException e)
        {
            e.printStackTrace();
        }
        return count;
    }

    //load all matches for referee assgmt
    //include the assigned referee if there is one
    public List<MatchAssignment> getMatchesForAssignment()
    {
        List<MatchAssignment> matchList = new ArrayList<>();

        String sql = "SELECT m.match_id, m.match_date, " +
                     "m.team1_country_name, m.team2_country_name, " +
                     "m.referee_id, " +
                     "(SELECT r.name FROM Referees r WHERE r.referee_id = m.referee_id) AS referee_name " +
                     "FROM Matches m " +
                     "ORDER BY m.match_date ASC";

        try
        {
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();

            while(rs.next())
            {
                MatchAssignment match = new MatchAssignment();

                //save match info
                match.setMatchId(rs.getInt("match_id"));
                match.setMatchDate(String.valueOf(rs.getTimestamp("match_date")));
                match.setTeam1CountryName(rs.getString("team1_country_name"));
                match.setTeam2CountryName(rs.getString("team2_country_name"));

                //save referee info
                match.setRefereeId(rs.getInt("referee_id"));
                match.setRefereeName(rs.getString("referee_name"));

                matchList.add(match);
            }

            rs.close();
            ps.close();
            conn.close();
        }
        catch(SQLException e)
        {
            e.printStackTrace();
        }

        return matchList;
    }

    //check if referee already has another match at the same date/time
    public boolean hasScheduleConflict(int refereeId, int matchId)
    {
        boolean conflict = false;
        String sql = "SELECT COUNT(*) AS total FROM Matches m1 " +
                     "JOIN Matches m2 ON m1.match_date = m2.match_date " +
                     "WHERE m1.match_id = ? " +
                     "AND m2.match_id != m1.match_id " +
                     "AND m2.referee_id = ?";
        try
        {
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);

            ps.setInt(1, matchId);
            ps.setInt(2, refereeId);

            ResultSet rs = ps.executeQuery();
            if(rs.next())
            {
                conflict = rs.getInt("total") > 0;
            }

            rs.close();
            ps.close();
            conn.close();
        }
        catch(SQLException e)
        {
            e.printStackTrace();
        }
        return conflict;
    }

    //check if referee can be assigned to this match
    //referee cant have the same country as either team
    //referee also cant already be busy with another match at the same time
    public String checkRefereeConflict(int refereeId, int matchId)
    {
        Referee referee = getRefereeById(refereeId);
        if(referee == null)
        {
            return "Referee not found.";
        }
        String team1 = null;
        String team2 = null;
        String sql = "SELECT team1_country_name, team2_country_name FROM Matches WHERE match_id = ?";
        try
        {
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, matchId);
            ResultSet rs = ps.executeQuery();
            if(rs.next())
            {
                //get both teams in this match
                team1 = rs.getString("team1_country_name");
                team2 = rs.getString("team2_country_name");
            }
            rs.close();
            ps.close();
            conn.close();
        }
        catch(SQLException e)
        {
            e.printStackTrace();
        }
        String refereeCountry = referee.getCountryName();

        //check if referee has the same country with team
        if(refereeCountry != null &&
          (refereeCountry.equals(team1) || refereeCountry.equals(team2)))
        {
            return "This referee cannot officiate this match.";
        }

        //check if referee is already assigned to another match at the same time
        if(hasScheduleConflict(refereeId, matchId))
        {
            return "This referee is already assigned to another match at the same time.";
        }

        return null;
    }

    //assign referee to a match
    public boolean assignReferee(int refereeId, int matchId)
    {
        String sql = "UPDATE Matches SET referee_id = ? WHERE match_id = ?";
        try
        {
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);

            //save referee assignment
            ps.setInt(1, refereeId);
            ps.setInt(2, matchId);
            int rows = ps.executeUpdate();
            ps.close();
            conn.close();
            return rows > 0;
        }
        catch(SQLException e)
        {
            e.printStackTrace();
        }

        return false;
    }

    //remove referee from a match
    public boolean unassignReferee(int matchId)
    {
        String sql = "UPDATE Matches SET referee_id = NULL WHERE match_id = ?";
        try
        {
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);

            //clear referee assignment
            ps.setInt(1, matchId);
            int rows = ps.executeUpdate();
            ps.close();
            conn.close();
            return rows > 0;
        }
        catch(SQLException e)
        {
            e.printStackTrace();
        }
        return false;
    }
}