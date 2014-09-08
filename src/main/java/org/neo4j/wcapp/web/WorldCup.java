package org.neo4j.wcapp.web;

public class WorldCup
{

    private int year;
    private String host;

    public WorldCup( int year, String host )
    {

        this.year = year;
        this.host = host;
    }

    public int getYear()
    {
        return year;
    }


    public String getHost()
    {
        return host;
    }
}
