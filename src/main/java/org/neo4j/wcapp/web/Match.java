package org.neo4j.wcapp.web;

import java.util.List;

public class Match
{
    private String id;
    private String description;
    private String homeScore;
    private String awayScore;
    private String date;
    private List<String> team1Players;
    private List<String> team2Players;

    public Match( String id, String description, String homeScore, String awayScore, String date, List<String>
            team1Players, List<String> team2Players )
    {
        this.id = id;
        this.description = description;
        this.homeScore = homeScore;
        this.awayScore = awayScore;
        this.date = date;
        this.team1Players = team1Players;
        this.team2Players = team2Players;
    }

    public Match( String id, String description, String homeScore, String awayScore, String date )
    {
        this.id = id;
        this.description = description;
        this.homeScore = homeScore;
        this.awayScore = awayScore;
        this.date = date;
    }

    public List<String> getTeam2Players()
    {
        return team2Players;
    }

    public List<String> getTeam1Players()
    {
        return team1Players;


    }

    public String getId()
    {
        return id;
    }

    public String getDescription()
    {
        return description;
    }

    public String getHomeScore()
    {
        return homeScore;
    }

    public String getAwayScore()
    {
        return awayScore;
    }

    public String getDate()
    {
        return date;
    }
}
