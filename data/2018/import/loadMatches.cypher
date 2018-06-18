USING PERIODIC COMMIT 1000
//LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/mneedham/neo4j-worldcup/master/data/2018/import/matches.csv" AS csvLine
LOAD CSV WITH HEADERS FROM "file:///matches.csv" AS csvLine

MERGE (match:Match {id: toInteger(csvLine.id)})
SET match.h_score = toInteger(csvLine.h_score),
    match.a_score = toInteger(csvLine.a_score),
    match.date = datetime({epochSeconds: apoc.date.parse(apoc.text.replace(csvLine.date, "Local time|-", ""), "s", "dd MMM yyyy HH:mm")}),
    match.description = csvLine.home + " vs. " + csvLine.away,
    match.round = csvLine.round

MERGE (home:Country {id: toInteger(csvLine.home_id)})
ON CREATE SET home.name = csvLine.home, home.code = csvLine.home_code

MERGE (match)-[:HOME_TEAM]->(home)
MERGE (match)<-[:PLAYED_IN]-(home)

MERGE (away:Country {id: toInteger(csvLine.away_id)})
ON CREATE SET away.name = csvLine.away, away.code = csvLine.away_code

MERGE (match)-[:AWAY_TEAM]->(away)
MERGE (match)<-[:PLAYED_IN]-(away)

MERGE (year:Year {year: toInt(csvLine.year)})

MERGE (worldCup:WorldCup {name: csvLine.world_cup})
ON CREATE SET worldCup.year = toInteger(csvLine.year)

MERGE (match)<-[:CONTAINS_MATCH]-(worldCup)

FOREACH(i IN CASE WHEN csvLine.host = "Korea/Japan" THEN [1] ELSE [] END |
	MERGE (host1:Country {name: "Korea Republic"})
	MERGE (host2:Country {name: "Japan"})
	MERGE (host1)<-[:HOSTED_BY]-(worldCup)
	MERGE (host2)<-[:HOSTED_BY]-(worldCup))

FOREACH(i IN CASE WHEN csvLine.host <> "Korea/Japan" THEN [1] ELSE [] END |
	MERGE (host:Country {name: csvLine.host})
	MERGE (host)<-[:HOSTED_BY]-(worldCup))

MERGE (year)<-[:IN_YEAR]-(worldCup)

MERGE (stadium:Stadium {name: csvLine.stadium})
MERGE (match)-[:PLAYED_IN_STADIUM]->(stadium);
