// Top scorer across all World Cups
MATCH (player)-[:STARTED|:SUBSTITUTE]->(stats)-[:SCORED_GOAL]->(goal),
      (stats)-[:IN_MATCH]->()<-[:CONTAINS_MATCH]-(wc:WorldCup)-[:IN_YEAR]->(year)
WHERE goal.type IN ["goal", "penalty"]
WITH  player.name AS player, COUNT(*) AS goals, COLLECT(DISTINCT year.year) AS competitions
UNWIND competitions AS competition 
WITH player, goals, competition ORDER BY player, goals, competition
RETURN player, goals, COLLECT(competition) AS competitions
ORDER BY goals DESC
LIMIT 20

// Matches that Jens Lehmann participated in
MATCH (p:Player {name: "Jens Lehmann"})-[r:STARTED|:SUBSTITUTE]->()-[:IN_MATCH]->()<-[:CONTAINS_MATCH]-(wc)
RETURN TYPE(r), COUNT(*), COLLECT(DISTINCT wc.name)

// Stadiums that hosted the most matches over all World Cups
MATCH (n:Stadium)<-[:PLAYED_IN_STADIUM]-()<-[:CONTAINS_MATCH]-(wc)-[:HOSTED_BY]-(host),
      (wc)-[:IN_YEAR]-(year)

WITH n, host, COUNT(*) as count, COLLECT(DISTINCT year.year) AS years
RETURN n.name, host.name, years, count
ORDER BY count DESC
LIMIT 5

// Stadiums that hosted the most matches over all World Cups with World Cups ordered by year ascending

MATCH (stadium:Stadium)<-[:PLAYED_IN_STADIUM]-()<-[:CONTAINS_MATCH]-(wc)-[:HOSTED_BY]-(host),
      (wc)-[:IN_YEAR]-(year)

WITH stadium, host, COUNT(*) as count, COLLECT(DISTINCT year.year) AS years

UNWIND years as year

WITH stadium, host, count, year
ORDER BY stadium.name, host.name, year 

RETURN stadium.name, host.name, COLLECT(year) AS years, count
ORDER BY count DESC
LIMIT 5

// Countries that hosted most world cups

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

// Hosts who reached the final

MATCH (phase:Phase {name: "Final"})<-[:IN_PHASE]-(match),
      (match)-[rel:HOME_TEAM|:AWAY_TEAM]-(host:Country)<-[:HOSTED_BY]-(worldCup),
      (worldCup)-[:CONTAINS_MATCH]->(match)
RETURN  host.name, match.description, worldCup.name

// Hosts who won the World Cup
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
MATCH (year:Year)<-[:IN_YEAR]-()<-[:FOR_WORLD_CUP]-(squad)<-[:IN_SQUAD]-(player), (country)-[:NAMED_SQUAD]->(squad)
WITH player, country, COLLECT(year.year) AS wcs, COUNT(*) AS times
WHERE times > 3

UNWIND wcs AS wc
WITH player, country, wc, times
ORDER BY times DESC, wc

RETURN player.name, times, COLLECT(wc), country.name
ORDER BY times DESC

// Queries from the London Hackathon - 18th June 2014

// Find teams that beat each other in the same world cups
MATCH (s:Squad) -[:BEAT]-> () -[:BEAT]-> (s)
RETURN s
