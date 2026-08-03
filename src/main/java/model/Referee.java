package model;

public class Referee 
{
    //referee id
    private int refereeId;

    //referee full name
    private String name;

    //referee nationality
    private String countryName;

    //fifa certificate level
    private String fifaCertificate;

    //years of experience
    private int yearsExperience;

    //empty constructor
    public Referee() {}

    public Referee(int refereeId, String name,
            String countryName,
            String fifaCertificate,
            int yearsExperience) 
            {
                this.refereeId = refereeId;
                this.name = name;
                this.countryName = countryName;
                this.fifaCertificate = fifaCertificate;
                this.yearsExperience = yearsExperience;
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

    public String getFifaCertificate() 
    {
        return fifaCertificate;
    }

    public void setFifaCertificate(String fifaCertificate) 
    {
        this.fifaCertificate = fifaCertificate;
    }

    public int getYearsExperience() 
    {
        return yearsExperience;
    }

    public void setYearsExperience(int yearsExperience) 
    {
        this.yearsExperience = yearsExperience;
    }
}