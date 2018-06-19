USING PERIODIC COMMIT 1000

//LOAD CSV WITH HEADERS FROM "file:///squads.csv" AS csvLine
LOAD CSV WITH HEADERS FROM "https://github.com/mneedham/neo4j-worldcup/raw/master/data/2018/import/squads.csv" AS csvLine

MATCH (worldCup:WorldCup {year: toInteger(csvLine.year)}),
      (c:Country {id: toInteger(csvLine.teamId)})

MATCH (squad:Squad {name: c.name + " Squad for " + worldCup.year })

MATCH (c)-[:NAMED_SQUAD]->(squad)-[:FOR_WORLD_CUP]->(worldCup)

MERGE (p:Player {id: toInteger(csvLine.playerId)})
ON CREATE SET p.name = csvLine.playerName,
              p.position = csvLine.playerPosition,
              p.dob = CASE WHEN csvLine.playerDOB <> ""
                      THEN datetime(csvLine.playerDOB)
                      ELSE null
                      END

MERGE (p)-[:IN_SQUAD]->(squad);