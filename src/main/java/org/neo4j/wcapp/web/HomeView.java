package org.neo4j.wcapp.web;

import java.util.ArrayList;
import java.util.List;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.node.ArrayNode;
import io.dropwizard.views.View;

public class HomeView extends View
{
    private JsonNode result;

    public HomeView( JsonNode result ) {
        super("home.ftl");
        this.result = result;
    }

    public List<WorldCup> getWorldCups() {
        ArrayNode rows = (ArrayNode) result.get( "data" );

        List<WorldCup> worldCups = new ArrayList<>(  );
        for ( JsonNode row : rows )
        {
            JsonNode wc = row.get( "row" ).get( 0 );
            JsonNode host = row.get( "row" ).get( 1 );
            worldCups.add( new WorldCup( wc.get( "year" ).asInt() , host.get( "name" ).asText() ));
        }

        return worldCups;
    }
}
