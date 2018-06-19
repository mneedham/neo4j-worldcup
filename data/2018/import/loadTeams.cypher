//LOAD CSV WITH HEADERS FROM "file:///worldcups.csv" AS csvLine
LOAD CSV WITH HEADERS FROM "https://github.com/mneedham/neo4j-worldcup/raw/master/data/2018/import/worldcups.csv" AS csvLine

MERGE (worldCup:WorldCup {year: toInteger(csvLine.year)})
SET worldCup.name = csvLine.name;

//LOAD CSV WITH HEADERS FROM "file:///teams.csv" AS csvLine
LOAD CSV WITH HEADERS FROM "https://github.com/mneedham/neo4j-worldcup/raw/master/data/2018/import/teams.csv" AS csvLine

MATCH (worldCup:WorldCup {year: toInteger(csvLine.year)})

MERGE (c:Country {id: toInteger(csvLine.teamId)})
ON CREATE SET c.name = csvLine.team

MERGE (squad:Squad {name: c.name + " Squad for " + csvLine.year })
SET squad.year = toInteger(csvLine.year)

MERGE (c)-[:NAMED_SQUAD]->(squad)-[:FOR_WORLD_CUP]->(worldCup);
