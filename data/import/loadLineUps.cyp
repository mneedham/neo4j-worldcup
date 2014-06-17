USING PERIODIC COMMIT 1000
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/mneedham/neo4j-worldcup/master/data/import/lineups.csv" AS csvLine
//LOAD CSV WITH HEADERS FROM "file:/Users/markneedham/projects/neo4j-worldcup/data/import/lineups.csv" AS csvLine

MATCH (home)<-[:HOME_TEAM]-(match:Match {id: csvLine.match_id})-[:AWAY_TEAM]->(away)
MATCH (player:Player {id: csvLine.player_id})
MATCH (wc:WorldCup {name: csvLine.world_cup})
MATCH (wc)<-[:FOR_WORLD_CUP]-()<-[:IN_SQUAD]-(player)

// home players
FOREACH(n IN (CASE csvLine.team WHEN "home" THEN [1] else [] END) |
	FOREACH(o IN (CASE csvLine.type WHEN "starting" THEN [1] else [] END) |
		MERGE (match)-[:HOME_TEAM]->(home)
		MERGE (player)-[:STARTED]->(stats)-[:IN_MATCH]->(match)
	)

	FOREACH(o IN (CASE csvLine.type WHEN "sub" THEN [1] else [] END) |
		MERGE (match)-[:HOME_TEAM]->(home)
		MERGE (player)-[:SUBSTITUTE]->(stats)-[:IN_MATCH]->(match)
	)	
)

// away players
FOREACH(n IN (CASE csvLine.team WHEN "away" THEN [1] else [] END) |
	FOREACH(o IN (CASE csvLine.type WHEN "starting" THEN [1] else [] END) |
		MERGE (match)-[:AWAY_TEAM]->(away)
		MERGE (player)-[:STARTED]->(stats)-[:IN_MATCH]->(match)
	)

	FOREACH(o IN (CASE csvLine.type WHEN "sub" THEN [1] else [] END) |
		MERGE (match)-[:AWAY_TEAM]->(away)
		MERGE (player)-[:SUBSTITUTE]->(stats)-[:IN_MATCH]->(match)
	)	
)
;