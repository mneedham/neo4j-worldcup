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