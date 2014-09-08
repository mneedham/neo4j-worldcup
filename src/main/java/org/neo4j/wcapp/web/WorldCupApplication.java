package org.neo4j.wcapp.web;

import java.net.URI;

import io.dropwizard.Application;
import io.dropwizard.assets.AssetsBundle;
import io.dropwizard.setup.Bootstrap;
import io.dropwizard.setup.Environment;
import io.dropwizard.views.ViewBundle;

public class WorldCupApplication extends Application<WorldCupConfiguration>
{
    public static void main( String[] args ) throws Exception
    {
        new WorldCupApplication().run( args );
    }

    @Override
    public String getName()
    {
        return "World Cup Graph";
    }

    @Override
    public void initialize( Bootstrap<WorldCupConfiguration> bootstrap )
    {
        bootstrap.addBundle( new ViewBundle() );
        bootstrap.addBundle( new AssetsBundle( "/assets/" ) );
    }

    @Override
    public void run( WorldCupConfiguration configuration, Environment environment )
    {
        Neo4jDatabase neo4jDatabase = new Neo4jDatabase( URI.create( "http://localhost:7474" ) );

        final WorldCupResource resource = new WorldCupResource( neo4jDatabase );
        environment.jersey().register( resource );
    }

}
