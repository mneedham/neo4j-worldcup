USING PERIODIC COMMIT 1000

//LOAD CSV WITH HEADERS FROM "file:///events.csv" AS csvLine
LOAD CSV WITH HEADERS FROM "https://github.com/mneedham/neo4j-worldcup/raw/master/data/2018/import/events.csv" AS csvLine

MATCH (match:Match {id: toInteger(csvLine.match_id)})
MATCH (player:Player {id: toInteger(csvLine.player_id)})
MATCH (player)-[:STARTED|:SUBSTITUTE]->(appearance)-[:IN_MATCH]->(match)

// goals
FOREACH(n IN (CASE WHEN csvLine.type IN ["penalty-shootout", "penalty", "goal", "owngoal"] THEN [1] else [] END) |
		MERGE (appearance)-[:SCORED_GOAL]->(penalty:Goal {time: csvLine.time, type: csvLine.type})
)

// cards
//FOREACH(n IN (CASE WHEN csvLine.type IN ["yellow", "red", "yellowred"] THEN [1] else [] END) |
//	FOREACH(t IN CASE WHEN team = home THEN [home] ELSE [away] END |
//		MERGE (stats)-[:RECEIVED_CARD]->(card {time: csvLine.time, type: csvLine.type})
//	)
//)
;