LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/mneedham/neo4j-worldcup/master/data/import/country_continents.csv" AS line

MERGE (c:Country {name: line.country})
MERGE (co:Continent {name: line.continent})
MERGE (c)-[:IN_CONTINENT]->(co);