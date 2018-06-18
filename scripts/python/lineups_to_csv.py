import csv
import glob
import json

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

            header_element = soup.select("div h1 a")

            if len(header_element) == 0:
                header_element = soup.select("div a h1")

            header = header_element[0].text
            groups = re.match("(\d{4}) FIFA World Cup ([a-zA-Z ]*)", header)
            year = int(groups[1])

            if year == 2018:
                with open("data/2018/matches/api/{0}.json".format(match_id)) as json_file:
                    the_json = json.loads(json_file.read())

                    home_team = the_json["HomeTeam"]
                    players = home_team["Players"]
                    for player in players:
                        type = "STARTED" if player["Status"] == 1 else "SUBSTITUTE"
                        writer.writerow([
                            year, match_id, home_team["IdTeam"], type, player["IdPlayer"]
                        ])

                    away_team = the_json["HomeTeam"]
                    players = away_team["Players"]
                    for player in players:
                        type = "STARTED" if player["Status"] == 1 else "SUBSTITUTE"
                        writer.writerow([
                            year, match_id, away_team["IdTeam"], type, player["IdPlayer"]
                        ])

            else:
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