import os
import requests
import yaml
from pprint import pprint

class repo:
    def __init__(self):
        self._repos = ["atlas-rd53-atca-dev", "atlas-rd53-fmc-dev"]
        self._owner = "slaclab"
        self._basedir = os.path.join(os.path.dirname(__file__), "../../etc")
        self._releases = list()
        self._boards = dict()
        self._targets = dict()
        data = None
        with open(f'{self._basedir}/targets.yaml') as f:
            data = yaml.load(f, Loader=yaml.FullLoader)

        for board in data:
            flavor = data[board]
            for fl in flavor:
                target = flavor[fl]
                if board not in self._boards:
                    self._boards[board] = list()
                self._boards[board].append([fl, target])
                if target not in self._targets:
                    self._targets[target] = dict()
        for repo in self._repos:
            query_url = f"https://api.github.com/repos/{self._owner}/{repo}/releases"
            r = requests.get(query_url)
            body = r.json()
            for k in body:
                self._releases.append(k["tag_name"])
                assets = k["assets"]
                for asset in assets:
                    (filename, ext) = os.path.splitext(asset["name"])
                    url = asset['browser_download_url']
                    try:
                        (board, rev, date, author, githash) = filename.split('-')
                    except:
                        pass
                    else:
                        if board in self._targets:
                            rev_entries = self._targets[board]
                            if rev not in rev_entries:
                                rev_entries[rev] = {
                                    'date': date,
                                    'author': author,
                                    'githash' : githash,
                                    'url_base' : None,
                                    'rel' : None,
                                    'files': dict()}
                            url_comp = url.split('/')
                            rel = url_comp[7]
                            filename = url_comp[8]
                            repo = url_comp[4]
                            owner = url_comp[3]
                            url_base = f"https://github.com/{owner}/{repo}/releases/download"
                            rev_entries[rev]['url_base'] = url_base
                            if filename not in rev_entries[rev]['files']:
                                rev_entries[rev]['files'][filename] = list()
                            rev_entries[rev]['files'][filename].append(rel)



        pprint(self._targets)

    def get_boards(self) -> list():
        return list(self._boards.keys())


r = repo()
boards = r.get_boards()
#pprint(boards)
