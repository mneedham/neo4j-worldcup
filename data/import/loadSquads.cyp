USING PERIODIC COMMIT 1000
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/mneedham/neo4j-worldcup/master/data/import/squads.csv" AS csvLine
//LOAD CSV WITH HEADERS FROM "file:/Users/markneedham/projects/neo4j-worldcup/data/import/squads.csv" AS csvLine

MATCH (y:Year {year: toInt(csvLine.year)})<-[:IN_YEAR]-(worldCup),
      (c:Country {name: csvLine.country})

MERGE (c)-[:NAMED_SQUAD]->(squad)-[:FOR_WORLD_CUP]->(worldCup)

MERGE (p:Player {id: csvLine.player_id})
ON CREATE SET p.name = csvLine.player_name

MERGE (p)-[:IN_SQUAD]->(squad);