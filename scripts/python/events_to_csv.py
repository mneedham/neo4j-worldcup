import csv
import glob
from bs4 import BeautifulSoup
import re

with open("data/2018/import/events.csv", "w") as matches_file:
    writer = csv.writer(matches_file, delimiter=",")

    writer.writerow([
        "match_id", "player_id", "time", "type", "scoring_team_id"
    ])

    for match_file in glob.glob("data/2018/matches/*.html"):
        print(match_file)
        match_id = match_file.split("/")[-1].replace(".html", "")
        with open(match_file, "r") as file:
            soup = BeautifulSoup(file.read(), "html.parser")

            scorers_teams = soup.select("ul.mh-l-scorers")

            for scoring_team in scorers_teams:
                scoring_team_id = scoring_team["data-team-id"]
                scorers = scoring_team.select("li.mh-scorer")
                for scorer in scorers:
                    scorer_element = scorer.select("div.p-i-no")[0]
                    player_id = scorer_element["data-player-id"]
                    events = scorer.select("span.ml-scorer-evmin span")
                    for event in events:
                        event_time = event.text.replace(",", "")

                        event_type = "goal"
                        if "PEN" in event_time:
                            event_type = "penalty"
                        if "OG" in event_time:
                            event_type = "owngoal"

                        event_time = event_time.replace("OG", "").replace("PEN", "").strip()

                        # print(player_id, scoring_team_id, event_time, event_type)

                        values = [
                            match_id, player_id, event_time, event_type, scoring_team_id
                        ]
                        values = [value.strip() if type(value) is str else value for value in values]
                        writer.writerow(values)
