USING PERIODIC COMMIT 1000
LOAD CSV WITH HEADERS FROM "file:///lineups.csv" AS csvLine
MATCH (player:Player {id: toInteger(csvLine.player_id)})
MATCH (country:Country {id: toInteger(csvLine.team_id)})
MATCH (wc:WorldCup {year: toInteger(csvLine.year)})
MATCH (match:Match {id: toInteger(csvLine.match_id)})

MERGE (app:Appearance {name: player.id + " in match " + match.id})
MERGE (app)-[:IN_MATCH]->(match)
WITH player, app, csvLine
CALL apoc.merge.relationship(player, csvLine.type, {}, {},  app) YIELD rel
RETURN count(*);

//USING PERIODIC COMMIT 1000
////LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/mneedham/neo4j-worldcup/master/data/import/lineups.csv" AS csvLine
//LOAD CSV WITH HEADERS FROM "file:///lineups.csv" AS csvLine
//
//MATCH (home)<-[:HOME_TEAM]-(match:Match {id: csvLine.match_id})-[:AWAY_TEAM]->(away)
//MATCH (player:Player {id: csvLine.player_id})
//MATCH (wc:WorldCup {name: csvLine.world_cup})
//MATCH (wc)<-[:FOR_WORLD_CUP]-()<-[:IN_SQUAD]-(player)
//
//// home players
//FOREACH(n IN (CASE csvLine.team WHEN "home" THEN [1] else [] END) |
//	FOREACH(o IN (CASE csvLine.type WHEN "starting" THEN [1] else [] END) |
//		MERGE (match)-[:HOME_TEAM]->(home)
//		MERGE (player)-[:STARTED]->(stats)-[:IN_MATCH]->(match)
//	)
//
//	FOREACH(o IN (CASE csvLine.type WHEN "sub" THEN [1] else [] END) |
//		MERGE (match)-[:HOME_TEAM]->(home)
//		MERGE (player)-[:SUBSTITUTE]->(stats)-[:IN_MATCH]->(match)
//	)
//)
//
//// away players
//FOREACH(n IN (CASE csvLine.team WHEN "away" THEN [1] else [] END) |
//	FOREACH(o IN (CASE csvLine.type WHEN "starting" THEN [1] else [] END) |
//		MERGE (match)-[:AWAY_TEAM]->(away)
//		MERGE (player)-[:STARTED]->(stats)-[:IN_MATCH]->(match)
//	)
//
//	FOREACH(o IN (CASE csvLine.type WHEN "sub" THEN [1] else [] END) |
//		MERGE (match)-[:AWAY_TEAM]->(away)
//		MERGE (player)-[:SUBSTITUTE]->(stats)-[:IN_MATCH]->(match)
//	)
//)
//;