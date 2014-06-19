LOAD CSV WITH HEADERS FROM "http://techslides.com/demos/country-capitals.csv" AS line
WITH line, CASE line.CountryName 
WHEN 'South Korea' THEN ['Korea Republic']
WHEN 'United Kingdom' THEN ['England', 'Scotland', 'Wales']
WHEN 'United States' THEN ['USA']
WHEN "Cote d'Ivoire" THEN ["Côte d'Ivoire"]
WHEN 'North Korea' THEN ['Korea DPR']
WHEN 'Serbia' THEN ['Serbia and Montenegro', 'Yugoslavia']
WHEN 'Japan' THEN ['Korea/Japan']
WHEN 'China' THEN ['China PR']
WHEN 'Ireland' THEN ['Republic of Ireland', 'Northern Ireland']
WHEN 'Russia' THEN ['Soviet Union']
WHEN 'Germany' THEN ['Germany FR', 'German DR']
WHEN 'Czech Republic' THEN ['Czechoslovakia']
WHEN 'Republic of Congo' THEN ['Zaire']
WHEN 'Indonesia' THEN ['Dutch East Indies']
END as countryNames
MATCH (country:Country)
WHERE country.name IN countryNames OR country.name = line.CountryName
SET country.lon = line.CapitalLongitude
SET country.lat = line.CapitalLatitude
RETURN count(country);