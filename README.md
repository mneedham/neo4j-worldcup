World Cup 2014 with Neo4j
==============

## Getting the data

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

## Importing into Neo4j

[load.cyp](data/import/load.cyp) contains a cypher script which reads [matches.csv](data/import/matches.csv) that was created above. You'll need to update the path as it's hardcoded for my machine

We then import using Neo4j shell:

````
/path/to/neo4j/bin/neo4j-shell --file /path/to/neo4j-world-cup/data/import.load.cyp
````

And we're done!