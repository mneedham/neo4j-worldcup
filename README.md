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

The [data/import](data/import/) directory contains all the cypher scripts you need to import the data. The scripts contain links to the raw version of CSV files containing the various bits of data.


You can import everything into a local Neo4j 2.1.2 database by using [doit.sh](doit.sh), making sure that you tell it where to look for Neo4j first by setting $WC_DB:

````
export WC_DB="/Users/markneedham/test-bench/databases/050/neo4j-enterprise-2.1.2"
````

````
./doit.sh
````