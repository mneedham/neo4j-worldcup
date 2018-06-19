USING PERIODIC COMMIT 1000

//LOAD CSV WITH HEADERS FROM "file:///lineups.csv" AS csvLine
LOAD CSV WITH HEADERS FROM "https://github.com/mneedham/neo4j-worldcup/raw/master/data/2018/import/lineups.csv" AS csvLine


MATCH (player:Player {id: toInteger(csvLine.player_id)})
MATCH (match:Match {id: toInteger(csvLine.match_id)})

MERGE (app:Appearance {name: player.id + " in match " + match.id})
MERGE (app)-[:IN_MATCH]->(match)
WITH player, app, csvLine
CALL apoc.merge.relationship(player, csvLine.type, {}, {},  app) YIELD rel
RETURN count(*);
