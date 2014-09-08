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

            matches.add( new Match( row.get( "row" ).get( 0 ).get( "description" ).asText() ) );
        }
        return matches;
    }
}
