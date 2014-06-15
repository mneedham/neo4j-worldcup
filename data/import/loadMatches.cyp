USING PERIODIC COMMIT 1000
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/mneedham/neo4j-worldcup/master/data/import/matches.csv" AS csvLine
//LOAD CSV WITH HEADERS FROM "file:/Users/markneedham/projects/neo4j-worldcup/data/import/matches.csv" AS csvLine

WITH csvLine, toInt(csvLine.match_number) AS matchNumber 

WITH csvLine, 
     CASE WHEN csvLine.phase = ""
     THEN
     	CASE WHEN matchNumber <= 48 THEN "Group matches"
     	     WHEN matchNumber > 48 AND matchNumber <= 56 THEN "Round of 16"
     	     WHEN matchNumber > 56 AND matchNumber <= 60 THEN "Quarter-finals"
     	     WHEN matchNumber > 60 AND matchNumber <= 62 THEN "Semi-finals"
     	     WHEN matchNumber = 63 THEN "Third place"
     		 ELSE "Final"
     	END
     ELSE
     	csvLine.phase
	END AS phase, matchNumber

MERGE (match:Match {id: csvLine.id})
SET match.h_score = csvLine.h_score,
    match.a_score = csvLine.a_score,
    match.attendance = csvLine.attendance,
    match.date = csvLine.date,
    match.description = csvLine.home + " vs. " + csvLine.away

MERGE (host:Country {name: csvLine.host})

MERGE (home:Country {name: csvLine.home})
MERGE (match)-[:HOME_TEAM]->(home)

MERGE (away:Country {name: csvLine.away})
MERGE (match)-[:AWAY_TEAM]->(away)

MERGE (year:Year {year: toInt(csvLine.year)})

MERGE (worldCup:WorldCup {name: csvLine.world_cup})
MERGE (match)<-[:CONTAINS_MATCH]-(worldCup)
MERGE (host)<-[:HOSTED_BY]-(worldCup)
MERGE (year)<-[:IN_YEAR]-(worldCup)

MERGE (stadium:Stadium {name: csvLine.stadium})
MERGE (match)-[:PLAYED_IN_STADIUM]->(stadium)

MERGE (p:Phase {name: phase})
MERGE (match)-[:IN_PHASE]->(p)

MERGE (mn:MatchNumber {value: matchNumber})
MERGE (match)-[:HAS_MATCH_NUMBER]->(mn)

MERGE (time:Time {time: csvLine.time})
MERGE (match)-[:PLAYED_AT_TIME]->(time);