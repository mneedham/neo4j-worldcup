World Cup 2014 with Neo4j
==============

## Importing the data set

The import of this data set uses LOAD CSV which was introduced in Neo4j 2.1.2 so you'll need to use that version.

You can [download Neo4j 2.1.2](http://www.neo4j.org/download) from the Neo4j website.

### Mac / Unix

Start Neo4j:

````
cd /path/to/where/you/installed/neo4j
./bin/neo4j start
````

Set the $WC_DB environment variable to the path to where you've installed Neo4j:

````
export WC_DB="/path/to/where/you/installed/neo4j"
````

Run the [doit.sh](doit.sh) script to import all the data:

````
./doit.sh
````

### Windows

Launch Neo4j using the desktop application.

Clear everything in the database and create indexes by running the following cypher statements in [Neo4j browser](http://localhost:7474)

````
MATCH n OPTIONAL MATCH (n)-[r]-() DELETE n,r;
````

````
CREATE INDEX ON :Match(id);
```

```
CREATE INDEX ON :WorldCup(name);
````

````
CREATE INDEX ON :Stadium(stadium);
````

````
CREATE INDEX ON :Phase(phase);
````

````
CREATE INDEX ON :Country(name);
````

````
CREATE INDEX ON :Time(time);
````

````
CREATE INDEX ON :MatchNumber(value);
````

````
CREATE INDEX ON :Player(id);
````

````
CREATE INDEX ON :Player(name);
````

Copy the contents of the following files into your Neo4j browser window one after the other and run them:

* [loadMatches.cyp](data/import/loadMatches.cyp)
* [loadSquads.cyp](data/import/loadSquads.cyp)
* [loadLineUps.cyp](data/import/loadLineUps.cyp)
* [loadEvents.cyp](data/import/loadEvents.cyp)

## Getting the raw data

There are 3 steps to getting the data ready for Neo4j:

* Find the pages we want to download e.g. all the matches

````
ruby scripts/find_matches.rb > data/matches.csv
````

* Download those pages

````
# reads from data/matches.csv and downloads into data/matches/
ruby scripts/download_matches.rb
````

* Create CSV files that we can use with Neo4j's LOAD CSV

````
# creates data/import/matches.csv
ruby scripts/to_csv
````