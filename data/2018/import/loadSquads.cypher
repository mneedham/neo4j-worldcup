USING PERIODIC COMMIT 1000
//LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/mneedham/neo4j-worldcup/master/data/import/squads.csv" AS csvLine
LOAD CSV WITH HEADERS FROM "file:///squads.csv" AS csvLine

MATCH (y:Year {year: toInteger(csvLine.year)})<-[:IN_YEAR]-(worldCup),
      (c:Country {id: toInteger(csvLine.teamId)})

MERGE (squad:Squad {name: c.name + " Squad for " + worldCup.name })
MERGE (c)-[:NAMED_SQUAD]->(squad)-[:FOR_WORLD_CUP]->(worldCup)

MERGE (p:Player {id: toInteger(csvLine.playerId)})
ON CREATE SET p.name = csvLine.playerName,
              p.position = csvLine.playerPosition,
              p.dob = CASE WHEN csvLine.playerDOB <> ""
                      THEN datetime(csvLine.playerDOB)
                      ELSE null
                      END

MERGE (p)-[:IN_SQUAD]->(squad);