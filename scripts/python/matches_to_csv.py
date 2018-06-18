import csv
import glob
from bs4 import BeautifulSoup
import re

with open("data/2018/import/matches.csv", "w") as matches_file:
    writer = csv.writer(matches_file, delimiter=",")

    writer.writerow([
        "id",
        "home_id", "home", "home_code",
        "away_id", "away", "away_code",
        "h_score", "a_score",
        "date", "stadium", "round",
        "world_cup", "year", "host",
        "reasonWin"
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
            world_cup = groups[0]
            year = int(groups[1])
            host = groups[2]

            if year == "1974":
                host = "Germany FR"

            home_element = soup.select("div.home")
            home_id = home_element[0]["data-team-id"]

            team_selector = "span.fi-t__nText" if year == 2018 else "span.t-nText"
            code_selector = "span.fi-t__nTri" if year == 2018 else "span.t-nTri"

            home = home_element[0].select(team_selector)[0].text
            home_code = home_element[0].select(code_selector)[0].text

            away_element = soup.select("div.away")

            away_id = away_element[0]["data-team-id"]
            away = away_element[0].select(team_selector)[0].text
            away_code = away_element[0].select(code_selector)[0].text

            round_selector = "span.fi__info__group" if year == 2018 else "div.mh-i-round"

            round = soup.select(round_selector)[0].text

            if round == "Play-off for third place":
                round = "Match for third place"

            location_date_element_selector = "div.fi__info__location" \
                if year == 2018 else "div.mh-i-location-date"
            location_date_element = soup.select(location_date_element_selector)[0]

            stadium_selector = "span.fi__info__stadium" if year == 2018 else "span.mh-i-stadium"

            stadium = location_date_element.select(stadium_selector)[0].text

            venue_selector = "span.fi__info__venue" if year == 2018 else "span.mh-i-venue"
            venue = location_date_element.select(venue_selector)[0].text

            date_selector = "div.fi-mu__info__datetime" if year == 2018 else "div.mh-i-datetime"
            date = soup.select(date_selector)[0].text.replace('\n', '')

            score_selector = "span.fi-s__scoreText" if year == 2018 else "span.s-scoreText"
            score = soup.select(score_selector)[0].text.split("-")

            h_score = a_score = ""
            if len(score) == 2:
                h_score, a_score = score

            if year == 2018:
                reasons_selector = "div.fi-mu__details div.fi-mu__reasonwin-wrap div.fi-mu__reasonwin"
                reason_win_elements = [
                    element
                    for element in soup.select(reasons_selector)
                    if not "hidden" in element.find_parent()["class"]
                ]

                if len(reason_win_elements) > 0:
                    reason_win = reason_win_elements[0].text
            else:
                reason_win_selector = "div.mu-reasonwin span.text-reasonwin"
                reason_win = soup.select(reason_win_selector)[0].text

            values = [
                match_id,
                home_id, home, home_code,
                away_id, away, away_code,
                h_score, a_score,
                date, stadium, round,
                world_cup, year, host,
                reason_win
            ]
            values = [value.strip() if type(value) is str else value for value in values]
            writer.writerow(values)
