package org.neo4j.wcapp.web;

import java.util.ArrayList;
import java.util.List;

import com.fasterxml.jackson.databind.JsonNode;
import io.dropwizard.views.View;

public class MatchView extends View
{
    private JsonNode result;

    public MatchView( JsonNode result )
    {
        super("match.ftl");
        this.result = result;
    }

    public Match getMatch() {
        JsonNode rowContents = result.get( "data" ).get( 0 ).get( "row" ).get( 0 );

        JsonNode teams = result.get( "data" ).get( 0 ).get( "row" ).get( 1 );

        JsonNode team1 = teams.get( 0 ).get( "team" ).get( "name" );
        JsonNode team2 = teams.get( 1 ).get( "team" ).get( "name" );

        List<String> team1Players = players( teams.get( 0 ).get( "players" ) );
        List<String> team2Players = players( teams.get( 1 ).get( "players" ) );

        String description = rowContents.get( "description" ).asText();
        String id = rowContents.get( "id" ).asText();
        String homeScore = rowContents.get( "h_score" ).asText();
        String awayScore = rowContents.get( "a_score" ).asText();
        String date = rowContents.get( "date" ).asText();

        return new Match( id, description, homeScore, awayScore, date, team1Players, team2Players );
    }

    private List<String> players( JsonNode players )
    {
        List<String> somePlayers = new ArrayList<>(  );
        for ( JsonNode player : players )
        {
            String playerName = player.get( "name" ).asText();
            somePlayers.add( playerName );
        }
        return somePlayers;
    }
}
