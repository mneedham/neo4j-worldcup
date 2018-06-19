import csv
import glob
from bs4 import BeautifulSoup

position_mapping = {
    "Goalkeeper": "g",
    "Defender": "d",
    "Midfielder": "m",
    "Forward": "f"
}

with open("data/2018/import/squads.csv", "w") as squads_file:
    writer = csv.writer(squads_file, delimiter=",")
    writer.writerow(["year", "teamId", "playerId", "playerName", "playerPosition", "playerDOB"])

    for team_file in glob.glob("data/2018/teams/*.html"):
        with open(team_file, "r") as file:
            year, team_id = team_file.split("/")[-1].replace(".html", "").split("-")
            # print(year, team_id, team_file)

            soup = BeautifulSoup(file.read(), "html.parser")

            if int(year) == 2018 and int(team_id) in [43962, 43965]:
                players = soup.select("div.fi-team__members a.fi-p--link")
                for player in players:
                    id = player["href"].split("/")[-2]
                    name = player.select("a")[0]["title"]
                    position = player.select("div.fi-p__info--role")[0].text.strip()
                    if position != "Coach":
                        writer.writerow([year, team_id, id, name, position_mapping[position], ""])
            else:
                players = soup.select("div.p-i-no")

                if len(players) == 0:
                    players = soup.select("div.p-i-prt-1")

                for player in players:
                    id = player["data-player-id"]
                    name = player["data-player-name"]
                    position = player.get("data-player-role", "")
                    dob = player.select("div.p-ag span")[0]["data-birthdate"]

                    if not position == "0":
                        writer.writerow([year, team_id, id, name.title(), position, dob])
