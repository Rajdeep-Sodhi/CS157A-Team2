package model;

//matchAssignment stores match information and the assigned referee
public class MatchAssignment
{
    //match id
    private int matchId;

    //date and time of the match
    private String matchDate;

    //names of the 2 teams
    private String team1CountryName;
    private String team2CountryName;

    //referee currently assigned (0 if noone assigned yet)
    private int refereeId;
    private String refereeName;

    public MatchAssignment() {}

    public int getMatchId()
    {
        return matchId;
    }

    public void setMatchId(int matchId)
    {
        this.matchId = matchId;
    }

    public String getMatchDate()
    {
        return matchDate;
    }

    public void setMatchDate(String matchDate)
    {
        this.matchDate = matchDate;
    }

    public String getTeam1CountryName()
    {
        return team1CountryName;
    }

    public void setTeam1CountryName(String team1CountryName)
    {
        this.team1CountryName = team1CountryName;
    }

    public String getTeam2CountryName()
    {
        return team2CountryName;
    }

    public void setTeam2CountryName(String team2CountryName)
    {
        this.team2CountryName = team2CountryName;
    }

    public int getRefereeId()
    {
        return refereeId;
    }

    public void setRefereeId(int refereeId)
    {
        this.refereeId = refereeId;
    }

    public String getRefereeName()
    {
        return refereeName;
    }

    public void setRefereeName(String refereeName)
    {
        this.refereeName = refereeName;
    }
}