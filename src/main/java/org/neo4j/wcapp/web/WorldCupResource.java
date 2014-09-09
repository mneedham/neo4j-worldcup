package org.neo4j.wcapp.web;

import java.util.HashMap;
import java.util.Map;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.QueryParam;
import javax.ws.rs.core.MediaType;

import com.codahale.metrics.annotation.Timed;
import com.fasterxml.jackson.databind.JsonNode;

@Path("/")
@Produces(MediaType.TEXT_HTML)
public class WorldCupResource
{
    private Neo4jDatabase neo4j;

    public WorldCupResource( Neo4jDatabase neo4j )
    {
        this.neo4j = neo4j;
    }

    @GET
    @Timed
    public HomeView index()
    {
        HashMap<String, Object> properties = new HashMap<>();

        JsonNode result = neo4j.query( "MATCH (wc:WorldCup)-[:HOSTED_BY]->(host)\n" +
                                       "RETURN wc, host", properties );

        return new HomeView(result);
    }

    @GET
    @Timed
    @Path( "/events/{year}" )
    public EventView event( @PathParam("year")int year)
    {
        Map<String, Object> properties = new HashMap<>(  );
        properties.put("year", year);

        JsonNode result = neo4j.query(
                "MATCH (host)<-[:HOSTED_BY]-(wc:WorldCup {year: {year}})-[:CONTAINS_MATCH]->(match)\n" +
                "RETURN match, host, wc", properties );

        return new EventView(result);
    }

    @GET
    @Timed
    @Path( "/matches/{matchId}" )
    public MatchView match( @PathParam("matchId")String matchId)
    {
        Map<String, Object> properties = new HashMap<>(  );
        properties.put("matchId", matchId);

        JsonNode result = neo4j.query(
                "MATCH (match:Match {id: {matchId} })<-[:IN_MATCH]-()<-[:STARTED]-(player)" +
                        "-[:IN_SQUAD]->(squad)<-[:NAMED_SQUAD]-(team), " +
                "      (squad)-[:FOR_WORLD_CUP]->(wc)-[:CONTAINS_MATCH]->(match)\n" +
                "WITH match, team, COLLECT(player) AS players\n" +
                "RETURN match, COLLECT({team: team, players: players}) AS teams", properties );

        return new MatchView(result);
    }
}
