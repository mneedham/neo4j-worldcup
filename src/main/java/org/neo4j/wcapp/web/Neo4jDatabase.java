package org.neo4j.wcapp.web;

import java.net.URI;
import java.util.Map;

import javax.ws.rs.core.MediaType;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.JsonNodeFactory;
import com.fasterxml.jackson.databind.node.ObjectNode;
import com.fasterxml.jackson.jaxrs.json.JacksonJsonProvider;
import com.sun.jersey.api.client.Client;
import com.sun.jersey.api.client.ClientResponse;
import com.sun.jersey.api.client.config.DefaultClientConfig;

public class Neo4jDatabase
{
    private final URI neo4jURI;
    private final Client client;

    public Neo4jDatabase( URI neo4jURI )
    {
        this.neo4jURI = neo4jURI;

        client = Client.create( config() );
    }

    private DefaultClientConfig config()
    {
        DefaultClientConfig defaultClientConfig = new DefaultClientConfig();
        defaultClientConfig.getClasses().add( JacksonJsonProvider.class );
        return defaultClientConfig;
    }

    public JsonNode query( String query, Map<String, Object> properties )
    {
        ObjectNode data = JsonNodeFactory.instance.objectNode();

        ArrayNode statements = JsonNodeFactory.instance.arrayNode();
        data.put("statements", statements);

        ObjectNode aQuery = JsonNodeFactory.instance.objectNode();
        aQuery.put( "statement", query );

        aQuery.put( "parameters", new ObjectMapper().valueToTree( properties ) );

        statements.add( aQuery );

        ClientResponse clientResponse = client.
                resource( neo4jURI + "/db/data/transaction/commit" ).
                accept( MediaType.APPLICATION_JSON_TYPE ).
                entity( data, MediaType.APPLICATION_JSON_TYPE ).
                post( ClientResponse.class );

        return clientResponse.getEntity( JsonNode.class ).get("results").get(0);
    }
}
