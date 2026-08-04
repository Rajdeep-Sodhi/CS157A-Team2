package model;

public class Referee 
{
    //referee id
    private int refereeId;

    //referee full name
    private String name;

    //referee nationality
    private String countryName;

    //empty constructor
    public Referee() {}

    public Referee(int refereeId, String name, String countryName)
            {
                this.refereeId = refereeId;
                this.name = name;
                this.countryName = countryName;
            }

    public int getRefereeId() 
    {
        return refereeId;
    }

    public void setRefereeId(int refereeId) 
    {
        this.refereeId = refereeId;
    }

    public String getName() 
    {
        return name;
    }

    public void setName(String name) 
    {
        this.name = name;
    }

    public String getCountryName() 
    {
        return countryName;
    }

    public void setCountryName(String countryName) 
    {
        this.countryName = countryName;
    }

}
