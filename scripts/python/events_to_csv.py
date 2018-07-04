import csv
import glob
import json

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

            header_element = soup.select("div h1 a")

            if len(header_element) == 0:
                header_element = soup.select("div a h1")

            header = header_element[0].text
            groups = re.match("(\d{4}) FIFA World Cup ([a-zA-Z ]*)", header)
            year = int(groups[1])

            if year == 2018:
                with open("data/2018/matches/api/{0}.json".format(match_id)) as json_file:
                    the_json = json.loads(json_file.read())

                    for scorer in the_json["HomeTeam"]["Goals"]:
                        type = scorer["Type"]
                        event_time = scorer["Minute"]
                        event_type = "goal"
                        if type == 1:
                            event_type = "penalty"
                            if scorer["Period"] == 11:
                                event_type = "penalty-shootout"
                        if type == 3:
                            event_type = "owngoal"

                        player_id = scorer["IdPlayer"]

                        scoring_team_id = the_json["HomeTeam"]["IdTeam"]

                        values = [
                            match_id, player_id, event_time, event_type, scoring_team_id
                        ]

                        values = [str(value).strip() for value in values]
                        writer.writerow(values)

                    for scorer in the_json["AwayTeam"]["Goals"]:
                        type = scorer["Type"]
                        event_time = scorer["Minute"]
                        event_type = "goal"
                        if type == 1:
                            event_type = "penalty"
                            if scorer["Period"] == 11:
                                event_type = "penalty-shootout"
                        if type == 3:
                            event_type = "owngoal"

                        player_id = scorer["IdPlayer"]

                        scoring_team_id = the_json["AwayTeam"]["IdTeam"]

                        values = [
                            match_id, player_id, event_time, event_type, scoring_team_id
                        ]

                        values = [str(value).strip() for value in values]
                        writer.writerow(values)
            else:
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

                            values = [
                                match_id, player_id, event_time, event_type, scoring_team_id
                            ]
                            values = [str(value).strip() for value in values]
                            writer.writerow(values)

                        # events = soup.select("div.p-lu-info")
                        # for event in events:
                        #     yellow_cards = event.select("span.p-e span.yellow-card")
