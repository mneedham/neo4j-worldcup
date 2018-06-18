import requests
import csv
from bs4 import BeautifulSoup

world_cups = {
    2014: "https://www.fifa.com/worldcup/archive/brazil2014",
    2010: "https://www.fifa.com/worldcup/archive/southafrica2010",
    2006: "https://www.fifa.com/worldcup/archive/germany2006",
    2002: "https://www.fifa.com/worldcup/archive/koreajapan2002",
    1998: "https://www.fifa.com/worldcup/archive/france1998",
    1994: "https://www.fifa.com/worldcup/archive/usa1994",
    1990: "https://www.fifa.com/worldcup/archive/italy1990",
    1986: "https://www.fifa.com/worldcup/archive/mexico1986",
    1982: "https://www.fifa.com/worldcup/archive/spain1982",
    1978: "https://www.fifa.com/worldcup/archive/argentina1978",
    1974: "https://www.fifa.com/worldcup/archive/germany1974",
    1970: "https://www.fifa.com/worldcup/archive/mexico1970",
    1966: "https://www.fifa.com/worldcup/archive/england1966",
    1962: "https://www.fifa.com/worldcup/archive/chile1962",
    1958: "https://www.fifa.com/worldcup/archive/sweden1958",
    1954: "https://www.fifa.com/worldcup/archive/switzerland1954",
    1950: "https://www.fifa.com/worldcup/archive/brazil1950",
    1938: "https://www.fifa.com/worldcup/archive/france1938",
    1934: "https://www.fifa.com/worldcup/archive/italy1934",
    1930: "https://www.fifa.com/worldcup/archive/uruguay1930"
}

with open("data/2018/teams.csv", "w") as teams_file:
    writer = csv.writer(teams_file, delimiter=",")
    writer.writerow(["year", "teamId", "team", "link"])

    for year, download_link in list(world_cups.items()):
        print(year)
        r = requests.get("{0}/teams".format(download_link))

        soup = BeautifulSoup(r.text, "html.parser")
        teams = soup.select("div.team-qualifiedteams li")

        for team in teams:
            team_element = team.select("a")[0]

            values = [
                year,
                team_element["href"].split("/")[-2].replace("team=", ""),
                team_element.text,
                team_element["href"]
            ]

            values = [value.strip() if type(value) is str else value
                      for value in values]
            writer.writerow(values)
