LOAD CSV FROM "https://raw.githubusercontent.com/mneedham/neo4j-worldcup/master/data/country/country_codes.csv" as line FIELDTERMINATOR '\t'
MATCH (c:Country {name:ltrim(line[1])}) 
SET c.iocCode = line[0];

LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/mneedham/neo4j-worldcup/master/data/country/country-capitals.csv" as line
MATCH (c:Country {name:ltrim(line.CountryName)}) 
SET c.isoCode2 = line.CountryCode;


LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/mneedham/neo4j-worldcup/master/data/country/geonames_org_countryInfo.csv" as line FIELDTERMINATOR '\t'
MATCH (c:Country {name:ltrim(line.Country)}) 
SET c.isoCode2 = line.ISO, c.isoCode3 = line.ISO3,c.population = toInt(line.Population);

LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/mneedham/neo4j-worldcup/master/data/country/country_gdp_per_capita.csv" as line
MATCH (c:Country {name:ltrim(line.Country)}) 
SET c.gdbPerCapita = toInt(line.GDP);

LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/mneedham/neo4j-worldcup/master/data/country/country_gdp_per_capita.csv" as line
MATCH (c:Country {isoCode3:line.Code}) 
SET c.gdbPerCapita = toInt(line.GDP);
