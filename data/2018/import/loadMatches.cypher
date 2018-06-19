USING PERIODIC COMMIT 1000
//LOAD CSV WITH HEADERS FROM "file:///matches.csv" AS csvLine
LOAD CSV WITH HEADERS FROM "https://github.com/mneedham/neo4j-worldcup/raw/master/data/2018/import/matches.csv" AS csvLine

WITH csvLine, apoc.text.regexGroups(csvLine.reasonWin, "\\((\\d) - (\\d)\\)")[0] AS reasonWin
WITH apoc.map.merge(csvLine,  { h_penalties: toInteger(reasonWin[1]), a_penalties: toInteger(reasonWin[2])}) AS csvLine

MATCH (worldCup:WorldCup {year: toInteger(csvLine.year)})

MERGE (match:Match {id: toInteger(csvLine.id)})
SET match.h_score = toInteger(csvLine.h_score),
    match.a_score = toInteger(csvLine.a_score),
    match.date = datetime({epochSeconds: apoc.date.parse(apoc.text.replace(csvLine.date, "Local time|-", ""), "s", "dd MMM yyyy HH:mm")}),
    match.description = csvLine.home + " vs. " + csvLine.away,
    match.round = csvLine.round

FOREACH(i IN CASE WHEN exists(csvLine.reasonWin) THEN [1] ELSE [] END |
	MERGE (match:Match {id: toInteger(csvLine.id)})
	SET match:ExtraTime
)

FOREACH(i IN CASE WHEN csvLine.reasonWin contains "penalties" THEN [1] ELSE [] END |
	MERGE (match:Match {id: toInteger(csvLine.id)})
	SET match:Penalties
)

WITH *

MATCH (home:Country {id: toInteger(csvLine.home_id)})
SET home.code = csvLine.home_code

WITH *

MERGE (match)-[:HOME_TEAM]->(home)
MERGE (match)<-[homePlayed:PLAYED_IN]-(home)
SET homePlayed.score = toInteger(csvLine.h_score),
    homePlayed.penalties = toInteger(csvLine.h_penalties)

WITH *

MATCH (away:Country {id: toInteger(csvLine.away_id)})
SET away.code = csvLine.away_code

WITH *

MERGE (match)-[:AWAY_TEAM]->(away)
MERGE (match)<-[awayPlayed:PLAYED_IN]-(away)
SET awayPlayed.score = toInteger(csvLine.a_score),
    awayPlayed.penalties = toInteger(csvLine.a_penalties)

MERGE (match)<-[:CONTAINS_MATCH]-(worldCup)

FOREACH(i IN CASE WHEN toInteger(csvLine.year) = 2002 THEN [1] ELSE [] END |
	MERGE (host1:Country {name: "Korea Republic"})
	MERGE (host2:Country {name: "Japan"})
	MERGE (host1)<-[:HOSTED_BY]-(worldCup)
	MERGE (host2)<-[:HOSTED_BY]-(worldCup))

FOREACH(i IN CASE WHEN toInteger(csvLine.year) <> 2002 THEN [1] ELSE [] END |
	MERGE (host:Country {name: csvLine.host})
	MERGE (host)<-[:HOSTED_BY]-(worldCup))

MERGE (stadium:Stadium {name: csvLine.stadium})
MERGE (match)-[:PLAYED_IN_STADIUM]->(stadium);
