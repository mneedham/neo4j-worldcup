// Top scorer across all World Cups
MATCH (player)-->(stats)-[:SCORED_GOAL]->(goal),
      (stats)-[:IN_MATCH]->()<-[:CONTAINS_MATCH]-(wc:WorldCup)
WHERE goal.type IN ["goal", "penalty"]
WITH  player.name AS player, count(*) AS goals, collect(DISTINCT wc.year) AS competitions
UNWIND competitions AS competition
WITH player, goals, competition ORDER BY player, goals, competition
RETURN player, goals, collect(competition) AS competitions
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

MATCH (stadium:Stadium)<-[:PLAYED_IN_STADIUM]-()<-[:CONTAINS_MATCH]-(wc)-[:HOSTED_BY]-(host)

WITH stadium, host, COUNT(*) as count, COLLECT(DISTINCT wc.year) AS years

UNWIND years as year

WITH stadium, host, count, year
ORDER BY stadium.name, host.name, year 

RETURN stadium.name, host.name, COLLECT(year) AS years, count
ORDER BY count DESC
LIMIT 5;

// Countries that hosted most world cups

MATCH (host:Country)<-[:HOSTED_BY]-(wc)

WITH host, COUNT(*) AS times, COLLECT(wc.year) AS years
UNWIND years AS year

WITH host, times, year
ORDER BY times DESC, year

RETURN host.name, times, COLLECT(year) AS years
ORDER BY times DESC;

// Hosts who reached the final

MATCH (match:Match {round: "Final"})<-[:PLAYED_IN]-(host:Country)<-[:HOSTED_BY]-(worldCup),
      (worldCup)-[:CONTAINS_MATCH]->(match)
RETURN  host.name, match.description, worldCup.name;

// Hosts who won the World Cup
MATCH (match:Match {round: "Final"})-[rel:HOME_TEAM|:AWAY_TEAM]->(host:Country)<-[:HOSTED_BY]-(worldCup),
      (worldCup)-[:CONTAINS_MATCH]->(match)

WITH match, host, worldCup,
     CASE WHEN TYPE(rel) = "HOME_TEAM" THEN match.h_score ELSE match.a_score END AS hostGoals,
     CASE WHEN TYPE(rel) = "HOME_TEAM" THEN match.a_score ELSE match.h_score END AS oppositionGoals
WHERE toInt(hostGoals) > toInt(oppositionGoals)

RETURN host.name, worldCup.name;

// England squad in 1966

MATCH (c:Country {name: "England"})-[:NAMED_SQUAD]->(squad),
      (squad)-[:FOR_WORLD_CUP]->(worldCup:WorldCup {year: 1966}),
      (squad)<-[:IN_SQUAD]-(player)
RETURN player.name, player.dob;

// Squad sizes over the years

MATCH (c:Country)-[:NAMED_SQUAD]->(squad),
      (squad)-[:FOR_WORLD_CUP]->(wc),
      (squad)<-[:IN_SQUAD]-(player)
WITH c.name AS country, wc.name AS worldCup, COUNT(*) as squadSize, wc.year AS year
ORDER BY year
RETURN country, worldCup, squadSize;

// Players named in more than 2 World Cup Squads
MATCH (wc)<-[:FOR_WORLD_CUP]-(squad)<-[:IN_SQUAD]-(player), (country)-[:NAMED_SQUAD]->(squad)
WITH player, country, collect(wc.year) AS wcs, COUNT(*) AS times
WHERE times > 3

UNWIND wcs AS wc
WITH player, country, wc, times
ORDER BY times DESC, wc

RETURN player.name, times, collect(wc), country.name
ORDER BY times DESC;

// Queries from the London Hackathon - 18th June 2014

// Find teams that beat each other in the same world cups
MATCH (s:Squad) -[:BEAT]-> () -[:BEAT]-> (s)
RETURN s;

// Revenge is a dish best served cold
// Find how long it took for a team to gain revenge for an earlier defeat

MATCH (year1) <-[:IN_YEAR]- (cup:WorldCup) -[:NEXT*0..18]-> (nextcup:WorldCup) -[:IN_YEAR]-> (year2)
MATCH (country1:Country) -[:NAMED_SQUAD]-> (c1s1) -[:FOR_WORLD_CUP]-> (cup)
MATCH (country2:Country) -[:NAMED_SQUAD]-> (c2s1) -[:FOR_WORLD_CUP]-> (cup)
MATCH (country1) -[:NAMED_SQUAD]-> (c1s2) -[:FOR_WORLD_CUP]-> (nextcup)
MATCH (country2) -[:NAMED_SQUAD]-> (c2s2) -[:FOR_WORLD_CUP]-> (nextcup)
MATCH (c1s1) -[:BEAT]-> (c2s1)
MATCH (c2s2) -[:BEAT]-> (c1s2)
WITH year2.year - year1.year as wait, year1, year2, country1, country2
ORDER BY wait desc, year1.year, year2.year

WITH year2, country2, country1, wait
ORDER BY wait 

WITH year2, country2, country1, COLLECT(wait) AS smallestWait

RETURN year2.year, country2.name, country1.name, smallestWait

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


// Bitter rivals search
// Attempt to location countries who have both hosted worldcups and who are less than 500 miles apart
MATCH (c1:Country), (c2:Country)
WHERE c1 <> c2 AND (c1:Country)<-[:HOSTED_BY]-(:WorldCup) AND (c2:Country)<-[:HOSTED_BY]-(:WorldCup)
WITH c1, c2, 2 * 6371 * asin(sqrt(haversin(radians(c1.lat - c2.lat))+ cos(radians(c1.lat))*
  cos(radians(c2.lat))* haversin(radians(c1.lon - c2.lon)))) AS dist
WHERE dist < 500
RETURN c1.name, c2.name, dist
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

// All stadiums that germany ever played in

MATCH (stadium:Stadium)<-[:PLAYED_IN_STADIUM]-(m)<-[:PLAYED_IN] -(Country)
WHERE Country.name="Germany"
return stadium, Country.name, Count(*)
order by Count(*) DESC

// Average size of squad per team per year 

MATCH (player:Player) - [:IN_SQUAD]- (squad:Squad) - [:FOR_WORLD_CUP] -(wc) - [:IN_YEAR] - (year:Year),
(country:Country)-[:NAMED_SQUAD]->(squad)
with squad, wc, country, year, count(*) as count_player

return year, avg(count_player)
order by year.year DESC
limit 30

// Top scorer by country

match (c:Country)-[:NAMED_SQUAD]->(s:Squad)--(player:Player)--()-[:SCORED_GOAL]->(g)
WITH c, player, count(distinct g) AS goals
WITH c, COLLECT({player:player.name, count: goals}) AS playersGoals

UNWIND playersGoals as playerGoals

WITH c, playerGoals
ORDER BY c.name, playerGoals.count DESC

WITH c, COLLECT(playerGoals)[0] AS topScorer
RETURN c.name, topScorer.player, topScorer.count
ORDER BY topScorer.count DESC

// Teams that went through a World Cup without losing a match (excluding penalties)
match (c:Country)<-[r:HOME_TEAM|:AWAY_TEAM]-(match)<-[:CONTAINS_MATCH]-(worldCup)-[:IN_YEAR]->(year)

WITH c, year,
     CASE WHEN TYPE(r) = "HOME_TEAM" THEN toInt(match.h_score) ELSE toInt(match.a_score) END AS goals,
     CASE WHEN TYPE(r) = "HOME_TEAM" THEN toInt(match.a_score) ELSE toInt(match.h_score) END AS oppositionGoals

WITH c, year, [result IN COLLECT({us: goals, them: oppositionGoals}) 
WHERE result.us < result.them] AS defeats

WITH c, year, defeats WHERE LENGTH(defeats) = 0
WITH c, COLLECT(year.year) AS times
RETURN c.name, times, LENGTH(times)
ORDER BY LENGTH(times) DESC

// World Cup winners who reached the final the next time around

MATCH (phase:Phase {name: "Final"})<-[:IN_PHASE]-(match),
      (match)-[rel:HOME_TEAM|:AWAY_TEAM]->(team:Country)

WITH match, team, worldCup,
     CASE WHEN TYPE(rel) = "HOME_TEAM" THEN match.h_score ELSE match.a_score END AS hostGoals,
     CASE WHEN TYPE(rel) = "HOME_TEAM" THEN match.a_score ELSE match.h_score END AS oppositionGoals
WHERE toInt(hostGoals) > toInt(oppositionGoals)
RETURN team

// Teams that played each other in more than one final
MATCH (phase:Phase {name:"Final"})<-[:IN_PHASE]-(match)<-[:CONTAINS_MATCH]-(cup)
MATCH (country)-[:PLAYED_IN]->(match)
WITH match,country,cup ORDER BY match.id,country.name
WITH match,collect(country) as countries,cup
WITH distinct countries,[ wc in collect(cup) | wc.name] as worldcup WHERE length(worldcup) > 1
RETURN [c in countries | c.name] AS finalists, worldcup

// Stadiums with the most goals
match (s:Stadium)<-[:PLAYED_IN_STADIUM]-(m)<-[:CONTAINS_MATCH]-(wc)
WITH s, COLLECT(DISTINCT wc.year) AS worldCups, COLLECT(toInt(m.h_score) +  toInt(m.a_score)) AS goals
RETURN s.name, worldCups,  REDUCE(acc=0, g IN goals | acc + g) as totalGoals
ORDER BY totalGoals DESC

// World Cup Finals by continent
MATCH (wc:WorldCup)-[:HOSTED_BY]->(host)-[:IN_CONTINENT]->(hostCont)
MATCH (phase:Phase {name: "Final"})<-[:IN_PHASE]-(match),
      (match)<-[rel:PLAYED_IN]-(team:Country)-[:IN_CONTINENT]->(cont),
      (match)<-[:CONTAINS_MATCH]-(wc)-[:IN_YEAR]->(year)

return year.year, collect(team.name), host.name, hostCont.name AS hostContinent, collect(cont.name) AS continentsInFinal
ORDER BY year.year