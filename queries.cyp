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

// England squad in 1966

MATCH (c:Country {name: "England"})-[:NAMED_SQUAD]->(squad),
      (squad)-[:FOR_WORLD_CUP]->(worldCup)-[:IN_YEAR]->(year {year: 1966}),
      (squad)<-[:IN_SQUAD]-(player)
RETURN c, squad, year, worldCup, player

// Squad sizes over the years

MATCH (c:Country)-[:NAMED_SQUAD]->(squad),
      (squad)-[:FOR_WORLD_CUP]->(worldCup)-[:IN_YEAR]-(year),
      (squad)<-[:IN_SQUAD]-(player)
WITH c.name AS country, worldCup.name AS worldCup, COUNT(*) as squadSize, year
ORDER BY year.year
RETURN country, worldCup, squadSize

// Players named in more than 2 World Cup Squads
MATCH (year)<-[:IN_YEAR]-()<-[:FOR_WORLD_CUP]-(squad)<-[:IN_SQUAD]-(player), (country)-[:NAMED_SQUAD]->(squad)
WITH player, country, COLLECT(year.year) AS wcs, COUNT(*) AS times
WHERE times > 2

UNWIND wcs AS wc
WITH player, country, wc, times
ORDER BY times DESC, wc

RETURN player.name, times, COLLECT(wc), country.name
ORDER BY times DESC