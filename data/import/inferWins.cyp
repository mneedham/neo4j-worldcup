MATCH (away)<-[:AWAY_TEAM]-(match:Match)-[:HOME_TEAM]->(home)
MATCH (match)<-[:CONTAINS_MATCH]-(worldCup)
MATCH (worldCup)<-[:FOR_WORLD_CUP]-(homeSquad)<-[:NAMED_SQUAD]-(home),
      (worldCup)<-[:FOR_WORLD_CUP]-(awaySquad)<-[:NAMED_SQUAD]-(away)

FOREACH(n IN (CASE WHEN toInt(match.h_score) > toInt(match.a_score) THEN [1] else [] END) |
	MERGE (homeSquad)-[:BEAT {score: match.h_score + "-" + match.a_score}]->(awaySquad)
)

FOREACH(n IN (CASE WHEN toInt(match.a_score) > toInt(match.h_score) THEN [1] else [] END) |
	MERGE (awaySquad)-[:BEAT {score: match.a_score + "-" + match.h_score}]->(homeSquad)
);
