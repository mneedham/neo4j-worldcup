MATCH (cup:WorldCup) -[:IN_YEAR]-> (year)
WITH cup, year
ORDER BY year.year

WITH COLLECT(cup) AS cups

FOREACH(i in RANGE(0, length(cups)-2) | FOREACH(cup1 in [cups[i]] |  FOREACH(cup2 in [cups[i+1]] | 
  CREATE UNIQUE (cup1)-[:NEXT]->(cup2))));