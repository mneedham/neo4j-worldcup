import csv
import glob

import re
from bs4 import BeautifulSoup

with open("data/2018/import/lineups.csv", "w") as lineups_file:
    writer = csv.writer(lineups_file, delimiter=",")

    writer.writerow([
        "year", "match_id", "team_id", "type", "player_id"
    ])

    for match_file in glob.glob("data/2018/matches/*.html"):
        match_id = match_file.split("/")[-1].replace(".html", "")
        print(match_id)
        with open(match_file, "r") as file:
            soup = BeautifulSoup(file.read(), "html.parser")

            header = soup.select("div h1 a")[0].text
            groups = re.match("(\d{4}) FIFA World Cup (.*?)™", header)
            year = groups[1]

            teams = [team["data-team-id"] for team in soup.select("td.team-name div.t")]

            home_starters = soup.select("table.fielded tr td.home div.p-i-no")
            for player in home_starters:
                writer.writerow([
                    year, match_id, teams[0], "STARTED", player["data-player-id"]
                ])

            away_starters = soup.select("table.fielded tr td.away div.p-i-no")
            for player in away_starters:
                writer.writerow([
                    year, match_id, teams[1], "STARTED", player["data-player-id"]
                ])

            home_subs = soup.select("table.substitutes tr td.home div.p-i-no")
            for player in home_subs:
                writer.writerow([
                    year, match_id, teams[0], "SUBSTITUTE", player["data-player-id"]
                ])

            away_subs = soup.select("table.substitutes tr td.away div.p-i-no")
            for player in away_subs:
                writer.writerow([
                    year, match_id, teams[1], "SUBSTITUTE", player["data-player-id"]
                ])