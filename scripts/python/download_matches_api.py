import csv
import os
from multiprocessing.pool import ThreadPool
from time import time as timer

import requests


def fetch_url(entry):
    filename, uri = entry
    path = "data/2018/matches/{0}".format(filename)

    if not os.path.exists(path):
        r = requests.get(uri, stream=True)
        if r.status_code == 200:
            with open(path, 'wb') as f:
                for chunk in r:
                    f.write(chunk)
    return path


def matches_uri(end_of_uri):
    return "https://www.fifa.com{0}".format(end_of_uri)


with open("data/2018/matches.csv", "r") as teams_file:
    reader = csv.reader(teams_file, delimiter=",")
    next(reader)

    urls = []
    for row in reader:

        if int(row[0]) == 2018:
            match_id = row[1].split("/")[-2].replace("match=", "")
            api_uri = "https://api.fifa.com/api/v1/live/football/17/254645/275073/{0}".format(match_id)
            urls.append(("api/{0}.json".format(match_id), api_uri))



start = timer()
results = ThreadPool(8).imap_unordered(fetch_url, urls)
for path in results:
    print(path)
print("Elapsed Time: %s" % (timer() - start,))
