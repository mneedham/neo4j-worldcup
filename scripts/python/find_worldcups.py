import re
import requests
import csv
from bs4 import BeautifulSoup

world_cups = {
    2018: "https://www.fifa.com/worldcup",
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

with open("data/2018/import/worldcups.csv", "w") as teams_file:
    writer = csv.writer(teams_file, delimiter=",")
    writer.writerow(["year", "name", "host"])

    for year, download_link in list(world_cups.items()):
        print(year)
        r = requests.get(download_link)

        soup = BeautifulSoup(r.text, "html.parser")

        header_element = soup.select("div h1 a")

        if len(header_element) == 0:
            header_element = soup.select("div a h1")

        header = header_element[0].text
        groups = re.match("(\d{4}) FIFA World Cup ([a-zA-Z ]*)", header)
        world_cup = groups[0]
        year = groups[1]
        host = groups[2]

        if year == "1974":
            host = "Germany FR"

        values = [year, world_cup, host]
        values = [value.strip() if type(value) is str else value for value in values]

        writer.writerow(values)
