package org.neo4j.wcapp.web;

import java.util.ArrayList;
import java.util.List;

import com.fasterxml.jackson.databind.JsonNode;
import io.dropwizard.views.View;

public class EventView extends View
{

    private JsonNode result;

    public EventView( JsonNode result )
    {
        super("event.ftl");
        this.result = result;
    }

    public WorldCup getWorldCup() {
        String host = result.get( "data" ).get( 0 ).get( "row" ).get( 1 ).get( "name" ).asText();
        int year = result.get( "data" ).get( 0 ).get( "row" ).get( 2 ).get( "year" ).asInt();

        return new WorldCup( year, host );
    }

    public List<Match> getMatches() {
        List<Match> matches = new ArrayList<>(  );

        JsonNode rows = result.get( "data" );
        for ( JsonNode row : rows )
        {

            JsonNode rowContents = row.get( "row" ).get( 0 );
            String description = rowContents.get( "description" ).asText();
            String id = rowContents.get( "id" ).asText();
            String homeScore = rowContents.get( "h_score" ).asText();
            String awayScore = rowContents.get( "a_score" ).asText();
            String date = rowContents.get( "date" ).asText();
            matches.add( new Match(id, description, homeScore, awayScore, date ) );
        }
        return matches;
    }
}
