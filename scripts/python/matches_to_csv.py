import csv
import glob
from bs4 import BeautifulSoup
import re

with open("data/2018/import/matches.csv", "w") as matches_file:
    writer = csv.writer(matches_file, delimiter=",")

    # "data/2018/matches/43950024.html"


    # world_cup, id, home, away, h_score, a_score, match_number, new_match_number, date, time, stadium, attendance, \
    # phase, year, host

    writer.writerow([
        "id",
        "home_id", "home", "home_code",
        "away_id", "away", "away_code",
        "h_score", "a_score",
        "date", "stadium",  "round",
        "world_cup",  "year", "host"
    ])

    for match_file in glob.glob("data/2018/matches/*.html"):
        print(match_file)
        match_id = match_file.split("/")[-1].replace(".html", "")
        with open(match_file, "r") as file:
            soup = BeautifulSoup(file.read(), "html.parser")

            header = soup.select("div h1 a")[0].text

            groups = re.match("(\d{4}) FIFA World Cup (.*?)™", header)
            year = groups[0]
            host = groups[1]
            world_cup = groups[2]

            home_element = soup.select("div.home")

            home_id = home_element[0]["data-team-id"]
            home = home_element[0].select("span.t-nText")[0].text
            home_code = home_element[0].select("span.t-nTri")[0].text

            away_element = soup.select("div.away")

            away_id = away_element[0]["data-team-id"]
            away = away_element[0].select("span.t-nText")[0].text
            away_code = away_element[0].select("span.t-nTri")[0].text

            round = soup.select("div.mh-i-round")[0].text

            if round == "Play-off for third place":
                round = "Match for third place"

            location_date_element = soup.select("div.mh-i-location-date")[0]
            stadium = location_date_element.select("span.mh-i-stadium")[0].text
            venue = location_date_element.select("span.mh-i-venue")[0].text

            date = soup.select("div.mh-i-datetime")[0].text

            h_score, a_score = soup.select("span.s-scoreText")[0].text.split("-")

            values = [
                match_id,
                home_id, home, home_code,
                away_id, away, away_code,
                h_score, a_score,
                date, stadium, round,
                world_cup, year, host
            ]
            values = [value.strip() if type(value) is str else value for value in values]
            writer.writerow(values)