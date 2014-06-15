USING PERIODIC COMMIT 1000
//LOAD CSV WITH HEADERS FROM "https://dl.dropboxusercontent.com/u/7619809/matches.csv" AS csvLine
LOAD CSV WITH HEADERS FROM "file:/Users/markneedham/projects/neo4j-worldcup/data/import/events.csv" AS csvLine


MATCH (home)<-[:HOME_TEAM]-(match:Match {id: csvLine.match_id})-[:AWAY_TEAM]->(away)

MATCH (player:Player {name: csvLine.player})-[:IN_SQUAD]->(squad)<-[:NAMED_SQUAD]-(team)
MATCH (player)-[:STARTED|:SUBSTITUTE]->(stats)-[:IN_MATCH]->(match)

// penalties
FOREACH(n IN (CASE csvLine.type WHEN "penalty" THEN [1] else [] END) |
	FOREACH(t IN CASE WHEN team = home THEN [home] ELSE [away] END |
		MERGE (stats)-[:SCORED_PENALTY]->(penalty {time: csvLine.time})
		MERGE (penalty)-[:FOR]->(t)
	)		
)

// open play goal
FOREACH(n IN (CASE csvLine.type WHEN "goal" THEN [1] else [] END) |
	FOREACH(t IN CASE WHEN team = home THEN [home] ELSE [away] END |
		MERGE (stats)-[:SCORED_OPEN_PLAY_GOAL]->(goal {time: csvLine.time})
		MERGE (goal)-[:FOR]->(t)
	)		
)

// own goal
FOREACH(n IN (CASE csvLine.type WHEN "owngoal" THEN [1] else [] END) |
	FOREACH(t IN CASE WHEN team = home THEN [away] ELSE [home] END |
		MERGE (stats)-[:SCORED_OWN_GOAL]->(goal {time: csvLine.time})
		MERGE (goal)-[:FOR]->(t)
	)		
)

// yellow card
FOREACH(n IN (CASE csvLine.type WHEN "yellow" THEN [1] else [] END) |
	FOREACH(t IN CASE WHEN team = home THEN [home] ELSE [away] END |
		MERGE (stats)-[:BOOKED]->(yellow {time: csvLine.time})
		MERGE (yellow)-[:FOR]->(t)
	)		
)

// red card
FOREACH(n IN (CASE csvLine.type WHEN "red" THEN [1] else [] END) |
	FOREACH(t IN CASE WHEN team = home THEN [home] ELSE [away] END |
		MERGE (stats)-[:SENT_OFF]->(red {time: csvLine.time})
		MERGE (red)-[:FOR]->(t)
	)		
)

;