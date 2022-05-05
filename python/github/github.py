import requests
from pprint import pprint

owner = "slaclab"
repo = "atlas-rd53-atca-dev"
query_url = f"https://api.github.com/repos/{owner}/{repo}/releases"

r = requests.get(query_url)
#pprint(r.json())

releases = list()
body = r.json()
for k in body:
    releases.append(k["tag_name"])
    assets = k["assets"]
    for a in assets:
        print(a["name"],a["browser_download_url"])
pprint(releases)
