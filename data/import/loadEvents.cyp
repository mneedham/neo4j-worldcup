USING PERIODIC COMMIT 1000
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/mneedham/neo4j-worldcup/master/data/import/events.csv" AS csvLine
//LOAD CSV WITH HEADERS FROM "file:/Users/markneedham/projects/neo4j-worldcup/data/import/events.csv" AS csvLine

MATCH (home)<-[:HOME_TEAM]-(match:Match {id: csvLine.match_id})-[:AWAY_TEAM]->(away)

MATCH (player:Player {id: csvLine.player_id})-[:IN_SQUAD]->(squad)<-[:NAMED_SQUAD]-(team)
MATCH (player)-[:STARTED|:SUBSTITUTE]->(stats)-[:IN_MATCH]->(match)

// goals
FOREACH(n IN (CASE WHEN csvLine.type IN ["penalty", "goal", "owngoal"] THEN [1] else [] END) |
	FOREACH(t IN CASE WHEN team = home THEN [home] ELSE [away] END |
		MERGE (stats)-[:SCORED_GOAL]->(penalty:Goal {time: csvLine.time, type: csvLine.type})
	)		
)

// cards
FOREACH(n IN (CASE WHEN csvLine.type IN ["yellow", "red", "yellowred"] THEN [1] else [] END) |
	FOREACH(t IN CASE WHEN team = home THEN [home] ELSE [away] END |
		MERGE (stats)-[:RECEIVED_CARD]->(card {time: csvLine.time, type: csvLine.type})
	)		
)
;