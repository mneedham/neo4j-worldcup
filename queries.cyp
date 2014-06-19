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

// Revenge is a dish best served cold
// Find how long it took for a team to gain revenge for an earlier defeat

MATCH (year1) <-[:IN_YEAR]- (cup:WorldCup) -[:NEXT*0..18]-> (nextcup:WorldCup) -[:IN_YEAR]-> (year2)
MATCH (country1:Country) -[:NAMED_SQUAD]-> (c1s1:Squad) -[:FOR_WORLD_CUP]-> (cup)
MATCH (country2:Country) -[:NAMED_SQUAD]-> (c2s1:Squad) -[:FOR_WORLD_CUP]-> (cup)
MATCH (country1) -[:NAMED_SQUAD]-> (c1s2:Squad) -[:FOR_WORLD_CUP]-> (nextcup)
MATCH (country2) -[:NAMED_SQUAD]-> (c2s2:Squad) -[:FOR_WORLD_CUP]-> (nextcup)
MATCH (c1s1) -[:BEAT]-> (c2s1)
MATCH (c2s2) -[:BEAT]-> (c1s2)
WITH year2.year - year1.year as wait, year1, year2, country1, country2
ORDER BY wait desc, year1.year, year2.year
 
RETURN "In " + year2.year + ", " + country2.name + " gained revenge over " + country1.name + " for beating them in " + year1.year + " after a wait of " + wait + " years" AS message

// Distance between Countries
MATCH (c1:Country)
MATCH (c2:Country)
WHERE c1 <> c2
WITH c1, c2, 2 * 6371 * asin(sqrt(haversin(radians(c1.lat - c2.lat))+ cos(radians(c1.lat))*
  cos(radians(c2.lat))* haversin(radians(c1.lon - c2.lon)))) AS dist
WHERE dist > 0
RETURN c1.name, c2.name, dist
ORDER BY dist
LIMIT 1000

// Unused squad members across World Cups
MATCH (a)-[:`IN_SQUAD`]->(b) 
WHERE not(a-[:SUBSTUTED|:STARTED]->()) 
RETURN b,count(a) 
order by count(a) desc

// Goals scored by English Players
match (s:Squad)--(player:Player)--()-[:SCORED_GOAL]->(g)
where s.name =~ "England.*"
return player.name, count(distinct g) as count
order by count desc
limit 10

// Average goals per match across all World Cups
match (wc:WorldCup)-->(m:Match)
optional match (m)<--()-[:SCORED_GOAL]->(g:Goal)
return wc.name, (count(distinct g) * 1.0 / count(distinct m)) as average
order by wc.name desc