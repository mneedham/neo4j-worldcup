import requests
import csv
from bs4 import BeautifulSoup

world_cups = {
	2014:  "https://www.fifa.com/worldcup/archive/brazil2014/matches/",
	2010 : "https://www.fifa.com/worldcup/archive/southafrica2010/matches/",
	2006 : "https://www.fifa.com/worldcup/archive/germany2006/matches",
	2002 : "https://www.fifa.com/worldcup/archive/koreajapan2002/matches",
	1998 : "https://www.fifa.com/worldcup/archive/france1998/matches",
	1994 : "https://www.fifa.com/worldcup/archive/usa1994/matches",
	1990 : "https://www.fifa.com/worldcup/archive/italy1990/matches",
	1986 : "https://www.fifa.com/worldcup/archive/mexico1986/matches",
	1982 : "https://www.fifa.com/worldcup/archive/spain1982/matches",
	1978 : "https://www.fifa.com/worldcup/archive/argentina1978/matches",
	1974 : "https://www.fifa.com/worldcup/archive/germany1974/matches",
	1970 : "https://www.fifa.com/worldcup/archive/mexico1970/matches",
	1966 : "https://www.fifa.com/worldcup/archive/england1966/matches",
	1962 : "https://www.fifa.com/worldcup/archive/chile1962/matches",
	1958 : "https://www.fifa.com/worldcup/archive/sweden1958/matches",
	1954 : "https://www.fifa.com/worldcup/archive/switzerland1954/matches",
	1950 : "https://www.fifa.com/worldcup/archive/brazil1950/matches",
	1938 : "https://www.fifa.com/worldcup/archive/france1938/matches",
	1934 : "https://www.fifa.com/worldcup/archive/italy1934/matches",
	1930 : "https://www.fifa.com/worldcup/archive/uruguay1930/matches"
}

with open("data/2018/matches.csv", "w") as matches_file:
	writer = csv.writer(matches_file, delimiter=",")
	writer.writerow(["year", "matchNumber", "venue", "home", "homeCode", "homeId", "away", "awayCode", "awayId", "link", "result"])

	for year, download_link in list(world_cups.items()):
		print(year)
		r = requests.get(download_link)

		soup = BeautifulSoup(r.text, "html.parser")
		matches = soup.select("div.match-list div.result")

		for match in matches:
			match_number = match.select(".mu-i-matchnum")[0].text
			venue = match.select(".mu-i-venue")[0].text
			home = match.select(".home .t-nText")[0].text
			home_code = match.select(".home .t-nTri")[0].text
			home_id = match.select(".home")[0]["data-team-id"]
			away = match.select(".away .t-nText")[0].text
			away_code = match.select(".away .t-nTri")[0].text
			away_id = match.select(".away")[0]["data-team-id"]
			link =  match.select("a.mu-m-link")[0]["href"]
			result = match.select('.s-scoreText')[0].text

			values = [
				year,
				match_number, venue,
				home, home_code, home_id,
				away, away_code, away_id,
				link, result
			]

			values = [value.strip() if type(value) is str else value for value in values]
			writer.writerow(values)
