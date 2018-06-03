#!/usr/bin/python

from distutils.version import LooseVersion

import argparse
import logging
import requests
import re

from update_release import  set_logging_config
from versions import _version

session = requests.Session()

# authorization token
TOKEN_URL = "https://auth.docker.io/token?service=registry.docker.io&scope=repository:%s:pull"

# find all tags
TAGS_URL =  "https://index.docker.io/v2/%s/tags/list"
TAG_RE = re.compile("^[\d]+(\.[\d]+)*$")

# get image digest for target
TARGET_DIGEST = "https://index.docker.io/v2/%(repository)s/manifests/%(tag)s"

class Fetcher:

    DIGEST_HEADER = {}

    def __init__(self, repository):
        self.repository = repository
        self.token = self.get_token()
        self.headers = {"Authorization": "Bearer %s"% self.token}
        self.headers_for_tags = {
            "Authorization": "Bearer %s"% self.token,
            "Accept": "application/vnd.docker.distribution.manifest.v2+json"
        }
        logging.debug("initialized fetcher for %s", self.repository)


    def get_token(self):
        response = session.get(TOKEN_URL % self.repository)
        response.raise_for_status()
        token = response.json().get("token")
        logging.debug("got token: %s", token)
        return token


    def get_versions(self):
        response = session.get(TAGS_URL % self.repository, headers=self.headers_for_tags)
        response.raise_for_status()
        all_tags = response.json().get("tags")
        numbered_tags = filter(lambda x: TAG_RE.match(x), all_tags)
        versions = map(LooseVersion, numbered_tags)
        logging.debug("got tags: %s", versions)
        return versions


def find_latest(repository):
    fetcher = Fetcher(repository)
    all_tags = fetcher.get_versions()
    return max(all_tags)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        usage="""Version checker script

This file retreives the latest version of ghost container image from docker hub
It can be run with both python 2.7 and 3.6""")
    parser.add_argument("repository", nargs='?', 
        help="repository name [default:library/ghost]",
        default="library/ghost")
    parser.add_argument('-v', '--version', action='store_true')
    parser.add_argument('-d', '--debug', action='store_true')
    parser.add_argument('-q', '--quiet', action='store_true')
    args = parser.parse_args()

    set_logging_config(quiet=args.quiet, debug=args.debug)
    logging.debug(args)

    # version needs to be print to output in order to be retrieved by Makefile
    if args.version:
        print(_version)
        raise SystemExit()

    print(find_latest(args.repository))
