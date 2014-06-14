// find the stadiums which hosted the most matches
MATCH (n:Stadium)<-[:PLAYED_IN_STADIUM]-()<-[:CONTAINS_MATCH]-(wc)-[:HOSTED_BY]-(host),
      (wc)-[:IN_YEAR]-(year)

WITH n, host, COUNT(*) as count, COLLECT(DISTINCT year.year) AS years
RETURN n.name, host.name, years, count
ORDER BY count DESC
LIMIT 5

// stadiums that hosted most matches with better ordering

MATCH (stadium:Stadium)<-[:PLAYED_IN_STADIUM]-()<-[:CONTAINS_MATCH]-(wc)-[:HOSTED_BY]-(host),
      (wc)-[:IN_YEAR]-(year)

WITH stadium, host, COUNT(*) as count, COLLECT(DISTINCT year.year) AS years

UNWIND years as year

WITH stadium, host, count, year
ORDER BY stadium.name, host.name, year 

RETURN stadium.name, host.name, COLLECT(year) AS years, count
ORDER BY count DESC
LIMIT 5

// country that hosted most world cups

MATCH (host:Country)<-[:HOSTED_BY]-()-[:IN_YEAR]->(year)

WITH host, COUNT(*) AS times, COLLECT(year.year) AS years
UNWIND years AS year

WITH host, times, year
ORDER BY times DESC, year

RETURN host.name, times, COLLECT(year) AS years
ORDER BY times DESC

// show the phases
MATCH (p:Phase)
RETURN p

// hosts who won

MATCH (phase:Phase {name: "Final"})<-[:IN_PHASE]-(match),
      (match)-[rel:HOME_TEAM|:AWAY_TEAM]-(host:Country)<-[:HOSTED_BY]-(worldCup),
      (worldCup)-[:CONTAINS_MATCH]->(match)
RETURN match, host

MATCH (phase:Phase {name: "Final"})<-[:IN_PHASE]-(match),
      (match)-[rel:HOME_TEAM|:AWAY_TEAM]->(host:Country)<-[:HOSTED_BY]-(worldCup),
      (worldCup)-[:CONTAINS_MATCH]->(match)

WITH match, host, worldCup,
     CASE WHEN TYPE(rel) = "HOME_TEAM" THEN match.h_score ELSE match.a_score END AS hostGoals,
     CASE WHEN TYPE(rel) = "HOME_TEAM" THEN match.a_score ELSE match.h_score END AS oppositionGoals
WHERE toInt(hostGoals) > toInt(oppositionGoals)

RETURN host.name, worldCup.name
