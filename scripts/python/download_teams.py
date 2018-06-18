import csv
from multiprocessing.pool import ThreadPool
from time import time as timer
import os
import requests


def fetch_url(entry):
    filename, uri = entry
    path = "data/2018/teams/{0}".format(filename)

    if not os.path.exists(path):
        r = requests.get(uri, stream=True)
        if r.status_code == 200:
            with open(path, 'wb') as f:
                for chunk in r:
                    f.write(chunk)
    return path


def teams_uri(year, team_id):
    return "https://www.fifa.com/worldcup/archive/edition={0}/library/teams/team={1}/_players/_players_list.html" \
        .format(year, team_id)


with open("data/2018/teams.csv", "r") as teams_file:
    reader = csv.reader(teams_file, delimiter=",")
    next(reader)

    urls = [("{0}-{1}.html".format(row[0], row[1]), teams_uri(row[0], row[1])) for row in reader]

start = timer()
results = ThreadPool(8).imap_unordered(fetch_url, urls)
for path in results:
    print(path)
print("Elapsed Time: %s" % (timer() - start,))
